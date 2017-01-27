" vim:fdm=marker

" Vundle stuff {{{
set nocompatible
filetype off
if has("win32")
    set rtp+=$HOME/vimfiles/bundle/Vundle.vim/
    call vundle#begin('$USERPROFILE/vimfiles/bundle/')
else
    set rtp+=~/.vim/bundle/Vundle.vim
    call vundle#begin()
endif
Plugin 'VundleVim/Vundle.vim'
Plugin 'scrooloose/nerdcommenter'
Plugin 'ctrlpvim/ctrlp.vim'
if has("win32")
    Plugin 'OmniSharp/omnisharp-vim'
endif
Plugin 'tpope/vim-dispatch'
Plugin 'vim-syntastic/syntastic'
Plugin 'ervandew/supertab'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'PProvost/vim-ps1'
Plugin 'scrooloose/nerdtree'
Plugin 'altercation/vim-colors-solarized'
Plugin 'chaoren/vim-wordmotion'
call vundle#end()
filetype plugin indent on
" }}}
" easy editing of vimrc file {{{
nmap <silent> <leader>ev :tabe $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>
" }}}
" vim-wordmotion configuration {{{
let g:wordmotion_mappings = {
\ 'w': '<C-w>',
\ 'b': '<C-b>',
\ 'e': '<C-e>',
\ 'ge': 'g<C-e>',
\ 'aw': 'a<C-w>',
\ 'iw': 'i<C-w>'
\}
" }}}
" remaps {{{
imap hh <Esc>
nnoremap ; :
vnoremap ; :
" }}}
" color scheme {{{
syntax on
set background=dark
colorscheme solarized
" }}}
" search {{{
set ignorecase
set smartcase
set incsearch
" }}}
" tabs {{{
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set shiftround
set autoindent
set smarttab
" }}}
" show whitespace {{{
set list
set listchars=tab:>.,trail:.,extends:#,nbsp:.
" }}}
" run bash from vim {{{
nmap <silent> <leader>ba :! bash<CR>
" }}}
" misc. settings {{{
set number
set nowrap
set showmatch
set backspace=indent,eol,start
set history=1000
set undolevels=1000
set wildignore=*.swp,*.bak,*.pyc,*.class
set title
set visualbell
set noerrorbells
" }}}
" custom functions {{{
" toggle between number and relativenumber
function! ToggleNumber()
    if(&relativenumber == 1)
        set norelativenumber
        set number
    else
        set relativenumber
    endif
endfunc

" format json
function! FormatJson()
    %!python -m json.tool
endfunc
" }}}
