
syntax on

colorscheme timessquare

set number

inoremap jj <Esc>
inoremap jk <Esc>
inoremap kj <Esc>

:command TAB set expandtab!

nnoremap B ^

nnoremap E $
nnoremap e $

" Shortcuts for displaying line numbers
:command NU set number!
:command NN set number!

:command RL source ~/.vimrc

" Map ; to :
nnoremap ; :
vnoremap ; :


" Highlight any text that is beyond the 81st column
function! ColorLongLines()
	if (!exists("s:LongLinesColored")) || (s:LongLinesColored == 0)
		"highlight OverLength ctermbg=1 ctermfg=226
		highlight OverLength ctermbg=242
		match OverLength /\%81v.\+/
		let s:LongLinesColored = 1
	elseif s:LongLinesColored == 1
		highlight OverLength NONE
		let s:LongLinesColored = 0
	endif
endfunction

:command LL call ColorLongLines()

function! CStuff()
	" For changing the colors of function names and braces/parenthases in C
	" TODO: Fix these
	"syn match FuncBraces "^[{}]$"
	"syn match FuncName " \w\+("
	"syn match FuncName ")$"
	"syn match CalledFunc "\t\w*("
	"syn match CalledFunc ");"

	syn match Not "![A-Za-z0-9_.]\+"

	" For the '->' operator
	syn match Not "![A-Za-z0-9_]\+->[A-Za-z0-9_]\+"

	set noexpandtab

	colorscheme rockefellercenter

	call ColorLongLines()
endfunction

function! ShellStuff()
	set tabstop=4
	set softtabstop=0
	set expandtab
	set shiftwidth=4
	set smarttab

	colorscheme timessquare

	call ColorLongLines()
endfunction

autocmd FileType c call CStuff()

autocmd FileType python,bash,sh,zsh call ShellStuff()


