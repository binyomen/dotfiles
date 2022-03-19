local M = {}

local util = require 'util'

-- Swap last delected text with the currently selected text.
-- https://vim.fandom.com/wiki/Swapping_characters,_words_and_lines
util.map('x', 'gx', [[<esc>`.``gvP``P``]])

return M
