local M = {}

local lspconfig = require 'lspconfig'
local util = require 'util'

util.map('n', '<leader><space>e', '<cmd>lua vim.diagnostic.open_float()<cr>')
util.map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
util.map('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')
util.map('n', '<leader><space>q', '<cmd>lua vim.diagnostic.setloclist()<cr>')

local function on_attach(_, buf)
    vim.api.nvim_buf_set_option(buf, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    util.buf_map(buf, 'n', '<leader><space>d', '<cmd>lua vim.lsp.buf.definition()<cr>')
    util.buf_map(buf, 'n', '<leader><space>D', '<cmd>lua vim.lsp.buf.declaration()<cr>')
    util.buf_map(buf, 'n', '<leader><space>K', '<cmd>lua vim.lsp.buf.hover()<cr>')
    util.buf_map(buf, 'n', '<leader><space>i', '<cmd>lua vim.lsp.buf.implementation()<cr>')
    util.buf_map(buf, 'n', '<leader><space><c-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>')
    util.buf_map(buf, 'n', '<leader><space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>')
    util.buf_map(buf, 'n', '<leader><space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>')
    util.buf_map(buf, 'n', '<leader><space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>')
    util.buf_map(buf, 'n', '<leader><space>td', '<cmd>lua vim.lsp.buf.type_definition()<cr>')
    util.buf_map(buf, 'n', '<leader><space>n', '<cmd>lua vim.lsp.buf.rename()<cr>')
    util.buf_map(buf, 'n', '<leader><space>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>')
    util.buf_map(buf, 'n', '<leader><space>r', '<cmd>lua vim.lsp.buf.references()<cr>')
    util.buf_map(buf, 'n', '<leader><space>f', '<cmd>lua vim.lsp.buf.formatting()<cr>')
end

if LOCAL_CONFIG.use_nvim_lua_ls then
    lspconfig.sumneko_lua.setup {
        on_attach = on_attach,
        settings = {
            Lua = {
                runtime = {
                    version = 'LuaJIT',
                    path = vim.split(package.path, ';'),
                },
                diagnostics = {
                    globals = {'vim'},
                    disable = {'redefined-local'},
                },
                workspace = {
                    library = vim.api.nvim_get_runtime_file('', true),
                },
            },
        },
    }
end

lspconfig.rls.setup {
    on_attach = on_attach,
    settings = {
        rust = {
            clippy_preference = 'on',
        },
    },
}

lspconfig.vimls.setup {
    on_attach = on_attach,
}

return M
