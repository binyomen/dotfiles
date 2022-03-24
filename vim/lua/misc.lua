local M = {}

local util = require 'util'

local namespace = vim.api.nvim_create_namespace('misc')

-- Fix the closest previous spelling mistake.
function M.fix_previous_spelling_mistake(motion)
    if motion == nil then
        vim.opt.opfunc = '__misc__fix_previous_spelling_mistake_opfunc'
        return 'g@l'
    end

    local extmark = util.get_extmark_from_cursor(namespace)

    -- Go back to the previous spelling mistake and choose the first suggestion.
    vim.cmd 'silent normal! [s1z='

    -- Return to our previous position.
    util.set_cursor_from_extmark(extmark, namespace)
    vim.api.nvim_buf_del_extmark(0 --[[buffer]], namespace, extmark)
end

function M.mark_previous_spelling_mistake_good(motion)
    if motion == nil then
        vim.opt.opfunc = '__misc__mark_previous_spelling_mistake_good_opfunc'
        return 'g@l'
    end

    local extmark = util.get_extmark_from_cursor(namespace)

    -- Go back to the previous spelling mistake and mark it as good.
    vim.cmd 'silent normal! [szg'

    -- Return to our previous position.
    util.set_cursor_from_extmark(extmark, namespace)
    vim.api.nvim_buf_del_extmark(0 --[[buffer]], namespace, extmark)
end

vim.cmd [[
    function! __misc__fix_previous_spelling_mistake_opfunc(motion) abort
        return v:lua.require('misc').fix_previous_spelling_mistake(a:motion)
    endfunction
    function! __misc__mark_previous_spelling_mistake_good_opfunc(motion) abort
        return v:lua.require('misc').mark_previous_spelling_mistake_good(a:motion)
    endfunction
]]

util.map('n', '<leader>z=', [[v:lua.require('misc').fix_previous_spelling_mistake()]], {expr = true})
util.map('n', '<leader>zg', [[v:lua.require('misc').mark_previous_spelling_mistake_good()]], {expr = true})

-- Highlight word under cursor.
local cursor_highlight_match_id = nil
function M.highlight_word_under_cursor()
    if cursor_highlight_match_id ~= nil then
        vim.fn.matchdelete(cursor_highlight_match_id)
    end

    local word = vim.fn.expand('<cword>')
    local pattern = string.format([[\V\<%s\>]], word)

    cursor_highlight_match_id = vim.fn.matchadd('__CursorOver', pattern)
end

function M.clear_cursor_highlight()
    if cursor_highlight_match_id ~= nil then
        vim.fn.matchdelete(cursor_highlight_match_id)
        cursor_highlight_match_id = nil
    end
end

vim.cmd [[
    augroup highlight_word_under_cursor
        autocmd!
        autocmd CursorMoved * lua require('misc').highlight_word_under_cursor()
        autocmd CursorMovedI * lua require('misc').highlight_word_under_cursor()
        autocmd WinLeave * lua require('misc').clear_cursor_highlight()
    augroup end
]]

return M
