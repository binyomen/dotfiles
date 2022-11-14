local util = require 'vimrc.util'
local statusline = require 'vimrc.statusline'

-- Diff two files.
util.user_command(
    'Diff',
    function(args)
        assert(#args.fargs == 2)

        local file1 = args.fargs[1]
        local file2 = args.fargs[2]

        vim.cmd.tabedit(file1)
        statusline.set_tab_page_name('Diff')
        vim.cmd.diffsplit(file2)
    end,
    {nargs = '+', complete = 'file'}
)

-- Display a diff for selected text.
local first_diff_state = nil
local namespace = vim.api.nvim_create_namespace('vimrc.diff')

local function clear_diff_state()
    first_diff_state = nil

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        vim.api.nvim_buf_clear_namespace(buf, namespace, 0 --[[line_start]], -1 --[[line_end]])
    end
end

local function select_first_diff(motion)
    local reg = util.get_opfunc_reg(motion)
    util.highlight_opfunc_range(namespace, 'Search', motion, reg)

    first_diff_state = {
        reg = reg,
        filetype = vim.bo.filetype,
    }
end

local function create_diff_buf(win, reg, filetype)
    local buf = vim.api.nvim_create_buf(false --[[listed]], true --[[scratch]])
    vim.api.nvim_win_set_buf(win, buf)

    vim.api.nvim_buf_set_name(buf, string.format('Diff [%d]', buf))

    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].filetype = filetype

    vim.cmd.normal {'V', bang = true}
    util.reg_put(reg)
end

local function perform_diff(motion)
    local reg_left = first_diff_state.reg
    local filetype_left = first_diff_state.filetype
    local reg_right = util.get_opfunc_reg(motion)
    local filetype_right = vim.bo.filetype

    clear_diff_state()

    vim.cmd.tabedit()
    statusline.set_tab_page_name('Diff')

    -- Clear the initial no-name buffer on close.
    vim.bo.bufhidden = 'wipe'

    local win_left = vim.api.nvim_get_current_win()
    create_diff_buf(win_left, reg_left, filetype_left)

    vim.cmd.vsplit()
    local win_right = vim.api.nvim_get_current_win()
    create_diff_buf(win_right, reg_right, filetype_right)

    vim.cmd.diffthis()
    vim.cmd.wincmd 'p'
    vim.cmd.diffthis()
end

-- Mark text for a diff.
util.map({'n', 'x'}, {expr = true}, '<leader>dd', util.new_operator(function(motion)
    if first_diff_state == nil then
        select_first_diff(motion)
    else
        perform_diff(motion)
    end
end))

-- Cancel a pending diff.
util.map('n', {expr = true}, '<leader>dx', util.new_operator_with_inherent_motion('l', function()
    clear_diff_state()
end))
