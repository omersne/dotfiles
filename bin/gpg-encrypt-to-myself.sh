#!/bin/bash

GPG="${GPG:-gpg}"

DOTFILES_ROOT=$(cd $(dirname $0) && pwd)/..
GPG_KEYS_DIR=$DOTFILES_ROOT/config/dotfiles/gpg/omer/keys

ENCRYPTION_KEY="$(< $GPG_KEYS_DIR/ENCRYPTION)"

bool()
{
    case "$1" in
        ""|0) return 1;;
        *) return 0;;
    esac
}

main()
{
    local arg filename binary=0 no_hidden_recipient=0 no_verbose=0
    for arg in "$@"; do
        case "$arg" in
            --binary|-b) binary=1;;
            --no-hiddent-recipient|--no-hidden|-n) no_hidden_recipient=1;;
            --no-verbosity|--no-verbose|-N) no_verbose=1;;
            *) filename="$arg";;
        esac
    done

    local args="-e"

    if ! bool "$binary"; then
        args+="a"
    fi

    if ! bool "$no_verbose"; then
        args+="v"
    fi

    if bool "$no_hidden_recipient"; then
        args+="r $ENCRYPTION_KEY!"
    else
        args+="R $ENCRYPTION_KEY!"
    fi

    if [ -n "$filename" ]; then
        $GPG $args "$filename"
    else
        $GPG $args
    fi
}
main "$@"

