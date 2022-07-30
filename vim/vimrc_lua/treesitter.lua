local util = require 'vimrc.util'

require('nvim-treesitter.configs').setup {
    ensure_installed = {
        'cpp',
        'css',
        'fish',
        'html',
        'javascript',
        'json',
        'lua',
        'markdown',
        'markdown_inline',
        'python',
        'toml',
        'typescript',
        'vim',
        'yaml',
    },
    highlight = {enable = true},
    indent = {enable = true},
    textobjects = {
        select = {
            enable = true,
            keymaps = {
                ['isa'] = '@attribute.inner',
                ['asa'] = '@attribute.outer',
                ['isb'] = '@block.inner',
                ['asb'] = '@block.outer',
                ['isC'] = '@call.inner',
                ['asC'] = '@call.outer',
                ['isc'] = '@class.inner',
                ['asc'] = '@class.outer',
                ['as/'] = '@comment.outer',
                ['isi'] = '@conditional.inner',
                ['asi'] = '@conditional.outer',
                ['isF'] = '@frame.inner',
                ['asF'] = '@frame.outer',
                ['isf'] = '@function.inner',
                ['asf'] = '@function.outer',
                ['isl'] = '@loop.inner',
                ['asl'] = '@loop.outer',
                ['isp'] = '@parameter.inner',
                ['asp'] = '@parameter.outer',
                ['isS'] = '@scopename.inner',
                ['ass'] = '@statement.outer',
            },
            selection_modes = {
                ['@attribute.inner'] = 'v',
                ['@attribute.outer'] = 'v',
                ['@block.inner'] = 'V',
                ['@block.outer'] = 'V',
                ['@call.inner'] = 'v',
                ['@call.outer'] = 'v',
                ['@class.inner'] = 'V',
                ['@class.outer'] = 'V',
                ['@comment.outer'] = 'V',
                ['@conditional.inner'] = 'V',
                ['@conditional.outer'] = 'V',
                ['@frame.inner'] = 'V',
                ['@frame.outer'] = 'V',
                ['@function.inner'] = 'V' ,
                ['@function.outer'] = 'V',
                ['@loop.inner'] = 'V',
                ['@loop.outer'] = 'V',
                ['@parameter.inner'] = 'v',
                ['@parameter.outer'] = 'v',
                ['@scopename.inner'] = 'v',
                ['@statement.outer'] = 'v',
            },
        },
        swap = {
            enable = true,
            swap_next = {
                ['<leader><right>'] = '@parameter.inner',
            },
            swap_previous = {
                ['<leader><left>'] = '@parameter.inner',
            },
        },
        move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
                [']]f'] = '@function.outer',
                [']]c'] = '@class.outer',
                [']]p'] = '@parameter.outer',
                [']9'] = {'@function.outer', 'class.outer'},
            },
            goto_next_end = {
                ['][f'] = '@function.outer',
                ['][c'] = '@class.outer',
                ['][p'] = '@parameter.outer',
                [']0'] = {'@function.outer', 'class.outer'},
            },
            goto_previous_start = {
                ['[[f'] = '@function.outer',
                ['[[c'] = '@class.outer',
                ['[[p'] = '@parameter.outer',
                ['[9'] = {'@function.outer', 'class.outer'},
            },
            goto_previous_end = {
                ['[]f'] = '@function.outer',
                ['[]c'] = '@class.outer',
                ['[]p'] = '@parameter.outer',
                ['[0'] = {'@function.outer', 'class.outer'},
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
