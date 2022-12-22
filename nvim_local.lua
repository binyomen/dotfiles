return {
    lua_ls_dynamic_settings = {
        Lua = {
            runtime = {
                path = vim.split(package.path, ';'),
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file('', true),
            },
        },
    },
    on_config_end = function()
        vim.filetype.add {
            filename = {
                gitattributes = 'gitattributes',
                gitconfig = 'gitconfig',
                gitignore = 'gitignore',
                bashrc = 'sh',
                vimrc = 'vim',
                ['config.global'] = 'i3config',
            },
        }
    end,
}
