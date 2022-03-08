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

local function do_normal_command(motion, normal_command)
    local command
    if motion == LINE_MOTION then
        command = string.format("silent normal! '[V']%s", normal_command)
    elseif motion == CHAR_MOTION then
        command = string.format('silent normal! `[v`]%s', normal_command)
    elseif is_visual_motion(motion) then
        command = string.format('silent normal! `<%s`>%s', motion, normal_command)
    else
        error(string.format('Invalid motion: %s', motion))
    end

    vim.cmd(command)
end

function M.copy(motion)
    do_normal_command(motion, '"*y')
end

vim.cmd [[
    function! __clipboard__copy_opfunc(motion) abort
        execute 'lua require("clipboard").copy("' . a:motion . '")'
    endfunction
]]

function M.paste(motion)
    do_normal_command(motion, '"*p')
end

vim.cmd [[
    function! __clipboard__paste_opfunc(motion) abort
        execute 'lua require("clipboard").paste("' . a:motion . '")'
    endfunction
]]

function M.paste_before()
    vim.cmd [[normal! "*P]]
end

function M.paste_after()
    vim.cmd [[normal! "*p]]
end

function M.paste_line()
  vim.cmd 'put *'
end

util.map('x', 'cy', ':lua require("clipboard").copy(vim.fn.visualmode())<cr>')
util.map('n', 'cy', ':set opfunc=__clipboard__copy_opfunc<cr>g@')
util.map('n', 'cY', ':set opfunc=__clipboard__copy_opfunc | execute "normal! " . v:count1 . "g@_"<cr>')
util.map('x', 'cp', ':lua require("clipboard").paste(vim.fn.visualmode())<cr>')
util.map('n', 'cp', ':set opfunc=__clipboard__paste_opfunc<cr>g@')
util.map('n', 'cpP', ':lua require("clipboard").paste_before()<cr>')
util.map('n', 'cpp', ':lua require("clipboard").paste_after()<cr>')
util.map('n', 'cP', ':lua require("clipboard").paste_line()<cr>')

return M
