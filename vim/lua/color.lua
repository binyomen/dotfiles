local M = {}

local util = require 'util'

local STATUSLINE_HIGHLIGHTS = {
    NeoSolarized = {
        base = '!StatusLine.bg',
        normal_accent = '!Function.fg',
        insert_accent = '!Constant.fg',
        visual_accent = '!Search.fg',
        replace_accent = '!IncSearch.fg',
    },
    gruvbox = {
        base = '!StatusLine.fg',
        normal_accent = '!GruvboxBlue.fg',
        insert_accent = '!GruvboxAqua.fg',
        visual_accent = '!GruvboxYellow.fg',
        replace_accent = '!GruvboxOrange.fg',
    },
    molokai = {
        base = '!StatusLine.fg',
        normal_accent = '!Type.fg',
        insert_accent = '!Function.fg',
        visual_accent = '!String.fg',
        replace_accent = '!Operator.fg',
    },
    onedark = {
        base = '!StatusLine.bg',
        normal_accent = '!Function.fg',
        insert_accent = '!String.fg',
        visual_accent = '!Type.fg',
        replace_accent = '!Identifier.fg',
    },
    PaperColor = {
        base = '!StatusLine.bg',
        normal_accent = '!Operator.fg',
        insert_accent = '!Include.fg',
        visual_accent = '!String.fg',
        replace_accent = '!Constant.fg',
    },
    nord = {
        base = '!StatusLine.bg',
        normal_accent = '!Function.fg',
        insert_accent = '!String.fg',
        visual_accent = '!SpecialChar.fg',
        replace_accent = '!Number.fg',
    },
    iceberg = {
        base = '!TabLine.fg',
        normal_accent = '!Function.fg',
        insert_accent = '!Special.fg',
        visual_accent = '!Title.fg',
        replace_accent = '!Constant.fg',
    },
    one = {
        base = '!StatusLine.bg',
        normal_accent = '!Function.fg',
        insert_accent = '!String.fg',
        visual_accent = '!Number.fg',
        replace_accent = '!Identifier.fg',
    },
    OceanicNext = {
        base = '!StatusLine.fg',
        normal_accent = '!Function.fg',
        insert_accent = '!String.fg',
        visual_accent = '!Label.fg',
        replace_accent = '!Statement.fg',
    },
    palenight = {
        base = '!StatusLine.bg',
        normal_accent = '!Function.fg',
        insert_accent = '!String.fg',
        visual_accent = '!Type.fg',
        replace_accent = '!Identifier.fg',
    },
    onehalfdark = {
        base = '!StatusLine.bg',
        normal_accent = '!Function.fg',
        insert_accent = '!String.fg',
        visual_accent = '!Type.fg',
        replace_accent = '!Identifier.fg',
    },
}

local function create_statusline_highlight(mode, base, accent)
    local primary_group = string.format('__StatuslinePrimary%s', mode)
    M.create_highlight_group(primary_group, {fg = base, bg = accent, gui = 'bold'})

    local secondary_group = string.format('__StatuslineSecondary%s', mode)
    M.create_highlight_group(secondary_group, {fg = accent, bg = base, gui = 'bold'})
end

local function create_statusline_highlights(highlights)
    create_statusline_highlight('Normal', highlights.base, highlights.normal_accent)
    create_statusline_highlight('Insert', highlights.base, highlights.insert_accent)
    create_statusline_highlight('Visual', highlights.base, highlights.visual_accent)
    create_statusline_highlight('Replace', highlights.base, highlights.replace_accent)
end

-- Define highlight groups based off of the current color scheme.
function M.set_highlight_groups()
    local colorscheme = vim.g.colors_name
    for name, highlights in pairs(STATUSLINE_HIGHLIGHTS) do
        if name == colorscheme then
            create_statusline_highlights(highlights)
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
    local tokens = vim.split(color_string, '.', {plain = true})
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
