local M = {}

local util = require 'vimrc.util'

util.map('i', 'uu', '<esc>') -- Use uu to exit insert mode.
util.map('i', 'hh', '<esc><cmd>update<cr>') -- Use hh to exit insert mode and save.
util.map('i', '<c-h>', '<cmd>update<cr>') -- Use ctrl+h to save while in insert mode.
util.map('n', '<space>', ':', {silent = false}) -- Remap space to : in normal mode for ease of use.
util.map('v', '<space>', ':', {silent = false}) -- Remap space to : in visual mode for ease of use.
util.map('n', '<bs>', '<cmd>update<cr>') -- Remap backspace to save in normal mode.
util.map('v', '<bs>', '<cmd>update<cr>') -- Remap backspace to save in visual mode.

util.map('i', '<c-t>', [[pumvisible() ? "\<c-n>" : "\<c-x>\<c-o>"]], {expr = true}) -- Easier omnifunc mapping.

util.map('i', '<c-d>', '<c-x><c-f>') -- Make file completion easier.
util.map('i', '<c-c>', '<c-x><c-n>') -- Make context-aware word completion easier.

return M
