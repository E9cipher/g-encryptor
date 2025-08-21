#!/usr/bin/env python3
import sys
import hashlib
import requests
from cryptography.fernet import Fernet
import getpass
import os

# --- Ask password once ---
password = getpass.getpass("Enter password: ")
hash_pass = hashlib.sha256(password.encode()).hexdigest()

url = f"http://localhost/banana/index.php?hash={hash_pass}now"
response = requests.get(url)
if response.status_code != 200 or len(response.text.strip()) != 44:
    print("Wrong password or failed to get key.", file=sys.stderr)
    sys.exit(1)

key1 = response.text.strip().encode()
fernet = Fernet(key1)

files_to_decrypt = sys.argv[1:]
if not files_to_decrypt:
    print("No files specified.", file=sys.stderr)
    sys.exit(1)

def should_skip(file_path):
    try:
        with open(file_path, "r", errors="ignore") as f:
            for line in f:
                if "GNOENCRYPT" in line:
                    return True
    except:
        return False
    return False

for file_path in files_to_decrypt:
    if should_skip(file_path):
        print(f"SKIPPED:{file_path}")
        continue

    try:
        with open(file_path, "rb") as f:
            encrypted_data = f.read()

        decrypted_data = fernet.decrypt(encrypted_data)

        if file_path.endswith(".enc"):
            output_file = file_path[:-4]
        else:
            output_file = f"{file_path}.decrypted"

        with open(output_file, "wb") as f:
            f.write(decrypted_data)

        os.remove(file_path)

        print(f"DECRYPTED:{file_path}")
    except Exception as e:
        print(f"FAILED:{file_path}:{e}", file=sys.stderr)

sys.exit(0)
