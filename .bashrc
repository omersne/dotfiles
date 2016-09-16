#!/bin/bash

if [ -e ~/.no_load_bashrc ]; then
    return 1
fi

[ -r ~/.dotfiles_dir_path ] && DOTFILES_DIR="$(cat ~/.dotfiles_dir_path)"

[ -r $HOME/.git_dir_path ] && GIT_DIR="$(cat $HOME/.git_dir_path)"

for file in ~/.{bashrc.local,functions,colors,exports,aliases,bash_prompt}; do
    [ -r $file ] && . $file
done
unset file

alias reload-config=". ~/.bashrc"

