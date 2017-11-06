#!/usr/bin/env python

import argparse
import json
import sys
from collections import OrderedDict

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--ordereddict", "-o", dest="object_pairs_hook",
                        action="store_const", const=OrderedDict, default=None,
                        help="Parse the JSON file as an OrderedDict.")
    parser.add_argument("json_file", nargs="?", default=sys.stdin,
                        type=lambda f: open(f, "r"))
    args = parser.parse_args()

    j = json.load(args.json_file, object_pairs_hook=args.object_pairs_hook)
    if args.json_file != sys.stdin:
        args.json_file.close()

    print(json.dumps(j, indent=4, sort_keys=args.object_pairs_hook is None))

    sys.exit(0)

if __name__ == "__main__":
    main()
