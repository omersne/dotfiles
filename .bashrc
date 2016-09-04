#!/bin/bash

[ -r ~/.dotfiles_dir_path ] && DOTFILES_DIR="$(cat ~/.dotfiles_dir_path)"

[ -r $HOME/.git_dir_path ] && GIT_DIR="$(cat $HOME/.git_dir_path)"

for file in ~/.{bashrc.local,functions,exports,aliases,bash_prompt}; do
    [ -r $file ] && . $file
done
unset file

alias reload-config=". ~/.bashrc"

