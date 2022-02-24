local M = {}

local function merge_default_opts(opts)
    return vim.tbl_extend('force', {silent = true, noremap = true}, opts or {})
end

function M.map(mode, lhs, rhs, opts)
    local opts = merge_default_opts(opts)
    vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
end

function M.buf_map(mode, lhs, rhs, opts)
    local opts = merge_default_opts(opts)
    vim.api.nvim_buf_set_keymap(0, mode, lhs, rhs, opts)
end

function M.bufnr_map(bufnr, mode, lhs, rhs, opts)
    local opts = merge_default_opts(opts)
    vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
end

return M