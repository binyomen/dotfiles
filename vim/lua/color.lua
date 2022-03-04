local M = {}

local util = require 'util'

local HIGHLIGHTS = {
    NeoSolarized = {
        __StatuslinePrimaryNormal = {fg = 'white', bg = '!Function.fg'},
        __StatuslineSecondaryNormal = {fg = 'white', bg = '#2072ac'},
        __StatuslinePrimaryInsert = {fg = 'white', bg = '!Constant.fg'},
        __StatuslineSecondaryInsert = {fg = 'white', bg = '#21827a'},
        __StatuslinePrimaryVisual = {fg = 'white', bg = '!Search.fg'},
        __StatuslineSecondaryVisual = {fg = 'white', bg = '#a37a00'},
        __StatuslinePrimaryReplace = {fg = 'white', bg = '!IncSearch.fg'},
        __StatuslineSecondaryReplace = {fg = 'white', bg = '#a53e12'},
    },
}

-- Define highlight groups based off of the current color scheme.
function M.set_highlight_groups()
    local colorscheme = vim.g.colors_name
    for name, highlights in pairs(HIGHLIGHTS) do
        if name == colorscheme then
            for group, options in pairs(highlights) do
                M.create_highlight_group(group, options)
            end

            break
        end
    end
end

function M.color_from_group(group)
    local synId = vim.fn.synIDtrans(vim.fn.hlID(group))

    return {
        fg = vim.fn.synIDattr(synId, 'fg'),
        bg = vim.fn.synIDattr(synId, 'bg'),
    }
end

function M.color_from_group_specifier(color_string)
    local tokens = util.split(color_string, '.')
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
    local fg = options.fg and parse_color(options.fg) or ''
    local bg = options.bg and parse_color(options.bg) or ''
    local gui = options.gui and parse_color(options.gui) or ''

    local fg = fg == '' and fg or string.format('guifg=%s', fg)
    local bg = bg == '' and bg or string.format('guibg=%s', bg)
    local gui = gui == '' and gui or string.format('gui=%s', gui)

    vim.cmd(string.format('highlight %s %s %s %s', name, fg, bg, gui))
end

vim.cmd [[
    augroup statusline_highlight_groups
        autocmd!
        autocmd ColorScheme * lua require('color').set_highlight_groups()
    augroup end
]]

return M
