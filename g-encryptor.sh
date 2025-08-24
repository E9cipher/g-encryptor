#!/bin/bash
# GNOENCRYPT

CONFIG_DIR="config/"
CONFIG_FILE="$CONFIG_DIR/config.ini"
LOGO_FILE="$CONFIG_DIR/logo.txt"
source "$CONFIG_DIR/colors.txt"


if [ -f "$CONFIG_FILE" ]; then
    TARGET_DIR=$(grep -m1 '^directory=' "$CONFIG_FILE" | cut -d'=' -f2- | xargs)

    # tilde present?
    if [[ "$TARGET_DIR" == ~* ]]; then
        TARGET_DIR="${TARGET_DIR/#\~/$HOME}"
    fi

    # Failsafe: default to .
    [ -z "$TARGET_DIR" ] && TARGET_DIR="."
else
    TARGET_DIR="."
fi


if [ -n "$1" ]; then
    OP="$1"
    case "$OP" in
        encrypt)
            encrypt
            ;;
        decrypt)
            decrypt
            ;;
        *)
            echo "Unknown operation: $OP"
            exit 1
            ;;
    esac
fi

function logo () {
    echo -e $yellow"$(tail -n +2 $LOGO_FILE)"
    echo -e $reset ""
}

function encrypt () {
    echo -e $yellow"Starting encryption process"$reset
    sleep 0.3

    if [ ! -d "$TARGET_DIR" ]; then
        echo -e $red"Target directory not found: $TARGET_DIR"$reset
        sleep 1
        menu
    fi

    # Recursively find all files (exclude .enc files)
    mapfile -d '' files < <(find "$TARGET_DIR" -type f ! -name "*.enc" -print0 2>/dev/null)

    if [ ${#files[@]} -eq 0 ]; then
        echo -e $red"No files to encrypt."$reset
    else
        for file in "${files[@]}"; do
            if grep -q "NOENCRYPT" "$file"; then
                echo -e $yellow"Skipped (NOENCRYPT): $file"$reset
                continue
            fi

            result=$(./encrypt.py "$file")
            case "$result" in
                ENCRYPTED:*)
                    orig_file="${result#ENCRYPTED:}"
                    echo -e $green"Encrypted: $orig_file"$reset
                    sleep 0.5
                    ;;
                SKIPPED:*)
                    skipped_file="${result#SKIPPED:}"
                    echo -e $yellow"Skipped: $skipped_file"$reset
                    sleep 0.5
                    ;;
                FAILED:*)
                    echo -e $red"$result"$reset
                    sleep 1
                    ;;
                *)
                    echo "$result"
                    ;;
            esac
        done
    fi

    echo -e $green"Done."$reset
    sleep 1
    menu
}

function decrypt () {
    echo -e $yellow"Starting decryption process.."$reset
    sleep 0.3

    if [ ! -d "$TARGET_DIR" ]; then
        echo -e $red"Target directory not found: $TARGET_DIR"$reset
        sleep 1
        menu
    fi

    # Recursively find all .enc files
    mapfile -d '' files < <(find "$TARGET_DIR" -type f -name "*.enc" -print0 2>/dev/null)

    if [ ${#files[@]} -eq 0 ]; then
        echo -e $red"No files to decrypt."$reset
    else
        # Pass all files to decrypt.py
        result=$(./decrypt.py "${files[@]}")
        # Line-by-line decryption
        while IFS= read -r line; do
            case "$line" in
                DECRYPTED:*)
                    orig_file="${line#DECRYPTED:}"
                    echo -e $green"Decrypted: $orig_file"$reset
                    rm -f "$orig_file.enc" 2>/dev/null
                    sleep 0.5
                    ;;
                SKIPPED:*)
                    skipped_file="${line#SKIPPED:}"
                    echo -e $yellow"Skipped: $skipped_file"$reset
                    sleep 0.5
                    ;;
                FAILED:*)
                    echo -e $red"$line"$reset
                    sleep 1
                    ;;
                *)
                    echo "$line"
                    ;;
            esac
        done <<< "$result"
    fi

    echo -e $green"Done"$reset
    sleep 1
    menu
}

function menu () {
    clear
    logo
    echo -e $blue"Choose an option: "
    echo "[1] Install packages"
    echo "[2] Encrypt File"
    echo "[3] Decrypt File"
    echo "[4] Edit config directory path"
    echo "[5] Exit"
    echo ""
    echo -n -e $reset"Choose: "
    read choice

    case "$choice" in
        1)
            # Do we have sudo?
            if ! command -v sudo &>/dev/null; then
                echo -e $red"Error: sudo not found. Please run as root."$reset
                exit 1
            fi
            echo -e $yellow"Installing required packages.."$reset
            sleep 0.1
            sudo apt update > /dev/null 2>&1 && sudo apt install -y python3-requests python3-cryptography python3 python3-hashlib python3-getpass > /dev/null 2>&1
            echo -e $green"Done."$reset
            sleep 0.3
            menu
            ;;
        2)
            encrypt
            ;;
        3)
            decrypt
            ;;
        4)
            echo -e $yellow"Current directory path: $TARGET_DIR"
            echo -n -e $yellow"Enter new directory path: "$reset
            read new_dir
            new_dir="${new_dir%/}"   # remove slash
            TARGET_DIR="$new_dir"
            if [ -d "$TARGET_DIR" ]; then
                if grep -q "^target_dir" config/config.ini; then
                    sed -i "s|^target_dir *=.*|target_dir = $TARGET_DIR|" config/config.ini
                else
                    sed -i "/\[settings\]/a target_dir = $TARGET_DIR" config/config.ini
                fi
                echo -e $green"Directory updated to $TARGET_DIR"$reset
                sleep 1
            else
                echo -e $red"Directory does not exist. No changes made."$reset
                sleep 1
            fi
            menu
            ;;
        5)
            echo "Quitting.."
            exit 0
            ;;
        *)
            echo -e $red"Invalid option" $reset
            sleep 1
            menu
            ;;
    esac
}
menu