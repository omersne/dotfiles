#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0) && pwd)

if [ ! -n "$1" ]; then
    echo "Usage: $0 <destination>" >&2
    echo "Exiting" >&2
    exit 1
fi

DEST="$1"

rc=0

for i in .* *; do

    case "$i" in

        .|..|.git|bin) continue;;

        *) scp -r "$i" $DEST || rc=1;;

    esac

done

exit $rc

