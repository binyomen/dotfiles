local M = {}

local mode_names = {
    n = 'normal',
    no = 'operator pending',
    nov = 'operator pending',
    noV = 'operator pending',
    ['no'] = 'operator pending',
    niI = 'normal',
    niR = 'normal',
    niV = 'normal',
    nt = 'normal',
    v = 'visual',
    vs = 'visual',
    V = 'visual line',
    Vs = 'visual line',
    [''] = 'visual block',
    ['s'] = 'visual block',
    s = 'select',
    S = 'select line',
    [''] = 'select block',
    i = 'insert',
    ic = 'insert',
    ix = 'insert',
    R = 'replace',
    Rc = 'replace',
    Rx = 'replace',
    Rv = 'virtual replace',
    Rvc = 'virtual replace',
    Rvx = 'virtual replace',
    c = 'command',
    cv = 'vim ex',
    r = 'prompt',
    rm = 'prompt',
    ['r?'] = 'confirm',
    ['!'] = 'shell',
    t = 'terminal',
}

local normal_colors = {
    base = '%#StatusLine#',
    mode = '%#Normal#',
    file = '%#Todo#',
    file_type = '%#Directory#',
    encoding = '%#Constant#',
    file_info = '%#Identifier#',

    tabline_active = '%#TabLineSel#',
    tabline_inactive = '%#TabLine#',
    tabline_fill = '%#TabLineFill#',
}

local operator_pending_colors = {
    base = '%#StatusLine#',
    mode = '%#Statement#',
    file = '%#Todo#',
    file_type = '%#Directory#',
    encoding = '%#Constant#',
    file_info = '%#Identifier#',

    tabline_active = '%#TabLineSel#',
    tabline_inactive = '%#TabLine#',
    tabline_fill = '%#TabLineFill#',
}

local visual_colors = {
    base = '%#StatusLine#',
    mode = '%#Search#',
    file = '%#Todo#',
    file_type = '%#Directory#',
    encoding = '%#Constant#',
    file_info = '%#Identifier#',

    tabline_active = '%#TabLineSel#',
    tabline_inactive = '%#TabLine#',
    tabline_fill = '%#TabLineFill#',
}

local select_colors = {
    base = '%#StatusLine#',
    mode = '%#IncSearch#',
    file = '%#Todo#',
    file_type = '%#Directory#',
    encoding = '%#Constant#',
    file_info = '%#Identifier#',

    tabline_active = '%#TabLineSel#',
    tabline_inactive = '%#TabLine#',
    tabline_fill = '%#TabLineFill#',
}

local insert_colors = {
    base = '%#StatusLine#',
    mode = '%#MoreMsg#',
    file = '%#Todo#',
    file_type = '%#Directory#',
    encoding = '%#Constant#',
    file_info = '%#Identifier#',

    tabline_active = '%#TabLineSel#',
    tabline_inactive = '%#TabLine#',
    tabline_fill = '%#TabLineFill#',
}

local replace_colors = {
    base = '%#StatusLine#',
    mode = '%#ErrorMsg#',
    file = '%#Todo#',
    file_type = '%#Directory#',
    encoding = '%#Constant#',
    file_info = '%#Identifier#',

    tabline_active = '%#TabLineSel#',
    tabline_inactive = '%#TabLine#',
    tabline_fill = '%#TabLineFill#',
}

local command_colors = {
    base = '%#StatusLine#',
    mode = '%#Question#',
    file = '%#Todo#',
    file_type = '%#Directory#',
    encoding = '%#Constant#',
    file_info = '%#Identifier#',

    tabline_active = '%#TabLineSel#',
    tabline_inactive = '%#TabLine#',
    tabline_fill = '%#TabLineFill#',
}

local terminal_colors = {
    base = '%#StatusLine#',
    mode = '%#Type#',
    file = '%#Todo#',
    file_type = '%#Directory#',
    encoding = '%#Constant#',
    file_info = '%#Identifier#',

    tabline_active = '%#TabLineSel#',
    tabline_inactive = '%#TabLine#',
    tabline_fill = '%#TabLineFill#',
}

local mode_colors = {
    n = normal_colors,
    no = operator_pending_colors,
    nov = operator_pending_colors,
    noV = operator_pending_colors,
    ['no'] = operator_pending_colors,
    niI = normal_colors,
    niR = normal_colors,
    niV = normal_colors,
    nt = normal_colors,
    v = visual_colors,
    vs = visual_colors,
    V = visual_colors,
    Vs = visual_colors,
    [''] = visual_colors,
    ['s'] = visual_colors,
    s = select_colors,
    S = select_colors,
    [''] = select_colors,
    i = insert_colors,
    ic = insert_colors,
    ix = insert_colors,
    R = replace_colors,
    Rc = replace_colors,
    Rx = replace_colors,
    Rv = replace_colors,
    Rvc = replace_colors,
    Rvx = replace_colors,
    c = command_colors,
    cv = command_colors,
    r = command_colors,
    rm = command_colors,
    ['r?'] = command_colors,
    ['!'] = command_colors,
    t = terminal_colors,
}

local function get_colors()
    local mode = vim.api.nvim_get_mode().mode
    return mode_colors[mode]
end

local function mode_name(colors)
    local mode = vim.api.nvim_get_mode().mode
    return string.format('%s %s ', colors.mode, mode_names[mode])
end

local function file_path(colors)
    return string.format('%s %%f ', colors.file)
end

local function flags(colors)
    return string.format('%s %%m%%r%%h%%w ', colors.file)
end

local function file_type(colors)
    return string.format('%s %%y ', colors.file_type)
end

local function encoding(colors)
    local encoding = vim.opt.fileencoding:get()
    local line_endings = vim.opt.fileformat:get()

    return string.format('%s %s[%s] ', colors.encoding, encoding, line_endings)
end

local function file_info(colors)
    return string.format('%s %%P %%l/%%L col: %%c ', colors.file_info)
end

local function absolute_path_to_file_name(path)
    return vim.fn.fnamemodify(path, ':t')
end

function M.active_statusline()
    local colors = get_colors()
    return table.concat {
        mode_name(colors),
        file_path(colors),
        flags(colors),
        '%=',
        file_type(colors),
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
        if vim.api.nvim_buf_is_loaded(buf) then
            table.insert(bufs, buf)
        end
    end
    table.sort(bufs)

    local active_buf = vim.api.nvim_get_current_buf()
    local colors = get_colors()

    local tabline = {}
    for _, buf in ipairs(bufs) do
        -- Choose the tab's highlighting.
        if buf == active_buf then
            table.insert(tabline, colors.tabline_active)
        else
            table.insert(tabline, colors.tabline_inactive)
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
    table.insert(tabline, colors.tabline_fill)

    return table.concat(tabline)
end

local function render_tabs()
    local active_tab = vim.api.nvim_get_current_tabpage()

    local tabline = {}
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        -- Choose the tab's highlighting.
        if tab == active_tab then
            table.insert(tabline, colors.tabline_active)
        else
            table.insert(tabline, colors.tabline_inactive)
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
    table.insert(tabline, colors.tabline_fill)

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

-- Show the statusline all the time, rather than only when a split is created.
vim.opt.laststatus = 2

-- Always show the tabline.
vim.opt.showtabline = 2

vim.opt.tabline = [[%!v:lua.require('statusline').tabline()]]

return M
