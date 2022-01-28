#!/bin/bash

set -e

DOTFILES_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "$DOTFILES_DIR/.colors"
. "$DOTFILES_DIR/.functions"

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
            return 1
        fi
    fi

    ln -s "$src" "$dst"
}

no_restrictions()
{
    return 0
}

symlink_dir_to_dir()
{
    local src_dir="$1"
    local dst_dir="$2"
    local filter_func="${3:-no_restrictions}"

    if [ ! -d "$dst_dir" ]; then
        if [ -e "$dst_dir" ]; then
            abort "'$dst_dir' exists but is not a directory"
        fi
        mkdir -p "$dst_dir"
    fi

    local files=( "$src_dir"/.* "$src_dir"/* )
    local symlink base_filename
    for symlink in "${files[@]}"; do
        if [ "$symlink" == "." ] || [ "$symlink" == ".." ] || [ -d "$symlink" ] || ! "$filter_func"; then
            continue
        fi
        base_filename="${symlink##*/}"

        if endswith "$base_filename" ".example"; then
            if [ -e $HOME/${base_filename%.example} ]; then
                continue
            else
                # Copy the file, so a symlink won't be created. The file will be
                # renamed to ${filename%.example} later and will be edited with the
                # local config.
                cp "$symlink" $HOME/
                continue
            fi
        fi

        if ! symlink_file_and_keep_old "$symlink" "$dst_dir"; then
            return 1
        fi
    done
}

only_hidden_files()
{
    local path="$1"
    startswith "$path" "."
}

all_files_except_scripts()
{
    local path="$1"
    ! endswith "$path" ".sh" ".py"
}

symlink_dotfiles()
{
    symlink_dir_to_dir "$DOTFILES_DIR" "$HOME" all_files_except_scripts

    symlink_dir_to_dir "$DOTFILES_DIR/.config" "$HOME/.config"

    local path
    for path in "$DOTFILES_DIR/.config/"*; do
        if [ -d "$path" ]; then
            symlink_dir_to_dir "$path" "$HOME/.config/$(basename "$path")"
        fi
    done

    symlink_dir_to_dir "$DOTFILES_DIR/vim" "$HOME/.vim"
    symlink_dir_to_dir "$DOTFILES_DIR/vim/color_schemes" "$HOME/.vim/colors"
    symlink_dir_to_dir "$DOTFILES_DIR/vim/syntax" "$HOME/.vim/syntax"

    symlink_dir_to_dir "$DOTFILES_DIR/.gnupg" "$HOME/.gnupg"
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

    echo "$DOTFILES_DIR" > $HOME/.dotfiles_dir_path
    [ -n "$GIT_DIR" ] && echo "$GIT_DIR" > ~/.git_dir_path

    symlink_dotfiles

    exit 0
}
main "$@"
