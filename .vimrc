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
set cinoptions:0,l1,g0,(1,E-s,+1
set copyindent
set clipboard+=unnamed
set exrc
set foldmethod=indent
set foldlevel=99
set nowrapscan
set incsearch
set relativenumber
set number
set splitright

command! W w
command! -range=% FormatJson silent <line1>,<line2>!python3 -m json.tool

" Clear search higlight with CTRL+L
nnoremap <silent> <C-l> :noh<CR>

" Use tabs with all file types
augroup indentation
	autocmd!
	autocmd FileType * set noexpandtab
	autocmd FileType * set tabstop=4
	autocmd FileType * set softtabstop=4
	autocmd FileType * set shiftwidth=4
augroup end

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

" Insert closing brace followed by semicolon when typing {;
inoremap {;<CR> {<CR>};<ESC>O
inoremap {<CR> {<CR>}<ESC>O

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

" OS dependent options
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
		set guifont=Menlo:h14
		" set macmeta " Enable ALT key
	elseif has('win32')
		set guifont=Liberation\ Mono:h10
		augroup wingui
			autocmd!
			autocmd GUIEnter * simalt ~x " Maximize window on startup
		augroup end
	endif
endif
