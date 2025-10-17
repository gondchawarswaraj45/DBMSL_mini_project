from flask import Flask, render_template, request, redirect, url_for, flash, session
import mysql.connector
from functools import wraps
import datetime
import config

app = Flask(__name__)
app.secret_key = 'super_secure_key_123'

# =========================================================
# DATABASE CONNECTION
# =========================================================
def get_db_connection():
    return mysql.connector.connect(**config.DB_CONFIG)


# =========================================================
# LOGIN DECORATORS
# =========================================================
def login_required(f):
    """Ensure that only logged-in users can access certain pages."""
    @wraps(f)
    def wrapper(*args, **kwargs):
        if 'username' not in session:
            flash("Please log in to continue.", "warning")
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return wrapper


def roles_required(*roles):
    """Restrict access to specific user roles."""
    def decorator(f):
        @wraps(f)
        def wrapper(*args, **kwargs):
            if 'role' not in session or session['role'] not in roles:
                flash("Access denied: You don’t have permission to view this page.", "danger")
                return redirect(url_for('login'))
            return f(*args, **kwargs)
        return wrapper
    return decorator


# =========================================================
# INDEX / REDIRECT
# =========================================================
@app.route('/')
def index():
    """Redirect users to login or dashboard depending on their role."""
    if 'username' not in session:
        return redirect(url_for('login'))

    role = session.get('role')
    if role == 'admin':
        return redirect(url_for('admin_dashboard'))
    elif role == 'doctor':
        return redirect(url_for('doctor_dashboard'))
    elif role == 'patient':
        return redirect(url_for('patient_dashboard'))
    else:
        session.clear()
        flash("Invalid session. Please log in again.", "danger")
        return redirect(url_for('login'))


# =========================================================
# LOGIN / LOGOUT
# =========================================================
@app.route('/login', methods=['GET', 'POST'])
def login():
    """Plain-text login verification"""
    if request.method == 'POST':
        username = request.form['username'].strip()
        password = request.form['password']
        role = request.form['role']

        cnx = get_db_connection()
        cur = cnx.cursor(dictionary=True)
        cur.execute("SELECT * FROM Users WHERE username=%s AND role=%s", (username, role))
        user = cur.fetchone()
        cur.close()
        cnx.close()

        print("DEBUG → user:", user)

        if user and user['password'] == password:
            session['username'] = username
            session['role'] = role
            session['user_id'] = user['user_id']
            session['linked_id'] = user.get('linked_id', None)
            flash(f"Welcome {username}!", "success")

            if role == 'admin':
                return redirect(url_for('admin_dashboard'))
            elif role == 'doctor':
                return redirect(url_for('doctor_dashboard'))
            elif role == 'patient':
                return redirect(url_for('patient_dashboard'))
        else:
            flash("Invalid username, password, or role!", "danger")

    return render_template('login.html')


@app.route('/logout')
def logout():
    """Logout and clear session."""
    session.clear()
    flash("Logged out successfully!", "info")
    return redirect(url_for('login'))


# =========================================================
# DASHBOARDS
# =========================================================
@app.route('/admin/dashboard')
@roles_required('admin')
def admin_dashboard():
    cnx = get_db_connection()
    cur = cnx.cursor(dictionary=True)

    cur.execute("SELECT COUNT(*) AS total FROM Doctor")
    doctors = cur.fetchone()['total']

    cur.execute("SELECT COUNT(*) AS total FROM Patient")
    patients = cur.fetchone()['total']

    cur.execute("SELECT COUNT(*) AS total FROM Room")
    rooms = cur.fetchone()['total']

    cur.close()
    cnx.close()

    return render_template('admin_dashboard.html',
                           doctor_count=doctors,
                           patient_count=patients,
                           room_count=rooms)


@app.route('/doctor/dashboard')
@roles_required('doctor')
def doctor_dashboard():
    return render_template('doctor_dashboard.html')


@app.route('/patient/dashboard')
@roles_required('patient')
def patient_dashboard():
    return render_template('patient_dashboard.html')


# =========================================================
# ROOM CHART
# =========================================================
@app.route('/room_chart')
@roles_required('admin')
def patient_room_chart():
    cnx = get_db_connection()
    cur = cnx.cursor(dictionary=True)

    # Fetch room mapping with patients and doctors
    cur.execute("""
        SELECT 
            r.room_id,
            r.room_number,
            r.room_type,
            r.charges_per_day,
            r.bed_count,
            p.name AS patient_name,
            d.name AS doctor_name
        FROM Room r
        LEFT JOIN Patient p ON r.room_id = p.room_id
        LEFT JOIN Doctor d ON p.doctor_id = d.doctor_id
        ORDER BY r.room_id;
    """)
    rooms = cur.fetchall()

    # Summary stats
    cur.execute("SELECT COUNT(*) AS total FROM Room")
    total_rooms = cur.fetchone()['total']

    cur.execute("SELECT COUNT(DISTINCT room_id) AS occupied FROM Patient WHERE room_id IS NOT NULL")
    occupied_rooms = cur.fetchone()['occupied']

    cur.close()
    cnx.close()

    # ✅ FIXED: use rooms instead of rows
    return render_template('patient_room_chart.html',
                           rows=rooms,
                           total_rooms=total_rooms,
                           occupied_rooms=occupied_rooms)


# =========================================================
# DOCTOR MANAGEMENT
# =========================================================
@app.route('/doctors')
@roles_required('admin')
def doctor_list():
    cnx = get_db_connection()
    cur = cnx.cursor(dictionary=True)
    cur.execute("""
        SELECT d.doctor_id, d.name, d.specialization, d.contact_no, d.fees, dep.dept_name
        FROM Doctor d
        LEFT JOIN Department dep ON d.department_id = dep.department_id
    """)
    doctors = cur.fetchall()
    cur.close()
    cnx.close()
    return render_template('doctors.html', doctors=doctors)


@app.route('/doctors/add', methods=['GET', 'POST'])
@roles_required('admin')
def add_doctor():
    cnx = get_db_connection()
    cur = cnx.cursor(dictionary=True)

    if request.method == 'POST':
        name = request.form['name']
        fees = request.form['fees']
        department_id = request.form['department_id']
        specialization = ", ".join(request.form.getlist('specializations'))
        phones = ", ".join(request.form.getlist('phones[]'))

        cur.execute("""
            INSERT INTO Doctor (name, fees, department_id, specialization, contact_no)
            VALUES (%s, %s, %s, %s, %s)
        """, (name, fees, department_id, specialization, phones))
        cnx.commit()
        flash("Doctor added successfully!", "success")
        cur.close()
        cnx.close()
        return redirect(url_for('doctor_list'))

    cur.execute("SELECT * FROM Department")
    departments = cur.fetchall()

    specialties = [
    {"specialization_name": s} for s in [
        'General Medicine', 'General Surgery', 'Cardiology', 'Neurology', 'Neurosurgery',
        'Orthopaedics', 'Pediatrics', 'Obstetrics & Gynecology', 'Dermatology', 'Psychiatry',
        'ENT (Otorhinolaryngology)', 'Ophthalmology', 'Anesthesiology', 'Radiology', 'Pathology',
        'Oncology', 'Nephrology', 'Urology', 'Gastroenterology', 'Pulmonology', 'Endocrinology',
        'Rheumatology', 'Hematology', 'Infectious Diseases', 'Geriatrics', 'Plastic & Reconstructive Surgery',
        'Pediatric Surgery', 'Cardiothoracic & Vascular Surgery', 'Critical Care Medicine', 'Emergency Medicine',
        'Family Medicine', 'Sports Medicine', 'Physical Medicine & Rehabilitation', 'Dentistry',
        'Forensic Medicine', 'Nuclear Medicine'
    ]
]


    cur.close()
    cnx.close()
    return render_template('add_doctor.html', departments=departments, specialties=specialties)


# =========================================================
# DOCTOR SCHEDULE
# =========================================================
@app.route('/doctor/<int:doctor_id>/schedule', methods=['GET', 'POST'])
@roles_required('admin', 'doctor')
def doctor_schedule(doctor_id):
    cnx = get_db_connection()
    cur = cnx.cursor(dictionary=True)

    if request.method == 'POST':
        day = request.form['day']
        start_time = request.form['start_time']
        end_time = request.form['end_time']

        if start_time >= end_time:
            flash("⚠️ End time must be after start time!", "danger")
            cur.close()
            cnx.close()
            return redirect(url_for('doctor_schedule', doctor_id=doctor_id))

        cur.execute("""
            INSERT INTO DoctorSchedule (doctor_id, day_of_week, start_time, end_time)
            VALUES (%s, %s, %s, %s)
        """, (doctor_id, day, start_time, end_time))
        cnx.commit()
        flash("✅ Schedule added successfully!", "success")

        cur.close()
        cnx.close()
        return redirect(url_for('doctor_schedule', doctor_id=doctor_id))

    cur.execute("""
        SELECT schedule_id, day_of_week, start_time, end_time
        FROM DoctorSchedule
        WHERE doctor_id = %s
    """, (doctor_id,))
    schedule = cur.fetchall()

    for s in schedule:
        if isinstance(s['start_time'], datetime.timedelta):
            s['start_time'] = str((datetime.datetime.min + s['start_time']).time())[:-3]
        if isinstance(s['end_time'], datetime.timedelta):
            s['end_time'] = str((datetime.datetime.min + s['end_time']).time())[:-3]

    cur.close()
    cnx.close()
    return render_template('doctor_schedule.html', schedule=schedule, doctor_id=doctor_id)


@app.route('/doctor/<int:doctor_id>/schedule/delete/<int:schedule_id>')
@roles_required('admin', 'doctor')
def delete_schedule(doctor_id, schedule_id):
    """Delete a specific doctor's schedule entry."""
    cnx = get_db_connection()
    cur = cnx.cursor()
    cur.execute("DELETE FROM DoctorSchedule WHERE schedule_id = %s", (schedule_id,))
    cnx.commit()
    cur.close()
    cnx.close()
    flash("🗑️ Schedule deleted successfully!", "info")
    return redirect(url_for('doctor_schedule', doctor_id=doctor_id))


# =========================================================
# APPOINTMENTS (FILTERED BY ROLE)
# =========================================================
@app.route('/appointments')
@roles_required('admin', 'doctor', 'patient')
def appointments_list():
    cnx = get_db_connection()
    cur = cnx.cursor(dictionary=True)

    role = session.get('role')
    linked_id = session.get('linked_id')  # doctor_id or patient_id

    # ADMIN → sees all appointments
    if role == 'admin':
        cur.execute("""
            SELECT a.appointment_id, a.appointment_date, a.time_slot,
                   p.name AS patient_name, d.name AS doctor_name
            FROM Appointment a
            JOIN Patient p ON a.patient_id = p.patient_id
            JOIN Doctor d ON a.doctor_id = d.doctor_id
            ORDER BY a.appointment_date DESC;
        """)
    
    # DOCTOR → sees only appointments for their patients
    elif role == 'doctor':
        cur.execute("""
            SELECT a.appointment_id, a.appointment_date, a.time_slot,
                   p.name AS patient_name, d.name AS doctor_name
            FROM Appointment a
            JOIN Patient p ON a.patient_id = p.patient_id
            JOIN Doctor d ON a.doctor_id = d.doctor_id
            WHERE a.doctor_id = %s
            ORDER BY a.appointment_date DESC;
        """, (linked_id,))
    
    # PATIENT → sees only their own appointments
    elif role == 'patient':
        cur.execute("""
            SELECT a.appointment_id, a.appointment_date, a.time_slot,
                   p.name AS patient_name, d.name AS doctor_name
            FROM Appointment a
            JOIN Patient p ON a.patient_id = p.patient_id
            JOIN Doctor d ON a.doctor_id = d.doctor_id
            WHERE a.patient_id = %s
            ORDER BY a.appointment_date DESC;
        """, (linked_id,))

    appointments = cur.fetchall()
    cur.close()
    cnx.close()

    # Split upcoming vs completed
    current_date = datetime.date.today()
    upcoming = [a for a in appointments if a['appointment_date'] >= current_date]
    completed = [a for a in appointments if a['appointment_date'] < current_date]

    return render_template(
        'appointments.html',
        role=role,
        upcoming=upcoming,
        completed=completed,
        current_date=current_date
    )


# =========================================================
#           ADD APPOINTMENT (ADMIN or PATIENT)
# =========================================================

@app.route('/appointments/add', methods=['GET', 'POST'])
@roles_required('admin', 'patient')
def add_appointment():
    cnx = get_db_connection()
    cur = cnx.cursor(dictionary=True)

    if request.method == 'POST':
        date = request.form['appointment_date']
        time = request.form['appointment_time']
        pid = request.form['patient_id']
        did = request.form['doctor_id']

        # Determine the day of the week
        day = datetime.datetime.strptime(date, '%Y-%m-%d').strftime('%A')

        # ✅ Check if the doctor is available at that day and time
        cur.execute("""
            SELECT * FROM DoctorSchedule
            WHERE doctor_id=%s AND day_of_week=%s 
              AND %s BETWEEN start_time AND end_time;
        """, (did, day, time))
        available = cur.fetchone()

        if not available:
            flash("⚠️ Doctor not available at that time!", "danger")
            cur.close()
            cnx.close()
            return redirect(url_for('add_appointment'))

        # ✅ Book the appointment
        cur.execute("""
            INSERT INTO Appointment (appointment_date, time_slot, patient_id, doctor_id)
            VALUES (%s, %s, %s, %s);
        """, (date, time, pid, did))
        cnx.commit()
        flash("✅ Appointment booked successfully!", "success")

        cur.close()
        cnx.close()
        return redirect(url_for('appointments_list'))

    # ✅ Fetch doctors with specialization, department, and fees
    cur.execute("""
        SELECT d.doctor_id, d.name, d.specialization, d.fees, dep.dept_name
        FROM Doctor d
        LEFT JOIN Department dep ON d.department_id = dep.department_id
        ORDER BY dep.dept_name, d.name;
    """)
    doctors = cur.fetchall()

    # ✅ Fetch patients
    cur.execute("SELECT patient_id, name FROM Patient;")
    patients = cur.fetchall()

    # ✅ Get today's date (for date input min attribute)
    current_date = datetime.date.today()

    # ✅ If logged in as patient, auto-fill their patient_id
    patient_id = None
    if session.get('role') == 'patient':
        # fetch linked patient_id from Users table
        cur.execute("SELECT linked_id FROM Users WHERE user_id = %s", (session['user_id'],))
        record = cur.fetchone()
        if record:
            patient_id = record['linked_id']

    cur.close()
    cnx.close()

    return render_template(
        'add_appointment.html',
        doctors=doctors,
        patients=patients,
        current_date=current_date,
        patient_id=patient_id
    )

# =========================================================
# BILLING
# =========================================================
@app.route('/billing')
@roles_required('admin', 'patient')
def billing():
    cnx = get_db_connection()
    cur = cnx.cursor(dictionary=True)
    cur.execute("""
        SELECT p.name AS patient_name, d.name AS doctor_name, d.fees AS doctor_fee,
               (d.fees + 500) AS total_bill
        FROM Patient p
        JOIN Doctor d ON p.doctor_id = d.doctor_id
        LIMIT 10
    """)
    bills = cur.fetchall()
    cur.close()
    cnx.close()
    return render_template('billing.html', bills=bills)


@app.route('/generate_invoice')
@roles_required('admin', 'patient')
def generate_invoice():
    flash("Invoice generation feature coming soon!", "info")
    return redirect(url_for('billing'))


# =========================================================
# REPORTS
# =========================================================
@app.route('/reports')
@roles_required('admin')
def reports():
    cnx = get_db_connection()
    cur = cnx.cursor(dictionary=True)

    cur.execute("""
        SELECT d.name AS doctor, COUNT(a.appointment_id) AS total_appointments
        FROM Doctor d
        LEFT JOIN Appointment a ON d.doctor_id = a.doctor_id
        GROUP BY d.name;
    """)
    appt_by_doc = cur.fetchall()

    cur.execute("""
        SELECT room_id, room_type, IFNULL(charges_per_day, 500) AS charges_per_day
        FROM Room;
    """)
    available_rooms = cur.fetchall()

    cur.execute("""
        SELECT medicine_name, manufacturer, stock
        FROM Medicine
        WHERE stock < 20;
    """)
    low_stock = cur.fetchall()

    cur.execute("""
        SELECT dept_name, SUM(d.fees) AS revenue
        FROM Department dep
        JOIN Doctor d ON dep.department_id = d.department_id
        JOIN Patient p ON d.doctor_id = p.doctor_id
        GROUP BY dep.dept_name;
    """)
    revenue_by_dept = cur.fetchall()

    cur.close()
    cnx.close()

    return render_template('reports.html',
                           appt_by_doc=appt_by_doc,
                           available_rooms=available_rooms,
                           low_stock=low_stock,
                           revenue_by_dept=revenue_by_dept)
                           
# =========================================================
# ADMISSION MANAGEMENT
# =========================================================
@app.route('/admissions', methods=['GET', 'POST'])
@roles_required('admin')
def manage_admissions():
    cnx = get_db_connection()
    cur = cnx.cursor(dictionary=True)

    if request.method == 'POST':
        patient_id = request.form['patient_id']
        doctor_id = request.form['doctor_id']
        room_id = request.form['room_id']
        admission_date = request.form['admission_date']
        relative_name = request.form['relative_name']
        relative_contact = request.form['relative_contact']
        relative_address = request.form['relative_address']
        patient_address = request.form['patient_address']

        # ✅ Validate 10-digit mobile number
        if not relative_contact.isdigit() or len(relative_contact) != 10:
            flash("⚠️ Invalid mobile number! Please enter a 10-digit number.", "danger")
            cur.close()
            cnx.close()
            return redirect(url_for('manage_admissions'))

        # ✅ Check if room is available
        cur.execute("SELECT availability FROM Room WHERE room_id=%s", (room_id,))
        room = cur.fetchone()

        if not room or room['availability'] == 0:
            flash("❌ Selected room is already occupied!", "danger")
        else:
            # ✅ Insert admission record (with doctor_id)
            cur.execute("""
                INSERT INTO Admission (
                    patient_id, doctor_id, room_id, admission_date,
                    relative_name, relative_contact, relative_address, patient_address
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """, (patient_id, doctor_id, room_id, admission_date,
                  relative_name, relative_contact, relative_address, patient_address))

            # ✅ Mark room occupied
            cur.execute("UPDATE Room SET availability=0 WHERE room_id=%s", (room_id,))

            # ✅ Link patient to room
            cur.execute("UPDATE Patient SET room_id=%s WHERE patient_id=%s", (room_id, patient_id))

            cnx.commit()
            flash("✅ Patient admitted successfully!", "success")

        cur.close()
        cnx.close()
        return redirect(url_for('manage_admissions'))

    # ============================================================
    # Fetch lists for dropdowns
    # ============================================================
    cur.execute("SELECT patient_id, name FROM Patient")
    patients = cur.fetchall()

    cur.execute("SELECT doctor_id, name, specialization FROM Doctor")
    doctors = cur.fetchall()

    cur.execute("SELECT room_id, room_number, room_type FROM Room WHERE availability=1")
    rooms = cur.fetchall()

    # ============================================================
    # Fetch all current admissions
    # ============================================================
    cur.execute("""
        SELECT a.admission_id, p.name AS patient_name, d.name AS doctor_name, 
               r.room_number, r.room_type, a.admission_date,
               a.relative_name, a.relative_contact
        FROM Admission a
        JOIN Patient p ON a.patient_id = p.patient_id
        JOIN Doctor d ON a.doctor_id = d.doctor_id
        JOIN Room r ON a.room_id = r.room_id
        ORDER BY a.admission_date DESC
    """)
    admissions = cur.fetchall()

    cur.close()
    cnx.close()

    return render_template('admissions.html',
                           patients=patients,
                           doctors=doctors,
                           rooms=rooms,
                           admissions=admissions)

# ============================================================
#               DISCHARGE
# ============================================================

@app.route('/discharge', methods=['GET', 'POST'])
@roles_required('admin')
def discharge_patient():
    cnx = get_db_connection()
    cur = cnx.cursor(dictionary=True)

    if request.method == 'POST':
        admission_id = request.form['admission_id']
        discharge_date = request.form['discharge_date']
        medicine_charges = float(request.form['medicine_charges'])

        # Fetch admission details
        cur.execute("""
            SELECT a.admission_date, a.room_id, a.doctor_id,
                   DATEDIFF(%s, a.admission_date) AS days_stayed
            FROM Admission a
            WHERE a.admission_id=%s
        """, (discharge_date, admission_id))
        admission = cur.fetchone()

        # Ensure valid days
        days = max(admission['days_stayed'], 1)

        # Fetch doctor fee and room rate
        cur.execute("SELECT fees FROM Doctor WHERE doctor_id=%s", (admission['doctor_id'],))
        doctor_fee = cur.fetchone()['fees']

        cur.execute("SELECT charges_per_day FROM Room WHERE room_id=%s", (admission['room_id'],))
        room_rate = cur.fetchone()['charges_per_day']

        room_charges = room_rate * days

        cur.execute("""
            INSERT INTO Discharge (admission_id, discharge_date, doctor_fees, room_charges, medicine_charges, payment_status)
            VALUES (%s, %s, %s, %s, %s, 'Paid')
        """, (admission_id, discharge_date, doctor_fee, room_charges, medicine_charges))

        # Free the room again
        cur.execute("UPDATE Room SET availability=1 WHERE room_id=%s", (admission['room_id'],))
        cnx.commit()

        cur.close()
        cnx.close()

        flash(f"✅ Patient discharged successfully. Room freed. Total days stayed: {days}", "success")
        return redirect(url_for('discharge_patient'))

    # Fetch active admissions
    cur.execute("""
        SELECT a.admission_id, p.name AS patient_name, r.room_number, r.room_type
        FROM Admission a
        JOIN Patient p ON a.patient_id=p.patient_id
        JOIN Room r ON a.room_id=r.room_id
        WHERE a.admission_id NOT IN (SELECT admission_id FROM Discharge)
    """)
    active_admissions = cur.fetchall()

    # Fetch discharge records
    cur.execute("""
        SELECT d.discharge_id, p.name AS patient_name, d.discharge_date,
               d.doctor_fees, d.room_charges, d.medicine_charges, d.total_bill, d.payment_status
        FROM Discharge d
        JOIN Admission a ON d.admission_id=a.admission_id
        JOIN Patient p ON a.patient_id=p.patient_id
        ORDER BY d.discharge_date DESC
    """)
    discharges = cur.fetchall()

    cur.close()
    cnx.close()
    return render_template('discharge.html', active_admissions=active_admissions, discharges=discharges)



# =========================================================
# RUN APP
# =========================================================
if __name__ == '__main__':
    print("\n✅ Registered Routes:")
    for rule in app.url_map.iter_rules():
        print(rule, "→", rule.endpoint)
    app.run(debug=True)

