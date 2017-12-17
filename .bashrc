#!/bin/bash

if [ -e ~/.no_load_bashrc ]; then
    return 1
fi

for file in ~/.{functions,colors,exports,aliases,bash_prompt,bashrc.local}; do
    [ -r $file ] && . $file
done
unset file

alias reload-config=". ~/.bashrc"

