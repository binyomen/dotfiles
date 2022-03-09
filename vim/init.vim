" vim:fdm=marker

lua require 'plugins'

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
nnoremap <BS> :w<CR>| " remap backspace to save in normal mode
vnoremap <BS> :w<CR>| " remap backspace to save in visual mode

function! s:omnifunc_map() abort
    if g:in_completion_menu
        return ''
    else
        return ''
    endif
endfunction
inoremap <expr> <c-t> <sid>omnifunc_map()| " Easier omnifunc mapping.
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
" use <leader>t for <c-w> {{{
nnoremap <leader>t <c-w>

nnoremap + <c-w>>
nnoremap - <c-w><
nnoremap <c-=> <c-w>+
nnoremap <c--> <c-w>-
" }}}
" use <leader>r to reload the buffer with :edit {{{
noremap <leader>r :edit<CR>
" }}}
" make gf open the file even if it doesn't exist {{{
noremap gf :e <cfile><cr>
" }}}
" remap ':' to ',' so that you can move backwards for f and t {{{
noremap : ,
" }}}
" <leader>h, <leader>m, and <leader>l for moving the cursor to the top, middle, and bottom of the screen {{{
noremap <leader>h H
noremap <leader>m M
noremap <leader>l L
" }}}
" swap meanings of ` and ' since one is easier to hit than the other {{{
noremap ` '
noremap ' `
" }}}
" remap <c-^> to M, which has more editor support {{{
nnoremap M <c-^>
" }}}
" easy switching between cpp and header files {{{
function! s:toggle_c() abort
    if expand('%:e') == 'h'
        edit %<.cpp
    elseif expand('%:e') == 'cpp'
        edit %<.h
    endif
endfunction
nnoremap <leader>ch :call <sid>toggle_c()<cr>
" }}}
" search help for word under cursor {{{
nnoremap <leader>? :execute 'help ' . expand("<cword>")<cr>
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
" highlight word under cursor {{{
augroup highlight_word_under_cursor
    autocmd!
    autocmd CursorMoved * exe printf('match IncSearch /\V\<%s\>/', escape(expand('<cword>'), '/\'))
augroup END
" }}}
" turn on spelling by default for certain file types {{{
augroup spell_file_types
    autocmd!
    autocmd FileType gitcommit,html,markdown,text setlocal spell
augroup END
" }}}
" Briefly highlight text on yank. {{{
augroup highlight_on_yank
    autocmd!
    autocmd TextYankPost * lua vim.highlight.on_yank {higroup = 'Search'}
augroup end
" }}}
" Close preview window after completion has finished. {{{
let g:in_completion_menu = 0
augroup close_preview_window
    autocmd!
    autocmd CompleteChanged * let g:in_completion_menu = 1
    autocmd CompleteDone * pclose | let g:in_completion_menu = 0
augroup end
" }}}
" }}}
" easy editing of configuration files {{{
nnoremap <silent> <leader>ve :edit $MYVIMRC<cr>| " open .vimrc in new tab
nnoremap <silent> <leader>vs :source $MYVIMRC<cr>| " resource .vimrc
nnoremap <silent> <leader>vl :execute 'silent edit ' . stdpath('config') . '/lua/'<cr>| " open lua scripts directory
nnoremap <silent> <leader>vp :execute 'silent edit ' . stdpath('data') . '/site/pack/packer/'<cr>| " open plugin directory
" }}}

lua require 'search'

" tabs {{{
set expandtab " tabs are expanded to spaces
set tabstop=4 " tabs count as 4 spaces
set softtabstop=4 " tabs count as 4 spaces while performing editing operations (yeah, I don't really understand this either)
set shiftwidth=4 " number of spaces used for autoindent
set shiftround " should round indents to multiple of shiftwidth
set autoindent " automatically indent lines
set smarttab " be smart about how you use shiftwidth vs tabstop or softtabstop I think
" }}}
" show whitespace {{{
set list " display whitespace characters
set listchars=tab:>.,trail:.,extends:#,nbsp:. " specify which whitespace characters to display ('trail' is for trailing spaces, and 'extends' is for when the line extends beyond the right end of the screen)
" }}}
" misc. settings {{{
set number " show line numbers
set relativenumber " show relative line numbers
set nowrap " don't wrap lines
set showmatch " show matching bracket when one is inserted
set wildignore+=.git " ignore the .git directory when expanding wildcards
set title " title of window set to titlename/currently edited file
set visualbell " use visual bell instead of beeping
set foldmethod=syntax " fold based on the language syntax (e.g. #region tags)
set colorcolumn=80,120 " highlight the 80th and 120th columns for better line-length management
set wildmode=longest,full " in command line, first <tab> press complete to longest common string, next show full match
set cursorline " highlight the current line
set cursorcolumn " highlight the current column
set nojoinspaces " don't add an extra space after a period for J and gq
set fileformats=unix,dos " Set Unix line endings as the default.

" Open new splits on the right and bottom, not left and top.
set splitright
set splitbelow
" }}}
" errorformat {{{
set errorformat=%[0-9]%\\+>%f(%l)\ :\ %m " build.exe errors

" Ignore anything that doesn't match the previous errors.
set errorformat+=%-G%.%#
" }}}
" custom functions and commands {{{
" format json
function! FormatJson()
    %!python -m json.tool
endfunc

command! -nargs=0 Hitest source $VIMRUNTIME/syntax/hitest.vim

command! -nargs=0 SynName echo synIDattr(synID(line("."), col("."), 1), 'name')
" }}}
" editor configuration {{{
" fvim {{{
if exists('g:fvim_loaded')
    " Toggle between normal and fullscreen
    nnoremap <A-CR> :<C-u>FVimToggleFullScreen<CR>

    " Cursor tweaks
    FVimCursorSmoothMove v:true
    FVimCursorSmoothBlink v:false

    " Background composition
    " FVimBackgroundComposition 'acrylic'   " 'none', 'blur' or 'acrylic'
    " FVimBackgroundOpacity 0.85            " value between 0 and 1, default bg opacity.
    " FVimBackgroundAltOpacity 0.85         " value between 0 and 1, non-default bg opacity.
    " FVimBackgroundImage 'C:/foobar.png'   " background image
    " FVimBackgroundImageVAlign 'center'    " vertial position, 'top', 'center' or 'bottom'
    " FVimBackgroundImageHAlign 'center'    " horizontal position, 'left', 'center' or 'right'
    " FVimBackgroundImageStretch 'fill'     " 'none', 'fill', 'uniform', 'uniformfill'
    " FVimBackgroundImageOpacity 0.85       " value between 0 and 1, bg image opacity

    " Title bar tweaks
    " FVimCustomTitleBar v:false             " themed with colorscheme

    " Debug UI overlay
    FVimDrawFPS v:false

    " Font tweaks
    FVimFontAntialias v:true
    FVimFontAutohint v:true
    FVimFontHintLevel 'full'
    FVimFontLigature v:true
    " FVimFontLineHeight '+1.0' " can be 'default', '14.0', '-1.0' etc.
    FVimFontSubpixel v:true
    " FVimFontNoBuiltInSymbols v:true " Disable built-in Nerd font symbols

    " Try to snap the fonts to the pixels, reduces blur
    " in some situations (e.g. 100% DPI).
    FVimFontAutoSnap v:true

    " Font weight tuning, possible valuaes are 100..900
    " FVimFontNormalWeight 400
    " FVimFontBoldWeight 700

    " Font debugging -- draw bounds around each glyph
    FVimFontDrawBounds v:false

    " UI options
    " FVimUIMultiGrid v:false     " per-window grid system -- work in progress
    " FVimUIPopupMenu v:false      " external popup menu
    " FVimUITabLine v:false       " external tabline -- not implemented
    " FVimUICmdLine v:false       " external cmdline -- not implemented
    " FVimUIWildMenu v:false      " external wildmenu -- not implemented
    " FVimUIMessages v:false      " external messages -- not implemented
    " FVimUITermColors v:false    " not implemented
    " FVimUIHlState v:false       " not implemented

    " Detach from a remote session without killing the server
    " If this command is executed on a standalone instance,
    " the embedded process will be terminated anyway.
    " FVimDetach
endif
" }}}
" firenvim {{{
if exists('g:started_by_firenvim')
    set nonumber " disable line numbers
    set norelativenumber " also necessary to disable line numbers
    set wrap " enable line wrapping
    set guifont=Ubuntu_Mono_derivative_Powerlin:h12

    let g:firenvim_config = {} " initialize a default config
    let g:firenvim_config['localSettings'] = {}
    let g:firenvim_config['localSettings']['.*'] = { 'takeover': 'never' } " never take over the text area automatically
endif
" }}}
" }}}

lua require 'api_explorer'
lua require 'case'
lua require 'clipboard'
lua require 'color'
lua require 'buffer'
lua require 'filetypes'
lua require 'statusline'
lua require 'style'
