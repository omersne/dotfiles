#!/usr/bin/env python

##############################################################################
# parse-file-info-json.py
# ------------------------------------------
# Converts the values in the JSON file generated by get-file-dates.py to a human
# readable format.
#
# Usage:
#       parse-files-info-json.py
#
# :authors: Omer Sne, @omersne, 0x65A9D22B299BA9B5
# :date: 2017-09-12
# :version: 0.0.6
##############################################################################

import os
import sys
import argparse
import json
from datetime import datetime
from collections import OrderedDict

FILE_INFO_FORMAT_VERSION_IF_NOT_SPECIFIED = "0.0.1"
DEFAULT_INFO_FILE = "___FILE_INFO_01.json"

def bytes_to_size_units(i):
    size_units = [ "", "K", "M", "G", "T", "P" ]
    size_unit_index = 0

    i = float(i)
    while i >= 1024:
        i /= 1024.0
        size_unit_index += 1

    i = "{:.1f}".format(i)
    if float(i).is_integer():
        #i = str(int(float(i)))
        i = i.split(".")[0]
        if not size_units[size_unit_index]:
            return int(i)

    return i + size_units[size_unit_index]

def ts_to_date(ts):
    return datetime.fromtimestamp(ts).strftime("%Y-%m-%d %H:%M:%S")

def parse_file_info_dict_0_0_1(file_info):
    for key in [ "st_atime", "st_birthtime", "st_ctime", "st_mtime" ]:
        if key in file_info["stat"]:
            file_info["stat"][key] = ts_to_date(file_info["stat"][key])

    file_info["stat"]["st_mode"] = oct(file_info["stat"]["st_mode"])[-4:]

    for key in [ "st_blksize", "st_size" ]:
        file_info["stat"][key] = bytes_to_size_units(file_info["stat"][key])

    file_info["date_added_UTC"] = ts_to_date(file_info["date_added_UTC"])

    if "file_info_format_version" not in file_info:
        file_info["file_info_format_version"] = FILE_INFO_FORMAT_VERSION_IF_NOT_SPECIFIED

def parse_file_info_dict_0_0_4(file_info):
    file_info["date_added_UTC"] = ts_to_date(file_info["date_added_UTC"])
    file_info["mod_date"] = ts_to_date(file_info["mod_date"])
    file_info["size"] = bytes_to_size_units(file_info["size"])
    file_info["mode"] = oct(file_info["mode"])[-4:]

    if "file_info_format_version" not in file_info:
        file_info["file_info_format_version"] = FILE_INFO_FORMAT_VERSION_IF_NOT_SPECIFIED

FILE_INFO_VERSION_PARSING_FUNCS = {
    "0.0.1": parse_file_info_dict_0_0_1,
    "0.0.2": parse_file_info_dict_0_0_1,
    "0.0.3": parse_file_info_dict_0_0_1,
    "0.0.4": parse_file_info_dict_0_0_4,
    "0.0.5": parse_file_info_dict_0_0_4,
    "0.0.6": parse_file_info_dict_0_0_4,
}

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("filename", nargs="?", default=DEFAULT_INFO_FILE)
    args = parser.parse_args()

    with open(args.filename, "r") as f:
        FILES_INFO = json.load(f, object_pairs_hook=OrderedDict)

    for filename, digests in FILES_INFO.iteritems():
        for digest, file_info in digests.iteritems():
            try:
                info_format_version = file_info["file_info_format_version"]
            except KeyError:
                info_format_version = FILE_INFO_FORMAT_VERSION_IF_NOT_SPECIFIED

            FILE_INFO_VERSION_PARSING_FUNCS[info_format_version](file_info)

    print(json.dumps(FILES_INFO, indent=4))

    sys.exit(0)

if __name__ == "__main__":
    main()