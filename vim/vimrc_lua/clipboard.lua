-- Inspired by https://github.com/christoomey/vim-system-copy.
--
-- Modified to be in Lua and to use the * register rather than command line
-- tools. This should (hopefully) make it more cross-platform and not require
-- me to install some paste.exe from the internet on all my Windows machines.

local util = require 'vimrc.util'

local copy_operator = util.new_operator(function(motion)
    util.opfunc_normal_command(motion, '"*y')
end)

-- Copy.
util.map({'n', 'x'}, 'cy', copy_operator, {expr = true})
util.map('n', 'cY', function() return copy_operator() .. '_' end, {expr = true})

-- Paste.
util.map({'n', 'x'}, {expr = true}, 'cp', util.new_operator(function(motion)
    util.opfunc_normal_command(motion, '"*p')
end))

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
