" vim:fdm=marker

lua require 'impatient'

let mapleader = ','
let maplocalleader = '\\'

lua require('vimrc.local_config').load_configs()

lua require 'vimrc.plugins'

lua require 'vimrc.api_explorer'
lua require 'vimrc.basics'
lua require 'vimrc.clipboard'
lua require 'vimrc.color'
lua require 'vimrc.config'
lua require 'vimrc.buffer'
lua require 'vimrc.filetypes'
lua require 'vimrc.gui'
lua require 'vimrc.misc'
lua require 'vimrc.search'
lua require 'vimrc.statusline'
lua require 'vimrc.style'
lua require 'vimrc.swap'
lua require 'vimrc.terminal'
