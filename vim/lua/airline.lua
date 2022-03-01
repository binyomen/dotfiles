local M = {}

local util = require 'util'

local current_style = 1
local style_variants = {
    0xe0b0,
    0xe0b4,
    0xe0b8,
    0xe0bc,
    0xe0c0,
    0xe0c4,
}

local function char_to_viml_unicode(char)
    return string.format('\\u%x', char)
end

local function apply_style(style)
    local base_char = style_variants[style]

    -- We need to convert to the VimL syntax for unicode since the Lua syntax
    -- doesn't seem to work.
    local left_sep = char_to_viml_unicode(base_char)
    local left_alt_sep = char_to_viml_unicode(base_char + 1)
    local right_sep = char_to_viml_unicode(base_char + 2)
    local right_alt_sep = char_to_viml_unicode(base_char + 3)

    vim.cmd(string.format('let g:airline_left_sep = "%s"', left_sep))
    vim.cmd(string.format('let g:airline_left_alt_sep = "%s"', left_alt_sep))
    vim.cmd(string.format('let g:airline_right_sep = "%s"', right_sep))
    vim.cmd(string.format('let g:airline_right_alt_sep = "%s"', right_alt_sep))

    util.refresh_airline()
end

function M.next_style()
    -- If we're gonna be messing with styles I guess we should use the fully
    -- patched font.
    vim.opt.guifont = 'UbuntuMono NF:h16'

    if current_style == #style_variants then
        current_style = 1
    else
        current_style = current_style + 1
    end

    apply_style(current_style)
end

util.map('n', '<leader>an', ':lua require("airline").next_style()<cr>')

apply_style(1)

return M
