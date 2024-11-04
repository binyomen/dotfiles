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
    vim.wo[0][0].spell = not vim.wo[0][0].spell
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

    -- This may throw in higher verbosity levels (e.g. with command line
    -- argument -V1).
    local succeeded, cursor_word = pcall(vim.fn.expand, '<cword>')
    if not succeeded or cursor_word == '' then
        return
    end

    local escaped_word = vim.fn.escape(cursor_word, [[\/]])
    local pattern = string.format([[\V\<%s\>]], escaped_word)

    vim.w.vimrc__cursor_highlight_match_id = vim.fn.matchadd('vimrc__CursorOver', pattern)
end

local cursor_word_enabled
local function enable_cursor_word()
    util.augroup('vimrc__highlight_word_under_cursor', {
        {{'CursorMoved', 'CursorMovedI'}, {callback = highlight_word_under_cursor}},
        {{'WinLeave', 'TermEnter'}, {callback = clear_cursor_highlight}},
    })
    highlight_word_under_cursor()
    cursor_word_enabled = true
end
local function disable_cursor_word()
    vim.api.nvim_del_augroup_by_name('vimrc__highlight_word_under_cursor')
    clear_cursor_highlight()
    cursor_word_enabled = false
end

enable_cursor_word()

util.map('n', 'c<space>', function()
    if cursor_word_enabled then
        disable_cursor_word()
    else
        enable_cursor_word()
    end
end)

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
    local old_errorformat = vim.o.errorformat
    vim.o.errorformat = ''

    local function append_errorformat(format)
        -- `vim.opt` seems to be broken when appending for errorformat. Use
        -- `vim.o` instead.
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
    {nargs = '+', complete = 'file'}
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
        util.set_tab_size(tab_size)
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

-- Disable conceal in diff mode.
util.augroup('vimrc__no_conceal_in_diff', {
    {'OptionSet', {pattern = 'diff', callback =
        function()
            if vim.wo.diff then
                if vim.wo.conceallevel == 2 then
                    vim.w.vimrc__reenable_conceal_when_diff_disabled = true
                else
                    vim.w.vimrc__reenable_conceal_when_diff_disabled = false
                end

                vim.wo[0][0].conceallevel = 0
            elseif vim.w.vimrc__reenable_conceal_when_diff_disabled then
                vim.wo[0][0].conceallevel = 2
                vim.w.vimrc__reenable_conceal_when_diff_disabled = nil
            end
        end,
    }},
})

-- Insert the title of a URL into the given register.
if util.vim_has('linux') then
    local COMMAND = [[wget -qO- '%s' | perl -l -0777 -ne 'print $1 if /<title.*?>\s*(.*?)\s*<\/title/si' | recode html..]]
    util.map('n', '<leader>ut', function()
        local url = vim.fn.expand('<cfile>')
        if url == '' then
            return
        end

        local title = vim.trim(vim.fn.system(string.format(COMMAND, url)))
        vim.fn.setreg(vim.v.register, title, 'v')
    end)
end

-- Sort using a motion.
util.map({'n', 'x'}, {expr = true}, '<leader>so', util.new_operator(function()
    util.opfunc_ex_command {cmd = 'sort'}
end))

-- Set all buffers to their relative paths.
local function relativize_buffer(previous_buf, buf)
    if util.buffer_is_file(buf) then
        local name = vim.api.nvim_buf_get_name(buf)
        local relative_name = util.relative_path(name)
        vim.api.nvim_buf_set_name(buf, relative_name)

        -- Editing the file in place will enable you to write it
        -- without needing a bang.
        vim.api.nvim_set_current_buf(buf)
        vim.cmd.edit()
        vim.api.nvim_set_current_buf(previous_buf)
    end
end
util.user_command(
    'RelativizeBuffersInternal',
    function()
        local previous_buf = vim.api.nvim_get_current_buf()
        local bufs = util.filter(vim.api.nvim_list_bufs(), function(buf)
            return vim.api.nvim_buf_is_loaded(buf) and vim.fn.buflisted(buf) ~= 0
        end)
        for _, buf in ipairs(bufs) do
            relativize_buffer(previous_buf, buf)
        end
    end,
    {nargs = 0}
)
util.user_command(
    'RelativizeBufferInternal',
    function()
        local buf = vim.api.nvim_get_current_buf()
        relativize_buffer(buf, buf)
    end,
    {nargs = 0}
)
util.user_command('RelativizeBuffers', 'keepalt RelativizeBuffersInternal', {nargs = 0})
util.user_command('RelativizeBuffer', 'keepalt RelativizeBufferInternal', {nargs = 0})
