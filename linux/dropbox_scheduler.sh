#!/bin/bash

# Requires the Dropbox Linux command line script.
# https://linux.dropbox.com/packages/dropbox.py


DROPBOX_SCHEDULE_FILE=${DROPBOX_SCHEDULE_FILE:-$HOME/.dropbox.schedule}

# The Dropbox schedule file should be written like this (This example starts at 
# 02:00 and ends at 06:00):
# 
# # 1 = Monday
# SYNC_DAYS=1,2,3
# SYNC_START_TIME=0200
# SYNC_END_TIME=0600
#

echo_error()
{
    local color_red="\033[38;5;9m"
    local color_none="\033[00m"
    echo -e "${color_red}$@${normal}" >&2
}

is_running()
{
    # As of 2016-09-04, dropbox.py does not return a non zero exit status when 
    # you try to check Dropbox's status when Dropbox isn't running, so I need to
    # check the output of the script instead.
    local dropbox_status="$(dropbox.py status 2>&1)"

    if [ "$dropbox_status" == "Dropbox isn't running!" ]; then
        return 1
    else
        return 0
    fi
}

start_dropbox()
{
    if ! is_running; then
        dropbox.py start
    else
        return 0
    fi
}

stop_dropbox()
{
    if is_running; then
        dropbox.py stop
    else
        return 0
    fi
}

if [ -e $HOME/.dropbox.always_on ] && [ -e $HOME/.dropbox.always_off ]; then
    echo_error "Error! .dropbox.always_on and .dropbox.always_off both exist in $HOME/."
    echo_error "Please delete at least one of them and run the script again."
    exit 1

elif [ -e $HOME/.dropbox.always_on ]; then
    start_dropbox
    exit $?

elif [ -e $HOME/.dropbox.always_off ]; then
    stop_dropbox
    exit $?
fi

SYNC_DAYS=( $(grep "SYNC_DAYS" $DROPBOX_SCHEDULE_FILE | \
        awk -F "=" '{print $NF}' | \
        sed "s/,/ /g") )

SYNC_START_TIME="$(grep "SYNC_START_TIME" $DROPBOX_SCHEDULE_FILE | \
        awk -F "=" '{print $NF}')"

SYNC_END_TIME="$(grep "SYNC_END_TIME" $DROPBOX_SCHEDULE_FILE | \
        awk -F "=" '{print $NF}')"

CURRENT_DAY="$(date +%u)"
CURRENT_TIME="$(date +%H%M)"

for day in "${SYNC_DAYS[@]}"; do

    if [ "$day" == "$CURRENT_DAY" ]; then

        if [ $CURRENT_TIME -ge $SYNC_START_TIME ] && [ $CURRENT_TIME -le $SYNC_END_TIME ]; then
            start_dropbox
        else
            stop_dropbox
        fi

        break
    fi
done

