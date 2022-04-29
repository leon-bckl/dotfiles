set nocompatible
filetype off
set fileformat=unix
set fileformats=unix,dos
set encoding=utf-8
set noswapfile
filetype indent plugin on
syntax on
set hidden
set wildmenu
set hlsearch
nnoremap <silent> <C-l> :noh<CR>
set ignorecase
set smartcase
set backspace=indent,eol,start
set autoindent
set laststatus=2
set confirm
set visualbell
set ruler
set notimeout ttimeout ttimeoutlen=200
set cindent
set cinoptions:=:0
set clipboard+=unnamed
set exrc
set foldmethod=indent
set foldlevel=99
set nowrapscan
set incsearch

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

" Bind :cp and :cn to g, and g.
nnoremap <silent> g, :cp<CR>
nnoremap <silent> g. :cn<CR>

" Enable fuzzy file search on ctrl-p
nnoremap <C-p> :find ./**/*

" Disable preview window for omni completion
set completeopt-=preview

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

" grep
if !has('win32')
	set grepprg=grep\ -In\ $*
endif

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
