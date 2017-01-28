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
Plugin 'VundleVim/Vundle.vim' " the plugin which runs Vundle
Plugin 'scrooloose/nerdcommenter' " commenting functionality
Plugin 'ctrlpvim/ctrlp.vim' " fuzzy search
if has("win32")
    Plugin 'OmniSharp/omnisharp-vim' " C# syntax-highlighting, code completion, etc.
endif
Plugin 'tpope/vim-dispatch' " async builds, needed for OmniSharp's server
Plugin 'vim-syntastic/syntastic' " syntax checking
Plugin 'ervandew/supertab' " uses <TAB> for completion
Plugin 'SirVer/ultisnips' " snippet functionality
Plugin 'honza/vim-snippets' " snippets for ultisnips
Plugin 'PProvost/vim-ps1' " Powershell syntax highlighting
Plugin 'scrooloose/nerdtree' " filesystem explorer
Plugin 'altercation/vim-colors-solarized' " the solarized color scheme
Plugin 'chaoren/vim-wordmotion' " supports CamelCase motion in words
call vundle#end()
filetype plugin indent on
" }}}
" easy editing of vimrc file {{{
nmap <silent> <leader>ev :tabe $MYVIMRC<CR>| " open .vimrc in new tab
nmap <silent> <leader>sv :so $MYVIMRC<CR>| " resource .vimrc
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
" remaps {{{
imap hh <Esc>| " use "hh" to get out of input mode
nnoremap ; :| " remap ; to : in normal mode for ease of use
vnoremap ; :| " remap ; to : in visual mode for ease of use
" }}}
" color scheme {{{
syntax on " turn on syntax highlighting
set background=dark " use the dark background theme for solarized
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
nmap <silent> <leader>ba :! bash<CR>| " a shortcut for running bash
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
