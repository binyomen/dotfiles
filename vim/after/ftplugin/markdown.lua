local util = require 'vimrc.util'

vim.bo.textwidth = 80

util.set_tab_size(2)

util.enable_conceal()

vim.b.vimrc__show_word_count = true

util.map('n', '<leader>p', util.paste_image, {buffer = true, silent = false})

vim.b.table_mode_corner = '|'
vim.b.table_mode_corner_corner = '|'
vim.b.table_mode_header_fillchar = '-'

util.map('n', '<cr>', vim.lsp.buf.definition, {buffer = true})

require('vimrc.markdown').init_in_buffer()
