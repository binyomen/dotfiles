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

function M.split(str, sep)
    local tokens = {}
    local currentToken = ''
    for i = 1,str:len() do
        local c = str:sub(i, i)
        if c == sep then
            table.insert(tokens, currentToken)
            currentToken = ''
        else
            currentToken = currentToken .. c
        end
    end

    table.insert(tokens, currentToken)

    return tokens
end

return M
