import mysql.connector
from config import DB_CONFIG
from werkzeug.security import generate_password_hash

# ---------- CONNECT TO MYSQL SERVER ----------
connection = mysql.connector.connect(
    host=DB_CONFIG['host'],
    user=DB_CONFIG['user'],
    password=DB_CONFIG['password']
)
cursor = connection.cursor()

# ---------- CREATE DATABASE ----------
cursor.execute("CREATE DATABASE IF NOT EXISTS HospitalDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;")
cursor.execute("USE HospitalDB;")

# ---------- USERS TABLE ----------
cursor.execute("""
CREATE TABLE IF NOT EXISTS Users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role ENUM('admin','doctor','patient') NOT NULL,
  linked_id INT DEFAULT NULL
);
""")

# ---------- DEPARTMENT TABLE ----------
cursor.execute("""
CREATE TABLE IF NOT EXISTS Department (
  department_id INT AUTO_INCREMENT PRIMARY KEY,
  dept_name VARCHAR(100) UNIQUE NOT NULL
);
""")

# ---------- SPECIALIZATION TABLE ----------
cursor.execute("""
CREATE TABLE IF NOT EXISTS Specialization (
  specialization_id INT AUTO_INCREMENT PRIMARY KEY,
  specialization_name VARCHAR(100) UNIQUE NOT NULL
);
""")

# ---------- DOCTOR TABLE ----------
cursor.execute("""
CREATE TABLE IF NOT EXISTS Doctor (
  doctor_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  fees DECIMAL(10,2) DEFAULT 0,
  department_id INT,
  contact_no VARCHAR(50),
  specialization VARCHAR(100),
  shift_days VARCHAR(100),
  start_time TIME,
  end_time TIME,
  FOREIGN KEY (department_id) REFERENCES Department(department_id)
    ON DELETE SET NULL ON UPDATE CASCADE
);
""")

# ---------- PATIENT TABLE ----------
cursor.execute("""
CREATE TABLE IF NOT EXISTS Patient (
  patient_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  age INT,
  gender ENUM('Male','Female','Other'),
  contact_no VARCHAR(50),
  disease VARCHAR(100),
  room_id INT,
  doctor_id INT,
  FOREIGN KEY (doctor_id) REFERENCES Doctor(doctor_id)
    ON DELETE SET NULL ON UPDATE CASCADE
);
""")

# ---------- ROOM TABLE ----------
cursor.execute("""
CREATE TABLE IF NOT EXISTS Room (
  room_id INT AUTO_INCREMENT PRIMARY KEY,
  room_type VARCHAR(50),
  charges_per_day DECIMAL(10,2) DEFAULT 0,
  availability ENUM('Available','Occupied') DEFAULT 'Available'
);
""")

# ---------- DOCTOR SCHEDULE TABLE ----------
cursor.execute("""
CREATE TABLE IF NOT EXISTS DoctorSchedule (
  schedule_id INT AUTO_INCREMENT PRIMARY KEY,
  doctor_id INT,
  day_of_week VARCHAR(15),
  start_time TIME,
  end_time TIME,
  FOREIGN KEY (doctor_id) REFERENCES Doctor(doctor_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);
""")

# ---------- APPOINTMENT TABLE ----------
cursor.execute("""
CREATE TABLE IF NOT EXISTS Appointment (
  appointment_id INT AUTO_INCREMENT PRIMARY KEY,
  appointment_date DATE,
  time_slot TIME,
  patient_id INT,
  doctor_id INT,
  FOREIGN KEY (patient_id) REFERENCES Patient(patient_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (doctor_id) REFERENCES Doctor(doctor_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);
""")

# ---------- MEDICINE TABLE ----------
cursor.execute("""
CREATE TABLE IF NOT EXISTS Medicine (
  medicine_id INT AUTO_INCREMENT PRIMARY KEY,
  medicine_name VARCHAR(100) NOT NULL,
  manufacturer VARCHAR(100),
  stock INT DEFAULT 0
);
""")

# ---------- BILLING TABLE ----------
cursor.execute("""
CREATE TABLE IF NOT EXISTS Billing (
  bill_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT,
  doctor_id INT,
  total_amount DECIMAL(10,2),
  billing_date DATE DEFAULT (CURRENT_DATE),
  FOREIGN KEY (patient_id) REFERENCES Patient(patient_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (doctor_id) REFERENCES Doctor(doctor_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);
""")

# ---------- INSERT SAMPLE DATA ----------
cursor.executemany("""
INSERT IGNORE INTO Department (dept_name)
VALUES (%s)
""", [
    ('Cardiology',),
    ('Neurology',),
    ('Orthopedics',),
    ('Pediatrics',),
    ('General Medicine',),
    ('Dermatology',),
    ('ENT',),
    ('Oncology',),
    ('Urology',),
    ('Gynecology',)
])

# ---------- INSERT ALL SPECIALIZATIONS ----------
specializations = [
    ('Cardiology',), ('Neurology',), ('Neurosurgery',), ('Orthopedics',),
    ('Pediatrics',), ('Gastroenterology',), ('Endocrinology',), ('Pulmonology',),
    ('Dermatology',), ('Ophthalmology',), ('ENT (Otolaryngology)',),
    ('Oncology',), ('Radiology',), ('Pathology',), ('Anesthesiology',),
    ('General Medicine',), ('General Surgery',), ('Plastic Surgery',),
    ('Urology',), ('Nephrology',), ('Hematology',), ('Psychiatry',),
    ('Rheumatology',), ('Immunology',), ('Gynecology',), ('Obstetrics',),
    ('Dentistry',), ('Oral Surgery',), ('Ophthalmic Surgery',),
    ('Pediatric Surgery',), ('Nuclear Medicine',), ('Infectious Diseases',),
    ('Critical Care Medicine',), ('Pain Management',), ('Sports Medicine',),
    ('Family Medicine',), ('Physical Medicine & Rehabilitation',),
    ('Geriatrics',), ('Cosmetic Dermatology',), ('Pulmonary & Sleep Medicine',)
]
cursor.executemany("INSERT IGNORE INTO Specialization (specialization_name) VALUES (%s)", specializations)

# ---------- CREATE DEFAULT ADMIN USER ----------
admin_pass = generate_password_hash('admin123')
cursor.execute("""
INSERT IGNORE INTO Users (username, password, role)
VALUES ('admin', %s, 'admin')
""", (admin_pass,))

connection.commit()
cursor.close()
connection.close()

print("✅ HospitalDB initialized successfully with all tables, specializations, and admin user!")

