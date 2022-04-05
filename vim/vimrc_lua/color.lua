local M = {}

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
}

local function create_statusline_highlight(mode, base, accent)
    local primary_group = string.format('__StatuslinePrimary%s', mode)
    M.create_highlight_group(primary_group, {fg = base, bg = accent, bold = true})

    local secondary_group = string.format('__StatuslineSecondary%s', mode)
    M.create_highlight_group(secondary_group, {fg = accent, bg = base})
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
            color = M.color_from_group(highlights.cursor_over)
        else
            color = highlights.cursor_over
        end
    else
        color = {bg = '!TabLine.bg', bold = true}
    end

    M.create_highlight_group('__CursorOver', color)
end

-- Define highlight groups based off of the current color scheme.
function M.set_highlight_groups()
    local colorscheme = vim.g.colors_name
    for name, highlights in pairs(HIGHLIGHTS) do
        if name == colorscheme then
            create_statusline_highlights(highlights)
            create_cursor_over_highlight(highlights)
            break
        end
    end
end

function M.color_from_group(group)
    local synId = vim.fn.synIDtrans(vim.fn.hlID(group))

    local function resolve_string_attr(attr)
        if attr == '' then
            return nil
        else
            return attr
        end
    end

    local function resolve_boolean_attr(attr)
        if attr == '1' then
            return true
        else
            return nil
        end
    end

    return {
        fg = resolve_string_attr(vim.fn.synIDattr(synId, 'fg')),
        bg = resolve_string_attr(vim.fn.synIDattr(synId, 'bg')),
        sp = resolve_string_attr(vim.fn.synIDattr(synId, 'sp')),
        font = resolve_string_attr(vim.fn.synIDattr(synId, 'font')),
        bold = resolve_boolean_attr(vim.fn.synIDattr(synId, 'bold')),
        italic = resolve_boolean_attr(vim.fn.synIDattr(synId, 'italic')),
        reverse = resolve_boolean_attr(vim.fn.synIDattr(synId, 'reverse')),
        inverse = resolve_boolean_attr(vim.fn.synIDattr(synId, 'inverse')),
        standout = resolve_boolean_attr(vim.fn.synIDattr(synId, 'standout')),
        underline = resolve_boolean_attr(vim.fn.synIDattr(synId, 'underline')),
        undercurl = resolve_boolean_attr(vim.fn.synIDattr(synId, 'undercurl')),
        strikethrough = resolve_boolean_attr(vim.fn.synIDattr(synId, 'strikethrough')),
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

local function expand_color_options(options)
    options.fg = options.fg and parse_color(options.fg)
    options.bg = options.bg and parse_color(options.bg)
    options.sp = options.sp and parse_color(options.sp)
end

local function produce_gui_list(options)
    local gui_list = {}

    for _, field in ipairs({'bold', 'italic', 'reverse', 'inverse', 'standout', 'underline', 'undercurl', 'strikethrough'}) do
        if options[field] then
            table.insert(gui_list, field)
        end
    end

    if vim.tbl_isempty(gui_list) then
        return ''
    else
        return string.format('gui=%s', table.concat(gui_list, ','))
    end
end

function M.create_highlight_group(name, options)
    expand_color_options(options)

    -- If we have no settings to apply, don't create the highlight group.
    if vim.tbl_isempty(vim.tbl_keys(options)) then
        return
    end

    local fg_string = options.fg and string.format('guifg=%s', options.fg) or ''
    local bg_string = options.bg and string.format('guibg=%s', options.bg) or ''
    local sp_string = options.sp and string.format('guisp=%s', options.sp) or ''
    local gui_string = produce_gui_list(options)

    vim.cmd(string.format(
        'highlight %s %s %s %s %s',
        name,
        fg_string,
        bg_string,
        sp_string,
        gui_string))
end

function M.on_colorscheme_loaded()
    vim.opt.termguicolors = true
    vim.opt.background = 'dark'

    vim.cmd [[colorscheme PaperColor]]
end

vim.cmd [[
    augroup statusline_highlight_groups
        autocmd!
        autocmd ColorScheme * lua require('vimrc.color').set_highlight_groups()
    augroup end
]]

vim.cmd [[command! -nargs=0 Hitest source $VIMRUNTIME/syntax/hitest.vim]]
vim.cmd [[command! -nargs=0 SynStack echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name") . " -> " . synIDattr(synIDtrans(v:val), "name")')]]

return M
