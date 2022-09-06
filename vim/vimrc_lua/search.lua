local util = require 'vimrc.util'

vim.opt.ignorecase = true -- Make search case insensitive.
vim.opt.smartcase = true -- Ignore case if only lowercase characters are used in search text.
vim.opt.incsearch = true -- Show search results incrementally as you type.
vim.opt.gdefault = true -- Always do global substitutions.
vim.opt.hlsearch = false -- Don't highlight searches by default.

-- Always do case sensitive search with * and #.
util.map({'n', 'x', 'o'}, '*', [[/\C\<<c-r>=expand('<cword>')<cr>\><cr>]])
util.map({'n', 'x', 'o'}, '#', [[?\C\<<c-r>=expand('<cword>')<cr>\><cr>]])

-- Search the file system using ripgrep.
if util.vim_executable('rg') then
    vim.opt.grepprg = 'rg --vimgrep --smart-case'
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
util.map('n', '<leader>cc', '<cmd>cclose | lclose<cr>')

local function set_quickfix_mappings()
    util.map('n', 'K', '<cmd>cprev<cr>zz<c-w>w', {buffer = true})
    util.map('n', 'J', '<cmd>cnext<cr>zz<c-w>w', {buffer = true})
end
util.augroup('vimrc__quickfix', {
    {'FileType', {pattern = 'qf', callback = set_quickfix_mappings}},
})

-- Only highlight searches while actually typing the search.
util.augroup('vimrc__search_highlight', {
    {'CmdlineEnter', {pattern = [[/,\?]], callback =
        function()
            vim.opt.hlsearch = true
        end
    }},
    {'CmdlineLeave', {pattern = [[/,\?]], callback =
        function()
            vim.opt.hlsearch = false
        end
    }},
})

vim.opt.path:append('**') -- Search recursively by default.

util.map('n', '<leader>/', ':Grep ', {silent = false})
util.map('n', '<leader><leader>/', function() grep() end)
util.map('n', '<leader>8', function() grep('-w ' .. vim.fn.expand('<cword>')) end)

-- Toggle search highlighting.
util.map('n', '<leader>sh', function()
    vim.opt.hlsearch = not vim.opt.hlsearch:get()
end)

-- Make gf open the file even if it doesn't exist.
util.map('n', 'gf', '<cmd>e <cfile><cr>')

-- Search Duck Duck Go for the chosen text.
util.map({'n', 'x'}, {expr = true}, '<leader>sd', util.new_operator(function(motion)
    local reg_backup = vim.fn.getreginfo('"')

    util.opfunc_normal_command(motion, 'y')
    local reg_content = vim.fn.getreg('"', 1, true --[[list]])
    if #reg_content > 1 then
        util.log_error('Cannot search multiple lines on Duck Duck Go.')
        return
    end

    util.browse_to(string.format('https://duckduckgo.com/?q=%s', reg_content[1]))

    vim.fn.setreg('"', reg_backup)
end))

-- Improve quickfix aesthetics, taken from
-- https://github.com/kevinhwang91/nvim-bqf#format-new-quickfix
function _G.quickfix_text(info)
    local items
    if util.vim_true(info.quickfix) then
        items = vim.fn.getqflist({id = info.id, items = 0}).items
    else
        items = vim.fn.getloclist(info.winid, {id = info.id, items = 0}).items
    end

    local LIMIT = 31
    local lines = {}
    for i = info.start_idx, info.end_idx do
        local item = items[i]
        local filename = ''
        local str

        if item.valid == 1 then
            if item.bufnr > 0 then
                filename = vim.fn.bufname(item.bufnr)
                if filename == '' then
                    filename = '[No Name]'
                end

                -- Replace the home directory with "~".
                filename = filename:gsub('^' .. vim.env.HOME, '~')

                -- Trim long filenames.
                --
                -- A character in the filename may have a width of more than 1.
                -- Ignore this issue in order to keep acceptable performance.
                if #filename <= LIMIT then
                    filename = string.format('%-' .. LIMIT .. 's', filename)
                else
                    filename = string.format('…%.' .. (LIMIT - 1) .. 's', filename:sub(1 - LIMIT))
                end
            end

            local lnum = item.lnum > 99999 and -1 or item.lnum
            local col = item.col > 999 and -1 or item.col
            local qtype = item.type == '' and '' or string.format(' %s', item.type:sub(1, 1):upper())

            str =  string.format('%s │%5d:%-3d│%s %s', filename, lnum, col, qtype, item.text)
        else
            str = item.text
        end

        table.insert(lines, str)
    end

    return lines
end

vim.o.quickfixtextfunc = [[{info -> v:lua._G.quickfix_text(info)}]]
