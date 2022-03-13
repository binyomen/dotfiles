-- Install packer on first run.
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) == 1 then
    vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

local packer = require 'packer'
local use = packer.use

-- Automatically compile packer when plugins.lua is changed.
vim.cmd([[
    augroup packer_auto_compile
        autocmd!
        autocmd BufWritePost plugins.lua source <afile> | PackerCompile
    augroup end
]])

local function not_firenvim()
    return not vim.g.started_by_firenvim
end

return require('packer').startup {
    function()
        -- Packer itself.
        use 'wbthomason/packer.nvim'

        -- General text editing.
        use 'tpope/vim-commentary' -- Commenting functionality.
        use 'tpope/vim-surround' -- Surround text in quotes, HTML tags, etc.
        use 'tpope/vim-repeat' -- Repeatable plugin actions.
        use 'inkarkat/vim-ReplaceWithRegister' -- Easy replacement without overwriting registers.
        use 'kana/vim-textobj-user' -- Framework for creating custom text objects.
        use 'kana/vim-textobj-entire' -- Text object of the entire buffer.
        use 'kana/vim-textobj-indent' -- Text object of an indented block.
        use 'kana/vim-textobj-line' -- Text object of the current line.
        use 'glts/vim-textobj-comment' -- Text object of a comment block.

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
                require('color').on_colorscheme_loaded()
            end,
        }
        use 'arcticicestudio/nord-vim'
        use 'cocopon/iceberg.vim'
        use 'rakr/vim-one'
        use 'mhartington/oceanic-next'
        use 'drewtempelmeyer/palenight.vim'
        use {'sonph/onehalf', rtp = 'vim'}

        -- External integration.
        use {'glacambre/firenvim', run = function() vim.fn['firenvim#install'](0) end} -- Usage in browsers.
        -- General git plugin.
        use {
            'tpope/vim-fugitive',
            cond = not_firenvim,
            config = function()
                require('util').map('n', '<leader>gd', ':Gvdiff<cr>') -- Display a diff view of the current file.
            end,
        }
        -- Display git status for each line.
        use {
            'lewis6991/gitsigns.nvim',
            cond = not_firenvim,
            requires = {'nvim-lua/plenary.nvim'},
            config = function()
                require('gitsigns').setup {
                    on_attach = function(bufnr)
                        local util = require 'util'

                        -- Navigation
                        util.buf_map(bufnr, 'n', ']c', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<cr>'", {expr = true})
                        util.buf_map(bufnr, 'n', '[c', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<cr>'", {expr = true})

                        -- Actions
                        util.buf_map(bufnr, 'n', '<leader>gss', ':Gitsigns stage_hunk<cr>')
                        util.buf_map(bufnr, 'v', '<leader>gss', ':Gitsigns stage_hunk<cr>')
                        util.buf_map(bufnr, 'n', '<leader>gsr', ':Gitsigns reset_hunk<cr>')
                        util.buf_map(bufnr, 'v', '<leader>gsr', ':Gitsigns reset_hunk<cr>')
                        util.buf_map(bufnr, 'n', '<leader>gsS', '<cmd>Gitsigns stage_buffer<cr>')
                        util.buf_map(bufnr, 'n', '<leader>gsu', '<cmd>Gitsigns undo_stage_hunk<cr>')
                        util.buf_map(bufnr, 'n', '<leader>gsR', '<cmd>Gitsigns reset_buffer<cr>')
                        util.buf_map(bufnr, 'n', '<leader>gsp', '<cmd>Gitsigns preview_hunk<cr>')
                        util.buf_map(bufnr, 'n', '<leader>gsb', '<cmd>lua require"gitsigns".blame_line{full=true}<cr>')
                        util.buf_map(bufnr, 'n', '<leader>gstb', '<cmd>Gitsigns toggle_current_line_blame<cr>')
                        util.buf_map(bufnr, 'n', '<leader>gsd', '<cmd>lua require"gitsigns".diffthis("~")<cr>')
                        util.buf_map(bufnr, 'n', '<leader>gstd', '<cmd>Gitsigns toggle_deleted<cr>')

                        -- Text object
                        util.buf_map(bufnr, 'o', 'igsh', ':<c-u>Gitsigns select_hunk<cr>')
                        util.buf_map(bufnr, 'x', 'igsh', ':<c-u>Gitsigns select_hunk<cr>')
                    end
                }
            end,
        }

        use {
            'neovim/nvim-lspconfig',
            config = function()
                require 'lsp'
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
            'binyomen/typescript-vim',
            branch = 'nvim_override',
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

        -- Misc.
        use {
            'editorconfig/editorconfig-vim',
            cond = function() return not LOCAL_CONFIG.no_editorconfig end,
        }
        use 'stefandtw/quickfix-reflector.vim' -- Edits in the quickfix window get reflected in the actual buffers.
    end,
    config = {
        profile = {
            -- Enable profiling plugin loads.
            enable = false,
        },
    },
}
