local M = {}

local util = require 'util'

local current_theme = 1
local themes = {
    {'NeoSolarized', 'solarized'},
    {'gruvbox', 'base16_gruvbox_dark_hard'},
    {'molokai', 'molokai'},
    {'onedark', 'onedark'},
    {'papercolor', 'papercolor'},
    {'nord', 'nord'},
    {'iceberg', 'nord'},
}

util.map('n', '<leader>ns', ':lua require("style").next_theme()<cr>')

function M.next_theme()
    if current_theme == #themes then
        current_theme = 1
    else
        current_theme = current_theme + 1
    end

    vim.cmd(string.format('colorscheme %s', themes[current_theme][1]))
    vim.g.airline_theme = themes[current_theme][2]

    util.refresh_airline()

    print(string.format('Switched to theme %s.', themes[current_theme][1]))
end

return M
