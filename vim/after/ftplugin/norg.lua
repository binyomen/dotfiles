local util = require 'vimrc.util'

vim.b.table_mode_corner = '|'
vim.b.table_mode_corner_corner = '|'
vim.b.table_mode_header_fillchar = '-'

vim.b.vimrc__show_word_count = true

vim.bo.textwidth = 79

util.set_tab_size(2)

vim.g.PasteImageFunction = 'g:EmptyPasteImage'
util.map('n', '<leader>p', util.paste_image, {buffer = true, silent = false})
