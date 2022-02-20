-- Make this a global module so that we can call back into it from vim script.
scratch = {}
local M = scratch

local util = require 'util'

local SCRATCH_BUFFER_NAME = '__SCRATCH__'

function M.open_scratch_buffer()
    if vim.opt.modified:get() then
        vim.api.nvim_err_writeln('Cannot open a scratch buffer in a modified buffer.')
        return
    end

    local bufnr = vim.fn.bufnr(SCRATCH_BUFFER_NAME)
    if bufnr == -1 then
        -- The scratch buffer doesn't exist. Create it.
        vim.cmd('edit ' .. SCRATCH_BUFFER_NAME)
    else
        -- The scratch buffer already exists. Switch to it.
        vim.cmd('buffer ' .. bufnr)
    end
end

function M.setup_scratch_buffer()
    vim.opt_local.buftype = 'nofile'
    vim.opt_local.bufhidden = 'hide'
    vim.opt_local.swapfile = false
    vim.opt_local.buflisted = true
end

vim.cmd [[
    augroup scratch_buffer
        autocmd!
        autocmd BufNewFile __SCRATCH__ lua scratch.setup_scratch_buffer()
    augroup end
]]

util.map('n', '<leader>sb', ':lua scratch.open_scratch_buffer()<cr>')

return M
