#!/bin/bash

rsync -vvae ssh --progress --human-readable --partial-dir='.___rsync_partial01' "$@"
