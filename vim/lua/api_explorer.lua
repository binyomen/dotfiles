local M = {}

local current_obj = _G

local function draw(buf)
    -- Temporarily allow us to modify the buffer.
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)

    local lines = {}
    for key, value in pairs(current_obj) do
        table.insert(lines, key)
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, true --[[strict_indexing]], lines)

    -- Make the buffer non-modifiable again.
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
end

function M.open()
    vim.cmd 'vnew'
    local win = vim.api.nvim_get_current_win()

    local buf = vim.api.nvim_create_buf(false --[[listed]], true --[[scratch]])
    vim.api.nvim_win_set_buf(win, buf)

    vim.api.nvim_buf_set_name(buf, string.format('Api Explorer [%d]', buf))

    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'api_explorer')

    vim.api.nvim_win_set_option(win, 'spell', false)
    vim.api.nvim_win_set_option(win, 'wrap', false)

    draw(buf)

    vim.cmd(string.format('buffer %d', buf))
end

vim.cmd 'command! -nargs=0 ApiExplorer lua require("api_explorer").open()'

return M
