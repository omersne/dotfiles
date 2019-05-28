#!/bin/bash

DOTFILES_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. $DOTFILES_DIR/.colors
. $DOTFILES_DIR/.functions

NO_REPLACE=0

abort()
{
    local message="$1"

    echo "$message" >&2
    exit 1
}

symlink_file_and_keep_old()
{
    local src="$1"
    local dst="$2"

    if [ -d "$dst" ]; then
        dst="${dst%/}/${src##*/}"
    fi

    # XXX: [ -h ] is needed for symlinks that
    # point to files that don't exist.
    if [ -e "$dst" ] || [ -h "$dst" ]; then
        local the_date="$(date_for_filename)"
        echo_info "A file named '$dst' already exists."
        if [ "$NO_REPLACE" == 1 ]; then
            return 0
        fi

        echo_info "It will be renamed to '$dst.old_$the_date'."
        mv "$dst" "$dst.old_$the_date"
        if [ $? -ne 0 ]; then
            echo_error "Failed to rename $filename"
            ((ERRORS++))
            return 1
        fi
    fi

    ln -s "$src" "$dst"
}

symlink_general_dotfiles()
{
    local symlink filename
    for symlink in $(find "$DOTFILES_DIR" -maxdepth 1 -type f -name ".*") \
                   "$DOTFILES_DIR/.config"; do
        filename="${symlink##*/}"

        if endswith "$filename" ".example"; then
            if [ -e $HOME/${filename%.example} ]; then
                continue
            else
                # Copy the file, so a symlink won't be created. The file will be
                # renamed to ${filename%.example} later and will be edited with the
                # local config.
                cp $filename $HOME/
                continue
            fi
        fi

        symlink_file_and_keep_old "$symlink" "$HOME/"
    done
}

symlink_vim_files()
{
    [ ! -d $HOME/.vim/colors ] && mkdir -p $HOME/.vim/colors

    local symlink
    for symlink in $(find $DOTFILES_DIR/vim/color_schemes/ -maxdepth 1 -type f); do
        symlink_file_and_keep_old "$symlink" "$HOME/.vim/colors/"
    done
}

symlink_gpg_files()
{
    [ ! -d $HOME/.gnupg ] && mkdir -p $HOME/.gnupg

    local symlink
    for symlink in $(find $DOTFILES_DIR/.gnupg/ -maxdepth 1 -type f); do
        symlink_file_and_keep_old "$symlink" "$HOME/.gnupg/"
    done
}

run_func()
{
    local func_name="$1"
    (
    ERRORS=0
    $func_name
    if [ $ERRORS -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
    )
}

main()
{
    local arg
    for arg in "$@"; do
        case "$arg" in
            --no-replace|-n) NO_REPLACE=1;;
            *) abort "Invalid argument: \`$arg'";;
        esac
    done

    local rc=0

    echo "$DOTFILES_DIR" > $HOME/.dotfiles_dir_path
    [ -n "$GIT_DIR" ] && echo "$GIT_DIR" > ~/.git_dir_path

    run_func symlink_general_dotfiles || rc=1
    run_func symlink_vim_files || rc=1
    run_func symlink_gpg_files || rc=1

    exit $rc
}
main "$@"
