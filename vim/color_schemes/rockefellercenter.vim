" local syntax file - set colors on a per-machine basis:
" vim: tw=0 ts=4 sw=4
" Vim color file
" Based on the "Elf Lord" theme by Ron Aaron <ron@ronware.org>


set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "rockefellercenter"
hi Normal								guifg=11	guibg=black
hi Comment	term=bold			ctermfg=208		guifg=#ffa500
hi Constant	term=underline			ctermfg=39		guifg=Magenta
hi Special	term=bold			ctermfg=red		guifg=Red
hi Identifier	term=underline	cterm=bold	ctermfg=Cyan	 	guifg=#40ffff
hi Statement	term=bold			ctermfg=226 		guifg=#aa4444	gui=bold
hi PreProc	term=underline			ctermfg=LightBlue	guifg=#ff80ff
hi Type		term=underline			ctermfg=9		guifg=#ffff00 	gui=bold
hi Function	term=bold			ctermfg=33 		guifg=Green
hi Repeat	term=underline			ctermfg=DarkGreen	guifg=white
hi Operator					ctermfg=Red		guifg=Red
hi Ignore					ctermfg=Black		guifg=bg
hi Error	term=reverse	ctermbg=Red 	ctermfg=White		guifg=White	guibg=Red
hi Todo		term=standout	ctermbg=Yellow 	ctermfg=Black 		guifg=Blue 	guibg=Yellow

hi LineNr	term=bold			ctermfg=75		guifg=#5fafff
"hi FuncName	term=bold			ctermfg=184		guifg=#5fafff
"hi FuncBraces	term=bold			ctermfg=184		guifg=#5fafff
"hi CalledFunc	term=bold			ctermfg=75		guifg=green
hi PreProc	term=bold			ctermfg=184		guifg=yellow
hi Not		term=bold			ctermfg=9


" Common groups that link to default highlighting.
" You can specify other highlighting easily.
hi link String		Constant
hi link Character	Constant
hi link Number		Constant
hi link Boolean		Constant
hi link Float		Number
hi link Conditional	Repeat
hi link Label		Statement
hi link Keyword		Statement
hi link Exception	Statement
hi link Include		PreProc
hi link Define		PreProc
hi link Macro		PreProc
hi link PreCondit	PreProc
hi link StorageClass	Type
hi link Structure	Type
hi link Typedef		Type
hi link Tag		Special
hi link SpecialChar	Special
hi link Delimiter	Special
hi link SpecialComment	Special
hi link Debug		Special
