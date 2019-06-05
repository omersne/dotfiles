#!/usr/bin/env python

##############################################################################
# make-json-readable.py
# ------------------------------------------
# Print JSON input with more readable indentation.
#
# Usage:
#       make-json-readable.py <json_file>
#
# :authors: Omer Sne, @omersne, 0x65A9D22B299BA9B5
# :date: 2017-07-02
# :version: 0.0.5
##############################################################################

import argparse
import json
import sys
from collections import OrderedDict

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--ordereddict", "-o", dest="object_pairs_hook",
                        action="store_const", const=OrderedDict, default=None,
                        help="Parse the JSON file as an OrderedDict.")
    parser.add_argument("json_file", nargs="?", default=sys.stdin)
    args = parser.parse_args()

    if hasattr(args.json_file, "read"):
        j = json.load(args.json_file, object_pairs_hook=args.object_pairs_hook)
    else:
        with open(args.json_file, "r") as file_obj:
            j = json.load(file_obj, object_pairs_hook=args.object_pairs_hook)

    print(json.dumps(j, indent=4, sort_keys=args.object_pairs_hook is None))

    sys.exit(0)

if __name__ == "__main__":
    main()
