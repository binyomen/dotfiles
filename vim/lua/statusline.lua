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

-- Show the statusline all the time, rather than only when a split is created.
vim.opt.laststatus = 2

vim.cmd [[
augroup statusline
    autocmd!
    autocmd WinEnter,BufWinEnter * setlocal statusline=%!v:lua.require('statusline').active_statusline()
    autocmd WinLeave * setlocal statusline=%!v:lua.require('statusline').inactive_statusline()
augroup end
]]

return M
