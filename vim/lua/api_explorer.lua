local M = {}

local util = require 'util'

local instances = {}

local function create_instance(win, buf)
    local instance = {
        win = win,
        buf = buf,
        current_table = _G,
        lines = {},
    }

    instances[win] = instance
    return instance
end

local function query_instance(win)
    local win = win or vim.api.nvim_get_current_win()
    return instances[win]
end

local function clear_instance(instance)
    instances[instance.win] = nil
end

local function key_to_string(key)
    return tostring(key)
end

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
    local spaces = string.rep(' ', max_key_length - o.key_string:len())
    return string.format('%s%s = %s', o.key_string, spaces, value_to_string(o.value))
end

local function render(instance)
    -- Temporarily allow us to modify the buffer.
    vim.api.nvim_buf_set_option(instance.buf, 'modifiable', true)

    -- Get a list of fields sorted by key.
    local max_key_length = 0
    local sorted_lines = {}
    for key, value in pairs(instance.current_table) do
        local key_string = key_to_string(key)
        max_key_length = math.max(max_key_length, key_string:len())
        table.insert(sorted_lines, {key = key, value = value, key_string = key_string})
    end
    table.sort(sorted_lines, function(a, b) return a.key_string < b.key_string end)

    -- Generate a line for each field.
    local lines = {}
    for _, o in ipairs(sorted_lines) do
        table.insert(lines, create_line(o, max_key_length))
        table.insert(instance.lines, {key = o.key, value = o.value})
    end

    vim.api.nvim_buf_set_lines(instance.buf, 0, -1, true --[[strict_indexing]], lines)

    -- Make the buffer non-modifiable again.
    vim.api.nvim_buf_set_option(instance.buf, 'modifiable', false)
end

local function set_mappings(buf)
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
    local win = vim.api.nvim_get_current_win()

    local buf = vim.api.nvim_create_buf(false --[[listed]], true --[[scratch]])
    vim.api.nvim_win_set_buf(win, buf)

    vim.api.nvim_buf_set_name(buf, string.format('Api Explorer [%d]', buf))

    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'api_explorer')

    vim.api.nvim_win_set_option(win, 'spell', false)
    vim.api.nvim_win_set_option(win, 'wrap', false)

    local instance = create_instance(win, buf)

    render(instance)

    vim.cmd(string.format('buffer %d', buf))

    set_mappings(buf)
end

function M.close(win)
    local instance = query_instance(win)
    if instance == nil then
        return
    end

    clear_instance(instance)

    if instance.win and vim.api.nvim_win_is_valid(instance.win) then
        vim.api.nvim_win_close(instance.win, true --[[force]])
    end
end

function M.nav_to()
    local instance = query_instance()

    local line_number = vim.api.nvim_win_get_cursor(instance.win)[1]

    local key = instance.lines[line_number].key
    instance.current_table = instance.current_table[key]
    render(instance)
end

vim.cmd 'command! -nargs=0 ApiExplorer lua require("api_explorer").open()'

vim.cmd [[
    augroup api_explorer
        autocmd!
        autocmd WinClosed * lua require("api_explorer").close(tonumber(vim.fn.expand("<amatch>")))
    augroup end
]]

return M
