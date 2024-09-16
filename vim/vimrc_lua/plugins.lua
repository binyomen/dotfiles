-- Install packer on first run.
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if require('vimrc.util').vim_empty(vim.fn.glob(install_path)) then
    vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd.packadd 'packer.nvim'
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
        use {
            'ggandor/leap.nvim',
            config = function()
                local util = require 'vimrc.util'
                util.map('n', 's', '<plug>(leap-forward-to)')
                util.map('n', 'S', '<plug>(leap-backward-to)')
                util.map({'o', 'x'}, 'z', '<plug>(leap-forward-to)')
                util.map({'o', 'x'}, 'Z', '<plug>(leap-backward-to)')
                util.map({'o', 'x'}, 'x', '<plug>(leap-forward-till)')
                util.map({'o', 'x'}, 'X', '<plug>(leap-backward-till)')
                util.map('n', 'gs', '<plug>(leap-cross-window)')
            end,
        }
        use {
            'ggandor/leap-spooky.nvim',
            config = function()
                require('leap-spooky').setup()
            end,
        }
        use {
            'smjonas/live-command.nvim',
            tag = '1.x',
            config = function()
                require('live-command').setup {
                    defaults = {
                        enable_highlighting = false,
                    },
                    commands = {
                        Norm = {
                            cmd = 'norm',
                            args = function(opts)
                                return vim.keycode(opts.args)
                            end,
                        },
                    },
                }
            end,
        }

        -- Custom text objects.
        use 'kana/vim-textobj-user' -- Framework for creating custom text objects.
        use 'kana/vim-textobj-entire' -- ae/ie: The entire buffer.
        use 'kana/vim-textobj-indent' -- ai/ii/aI/iI: Similarly indented groups.
        use 'kana/vim-textobj-line' -- al/il: The current line.
        use 'glts/vim-textobj-comment' -- ac/ic/aC: A comment block.
        use 'Julian/vim-textobj-variable-segment' -- av/iv: Part of a camelCase or snake_case variable.
        use { -- ak/ik/aK/iK: Columns of characters.
            'idbrii/textobj-word-column.vim',
            config = function()
                vim.g.textobj_wordcolumn_no_default_key_mappings = 1

                vim.fn['textobj#user#map']('wordcolumn', {
                    word = {
                        ['select-i'] = 'ik',
                        ['select-a'] = 'ak',
                    },
                    WORD = {
                        ['select-i'] = 'iK',
                        ['select-a'] = 'aK',
                    },
                })
            end,
        }
        use 'sgur/vim-textobj-parameter' -- a,/i,: Function arguments and parameters.
        use 'thinca/vim-textobj-between' -- af/if: Between a given character.
        use { -- aq/iq/aQ/iQ: Smart quotes.
            'preservim/vim-textobj-quote',
            config = function()
                local util = require 'vimrc.util'
                util.map({'n', 'x'}, '<leader>qc', '<plug>ReplaceWithCurly')
                util.map({'n', 'x'}, '<leader>qs', '<plug>ReplaceWithStraight')
                util.map({'n', 'x'}, '<leader>qt', '<cmd>ToggleEducate<cr>')
            end,
        }

        -- Color schemes.
        use {
            'iCyMind/NeoSolarized',
            opt = true,
            config = function()
                vim.g.neosolarized_contrast = 'high'
            end,
        }
        use {'tomasr/molokai', opt = true}
        use {'joshdick/onedark.vim', opt = true}
        use { 'NLKNguyen/papercolor-theme', opt = true }
        use {'arcticicestudio/nord-vim', opt = true}
        use {'cocopon/iceberg.vim', opt = true}
        use {'rakr/vim-one', opt = true}
        use {'mhartington/oceanic-next', opt = true}
        use {'drewtempelmeyer/palenight.vim', opt = true}
        use {'sonph/onehalf', rtp = 'vim', opt = true}
        use {
            'folke/tokyonight.nvim',
            config = function()
                require('tokyonight').setup {
                    style = 'night',
                    dim_inactive = true,
                }

                vim.cmd.colorscheme 'tokyonight-night'
            end,
        }

        -- User interface stuff.
        use {
            'lukas-reineke/indent-blankline.nvim',
            config = function()
                require('ibl').setup {
                    scope = {
                        -- Don't show underlines on the first and last lines of
                        -- the current scope.
                        show_start = false,
                        show_end = false,
                    },
                }
            end,
        }
        use {
            'voldikss/vim-floaterm',
            config = function()
                vim.g.floaterm_width = 0.99
                vim.g.floaterm_height = 0.99
                vim.g.floaterm_autoinsert = false

                local util = require 'vimrc.util'
                util.map('n', '<m-t>', [[<cmd>FloatermToggle<cr>]])
                -- The `<cmd>echo<cr>` is necessary to prevent the "-- TERMINAL --"
                -- mode from still being displayed after exiting the terminal
                -- window. I tried alternatives like `<cmd><esc>` and
                -- `:<esc>` but neither of them cleared the bottom line.
                util.map('t', '<m-t>', [[<c-\><c-n><cmd>FloatermToggle<cr><cmd>echo<cr>]])
            end,
        }
        use {
            'rickhowe/diffchar.vim',
            config = function()
                vim.g.DiffUnit = 'word'
            end,
        }
        use {
            'dhruvasagar/vim-table-mode',
            config = function()
                vim.g.table_mode_map_prefix = '<leader>0'
            end,
        }
        use {
            'kosayoda/nvim-lightbulb',
            config = function()
                require('nvim-lightbulb').setup {
                    autocmd = {
                        enabled = true,
                    },
                }
            end,
        }
        use {
            'norcalli/nvim-colorizer.lua',
            config = function()
                require('colorizer').setup(
                    {
                        'css',
                        'i3config',
                    },
                    {
                        css = true,
                        css_fn = true,
                    }
                )
            end,
        }

        -- External integration.
        use {
            'glacambre/firenvim',
            run = function()
                vim.fn['firenvim#install'](0)
            end,
        }
        use {
            'tpope/vim-fugitive',
            cond = not_firenvim,
            config = function()
                require('vimrc.util').map('n', '<leader>gfd', ':Gvdiff<cr>') -- Display a diff view of the current file.
            end,
        }
        use {
            'lewis6991/gitsigns.nvim',
            cond = not_firenvim,
            config = function()
                local gitsigns = require 'gitsigns'

                gitsigns.setup {
                    on_attach = function(buf)
                        local util = require 'vimrc.util'

                        local function gitsigns_map(mode, lhs, rhs, opts)
                            local opts = util.default(opts, {})
                            opts.buffer = buf
                            util.map(mode, lhs, rhs, opts)
                        end

                        -- Navigation
                        local function nav_map(lhs, func)
                            gitsigns_map(
                                'n',
                                lhs,
                                function()
                                    if vim.wo.diff then
                                        return lhs
                                    else
                                        vim.schedule(func)
                                        return '<ignore>'
                                    end
                                end,
                                {expr = true}
                            )
                        end
                        nav_map(']c', gitsigns.next_hunk)
                        nav_map('[c', gitsigns.prev_hunk)

                        -- Actions
                        gitsigns_map({'n', 'x'}, '<leader>gs', gitsigns.stage_hunk)
                        gitsigns_map({'n', 'x'}, '<leader>gr', gitsigns.reset_hunk)
                        gitsigns_map('n', '<leader>gS', gitsigns.stage_buffer)
                        gitsigns_map('n', '<leader>gu', gitsigns.undo_stage_hunk)
                        gitsigns_map('n', '<leader>gR', gitsigns.reset_buffer)
                        gitsigns_map('n', '<leader>gp', gitsigns.preview_hunk)
                        gitsigns_map('n', '<leader>gb', function() gitsigns.blame_line {full=true} end)
                        gitsigns_map('n', '<leader>gtb', gitsigns.toggle_current_line_blame)
                        gitsigns_map('n', '<leader>gd', gitsigns.diffthis)
                        gitsigns_map('n', '<leader>gD', function() gitsigns.diffthis('~') end)
                        gitsigns_map('n', '<leader>gtd', gitsigns.toggle_deleted)

                        -- Text object
                        gitsigns_map({'o', 'x'}, 'igh', gitsigns.select_hunk)
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
        use 'img-paste-devs/img-paste.vim'
        use {
            'justinmk/vim-dirvish',
            config = function()
                require('vimrc.util').map('n', '<leader>-', '<plug>(dirvish_up)')
            end,
        }
        use {
            'sindrets/diffview.nvim',
            requires = 'nvim-lua/plenary.nvim',
            config = function()
                local actions = require('diffview.actions')
                require('diffview').setup {
                    use_icons = false,
                    file_panel = {
                        win_config = {
                            width = 20,
                        },
                    },
                    keymaps = {
                        disable_defaults = true,
                        view = {
                            ['gf'] = actions.goto_file,
                            ['<leader>gtf'] = actions.toggle_files,
                        },
                        file_panel = {
                            ['j'] = actions.next_entry,
                            ['k'] = actions.prev_entry,
                            ['<cr>'] = actions.select_entry,
                            ['s'] = actions.toggle_stage_entry,
                            ['S'] = actions.stage_all,
                            ['U'] = actions.unstage_all,
                            ['R'] = actions.refresh_files,
                            ['L'] = actions.open_commit_log,
                            ['gf'] = actions.goto_file,
                            ['i'] = actions.listing_style,
                            ['f'] = actions.toggle_flatten_dirs,
                            ['<leader>gtf'] = actions.toggle_files,
                        },
                        file_history_panel = {
                            ['g!'] = actions.options,
                            ['L'] = actions.open_commit_log,
                            ['j'] = actions.next_entry,
                            ['k'] = actions.prev_entry,
                            ['<cr>'] = actions.select_entry,
                            ['<leader>gtf'] = actions.toggle_files,
                        },
                        option_panel = {
                            ['<tab>'] = actions.select_entry,
                            ['q']     = actions.close,
                        },
                    },
                }

                local util = require 'vimrc.util'
                util.map('n', '<leader>gvo', '<cmd>DiffviewOpen<cr>')
                util.map('n', '<leader>gvh', '<cmd>DiffviewFileHistory<cr>')
            end,
        }
        use {
            'sakhnik/nvim-gdb',
            cond = function() return not require('vimrc.util').vim_has('win32') end,
            setup = function()
                vim.g.nvimgdb_disable_start_keymaps = true
                vim.g.nvimgdb_config_override = {
                    key_frameup = '<c-up>',
                    key_framedown = '<c-down>',
                    termwin_command = 'belowright vnew',
                    codewin_command = 'vnew',
                }
            end,
        }
        use {
            'weirongxu/plantuml-previewer.vim',
            requires = 'tyru/open-browser.vim',
        }

        -- Completion.
        use {
            'hrsh7th/nvim-cmp',
            requires = {
                'hrsh7th/cmp-nvim-lsp',
                'hrsh7th/cmp-buffer',
                'hrsh7th/cmp-path',
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
        use 'PProvost/vim-ps1'
        use 'ElmCast/elm-vim'
        use 'fladson/vim-kitty'
        use 'aklt/plantuml-syntax'

        -- Misc.
        use {
            'editorconfig/editorconfig-vim',
            cond = function() return not LOCAL_CONFIG.no_editorconfig end
        }
        use {
            'kevinhwang91/nvim-bqf',
            config = function()
                require('bqf').setup {
                    preview = {
                        winblend = 0,
                    },
                }
            end,
        }
        use 'tpope/vim-eunuch' -- Filesystem commands.
        use 'milisims/nvim-luaref' -- Documentation for built-in Lua functions.
        use 'nvim-lua/plenary.nvim' -- Useful utilities.
        use {
            'tpope/vim-characterize',
            after = 'vim-easy-align', -- Since vim-easy-align also maps ga
            config = function()
                require('vimrc.util').map('n', 'g9', '<plug>(characterize)')
            end,
        }
        use {
            'vimwiki/vimwiki',
            branch = 'dev',
            setup = function()
                vim.g.vimwiki_key_mappings = {all_maps = 0}
                vim.g.vimwiki_toc_header_level = 2
                vim.g.vimwiki_auto_chdir = 1
                vim.g.vimwiki_ext2syntax = vim.empty_dict()
                vim.g.vimwiki_links_header_level = 2
                vim.g.vimwiki_auto_header = 1
                vim.g.vimwiki_valid_html_tags = 'p,blockquote,ul,ol,li'
                vim.g.vimwiki_tags_header_level = 2

                local util = require 'vimrc.util'
                util.map('n', '<leader>ww', '<plug>VimwikiIndex')
                util.map('n', '<leader>ws', '<plug>VimwikiUISelect')

                local vimwiki_list = {{
                    name = 'Index',
                    path = '~/vimwiki/',
                    path_html = '~/vimwiki/.html/',
                    auto_export = 1,
                    auto_toc = 1,
                    auto_tags = 1,
                    auto_generate_links = 1,
                    auto_generate_tags = 1,
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
        use {
            'jakewvincent/mkdnflow.nvim',
            config = function()
                local lead = '<leader>w'
                require('mkdnflow').setup {
                    perspective = {
                        nvim_wd_heel = false,
                    },
                    links = {
                        transform_explicit = require('vimrc.markdown').slugify,
                        context = 2,
                    },
                    mappings = {
                        MkdnEnter = false,
                        MkdnTab = false,
                        MkdnSTab = false,
                        MkdnNextLink = false,
                        MkdnPrevLink = false,
                        MkdnNextHeading = false,
                        MkdnPrevHeading = false,
                        MkdnGoBack = false,
                        MkdnGoForward = false,
                        MkdnFollowLink = {'n', lead .. 'w'},
                        MkdnDestroyLink = {'n', '<m-cr>'},
                        MkdnTagSpan = false,
                        MkdnMoveSource = {'n', '<f2>'},
                        MkdnYankAnchorLink = {'n', lead .. 'a'},
                        MkdnYankFileAnchorLink = {'n', lead .. 'fa'},
                        MkdnIncreaseHeading = {'n', lead .. '+'},
                        MkdnDecreaseHeading = {'n', lead .. '-'},
                        MkdnToggleToDo = {{'n', 'x'}, lead .. 't'},
                        MkdnNewListItem = false,
                        MkdnNewListItemBelowInsert = false,
                        MkdnNewListItemAboveInsert = false,
                        MkdnExtendList = false,
                        MkdnUpdateNumbering = {'n', lead .. 'n'},
                        MkdnCreateLink = {{'n', 'x'}, lead .. 'c'},
                        MkdnTableNextCell = false,
                        MkdnTablePrevCell = false,
                        MkdnTableNextRow = false,
                        MkdnTablePrevRow = false,
                        MkdnTableNewRowBelow = false,
                        MkdnTableNewRowAbove = false,
                        MkdnTableNewColAfter = false,
                        MkdnTableNewColBefore = false,
                        MkdnFoldSection = false,
                        MkdnUnfoldSection = false,
                    }
                }
            end,
        }
        use {
            'binyomen/vim-emoji-abbreviations',
            config = function()
                require('vim-emoji-abbreviations').setup()
            end,
        }

        -- Tree-sitter
        use {
            'nvim-treesitter/nvim-treesitter',
            run = ':TSUpdate',
            config = function()
                require 'vimrc.treesitter'
            end,
        }
        use 'nvim-treesitter/nvim-treesitter-textobjects'
        use 'nvim-treesitter/nvim-treesitter-refactor'
        use {
            'nvim-treesitter/nvim-treesitter-context',
            config = function()
                require('treesitter-context').setup()

                local util = require 'vimrc.util'
                util.map('n', '<leader>ct', '<cmd>TSContextToggle<cr>')
            end,
        }

        if LOCAL_CONFIG.use_local_plugins then
            LOCAL_CONFIG.use_local_plugins()
        end
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
