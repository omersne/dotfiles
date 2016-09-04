#!/bin/bash

if [ -z "$1" ]; then
    echo -e "Error. Usage is: $0 <new name>" >&2
    exit 1
fi

scutil --set ComputerName "$1"
scutil --set LocalHostName "$1"
scutil --set HostName "$1"

