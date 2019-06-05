#!/usr/bin/env python

##############################################################################
# csv-to-json.py
# ------------------------------------------
# Convert CSV input to a list of dictionaries in JSON format.
#
# Usage:
#       csv-to-json.py <filename>
#
# :authors: Omer Sne, @omersne, 0x65A9D22B299BA9B5
# :date: 2018-07-02
# :version: 0.0.2
##############################################################################

import argparse
import csv
import json
import sys

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("csv_file", nargs="?", default=sys.stdin)
    args = parser.parse_args()

    if hasattr(args.csv_file, "read"):
        reader = csv.DictReader(args.csv_file)
        j = [entry for entry in reader]
    else:
        with open(args.csv_file, "r") as file_obj:
            reader = csv.DictReader(file_obj)
            j = [entry for entry in reader]

    print(json.dumps(j, indent=4, sort_keys=True))
    sys.exit(0)

if __name__ == "__main__":
    main()
