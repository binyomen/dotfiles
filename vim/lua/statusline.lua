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

local function mode_name()
    local mode = vim.api.nvim_get_mode().mode
    return mode_names[mode]
end

local function file_path()
    return ' %f'
end

local function flags()
    return ' %m%r%h%w'
end

local function file_type()
    return '%y'
end

local function encoding()
    local encoding = vim.opt.fileencoding:get()
    local line_endings = vim.opt.fileformat:get()

    return string.format(' %s[%s]', encoding, line_endings)
end

local function file_info()
    return ' %P %l/%L col: %c'
end

local function absolute_path_to_file_name(path)
    return vim.fn.fnamemodify(path, ':t')
end

function M.active_statusline()
    return table.concat {
        mode_name(),
        file_path(),
        flags(),
        '%=',
        file_type(),
        encoding(),
        file_info(),
    }
end

function M.inactive_statusline()
    return '%F'
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

    local tabline = {}
    for _, buf in ipairs(bufs) do
        -- Choose the tab's highlighting.
        if buf == active_buf then
            table.insert(tabline, '%#TabLineSel#')
        else
            table.insert(tabline, '%#TabLine#')
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
    table.insert(tabline, '%#TabLineFill#%T')

    return table.concat(tabline)
end

local function render_tabs()
    local active_tab = vim.api.nvim_get_current_tabpage()

    local tabline = {}
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        -- Choose the tab's highlighting.
        if tab == active_tab then
            table.insert(tabline, '%#TabLineSel#')
        else
            table.insert(tabline, '%#TabLine#')
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
    table.insert(tabline, '%#TabLineFill#%T')

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
