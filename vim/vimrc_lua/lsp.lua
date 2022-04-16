local M = {}

local completion = require 'vimrc.completion'
local lspconfig = require 'lspconfig'
local util = require 'vimrc.util'

util.map('n', '<leader><space>e', '<cmd>lua vim.diagnostic.open_float()<cr>')
util.map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
util.map('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')
util.map('n', '<leader><space>q', '<cmd>lua vim.diagnostic.setloclist()<cr>')

local function on_attach(_, buf)
    vim.api.nvim_buf_set_option(buf, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    util.map('n', '<leader><space>d', '<cmd>lua vim.lsp.buf.definition()<cr>', {buffer = buf})
    util.map('n', '<leader><space>D', '<cmd>lua vim.lsp.buf.declaration()<cr>', {buffer = buf})
    util.map('n', '<leader><space>K', '<cmd>lua vim.lsp.buf.hover()<cr>', {buffer = buf})
    util.map('n', '<leader><space>i', '<cmd>lua vim.lsp.buf.implementation()<cr>', {buffer = buf})
    util.map('n', '<leader><space><c-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>', {buffer = buf})
    util.map('n', '<leader><space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>', {buffer = buf})
    util.map('n', '<leader><space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>', {buffer = buf})
    util.map('n', '<leader><space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>', {buffer = buf})
    util.map('n', '<leader><space>td', '<cmd>lua vim.lsp.buf.type_definition()<cr>', {buffer = buf})
    util.map('n', '<leader><space>n', '<cmd>lua vim.lsp.buf.rename()<cr>', {buffer = buf})
    util.map('n', '<leader><space>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', {buffer = buf})
    util.map('n', '<leader><space>r', '<cmd>lua vim.lsp.buf.references()<cr>', {buffer = buf})
    util.map('n', '<leader><space>f', '<cmd>lua vim.lsp.buf.formatting()<cr>', {buffer = buf})
end

local function setup_language_server(name, config)
    local config = util.default(config, {})

    local base_config = {on_attach = on_attach, capabilities = completion.capabilities}
    local final_config = vim.tbl_extend('force', base_config, config)

    lspconfig[name].setup(final_config)
end

if LOCAL_CONFIG.use_nvim_lua_ls then
    -- https://github.com/sumneko/lua-language-server
    setup_language_server('sumneko_lua', {
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
    })
end

-- https://github.com/rust-lang/rls
setup_language_server('rls', {
    settings = {
        rust = {
            clippy_preference = 'on',
        },
    },
})

-- https://github.com/iamcco/vim-language-server
setup_language_server('vimls')

-- https://github.com/hrsh7th/vscode-langservers-extracted
setup_language_server('html')
setup_language_server('cssls')
setup_language_server('jsonls')
setup_language_server('eslint')

if LOCAL_CONFIG.language_servers then
    for _, server in ipairs(LOCAL_CONFIG.language_servers) do
        lspconfig[server.name] = server.default_options
        setup_language_server(server.name, server.setup_options)
    end
end

return M
