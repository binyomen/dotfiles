local M = {}

local util = require 'util'

local namespace = vim.api.nvim_create_namespace('misc')

-- Fix the closest previous spelling mistake.
function M.fix_previous_spelling_mistake(motion)
    if motion == nil then
        vim.opt.opfunc = '__misc__fix_previous_spelling_mistake_opfunc'
        return 'g@l'
    end

    local pos = vim.api.nvim_win_get_cursor(0 --[[window]])
    local extmark = util.get_extmark_from_pos({pos[1] - 1, pos[2]}, namespace)

    -- Go back to the previous spelling mistake and choose the first suggestion.
    vim.cmd 'silent normal! [s1z='

    -- Return to our previous position.
    local extmark_pos = vim.api.nvim_buf_get_extmark_by_id(
        0 --[[buffer]],
        namespace,
        extmark,
        {}
    )
    vim.api.nvim_win_set_cursor(0 --[[window]], {extmark_pos[1] + 1, extmark_pos[2]})
end

vim.cmd [[
    function! __misc__fix_previous_spelling_mistake_opfunc(motion) abort
        return v:lua.require('misc').fix_previous_spelling_mistake(a:motion)
    endfunction
]]

util.map('n', '<leader>z=', [[v:lua.require('misc').fix_previous_spelling_mistake()]], {expr = true})

return M
