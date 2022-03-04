local M = {}

local function redraw_tabline()
    -- For some reason :redrawtabline doesn't work....
    vim.cmd [[let &ro = &ro]]
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
    return string.format('%s %%y ', colors.primary)
end

local function file_path(colors)
    return string.format('%s %%f ', colors.secondary)
end

local function flags(colors)
    return string.format('%s %%m%%r%%h%%w ', colors.secondary)
end

local function encoding(colors)
    local encoding = vim.opt.fileencoding:get()
    local line_endings = vim.opt.fileformat:get()

    return string.format('%s %s[%s] ', colors.secondary, encoding, line_endings)
end

local function file_info(colors)
    return string.format('%s %%P %%l/%%L col: %%c ', colors.primary)
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

local function render_buffers()
    local bufs = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.fn.buflisted(buf) ~= 0 then
            table.insert(bufs, buf)
        end
    end

    local active_buf = vim.api.nvim_get_current_buf()
    local colors = get_colors()

    local tabline = {}
    for _, buf in ipairs(bufs) do
        -- Choose the tab's highlighting.
        if buf == active_buf then
            table.insert(tabline, colors.primary)
        else
            table.insert(tabline, colors.secondary)
        end

        -- Start the actual tab.
        table.insert(tabline, string.format('%%%dT', buf))

        -- Label the tab.
        local name = absolute_path_to_file_name(vim.api.nvim_buf_get_name(buf))
        if name == '' then
            name = '[No Name]'
        end
        table.insert(tabline, string.format(' %d %s ', buf, name))
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
        -- Choose the tab's highlighting.
        if tab == active_tab then
            table.insert(tabline, colors.primary)
        else
            table.insert(tabline, colors.secondary)
        end

        -- Start the actual tab.
        table.insert(tabline, string.format('%%%dT', tab))

        -- Label the tab.
        local win = vim.api.nvim_tabpage_get_win(tab)
        local buf = vim.api.nvim_win_get_buf(win)
        local name = absolute_path_to_file_name(vim.api.nvim_buf_get_name(buf))
        if name == '' then
            name = '[No Name]'
        end
        table.insert(tabline, string.format(' %s ', name))
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

vim.cmd [[
    augroup statusline
        autocmd!
        autocmd WinEnter,BufWinEnter * setlocal statusline=%!v:lua.require('statusline').active_statusline()
        autocmd WinLeave * setlocal statusline=%!v:lua.require('statusline').inactive_statusline()
    augroup end
]]
vim.opt.tabline = [[%!v:lua.require('statusline').tabline()]]

if vim.g.started_by_firenvim then
    vim.opt.laststatus = 0
    vim.opt.showtabline = 0
else
    vim.opt.laststatus = 2
    vim.opt.showtabline = 2
end

return M
