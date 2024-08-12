local M = {}

local util = require 'vimrc.util'

local HIGHLIGHTS = {
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
    ['tokyonight-night'] = {
        base = '!TabLineFill.bg',
        normal_accent = '!Function.fg',
        insert_accent = '!String.fg',
        visual_accent = '!Identifier.fg',
        replace_accent = '!@variable.builtin.fg',
        cursor_over = {bg = '!StatusLineNC.fg', bold = true}
    },
}

local function color_from_group(group)
    return vim.api.nvim_get_hl(0 --[[ns_id]], {name = group, link = false})
end

local function color_from_group_specifier(color_string)
    local tokens = vim.split(color_string, '.', {plain = true})
    local group = vim.fn.join({unpack(tokens, 1, #tokens - 1)}, '.')
    local specifier = tokens[#tokens]

    return color_from_group(group)[specifier]
end

local function parse_color(color_string)
    if color_string:sub(1, 1) == '!' then
        return color_from_group_specifier(color_string:sub(2))
    else
        return color_string
    end
end

local function expand_color_options(options)
    options.fg = options.fg and parse_color(options.fg)
    options.bg = options.bg and parse_color(options.bg)
    options.sp = options.sp and parse_color(options.sp)
end

local function create_highlight_group(name, options)
    local options = vim.deepcopy(options)
    expand_color_options(options)

    -- If we have no settings to apply, don't create the highlight group.
    if vim.tbl_isempty(vim.tbl_keys(options)) then
        return
    end

    vim.api.nvim_set_hl(0 --[[ns_id]], name, options)
end

local function create_statusline_highlight(mode, base, accent)
    local primary_group = string.format('vimrc__StatuslinePrimary%s', mode)
    create_highlight_group(primary_group, {fg = base, bg = accent, bold = true})

    local secondary_group = string.format('vimrc__StatuslineSecondary%s', mode)
    create_highlight_group(secondary_group, {fg = accent, bg = base})

    local winbar_active_group = string.format('vimrc__WinbarActive%s', mode)
    create_highlight_group(winbar_active_group, {fg = accent, bg = base, bold = true})

    local winbar_inactive_group = string.format('vimrc__WinbarInactive%s', mode)
    create_highlight_group(winbar_inactive_group, {fg = accent, bg = base})
end

local function create_statusline_highlights(highlights)
    create_statusline_highlight('Normal', highlights.base, highlights.normal_accent)
    create_statusline_highlight('Insert', highlights.base, highlights.insert_accent)
    create_statusline_highlight('Visual', highlights.base, highlights.visual_accent)
    create_statusline_highlight('Replace', highlights.base, highlights.replace_accent)
end

local function create_cursor_over_highlight(highlights)
    local color
    if highlights.cursor_over then
        if type(highlights.cursor_over) == 'string' then
            color = color_from_group(highlights.cursor_over)
        else
            color = highlights.cursor_over
        end
    else
        color = {bg = '!TabLine.bg', bold = true}
    end

    create_highlight_group('vimrc__CursorOver', color)
end

local function create_statusline_warning_highlight(highlights)
    local color
    if highlights.statusline_warning then
        if type(highlights.statusline_warning) == 'string' then
            color = color_from_group(highlights.statusline_warning)
        else
            color = highlights.statusline_warning
        end
    else
        color = {fg = '!WarningMsg.fg', bg = highlights.base, bold = true}
    end

    create_highlight_group('vimrc__StatuslineWarning', color)
end

-- Define highlight groups based off of the current color scheme.
local function set_highlight_groups()
    local colorscheme = vim.g.colors_name
    for name, highlights in pairs(HIGHLIGHTS) do
        if name == colorscheme then
            create_statusline_highlights(highlights)
            create_cursor_over_highlight(highlights)
            create_statusline_warning_highlight(highlights)
            return
        end
    end

    error(string.format('Color scheme not found: %s', colorscheme))
end

util.augroup('vimrc__statusline_highlight_groups', {
    {'ColorScheme', {callback = set_highlight_groups}},
})

util.user_command('HiTest', 'source $VIMRUNTIME/syntax/hitest.vim', {nargs = 0})
util.user_command(
    'SynStack',
    function()
        if util.treesitter_active() then
            local node = require('nvim-treesitter.ts_utils').get_node_at_cursor()
            local nodes = {}
            while node ~= nil do
                table.insert(nodes, node)
                node = node:parent()
            end

            local max_type_len = 0
            for _, node in ipairs(nodes) do
                local node_type_len = #node:type()
                if node_type_len > max_type_len then
                    max_type_len = node_type_len
                end
            end

            local descriptions = util.tbl_map(nodes, function(node)
                local node_type = node:type()
                local spacing = (' '):rep(max_type_len + 1 - node_type:len())
                local node_text = vim.treesitter.get_node_text(node, 0 --[[source]])

                local node_lines = vim.split(node_text, '\n')
                local node_content
                if #node_lines == 1 then
                    node_content = vim.trim(node_lines[1])
                else
                    node_content = string.format(
                        '%s … %s',
                        vim.trim(node_lines[1]),
                        vim.trim(node_lines[#node_lines])
                    )
                end

                return string.format(
                    '%s%s│ %s',
                    node:type(),
                    spacing,
                    node_content
                )
            end)

            util.echo(table.concat(descriptions, '\n'), true --[[add_to_history]])
        else
            local stack = vim.fn.synstack(vim.fn.line '.', vim.fn.col '.')
            local mapped = util.tbl_map(stack, function(item)
                local from_name = vim.fn.synIDattr(item, 'name')
                local to_name = vim.fn.synIDattr(vim.fn.synIDtrans(item), 'name')
                return string.format('%s -> %s', from_name, to_name)
            end)
            util.echo(vim.inspect(mapped), true --[[add_to_history]])
        end
    end,
    {nargs = 0}
)

return M
