#!/bin/bash

DOTFILES_ROOT=$(cd $(dirname $0) && pwd)/..
GPG_KEYS_DIR=$DOTFILES_ROOT/config/dotfiles/gpg/omer/keys
PRIMARY_KEY="$(< $GPG_KEYS_DIR/PRIMARY)"

SUPPORTED_LANGUAGES=(
    shell bash sh zsh
    python py
    c
)

usage()
{
    echo "Usage: $0 -l {$(sed "s/ /,/g" <<< "${SUPPORTED_LANGUAGES[@]}")}"
    exit 1
}

tolower()
{
    tr '[:upper:]' '[:lower:]'
}

print_char_number_of_times()
{
    local char="$1"
    local num="$2"
    local add_newline="${3:-0}"

    eval "printf '$char%.0s' {1..$num}"

    if [ "$add_newline" == 1 ]; then
        echo
    fi
}

print_header()
{
    case "$PROGRAMMING_LANGUAGE" in
        shell|bash|sh|zsh|python|py)
            print_char_number_of_times "#" 78 1
            local N="#";;
        c)
            echo -n "/"
            print_char_number_of_times "*" 77 1
            local N="*";;
        *)
            usage;;
    esac

    cat <<EOF
$N <title>
$N ------------------------------------------
$N <description>
$N
$N Usage:
$N       <usage>
$N
$N :authors: Omer Sne, @omersne, 0x${PRIMARY_KEY: -16}
$N :date: $(date +%Y-%m-%d)
$N :version: <version>
$N :license: <license>
$N :copyright: (c) $(date +%Y) Omer Sne
EOF

    case "$PROGRAMMING_LANGUAGE" in
        shell|bash|sh|python|py)
            print_char_number_of_times "#" 78 1;;

        c)
            print_char_number_of_times "*" 77
            echo "/";;
    esac
}

main()
{
    while [ $# -gt 0 ]; do
        case "$1" in
            --help|-h) usage;;
            --language|--lang|-l) PROGRAMMING_LANGUAGE="$(tolower <<< "$2")"; shift;;
            *) PROGRAMMING_LANGUAGE="$(tolower <<< "$1")";;
        esac
        shift
    done

    if [ -z "$PROGRAMMING_LANGUAGE" ]; then
        usage
    fi
    print_header
    exit 0
}
main "$@"

