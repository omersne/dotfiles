#!/bin/bash

set -e

: "${VERBOSE:=0}"

if [ "$VERBOSE" == 1 ]; then
    set -x
fi

echo "TZ=$EXT_TZ" >> /etc/environment

echo "$EXT_USER:x:$EXT_UID:$EXT_GID:$EXT_USER:$EXT_HOME:/usr/bin/zsh" >> /etc/passwd
echo "$EXT_USER:*:99999:0:99999:7:::" >> /etc/shadow
echo "$EXT_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
service ssh start > /dev/null

if [ "$*" == "zsh" ]; then
    su - "$EXT_USER"
else
    su - "$EXT_USER" -c -- "$@"
fi
