local util = require 'vimrc.util'

vim.opt.ignorecase = true -- Make search case insensitive.
vim.opt.smartcase = true -- Ignore case if only lowercase characters are used in search text.
vim.opt.incsearch = true -- Show search results incrementally as you type.
vim.opt.gdefault = true -- Always do global substitutions.
vim.opt.hlsearch = false -- Don't highlight searches by default.

-- Always do case sensitive search with * and #.
util.map('', '*', [[/\C\<<c-r>=expand('<cword>')<cr>\><cr>]])
util.map('', '#', [[?\C\<<c-r>=expand('<cword>')<cr>\><cr>]])

-- Search the file system using ripgrep.
if util.vim_executable('rg') then
    vim.opt.grepprg = 'rg --vimgrep --smart-case --hidden'
    vim.opt.grepformat = '%f:%l:%c:%m'
end

util.user_command('COpen', 'copen | normal! <c-w>J', {nargs = 0})

local last_grep_args = ''
local function grep(args)
    -- If we weren't passed in any args, we should execute the last search.
    -- Otherwise we should store the given arguments as the last search.
    if args == nil then
        args = last_grep_args
    else
        last_grep_args = args
    end

    vim.cmd('silent grep! ' .. args)
    vim.cmd 'COpen'
end
util.user_command('Grep', function(args) grep(args.args) end, {nargs = 1})

util.map('n', '[q', '<cmd>cprev<cr>')
util.map('n', ']q', '<cmd>cnext<cr>')

util.map('n', '<leader>co', '<cmd>COpen<cr>')
util.map('n', '<leader>cc', '<cmd>cclose<cr>')

vim.cmd [[
    function! s:QuickfixMapping()
        nnoremap <buffer> K <cmd>cprev<cr>zz<c-w>w
        nnoremap <buffer> J <cmd>cnext<cr>zz<c-w>w
    endfunction

    augroup vimrc__quickfix
        autocmd!
        autocmd filetype qf call <sid>QuickfixMapping()
    augroup end

    " Only highlight searches while actually typing the search.
    augroup vimrc__search_highlight
        autocmd!
        autocmd CmdlineEnter /,\? :set hlsearch
        autocmd CmdlineLeave /,\? :set nohlsearch
    augroup end
]]

vim.opt.path:append('**') -- Search recursively by default.

util.map('n', '<leader>/', ':Grep ', {silent = false})
util.map('n', '<leader><leader>/', function() grep() end)
util.map('n', '<leader>8', function() grep('-w ' .. vim.fn.expand('<cword>')) end)
util.map('n', '<leader>f', ':find ', {silent = false})

-- Toggle search highlighting.
util.map('n', '<leader>sh', function()
    vim.opt.hlsearch = not vim.opt.hlsearch:get()
end)

-- Make gf open the file even if it doesn't exist.
util.map('n', 'gf', '<cmd>e <cfile><cr>')

-- Search Duck Duck Go for the chosen text.
local duck_duck_go = util.new_operator(function(motion)
    local reg_backup = vim.fn.getreginfo('"')

    util.opfunc_normal_command(motion, 'y')
    local reg_content = vim.fn.getreg('"', 1, true --[[list]])
    if #reg_content > 1 then
        util.log_error('Cannot search multiple lines on Duck Duck Go.')
        return
    end

    vim.fn['netrw#BrowseX'](string.format('https://duckduckgo.com/?q=%s', reg_content[1]), 0)

    vim.fn.setreg('"', reg_backup)
end)

util.map({'n', 'x'}, '<leader>sd', duck_duck_go, {expr = true})
