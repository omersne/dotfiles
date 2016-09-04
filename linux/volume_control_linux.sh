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

change_volume()
{
    local volume="$1"

    # If $volume doesn't end with a percent sign
    if [ "${volume%\%}" == "$volume" ]; then
        volume="$volume%"
    fi

    # XXX: Check which Linux distros this works on (in addition to Ubuntu).
    amixer -q -D pulse sset Master 0 $volume
}

change_volume_relative()
{
    local volume="$1"

    amixer -q -D pulse sset Master $volume
}

mute_volume()
{
    amixer -q -D pulse sset Master mute
}

unmute_volume()
{
    amixer -q -D pulse sset Master unmute
}

toggle_volume()
{
    amixer -q -D pulse sset Master toggle
}

get_mute_status()
{
    if amixer -D pulse get Master | grep -q "\[off\]" \
            && ! amixer -D pulse get Master | grep -q "\[on\]"; then
        echo 1
    else
        echo 0
    fi
}

get_current_volume()
{
    local current_volume="$(amixer -D pulse get Master | \
            grep -o "\[[0-9]\+%\]" | \
            sed "s/\[//g; s/\]//g" | \
            sort -u)"

    # If there is more than one line in the output, that means that the
    # right and left left channels have different volume levels.
    if [ $(echo "$current_volume" | wc -l) -gt 1 ]; then
        local left_channel="$(echo "$current_volume" | head -1)"
        local right_channel="$(echo "$current_volume" | tail -1)"

        echo "L: $left_channel, R: $right_channel"
    else
        # The two channels have the same volume level, so only print the 
        # percentage once.
        echo "$current_volume"
    fi
}

for i in "$@"; do
    case $i in
        --help|-h|help)
            echo -e "$(help_info)"
            exit 1
            ;;
    esac
done

while [ $# -gt 0 ]; do

    case "$1" in

        --set|-s)
            if is_int "$2"; then
                vol_to_set="$2"
                if [ -n "$vol_to_set" ]; then
                    shift
                    change_volume "$vol_to_set"
                fi
            fi
            ;;

        --mute|-m)
            mute_volume
            ;;

        --unmute|-u)
            unmute_volume
            ;;

        --toggle|-t)
            toggle_volume
            ;;

        --increase-by|-i)
            if is_int "$2"; then
                vol_to_increase=$2
                shift
            fi
            # If an amount to increase by is not specified, default to 5%.
            vol_to_increase="${vol_to_increase:-5}"

            if [ "${vol_to_increase%\%}" == "$vol_to_increase" ]; then
                vol_to_increase="$vol_to_increase%"
            fi

            change_volume_relative "${vol_to_increase}+"
            ;;

        --decrease-by|-d)
            if is_int "$2"; then
                vol_to_decrease=$2
                shift
            fi
            # If an amount to decrease by is not specified, default to 5%.
            vol_to_decrease="${vol_to_decrease:-5}"

            if [ "${vol_to_decrease%\%}" == "$vol_to_decrease" ]; then
                vol_to_decrease="$vol_to_decrease%"
            fi

            change_volume_relative "${vol_to_decrease}-"
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

    muted="$(get_mute_status)"
    current_volume="$(get_current_volume)"

    if [ "$muted" == 1 ]; then
        current_volume="${color_blue}$current_volume${color_none}"
    fi

    echo -e "${color_orange}[$current_volume${color_orange}]"
fi



