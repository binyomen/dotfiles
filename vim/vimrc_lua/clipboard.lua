-- Inspired by https://github.com/christoomey/vim-system-copy.
--
-- Modified to be in Lua and to use the * register rather than command line
-- tools. This should (hopefully) make it more cross-platform and not require
-- me to install some paste.exe from the internet on all my Windows machines.

local util = require 'vimrc.util'

local copy = util.new_operator(function(motion)
    util.opfunc_normal_command(motion, '"*y')
end)

local paste = util.new_operator(function(motion)
    util.opfunc_normal_command(motion, '"*p')
end)

local function paste_before()
    vim.cmd(string.format([[normal! "*%dP]], vim.v.count1))
end

local function paste_after()
    vim.cmd(string.format([[normal! "*%dp]], vim.v.count1))
end

local function paste_line()
    for _ = 1,vim.v.count1 do
        vim.cmd [[put *]]
    end
end

util.map({'n', 'x'}, 'cy', copy, {expr = true})
util.map('n', 'cY', function() return copy() .. '_' end, {expr = true})
util.map({'n', 'x'}, 'cp', paste, {expr = true})
util.map('n', 'cpP', paste_before)
util.map('n', 'cpp', paste_after)
util.map('n', 'cP', paste_line)
