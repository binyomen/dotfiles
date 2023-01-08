local util = require 'vimrc.util'

local SCRATCH_BUFFER_NAME = '__SCRATCH__'

-- Open a scratch buffer.
util.map('n', '<leader>bs', function()
    if vim.o.modified then
        util.log_error 'Cannot open a scratch buffer in a modified buffer.'
        return
    end

    local buf = vim.fn.bufnr(SCRATCH_BUFFER_NAME)
    if buf == -1 then
        -- The scratch buffer doesn't exist. Create it.
        buf = vim.api.nvim_create_buf(true --[[listed]], true --[[scratch]])
        if buf == 0 then
            error('Failed to create scratch buffer.')
        end

        vim.api.nvim_buf_set_name(buf, SCRATCH_BUFFER_NAME)
    end

    -- The scratch buffer now exists. Switch to it.
    vim.api.nvim_set_current_buf(buf)
end)

util.map('n', '<leader>bt', [['<cmd>' . v:count . 'b<cr>']], {expr = true, replace_keycodes = false})
util.map('n', '<leader>bn', [['<cmd>' . v:count1 . 'bn<cr>']], {expr = true, replace_keycodes = false})
util.map('n', '<leader>bp', [['<cmd>' . v:count1 . 'bp<cr>']], {expr = true, replace_keycodes = false})
util.map('n', '<leader>bf', [[<cmd>bf<cr>]])
util.map('n', '<leader>bl', [[<cmd>bl<cr>]])

-- Delete a buffer.
util.map('n', '<leader>bd', function()
    local buf = vim.v.count
    util.buf_delete(buf)
end)

util.map('n', 'x', ':buffer ', {silent = false})

util.map('n', '<c-m>', function()
    vim.b.vimrc__buffer_marked = not vim.b.vimrc__buffer_marked
end)
