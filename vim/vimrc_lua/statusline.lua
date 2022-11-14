local M = {}

local util = require 'vimrc.util'

local function redraw_tabline()
    -- For some reason :redrawtabline doesn't work....
    vim.bo.readonly = vim.bo.readonly
end

local NORMAL_COLORS = {
    primary = '%#vimrc__StatuslinePrimaryNormal#',
    secondary = '%#vimrc__StatuslineSecondaryNormal#',
    winbar_active = '%#vimrc__WinbarActiveNormal#';
    winbar_inactive = '%#vimrc__WinbarInactiveNormal#';
}

local VISUAL_COLORS = {
    primary = '%#vimrc__StatuslinePrimaryVisual#',
    secondary = '%#vimrc__StatuslineSecondaryVisual#',
    winbar_active = '%#vimrc__WinbarActiveVisual#';
    winbar_inactive = '%#vimrc__WinbarInactiveVisual#';
}

local INSERT_COLORS = {
    primary = '%#vimrc__StatuslinePrimaryInsert#',
    secondary = '%#vimrc__StatuslineSecondaryInsert#',
    winbar_active = '%#vimrc__WinbarActiveInsert#';
    winbar_inactive = '%#vimrc__WinbarInactiveInsert#';
}

local REPLACE_COLORS = {
    primary = '%#vimrc__StatuslinePrimaryReplace#',
    secondary = '%#vimrc__StatuslineSecondaryReplace#',
    winbar_active = '%#vimrc__WinbarActiveReplace#';
    winbar_inactive = '%#vimrc__WinbarInactiveReplace#';
}

local MODE_COLORS = {
    n = NORMAL_COLORS,
    no = NORMAL_COLORS,
    nov = NORMAL_COLORS,
    noV = NORMAL_COLORS,
    [t'no<c-v>'] = NORMAL_COLORS,
    niI = NORMAL_COLORS,
    niR = NORMAL_COLORS,
    niV = NORMAL_COLORS,
    nt = NORMAL_COLORS,
    v = VISUAL_COLORS,
    vs = VISUAL_COLORS,
    V = VISUAL_COLORS,
    Vs = VISUAL_COLORS,
    [t'<c-v>'] = VISUAL_COLORS,
    [t'<c-v>s'] = VISUAL_COLORS,
    s = VISUAL_COLORS,
    S = VISUAL_COLORS,
    [''] = VISUAL_COLORS,
    i = INSERT_COLORS,
    ic = INSERT_COLORS,
    ix = INSERT_COLORS,
    R = REPLACE_COLORS,
    Rc = REPLACE_COLORS,
    Rx = REPLACE_COLORS,
    Rv = REPLACE_COLORS,
    Rvc = REPLACE_COLORS,
    Rvx = REPLACE_COLORS,
    c = INSERT_COLORS,
    cv = INSERT_COLORS,
    r = INSERT_COLORS,
    rm = INSERT_COLORS,
    ['r?'] = INSERT_COLORS,
    ['!'] = INSERT_COLORS,
    t = INSERT_COLORS,
}

local function get_colors()
    local mode = vim.api.nvim_get_mode().mode
    return MODE_COLORS[mode]
end

local function file_type(colors)
    local file_type = vim.bo.filetype
    local file_type_string = file_type == '' and '-' or file_type:upper()
    return string.format('%s   %s   ', colors.primary, file_type_string)
end

local function treesitter_context(colors)
    if not util.treesitter_active() then
        return colors.secondary
    end

    local allowed_width = vim.o.columns - 50
    local context = vim.fn['nvim_treesitter#statusline'] {indicator_size = allowed_width}
    return string.format('%s %s %%<', colors.secondary, context)
end

local function flags(colors)
    return string.format('%s %%m%%r%%h%%w ', colors.secondary)
end

local function encoding(colors)
    local encoding = vim.bo.fileencoding
    local line_endings = vim.bo.fileformat
    local eol = vim.bo.endofline
    local eol_text = eol and '' or ' NOEOL'

    return string.format('%s %s[%s]%s ', colors.secondary, encoding, line_endings, eol_text)
end

local function search_count(colors)
    local result = vim.fn.searchcount {maxcount = 0}

    if result == nil or
        result.incomplete == nil or
        result.current == nil or
        result.total == nil then
            return ''
    end

    local index_string
    -- If we timed out.
    if result.incomplete == 1 then
        index_string = '?/??'
    else
        index_string = string.format('%d/%d', result.current, result.total)
    end

    return string.format('%s %s ', colors.secondary, index_string)
end

local function file_info(colors)
    local word_count_string = ''
    if vim.b.vimrc__show_word_count then
        if vim.b.vimrc__word_count == nil then
            -- Start with a reasonable default.
            vim.b.vimrc__word_count = vim.fn.wordcount().words
        end

        word_count_string = string.format('WC:%d ', vim.b.vimrc__word_count)
    end

    return string.format('%s %s%%P %%l/%%L col:%%c ', colors.primary, word_count_string)
end

local function warnings()
    local messages = {}

    if util.vim_true(vim.b.table_mode_active) then
        table.insert(messages, 'TABLE MODE')
    end

    if util.vim_true(vim.b.vimrc__in_link_mode) then
        table.insert(messages, 'LINK MODE')
    end

    if vim.b.vimrc__trailing_space_count ~= nil and vim.b.vimrc__trailing_space_count > 0 then
        table.insert(messages, string.format(
            'TRAILING SPACES: %d, line %d',
            vim.b.vimrc__trailing_space_count,
            vim.b.vimrc__trailing_space_line
        ))
    end

    if vim.tbl_isempty(messages) then
        return ''
    else
        return string.format('%%#vimrc__StatuslineWarning# %s ', table.concat(messages, ' | '))
    end
end

local function absolute_path_to_file_name(path)
    return vim.fn.fnamemodify(path, ':t')
end

function M.do_statusline()
    -- Force the tabline to redraw, since it won't always when things like the
    -- mode change.
    redraw_tabline()

    local colors = get_colors()
    local result = table.concat {
        file_type(colors),
        treesitter_context(colors),
        flags(colors),
        '%=',
        encoding(colors),
        search_count(colors),
        file_info(colors),
        warnings(),
    }

    return result
end

local function render_buffers(colors)
    local bufs = util.filter(vim.api.nvim_list_bufs(), function(buf)
        return
            vim.api.nvim_buf_is_loaded(buf) and
            vim.fn.buflisted(buf) ~= 0
    end)

    local active_buf = vim.api.nvim_get_current_buf()

    local tabline = {}
    for _, buf in ipairs(bufs) do
        local name = absolute_path_to_file_name(vim.api.nvim_buf_get_name(buf))
        if name == '' then
            name = '[No Name]'
        end
        local name_with_buf_number = string.format('%d %s', buf, name)

        -- Choose the tab's highlighting.
        if buf == active_buf then
            table.insert(tabline, colors.primary)
        else
            table.insert(tabline, colors.secondary)
        end

        local is_modified = vim.bo[buf].modified
        local modified_string = is_modified and ' ●' or ''

        -- Label the tab.
        table.insert(tabline, string.format(' %s%s ', name_with_buf_number, modified_string))
    end

    -- Fill out the empty space in the tabline.
    table.insert(tabline, colors.secondary)

    return table.concat(tabline)
end

local function render_tabs(colors)
    local active_tab = vim.api.nvim_get_current_tabpage()

    local tabline = {}
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        local name
        if vim.t[tab].vimrc__tab_page_name then
            name = vim.t[tab].vimrc__tab_page_name
        else
            local win = vim.api.nvim_tabpage_get_win(tab)
            local buf = vim.api.nvim_win_get_buf(win)
            name = absolute_path_to_file_name(vim.api.nvim_buf_get_name(buf))
            if name == '' then
                name = '[No Name]'
            end
        end
        local name_with_tab_number = string.format('[%d] %s', tab, name)

        -- Choose the tab's highlighting.
        if tab == active_tab then
            table.insert(tabline, colors.primary)
        else
            table.insert(tabline, colors.secondary)
        end

        -- Label the tab.
        table.insert(tabline, string.format(' %s ', name_with_tab_number))
    end

    return table.concat(tabline)
end

function M.tabline()
    local colors = get_colors()

    if #vim.api.nvim_list_tabpages() == 1 then
        -- Just render the buffers if we only have one tab.
        return render_buffers(colors)
    else
        -- If we have multiple tabs, render the buffers first, then the tabs on
        -- the right.
        local tabline = {}
        table.insert(tabline, render_buffers(colors))
        table.insert(tabline, '%=')
        table.insert(tabline, render_tabs(colors))

        return table.concat(tabline)
    end
end

local function on_cursor_hold()
    if vim.b.vimrc__show_word_count then
        local result = vim.fn.searchcount {pattern = [[\w\+]], timeout = 0, maxcount = 0}
        vim.b.vimrc__word_count = result.total
    end

    do
        vim.b.vimrc__trailing_space_count = vim.fn.searchcount {pattern = [[\s\+$]], timeout = 0, maxcount = 0}.total
        if vim.b.vimrc__trailing_space_count > 0 then
            vim.b.vimrc__trailing_space_line = vim.fn.search([[\s\+$]], 'n')
        end
    end
end

function M.do_winbar(state)
    if util.vim_true(vim.g.started_by_firenvim) then
        return ''
    end

    local colors = get_colors()

    local color
    if state == 'active' then
        color = colors.winbar_active
    else
        color = colors.winbar_inactive
    end

    return string.format('%s %%f %s', color, colors.winbar_inactive)
end

local function set_winbar(state)
    if util.is_floating_window() then
        return
    end

    vim.wo.winbar = string.format(
        [[%%!v:lua.require('vimrc.statusline').do_winbar('%s')]],
        state
    )
end

util.augroup('vimrc__winbar', {
    {{'WinEnter', 'BufWinEnter'}, {callback = function() set_winbar('active') end}},
    {'WinLeave', {callback = function() set_winbar('inactive') end}},
})

util.augroup('vimrc__statusline', {
    {{'CursorHold', 'CursorHoldI'}, {callback = on_cursor_hold}},
})

vim.o.tabline = [[%!v:lua.require('vimrc.statusline').tabline()]]

function M.set_statusline()
    vim.o.statusline = [[%!v:lua.require('vimrc.statusline').do_statusline()]]
end

function M.set_tab_page_name(name, tab)
    local tab = util.default(tab, 0)
    vim.t[tab].vimrc__tab_page_name = name
end

function M.clear_tab_page_name(tab)
    local tab = util.default(tab, 0)
    vim.t[tab].vimrc__tab_page_name = nil
end

util.user_command(
    'SetTabPageName',
    function(args)
        M.set_tab_page_name(args.args, args.count)
    end,
    {nargs = 1, range = 0}
)

util.user_command(
    'ClearTabPageName',
    function(args)
        M.clear_tab_page_name(args.count)
    end,
    {nargs = 0, range = 0}
)

if util.vim_true(vim.g.started_by_firenvim) then
    vim.o.laststatus = 0
    vim.o.showtabline = 0
else
    vim.o.laststatus = 3
    vim.o.showtabline = 2
    M.set_statusline()
end

return M
