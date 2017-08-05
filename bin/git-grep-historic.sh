#!/bin/bash

list_commits()
{
    git rev-list --all
}

main()
{
    local commit
    list_commits | \
        while read commit; do
            #git grep "$@" $commit
            git show $commit | grep "$@" | grep "^[+-]" | \
                (while read line; do
                    echo "$commit: $line"
                done)
        done
}
main "$@"

