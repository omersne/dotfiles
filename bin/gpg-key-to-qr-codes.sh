#!/bin/bash

##############################################################################
# gpg-key-to-qr-codes.sh
# ------------------------------------------
# Encrypt an exported GPG key file symmetrically with a random password and then
# convert it to a series of QR code images.
# The reason why the exported key is encrypted again (assuming it already has a
# password) is so it can be scanned with an untrusted device (like a cell phone)
# and unlocked on a secure one with the random password which is only written on
# paper. After that decryption the user will still need to enter the password for
# their private key.
#
# Usage:
#       gpg-key-to-qr-codes.sh <key_file> <password_length>
#
# :authors: Omer Sne, @omersne, 0x65A9D22B299BA9B5
# :date: 2018-10-07
# :version: 0.0.1
##############################################################################

set -e

usage()
{
    sed -ne '/^#####/,/^#####/ p' "$0"
    exit 1
}

# Dependency verification
for program in gpg random-string.sh file-to-qr-codes.sh; do
    which "$program" > /dev/null
done

KEY_FILE="$1"
[ -r "$1" ] || usage
PASSWORD_LENGTH="$2"
[ -n "$2" ] || usage

PASSWORD="$(random-string.sh --length "$PASSWORD_LENGTH" | awk '{print $NF}')"
echo "Password: $PASSWORD"

TMP_DIR="$(mktemp -d /tmp/XXXXXXXXXXXXXXXX)"
[ -d "$TMP_DIR" ]
echo "Output directory: $TMP_DIR"

cat "$KEY_FILE" | gpg \
        --symmetric \
        --cipher-algo AES256 \
        --batch \
        --passphrase "$PASSWORD" \
        --armor > "$TMP_DIR/sec_enc.gpg.asc"

cd "$TMP_DIR"

file-to-qr-codes.sh sec_enc.gpg.asc
