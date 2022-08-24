local M = {}

local util = require 'vimrc.util'

local function redraw_tabline()
    -- For some reason :redrawtabline doesn't work....
    vim.bo[vim.g.statusline_bufid].readonly = vim.bo[vim.g.statusline_bufid].readonly
end

local NORMAL_COLORS = {
    primary = '%#vimrc__StatuslinePrimaryNormal#',
    secondary = '%#vimrc__StatuslineSecondaryNormal#',
}

local VISUAL_COLORS = {
    primary = '%#vimrc__StatuslinePrimaryVisual#',
    secondary = '%#vimrc__StatuslineSecondaryVisual#',
}

local INSERT_COLORS = {
    primary = '%#vimrc__StatuslinePrimaryInsert#',
    secondary = '%#vimrc__StatuslineSecondaryInsert#',
}

local REPLACE_COLORS = {
    primary = '%#vimrc__StatuslinePrimaryReplace#',
    secondary = '%#vimrc__StatuslineSecondaryReplace#',
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
    local file_type = vim.bo[vim.g.statusline_bufid].filetype
    local file_type_string = file_type == '' and '-' or file_type:upper()
    return string.format('%s   %s   ', colors.primary, file_type_string)
end

local function file_path(colors)
    return string.format('%s %%f %%<', colors.secondary)
end

local function flags(colors)
    return string.format('%s %%m%%r%%h%%w ', colors.secondary)
end

local function encoding(colors)
    local encoding = vim.bo[vim.g.statusline_bufid].fileencoding
    local line_endings = vim.bo[vim.g.statusline_bufid].fileformat
    local eol = vim.bo[vim.g.statusline_bufid].endofline
    local eol_text = eol and '' or ' NOEOL'

    return string.format('%s %s[%s]%s ', colors.secondary, encoding, line_endings, eol_text)
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

    return string.format('%s %s%%P %%l/%%L col: %%c ', colors.primary, word_count_string)
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

local function active_statusline()
    -- Force the tabline to redraw, since it won't always when things like the
    -- mode change.
    redraw_tabline()

    local colors = get_colors()
    return table.concat {
        file_type(colors),
        file_path(colors),
        flags(colors),
        '%=',
        encoding(colors),
        file_info(colors),
        warnings(),
    }
end

local function inactive_statusline()
    return '%#StatusLineNC# %F '
end

function M.do_statusline(state)
    vim.g.statusline_bufid = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
    local result

    if state == 'active' then
        result = active_statusline()
    elseif state == 'inactive' then
        result = inactive_statusline()
    else
        error('unexpected')
    end

    vim.g.statusline_bufid = nil
    return result
end

local function render_single_tab(tabline, colors, buf, is_active, name)
    -- Choose the tab's highlighting.
    if is_active then
        table.insert(tabline, colors.primary)
    else
        table.insert(tabline, colors.secondary)
    end

    local is_modified = vim.bo[buf].modified
    local modified_string = is_modified and ' ●' or ''

    -- Label the tab.
    table.insert(tabline, string.format(' %s%s ', name, modified_string))
end

local function render_buffers()
    local bufs = util.filter(vim.api.nvim_list_bufs(), function(buf)
        return
            vim.api.nvim_buf_is_loaded(buf) and
            vim.fn.buflisted(buf) ~= 0
    end)

    local active_buf = vim.api.nvim_get_current_buf()
    local colors = get_colors()

    local tabline = {}
    for _, buf in ipairs(bufs) do
        local name = absolute_path_to_file_name(vim.api.nvim_buf_get_name(buf))
        if name == '' then
            name = '[No Name]'
        end

        -- Label the tab with the buffer number and name.
        render_single_tab(
            tabline,
            colors,
            buf,
            buf == active_buf,
            string.format('%d %s', buf, name))
    end

    -- Fill out the empty space in the tabline.
    table.insert(tabline, colors.secondary)

    return table.concat(tabline)
end

local function render_tabs()
    local active_tab = vim.api.nvim_get_current_tabpage()
    local colors = get_colors()

    local tabline = {}
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        local win = vim.api.nvim_tabpage_get_win(tab)
        local buf = vim.api.nvim_win_get_buf(win)
        local name = absolute_path_to_file_name(vim.api.nvim_buf_get_name(buf))
        if name == '' then
            name = '[No Name]'
        end

        -- Label the tab with the buffer name.
        render_single_tab(
            tabline,
            colors,
            buf,
            tab == active_tab,
            name)
    end

    -- Fill out the empty space in the tabline.
    table.insert(tabline, colors.secondary)

    return table.concat(tabline)
end

function M.tabline()
    if #vim.api.nvim_list_tabpages() == 1 then
        -- Just render the buffers if we only have one tab.
        return render_buffers()
    else
        -- If we have multiple tabs, render the tabs first, then the buffers on
        -- the right.
        local tabline = {}
        table.insert(tabline, render_tabs())
        table.insert(tabline, '%=')
        table.insert(tabline, render_buffers())

        return table.concat(tabline)
    end
end

local function on_cursor_hold()
    if vim.b.vimrc__show_word_count then
        local result = vim.fn.searchcount({pattern = [[\w\+]], timeout = 0, maxcount = 0})
        vim.b.vimrc__word_count = result.total
    end

    do
        vim.b.vimrc__trailing_space_count = vim.fn.searchcount({pattern = [[\s\+$]], timeout = 0, maxcount = 0}).total
        if vim.b.vimrc__trailing_space_count > 0 then
            vim.b.vimrc__trailing_space_line = vim.fn.search([[\s\+$]], 'n')
        end
    end
end

local function set_statusline(state)
    vim.opt_local.statusline = string.format(
        [[%%!v:lua.require('vimrc.statusline').do_statusline('%s')]],
        state
    )
end

util.augroup('vimrc__statusline', {
    {{'WinEnter', 'BufWinEnter'}, {callback = function() set_statusline('active') end}},
    {'WinLeave', {callback = function() set_statusline('inactive') end}},
    {{'CursorHold', 'CursorHoldI'}, {callback = on_cursor_hold}},
})

vim.opt.tabline = [[%!v:lua.require('vimrc.statusline').tabline()]]

if util.vim_true(vim.g.started_by_firenvim) then
    vim.opt.laststatus = 0
    vim.opt.showtabline = 0
else
    vim.opt.laststatus = 2
    vim.opt.showtabline = 2
end

return M
