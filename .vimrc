syntax on
set nocompatible
set modelines=5
set number
set ignorecase
set smartcase
set ruler

" Default colorscheme. Will be overridden for some file types.
colorscheme timessquare

" Sometimes I need the 'kj' mapping to be disabled when I'm pasting text into Vim.
function! ToggleEscAliases()
	if (!exists("s:EscAliasesEnabled")) || (s:EscAliasesEnabled == 0)
		inoremap kj <Esc>
		let s:EscAliasesEnabled = 1
	elseif s:EscAliasesEnabled == 1
		iunmap kj
		let s:EscAliasesEnabled = 0
	endif
endfunction
:command ESC call ToggleEscAliases()
:command E call ToggleEscAliases()
" Enable the <Esc> aliases by default.
call ToggleEscAliases()

" For getting to the start of the line more easily.
nnoremap B ^

" For getting to the end of the line more easily.
nnoremap E $
nnoremap e $

" Shortcuts for displaying line numbers
:command NU set number!
:command NN set number!

" Set Vim to use spaces instead of tabs.
:command FS set tabstop=8 shiftwidth=4 expandtab smarttab
:command SPACES set tabstop=8 shiftwidth=4 expandtab smarttab

" Set Vim to use tabs instead of spaces.
:command ET set tabstop=8 shiftwidth=8 noexpandtab nosmarttab
:command TABS set tabstop=8 shiftwidth=8 noexpandtab nosmarttab

" Reload this file.
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
" Enable colored long lines by default.
call ColorLongLines()

" Some Mac OS versions don't recognize these file types by default.
au BufNewFile,BufRead *.c,*.h setlocal filetype=c
au BufNewFile,BufRead *.cpp,*.hpp setlocal filetype=cpp
au BufNewFile,BufRead *.ino setlocal filetype=arduino
au BufNewfile,BufRead *.go setlocal filetype=go
au BufNewfile,BufRead *.awk,*.gawk setlocal filetype=awk

au Filetype c,go setlocal noexpandtab
au FileType cpp,arduino setlocal tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab
au FileType c,cpp,arduino,go colorscheme rockefellercenter

au FileType python,bash,sh,zsh,awk setlocal tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab

" When editing a file, always jump to the last cursor position
autocmd BufReadPost *
	\ if line("'\"") > 0 && line ("'\"") <= line("$") |
		\ exe "normal! g'\"" |
	\ endif

