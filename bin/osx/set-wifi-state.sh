#!/bin/bash

##############################################################################
# set-wifi-state.sh
# ------------------------------------------
# Turn WiFi on/off.
#
# Usage:
#       set-wifi-state.sh {on,off}
#
# :authors: Omer Sne, @omersne, 0x65A9D22B299BA9B5
# :date: 2017-12-16
# :version: 0.0.1
##############################################################################

usage()
{
    cat <<END_HELP
Usage: $0 {on,off}
END_HELP

    exit 1
}

STATE_TO_SET="$1"
case "$STATE_TO_SET" in
    on|off) ;;
    *)
        echo "Usage: $0 {on,off}" >&2
        exit 1
        ;;
esac

CURRENT_DEVICE="$(networksetup -listallhardwareports | sed -ne '/Wi-Fi/ {n; s/.* //p;}')"
networksetup -setairportpower "$CURRENT_DEVICE" "$STATE_TO_SET"
