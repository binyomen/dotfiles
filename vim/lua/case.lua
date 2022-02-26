local M = {}

local util = require 'util'

local LINE_MOTION = 'line'
local CHAR_MOTION = 'char'

local function do_normal_command(motion, normal_command)
    local command
    if motion == LINE_MOTION then
        command = string.format("silent normal! '[V']%s", normal_command)
    elseif motion == CHAR_MOTION then
        command = string.format('silent normal! `[v`]%s', normal_command)
    else
        error(string.format('Invalid motion: %s', motion))
    end

    vim.cmd(command)
end

function M.lowercase(motion)
    do_normal_command(motion, 'u')
end

vim.cmd [[
    function! __clipboard__lowercase_opfunc(motion) abort
        execute 'lua require("case").lowercase("' . a:motion . '")'
    endfunction
]]

function M.uppercase(motion)
    do_normal_command(motion, 'U')
end

vim.cmd [[
    function! __clipboard__uppercase_opfunc(motion) abort
        execute 'lua require("case").uppercase("' . a:motion . '")'
    endfunction
]]

util.map('n', '<leader>cu', ':set opfunc=__clipboard__lowercase_opfunc<cr>g@')
util.map('n', '<leader>cU', ':set opfunc=__clipboard__uppercase_opfunc<cr>g@')

return M
