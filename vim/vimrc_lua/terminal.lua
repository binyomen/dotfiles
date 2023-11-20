local util = require 'vimrc.util'

-- Use pwsh on Windows.
if util.vim_has('win32') then
    util.enable_pwsh()
end

util.augroup('vimrc__terminal', {
    {'TermOpen', {callback =
        function()
            -- Use `opt_local` rather than `wo` to properly mimic the behavior
            -- of `:setlocal`. Otherwise all buffers opened in the same window
            -- as the terminal after the terminal is opened will also have
            -- spellchecking disabled.
            vim.opt_local.spell = false
        end
    }},
})

