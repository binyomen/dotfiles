local M = {}

local util = require 'vimrc.util'

function M.configure_text()
    -- Set linewrapping.
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true

    -- Standard motion commands should move by wrapped lines.
    util.map('', 'k', 'gk', {buffer = true})
    util.map('', 'j', 'gj', {buffer = true})
    util.map('', '0', 'g0', {buffer = true})
    util.map('', '$', 'g$', {buffer = true})
    util.map('', '^', 'g^', {buffer = true})
    util.map('', 'H', 'g^', {buffer = true})
    util.map('', 'L', 'g$', {buffer = true}) -- TODO: This should be changed to gg_ or whatever the linewrapping version of g_ is.
    -- autocmd FileType text noremap <buffer> <silent> g_ gg_| -- TODO: is there a linewrapping version of g_?
end

function M.configure_html()
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
end

function M.configure_help()
    -- If conceallevel is 2, it means the help ftplugin has been loaded and we
    -- can apply our settings without them being overridden. If not, defer and
    -- try again.
    if vim.opt_local.conceallevel:get() ~= 2 then
        vim.defer_fn(M.configure_help, 10)
        return
    end

    -- Make concealed characters in help files visible.
    vim.opt_local.conceallevel = 0
    vim.cmd [[highlight link HelpBar Normal]]
    vim.cmd [[highlight link HelpStar Normal]]
end

function M.configure_markdown()
    vim.opt_local.textwidth = 79

    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2

    vim.b.show_word_count = true

    util.map('n', '<leader>p', [[<cmd>call mdip#MarkdownClipboardImage()<cr>]], {buffer = true})

    -- I'm tired we're just gonna do this a second after the buffer loads lol.
    vim.defer_fn(
        function()
            -- Don't automatically insert bullets when hitting enter in a list.
            vim.opt_local.formatoptions:remove('r')

            -- Don't use the indentexpr provided by vim-markdown, since it depends
            -- on vim.g.vim_markdown_new_list_item_indent and as a result doesn't
            -- work if you set that to zero.
            vim.opt_local.indentexpr = ''

            vim.opt_local.comments = {'fb:>', 'fb:*', 'fb:+', 'fb:-'}

            -- Support org mode tables.
            vim.b.table_mode_corner = '+'
            vim.b.table_mode_corner_corner = '+'
            vim.b.table_mode_header_fillchar = '='
        end,
        1000
    )
end

vim.cmd [[
    augroup vimrc__txt_files
        autocmd!
        autocmd FileType text lua require('vimrc.filetypes').configure_text()
    augroup end
    augroup vimrc__go_files
        autocmd!
        autocmd FileType go setlocal rtp+=$GOPATH/src/github.com/golang/lint/misc/vim " add golint for vim to the runtime path
        autocmd BufWritePost,FileWritePost *.go execute 'mkview!' | execute 'Lint' | execute 'silent! loadview'| " execute the Lint command on write
    augroup end
    augroup vimrc__xaml_files
        autocmd!
        autocmd BufNewFile,BufRead *.xaml set ft=xml " XAML is basically just XML
    augroup end
    augroup vimrc__html_files
        autocmd!
        autocmd FileType html lua require('vimrc.filetypes').configure_html()
    augroup end
    augroup vimrc__help_files
        autocmd!
        autocmd FileType help lua require('vimrc.filetypes').configure_help()
    augroup end
    augroup vimrc__markdown_files
        autocmd!
        autocmd FileType markdown lua require('vimrc.filetypes').configure_markdown()
    augroup end

    augroup vimrc__spell_file_types
        autocmd!
        autocmd FileType gitcommit,html,markdown,text setlocal spell
    augroup end
]]

return M
