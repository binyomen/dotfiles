local util = require 'vimrc.util'

util.augroup('vimrc__nospell_file_types', {
    {'FileType', {pattern = 'git,dirvish', callback =
        function()
            vim.wo.spell = false
        end
    }},
})

vim.filetype.add {
    extension = {
        -- XAML and WPRP are basically just XML.
        xaml = 'xml',
        wprp = 'xml',

        hbs = 'html',

        -- I work with tree-sitter queries more than scheme at this point,
        -- although they really should have a different extension....
        scm = 'query',
    },
}
