local M = {}

local cmp = require 'cmp'
local luasnip = require 'luasnip'
local util = require 'vimrc.util'

vim.opt.completeopt = {'menu', 'menuone', 'noselect'}

cmp.setup {
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = {
        ['<c-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
        ['<c-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
        ['<c-space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
        ['<c-e>'] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
        }),
        -- Accept currently selected item. Set `select` to `false` to only
        -- confirm explicitly selected items.
        ['<c-t>'] = cmp.mapping.confirm {select = true},
    },
    sources = cmp.config.sources(
        {{name = 'nvim_lsp'}, {name = 'luasnip'}, {name = 'nvim_lua'}, {name = 'rg'}, {name = 'calc'}},
        {{name = 'buffer'}}
    )
}

cmp.setup.cmdline('/', {
    sources = {{name = 'buffer'}},
})
cmp.setup.cmdline('?', {
    sources = {{name = 'buffer'}},
})

cmp.setup.cmdline(':', {
    sources = cmp.config.sources({{name = 'path'}}, {{name = 'cmdline'}}),
})

M.capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

util.map('i', '<tab>', [[luasnip#expand_or_jumpable() ? '<plug>luasnip-expand-or-jump' : '<tab>']], {expr = true, noremap = false})
util.map('i', '<s-tab>', [[<cmd>lua require('luasnip').jump(-1)<cr>]])
util.map('s', '<tab>', [[<cmd>lua require('luasnip').jump(1)<cr>]])
util.map('s', '<s-tab>', [[<cmd>lua require('luasnip').jump(-1)<cr>]])

return M
