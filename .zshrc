#!/bin/zsh

if [ -e ~/.no_load_zshrc ]; then
    return 1
fi

[ -r $HOME/.dotfiles_dir_path ] && DOTFILES_DIR="$(cat $HOME/.dotfiles_dir_path)"

[ -r $HOME/.git_dir_path ] && GIT_DIR="$(cat $HOME/.git_dir_path)"

setopt prompt_subst
setopt no_beep
setopt complete_in_word
setopt noautomenu
setopt nomenucomplete

for func in compinit bashcompinit; do
    if ! type $func > /dev/null 2>&1; then
        autoload -U +X $func && $func
    fi
done
unset func

for file in .{zshrc.local,functions,colors,exports,aliases,zsh_prompt,dotfiles_overriders}; do
    if [ -n "$DOTFILES_DIR" ] && [ -r $DOTFILES_DIR/$file ]; then
        . $DOTFILES_DIR/$file
    else
        [ -r ~/$file ] && . ~/$file
    fi
done
unset file

[ -r $DOTFILES_DIR/zsh/key_bindings.zsh ] && . $DOTFILES_DIR/zsh/key_bindings.zsh

alias reload-config=". $HOME/.zshrc"

