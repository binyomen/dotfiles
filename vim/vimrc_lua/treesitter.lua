local util = require 'vimrc.util'

require('nvim-treesitter.configs').setup {
    ensure_installed = {
        'bash',
        'c_sharp',
        'comment',
        'css',
        'fish',
        'git_rebase',
        'gitattributes',
        'gitignore',
        'html',
        'javascript',
        'json',
        'lua',
        'markdown',
        'markdown_inline',
        'python',
        'query',
        'regex',
        'rust',
        'sql',
        'toml',
        'typescript',
        'vim',
        'vimdoc',
        'wgsl',
        'yaml',
    },
    highlight = {enable = true},
    indent = {
        enable = true,
        disable = {'markdown'},
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = 'goi',
            node_incremental = 'gon',
            scope_incremental = 'gos',
            node_decremental = 'goN',
        },
    },
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
                [']f'] = '@function.outer',
                [']k'] = '@class.outer',
                [']p'] = '@parameter.outer',
                [']]'] = {query = {'@function.outer', '@class.outer'}},
            },
            goto_next_end = {
                [']F'] = '@function.outer',
                [']K'] = '@class.outer',
                [']P'] = '@parameter.outer',
                [']['] = {query = {'@function.outer', '@class.outer'}},
            },
            goto_previous_start = {
                ['[f'] = '@function.outer',
                ['[k'] = '@class.outer',
                ['[p'] = '@parameter.outer',
                ['[['] = {query = {'@function.outer', '@class.outer'}},
            },
            goto_previous_end = {
                ['[F'] = '@function.outer',
                ['[K'] = '@class.outer',
                ['[P'] = '@parameter.outer',
                ['[]'] = {query = {'@function.outer', '@class.outer'}},
            },
        },
    },
    refactor = {
        navigation = {
            enable = true,
            keymaps = {
                goto_definition = false,
                goto_definition_lsp_fallback = 'gd',
                list_definitions = 'gl',
                list_definitions_toc = 'gO',
                goto_next_usage = false,
                goto_previous_usage = false,
            },
        },
    },
    playground = {
        enable = true,
    },
    query_linter = {
        enable = true,
    },
}

util.augroup('vimrc__treesitter_buffers', {
    {'BufWinEnter', {callback =
        function(args)
            if vim.b.vimrc__treesitter_folding_set then
                return
            end
            vim.b.vimrc__treesitter_folding_set = true

            if util.treesitter_active(args.buf) then
                vim.wo.foldmethod = 'expr'
                vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
                vim.wo.foldenable = false
            else
                vim.wo.foldmethod = 'syntax'
                vim.wo.foldexpr = ''
            end
        end,
    }},
})

local HIGHLIGHTS = {
    ['@annotation'] = {link = 'PreProc'},
    ['@attribute'] = {link = 'PreProc'},

    ['@boolean'] = {link = 'Boolean'},

    ['@character'] = {link = 'Character'},
    ['@character.special'] = {link = 'SpecialChar'},
    ['@comment'] = {link = 'Comment'},
    ['@conditional'] = {link = 'Conditional'},
    ['@constant'] = {link = 'Constant'},
    ['@constant.builtin'] = {link = 'Special'},
    ['@constant.macro'] = {link = 'Define'},
    ['@constructor'] = {link = 'Special'},

    ['@debug'] = {link = 'Debug'},
    ['@define'] = {link = 'Define'},

    ['@error'] = {link = '@none'},
    ['@exception'] = {link = 'Exception'},

    ['@field'] = {link = 'Identifier'},
    ['@float'] = {link = 'Float'},
    ['@function'] = {link = 'Function'},
    ['@function.builtin'] = {link = 'Special'},
    ['@function.call'] = {link = '@function'},
    ['@function.macro'] = {link = 'Macro'},

    ['@include'] = {link = 'Include'},

    ['@keyword'] = {link = 'Keyword'},
    ['@keyword.function'] = {link = 'Keyword'},
    ['@keyword.operator'] = {link = '@operator'},
    ['@keyword.return'] = {link = '@keyword'},

    ['@label'] = {link = 'Label'},

    ['@method'] = {link = 'Function'},
    ['@method.call'] = {link = '@method'},

    ['@namespace'] = {link = 'Include'},
    ['@none'] = {link = 'None'},
    ['@number'] = {link = 'Number'},

    ['@operator'] = {link = 'Operator'},

    ['@parameter'] = {link = 'Identifier'},
    ['@parameter.reference'] = {link = '@parameter'},
    ['@preproc'] = {link = 'PreProc'},
    ['@property'] = {link = 'Identifier'},
    ['@punctuation.bracket'] = {link = 'Delimiter'},
    ['@punctuation.delimiter'] = {link = 'Delimiter'},
    ['@punctuation.special'] = {link = 'Delimiter'},

    ['@repeat'] = {link = 'Repeat'},

    ['@storageclass'] = {link = 'StorageClass'},
    ['@string'] = {link = 'String'},
    ['@string.escape'] = {link = 'SpecialChar'},
    ['@string.regex'] = {link = 'String'},
    ['@string.special'] = {link = 'SpecialChar'},
    ['@symbol'] = {link = 'Identifier'},

    ['@tag'] = {link = 'Label'},
    ['@tag.attribute'] = {link = '@property'},
    ['@tag.delimiter'] = {link = 'Delimiter'},
    ['@text'] = {link = '@none'},
    ['@text.danger'] = {link = 'WarningMsg'},
    ['@text.emphasis'] = {italic = true},
    ['@text.environment'] = {link = 'Macro'},
    ['@text.environment.name'] = {link = 'Type'},
    ['@text.literal'] = {link = 'String'},
    ['@text.math'] = {link = 'Special'},
    ['@text.note'] = {link = 'SpecialComment'},
    ['@text.reference'] = {link = 'Constant'},
    ['@text.strike'] = {strikethrough = true},
    ['@text.strong'] = {bold = true},
    ['@text.title'] = {link = 'Title'},
    ['@text.underline'] = {underline = true},
    ['@text.uri'] = {link = 'Underlined'},
    ['@text.warning'] = {link = 'Todo'},
    ['@todo'] = {link = 'Todo'},
    ['@type'] = {link = 'Type'},
    ['@type.builtin'] = {link = 'Type'},
    ['@type.definition'] = {link = 'Typedef'},
    ['@type.qualifier'] = {link = 'Type'},

    ['@variable'] = {link = '@none'},
    ['@variable.builtin'] = {link = 'Special'},
}

vim.schedule(function()
    for capture, options in pairs(HIGHLIGHTS) do
        local options = vim.deepcopy(options)

        options.default = true
        vim.api.nvim_set_hl(0 --[[namespace]], capture, options)
    end
end)
