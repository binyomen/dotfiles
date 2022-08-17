return {
    use_nvim_lua_ls = true,
    on_config_end = function()
        local util = require 'vimrc.util'

        -- Correctly set filetypes on dotfiles.
        local function make_filetype_autocmd(filename, filetype)
            return {{'BufNewFile', 'BufRead'}, {pattern = filename, callback =
                function()
                    vim.opt_local.filetype = filetype
                end
            }}
        end
        util.augroup('nvim_local__set_dotfile_filetypes', {
            make_filetype_autocmd('gitconfig', 'gitconfig'),
            make_filetype_autocmd('gitignore', 'gitignore'),
            make_filetype_autocmd('bashrc', 'sh'),
            make_filetype_autocmd('vimrc', 'vim'),
        })
    end,
}
