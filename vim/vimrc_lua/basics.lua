local util = require 'vimrc.util'

-- Normal and visual mode
util.map({'n', 'x'}, '<space>', ':', {silent = false}) -- Remap space to : in normal and visual mode for ease of use.
util.map({'n', 'x'}, '<bs>', '<cmd>update<cr>') -- Remap backspace to save in normal and visual mode.

-- Insert mode
util.map('i', 'uu', '<esc>') -- Use uu to exit insert mode.
util.map('i', 'hh', '<esc><cmd>update<cr>') -- Use hh to exit insert mode and save.
util.map('i', '<c-h>', '<cmd>update<cr>') -- Use ctrl+h to save while in insert mode.
util.map('i', '<c-d>', '<c-x><c-f><c-n>') -- Make file completion easier.
util.map('i', '<c-c>', '<c-x><c-n><c-n>') -- Make context-aware word completion easier.

-- Movement
util.map('', 'H', '^') -- H moves to first non-blank character of line.
util.map('', 'L', 'g_') -- L moves to last non-blank character of line.
util.map('', ':', ',') -- Move background for f and t even with , as the leader key.
util.map('', '<leader>h', 'H') -- Move the cursor to the top of the screen.
util.map('', '<leader>m', 'M') -- Move the cursor to the middle of the screen.
util.map('', '<leader>l', 'L') -- Move the cursor to the bottom of the screen.
util.map('', [[`]], [[']]) -- Swap ` and ' since one is easier to hit than the other.
util.map('', [[']], [[`]]) -- Swap ` and ' since one is easier to hit than the other.

-- Scrolling
util.map('n', '<c-h>', '<c-e>') -- Scroll down.
util.map('n', '<c-n>', '<c-y>') -- Scroll up.

-- Buffers
util.map('n', 'M', '<c-^>') -- Remap <c-^> to M, which has more editor support.
util.map('n', '<leader>r', '<cmd>edit<cr>') -- Use <leader>r to reload the buffer with :edit.

-- Windows
util.map('n', '<leader>t', '<c-w>')
util.map('n', '+', '<c-w>>')
util.map('n', '-', '<c-w><')
util.map('n', '<c-=>', '<c-w>+')
util.map('n', '<c-->', '<c-w>-')

-- Options
-- Tabs
vim.opt.expandtab = true -- Tabs are expanded to spaces.
vim.opt.tabstop = 4 -- Tabs count as 4 spaces.
vim.opt.softtabstop = 4 -- Tabs count as 4 spaces while performing editing operations (yeah, I don't really understand this either).
vim.opt.shiftwidth = 4 -- Number of spaces used for autoindent.
vim.opt.shiftround = true -- Should round indents to multiple of shiftwidth.
-- Show whitespace
vim.opt.list = true -- Display whitespace characters.
vim.opt.listchars = {tab = '>.', trail = '.', extends = '#', nbsp = '.'} -- Specify which whitespace characters to display.
-- UI
vim.opt.number = true -- Show line numbers.
vim.opt.relativenumber = true -- Show relative line numbers.
vim.opt.title = true -- Title of window set to titlename/currently edited file.
vim.opt.visualbell = true -- Use visual bell instead of beeping.
vim.opt.colorcolumn = {80, 120} -- Highlight the 80th and 120th columns for better line-length management.
vim.opt.cursorline = true -- Highlight the current line.
vim.opt.cursorcolumn = true -- Highlight the current column.
vim.opt.wildmode = {'longest', 'full'} -- In command line, first <tab> press complete to longest common string, next show full match.
vim.opt.lazyredraw = true -- Don't redraw the screen while executing mappings and commands.
vim.opt.wildignore:append('.git') -- Ignore the .git directory when expanding wildcards.
vim.opt.scrolloff = 2
vim.opt.sidescrolloff = 3
vim.opt.splitright = true
vim.opt.splitbelow = true
-- Editing
vim.opt.wrap = false -- Don't wrap lines.
vim.opt.showmatch = true -- Show matching bracket when one is inserted.
vim.opt.foldmethod = 'syntax' -- Fold based on the language syntax (e.g. #region tags).
vim.opt.fileformats = {'unix', 'dos'} -- Set Unix line endings as the default.
vim.opt.diffopt:append('vertical') -- Always open diffs in vertical splits.
vim.opt.timeout = false -- Don't time out waiting for mappings.
