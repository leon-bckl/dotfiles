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

" Custom mappings
map <space> <leader>
nnoremap <leader>m :wa \| silent! make! \| cwindow<CR>
nnoremap <leader>o :copen<CR>
nnoremap <leader>c :cclose<CR>
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

" Open a new scratch buffer that cannot be saved or use the existing one
function! s:OpenScratchBuffer()
	let buf = bufnr('scratch')
	if buf != -1
		execute 'buffer' . buf
	else
		enew
		setlocal buftype=nofile
		setlocal bufhidden=hide
		setlocal noswapfile
		file scratch
	endif
endfunction
command! Scratch call <SID>OpenScratchBuffer()

" Remove all lines from quickfix that do not point to a file location
function! s:CleanQuickFixList()
	let list = getqflist()
	let newlist = []

	for item in list
		if item['valid']
			call add(newlist, item)
		endif
	endfor

	if !empty(newlist)
		call setqflist(newlist)
	endif
endfunction
nnoremap <leader>q :call <SID>CleanQuickFixList()<CR>

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
function! s:StripTrailingWhitespaces()
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

" Search with ag
if executable('ag')
	" Define a custom command `Ag` to execute `ag` without changing `grepprg`
	command! -nargs=+ Ag call <SID>SearchWithAg(<q-args>)

	" Function to execute `ag` and populate the quickfix list
	function! s:SearchWithAg(...) abort
		" Join the command line arguments passed to `Ag`
		let l:args = join(a:000, ' ')
		" Run `ag --vimgrep` and capture the output in the quickfix list
		execute 'cgetexpr system("ag --vimgrep " . l:args)'
		" Open the quickfix window if there are results
		if len(getqflist()) > 0
			copen
		else
			echo 'No results found for ' . l:args
		endif
	endfunction
endif

" OS specific options
if has('win32')
	set errorformat+=%f\ :\ error\ %m

	if executable('tee')
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
	let g:NERDTreeWinSize=32
	let g:NERDTreeMinimalUI=1
	let g:NERDTreeMapHelp='F1>'

  let g:vim_ai_chat = {
  \  "options": {
  \    "model": "gpt-4o",
  \    "max_tokens": 1000,
  \    "endpoint_url": "https://api.openai.com/v1/chat/completions",
  \    "temperature": 1,
  \    "request_timeout": 20,
  \    "enable_auth": 1,
  \    "selection_boundary": "#####",
  \  },
  \  "ui": {
  \    "code_syntax_enabled": 1,
  \    "populate_options": 0,
  \    "open_chat_command": "preset_below",
  \    "scratch_buffer_keep_open": 0,
  \    "paste_mode": 1,
  \  },
  \}

	" Setup plugins
	call plug#begin('~/.vim/plugged')

	Plug 'junegunn/fzf', {'do': {-> fzf#install()}}
	Plug 'junegunn/fzf.vim'
	Plug 'morhetz/gruvbox'
	Plug 'neoclide/coc.nvim', {'branch': 'release','do': {-> coc#util#install()}}
	Plug 'tpope/vim-fugitive'
	Plug 'tpope/vim-surround'
	Plug 'tpope/vim-commentary'
	Plug 'markonm/traces.vim'
	Plug 'nacitar/a.vim'
	Plug 'Raimondi/delimitMate'
	Plug 'madox2/vim-ai'
	Plug 'preservim/NERDTree'

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

	" fzf

	nnoremap <silent><expr> <C-p> (len(system('git rev-parse')) ? ':Files' : ':GFiles') . "\<CR>"
	nnoremap <silent> <leader>b :Buffers<CR>

	" Coc

	nnoremap <leader>[ <Plug>(coc-diagnostic-prev)
	nnoremap <leader>] <Plug>(coc-diagnostic-next)
	nnoremap <silent> <C-[> :call <SID>GoToDefinition('declaration', 'jumpDeclaration')<CR>
	nnoremap <silent> <C-]> :call <SID>GoToDefinition('definition', 'jumpDefinition')<CR>
	nnoremap <leader>r <Plug>(coc-references)
	nnoremap <leader>R <Plug>(coc-rename)
	nnoremap <leader>a <Plug>(coc-fix-current)
	nnoremap <leader>x <Plug>(coc-refactor)
	nnoremap <leader>u <Plug>(coc-format)
	inoremap <silent><expr> <C-space> coc#refresh()
	inoremap <silent> <C-tab> <C-r>=CocActionAsync('showSignatureHelp')<CR>
	nnoremap <silent> K :call <SID>ShowDocumentation()<CR>

	function! s:GoToDefinition(cocProvider, cocAction)
		if CocHasProvider(a:cocProvider) && CocAction(a:cocAction)
			return v:true
		endif

		let ret = execute("tag " . " " . expand('<cword>'))
		if ret =~ "Error"
			call searchdecl(expand('<cword>'))
		endif
	endfunction

	function! s:ShowDocumentation()
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
		autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
	augroup end

	" NERDTree
	nnoremap <silent> <leader>f :NERDTreeFind<CR>
	nnoremap <silent> <leader>t :NERDTreeFocus<CR>

	" gruvbox
	colorscheme gruvbox
	set background=dark
endif
