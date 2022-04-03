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

lua require 'vimrc.api_explorer'
lua require 'vimrc.basics'
lua require 'vimrc.clipboard'
lua require 'vimrc.color'
lua require 'vimrc.config'
lua require 'vimrc.buffer'
lua require 'vimrc.filetypes'
lua require 'vimrc.gui'
lua require 'vimrc.misc'
lua require 'vimrc.search'
lua require 'vimrc.statusline'
lua require 'vimrc.style'
lua require 'vimrc.swap'
lua require 'vimrc.terminal'
