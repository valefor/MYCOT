"==================================
"Edit by Herr_Alucard
"==================================
"Non-Compatible Mode
set nocp
"The useful global configuration
"==================================
syn on
set nohlsearch
highlight Comment term=bold ctermfg=2
highlight Constant term=underline ctermfg=7

"vim temp
"let vimtdir=$HOME .'/.vim/vimtmp'
"set backup
"let &backupdir=vimtdir
"let &directory=vimtdir
"let &viminfo="'20,".'%,n'.'~/.vim/viminfo'
"set backup
"set history=1000

set number 
set tabstop=4
set expandtab
set softtabstop=4
set shiftwidth=4
set backspace=2
set autoindent
set showmatch
set ai
set ruler
colo freya
set tags=tags;
set autochdir
set showcmd
set smartcase
set incsearch

filetype on

"Statusline	
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]\ [POS=%04l,%04v][%p%%]\ [LEN=%L]
"set statusline=%<%F%h%m%r=\[%B\]\ %l,%c%V\ %P 
set laststatus=2
"==================================
"The shortcut 
"==================================
"Set mapleade
let mapleader=","
"Fast reloading of the .vimrc
map <silent><leader>ss:source ~/.vimrc<cr>
"Fast editing of .vimrc
map <silent><leader>ee:e ~/.vimrc<cr>
"When .vimrc is edited ,reload it
autocmd! bufwritepost .vimrc source ~/.vimrc

"==================================
"Key&Shortcut Mapping
"==================================
map <F2> : w!<CR>
imap <F2> <ESC>:w!<CR>li

map <F3> : TlistToggle<CR>5<C-w>h
imap <F3> <ESC>:TlistToggle<CR>l5<C-w>hi

"Deprecated
map <F4> : set invnumber<CR>5<C-w>h
imap <F4> <ESC>:set invnumber<CR>l5<C-w>hi

"map <F5> : set e!<CR>
"imap <F5> <ESC>:e!<CR>li

" Refresh
map <F6> :e!<CR>5<C-w>h
imap <F6> <ESC>:e!<CR>l5<C-w>hi

"New Tab
map <F10> :tabnew<CR>5<C-w>h
imap <F10> <ESC>:tabnew<CR>l5<C-w>hi

"previous Tab
map <F11> :tabp<CR>5<C-w>h
imap <F11> <ESC>:tabp<CR>l5<C-w>hi

"next Tab
map <F12> :tabn<CR>5<C-w>h
imap <F12> <ESC>:tabn<CR>l5<C-w>hi

map <MouseDown> :<C-Y>
map <MouseUp> :<C-E>

"nmap edv :e ~/_vimrc<CR>
"nmap scv :source ~/_vimrc<CR>

"Upcase the first char of word in current line
nmap gUu :.s/\([_\s]*\)\([0-9a-zA-Z]*\)/\=submatch(1).substitute(tolower(submatch(2)),'.*','\u&','g')/g<CR>

nmap fu :set fileformat=unix<CR><F2>
nmap fd :set fileformat=dos<CR><F2>
"nmap cp :!cp -f % c:\cygwin\home\ehuufei\ttcn\quick_test<CR><ESC>
" In unix erv
" nmap cp :!cp % /scratch/j20/ft/ehuufei/testsuite/quick_test/<CR><ESC>
"nmap <C-[> :ts<CR>

"Fast Comments
nmap ZC :.s/^\(.*\)$/\/\*\1\*\/<CR>:set nohlsearch<CR><ESC>j
nmap Zc :.s/\/\*\(.*\)\*\//\1<CR>:set nohlsearch<CR><ESC>j

"------------------------------------------------------------------------
" Alucard's fast edit
"------------------------------------------------------------------------
nmap zy viwy
nmap zp viwp

"------------------------------------------------------------------------
" Set options and add mapping such that Vim behaves a lot like MS-Windows
"------------------------------------------------------------------------
source $VIMRUNTIME/mswin.vim
behave mswin

"==================================
"The custom function
"==================================
"Platform
function!MySys()
	if has("win32")
		return "windows"
	else
		return "linux"
	endif
endfunction

"SwitchToBuf--Open/Edit a new file in a new Tab
function! SwitchToBuf(filename)
"let fullfn=substitute(a:filename,"^\\~/",$HOME."/","")
"find in current tab
let bufwinnr=bufwinnr(a:filename)
if bufwinnr !=-1
	exec bufwinnr ."wincmd w"
	return
else
	"finde in each tab
	tabfirst
	let tab=1
	while tab <= tabpagenr("$")
		let bufwinnr =bufwinnr(a:filename)
		if bufwinnr !=-1
			exec "normal".tab."gt"
			exec bufwinnr."wincmd w"
			return
		endif
		tabnext
		let tab = tab+1
	endwhile
	"not exist,new tab
	exec "tabnew". a:filename
endfunction


"==================================
"Tag List(ctags)
"==================================
if MySys()=="windows"
	let Tlist_Ctags_Cmd='ctags'
elseif MySys()=="linux"
	let Tlist_Ctags_Cmd='/usr/bin/ctags'
endif
let Tlist_Show_One_File = 1
let Tlist_Exit_OnlyWindows = 1
let Tlist_Use_Right_Window = 1
let Tlist_Sort_Type ="order"
let Tlist_Display_Prototype=0
let Tlist_Compart_Format=1
let Tlist_GainFocus_On_ToggleOpen=0
let Tlist_Close_On_select=0
let Tlist_Enable_Fold_Column=0
let Tlist_WinWidth=40
" AVP format
nmap ,at :!avpfmt % REPLACE <CR>
" Module format
nmap ,mt :!mfmt % <CR>
" Super Module format
nmap ,st :g/\(^\s*$\n\)*\(\/\/\s*\w*\n\)*import from.\n*/d<CR>:!mfmt % <CR>

"==================================
" C++ keywords highlights
"==================================
" !Install Syntastic first: https://github.com/scrooloose/syntastic
execute pathogen#infect()
" For g++
nmap gpl :!g++ -std=c++11 % <CR>
nmap cpl :!clang % <CR>
let g:syntastic_cpp_compiler_options = ' -std=c++11'
" For clang
"let g:syntastic_cpp_compiler = 'clang++'
"let g:syntastic_cpp_compiler_options = ' -std=c++11 -stdlib=libc++'
