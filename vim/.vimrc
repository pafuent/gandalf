set nocompatible               " be iMproved, required
filetype off                   " required!

set rtp+=~/.vim/bundle/Vundle.vim/
call vundle#rc()

" let Vundle manage Vundle
" required! 
Bundle 'gmarik/Vundle.vim'

Bundle 'bling/vim-airline'
Bundle 'fugitive.vim'
Bundle 'kien/ctrlp.vim'
Bundle 'scrooloose/syntastic'
Bundle 'scrooloose/nerdtree'
Bundle 'scrooloose/nerdcommenter'
Bundle 'rosenfeld/conque-term'
"Bundle 'majutsushi/tagbar'
"Bundle 'jmcantrell/vim-virtualenv'

Bundle 'morhetz/gruvbox'
Bundle 'chriskempson/tomorrow-theme', {'rtp': 'vim/'}

filetype plugin indent on

" No more swp files
set noswapfile

" Highligth search results
set hlsearch

" To allow swich between buffers without saving them
set hidden

" Colorscheme
set t_Co=256
set background=dark
"colorscheme gruvbox
colorscheme Tomorrow-Night

" Hide the --Insert-- from the status line (the others too)
set noshowmode

" Tabs as spaces
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4

" Aid for 80 chars line length
set colorcolumn=80

" autocompletion of files and commands behaves like shell
" (complete only the common part, list the options that match)
set wildmode=list:longest

" always show status bar
set laststatus=2

" Don't redraw while executing macros (good performance config)
set lazyredraw

" NERDTree ingnore filters
let NERDTreeIgnore=['\~$','\.pyc$']

" Airline
let g:airline_powerline_fonts=1
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_theme = 'powerlineish'
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#tabline#enabled = 1

" Used by CtrlP
set wildignore+=*.pyc

"let g:pyflakes_use_quickfix = 0
"highlight clear SpellBad
"highlight SpellBad cterm=underline ctermfg=1

"let g:tagbar_autofocus = 1

" Set the <leader>
let mapleader=","

" save as sudo
ca w!! w !sudo tee "%"

" better backup, swap and undos storage
set directory=~/.vim/dirs/tmp " directory to place swap files in
set backup " make backup files
set backupdir=~/.vim/dirs/backups " where to put backup files
set undofile " persistent undos - undo after you re-open the file
set undodir=~/.vim/dirs/undos
set viminfo+=n~/.vim/dirs/viminfo

" create needed directories if they don't exist
if !isdirectory(&backupdir)
    call mkdir(&backupdir, "p")
endif
if !isdirectory(&directory)
    call mkdir(&directory, "p")
endif
if !isdirectory(&undodir)
    call mkdir(&undodir, "p")
endif

" CtrlP
let g:ctrlp_working_path_mode = '0'
let g:ctrlp_custom_ignore = 'continuous_integration/reports'

" My mappings
nmap <C-PageUp> :bp<CR>
imap <C-PageUp> <Esc>:bp<CR>
nmap <C-PageDown> :bn<CR>
imap <C-PageDown> <Esc>:bn<CR>
nmap <expr> <C-n> g:NERDTree.IsOpen() ? ':NERDTreeToggle<CR>' : ':NERDTree %:p:h<CR>'
map <C-t> :CtrlPTag<CR>
map <C-b> :ConqueTerm bash<CR>
"map <C-t> :TagbarToggle<CR>
map <C-c> :SyntasticCheck<CR>
map <F3> :set hlsearch!<CR>
