local M = {}

local util = require 'util'

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

util.map('n', '<leader>ns', ':lua require("style").next_theme()<cr>')

function M.next_theme()
    if current_theme == #themes then
        current_theme = 1
    else
        current_theme = current_theme + 1
    end

    local theme = themes[current_theme]
    vim.cmd(string.format('colorscheme %s', theme))
    print(string.format('Switched to theme %s.', theme))
end

return M
