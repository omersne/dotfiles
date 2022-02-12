#!/bin/bash

##############################################################################
# docker-linux-env.sh
# ------------------------------------------
# Run my default linux docker configuration
#
# Usage:
#       docker-linux-env.sh
#
# :authors: Omer Sne, @omersne, 0x70FD7223D22DFA23
# :date: 2022-02-12
# :version: 0.0.1
##############################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

: "${VERBOSE:=0}"
: "${NO_HOME:=0}"
: "${HOME_MOUNT_RW:=0}"

if [ "$VERBOSE" == 1 ]; then
    set -x
fi

: "${VER:=ubuntu-20.04}"
BUILD_NAME="$USER-$VER"

if [ -f "/.dockerenv" ]; then
    "$@"
    exit $?
fi

MOUNTS=(
    "-v" "$DOTFILES_DIR:/dotfiles:ro"
)
if [ "$NO_HOME" != 1 ]; then
    if [ "$HOME_MOUNT_RW" == 1 ]; then
        MOUNTS+=("-v" "$HOME:$HOME")
    else
        MOUNTS+=("-v" "$HOME:$HOME:ro")
    fi
fi

if [ -e /etc/timezone ]; then # Linux
    TIMEZONE_NAME="$(cat /etc/timezone)"
elif [ -e /etc/localtime ]; then # Mac
    TIMEZONE_NAME="$(readlink /etc/localtime | awk -F '/' '{printf("%s/%s\n", $(NF-1), $NF)}')"
else
    echo "Error: No timezone file" >&2
    exit 1
fi

EXT_USER="$USER"
EXT_UID="$UID"
EXT_GID="$(id -g)"
EXT_HOME="$HOME"

((SSH_FORWARDING_PORT=10000 + EXT_UID))

DOCKER_CMD=(
    docker run
    -it
    --rm
    -h $(hostname)-docker
    -p "$SSH_FORWARDING_PORT:22" # https://stackoverflow.com/a/37970046
    "${MOUNTS[@]}"
    -e EXT_USER="$EXT_USER"
    -e EXT_UID="$EXT_UID"
    -e EXT_GID="$EXT_GID"
    -e EXT_HOME="$EXT_HOME"
    -e EXT_TZ="$TIMEZONE_NAME"
    "$BUILD_NAME"
    "$@"
)
"${DOCKER_CMD[@]}"
