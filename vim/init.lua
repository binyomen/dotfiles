require 'impatient'

vim.g.mapleader = ','
vim.g.maplocalleader = '\\'

require('vimrc.local_config').load_configs()

if LOCAL_CONFIG.on_config_start then
    LOCAL_CONFIG.on_config_start()
end

require 'vimrc.plugins'

require 'vimrc.api_explorer'
require 'vimrc.basics'
require 'vimrc.buffer'
require 'vimrc.clipboard'
require 'vimrc.color'
require 'vimrc.config'
require 'vimrc.diff'
require 'vimrc.filetypes'
require 'vimrc.find'
require 'vimrc.gui'
require 'vimrc.misc'
require 'vimrc.search'
require 'vimrc.statusline'
require 'vimrc.style'
require 'vimrc.swap'
require 'vimrc.terminal'

if LOCAL_CONFIG.on_config_end then
    LOCAL_CONFIG.on_config_end()
end
