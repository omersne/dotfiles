#!/bin/zsh

if [ -e ~/.no_load_zshrc ]; then
    return 1
fi

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

for file in .{functions,colors,exports,aliases,completion,zsh_prompt,zshrc.local}; do
    [ -r ~/$file ] && . ~/$file
done
unset file

[ -r $DOTFILES_DIR/zsh/key_bindings.zsh ] && . $DOTFILES_DIR/zsh/key_bindings.zsh

alias reload-config=". $HOME/.zshrc"

