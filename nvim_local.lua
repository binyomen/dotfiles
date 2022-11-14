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
        local util = require 'vimrc.util'

        -- Correctly set filetypes on dotfiles.
        local function make_filetype_autocmd(filename, filetype)
            return {{'BufNewFile', 'BufRead'}, {pattern = filename, callback =
                function()
                    vim.bo.filetype = filetype
                end
            }}
        end
        util.augroup('nvim_local__set_dotfile_filetypes', {
            make_filetype_autocmd('gitattributes', 'gitattributes'),
            make_filetype_autocmd('gitconfig', 'gitconfig'),
            make_filetype_autocmd('gitignore', 'gitignore'),
            make_filetype_autocmd('bashrc', 'sh'),
            make_filetype_autocmd('vimrc', 'vim'),
        })
    end,
}
