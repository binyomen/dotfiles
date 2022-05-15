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
    mapping = cmp.mapping.preset.insert {
        ['<c-b>'] = cmp.mapping.scroll_docs(-4),
        ['<c-f>'] = cmp.mapping.scroll_docs(4),
        ['<c-space>'] = cmp.mapping.complete(),
        -- Accept currently selected item. Set `select` to `false` to only
        -- confirm explicitly selected items.
        ['<c-t>'] = cmp.mapping.confirm {select = true},
    },
    sources = cmp.config.sources(
        {{name = 'nvim_lsp'}, {name = 'luasnip'}, {name = 'nvim_lua'}, {name = 'rg'}, {name = 'calc'}, {name = 'omni'}},
        {{name = 'buffer'}}
    )
}

-- local cmdline_mappings = cmp.mapping.preset.cmdline {
--     ['<C-n>'] = cmp.mapping.select_next_item {behavior = cmp.SelectBehavior.Insert},
--     ['<C-p>'] = cmp.mapping.select_prev_item {behavior = cmp.SelectBehavior.Insert},
-- }

-- cmp.setup.cmdline('/', {
--     mapping = cmdline_mappings,
--     sources = {{name = 'buffer'}},
-- })
-- cmp.setup.cmdline('?', {
--     mapping = cmdline_mappings,
--     sources = {{name = 'buffer'}},
-- })

-- cmp.setup.cmdline(':', {
--     mapping = cmdline_mappings,
--     sources = cmp.config.sources({{name = 'path'}}, {{name = 'cmdline'}}),
-- })

M.capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

util.map('i', {expr = true}, '<tab>', function()
    if luasnip.expand_or_jumpable() then
        return '<plug>luasnip-expand-or-jump'
    else
        return '<tab>'
    end
end)
util.map('s', '<tab>', function() luasnip.jump(1) end)
util.map({'i', 's'}, '<s-tab>', function() luasnip.jump(-1) end)

return M
