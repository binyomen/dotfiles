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
        vim.defer_fn(configure_help, 10)
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

    vim.b.show_word_count = true

    util.map('n', '<leader>p', vim.fn['mdip#MarkdownClipboardImage'], {buffer = true})

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

local function configure_vimwiki()
    util.map('n', '<leader>wh', '<plug>Vimwiki2HTML')
    util.map('n', '<leader>wb', '<plug>Vimwiki2HTMLBrowse')
    util.map('n', '<cr>', '<plug>VimwikiFollowLink')
    util.map('n', '[[', '<plug>VimwikiGoToPrevHeader')
    util.map('n', ']]', '<plug>VimwikiGoToNextHeader')
    util.map('n', '[=', '<plug>VimwikiGoToPrevSiblingHeader')
    util.map('n', ']=', '<plug>VimwikiGoToNextSiblingHeader')
    util.map('n', '[u', '<plug>VimwikiGoToParentHeader')
    util.map('n', ']u', '<plug>VimwikiGoToParentHeader')

    vim.b.table_mode_corner = '|'
    vim.b.table_mode_corner_corner = '|'
    vim.b.table_mode_header_fillchar = '-'

    vim.defer_fn(
        function()
            vim.opt_local.conceallevel = 0
        end,
        1000
    )
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

util.augroup('vimrc__xaml_files', {
    {{'BufNewFile', 'BufRead'}, {pattern = '*.xaml', callback =
        function()
            -- XAML is basically just XML.
            vim.opt_local.filetype = 'xml'
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

util.augroup('vimrc__spell_file_types', {
    {'FileType', {pattern = 'gitcommit,html,markdown,text', callback =
        function()
            vim.opt_local.spell = true
        end
    }},
})
