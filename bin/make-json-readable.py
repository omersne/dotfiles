#!/usr/bin/env python

import argparse
import json
import sys

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("filename", nargs="?", default=sys.stdin)
    args = parser.parse_args()

    if isinstance(args.filename, file):
        j = json.load(args.filename)
    else:
        with open(args.filename, "r") as f:
            j = json.load(f)

    print json.dumps(j, indent=4, sort_keys=True)

    sys.exit(0)

if __name__ == "__main__":
    main()
