#!/usr/bin/env python

##############################################################################
# bitcoin-address-generator.py
# ------------------------------------------
# Generate a Bitcoin address from an ECDSA private key. If a key is not
# specified, the script will create a new one with openssl and use it for
# generating the Bitcoin address.
#
# :authors: Omer Sne, @omersne
# :date: 2017-08-12
# :version: 0.0.1
##############################################################################

import argparse
import sys
import base64
import json
import hashlib
import re
import subprocess
import binascii
from collections import OrderedDict

def read_file(filename):
    with open(filename, "r") as f:
        return f.read()

def create_key():
    cmd = [ "openssl", "ecparam", "-genkey", "-name", "secp256k1" ]
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (stdout, stderr) = p.communicate()
    p.wait()
    # XXX: openssl exit statuses are unreliable sometimes.
    if p.returncode != 0 or re.search("(error|invalid)", stderr, flags=re.IGNORECASE):
        raise Exception("Failed to generate a new ECDSA key.")

    return stdout

def sha256(s):
    return hashlib.sha256(s).digest()

def ripemd160(s):
    return hashlib.new("ripemd160", s).digest()

# Based on https://stackoverflow.com/a/561704
class Base58(object):
    ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    ALPHABET_REVERSE = dict((c, i) for (i, c) in enumerate(ALPHABET))
    BASE = len(ALPHABET)

    def __init__(self, data):
        self.data = data

    def encode(self):
        n = self.data
        leading_zeroes = 0

        if isinstance(n, str):
            if n.startswith("\x00"):
                leading_zeroes = len(re.search("^(\x00+)", n).group(1))
            n = int(binascii.hexlify(n), 16)

        s = []
        while True:
            n, r = divmod(n, self.BASE)
            s.append(self.ALPHABET[r])
            if n == 0:
                break

        while leading_zeroes > 0:
            s.append(self.ALPHABET[0])
            leading_zeroes -= 1

        return "".join(reversed(s))

    def decode(self):
        s = self.data
        n = 0
        for c in s:
            n = n * self.BASE + self.ALPHABET_REVERSE[c]

        return n

class KeyParser(object):
    def __init__(self, key):
        if self.is_pem_key(key):
            self.pem_key = key
            self.key = self.decode_pem_key(key)
        else:
            self.pem_key = None
            self.key = key

        self.private = self.key[7:39]
        self.public = self.key[-65:]

    def is_pem_key(self, key):
        return "-----BEGIN EC PRIVATE KEY-----" in key

    def decode_pem_key(self, key):
        # For keys that include the EC parameters section.
        private_key_section = re.search(
                "-----BEGIN EC PRIVATE KEY-----(.*)-----END EC PRIVATE KEY-----",
                key.replace("\n", "")).group(1)
        return base64.b64decode(private_key_section)

    def raw(self):
        return (self.public, self.private)

    def hex(self):
        public, private = self.raw()
        return (public.encode("hex"), private.encode("hex"))

class BitcoinAddressGenerator(object):
    VERSION_PREFIX = "\x00"

    def __init__(self, key):
        self.key = key

        # https://en.bitcoin.it/wiki/Technical_background_of_version_1_Bitcoin_addresses
        self.public_address = self.VERSION_PREFIX + ripemd160(sha256(self.key.public))
        checksum = sha256(sha256(self.public_address))[:4]
        self.public_address += checksum

        # https://en.bitcoin.it/wiki/Wallet_import_format
        self.private_address = "\x80" + self.key.private
        checksum = sha256(sha256(self.private_address))[:4]
        self.private_address += checksum

    def binary(self):
        return (self.public_address, self.private_address)

    def base58(self):
        return (Base58(self.public_address).encode(), Base58(self.private_address).encode())

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--key-file", "-k", dest="key_file",
                        help="Generate bitcoin addresses from an existing key.")
    parser.add_argument("--json", "-J", dest="json_output", action="store_true",
                        help="JSON output.")
    args = parser.parse_args()

    if args.key_file:
        key = KeyParser(read_file(args.key_file))
    else:
        key = KeyParser(create_key())

    address_info = OrderedDict()
    address_info["public_address"], address_info["private_address"] = \
            BitcoinAddressGenerator(key).base58()
    address_info["public_key"], address_info["private_key"] = key.hex()
    if key.pem_key:
        address_info["pem_key"] = key.pem_key

    if args.json_output:
        print json.dumps(address_info, indent=4)
    else:
        for key, value in address_info.iteritems():
            print "{}:{}{}".format(key, "\n" if "\n" in value else " ", value)

    sys.exit(0)

if __name__ == "__main__":
    main()
