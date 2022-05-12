-- Install packer on first run.
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if require('vimrc.util').vim_empty(vim.fn.glob(install_path)) then
    vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

local packer = require 'packer'
local use = packer.use

-- Automatically compile packer when plugins.lua is changed.
require('vimrc.util').augroup('vimrc__packer_auto_compile', {
    {'BufWritePost', {pattern = 'plugins.lua', command = 'source <afile> | PackerCompile'}},
})

local function not_firenvim()
    return not require('vimrc.util').vim_true(vim.g.started_by_firenvim)
end

return require('packer').startup {
    function()
        -- Packer itself.
        use 'wbthomason/packer.nvim'

        -- Cache lua module bytecode.
        use 'lewis6991/impatient.nvim'

        -- General text editing.
        use 'tpope/vim-commentary' -- Commenting functionality.
        use 'tpope/vim-surround' -- Surround text in quotes, HTML tags, etc.
        use 'tpope/vim-repeat' -- Repeatable plugin actions.
        use 'inkarkat/vim-ReplaceWithRegister' -- Easy replacement without overwriting registers.
        use {
            'junegunn/vim-easy-align',
            config = function()
                require('vimrc.util').map({'n', 'x'}, 'ga', '<plug>(EasyAlign)')
            end,
        }

        -- Custom text objects.
        use 'kana/vim-textobj-user' -- Framework for creating custom text objects.
        use 'kana/vim-textobj-entire' -- ae/ie: The entire buffer.
        use 'kana/vim-textobj-indent' -- ai/ii/aI/iI: Similarly indented groups.
        use 'kana/vim-textobj-line' -- al/il: The current line.
        use 'glts/vim-textobj-comment' -- ac/ic/aC: A comment block.
        use 'Julian/vim-textobj-variable-segment' -- av/iv: Part of a camelCase or snake_case variable.
        use { -- aq/iq/aQ/iQ: Columns of characters.
            'idbrii/textobj-word-column.vim',
            config = function()
                vim.g.textobj_wordcolumn_no_default_key_mappings = 1

                vim.fn['textobj#user#map']('wordcolumn', {
                    word = {
                        ['select-i'] = 'iq',
                        ['select-a'] = 'aq',
                    },
                    WORD = {
                        ['select-i'] = 'iQ',
                        ['select-a'] = 'aQ',
                    },
                })
            end,
        }
        use 'sgur/vim-textobj-parameter' -- a,/i,: Function arguments and parameters.
        use 'thinca/vim-textobj-between' -- af/if: Between a given character.
        use {
            'dhruvasagar/vim-table-mode',
            config = function()
                vim.g.table_mode_map_prefix = '<leader>0'
            end,
        }

        -- User interface stuff.
        use {
            'iCyMind/NeoSolarized',
            config = function()
                vim.g.neosolarized_contrast = 'high'
            end,
        }
        use 'tomasr/molokai'
        use 'joshdick/onedark.vim'
        use {
            'NLKNguyen/papercolor-theme',
            config = function()
                require('vimrc.color').on_colorscheme_loaded()
            end,
        }
        use 'arcticicestudio/nord-vim'
        use 'cocopon/iceberg.vim'
        use 'rakr/vim-one'
        use 'mhartington/oceanic-next'
        use 'drewtempelmeyer/palenight.vim'
        use {'sonph/onehalf', rtp = 'vim'}
        use {
            'lukas-reineke/indent-blankline.nvim',
            config = function()
                require('indent_blankline').setup()
            end,
        }
        use {
            'voldikss/vim-floaterm',
            config = function()
                vim.g.floaterm_keymap_toggle = '<leader>9t'
            end,
        }

        -- External integration.
        use {'glacambre/firenvim', run = function() vim.fn['firenvim#install'](0) end} -- Usage in browsers.
        use {
            'tpope/vim-fugitive',
            cond = not_firenvim,
            config = function()
                require('vimrc.util').map('n', '<leader>gd', ':Gvdiff<cr>') -- Display a diff view of the current file.
            end,
        }
        use {
            'lewis6991/gitsigns.nvim',
            cond = not_firenvim,
            requires = {'nvim-lua/plenary.nvim'},
            config = function()
                require('gitsigns').setup {
                    on_attach = function(bufnr)
                        local util = require 'vimrc.util'

                        -- Navigation
                        util.map('n', ']c', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<cr>'", {expr = true, buffer = bufnr})
                        util.map('n', '[c', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<cr>'", {expr = true, buffer = bufnr})

                        -- Actions
                        util.map({'n', 'x'}, '<leader>gss', ':Gitsigns stage_hunk<cr>', {buffer = bufnr})
                        util.map({'n', 'x'}, '<leader>gsr', ':Gitsigns reset_hunk<cr>', {buffer = bufnr})
                        util.map('n', '<leader>gsS', '<cmd>Gitsigns stage_buffer<cr>', {buffer = bufnr})
                        util.map('n', '<leader>gsu', '<cmd>Gitsigns undo_stage_hunk<cr>', {buffer = bufnr})
                        util.map('n', '<leader>gsR', '<cmd>Gitsigns reset_buffer<cr>', {buffer = bufnr})
                        util.map('n', '<leader>gsp', '<cmd>Gitsigns preview_hunk<cr>', {buffer = bufnr})
                        util.map('n', '<leader>gsb', function() require('gitsigns').blame_line {full=true} end, {buffer = bufnr})
                        util.map('n', '<leader>gstb', '<cmd>Gitsigns toggle_current_line_blame<cr>', {buffer = bufnr})
                        util.map('n', '<leader>gsd', function() require('gitsigns').diffthis '~' end, {buffer = bufnr})
                        util.map('n', '<leader>gstd', '<cmd>Gitsigns toggle_deleted<cr>', {buffer = bufnr})

                        -- Text object
                        util.map({'o', 'x'}, 'igsh', ':<c-u>Gitsigns select_hunk<cr>', {buffer = bufnr})
                    end
                }
            end,
        }
        use {
            'neovim/nvim-lspconfig',
            after = 'nvim-cmp',
            config = function()
                require 'vimrc.lsp'
            end,
        }
        use 'ferrine/md-img-paste.vim'
        use 'justinmk/vim-dirvish'

        -- Completion.
        use {
            'hrsh7th/nvim-cmp',
            requires = {
                'hrsh7th/cmp-nvim-lsp',
                'hrsh7th/cmp-buffer',
                'hrsh7th/cmp-path',
                'hrsh7th/cmp-cmdline',
                'hrsh7th/cmp-nvim-lua',
                'hrsh7th/cmp-omni',
                'saadparwaiz1/cmp_luasnip',
                'lukas-reineke/cmp-rg',
                'hrsh7th/cmp-calc',
                'L3MON4D3/LuaSnip',
                'honza/vim-snippets',
            },
            config = function()
                require('luasnip.loaders.from_snipmate').lazy_load()
                require 'vimrc.completion'
            end,
        }

        -- File types.
        use {
            'PProvost/vim-ps1',
            ft = 'ps1',
        }
        use {
            'dag/vim-fish',
            ft = 'fish',
        }
        use {
            'tmhedberg/SimpylFold',
            ft = 'python',
        }
        use {
            'cespare/vim-toml',
            ft = 'toml',
        }
        use {
            'rust-lang/rust.vim',
            ft = 'rust',
            config = function()
                vim.g.rustfmt_autosave = 1 -- Run rustfmt on save.
                vim.g.rust_recommended_style = 0 -- Don't force textwidth=99.
            end,
        }
        use {
            'leafgarland/typescript-vim',
            ft = 'typescript',
        }
        use {
            'jelera/vim-javascript-syntax',
            ft = 'javascript',
        }
        use {
            'ElmCast/elm-vim',
            ft = 'elm',
        }
        use {
            'preservim/vim-markdown',
            ft = 'markdown',
            config = function()
                vim.g.vim_markdown_new_list_item_indent = 0
                vim.g.vim_markdown_auto_insert_bullets = 0
            end,
        }

        -- Misc.
        use {
            'editorconfig/editorconfig-vim',
            cond = function() return not LOCAL_CONFIG.no_editorconfig end,
        }
        use 'stefandtw/quickfix-reflector.vim' -- Edits in the quickfix window get reflected in the actual buffers.
        use 'tpope/vim-eunuch' -- Filesystem commands.
        use 'milisims/nvim-luaref' -- Documentation for built-in Lua functions.
        use 'nvim-lua/plenary.nvim' -- Useful utilities.
        use {
            'tpope/vim-characterize',
            after = 'vim-easy-align', -- Since vim-easy-align also maps ga
            config = function()
                require('vimrc.util').map('n', 'g8', '<plug>(characterize)')
            end,
        }
        use {
            'vimwiki/vimwiki',
            branch = 'dev',
            setup = function()
                vim.g.vimwiki_key_mappings = {all_maps = 0}
                vim.g.vimwiki_toc_header_level = 2
                vim.g.vimwiki_auto_chdir = 1

                local util = require 'vimrc.util'
                util.map('n', '<leader>ww', '<plug>VimwikiIndex')
                util.map('n', '<leader>ws', '<plug>VimwikiUISelect')

                local vimwiki_list = {{
                    name = 'Index',
                    path = '~/vimwiki/',
                    path_html = '~/vimwiki/html/',
                    auto_export = 1,
                    auto_toc = 1,
                    maxhi = 1,
                }}

                if LOCAL_CONFIG.vimwiki_list ~= nil then
                    for _, item in ipairs(LOCAL_CONFIG.vimwiki_list) do
                        table.insert(vimwiki_list, item)
                    end
                end

                vim.g.vimwiki_list = vimwiki_list
            end,
        }
    end,
    config = {
        profile = {
            -- Enable profiling plugin loads.
            enable = false,
        },
        git = {
            -- Don't timeout when cloning new plugins.
            clone_timeout = false,
        },
    },
}
