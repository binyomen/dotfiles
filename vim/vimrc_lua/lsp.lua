local completion = require 'vimrc.completion'
local lspconfig = require 'lspconfig'
local util = require 'vimrc.util'

util.map('n', '<leader><space>q', vim.diagnostic.setloclist)

local function on_attach(_, buf)
    -- Remove the default omnifunc (v:lua.vim.lsp.omnifunc), since it causes
    -- issues if it's used with the extra capabilities provided by nvim-cmp.
    vim.bo[buf].omnifunc = nil

    util.map('n', '<leader><space>d', vim.lsp.buf.definition, {buffer = buf})
    util.map('n', '<leader><space>D', vim.lsp.buf.declaration, {buffer = buf})
    util.map('n', '<leader><space>i', vim.lsp.buf.implementation, {buffer = buf})
    util.map('n', '<leader><space><c-k>', vim.lsp.buf.signature_help, {buffer = buf})
    util.map('n', '<leader><space>wa', vim.lsp.buf.add_workspace_folder, {buffer = buf})
    util.map('n', '<leader><space>wr', vim.lsp.buf.remove_workspace_folder, {buffer = buf})
    util.map('n', '<leader><space>wl', function() util.echo(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, {buffer = buf})
    util.map('n', '<leader><space>td', vim.lsp.buf.type_definition, {buffer = buf})
    util.map('n', '<leader><space>n', vim.lsp.buf.rename, {buffer = buf})
    util.map('n', '<leader><space>ca', vim.lsp.buf.code_action, {buffer = buf})
    util.map('n', '<leader><space>r', vim.lsp.buf.references, {buffer = buf})
    util.map('n', '<leader><space>f', function() vim.lsp.buf.format {async = true} end, {buffer = buf})
    util.map('n', '<leader><space>s', vim.lsp.buf.document_symbol, {buffer = buf})
    util.map('n', '<leader><space>S', function() vim.lsp.buf.workspace_symbol('') end, {buffer = buf})
    util.map('n', '<leader><space>h', '<cmd>ClangdSwitchSourceHeader<cr>', {buffer = buf})
    util.map('n', '<leader><space>cs', '<cmd>ClangdShowSymbolInfo<cr>', {buffer = buf})
end

local function setup_language_server(name, config)
    local config = util.default(config, {})

    local base_config = {on_attach = on_attach, capabilities = completion.capabilities}
    local final_config = vim.tbl_extend('force', base_config, config)

    lspconfig[name].setup(final_config)
end

-- https://github.com/LuaLS/lua-language-server
setup_language_server('lua_ls', {
    settings = LOCAL_CONFIG.lua_ls_dynamic_settings,
})

-- https://github.com/rust-lang/rust-analyzer
setup_language_server('rust_analyzer', {
    cmd = {'rustup', 'run', 'stable', 'rust-analyzer'},
    settings = {
        ['rust-analyzer'] = {
            checkOnSave = {
                command = 'clippy',
            },
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

-- https://github.com/artempyanykh/marksman
setup_language_server('marksman')

-- https://github.com/microsoft/pyright
setup_language_server('pyright')

-- https://github.com/mattn/efm-langserver
setup_language_server('efm', {
    filetypes = {'markdown'},
    init_options = {documentFormatting = true},
    settings = {
        rootMarkers = {'.git/'},
        languages = {
            markdown = {{
                formatCommand = 'prettier --stdin-filepath ${INPUT}',
                formatStdin = true,
            }},
        },
    },
})

if LOCAL_CONFIG.language_servers then
    for _, server in ipairs(LOCAL_CONFIG.language_servers) do
        if server.default_options then
            lspconfig[server.name] = server.default_options
        end
        setup_language_server(server.name, server.setup_options)
    end
end
