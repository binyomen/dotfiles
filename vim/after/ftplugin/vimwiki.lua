local util = require 'vimrc.util'

util.map('n', '<leader>wh', '<plug>Vimwiki2HTML', {buffer = true})
util.map('n', '<leader>wb', '<plug>Vimwiki2HTMLBrowse', {buffer = true})
util.map('n', '<leader>wl', '<plug>VimwikiNormalizeLink', {buffer = true})
util.map('x', '<leader>wl', '<plug>VimwikiNormalizeLinkVisual', {buffer = true})
util.map('n', '<leader>wk', vim.fn['vimwiki#base#linkify'], {buffer = true})
util.map('n', '<leader>wt', '<plug>VimwikiToggleListItem', {buffer = true})
util.map('n', '<cr>', '<plug>VimwikiFollowLink', {buffer = true})
util.map('n', '<leader><cr>', '<plug>VimwikiVSplitLink', {buffer = true})
util.map('n', '<leader><leader><cr>', '<plug>VimwikiSplitLink', {buffer = true})
util.map('n', '[h', '<plug>VimwikiGoToPrevHeader', {buffer = true})
util.map('n', ']h', '<plug>VimwikiGoToNextHeader', {buffer = true})
util.map('n', '[=', '<plug>VimwikiGoToPrevSiblingHeader', {buffer = true})
util.map('n', ']=', '<plug>VimwikiGoToNextSiblingHeader', {buffer = true})
util.map('n', '[u', '<plug>VimwikiGoToParentHeader', {buffer = true})
util.map('n', ']u', '<plug>VimwikiGoToParentHeader', {buffer = true})

vim.b.table_mode_corner = '|'
vim.b.table_mode_corner_corner = '|'
vim.b.table_mode_header_fillchar = '-'

vim.b.vimrc__show_word_count = true

vim.bo.textwidth = 80

util.set_tab_size(2)

vim.g.PasteImageFunction = 'g:EmptyPasteImage'
util.map('n', '<leader>p', util.paste_image, {buffer = true, silent = false})
