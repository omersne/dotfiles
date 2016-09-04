#!/bin/bash

DOTFILES_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. $DOTFILES_DIR/.colors

echo "$DOTFILES_DIR" > $HOME/.dotfiles_dir_path

[ -n "$GIT_DIR" ] && echo "$GIT_DIR" > ~/.git_dir_path

for symlink in $(find $DOTFILES_DIR -maxdepth 1 -type f -name ".*"); do

    filename="${symlink##*/}"
    replaced_by_symlinks_dir=$HOME/.replaced_by_symlinks/

    # If it's an example file
    if [ "${filename%.example}" != "${filename}" ]; then

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

    if [ -h $HOME/$filename ]; then

        rm $HOME/$filename && ln -s $symlink $HOME/$filename

    elif [ -f $HOME/$filename ]; then

        the_date=$(date +%Y-%m-%d_%H-%M)

        echo_info "A file named $filename already exists in $HOME."
        echo_info "It will be renamed to $filename.old_$the_date"

        if mv $HOME/$filename $HOME/$filename.old_$the_date; then
            ln -s $symlink $HOME/$filename
        else
            echo_error "Failed to rename $filename"
        fi

    else

        ln -s $symlink $HOME/$filename
    fi
done

# Vim color schemes
mkdir -p $HOME/.vim/colors

for symlink in $(find $DOTFILES_DIR/vim/color_schemes/ -maxdepth 1 -type f); do

    filename="${symlink##*/}"

    if [ -h $HOME/.vim/colors/$filename ]; then

        rm $HOME/.vim/colors/$filename && ln -s $symlink $HOME/.vim/colors/

    elif [ -f $HOME/.vim/colors/$filename ]; then

        the_date=$(date +%Y-%m-%d_%H-%M)

        echo_info "A file named $filename already exists in $HOME/.vim/colors/."
        echo_info "It will be renamed to $filename.old_$the_date"

        mv $HOME/.vim/colors/$filename $HOME/.vim/colors/$filename.old_$the_date

        ln -s $symlink $HOME/.vim/colors/

    else

        ln -s $symlink $HOME/.vim/colors/

    fi

done

# If a prompt file already exists, assume that it's a custom prompt that was 
# chosen from $DOTFILES_DIR/<shell>/prompts and don't overwrite it.
[ ! -e $HOME/.bash_prompt ] && ln -s $DOTFILES_DIR/bash/prompts/statueofliberty $HOME/.bash_prompt
[ ! -e $HOME/.zsh_prompt ] && ln -s $DOTFILES_DIR/zsh/prompts/centralpark $HOME/.zsh_prompt


