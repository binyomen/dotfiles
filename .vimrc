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
Plugin 'fatih/vim-go' " Go plugin
Plugin 'lervag/vimtex' " LaTeX plugin
Plugin 'rust-lang/rust.vim' " Rust plugin
Plugin 'editorconfig/editorconfig-vim' " .editorconfig support
call vundle#end()
filetype plugin indent on
" }}}
" leader keys {{{
let mapleader = ',' " semicolon is the leader key
let maplocalleader = '\\' " backslash is the localleader key
" }}}
" remaps {{{
" easier remappings of common commands {{{
inoremap uu <Esc>| " use "uu" to exit insert mode
inoremap hh <Esc>:w<CR>| " use "hh" to exit insert mode and save
nnoremap <space> :| " remap space to : in normal mode for ease of use
vnoremap <space> :| " remap space to : in visual mode for ease of use
nnoremap <space><space> :wq<CR>| " remap space twice to save and quit for ease of use
nnoremap <BS> :w<CR>| " remap backspace to save in normal mode
vnoremap <BS> :w<CR>| " remap backspace to save in visual mode
nnoremap <CR><CR> :q<CR>| " remap enter twice to quit
" }}}
" use H and L to go to beginning and end of lines {{{
" NOTE: nmap is used here rather than nnoremap in order for the .txt filetype
" configuration to be able to make use of these mappings. If a better way to
" deal with this is found, it will be changed.
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
" filetype configuration {{{
" .txt files {{{
augroup txt_files
    autocmd!
    autocmd FileType text setlocal wrap linebreak " set linewrapping
    autocmd FileType text setlocal spell spelllang=en_us " use the en_us dictionary

    " standard motion commands should move by wrapped lines
    autocmd FileType text noremap <buffer> <silent> k gk
    autocmd FileType text noremap <buffer> <silent> j gj
    autocmd FileType text noremap <buffer> <silent> 0 g0
    autocmd FileType text noremap <buffer> <silent> $ g$
    autocmd FileType text noremap <buffer> <silent> ^ g^
    autocmd FileType text noremap <buffer> <silent> H g^
    autocmd FileType text noremap <buffer> <silent> L g$| " TODO: this should be changed to gg_ or whatever the linewrapping version of g_ is
    "autocmd FileType text noremap <buffer> <silent> g_ gg_| " TODO: is there a linewrapping version of g_?
augroup END
" }}}
" gitcommit files {{{
augroup gitcommit_files
    autocmd!
    autocmd FileType gitcommit setlocal spell
augroup END
" }}}
" go files {{{
augroup go_files
    autocmd!
    autocmd FileType go setlocal rtp+=$GOPATH/src/github.com/golang/lint/misc/vim " add golint for vim to the runtime path
    autocmd BufWritePost,FileWritePost *.go execute 'mkview!' | execute 'Lint' | execute 'silent! loadview'| " execute the Lint command on write
augroup END
" }}}
" markdown files {{{
augroup markdown_files
    autocmd!
    autocmd FileType markdown setlocal formatoptions+=a " automatically wrap lines
    autocmd FileType markdown setlocal spell " turn on spellcheck
augroup END
" }}}
" tex files {{{
augroup tex_files
    autocmd!
    autocmd FileType tex setlocal spell " turn on spellcheck
augroup END
" }}}
" }}}
" plugin configuration {{{
" ctrlp configuration {{{
let g:ctrlp_working_path_mode='w'
let g:ctrlp_by_filename=1
" }}}
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
let g:airline#extensions#tabline#fnamemod=":t" " only display filenames in tabs
let g:airline_powerline_fonts=1 " use the fonts that give you the cool arrows in the status line
set encoding=utf8 " make sure we're using the correct encoding for the symbols
if has('gui_running')
    set guifont=Ubuntu_Mono_derivative_Powerlin:h11
endif
let g:airline_theme='dark' " set the airline theme to dark
noremap <c-l> :AirlineRefresh<cr><c-l>| " Refresh vim-airline when Ctrl+L is pressed in addition to the display
" }}}
" YouCompleteMe configuration {{{
let g:ycm_goto_buffer_command='new-or-existing-tab' " GoTo opens in new tab, unless what's being gone to is in an existing tab
let g:ycm_autoclose_preview_window_after_completion=1 " close the preview window when a completion is selected
nnoremap <leader>yg :YcmCompleter GoTo<CR>| " perform a GoTo operation
" }}}
" vim-fugitive configuration {{{
nnoremap <leader>gd :Gvdiff<CR>| " display a diff view of the current file
" }}}
" vim-go configuration {{{
let g:go_fmt_experimental=1 " use an experimental function which won't close folds every time gofmt is run
let g:go_fmt_command='goimports' " use goimports rather than gofmt for formatting on save
" }}}
" vimtex configuration {{{
let g:vimtex_view_general_viewer='SumatraPDF' " set the PDF viewer
" set the viewer's options
let g:vimtex_view_general_options
    \ = '-reuse-instance -forward-search @tex @line @pdf'
    \ . ' -inverse-search "gvim --servername ' . v:servername
    \ . ' --remote-send \"^<C-\^>^<C-n^>'
    \ . ':drop \%f^<CR^>:\%l^<CR^>:normal\! zzzv^<CR^>'
    \ . ':execute ''drop '' . fnameescape(''\%f'')^<CR^>'
    \ . ':\%l^<CR^>:normal\! zzzv^<CR^>'
    \ . ':call remote_foreground('''.v:servername.''')^<CR^>^<CR^>\""'
let g:vimtex_view_general_options_latexmk='-reuse-instance' " set latexmk's options
let g:vimtex_fold_enabled=1
" }}}
" rust.vim configuration {{{
let g:rustfmt_autosave=1 " run rustfmt on save
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
set gdefault " always do global substitutions
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
set wildmode=longest,full " in command line, first <tab> press complete to longest common string, next show full match
set wildmenu " visually cycle through command line completions
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
