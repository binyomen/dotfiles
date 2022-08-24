local util = require 'vimrc.util'

local namespace = vim.api.nvim_create_namespace('vimrc.misc')

-- Fix the closest previous spelling mistake.
util.map('n', {expr = true}, '<leader>z=', util.new_operator_with_inherent_motion('l', function()
    local extmark = util.get_extmark_from_cursor(namespace)

    -- Go back to the previous spelling mistake and choose the first suggestion.
    vim.cmd [[silent normal [s1z=]]

    -- Return to our previous position.
    util.set_cursor_from_extmark(extmark, namespace)
    vim.api.nvim_buf_del_extmark(0 --[[buffer]], namespace, extmark)
end))

-- Mark the closest previous spelling mistake good.
util.map('n', {expr = true, silent = false}, '<leader>zg', util.new_operator_with_inherent_motion('l', function()
    local extmark = util.get_extmark_from_cursor(namespace)

    -- Go back to the previous spelling mistake and mark it as good.
    vim.cmd [[normal [szg]]

    -- Return to our previous position.
    util.set_cursor_from_extmark(extmark, namespace)
    vim.api.nvim_buf_del_extmark(0 --[[buffer]], namespace, extmark)
end))

util.map('n', '<leader>zt', function()
    vim.opt_local.spell = not vim.opt_local.spell:get()
end)

local function clear_cursor_highlight()
    if vim.w.vimrc__cursor_highlight_match_id ~= nil then
        vim.fn.matchdelete(vim.w.vimrc__cursor_highlight_match_id)
        vim.w.vimrc__cursor_highlight_match_id = nil
    end
end

-- Highlight word under cursor.
local function highlight_word_under_cursor()
    clear_cursor_highlight()

    local word = vim.fn.escape(vim.fn.expand('<cword>'), [[\/]])
    local pattern = string.format([[\V\<%s\>]], word)

    vim.w.vimrc__cursor_highlight_match_id = vim.fn.matchadd('vimrc__CursorOver', pattern)
end

util.augroup('vimrc__highlight_word_under_cursor', {
    {{'CursorMoved', 'CursorMovedI'}, {callback = highlight_word_under_cursor}},
    {'WinLeave', {callback = clear_cursor_highlight}},
})

-- Center mode.
local in_center_mode
local function enable_center_mode()
    util.augroup('vimrc__center_mode', {
        {'CursorMoved', {command = 'normal! zz'}},
    })

    vim.cmd [[normal! zz]]

    in_center_mode = true
end

local function disable_center_mode()
    -- Do this check since the below API will fail if the group doesn't exist.
    if in_center_mode then
        vim.api.nvim_del_augroup_by_name('vimrc__center_mode')
    end

    in_center_mode = false
end

-- This is the default setting.
disable_center_mode()

-- Toggle center mode.
util.map('n', {expr = true}, 'cm', util.new_operator_with_inherent_motion('l', function()
    if in_center_mode then
        disable_center_mode()
    else
        enable_center_mode()
    end
end))

-- Easy switching between cpp and header files.
util.map('n', '<leader>ch', function()
    if vim.fn.expand('%:e') == 'h' then
        vim.cmd [[edit %<.cpp]]
    elseif vim.fn.expand('%:e') == 'cpp' then
        vim.cmd [[edit %<.h]]
    end
end)

-- Search help for the word under the cursor.
util.map('n', '<leader>?', [[<cmd>execute 'help ' . expand("<cword>")<cr>]])

-- Open GitHub short URLs for plugins.
util.map('n', '<leader>gh', function()
    util.browse_to('https://github.com/' .. vim.fn.expand('<cfile>'))
end)

-- errorformat
do
    -- `vim.opt` seems to be broken when appending for errorformat. Use `vim.o` instead.
    local old_errorformat = vim.o.errorformat
    vim.o.errorformat = ''

    local function append_errorformat(format)
        vim.o.errorformat = vim.o.errorformat .. ',' .. format
    end

    -- build.exe errors
    append_errorformat([[%[0-9]%\+>%f(%l) : %m]])
    append_errorformat([[%f(%l) : %m]])

    -- Add the original format strings to the end.
    append_errorformat(old_errorformat)

    -- Ignore anything that doesn't match the previous errors.
    append_errorformat([[%-G%.%#]])
end

-- Fixes the problem detailed at
-- http://vim.wikia.com/wiki/Keep_folds_closed_while_inserting_text. Without
-- this, folds open and close at will as you type code.
util.augroup('vimrc__fixfolds', {
    {'InsertEnter', {command = [[if !exists('w:last_fdm') | let w:last_fdm=&foldmethod | setlocal foldmethod=manual | endif]]}},
    {{'InsertLeave', 'WinLeave'}, {command = [[if exists('w:last_fdm') | let &l:foldmethod=w:last_fdm | unlet w:last_fdm | endif]]}},
})

-- Briefly highlight text on yank.
util.augroup('vimrc__highlight_on_yank', {
    {'TextYankPost', {callback =
        function()
            vim.highlight.on_yank {higroup = 'Search'}
        end,
    }},
})

-- Easily open files specified by a glob.
util.user_command(
    'Open',
    function(args)
        local files = vim.fn.glob(args.args, false --[[nosuf]], true --[[list]])

        for _, file in ipairs(files) do
            vim.cmd(string.format('edit %s', file))
        end
    end,
    {nargs = '+'}
)

-- Open all folds the first time a buffer is opened.
util.augroup('vimrc__open_folds', {
    {'BufWinEnter', {callback =
        function()
            if vim.b.vimrc__folds_opened == nil then
                -- Use `vim.schedule` to make it run after other instances of
                -- BufWinEnter.
                vim.schedule(function()
                    if not vim.wo.diff and vim.b.term_title == nil then
                        vim.cmd [[normal! zR]]
                    end
                end)

                vim.b.vimrc__folds_opened = true
            end
        end,
    }},
})

-- Customize <c-l> refresh.
util.map('n', '<c-l>', '<cmd>IndentBlanklineRefresh<cr><c-l>')

-- Yank the results of a command.
util.user_command(
    'YankCommand',
    function(args)
        local old_more = vim.o.more
        vim.o.more = false

        vim.cmd [[redir @"]]
        vim.cmd(args.args)
        vim.cmd [[redir END]]

        vim.o.more = old_more
    end,
    {nargs = 1, complete = 'command'}
)

-- Configure tab size.
util.user_command(
    'SetTabSize',
    function(args)
        local tab_size = tonumber(args.args)

        vim.opt_local.tabstop = tab_size
        vim.opt_local.softtabstop = tab_size
        vim.opt_local.shiftwidth = tab_size
    end,
    {nargs = 1}
)

-- Don't clobber unnamed register.
local function remap_c(command, mode)
    util.map(mode, {expr = true}, command, function()
        if vim.v.register == '"' then
            return '"_' .. command
        else
            return command
        end
    end)
end
remap_c('c', {'n', 'x'})
remap_c('C', 'n')
remap_c('cc', 'n')
util.map('x', 'p', 'P')
util.map('x', 'P', 'p')

-- Convert files with Pandoc.
util.user_command(
    'PandocConvert',
    function(args)
        local file_name
        if util.buffer_is_file() then
            file_name = vim.fn.expand('%')
        else
            local buf_content = vim.api.nvim_buf_get_lines(0 --[[buffer]], 0, -1, true --[[strict_indexing]])
            file_name = vim.fn.tempname()
            vim.fn.writefile(buf_content, file_name)
        end

        local to_extension = args.args
        local output_file = string.format('%s.%s', vim.fn.tempname(), to_extension)

        local output = vim.fn.system({
            'pandoc',
            file_name,
            '-o',
            output_file,
        })
        if vim.v.shell_error ~= 0 then
            util.log_error(string.format('Pandoc command failed: %s', output))
        end

        util.browse_to(output_file)
    end,
    {nargs = 1}
)

-- Make the initial no name buffer disappear when navigated away from.
vim.schedule(function()
    local initial_buf = 1
    if vim.api.nvim_buf_get_name(initial_buf) == '' then
        vim.bo[initial_buf].bufhidden = 'wipe'
    end
end)
