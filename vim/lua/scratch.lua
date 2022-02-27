local M = {}

local util = require 'util'

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

    -- The scratch buffer now exists. Switch to it. We need to use `edit`
    -- rather than `buffer` because with buffer, the 'buflisted' option won't
    -- be set.
    vim.cmd(string.format('edit #%d', buf))
end

util.map('n', '<leader>bs', ':lua require("scratch").open_scratch_buffer()<cr>')

return M
