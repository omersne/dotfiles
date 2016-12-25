#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0) && pwd)

. $SCRIPT_DIR/../.functions
. $SCRIPT_DIR/../.colors

echo_and_run_cmd()
{
    echo --- "$@" ---
    "$@"
    echo
}

#if ___is_osx; then
#    DEST_DIR=$SCRIPT_DIR/../osx/bin
#
#elif ___is_linux; then
#    DEST_DIR=$SCRIPT_DIR/../linux/bin
#
#else
#    echo_error "Unsupported platform."
#    echo_error "Exiting"
#    exit 1
#fi

DEST_DIR=$SCRIPT_DIR/../bin

if [ ! -d $DEST_DIR ]; then
    mkdir -p $DEST_DIR
fi

for i in "$@"; do

    case "$i" in

        all)
            all_options="$(sed -ne '/^ *case .* in$/,/^ *esac$/ {/)$/ {s/[^0-9A-Za-z_-]//g; /^all$/!p;};}' "$0")"
            $0 $all_options
            ;;

        rstrip-newline)
            echo "[rstrip-newline]"
	        echo_and_run_cmd gcc -Wall $SCRIPT_DIR/rstrip-newline.c -o $DEST_DIR/rstrip-newline
            ;;

        newline-to-backslash-n)
            echo "[newline-to-backslash-n]"
	        echo_and_run_cmd gcc -Wall $SCRIPT_DIR/newline-to-backslash-n.c -o $DEST_DIR/newline-to-backslash-n
            ;;

        *)
            echo
            echo_error "Invalid option: $i"
            echo
            continue
            ;;

    esac

done

