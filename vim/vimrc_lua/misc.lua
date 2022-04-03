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

    vim.w.vimrc__cursor_highlight_match_id = vim.fn.matchadd('__CursorOver', pattern)
end

function M.clear_cursor_highlight()
    if vim.w.vimrc__cursor_highlight_match_id ~= nil then
        vim.fn.matchdelete(vim.w.vimrc__cursor_highlight_match_id)
        vim.w.vimrc__cursor_highlight_match_id = nil
    end
end

vim.cmd [[
    augroup highlight_word_under_cursor
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
        augroup center_mode
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

return M
