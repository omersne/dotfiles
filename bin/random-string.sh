#!/bin/bash

set -o pipefail

ALLOWED_CHARS='A-Za-z0-9_=()*&^%\$#@\!/\\-'
LENGTHS="08 10 15 16 20 24 25 30 32 35 40 45 48 50 55 60 64"
ADD_PREFIX=1

read_random_bytes()
{
    cat /dev/urandom
}

_tr()
{
    if [ "$(uname)" == "Darwin" ] && which gtr > /dev/null 2>&1; then
        gtr "$@"
    else
        tr "$@"
    fi
}

remove_invalid_chars()
{
    _tr -dc "$ALLOWED_CHARS"
}

get_num_of_chars()
{
    local length="$1"

    fold -w "$length"
}

get_line()
{
    head -1
}

print_random_strings()
{
    local length
    for length in $LENGTHS; do
        if [ "$ADD_PREFIX" == 1 ]; then
            echo -n "$length: "
        fi
        read_random_bytes | remove_invalid_chars | get_num_of_chars "$length" | get_line
    done
}

main()
{
    while [ $# -gt 0 ]; do
        case "$1" in
            --alphanumeric|-a)
                ALLOWED_CHARS="A-Za-z0-9";;
            --alpha|-l)
                ALLOWED_CHARS="A-Za-z";;
            --numeric|-n)
                ALLOWED_CHARS="0-9";;
            --length|-t)
                LENGTHS="$2"
                shift;;
            --no-prefix)
                ADD_PREFIX=0;;
            *)
                echo "Invalid argument: \`$1'" >&2
                echo "Exiting" >&2
                exit 1;;
        esac
        shift
    done

    print_random_strings
    exit 0
}
main "$@"
