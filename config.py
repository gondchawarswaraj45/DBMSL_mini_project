# config.py
import os

# ✅ Allow dynamic configuration via environment variables (for safety)
DB_CONFIG = {
    'user': os.getenv('DB_USER', 'swaraj'),
    'password': os.getenv('DB_PASSWORD', 'S123'),
    'host': os.getenv('DB_HOST', '127.0.0.1'),
    'database': os.getenv('DB_NAME', 'HospitalDB'),
    'raise_on_warnings': True,
    'autocommit': False,       # ✅ ensures explicit commits (for data safety)
    'charset': 'utf8mb4',      # ✅ supports Unicode characters properly
    'use_pure': True           # ✅ pure Python implementation (avoids C extension issues)
}

# ✅ Optional: For debugging, show which database is connected (disabled by default)
if __name__ == "__main__":
    print("✅ Database Configuration Loaded:")
    for key, value in DB_CONFIG.items():
        if key == 'password':
            print(f"{key}: {'*' * len(value)}")
        else:
            print(f"{key}: {value}")

