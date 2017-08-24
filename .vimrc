
set modeline
set modelines=5

syntax on

colorscheme timessquare

set number

"inoremap jj <Esc>
"inoremap jk <Esc>
inoremap kj <Esc>

:command TAB set expandtab!

nnoremap B ^

nnoremap E $
nnoremap e $

" Shortcuts for displaying line numbers
:command NU set number!
:command NN set number!

:command FS set tabstop=8 shiftwidth=4 expandtab smarttab
:command SPACES set tabstop=8 shiftwidth=4 expandtab smarttab

:command ET set tabstop=8 shiftwidth=8 noexpandtab nosmarttab
:command TABS set tabstop=8 shiftwidth=8 noexpandtab nosmarttab

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
	"syn match Not "!\(\(\w\|::\)\+<.*>([^)]\+)\|\(\w\|::\)\+\(([^)]*)\)\?\)\(\(->\|\.\)\(\(\w\|::\)\+<.*>([^)]*)\|\(\w\|::\)\+\(([^)]*)\)\?\)\)*"
	"syn match Not "!\(\w\|::\)\+\(<.*>\)\?\(([^)]*)\)\?\(\(->\|\.\)\(\w\|::\)\+\(<.*>\)\?\(([^)]*)\)\?\)*"
	syn match Not "\((\s*\)\@<=!"
	set noexpandtab
	colorscheme rockefellercenter
	call ColorLongLines()
endfunction

:command CS call CStuff()

function! ShellStuff()
	set tabstop=8
	set softtabstop=0
	set expandtab
	set shiftwidth=4
	set smarttab

	colorscheme timessquare

	call ColorLongLines()
endfunction

:command SS call ShellStuff()

au BufRead,BufNewFile *.h set filetype=c

autocmd FileType c,cpp call CStuff()

autocmd FileType python,bash,sh,zsh call ShellStuff()

" When editing a file, always jump to the last cursor position
autocmd BufReadPost *
	\ if line("'\"") > 0 && line ("'\"") <= line("$") |
		\ exe "normal! g'\"" |
	\ endif

