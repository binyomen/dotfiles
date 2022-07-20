local util = require 'vimrc.util'

local function configure_text()
    -- Set linewrapping.
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true

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
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
end

local function configure_help()
    -- If conceallevel is 2, it means the help ftplugin has been loaded and we
    -- can apply our settings without them being overridden. If not, defer and
    -- try again.
    if vim.opt_local.conceallevel:get() ~= 2 then
        util.defer(10, configure_help)
        return
    end

    -- Make concealed characters in help files visible.
    vim.opt_local.conceallevel = 0
    vim.cmd [[highlight link HelpBar Normal]]
    vim.cmd [[highlight link HelpStar Normal]]
end

local function configure_markdown()
    vim.opt_local.textwidth = 79

    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2

    util.enable_conceal()

    vim.b.vimrc__show_word_count = true

    util.map('n', '<leader>p', util.paste_image, {buffer = true})

    vim.b.table_mode_corner = '|'
    vim.b.table_mode_corner_corner = '|'
    vim.b.table_mode_header_fillchar = '-'
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

    vim.opt_local.textwidth = 79

    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2

    vim.g.PasteImageFunction = 'g:EmptyPasteImage'
    util.map('n', '<leader>p', util.paste_image, {buffer = true})
end

local function configure_neorg()
    vim.b.table_mode_corner = '|'
    vim.b.table_mode_corner_corner = '|'
    vim.b.table_mode_header_fillchar = '-'

    vim.b.vimrc__show_word_count = true

    vim.opt_local.textwidth = 79

    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2

    vim.g.PasteImageFunction = 'g:EmptyPasteImage'
    util.map('n', '<leader>p', util.paste_image, {buffer = true})
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

util.augroup('vimrc__xaml_and_wprp_files', {
    {{'BufNewFile', 'BufRead'}, {pattern = '*.xaml,*.wprp', callback =
        function()
            -- XAML and WPRP are basically just XML.
            vim.opt_local.filetype = 'xml'
        end
    }},
})

util.augroup('vimrc__hbs_files', {
    {{'BufNewFile', 'BufRead'}, {pattern = '*.hbs', callback =
        function()
            vim.opt_local.filetype = 'html'
        end
    }},
})

util.augroup('vimrc__html_files', {
    {'FileType', {pattern = 'html', callback = configure_html}},
})

util.augroup('vimrc__help_files', {
    {'FileType', {pattern = 'help', callback = configure_help}},
})

util.augroup('vimrc__markdown_files', {
    {'FileType', {pattern = 'markdown', callback = configure_markdown}},
})

util.augroup('vimrc__vimwiki_files', {
    {'FileType', {pattern = 'vimwiki', callback = configure_vimwiki}},
})

util.augroup('vimrc__neorg_files', {
    {'FileType', {pattern = 'norg', callback = configure_neorg}},
})

util.augroup('vimrc__spell_file_types', {
    {'FileType', {pattern = 'gitcommit,html,markdown,text,vimwiki', callback =
        function()
            vim.opt_local.spell = true
        end
    }},
})
