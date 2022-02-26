-- Inspired by https://github.com/christoomey/vim-system-copy.
--
-- Modified to be in Lua and to use the * register rather than command line
-- tools. This should (hopefully) make it more cross-platform and not require
-- me to install some paste.exe from the internet on all my Windows machines.

local M = {}

local util = require 'util'

local LINE_MOTION = 'line'
local CHAR_MOTION = 'char'
local VISUAL_MOTION = 'v'
local VISUAL_LINE_MOTION = 'V'
local VISUAL_BLOCK_MOTION = ''

local function is_visual_motion(motion)
    return
        motion == VISUAL_MOTION or
        motion == VISUAL_LINE_MOTION or
        motion == VISUAL_BLOCK_MOTION
end

function M.copy(motion)
    local command
    if motion == LINE_MOTION then
        command = string.format(
            'silent %d,%dy *',
            vim.fn.line("'["),
            vim.fn.line("']")
        )
    elseif motion == CHAR_MOTION then
        command = 'silent normal! `[v`]"*y'
    elseif is_visual_motion(motion) then
        command = string.format('silent normal! `<%s`>"*y', motion)
    else
        error(string.format('Invalid motion: %s', motion))
    end

    vim.cmd(command)
end

vim.cmd [[
    function! __clipboard__copy_opfunc(motion) abort
        execute 'lua require("clipboard").copy("' . a:motion . '")'
    endfunction
]]

function M.paste(motion)
    local command
    if motion == LINE_MOTION then
        -- First delete the lines.
        vim.cmd(string.format(
            'silent %d,%dd',
            vim.fn.line("'["),
            vim.fn.line("']")
        ))

        command = 'normal! "*P'
    elseif motion == CHAR_MOTION then
        command = 'normal! `[v`]"*p'
    elseif is_visual_motion(motion) then
        command = string.format('normal! `<%s`>"*p', motion)
    else
        error(string.format('Invalid motion: %s', motion))
    end

    vim.cmd(command)
end

vim.cmd [[
    function! __clipboard__paste_opfunc(motion) abort
        execute 'lua require("clipboard").paste("' . a:motion . '")'
    endfunction
]]

function M.paste_line()
  vim.cmd 'put *'
end

util.map('x', 'cy', ':lua require("clipboard").copy(vim.fn.visualmode())<cr>')
util.map('n', 'cy', ':set opfunc=__clipboard__copy_opfunc<cr>g@')
util.map('n', 'cY', ':set opfunc=__clipboard__copy_opfunc | execute "normal! " . v:count1 . "g@_"<cr>')
util.map('x', 'cp', ':lua require("clipboard").paste(vim.fn.visualmode())<cr>')
util.map('n', 'cp', ':set opfunc=__clipboard__paste_opfunc<cr>g@')
util.map('n', 'cP', ':lua require("clipboard").paste_line()<cr>')

return M
