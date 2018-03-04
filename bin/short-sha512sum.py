#!/usr/bin/env python

##############################################################################
# short-<hash_algo>.py
# ------------------------------------------
# Print the digest of a file represented in base64.
#
# Example:
# $ sha256sum <<< abc
# edeaaff3f1774ad2888673770c6d64097e391bc362d7d6fb34982ddf0efd18cb  -
# $ short-sha256sum.py <<< abc
# O3qr_Pxd0rSiIZzdwxtZAl-ORvDYtfW-zSYLd8O_RjL  -
#
# Usage:
#       short-<hash_algo>.py <filenames>
#
# :authors: Omer Sne, @omersne, 0x65A9D22B299BA9B5
# :date: 2018-02-26
# :version: 0.0.1
##############################################################################

import sys
import os
import argparse
import hashlib
import re

HASH_BLOCK_SIZE = 65536
HASH_ALGOS = {
    "short-md5sum.py":    hashlib.md5,
    "short-sha1sum.py":   hashlib.sha1,
    "short-sha224sum.py": hashlib.sha256,
    "short-sha256sum.py": hashlib.sha256,
    "short-sha384sum.py": hashlib.sha384,
    "short-sha512sum.py": hashlib.sha512,
}

# Based on https://stackoverflow.com/a/561704
class Encoder(object):
    ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
    ALPHABET_REVERSE = { c: i for i, c in enumerate(ALPHABET) }
    BASE = len(ALPHABET)
    SIGN_CHARACTER = "$"

    @classmethod
    def encode(cls, n):
        leading_zeroes = 0
        if isinstance(n, basestring):
            if n.startswith("0"):
                leading_zeroes = len(re.search("^(0+)", n).group(1))
            n = int(n, 16)

        if n < 0:
            return cls.SIGN_CHARACTER + encode(-n)
        s = []
        while True:
            n, r = divmod(n, cls.BASE)
            s.append(cls.ALPHABET[r])
            if n == 0: break
        return "".join(reversed(s))

    @classmethod
    def decode(cls, s):
        if s[0] == cls.SIGN_CHARACTER:
            return -decode(s[1:])
        n = 0
        for c in s:
            n = n * cls.BASE + cls.ALPHABET_REVERSE[c]
        return n

def main():
    script_name = os.path.basename(__file__)
    if script_name not in HASH_ALGOS:
        raise RuntimeError("Invalid script name: `{}'.".format(script_name))

    hash_algo = HASH_ALGOS[script_name]

    parser = argparse.ArgumentParser()
    parser.add_argument("filenames", nargs="*", default=[ "/dev/stdin" ])
    args = parser.parse_args()

    for filename in args.filenames:
        hasher = hash_algo()

        with open(filename, "rb") as fd:
            for block in iter(lambda: fd.read(HASH_BLOCK_SIZE), b""):
                hasher.update(block)

        print "{}  {}".format(Encoder.encode(hasher.hexdigest()),
                              "-" if filename == "/dev/stdin" else filename)

    sys.exit(0)

if __name__ == "__main__":
    main()
