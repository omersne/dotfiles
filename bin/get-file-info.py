#!/usr/bin/env python

##############################################################################
# get-file-info.py
# ------------------------------------------
# Create a JSON file with the stat() information of versions of files.
# The version of a file is its SHA512 digest.
#
# Usage:
#       get-file-dates.py [-f <JSON file>] [-d <directory>]
#
# If a filename is not specified, the script will default to "___FILE_INFO_01.json"
# If a directory is not specified, the script will default to "."
#
# :authors: Omer Sne, @omersne, 0x65A9D22B299BA9B5
# :date: 2017-09-12
# :version: 0.0.12
##############################################################################

import os
import sys
import argparse
import json
import datetime
import hashlib
import time
import signal
import re
import glob
from collections import OrderedDict

FILE_VERSION_DIGEST_ALGO = "sha512"
FILE_VERSION_DIGEST_FUNC = getattr(hashlib, FILE_VERSION_DIGEST_ALGO)
FILE_IO_BLOCK_SIZE = 65536

FILE_INFO_FORMAT_VERSION = "0.0.7"

DEFAULT_INFO_FILE = "___FILE_INFO_01.json"

def get_file_version_digest(filename):
    digest = FILE_VERSION_DIGEST_FUNC()
    with open(filename, "rb") as f:
        for block in iter(lambda: f.read(FILE_IO_BLOCK_SIZE), b""):
            digest.update(block)

    return digest.hexdigest()

def is_json_serializable(value):
    try:
        json.dumps(value)
        return True
    except TypeError:
        return False

class GetFileInfo(object):

    def __init__(self, args):
        self.args = args

        try:
            with open(self.args.info_file, "r") as f:
                self.file_info = json.load(f, object_pairs_hook=OrderedDict)
        except IOError:
            print("'{}' does not exist. An empty dict will be used.".format(
                  self.args.info_file))
            self.file_info = OrderedDict()

        def signal_handler(signal, frame):
            if not self.args.no_dump_on_sigint:
                self.dump_json_file()
            print("Got Ctrl+C, exiting.")
            sys.exit(130)
        signal.signal(signal.SIGINT, signal_handler)

        self.patterns_to_ignore = [ re.compile(i) for i in self.args.ignore_patterns ]
        self.only_patterns = [ re.compile(i) for i in self.args.only_patterns ]

        self.filenames_to_ignore = []
        self.only_filenames = []

        if self.args.ignore_globs:
            self.filenames_to_ignore = self.get_glob_results(self.args.ignore_globs)
        elif self.args.only_globs:
            self.only_filenames = self.get_glob_results(self.args.only_globs)

        self.errors = []

        # `cd' to the base directory, so the dict keys will be relative paths.
        os.chdir(self.args.base_directory)

    def get_glob_results(self, glob_list):
        names = []
        #OS_WALK_PATH_START = "."
        for g in glob_list:
            #filenames += [ os.path.join(OS_WALK_PATH_START, i) for i in glob.glob(g) ]
            names += [ i for i in glob.glob(g) ]

        return names

    def should_ignore_filename(self, filename):
        if filename in self.filenames_to_ignore:
            return True
        for pattern in self.patterns_to_ignore:
            if pattern.search(filename):
                return True

        return False

    def only_filename(self, filename):
        if filename in self.only_filenames:
            return True
        for pattern in self.only_patterns:
            if pattern.search(filename):
                return True

        return False

    def should_check_file(self, filename):
        if os.path.abspath(filename) == os.path.abspath(self.args.info_file) and \
                not self.args.include_info_file:
            return False

        if self.filenames_to_ignore or self.patterns_to_ignore:
            if self.should_ignore_filename(filename):
                return False
            else:
                return True

        if self.only_filenames or self.only_patterns:
            if self.only_filename(filename):
                return True
            else:
                return False

        return True

    def get_stat_info(self, path):
        stat = os.lstat(path)

        info = OrderedDict()
        info["date_added_UTC"] = int(time.time())
        info["mod_date"] = int(stat.st_mtime)
        info["size"] = stat.st_size
        info["mode"] = stat.st_mode
        info["is_symlink"] = os.path.islink(path)
        if info["is_symlink"]:
            info["points_to"] = os.readlink(path)
            info["id_str"] = "{}_{}_{}_{}".format(
                             info["mod_date"], info["size"],
                             info["mode"], info["points_to"])
        info["file_info_format_version"] = FILE_INFO_FORMAT_VERSION

        return info

    def get_file_info(self):
        file_counter = 0
        changes_made = False
        for root, _, files in os.walk("."):
            for filename in files:
                filename = os.path.join(root, filename)
                if not self.should_check_file(filename):
                    continue

                print("{}:".format(filename))
                if self.args.dry_run:
                    continue

                if filename in self.file_info:
                    if self.args.skip_if_saved:
                        print("'{}' already exists in the info file.".format(filename))
                        continue
                else:
                    self.file_info[filename] = OrderedDict()

                info = self.get_stat_info(filename)

                # In case we want additional info that is an empty string/list/dict, etc...
                if self.args.additional_information is not None:
                    info["additional_information"] = self.args.additional_information

                if info["is_symlink"]:
                    digest = FILE_VERSION_DIGEST_FUNC(info["id_str"].encode("utf-8")).hexdigest()
                    file_version_digest = "SYMLINK_" + digest
                else:
                    try:
                        file_version_digest = get_file_version_digest(filename)
                    except IOError:
                        self.errors.append(filename)
                        continue

                print("    {}".format(file_version_digest))

                if file_version_digest in self.file_info[filename]:
                    print("The version of '{}' with the digest '{}' already exists in "
                          "the info file.".format(filename, file_version_digest))
                    continue

                self.file_info[filename][file_version_digest] = info
                changes_made = True

                file_counter += 1

                if self.args.constant_dump or (self.args.dump_every_number_of_files \
                        and file_counter % self.args.dump_every_number_of_files == 0):
                    print("Writing the JSON file")
                    self.dump_json_file()

        # XXX: Although the file contents would be the same if no changes were
        # made and the json was dumped again, the modification date would be
        # changed and I would prefer to prevent that.
        if changes_made:
            self.dump_json_file()

        if self.errors:
            print("Failed to get information about the following files: {}.".format(
                  self.errors))

        return len(self.errors) == 0

    def dump_json_file(self):
        with open(self.args.info_file, "w") as f:
            json.dump(self.file_info, f, indent=4)

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--directory", "-d", dest="base_directory", default=".")
    parser.add_argument("--info-file", "-f", dest="info_file", default=DEFAULT_INFO_FILE,
                        type=os.path.abspath)
    parser.add_argument("--skip-if-saved", "-k", dest="skip_if_saved",
                        action="store_true", default=False)
    parser.add_argument("--constant-dump", dest="constant_dump",
                        action="store_true", default=False)
    parser.add_argument("--dump-every-number-of-files", dest="dump_every_number_of_files",
                        default=None, type=int)
    parser.add_argument("--no-dump-on-sigint", dest="no_dump_on_sigint",
                        default=False, action="store_true")

    parser.add_argument("--dry-run", "-n", dest="dry_run", default=False,
                        action="store_true")

    parser.add_argument("--include-info-file", dest="include_info_file",
                        default=False, action="store_true")

    additional_info = parser.add_mutually_exclusive_group()
    additional_info.add_argument("--additional-information", "--additional-info", "-I",
                                 dest="additional_information", default=None)
    additional_info.add_argument("--additional-information-json", dest="additional_information",
                                 default=None, type=json.loads)

    patterns = parser.add_mutually_exclusive_group()
    patterns.add_argument("--ignore-patterns", dest="ignore_patterns", default=[],
                          action="append")
    patterns.add_argument("--only-patterns", dest="only_patterns", default=[],
                          action="append")

    globs = parser.add_mutually_exclusive_group()
    globs.add_argument("--ignore-globs", dest="ignore_globs", default=[],
                       action="append")
    globs.add_argument("--only-globs", dest="only_globs", default=[],
                       action="append")

    args = parser.parse_args()

    if (args.only_patterns or args.only_globs) and \
            (args.ignore_patterns or args.ignore_globs):
        parser.error("Conflicting only/ignore patterns/globs.")

    return args

def main():
    args = parse_args()

    sys.exit(0 if GetFileInfo(args).get_file_info() else 1)

if __name__ == "__main__":
    main()
