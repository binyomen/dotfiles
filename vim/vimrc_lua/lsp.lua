local completion = require 'vimrc.completion'
local lspconfig = require 'lspconfig'
local util = require 'vimrc.util'

util.map('n', '<leader><space>e', vim.diagnostic.open_float)
util.map('n', '[d', vim.diagnostic.goto_prev)
util.map('n', ']d', vim.diagnostic.goto_next)
util.map('n', '<leader><space>q', vim.diagnostic.setloclist)

local function on_attach(_, buf)
    vim.api.nvim_buf_set_option(buf, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    util.map('n', '<leader><space>d', vim.lsp.buf.definition, {buffer = buf})
    util.map('n', '<leader><space>D', vim.lsp.buf.declaration, {buffer = buf})
    util.map('n', '<leader><space>K', vim.lsp.buf.hover, {buffer = buf})
    util.map('n', '<leader><space>i', vim.lsp.buf.implementation, {buffer = buf})
    util.map('n', '<leader><space><c-k>', vim.lsp.buf.signature_help, {buffer = buf})
    util.map('n', '<leader><space>wa', vim.lsp.buf.add_workspace_folder, {buffer = buf})
    util.map('n', '<leader><space>wr', vim.lsp.buf.remove_workspace_folder, {buffer = buf})
    util.map('n', '<leader><space>wl', function() util.echo(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, {buffer = buf})
    util.map('n', '<leader><space>td', vim.lsp.buf.type_definition, {buffer = buf})
    util.map('n', '<leader><space>n', vim.lsp.buf.rename, {buffer = buf})
    util.map('n', '<leader><space>ca', vim.lsp.buf.code_action, {buffer = buf})
    util.map('n', '<leader><space>r', vim.lsp.buf.references, {buffer = buf})
    util.map('n', '<leader><space>f', vim.lsp.buf.formatting, {buffer = buf})
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
