#!/usr/bin/env python

##############################################################################
# battery_status.py
# ------------------------------------------
# Get information about the current battery status of a laptop running Mac OS.
#
# Usage:
#       battery_status.py [--json] [--fields <fields>]
#
# :authors: Omer Sne, @omersne, 0x65A9D22B299BA9B5
# :date: 2017-11-07
# :version: 0.0.1
##############################################################################

import sys
import argparse
import re
import subprocess
import json
from collections import OrderedDict

TEST_OUTPUTS = [
    # MBP 2016 15", Sierra:
    "Now drawing from 'AC Power'\n -InternalBattery-0 (id=9999999)\t100%; charged; 0:00 remaining present: true\n",
    "Now drawing from 'AC Power'\n -InternalBattery-0 (id=9999999)\t89%; charging; (no estimate) present: true\n",
    "Now drawing from 'AC Power'\n -InternalBattery-0 (id=9999999)\t90%; charging; 1:16 remaining present: true\n",
    "Now drawing from 'Battery Power'\n -InternalBattery-0 (id=9999999)\t99%; discharging; 4:23 remaining present: true\n",
    "Now drawing from 'Battery Power'\n -InternalBattery-0 (id=9999999)\t97%; discharging; (no estimate) present: true\n",

    # MB Air 2015 13.3", El Capitan:
    "Now drawing from 'AC Power'\n -InternalBattery-0 \t100%; charged; 0:00 remaining present: true\n",
    "Now drawing from 'AC Power'\n -InternalBattery-0 \t99%; finishing charge; 0:31 remaining present: true\n",

    # MB Air 2014 13.3", El Capitan:
    "Now drawing from 'AC Power'\n -InternalBattery-0\t100%; charged; 0:00 remaining\n",

    # MBP 2015 13.3", El Capitan:
    "Now drawing from 'Battery Power'\n -InternalBattery-0\t71%; discharging; 4:49 remaining present: true\n",
    "Now drawing from 'AC Power'\n -InternalBattery-0\t88%; charging; 0:55 remaining present: true\n",
    "Now drawing from 'AC Power'\n -InternalBattery-0\t99%; finishing charge; 0:40 remaining present: true\n",
    "Now drawing from 'AC Power'\n -InternalBattery-0\t100%; charged; 0:00 remaining present: true\n",
    "Now drawing from 'Battery Power'\n -InternalBattery-0\t100%; discharging; (no estimate) present: true\n",
]

BATTERY_STATUS_CMD = [ "pmset", "-g", "batt" ]

OUTPUT_RE = re.compile("^Now drawing from '(?P<input>[\w\s]+)'\n"
                       "\s*-(?P<battery_name>\w+)-(?P<battery_num>[0-9]+)\s+"
                       "(?:\(id=(?P<battery_id>[0-9]+)\)\s+)?(?P<charge_level>[0-9]+%)\s*;\s*"
                       "(?P<charge_status>[\w\s]+);\s*"
                       "(?P<remaining>\(no estimate\)|[0-9]+:[0-9]+ remaining)"
                       "(?:\s+present:\s*(?P<present>true|false))?$",
                       flags=re.MULTILINE)

class BatteryStatusParserError(Exception):
    pass

def get_output():
    p = subprocess.Popen(BATTERY_STATUS_CMD, stdout=subprocess.PIPE)
    stdout = p.communicate()[0]
    p.wait()

    return stdout

def get_status_dict(re_match):
    status_dict = OrderedDict(sorted(re_match.groupdict().items()))
    conversion_table = {
        "true": True,
        "false": False,
        "null": None,
    }

    for key, value in status_dict.items():
        if value is None:
            continue
        elif value.isdigit():
            status_dict[key] = int(value)
        elif value in conversion_table:
            status_dict[key] = conversion_table[value]

    return status_dict

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--fields", "-f", dest="fields", default=None,
                        type=lambda x: x.split(","))
    parser.add_argument("--json", "-J", dest="json_output", default=False,
                        action="store_true")
    tests = parser.add_mutually_exclusive_group()
    tests.add_argument("--test", dest="test", default=False, action="store_true",
                       help=argparse.SUPPRESS)
    tests.add_argument("--get-output", dest="get_output", default=False,
                       action="store_true", help=argparse.SUPPRESS)
    args = parser.parse_args()

    if args.test:
        outputs = TEST_OUTPUTS
    elif args.get_output:
        print repr(get_output())
        sys.exit(0)
    else:
        outputs = [ get_output() ]

    for output in outputs:
        match = OUTPUT_RE.search(output)
        if not match:
            raise BatteryStatusParserError("Failed to parse the output of `{}'.\n".format(
                                           BATTERY_STATUS_CMD))

        status_dict = get_status_dict(match)
        if args.fields:
            status_dict = OrderedDict([ (key, status_dict[key]) for key in args.fields ])

        if args.json_output:
            print(json.dumps(status_dict, indent=4))
        else:
            for key, value in status_dict.items():
                print("{: <14} {}".format(key+":", value))

    sys.exit(0)

if __name__ == "__main__":
    main()
