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
set cinoptions=:0,l1,g0,(1,E-s,+1,N-s
set copyindent
set clipboard+=unnamed
set exrc
set foldmethod=indent
set foldlevel=99
set nowrapscan
set incsearch
set splitright
set completeopt-=preview
set display=lastline,uhex
set formatoptions+=j
set autoread
set tabstop=2
set number
set relativenumber
set path=.,**

" Use tabs with all file types
augroup indentation
	autocmd!
	autocmd FileType * set noexpandtab
	autocmd FileType * set tabstop=2
	autocmd FileType * set softtabstop=2
	autocmd FileType * set shiftwidth=0
augroup end

" Custom shortcuts
map <space> <leader>
nnoremap <leader>m :wa \| silent! make! \| cwindow<CR>
nnoremap <leader>h :noh<CR>
nnoremap <leader>n :set number!<CR>
nnoremap <leader>N :set relativenumber!<CR>
nnoremap <leader>, :cp<CR>
nnoremap <leader>. :cn<CR>
xnoremap <leader>p "_dP
noremap <C-d> <C-d>zz
noremap <C-u> <C-u>zz
noremap <C-f> <C-f>M
noremap <C-b> <C-b>M
nnoremap n nzz
nnoremap N Nzz

command! W w
command! -range=% FormatJson silent <line1>,<line2>!python3 -m json.tool

function! OpenScratchBuffer()
	let scratch_bufnr = -1
	for bufnr in range(1, bufnr('$'))
		if getbufvar(bufnr, '&buftype') ==# 'nofile' && buflisted(bufnr)
			let scratch_bufnr = bufnr
			break
		endif
	endfor

	if scratch_bufnr == -1
		enew | setlocal buftype=nofile bufhidden=hide noswapfile
	else
		execute 'buffer' scratch_bufnr
	endif
endfunction

command! Scratch call OpenScratchBuffer()

" Make [[ and ]] work when { or } are not in the first column
map <silent> [[ ?{<CR>:silent! normal! 99[{<CR>:noh<CR>
map <silent> ]] :silent! normal! 99]}<CR>:silent! normal! $<CR>/{<CR>:noh<CR>

" Move lines up and down with CTRL+J/K
execute "set <C-j>=\ej"
execute "set <C-k>=\ek"
nnoremap <C-j> :m .+1<CR>==
nnoremap <C-k> :m .-2<CR>==
inoremap <C-j> <Esc>:m .+1<CR>==gi
inoremap <C-k> <Esc>:m .-2<CR>==gi
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv

" Insert closing brace followed by semicolon when typing {;
inoremap {;<CR> {<CR>};<ESC>O
inoremap {<CR> {<CR>}<ESC>O

" Remove trailing whitespace on file save
function! <SID>StripTrailingWhitespaces()
	if &ft != "markdown"
		let l = line(".")
		let c = col(".")
		%s/\s\+$//e
		call cursor(l, c)
	endif
endfun

augroup stripwhitespace
	autocmd!
	autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()
augroup end

" OS specific options
if has('win32')
	set errorformat+=%f\ :\ error\ %m

	call system('where tee')

	if !v:shell_error
		set shellpipe=\|\ tee
	endif
else
	set grepprg=grep\ -In\ $*
	set errorformat+=%f:l:c:\ error:\ %m
endif

" GUI options
if has('gui_running')
	set guioptions=!c

	if has('macunix')
		set guifont=Menlo:h12
		" set macmeta " Enable ALT key
	elseif has('win32')
		set guifont=Liberation\ Mono:h10
		augroup wingui
			autocmd!
			autocmd GUIEnter * simalt ~x " Maximize window on startup
		augroup end
	endif
endif

" Custom syntax higlight
augroup highlightcustom
	autocmd!
	" Custom types
	autocmd Syntax c,cpp,objc,objcpp syntax keyword cType b8 b32 i8 u8 i16 u16 i32 u32 i64 u64 iptr uptr isize usize f32 f64
	autocmd Syntax c,cpp,objc,objcpp syntax match cType "\<enum_" " Only highlight the 'enum_' prefix on sized enum typedefs
	" Custom macros
	autocmd Syntax c,cpp,objc,objcpp syntax keyword cDefine ASSERT UNUSED
	" Function names
	autocmd Syntax c,cpp,objc,objcpp syntax match cCustomParen "?=(" contains=cParen,cCppParen
	autocmd Syntax c,cpp,objc,objcpp syntax match cCustomFunc  "\w\+\s*(\@=" contains=cCustomParen
	autocmd Syntax c,cpp,objc,objcpp highlight def link cCustomFunc Function
	" Win32 types
	autocmd Syntax c,cpp syntax keyword cType BYTE WORD DWORD BOOL SHORT USHORT INT UINT LONG ULONG LONGLONG ULONGLONG LONG_PTR ULONG_PTR DWORD_PTR SIZE_T WPARAM LPARAM LRESULT HRESULT HANDLE HINSTANCE HMODULE HWND HICON HCURSOR HBRUSH HKL HRAWINPUT HDC HGLRC LARGE_INTEGER POINT RECT GUID PROC FARPROC HANDLER_ROUTINE SYSTEM_INFO MEMORYSTATUSEX SYSTEMTIME SECURITY_ATTRIBUTES THREAD_START_ROUTINE FILETIME WIN32_FILE_ATTRIBUTE_DATA GET_FILEEX_INFO_LEVELS WIN32_FIND_DATAW OVERLAPPED MSG WNDPROC WNDCLASSEXW RAWINPUTHEADER RAWMOUSE RAWKEYBOARD RAWHID RAWINPUT RAWINPUTDEVICE PIXELFORMATDESCRIPTOR
	" OpenGL types and macros
	autocmd Syntax c,cpp,objc,objcpp syntax keyword cType GLenum GLbitfield GLuint GLint GLsizei GLboolean GLbyte GLshort GLubyte GLushort GLulong GLfloat GLclampf GLdouble GLclampd GLvoid GLchar GLintptr GLsizeiptr
	autocmd Syntax c,cpp,objc,objcpp syntax match cConstant "\<GL_[A-Z0-9\_]\+\>"
	autocmd Syntax c,cpp,objc,objcpp syntax match cConstant "\<WGL_[A-Z0-9\_]\+\>"
augroup end

" Plugins

let s:use_plugins=v:true

if !s:use_plugins
	nnoremap <C-p> :find ./**/*
	colorscheme desert
else
	" Download plug.vim if it doesn't already exist (not on windows because I can't be bothered)
	let s:plugins_need_install=v:false
	if !has('win32') && empty(glob('~/.vim/autoload/plug.vim'))
		let s:plugins_need_install=v:true
		silent !echo 'Installing vim plug'
		silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
		source ~/.vim/autoload/plug.vim
	endif

	" Set coc extensions that should be installed automatically
	let g:coc_global_extensions = [
		\'coc-json',
		\'coc-clangd'
	\]

	let g:vimspector_install_gadgets = ['CodeLLDB']
	let g:vimspector_enable_mappings = 'VISUAL_STUDIO'
	let g:alternateNoDefaultAlternate = 1
	let g:strictAlternateMatching = 1

	" Setup plugins
	call plug#begin('~/.vim/plugged')

	Plug 'ctrlpvim/ctrlp.vim'
	Plug 'morhetz/gruvbox'
	Plug 'neoclide/coc.nvim', {'branch': 'release','do': {-> coc#util#install()}}
	Plug 'tpope/vim-fugitive'
	Plug 'tpope/vim-surround'
	Plug 'tpope/vim-commentary'
	Plug 'markonm/traces.vim'
	Plug 'nacitar/a.vim'

	if !has('win32')
		Plug 'puremourning/vimspector'
	endif

	call plug#end()

	if s:plugins_need_install
		PlugInstall

		if !has('win32')
			VimspectorInstall
		endif
	endif

	" Include git branch in status line
	set statusline=%f%m\ %{FugitiveStatusline()}\ %h%w%r%=%-14.(%l,%c%V%)\ %P

	" ctrlpvim

	let g:ctrlp_custom_ignore = {
		\ 'dir': '\.git\|.build'
	\ }
	let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
	let g:ctrlp_use_caching = 1
	let g:ctrlp_working_path_mode = 0
	let g:ctrlp_max_files = 25000

	" Coc

	" Use `g[` and `g]` to navigate diagnostics
	" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
	nmap <silent> g[ <Plug>(coc-diagnostic-prev)
	nmap <silent> g] <Plug>(coc-diagnostic-next)

	function! s:GoToDefinition()
		if CocHasProvider('definition') && CocAction('jumpDefinition')
			return v:true
		endif

		let ret = execute("tag " . " " . expand('<cword>'))
		if ret =~ "Error"
			call searchdecl(expand('<cword>'))
		endif
	endfunction

	nmap <silent> <C-]> :call <SID>GoToDefinition()<CR>
	nmap <silent> gr <Plug>(coc-references)

	" Use K to show documentation in preview window.
	nnoremap <silent> K :call <SID>show_documentation()<CR>

	function! s:show_documentation()
		if (index(['vim','help'], &filetype) >= 0)
			execute 'h '.expand('<cword>')
		elseif (coc#rpc#ready())
			call CocActionAsync('doHover')
		else
			execute '!' . &keywordprg . " " . expand('<cword>')
		endif
	endfunction

	augroup coc
		" Highlight the symbol and its references when holding the cursor.
		autocmd CursorHold * silent call CocActionAsync('highlight')
	augroup end

	" Symbol renaming.
	nmap gR <Plug>(coc-rename)

	" gruvbox
	colorscheme gruvbox
	set background=dark
endif

