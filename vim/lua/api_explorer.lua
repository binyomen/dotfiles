local M = {}

local util = require 'util'

local win
local buf
local current_obj = _G

local function value_to_string(value)
    local t = type(value)
    if t == 'string' then
        return string.format('%q', value)
    elseif t == 'number' then
        return string.format('%g', value)
    elseif t == 'function' or t == 'table' then
        return string.format('<%s>', value)
    else
        error(string.format('Unsupported type: %s', t))
    end
end

local function create_line(o, max_key_length)
    local spaces = string.rep(' ', max_key_length - o.key:len())
    return string.format('%s%s = %s', o.key, spaces, value_to_string(o.value))
end

local function draw()
    -- Temporarily allow us to modify the buffer.
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)

    -- Get a list of fields sorted by key.
    local max_key_length = 0
    local sorted_lines = {}
    for key, value in pairs(current_obj) do
        max_key_length = math.max(max_key_length, key:len())
        table.insert(sorted_lines, {key = key, value = value})
    end
    table.sort(sorted_lines, function(a, b) return a.key < b.key end)

    -- Generate a line for each field.
    local lines = {}
    for _, o in ipairs(sorted_lines) do
        table.insert(lines, create_line(o, max_key_length))
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, true --[[strict_indexing]], lines)

    -- Make the buffer non-modifiable again.
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
end

local function set_mappings()
    local mappings = {
        q = 'close()',
        ['<cr>'] = 'nav_to()',
    }

    for lhs, rhs in pairs(mappings) do
        util.bufnr_map(
            buf,
            'n',
            lhs,
            ':lua require("api_explorer").' .. rhs .. '<cr>',
            {nowait = true})
    end
end

function M.open()
    vim.cmd 'vnew'
    win = vim.api.nvim_get_current_win()

    buf = vim.api.nvim_create_buf(false --[[listed]], true --[[scratch]])
    vim.api.nvim_win_set_buf(win, buf)

    vim.api.nvim_buf_set_name(buf, string.format('Api Explorer [%d]', buf))

    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'api_explorer')

    vim.api.nvim_win_set_option(win, 'spell', false)
    vim.api.nvim_win_set_option(win, 'wrap', false)

    draw()

    vim.cmd(string.format('buffer %d', buf))

    set_mappings()
end

function M.close()
    if win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true --[[force]])
    end
end

function M.nav_to()
    local line = vim.api.nvim_get_current_line()

    local key = ''
    for i = 1,line:len() do
        local c = line:sub(i, i)
        if c == ' ' then
            break
        else
            key = key .. c
        end
    end

    current_obj = current_obj[key]
    draw()
end

vim.cmd 'command! -nargs=0 ApiExplorer lua require("api_explorer").open()'

return M
