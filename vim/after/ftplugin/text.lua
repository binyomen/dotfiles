local util = require 'vimrc.util'

vim.wo.wrap = true
vim.wo.linebreak = true

util.map({'n', 'x', 'o'}, 'k', 'gk', {buffer = true})
util.map({'n', 'x', 'o'}, 'j', 'gj', {buffer = true})
util.map({'n', 'x', 'o'}, '0', 'g0', {buffer = true})
util.map({'n', 'x', 'o'}, '$', 'g$', {buffer = true})
util.map({'n', 'x', 'o'}, '^', 'g^', {buffer = true})
util.map({'n', 'x', 'o'}, 'H', 'g^', {buffer = true})
util.map({'n', 'x', 'o'}, 'L', 'g$', {buffer = true})
