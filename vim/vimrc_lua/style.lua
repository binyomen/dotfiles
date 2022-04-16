local util = require 'vimrc.util'

local current_theme = 1
local themes = {
    'PaperColor',
    'NeoSolarized',
    'molokai',
    'onedark',
    'nord',
    'iceberg',
    'one',
    'OceanicNext',
    'palenight',
    'onehalfdark',
}

util.map('n', '<leader>ns', function()
    if current_theme == #themes then
        current_theme = 1
    else
        current_theme = current_theme + 1
    end

    local theme = themes[current_theme]
    vim.cmd(string.format('colorscheme %s', theme))
    util.echo(string.format('Switched to theme %s.', theme))
end)
