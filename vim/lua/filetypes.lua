local M = {}

local util = require 'util'

function M.configure_text()
    -- Set linewrapping.
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true

    -- Standard motion commands should move by wrapped lines.
    util.buf_map(0, '', 'k', 'gk')
    util.buf_map(0, '', 'j', 'gj')
    util.buf_map(0, '', '0', 'g0')
    util.buf_map(0, '', '$', 'g$')
    util.buf_map(0, '', '^', 'g^')
    util.buf_map(0, '', 'H', 'g^')
    util.buf_map(0, '', 'L', 'g$') -- TODO: This should be changed to gg_ or whatever the linewrapping version of g_ is.
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
end

vim.cmd [[
    augroup txt_files
        autocmd!
        autocmd FileType text lua require('filetypes').configure_text()
    augroup end
    augroup go_files
        autocmd!
        autocmd FileType go setlocal rtp+=$GOPATH/src/github.com/golang/lint/misc/vim " add golint for vim to the runtime path
        autocmd BufWritePost,FileWritePost *.go execute 'mkview!' | execute 'Lint' | execute 'silent! loadview'| " execute the Lint command on write
    augroup end
    augroup xaml_files
        autocmd!
        autocmd BufNewFile,BufRead *.xaml set ft=xml " XAML is basically just XML
    augroup end
    augroup html_files
        autocmd!
        autocmd FileType html lua require('filetypes').configure_html()
    augroup end
    augroup help_files
        autocmd!
        autocmd FileType help lua require('filetypes').configure_help()
    augroup end
    augroup markdown_files
        autocmd!
        autocmd FileType markdown lua require('filetypes').configure_markdown()
    augroup end

    augroup spell_file_types
        autocmd!
        autocmd FileType gitcommit,html,markdown,text setlocal spell
    augroup end
]]

return M
