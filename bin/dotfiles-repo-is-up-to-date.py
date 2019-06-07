#!/usr/bin/env python

##############################################################################
# dotfiles-repo-is-up-to-date.py
# ------------------------------------------
# Check if the local dotfiles clone this script is run from is up to date with
# the origin in GitHub.
#
# Usage:
#       dotfiles-repo-is-up-to-date.py
#
# :authors: Omer Sne, @omersne, 0x65A9D22B299BA9B5
# :date: 2018-12-19
# :version: 0.0.2
##############################################################################

from __future__ import print_function
import sys
import os
import subprocess

import requests

DOTFILES_DIR = os.path.join(os.path.dirname(__file__), "..")

# https://developer.github.com/v3/repos/commits/#get-a-single-commit
API_REPO_INFO_URL = "https://api.github.com/repos/omersne/dotfiles/commits/master"
HEADERS = {
    "Accept": "application/vnd.github.VERSION.sha",
}

def main():
    req = requests.get(API_REPO_INFO_URL, headers=HEADERS)
    req.raise_for_status()
    origin_digest = req.text

    cmd = ["git", "-C", DOTFILES_DIR, "rev-parse", "HEAD"]
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout = proc.communicate()[0]
    proc.wait()
    local_digest = stdout.strip().decode("utf-8")

    if local_digest == origin_digest:
        print("dotfiles repo is up to date")
        sys.exit(0)
    else:
        print("dotfiles repo is not up to date, expected '{}', got '{}'".format(
              origin_digest, local_digest))
        sys.exit(1)

if __name__ == "__main__":
    main()
