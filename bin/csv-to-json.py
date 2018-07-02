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
# :version: 0.0.1
##############################################################################

import argparse
import csv
import json
import sys

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("csv_file", nargs="?", default=sys.stdin,
                        type=lambda f: open(f, "r"))
    args = parser.parse_args()

    dr = csv.DictReader(args.csv_file)
    j = [entry for entry in dr]

    print(json.dumps(j, indent=4, sort_keys=True))
    sys.exit(0)

if __name__ == "__main__":
    main()
