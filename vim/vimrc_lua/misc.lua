local M = {}

local util = require 'vimrc.util'

local namespace = vim.api.nvim_create_namespace('misc')

-- Fix the closest previous spelling mistake.
M.fix_previous_spelling_mistake = util.new_operator_with_inherent_motion('l', function()
    local extmark = util.get_extmark_from_cursor(namespace)

    -- Go back to the previous spelling mistake and choose the first suggestion.
    vim.cmd 'silent normal! [s1z='

    -- Return to our previous position.
    util.set_cursor_from_extmark(extmark, namespace)
    vim.api.nvim_buf_del_extmark(0 --[[buffer]], namespace, extmark)
end)

M.mark_previous_spelling_mistake_good = util.new_operator_with_inherent_motion('l', function()
    local extmark = util.get_extmark_from_cursor(namespace)

    -- Go back to the previous spelling mistake and mark it as good.
    vim.cmd 'silent normal! [szg'

    -- Return to our previous position.
    util.set_cursor_from_extmark(extmark, namespace)
    vim.api.nvim_buf_del_extmark(0 --[[buffer]], namespace, extmark)
end)

util.map('n', '<leader>z=', [[v:lua.require('vimrc.misc').fix_previous_spelling_mistake()]], {expr = true})
util.map('n', '<leader>zg', [[v:lua.require('vimrc.misc').mark_previous_spelling_mistake_good()]], {expr = true})

util.map('n', '<leader>zt', [[<cmd>setlocal spell!<cr>]])

-- Highlight word under cursor.
function M.highlight_word_under_cursor()
    M.clear_cursor_highlight()

    local word = vim.fn.escape(vim.fn.expand('<cword>'), [[\/]])
    local pattern = string.format([[\V\<%s\>]], word)

    vim.w.vimrc__cursor_highlight_match_id = vim.fn.matchadd('vimrc__CursorOver', pattern)
end

function M.clear_cursor_highlight()
    if vim.w.vimrc__cursor_highlight_match_id ~= nil then
        vim.fn.matchdelete(vim.w.vimrc__cursor_highlight_match_id)
        vim.w.vimrc__cursor_highlight_match_id = nil
    end
end

vim.cmd [[
    augroup vimrc__highlight_word_under_cursor
        autocmd!
        autocmd CursorMoved * lua require('vimrc.misc').highlight_word_under_cursor()
        autocmd CursorMovedI * lua require('vimrc.misc').highlight_word_under_cursor()
        autocmd WinLeave * lua require('vimrc.misc').clear_cursor_highlight()
    augroup end
]]

-- Center mode.
local in_center_mode
function M.enable_center_mode()
    vim.cmd [[
        augroup vimrc__center_mode
            autocmd!
            autocmd CursorMoved * normal! zz
        augroup end
    ]]
    vim.cmd [[normal! zz]]

    in_center_mode = true
end

function M.disable_center_mode()
    -- Do this check since the below autocmd will fail if the group doesn't exist.
    if in_center_mode then
        vim.cmd [[autocmd! center_mode]]
    end

    in_center_mode = false
end

-- This is the default setting.
M.disable_center_mode()

M.toggle_center_mode = util.new_operator_with_inherent_motion('l', function()
    if in_center_mode then
        M.disable_center_mode()
    else
        M.enable_center_mode()
    end
end)

util.map('n', 'cm', [[v:lua.require('vimrc.misc').toggle_center_mode()]], {expr = true})

-- Easy switching between cpp and header files.
function M.toggle_c()
    if vim.fn.expand('%:e') == 'h' then
        vim.cmd [[edit %<.cpp]]
    elseif vim.fn.expand('%:e') == 'cpp' then
        vim.cmd [[edit %<.h]]
    end
end
util.map('n', '<leader>ch', [[<cmd>lua require('vimrc.misc').toggle_c()<cr>]])

-- Search help for the word under the cursor.
util.map('n', '<leader>?', [[<cmd>execute 'help ' . expand("<cword>")<cr>]])

-- Open GitHub short URLs for plugins.
util.map('n', '<leader>gh', [[<cmd>call netrw#BrowseX('https://github.com/' . expand('<cfile>'), 0)<cr>]])

-- errorformat
vim.opt.errorformat = {[[%[0-9]%\+>%f(%l) : %m]]} -- build.exe errors
-- Ignore anything that doesn't match the previous errors.
vim.opt.errorformat:append([[%-G%.%#]])

-- Fixes the problem detailed at
-- http://vim.wikia.com/wiki/Keep_folds_closed_while_inserting_text. Without
-- this, folds open and close at will as you type code.
vim.cmd [[
    augroup vimrc__fixfolds
        autocmd!
        autocmd InsertEnter * if !exists('w:last_fdm') | let w:last_fdm=&foldmethod | setlocal foldmethod=manual | endif
        autocmd InsertLeave,WinLeave * if exists('w:last_fdm') | let &l:foldmethod=w:last_fdm | unlet w:last_fdm | endif
    augroup end
]]

-- Close preview window after completion has finished.
vim.cmd [[
    augroup vimrc__close_preview_window
        autocmd!
        autocmd CompleteDone * pclose
    augroup end
]]

-- Briefly highlight text on yank.
vim.cmd [[
    augroup vimrc__highlight_on_yank
        autocmd!
        autocmd TextYankPost * lua vim.highlight.on_yank {higroup = 'Search'}
    augroup end
]]

return M
