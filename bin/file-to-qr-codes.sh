#!/bin/bash

##############################################################################
# file-to-qr-codes.sh
# ------------------------------------------
# Convert a file to a series of QR code images (png and svg).
#
# Based on https://gist.github.com/joostrijneveld/59ab61faa21910c8434c
#
# Usage:
#       file-to-qr-codes.sh <source_file>
#
# :authors: Omer Sne, @omersne, 0x65A9D22B299BA9B5
# :date: 2018-10-07
# :version: 0.0.1
##############################################################################

set -e

# https://github.com/fukuchi/libqrencode/issues/31#issuecomment-120911314
MAX_CHUNK_LENGTH=2953

SPLIT="split"
# The default version of `split' on Mac OS is problematic.
if [ "$(uname)" == "Darwin" ]; then
    SPLIT="gsplit"
fi

# Dependency verification
for program in "$SPLIT" "qrencode"; do
    which "$program" > /dev/null
done

FILENAME="$1"
[ -r "$FILENAME" ]

if [ "$(wc -c < "$FILENAME")" -gt "$MAX_CHUNK_LENGTH" ]; then
    "$SPLIT" "$FILENAME" -b "$MAX_CHUNK_LENGTH" --numeric-suffixes "${FILENAME}_chunk_"
    FILES_TO_CONVERT=("${FILENAME}_chunk_"*)
else
    FILES_TO_CONVERT=("$FILENAME")
fi

for file in "${FILES_TO_CONVERT[@]}"; do
    qrencode -8 -o "${file}_qr_code.png" < "$file"
    qrencode -8 -t SVG -o "${file}_qr_code.svg" < "$file"
done
