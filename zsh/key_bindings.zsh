_delete_to_end_of_line()
{
    BUFFER="${BUFFER:0:$CURSOR}"
    CURSOR="${#BUFFER}"
}
zle -N _delete_to_end_of_line

_delete_to_start_of_line()
{
    BUFFER="${BUFFER:$CURSOR}"
    CURSOR="0"
}
zle -N _delete_to_start_of_line

_while_true_do()
{
    BUFFER="while true; do ; done"
    CURSOR="15"
}
zle -N _while_true_do

_while_i_is_smaller_than()
{
    BUFFER="i=0; while [ \$i -lt  ]; do ; ((i++)); done"
    CURSOR="20"
}
zle -N _while_i_is_smaller_than

_for_i_in_do()
{
    BUFFER="for i in ; do ; done"
    CURSOR="9"
}
zle -N _for_i_in_do

_c_style_for_loop()
{
    BUFFER="for (( i=0; i<=; i++ )); do ; done"
    CURSOR="15"
}
zle -N _c_style_for_loop

_awk_space_divider()
{
    BUFFER="$BUFFER | awk '{print $}'"
    CURSOR="$(( ${#BUFFER} - 2 ))"
}
zle -N _awk_space_divider

_tr_newline_to_space()
{
    BUFFER="$BUFFER | tr '\\n' ' '"
    CURSOR="${#BUFFER}"
}
zle -N _tr_newline_to_space

_tr_space_to_newline()
{
    BUFFER="$BUFFER | tr ' ' '\\n'"
    CURSOR="${#BUFFER}"
}
zle -N _tr_space_to_newline

typeset -A ___key_bindings
if ___is_tmux_session; then
    ___key_bindings=(
        "^[[1;3C" forward-word # alt + right arrow
        "^[[1;3D" backward-word # alt + left arrow

        "^[[1;4C" end-of-line # alt + shift + right arrow
        "^[[1;4B" end-of-line # alt + down arrow

        "^[[1;4D" beginning-of-line # alt + shift + left arrow
        "^[[1;4A" beginning-of-line # alt + up arrow

        "^[[1;2C" delete-char # shift + right_arrow
        "^[[1;2D" backward-delete-char # shift + left_arrow

        "^[[1;2A" _delete_to_end_of_line # shift + down arrow
        "^[[1;2A" _delete_to_start_of_line # shift + up arrow
    )
else
    ___key_bindings=(
        "^[^[[C" forward-word # alt + right arrow
        "^[^[[D" backward-word # alt + left arrow

        "^[[1;10C" end-of-line # alt + shift + right arrow
        "^[^[[B" end-of-line # alt + down arrow

        "^[[1;10D" beginning-of-line # alt + shift + left arrow
        "^[^[[A" beginning-of-line # alt + up arrow

        "^[[1;2C" delete-char # shift + right_arrow
        "^[[1;2D" backward-delete-char # shift + left_arrow

        "^[[F" delete-char # shift + right_arrow
        "^[[H" backward-delete-char # shift + left_arrow

        "^[[6~" _delete_to_end_of_line # fn + down arrow
        "^[[1;2B" _delete_to_end_of_line # shift + down arrow

        "^[[5~" _delete_to_end_of_line # fn + down arrow
        "^[[1;2A" _delete_to_start_of_line # shift + up arrow

        #"^[[6~" _delete_to_end_of_line # fn + down arrow
        "^[[1;2B" _delete_to_end_of_line # shift + down arrow
        #"^[[5~" _delete_to_end_of_line # fn + down arrow
        "^[[1;2A" _delete_to_start_of_line # shift + up arrow

        # TODO: tmux support
        "^[OP" _while_true_do # fn + F1
        "^[[1;2P" _while_i_is_smaller_than # fn + shift + F1
        "^[OQ" _for_i_in_do # fn + F2
        "^[[1;2Q" _c_style_for_loop # fn + shift + F2
        "^[OR" _awk_space_divider # fn + F3
        "^[OS" _tr_newline_to_space # fn + F4
        "^[[1;2S" _tr_space_to_newline # fn + shift + F4
    )
fi

for key in "${(@k)___key_bindings}"; do
    bindkey "$key" "${___key_bindings[$key]}"
done
unset key

