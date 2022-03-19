local M = {}

local util = require 'util'

vim.opt.ignorecase = true -- Make search case insensitive.
vim.opt.smartcase = true -- Ignore case if only lowercase characters are used in search text.
vim.opt.incsearch = true -- Show search results incrementally as you type.
vim.opt.gdefault = true -- Always do global substitutions.
vim.opt.hlsearch = false -- Don't highlight searches by default.

-- Always do case sensitive search with * and #.
util.map('', '*', [[/\C\<<c-r>=expand('<cword>')<cr>\><cr>]])
util.map('', '#', [[?\C\<<c-r>=expand('<cword>')<cr>\><cr>]])

-- Search the file system using ripgrep.
if vim.fn.executable('rg') then
    vim.opt.grepprg = 'rg --vimgrep --smart-case --hidden'
    vim.opt.grepformat = '%f:%l:%c:%m'
end

vim.cmd 'command! -nargs=0 COpen copen | normal! <c-w>J'

function M.grep(args)
    -- Expand anything like wildcards or <cword>. This is important for storing
    -- in last_grep_args, and doing it here guarantees we pass the same
    -- arguments to grep as we store.
    local args = vim.fn.expandcmd(args)

    -- If we weren't passed in any args, we should execute the last search.
    -- Otherwise we should store the given arguments as the last search.
    if args == '' then
        args = M.last_grep_args
    else
        M.last_grep_args = args
    end

    vim.cmd('execute "silent grep! ' .. args .. '"')
    vim.cmd 'COpen'
end
vim.cmd 'command! -nargs=* Grep lua require("search").grep("<args>")'

util.map('n', '[q', ':cprev<cr>')
util.map('n', ']q', ':cnext<cr>')

util.map('n', '<leader>co', ':COpen<cr>')
util.map('n', '<leader>cc', ':cclose<cr>')

vim.cmd [[
    function! s:QuickfixMapping()
        nnoremap <buffer> K :cprev<cr>zz<c-w>w
        nnoremap <buffer> J :cnext<cr>zz<c-w>w
    endfunction

    augroup quickfix
        autocmd!
        autocmd filetype qf call <sid>QuickfixMapping()
    augroup end

    " Only highlight searches while actually typing the search.
    augroup search_highlight
        autocmd!
        autocmd CmdlineEnter /,\? :set hlsearch
        autocmd CmdlineLeave /,\? :set nohlsearch
    augroup end
]]

vim.opt.path:append('**') -- Search recursively by default.

util.map('n', '<leader>/', ':Grep ', {silent = false})
util.map('n', '<leader><leader>/', ':Grep<cr>')
util.map('n', '<leader>8', ':Grep -w <cword><cr>')
util.map('n', '<leader>f', ':find ', {silent = false})

-- Toggle search highlighting.
util.map('n', '<leader>sh', ':set hlsearch!<cr>')

-- Make gf open the file even if it doesn't exist.
util.map('n', 'gf', '<cmd>e <cfile><cr>')

return M
