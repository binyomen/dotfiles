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

function M.color_from_group(group)
    local synId = vim.fn.synIDtrans(vim.fn.hlID(group))

    return {
        fg = vim.fn.synIDattr(synId, 'fg'),
        bg = vim.fn.synIDattr(synId, 'bg'),
    }
end

function M.color_from_group_specifier(color_string)
    local tokens = M.split(color_string, '.')
    local group = tokens[1]
    local specifier = tokens[2]

    return M.color_from_group(group)[specifier]
end

local function parse_color(color_string)
    if color_string:sub(1, 1) == '!' then
        return M.color_from_group_specifier(color_string:sub(2))
    else
        return color_string
    end
end

function M.create_highlight_group(name, options)
    local fg = options.fg and string.format('guifg=%s', parse_color(options.fg)) or ''
    local bg = options.bg and string.format('guibg=%s', parse_color(options.bg)) or ''
    local gui = options.gui and string.format('gui=%s', parse_color(options.gui)) or ''

    vim.cmd(string.format('highlight %s %s %s %s', name, fg, bg, gui))
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
