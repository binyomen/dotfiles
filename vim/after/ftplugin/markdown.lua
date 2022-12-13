local util = require 'vimrc.util'

vim.bo.textwidth = 80
util.set_tab_size(2)
util.enable_conceal_if_not_in_diff()

vim.b.vimrc__show_word_count = true

util.map('n', '<leader>p', util.paste_image, {buffer = true, silent = false})

util.set_table_style(util.MARKDOWN_STYLE)

util.map('n', '<cr>', vim.lsp.buf.definition, {buffer = true})

vim.schedule(function()
    vim.fn['textobj#quote#init']()
end)

require('vimrc.markdown').init_in_buffer()
