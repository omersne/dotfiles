#!/bin/bash

GPG="${GPG:-gpg}"

endswith()
{
    [ "${1%*$2}" != "$1" ]
}

list_fingerprints()
{
    local key_id="$1"

    $GPG --fingerprint --fingerprint "$key_id"
}

main()
{
    local arg key_id no_spaces=0
    for arg in "$@"; do
        case "$arg" in
            --no-spaces|-n) local no_spaces=1;;
            *) key_id="$arg";;
        esac
    done

    local line line_no_spaces rc=1
    while read line; do
        line_no_spaces="$(sed "s/ //g" <<< "$line")"
        if endswith "$line_no_spaces" "$key_id"; then
            if [ "$no_spaces" == 1 ]; then
                echo "$line_no_spaces"
            else
                echo "$line"
            fi
            rc=0
            break
        fi
    done < <(list_fingerprints "$key_id")

    exit $rc
}
main "$@"

