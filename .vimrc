" vim:fdm=marker

" Vundle stuff {{{
set nocompatible
filetype off
if has('win32')
    set rtp+=$HOME/vimfiles/bundle/Vundle.vim/
    call vundle#begin('$USERPROFILE/vimfiles/bundle/')
else
    set rtp+=~/.vim/bundle/Vundle.vim
    call vundle#begin()
endif
Plugin 'VundleVim/Vundle.vim' " the plugin which runs Vundle
Plugin 'scrooloose/nerdcommenter' " commenting functionality
Plugin 'ctrlpvim/ctrlp.vim' " fuzzy search
Plugin 'PProvost/vim-ps1' " Powershell syntax highlighting
Plugin 'scrooloose/nerdtree' " filesystem explorer
Plugin 'altercation/vim-colors-solarized' " the solarized color scheme
Plugin 'chaoren/vim-wordmotion' " supports CamelCase motion in words
Plugin 'vim-airline/vim-airline' " a statusline plugin
Plugin 'vim-airline/vim-airline-themes' " themes for vim-airline
Plugin 'tpope/vim-surround' " surround text in quotes, HTML tags, etc.
if has('python') || has('python3')
    Plugin 'Valloric/YouCompleteMe' " code completion engine
endif
Plugin 'tpope/vim-fugitive' " git plugin
Plugin 'tmhedberg/SimpylFold' " syntax folding for Python
Plugin 'Rykka/riv.vim' " restructuredtext features
call vundle#end()
filetype plugin indent on
" }}}
" leader keys {{{
:let mapleader = "," " semicolon is the leader key
" }}}
" remaps {{{
" easier remappings of common commands {{{
inoremap uu <Esc>| " use "uu" to exit insert mode
inoremap hh <Esc>:w<CR>| " use "hh" to exit insert mode and save
nnoremap <space> :| " remap space to : in normal mode for ease of use
vnoremap <space> :| " remap space to : in visual mode for ease of use
nnoremap <space><space> :wq<CR>| " remap space twice to save and quit for ease of use
nnoremap <BS> :w<CR>| " remap backspace to save
nnoremap <CR><CR> :q<CR>| " remap enter twice to quit
" }}}
" use H and L to go to beginning and end of lines {{{
noremap H ^| " H moves to first non-blank character of line
noremap L g_| " L moves to last non-blank character of line
" }}}
" easier scrolling/scrolling that doesn't conflict with existing mappings {{{
nnoremap <c-h> <c-e>| " scroll down
nnoremap <c-n> <c-y>| " scroll up
" }}}
" }}}
" autocmds {{{
" fixes the problem detailed at http://vim.wikia.com/wiki/Keep_folds_closed_while_inserting_text {{{
" Without this, folds open and close at will as you type code.
augroup fixfolds
    autocmd!
    autocmd InsertEnter * if !exists('w:last_fdm') | let w:last_fdm=&foldmethod | setlocal foldmethod=manual | endif
    autocmd InsertLeave,WinLeave * if exists('w:last_fdm') | let &l:foldmethod=w:last_fdm | unlet w:last_fdm | endif
augroup END
" }}}
" }}}
" plugin configuration {{{
" solarized configuration {{{
syntax on " turn on syntax highlighting
set background=dark " use the dark background theme for solarized
let g:solarized_italic=0 " don't italicize text in solarized (it sometimes draws weird in gVim)
if !has('gui_running')
    let g:solarized_termcolors=256 " make sure to use 256 color mode if running in a terminal
endif
" }}}
" vim-wordmotion configuration {{{
" require CTRL key to perform CamelCase motion
let g:wordmotion_mappings = {
\ 'w': '<C-w>',
\ 'b': '<C-b>',
\ 'e': '<C-e>',
\ 'ge': 'g<C-e>',
\ 'aw': 'a<C-w>',
\ 'iw': 'i<C-w>'
\}
" }}}
" vim-airline configuration {{{
set laststatus=2 " show the statusline all the time, rather than only when a split is created
let g:airline#extensions#tabline#enabled=1 " use the tabline
let g:airline_powerline_fonts=1 " use the fonts that give you the cool arrows in the status line
set encoding=utf8 " make sure we're using the correct encoding for the symbols
if has('gui_running')
    set guifont=Ubuntu_Mono_derivative_Powerlin:h11
endif
let g:airline_theme='dark'
" }}}
" YouCompleteMe configuration {{{
let g:ycm_goto_buffer_command='new-or-existing-tab'
" }}}
" vim-fugitive configuration {{{
nnoremap <leader>gd :Gvdiff<CR>| " display a diff view of the current file
" }}}
" }}}
" easy editing of vimrc file {{{
nnoremap <silent> <leader>ev :tabe $MYVIMRC<CR>| " open .vimrc in new tab
nnoremap <silent> <leader>sv :so $MYVIMRC<CR>| " resource .vimrc
" }}}
" color scheme {{{
colorscheme solarized " set the color scheme to use solarized
" }}}
" search {{{
set ignorecase " make search case insensitive
set smartcase " ignore case if only lowercase characters used in search text
set incsearch " show search results incrementally as you type
" }}}
" tabs {{{
set expandtab " tabs are expanded to spaces
set tabstop=4 " tabs count as 4 spaces
set softtabstop=4 " tabs count as 4 spaces while performing editing operations (yeah, I don't really understand this either)
set shiftwidth=4 " number of spaces used for autoindent
set shiftround " should round indents to multiple of shiftwidt
set autoindent " automatically indent lines
set smarttab " be smart about how you use shiftwidth vs tabstop or softtabstop I think
" }}}
" show whitespace {{{
set list " display whitespace characters
set listchars=tab:>.,trail:.,extends:#,nbsp:. " specify which whitespace characters to display ('trail' is for trailing spaces, and 'extends' is for when the line extends beyond the right end of the screen)
" }}}
" run bash from vim {{{
nnoremap <silent> <leader>ba :! bash<CR>| " a shortcut for running bash
" }}}
" misc. settings {{{
set number " show line numbers
set nowrap " don't wrap lines
set showmatch " show matching bracket when one is inserted
set backspace=indent,eol,start " be able to backspace beyond the point where insert mode was entered
set history=1000 " the length of the : command history
set undolevels=1000 " maximum number of changes that can be undone
set wildignore=*.swp,*.bak,*.pyc,*.class " file patterns to ignore when expanding wildcards
set title " title of window set to titlename/currently edited file
set visualbell " use visual bell instead of beeping
set noerrorbells " don't ring the bell for error messages
set foldmethod=syntax " fold based on the language syntax (e.g. #region tags)
set colorcolumn=80,120 " highlight the 80th and 120th columns for better line-length management
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
