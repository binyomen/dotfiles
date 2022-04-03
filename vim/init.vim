" vim:fdm=marker

let mapleader = ','
let maplocalleader = '\\'

lua require('vimrc.local_config').load_configs()

lua require 'vimrc.plugins'

" remaps {{{
" easy switching between cpp and header files {{{
function! s:toggle_c() abort
    if expand('%:e') == 'h'
        edit %<.cpp
    elseif expand('%:e') == 'cpp'
        edit %<.h
    endif
endfunction
nnoremap <silent> <leader>ch :call <sid>toggle_c()<cr>
" }}}
" search help for word under cursor {{{
nnoremap <leader>? :execute 'help ' . expand("<cword>")<cr>
" }}}
" open GitHub short URLs for plugins {{{
nnoremap <leader>gh <cmd>call netrw#BrowseX('https://github.com/' . expand('<cfile>'), 0)<cr>
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

command! -nargs=0 SynStack echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name") . " -> " . synIDattr(synIDtrans(v:val), "name")')
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

lua require 'vimrc.api_explorer'
lua require 'vimrc.basics'
lua require 'vimrc.clipboard'
lua require 'vimrc.color'
lua require 'vimrc.config'
lua require 'vimrc.buffer'
lua require 'vimrc.filetypes'
lua require 'vimrc.misc'
lua require 'vimrc.search'
lua require 'vimrc.statusline'
lua require 'vimrc.style'
lua require 'vimrc.swap'
lua require 'vimrc.terminal'
