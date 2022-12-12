local util = require 'vimrc.util'

util.set_table_style(util.MARKDOWN_STYLE)

vim.b.vimrc__show_word_count = true

vim.bo.textwidth = 80

util.set_tab_size(2)

vim.g.PasteImageFunction = 'g:EmptyPasteImage'
util.map('n', '<leader>p', util.paste_image, {buffer = true, silent = false})
