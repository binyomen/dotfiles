local M = {}

local util = require 'util'

-- Swap current character with next and previous.
util.map('n', '<leader>sc', [[xph]])
util.map('n', '<leader>sC', [[xhPl]])

-- Swap last delected text with the currently selected text.
-- https://vim.fandom.com/wiki/Swapping_characters,_words_and_lines
util.map('x', 'gx', [[<esc>`.``gvP``P``]])

return M
