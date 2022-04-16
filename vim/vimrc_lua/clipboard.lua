-- Inspired by https://github.com/christoomey/vim-system-copy.
--
-- Modified to be in Lua and to use the * register rather than command line
-- tools. This should (hopefully) make it more cross-platform and not require
-- me to install some paste.exe from the internet on all my Windows machines.

local M = {}

local util = require 'vimrc.util'

local function do_normal_command(motion, normal_command)
    local command

    util.process_opfunc_command(motion, {
        line = function()
            command = string.format([[silent normal! '[V']%s]], normal_command)
        end,
        char = function()
            command = string.format([[silent normal! `[v`]%s]], normal_command)
        end,
        block = function()
            command = string.format(t[[silent normal! `[<c-v>`]%s]], normal_command)
        end,
        visual = function()
            command = string.format([[silent normal! `<%s`>%s]], motion, normal_command)
        end,
    })

    vim.cmd(command)
end

M.copy = util.new_operator(function(motion)
    do_normal_command(motion, '"*y')
end)

M.paste = util.new_operator(function(motion)
    do_normal_command(motion, '"*p')
end)

function M.paste_before()
    vim.cmd(string.format([[normal! "*%dP]], vim.v.count1))
end

function M.paste_after()
    vim.cmd(string.format([[normal! "*%dp]], vim.v.count1))
end

function M.paste_line()
    for _ = 1,vim.v.count1 do
        vim.cmd [[put *]]
    end
end

util.map('x', 'cy', [[:lua require('vimrc.clipboard').copy(vim.fn.visualmode())<cr>]])
util.map('n', 'cy', [[v:lua.require('vimrc.clipboard').copy()]], {expr = true})
util.map('n', 'cY', [[v:lua.require('vimrc.clipboard').copy() . '_']], {expr = true})
util.map('x', 'cp', [[:lua require('vimrc.clipboard').paste(vim.fn.visualmode())<cr>]])
util.map('n', 'cp', [[v:lua.require('vimrc.clipboard').paste()]], {expr = true})
util.map('n', 'cpP', [[<cmd>lua require('vimrc.clipboard').paste_before()<cr>]])
util.map('n', 'cpp', [[<cmd>lua require('vimrc.clipboard').paste_after()<cr>]])
util.map('n', 'cP', [[<cmd>lua require('vimrc.clipboard').paste_line()<cr>]])

return M
