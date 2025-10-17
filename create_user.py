#!/usr/bin/env python3
import mysql.connector
from werkzeug.security import generate_password_hash
import getpass
import config
import sys

# ✅ Function to create user safely
def create_user(username, plain_password, role, linked_id=None):
    if role not in ['admin', 'doctor', 'patient']:
        print("❌ Invalid role! Must be one of: admin, doctor, or patient.")
        return

    try:
        hashed = generate_password_hash(plain_password)

        cnx = mysql.connector.connect(**config.DB_CONFIG)
        cur = cnx.cursor()

        # Check for duplicate username
        cur.execute("SELECT username FROM Users WHERE username = %s", (username,))
        if cur.fetchone():
            print(f"⚠️ Username '{username}' already exists. Please choose another.")
            cur.close()
            cnx.close()
            return

        cur.execute("""
            INSERT INTO Users (username, password, role, linked_id)
            VALUES (%s, %s, %s, %s)
        """, (username, hashed, role, linked_id))

        cnx.commit()
        print(f"✅ User created successfully! → Username: {username}, Role: {role}")

    except mysql.connector.Error as err:
        print(f"❌ Database Error: {err}")
    except Exception as e:
        print(f"❌ Unexpected Error: {e}")
    finally:
        try:
            cur.close()
            cnx.close()
        except:
            pass


# ✅ Main entry point
if __name__ == "__main__":
    print("\n=== 🏥 Hospital Management System: Create User ===\n")

    try:
        username = input("👤 Enter username: ").strip()
        if not username:
            sys.exit("❌ Username cannot be empty.")

        password = getpass.getpass("🔒 Enter password: ").strip()
        if len(password) < 4:
            sys.exit("❌ Password must be at least 4 characters long.")

        role = input("🎭 Enter role (admin / doctor / patient): ").strip().lower()
        linked_id = input("🔗 Enter linked_id (doctor_id or patient_id) or leave blank: ").strip()
        linked_id = int(linked_id) if linked_id else None

        create_user(username, password, role, linked_id)
        print("\n✅ Done!\n")

    except KeyboardInterrupt:
        print("\n⚠️ Operation cancelled by user.")
    except Exception as e:
        print(f"\n❌ Error: {e}")

