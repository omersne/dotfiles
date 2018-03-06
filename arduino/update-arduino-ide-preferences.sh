#!/bin/bash

set -e

update_entry_value()
{
    local name="$1"
    local new_value="$2"

    $SED -i "/^$name=/ {s/=.*/=$new_value/;}" -- "$PREFERENCES_FILE"
}

SED=sed
if [ "$(uname)" == Darwin ]; then
    SED=gsed
fi
which $SED > /dev/null

PREFERENCES_FILE="$1"
if [ ! -w "$PREFERENCES_FILE" ]; then
    echo "'$PREFERENCES_FILE' is not writable." >&2
    exit 1
fi

update_entry_value editor.auto_close_braces false
update_entry_value editor.indent false
update_entry_value editor.tabs.size 4
