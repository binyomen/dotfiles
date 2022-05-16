local util = require 'vimrc.util'

require('nvim-treesitter.configs').setup {
    ensure_installed = {'lua'},
    highlight = {enable = true},
    indent = {enable = true},
    textobjects = {
        select = {
            enable = true,
            keymaps = {
                ['if'] = '@function.inner',
                ['af'] = '@function.outer',
            },
        },
    },
}

util.augroup('vimrc__treesitter_buffers', {
    {'BufWinEnter', {callback =
        function(args)
            if vim.b.vimrc__treesitter_folding_set then
                return
            end
            vim.b.vimrc__treesitter_folding_set = true

            if require('vim.treesitter.highlighter').active[args.buf] then
                vim.wo.foldmethod = 'expr'
                vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
            else
                vim.wo.foldmethod = 'syntax'
                vim.wo.foldexpr = ''
            end
        end,
    }},
})
