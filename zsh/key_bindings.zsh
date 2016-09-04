
bindkey "^[^[[C" forward-word # alt + right arrow
bindkey "^[^[[D" backward-word # alt + left arrow

bindkey "^[[1;10C" end-of-line # alt + shift + right arrow
bindkey "^[^[[B" end-of-line # alt + down arrow

bindkey "^[[1;10D" beginning-of-line # alt + shift + left arrow
bindkey "^[^[[A" beginning-of-line # alt + up arrow

bindkey "^[[1;2C" delete-char # shift + right_arrow
bindkey "^[[1;2D" backward-delete-char # shift + left_arrow

bindkey "^[[F" delete-char # shift + right_arrow
bindkey "^[[H" backward-delete-char # shift + left_arrow

_delete_to_end_of_line()
{
    BUFFER="${BUFFER:0:$CURSOR}"
    CURSOR="${#BUFFER}"
}
zle -N _delete_to_end_of_line
bindkey '^[[6~' _delete_to_end_of_line # fn + down arrow
bindkey '^[[1;2B' _delete_to_end_of_line # shift + down arrow


_delete_to_start_of_line()
{
    BUFFER="${BUFFER:$CURSOR}"
    CURSOR="0"
}
zle -N _delete_to_start_of_line
bindkey '^[[5~' _delete_to_end_of_line # fn + down arrow
bindkey '^[[1;2A' _delete_to_start_of_line # shift + up arrow


_while_true_do()
{
    BUFFER="while true; do ; done"
    CURSOR="15"
}
zle -N _while_true_do
bindkey '^[OP' _while_true_do # fn + F1

_while_i_is_smaller_than()
{
    BUFFER="i=0; while [ \$i -lt  ]; do ; ((i++)); done"
    CURSOR="20"
}
zle -N _while_i_is_smaller_than
bindkey '^[[1;2P' _while_i_is_smaller_than # fn + shift + F1

_for_i_in_do()
{
    BUFFER="for i in ; do ; done"
    CURSOR="9"
}
zle -N _for_i_in_do
bindkey '^[OQ' _for_i_in_do # fn + F2

_c_style_for_loop()
{
    BUFFER="for (( i=0; i<=; i++ )); do ; done"
    CURSOR="15"
}
zle -N _c_style_for_loop
bindkey '^[[1;2Q' _c_style_for_loop # fn + shift + F2

_awk_space_divider()
{
    BUFFER="$BUFFER | awk '{print $}'"
    CURSOR="$(( ${#BUFFER} - 2 ))"
}
zle -N _awk_space_divider
bindkey '^[OR' _awk_space_divider # fn + F3

_tr_newline_to_space()
{
    BUFFER="$BUFFER | tr '\\n' ' '"
    CURSOR="${#BUFFER}"
}
zle -N _tr_newline_to_space
bindkey '^[OS' _tr_newline_to_space # fn + F4

_tr_space_to_newline()
{
    BUFFER="$BUFFER | tr ' ' '\\n'"
    CURSOR="${#BUFFER}"
}
zle -N _tr_space_to_newline
bindkey '^[[1;2S' _tr_space_to_newline # fn + shift + F4


