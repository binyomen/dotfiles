local M = {}

local function redraw_tabline()
    -- For some reason :redrawtabline doesn't work....
    vim.opt_local.readonly = vim.opt_local.readonly
end

local NORMAL_COLORS = {
    primary = '%#__StatuslinePrimaryNormal#',
    secondary = '%#__StatuslineSecondaryNormal#',
}

local VISUAL_COLORS = {
    primary = '%#__StatuslinePrimaryVisual#',
    secondary = '%#__StatuslineSecondaryVisual#',
}

local INSERT_COLORS = {
    primary = '%#__StatuslinePrimaryInsert#',
    secondary = '%#__StatuslineSecondaryInsert#',
}

local REPLACE_COLORS = {
    primary = '%#__StatuslinePrimaryReplace#',
    secondary = '%#__StatuslineSecondaryReplace#',
}

local MODE_COLORS = {
    n = NORMAL_COLORS,
    no = NORMAL_COLORS,
    nov = NORMAL_COLORS,
    noV = NORMAL_COLORS,
    ['no'] = NORMAL_COLORS,
    niI = NORMAL_COLORS,
    niR = NORMAL_COLORS,
    niV = NORMAL_COLORS,
    nt = NORMAL_COLORS,
    v = VISUAL_COLORS,
    vs = VISUAL_COLORS,
    V = VISUAL_COLORS,
    Vs = VISUAL_COLORS,
    [''] = VISUAL_COLORS,
    ['s'] = VISUAL_COLORS,
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
    local file_type = vim.opt_local.filetype:get()
    local file_type_string = file_type == '' and '-' or file_type:upper()
    return string.format('%s   %s   ', colors.primary, file_type_string)
end

local function file_path(colors)
    return string.format('%s %%f ', colors.secondary)
end

local function flags(colors)
    return string.format('%s %%m%%r%%h%%w ', colors.secondary)
end

local function encoding(colors)
    local encoding = vim.opt_local.fileencoding:get()
    local line_endings = vim.opt_local.fileformat:get()
    local eol = vim.opt_local.endofline:get()
    local eol_text = eol and '' or ' NOEOL'

    return string.format('%s %s[%s]%s ', colors.secondary, encoding, line_endings, eol_text)
end

local function file_info(colors)
    local word_count_string = ''
    if vim.b.show_word_count then
        if vim.b.word_count == nil then
            -- Start with a reasonable default.
            vim.b.word_count = vim.fn.wordcount().words
        end

        word_count_string = string.format('WC:%d ', vim.b.word_count)
    end

    return string.format('%s %s%%P %%l/%%L col: %%c ', colors.primary, word_count_string)
end

local function absolute_path_to_file_name(path)
    return vim.fn.fnamemodify(path, ':t')
end

function M.active_statusline()
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
    }
end

function M.inactive_statusline()
    return '%#StatusLineNC# %F '
end

local function render_single_tab(tabline, colors, buf, is_active, name)
    -- Choose the tab's highlighting.
    if is_active then
        table.insert(tabline, colors.primary)
    else
        table.insert(tabline, colors.secondary)
    end

    local is_modified = vim.api.nvim_buf_get_option(buf, 'modified')
    local modified_string = is_modified and ' ●' or ''

    -- Label the tab.
    table.insert(tabline, string.format(' %s%s ', name, modified_string))
end

local function render_buffers()
    local bufs = vim.tbl_filter(
        function(buf)
            return vim.api.nvim_buf_is_loaded(buf) and vim.fn.buflisted(buf) ~= 0
        end,
        vim.api.nvim_list_bufs()
    )

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

function M.on_cursor_hold()
    if not vim.b.show_word_count then
        return
    end

    local result = vim.fn.searchcount({pattern = [[\w\+]], timeout = 0, maxcount = 0})
    vim.b.word_count = result.total
end

vim.cmd [[
    augroup statusline
        autocmd!
        autocmd WinEnter,BufWinEnter * setlocal statusline=%!v:lua.require('vimrc.statusline').active_statusline()
        autocmd WinLeave * setlocal statusline=%!v:lua.require('vimrc.statusline').inactive_statusline()
        autocmd CursorHold * lua require('vimrc.statusline').on_cursor_hold()
        autocmd CursorHoldI * lua require('vimrc.statusline').on_cursor_hold()
    augroup end
]]
vim.opt.tabline = [[%!v:lua.require('vimrc.statusline').tabline()]]

if vim.g.started_by_firenvim then
    vim.opt.laststatus = 0
    vim.opt.showtabline = 0
else
    vim.opt.laststatus = 2
    vim.opt.showtabline = 2
end

return M
