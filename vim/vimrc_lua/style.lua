local util = require 'vimrc.util'

local current_theme = 1
local themes = {
    {name = 'PaperColor', plugin = 'papercolor-theme'},
    {name = 'NeoSolarized', plugin = 'NeoSolarized'},
    {name = 'molokai', plugin = 'molokai'},
    {name = 'onedark', plugin = 'onedark.vim'},
    {name = 'nord', plugin = 'nord-vim'},
    {name = 'iceberg', plugin = 'iceberg.vim'},
    {name = 'one', plugin = 'vim-one'},
    {name = 'OceanicNext', plugin = 'oceanic-next'},
    {name = 'palenight', plugin = 'palenight.vim'},
    {name = 'onehalfdark', plugin = 'onehalf'},
}

util.map('n', '<leader>ns', function()
    if current_theme == #themes then
        current_theme = 1
    else
        current_theme = current_theme + 1
    end

    local theme = themes[current_theme]
    vim.cmd(string.format('packadd %s', theme.plugin))
    vim.cmd(string.format('colorscheme %s', theme.name))
    util.echo(string.format('Switched to theme %s.', theme.name))
end)
