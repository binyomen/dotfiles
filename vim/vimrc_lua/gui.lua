local util = require 'vimrc.util'

local font_name
local font_size

local function validate_font()
    if type(font_name) ~= 'string' then
        error(string.format(
            [[font_name '%s' must be a string. Instead it's a %s.]],
            font_name,
            type(font_name)
        ))
    end

    if type(font_size) ~= 'number' then
        error(string.format(
            [[font_size '%s' must be a number. Instead it's a %s.]],
            font_size,
            type(font_size)
        ))
    end
end

local function update_font()
    validate_font()
    vim.opt.guifont = string.format('%s:h%d', font_name, font_size)
end

local function defer_font_size_print()
    -- We need to wait to print this, size the resize will clear echo output.
    util.defer(200, function()
        util.echo(string.format('Font size now %d', font_size), true --[[add_to_history]])
    end)
end

-- Increment font size.
util.map('n', '<m-up>', function()
    font_size = font_size + 1
    update_font()
    defer_font_size_print()
end)

-- Decrement font size.
util.map('n', '<m-down>', function()
    font_size = font_size - 1
    update_font()
    defer_font_size_print()
end)

-- fvim
if util.vim_true(vim.g.fvim_loaded) then
    -- Toggle between normal and fullscreen.
    util.map('n', '<a-cr>', '<cmd>FVimToggleFullScreen<cr>')

    -- Cursor tweaks.
    vim.cmd [[FVimCursorSmoothMove v:true]]
    vim.cmd [[FVimCursorSmoothBlink v:false]]

    -- Background composition.
    -- FVimBackgroundComposition 'acrylic'   " 'none', 'blur' or 'acrylic'
    -- FVimBackgroundOpacity 0.85            " value between 0 and 1, default bg opacity.
    -- FVimBackgroundAltOpacity 0.85         " value between 0 and 1, non-default bg opacity.
    -- FVimBackgroundImage 'C:/foobar.png'   " background image
    -- FVimBackgroundImageVAlign 'center'    " vertial position, 'top', 'center' or 'bottom'
    -- FVimBackgroundImageHAlign 'center'    " horizontal position, 'left', 'center' or 'right'
    -- FVimBackgroundImageStretch 'fill'     " 'none', 'fill', 'uniform', 'uniformfill'
    -- FVimBackgroundImageOpacity 0.85       " value between 0 and 1, bg image opacity

    -- Title bar tweaks.
    -- FVimCustomTitleBar v:false             " themed with colorscheme

    -- Debug UI overlay.
    vim.cmd [[FVimDrawFPS v:false]]

    -- Font tweaks.
    vim.cmd [[FVimFontAntialias v:true]]
    vim.cmd [[FVimFontAutohint v:true]]
    vim.cmd [[FVimFontHintLevel 'full']]
    vim.cmd [[FVimFontLigature v:true]]
    -- FVimFontLineHeight '+1.0' " can be 'default', '14.0', '-1.0' etc.
    vim.cmd [[FVimFontSubpixel v:true]]
    -- FVimFontNoBuiltInSymbols v:true " Disable built-in Nerd font symbols

    -- Try to snap the fonts to the pixels, reduces blur in some situations
    -- (e.g. 100% DPI).
    vim.cmd [[FVimFontAutoSnap v:true]]

    -- Font weight tuning, possible valuaes are 100..900.
    -- FVimFontNormalWeight 400
    -- FVimFontBoldWeight 700

    -- Font debugging -- draw bounds around each glyph.
    vim.cmd [[FVimFontDrawBounds v:false]]

    -- UI options.
    -- FVimUIMultiGrid v:false     " per-window grid system -- work in progress
    -- FVimUIPopupMenu v:false      " external popup menu
    -- FVimUITabLine v:false       " external tabline -- not implemented
    -- FVimUICmdLine v:false       " external cmdline -- not implemented
    -- FVimUIWildMenu v:false      " external wildmenu -- not implemented
    -- FVimUIMessages v:false      " external messages -- not implemented
    -- FVimUITermColors v:false    " not implemented
    -- FVimUIHlState v:false       " not implemented

    -- Detach from a remote session without killing the server If this command
    -- is executed on a standalone instance, the embedded process will be
    -- terminated anyway.
    -- FVimDetach
end

-- firenvim
if util.vim_true(vim.g.started_by_firenvim) then
    vim.opt.number = false
    vim.opt.relativenumber = false
    vim.opt.wrap = true

    -- Initialize a default config to never take over the text area
    -- automatically.
    local config = {
        localSettings = {
            ['.*'] = { takeover = 'never' },
        },
    }
    vim.g.firenvim_config = config
end

-- neovide
if util.vim_true(vim.g.neovide) then
    font_name = 'Fira Code'
    font_size = 12
    update_font()

    -- Make neovide fullscreen.
    util.map('n', '<a-cr>', function()
        vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
        vim.fn.NeovideNotifyfullscreenChanged(nil, nil, nil)
    end)
end
