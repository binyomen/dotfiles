local M = {}

local function merge_default_opts(opts)
    return vim.tbl_extend('force', {silent = true, noremap = true}, opts or {})
end

function M.map(mode, lhs, rhs, opts)
    local opts = merge_default_opts(opts)
    vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
end

function M.buf_map(buf, mode, lhs, rhs, opts)
    local opts = merge_default_opts(opts)
    vim.api.nvim_buf_set_keymap(buf, mode, lhs, rhs, opts)
end

function M.file_exists(path)
    local s = vim.loop.fs_stat(path)
    return s ~= nil and s.type == 'file'
end

function M.directory_exists(path)
    local s = vim.loop.fs_stat(path)
    return s ~= nil and s.type == 'directory'
end

function M.buf_delete(buf)
    -- Marking the buffer as unlisted and unloading it has the same effect as
    -- the :bdelete command.
    vim.api.nvim_buf_set_option(buf, 'buflisted', false)
    vim.api.nvim_buf_delete(buf, {unload = true})
end

return M
