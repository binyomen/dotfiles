local M = {}

-- Many commands here are taken from
-- https://vim.fandom.com/wiki/Swapping_characters,_words_and_lines, with
-- modifications by me.
--
-- The trick for forncing undo to restore the cursor position (see
-- "aa<bs><esc>" in the mappings) is from
-- https://vim.fandom.com/wiki/Restore_the_cursor_position_after_undoing_text_change_made_by_a_script.

local util = require 'util'

-- Swap current character with next and previous, keeping the cursor in the
-- same place.
util.map('n', '<leader>sc', [[xph]])
util.map('n', '<leader>sC', [[xhPl]])

-- Swap current word with the next and previous, keeping the cursor in the same place.
util.map('n', '<leader>sw', [["_yiwaa<bs><esc>:s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/g<cr>``]])
util.map('n', '<leader>sW', [["_yiwmzaa<bs><esc>?\w\+\_W\+\%#<cr>:s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/g<cr>`z]])

-- Push the current word to the left or right.
util.map('n', '<leader>sl', [["_yiwaa<bs><esc>?\w\+\_W\+\%#<cr>:s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/<cr>``]])
util.map('n', '<leader>sr', [["_yiwaa<bs><esc>:s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/<cr>``/\w\+\_W\+<cr>]])

-- Swap last delected text with the currently selected text.
-- https://vim.fandom.com/wiki/Swapping_characters,_words_and_lines
util.map('x', 'gx', [[<esc>`.``gvP``P``]])

return M
