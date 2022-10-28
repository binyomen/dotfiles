local util = require 'vimrc.util'

util.augroup('vimrc__rustfmt', {
    {'BufWritePre', {buffer = 0, callback =
        function()
            vim.lsp.buf.format()
        end
    }},
})
