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
vim.cmd [[
    augroup highlight_word_under_cursor
        autocmd!
        autocmd CursorMoved * exe printf('match __CursorOver /\V\<%s\>/', escape(expand('<cword>'), '/\'))
    augroup END
]]

return M
