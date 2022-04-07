" vim:fdm=marker

lua require 'impatient'

let mapleader = ','
let maplocalleader = '\\'

lua require('vimrc.local_config').load_configs()

lua require 'vimrc.plugins'

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
