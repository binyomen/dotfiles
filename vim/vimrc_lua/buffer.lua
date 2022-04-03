local M = {}

local util = require 'vimrc.util'

local SCRATCH_BUFFER_NAME = '__SCRATCH__'

function M.open_scratch_buffer()
    if vim.opt.modified:get() then
        vim.api.nvim_err_writeln('Cannot open a scratch buffer in a modified buffer.')
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
end

util.map('n', '<leader>bs', [[<cmd>lua require('vimrc.buffer').open_scratch_buffer()<cr>]])

function M.delete_buffer()
    local buf = vim.v.count
    util.buf_delete(buf)
end

util.map('n', '<leader>bt', [['<cmd>' . v:count . 'b<cr>']], {expr = true})
util.map('n', '<leader>bn', [['<cmd>' . v:count1 . 'bn<cr>']], {expr = true})
util.map('n', '<leader>bp', [['<cmd>' . v:count1 . 'bp<cr>']], {expr = true})
util.map('n', '<leader>bf', [[<cmd>bf<cr>]])
util.map('n', '<leader>bl', [[<cmd>bl<cr>]])

util.map('n', '<leader>bd', [[<cmd>lua require('vimrc.buffer').delete_buffer()<cr>]])

function M.delete_no_name_buffer()
    local buf = vim.fn.expand('<abuf>')

    vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) then
            util.buf_delete(buf)
        end
    end)
end

return M
