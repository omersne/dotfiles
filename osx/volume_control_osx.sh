#!/bin/bash

color_none="\033[00m"
color_blue="\033[38;5;33m"
color_orange="\033[38;5;208m"
color_red="\033[38;5;9m"
color_green="\033[38;5;10m"
color_yellow="\033[38;5;11m"
color_cyan="\033[38;5;14m"

help_info()
{
    cat <<EOF
This script is used for controlling the computer volume in Mac OS X

Usage: $0 [OPTIONS]
Options:
    --mute, -m                        | Mute the computer's volume.
    --unmute, -u                      | Unmute the computer's volume.
    --toggle, -t                      | Toggle between mute and unmute.

    --set <VOLUME>, -s <VOLUME>       | Any number from 0 to 100 - change the 
                                      | volume to that number (in percent).

    --quiet, -q                       | Don't print any messages or the computer's
                                      | volume to the screen.

    --increase-by VOLUME, -i VOLUME   | Increase the computer's volume by a
                                      | specific amount. *

    --decrease-by VOLUME, -d VOLUME   | decrease the computer's volume by a 
                                      | specific amount. *

* If an amount is not specified, the script will default to 5%
    
EOF
}

is_int()
{
    if [ $1 -eq $1 ] 2>/dev/null; then
        return 0
    fi
    return 1
}

for i in "$@"; do
    case $i in
        --help|-h|help)
            echo -e "$(help_info)"
            exit 1
            ;;
    esac
done

muted="$(osascript -e "output muted of (get volume settings)")"

while [ $# -gt 0 ]; do

    case $1 in

        --set|-s)
            if is_int "$2"; then
                vol_to_set="$2"
                if [ -n "$vol_to_set" ]; then
                    shift
                    osascript -e "set volume output volume $vol_to_set"
                fi
            fi
            ;;

        --mute|-m)
            osascript -e "set volume output muted true"
            ;;

        --unmute|-u)
            osascript -e "set volume output muted false"
            ;;

        --toggle|-t)
            if [ "$muted" == "true" ]; then
                osascript -e "set volume output muted false"
            else
                osascript -e "set volume output muted true"
            fi
            ;;

        --increase-by|-i)
            if is_int "$2"; then
                vol_to_increase=$2
                shift
            fi
            vol_to_increase="${vol_to_increase:-5}"
            osascript -e "set volume output volume ((output volume of \
                    (get volume settings)) + $vol_to_increase)"
            ;;

        --decrease-by|-d)
            if is_int "$2"; then
                vol_to_decrease=$2
                shift
            fi
            vol_to_decrease="${vol_to_decrease:-5}"
            osascript -e "set volume output volume ((output volume of \
                    (get volume settings)) - $vol_to_decrease)"
            ;;

        --quiet|-q)
            quiet=1
            ;;

        *)
            echo_error "Invalid option: $1."
            echo_error "Exiting."
            exit 1
            ;;
    esac

    shift
done

if [ "$quiet" != 1 ]; then

    muted="$(osascript -e 'output muted of (get volume settings)')"
    current_volume="$(osascript -e 'output volume of (get volume settings)')%"

    if [ "$muted" == "true" ]; then
        current_volume="${color_blue}$current_volume${color_none}"
    fi

    echo -e "${color_orange}[$current_volume${color_orange}]"
fi

