#!/usr/bin/env python3
import sys
import os
from cryptography.fernet import Fernet

# GNOENCRYPT
key1 = b"VZ0dguatW7_4UnQPTn1r8rxC8aznZ0w-ERL4CBwKAI4="
fernet = Fernet(key1)

def should_skip(file_path):
    try:
        with open(file_path, "r", errors="ignore") as f:
            for line in f:
                if "GNOENCRYPT" in line:
                    return True
    except Exception:
        return False
    return False

files_to_encrypt = sys.argv[1:]
if not files_to_encrypt:
    print("ERROR: No files specified.", file=sys.stderr)
    sys.exit(1)

for file_to_encrypt in files_to_encrypt:
    if should_skip(file_to_encrypt):
        print(f"SKIPPED:{file_to_encrypt}")
        continue

    try:
        with open(file_to_encrypt, "rb") as f:
            data = f.read()

        encrypted_data = fernet.encrypt(data)
        encrypted_file = f"{file_to_encrypt}.enc"

        with open(encrypted_file, "wb") as f:
            f.write(encrypted_data)

        if os.path.exists(encrypted_file) and os.path.getsize(encrypted_file) > 0:
            os.remove(file_to_encrypt)
            print(f"ENCRYPTED:{file_to_encrypt}->{encrypted_file}")
        else:
            print(f"FAILED:{file_to_encrypt}:Encrypted file not created!", file=sys.stderr)

    except Exception as e:
        print(f"FAILED:{file_to_encrypt}:{e}", file=sys.stderr)

sys.exit(0)
