-- Inspired by https://github.com/christoomey/vim-system-copy.
--
-- Modified to be in Lua and to use the * register rather than command line
-- tools. This should (hopefully) make it more cross-platform and not require
-- me to install some paste.exe from the internet on all my Windows machines.

local util = require 'vimrc.util'

-- Copy.
local copy_operator = util.new_operator(function(motion)
    util.opfunc_normal_command(motion, '"*y')
    util.opfunc_normal_command(motion, '"+y')
end)
util.map('n', 'cy', copy_operator, {expr = true})
util.map('x', 'Cy', copy_operator, {expr = true})
util.map('n', 'cY', function() return copy_operator() .. '_' end, {expr = true})

-- Paste.
local paste_operator = util.new_operator(function(motion)
    util.opfunc_normal_command(motion, '"*p')
end)
util.map('n', {expr = true}, 'cp', paste_operator)
util.map('x', {expr = true}, 'Cp', paste_operator)

-- Paste before.
util.map('n', 'cpP', function()
    vim.cmd(string.format([[normal! "*%dP]], vim.v.count1))
end)

-- Paste after.
util.map('n', 'cpp', function()
    vim.cmd(string.format([[normal! "*%dp]], vim.v.count1))
end)

-- Paste line.
util.map('n', 'cP', function()
    for _ = 1,vim.v.count1 do
        vim.cmd [[put *]]
    end
end)
