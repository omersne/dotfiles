#!/bin/bash

startswith()
{
    [ "${1#$2}" == "$1" ] && return 1 || return 0
}

git_log()
{
    git log --pretty='%H'
}

from_top()
{
    local index="$1"

    head $index | tail -1
}

from_bottom()
{
    local index="$1"

    tail -${index#+} | head -1
}

show_commit()
{
    local func="$1"
    local index="$2"

    git show $(git_log | $func $index)
}

main()
{
    for i in "$@"; do
        case "$i" in
            --help|-h|help)
                echo "Usage: $0 <commit index>"
                exit 1
                ;;
        esac
    done

    local COMMIT_NUM="${1:--1}"

    if startswith "$COMMIT_NUM" "-"; then
        show_commit from_top $COMMIT_NUM
    elif startswith "$COMMIT_NUM" "+"; then
        show_commit from_bottom $COMMIT_NUM
    else
        git show "$@"
    fi
}
main "$@"
