#!/bin/zsh

[ -r $HOME/.dotfiles_dir_path ] && DOTFILES_DIR="$(cat $HOME/.dotfiles_dir_path)"

[ -r $HOME/.git_dir_path ] && GIT_DIR="$(cat $HOME/.git_dir_path)"

setopt prompt_subst
setopt no_beep
setopt complete_in_word
setopt noautomenu
setopt nomenucomplete


for file in ~/.{zshrc.local,functions,colors,exports,aliases,zsh_prompt}; do
    [ -r $file ] && . $file
done
unset file

[ -r $DOTFILES_DIR/zsh/key_bindings.zsh ] && . $DOTFILES_DIR/zsh/key_bindings.zsh

alias reload-config=". $HOME/.zshrc"

