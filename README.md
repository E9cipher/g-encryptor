# G-encryptor
## Overview
This project coded in python allows the user to encrypt/decrypt files in a specified directory.
## Modes
There are two modes, the user-friendly and the machine-friendly.
### User-friendly
Displays the menu, logo and options for user to select. Outputs every change it makes, including deletions, encryptions and decryptions
```bash
./g-encryptor.sh
```
and this will display the menu with its options
![Menu](images/screenshot.1.png)
### Machine-friendly
This is a mode which a script can call the file, pass an argument (encrypt/decrypt) and the script will do the thing
```bash
./g-encryptor.sh encrypt
./g-encryptor.sh decrypt
```
that will encrypt/decrypt the specified directory (`TARGET_DIR`)
## Usage
If you are in user mode, run just `./g-encryptor.sh`. If it is running on machine mode, run `./g-encryptor <encrypt|decrypt>`.

I'll update README.md soon
