local util = require 'vimrc.util'

local function configure_text()
    -- Set linewrapping.
    vim.wo.wrap = true
    vim.wo.linebreak = true

    -- Standard motion commands should move by wrapped lines.
    util.map({'n', 'x', 'o'}, 'k', 'gk', {buffer = true})
    util.map({'n', 'x', 'o'}, 'j', 'gj', {buffer = true})
    util.map({'n', 'x', 'o'}, '0', 'g0', {buffer = true})
    util.map({'n', 'x', 'o'}, '$', 'g$', {buffer = true})
    util.map({'n', 'x', 'o'}, '^', 'g^', {buffer = true})
    util.map({'n', 'x', 'o'}, 'H', 'g^', {buffer = true})
    util.map({'n', 'x', 'o'}, 'L', 'g$', {buffer = true})
end

local function configure_html()
    util.set_tab_size(2)
end

local function configure_markdown()
    vim.bo.textwidth = 79

    util.set_tab_size(2)

    util.enable_conceal()

    vim.b.vimrc__show_word_count = true

    util.map('n', '<leader>p', util.paste_image, {buffer = true, silent = false})

    vim.b.table_mode_corner = '|'
    vim.b.table_mode_corner_corner = '|'
    vim.b.table_mode_header_fillchar = '-'

    util.map('n', '<cr>', vim.lsp.buf.definition, {buffer = true})

    require('vimrc.markdown').init_in_buffer()
end

local function configure_vimwiki()
    util.map('n', '<leader>wh', '<plug>Vimwiki2HTML', {buffer = true})
    util.map('n', '<leader>wb', '<plug>Vimwiki2HTMLBrowse', {buffer = true})
    util.map('n', '<leader>wl', '<plug>VimwikiNormalizeLink', {buffer = true})
    util.map('x', '<leader>wl', '<plug>VimwikiNormalizeLinkVisual', {buffer = true})
    util.map('n', '<leader>wk', vim.fn['vimwiki#base#linkify'], {buffer = true})
    util.map('n', '<leader>wt', '<plug>VimwikiToggleListItem', {buffer = true})
    util.map('n', '<cr>', '<plug>VimwikiFollowLink', {buffer = true})
    util.map('n', '<leader><cr>', '<plug>VimwikiVSplitLink', {buffer = true})
    util.map('n', '<leader><leader><cr>', '<plug>VimwikiSplitLink', {buffer = true})
    util.map('n', '[h', '<plug>VimwikiGoToPrevHeader', {buffer = true})
    util.map('n', ']h', '<plug>VimwikiGoToNextHeader', {buffer = true})
    util.map('n', '[=', '<plug>VimwikiGoToPrevSiblingHeader', {buffer = true})
    util.map('n', ']=', '<plug>VimwikiGoToNextSiblingHeader', {buffer = true})
    util.map('n', '[u', '<plug>VimwikiGoToParentHeader', {buffer = true})
    util.map('n', ']u', '<plug>VimwikiGoToParentHeader', {buffer = true})

    vim.b.table_mode_corner = '|'
    vim.b.table_mode_corner_corner = '|'
    vim.b.table_mode_header_fillchar = '-'

    vim.b.vimrc__show_word_count = true

    vim.bo.textwidth = 79

    util.set_tab_size(2)

    vim.g.PasteImageFunction = 'g:EmptyPasteImage'
    util.map('n', '<leader>p', util.paste_image, {buffer = true, silent = false})
end

local function configure_norg()
    vim.b.table_mode_corner = '|'
    vim.b.table_mode_corner_corner = '|'
    vim.b.table_mode_header_fillchar = '-'

    vim.b.vimrc__show_word_count = true

    vim.bo.textwidth = 79

    util.set_tab_size(2)

    vim.g.PasteImageFunction = 'g:EmptyPasteImage'
    util.map('n', '<leader>p', util.paste_image, {buffer = true, silent = false})
end

local function configure_xml()
    util.set_tab_size(2)
end

util.augroup('vimrc__txt_files', {
    {'FileType', {pattern = 'text', callback = configure_text}},
})

util.augroup('vimrc__go_files', {
    {'FileType', {pattern = 'go', callback =
        function()
            vim.opt_local.runtimepath:append('$GOPATH/src/github.com/golang/lint/misc/vim')
        end,
    }},
    {{'BufWritePost', 'FileWritePost'}, {pattern = '*.go', callback =
        function()
            vim.cmd [[mkview! | Lint | silent! loadview]]
        end,
    }},
})

util.augroup('vimrc__html_files', {
    {'FileType', {pattern = 'html', callback = configure_html}},
})

util.augroup('vimrc__markdown_files', {
    {'FileType', {pattern = 'markdown', callback = configure_markdown}},
})

util.augroup('vimrc__vimwiki_files', {
    {'FileType', {pattern = 'vimwiki', callback = configure_vimwiki}},
})

util.augroup('vimrc__norg_files', {
    {'FileType', {pattern = 'norg', callback = configure_norg}},
})

util.augroup('vimrc__xml_files', {
    {'FileType', {pattern = 'xml', callback = configure_xml}},
})

util.augroup('vimrc__nospell_file_types', {
    {'FileType', {pattern = 'git,dirvish', callback =
        function()
            vim.wo.spell = false
        end
    }},
})

vim.filetype.add {
    extension = {
        -- XAML and WPRP are basically just XML.
        xaml = 'xml',
        wprp = 'xml',

        hbs = 'html',

        -- I work with tree-sitter queries more than scheme at this point,
        -- although they really should have a different extension....
        scm = 'query',
    },
}

-- Rust settings.
vim.g.rustfmt_autosave = 1 -- Run rustfmt on save.
vim.g.rust_recommended_style = 0 -- Don't force textwidth=99.
