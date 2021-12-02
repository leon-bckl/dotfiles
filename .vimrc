set nocompatible              " be iMproved, required
filetype off                  " required
set fileformat=unix
set fileformats=unix,dos
set encoding=utf-8
set noswapfile

filetype indent plugin on   " Attempt to detect filetype/contents so that vim can autoindent etc
syntax on                   " Enable syntax highlighting
set hidden                  " Enable switching from an  unsaved buffer without saving it first and keep an undo history for multiple files. Warn when quitting without saving, and keep swap files.
set wildmenu                " Better command-line completion
set hlsearch                " Highlight searches
" Use Ctrl+L to temporarily turn off search highlighting
nnoremap <silent> <C-l> :noh<CR>
set ignorecase              " Use case insensitive search
set smartcase               " Use case sensitive search if there are capital letters
set backspace=indent,eol,start   " Allow backspacing over autoindent, line breaks and start of insert action
set autoindent                   " When opening a new line and no filetype-specific indenting is enabled, keep the same indent as the line you're currently on(Useful for READMEs, etc)
set laststatus=2                 " Always display the status line, even if only one window is displayed
set confirm                      " Instead of failing a command because of unsaved changes, instead raise a  dialogue asking if you wish to save changed files
set visualbell                   " Use visual bell instead of beeping when doing something wrong
set ruler                        " Display cursor position
set notimeout ttimeout ttimeoutlen=200  " Quickly time out on keycodes, but never time out on mappings
set cindent
set cinoptions:=:0 "Don't indent case labels
set clipboard+=unnamed            " Share windows clipboard
set exrc                          " Enable Project Specific .vimrc
set foldmethod=syntax
set foldlevel=99

" Use tabs with all file types
autocmd FileType * set noexpandtab
autocmd FileType * set tabstop=4
autocmd FileType * set softtabstop=4
autocmd FileType * set shiftwidth=4

" Make [[ and ]] work when { or } are not in the first column
map [[ ?{<CR>w99[{:noh<CR>
map ][ /}<CR>b99]}:noh<CR>
map ]] j0[[%/{<CR>:noh<CR>
map [] k$][%?}<CR>:noh<CR>

" Move lines up and down with CTRL+J/K
execute "set <C-j>=\ej"
execute "set <C-k>=\ek"
nnoremap <C-j> :m .+1<CR>==
nnoremap <C-k> :m .-2<CR>==
inoremap <C-j> <Esc>:m .+1<CR>==gi
inoremap <C-k> <Esc>:m .-2<CR>==gi
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv

" Enable fuzzy file search on ctrl-p
nnoremap <C-p> :find ./**/*

"Remove trailing whitespace on file save

function! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()

" Insert closing brace followed by semicolon when typing {;
inoremap {;<CR> {<CR>};<ESC>O
inoremap {<CR> {<CR>}<ESC>O

" gui options
if has('gui_running')
	set guioptions=!c

	if has('macunix')
		set guifont=Menlo:h14
		" set macmeta " Enable ALT key
	elseif has('win32')
		set guifont=Liberation\ Mono:h10
		au GUIEnter * simalt ~x " Maximize window on startup
	endif
endif

if has('win32')
	call system('where tee')

	if !v:shell_error
		set shellpipe=\|\ tee
	endif
endif
