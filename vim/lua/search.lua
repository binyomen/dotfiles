search = {}
local M = search

local util = require 'util'

vim.opt.ignorecase = true -- Make search case insensitive.
vim.opt.smartcase = true -- Ignore case if only lowercase characters are used in search text.
vim.opt.incsearch = true -- Show search results incrementally as you type.
vim.opt.gdefault = true -- Always do global substitutions.

-- Search the file system using ripgrep.
if vim.fn.executable('rg') then
    vim.opt.grepprg = 'rg --vimgrep --smart-case --hidden'
    vim.opt.grepformat = '%f:%l:%c:%m'
end

vim.cmd 'command! -nargs=0 COpen copen | normal! <c-w>J'
vim.cmd 'command! -nargs=+ Grep execute "silent grep! <args>" | COpen'

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
]]

vim.opt.path:append('**') -- Search recursively by default.

util.map('n', '<leader>/', ':Grep<space>', {silent = false})
util.map('n', '<leader>8', ':Grep -w <cword><cr>')
util.map('n', '<leader>f', ':find<space>', {silent = false})

return M
