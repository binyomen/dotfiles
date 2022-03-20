local M = {}

-- Many commands here are taken from
-- https://vim.fandom.com/wiki/Swapping_characters,_words_and_lines, with
-- modifications by me.
--
-- The trick for forncing undo to restore the cursor position (see
-- "aa<bs><esc>" in the mappings) is from
-- https://vim.fandom.com/wiki/Restore_the_cursor_position_after_undoing_text_change_made_by_a_script.

local util = require 'util'

-- Swap current character with next and previous, keeping the cursor in the
-- same place.
util.map('n', '<leader>sc', [[xph]])
util.map('n', '<leader>sC', [[xhPl]])

-- Swap current word with the next and previous, keeping the cursor in the same place.
util.map('n', '<leader>sw', [["_yiwaa<bs><esc>:s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/g<cr>``]])
util.map('n', '<leader>sW', [["_yiwmzaa<bs><esc>?\w\+\_W\+\%#<cr>:s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/g<cr>`z]])

-- Push the current word to the left or right.
util.map('n', '<leader>sl', [["_yiwaa<bs><esc>?\w\+\_W\+\%#<cr>:s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/<cr>``]])
util.map('n', '<leader>sr', [["_yiwaa<bs><esc>:s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/<cr>``/\w\+\_W\+<cr>]])
util.map('n', '<m-h>', '<leader>sl', {noremap = false})
util.map('n', '<m-l>', '<leader>sr', {noremap = false})

-- Push the current line up and down.
util.map('n', '<m-k>', [[ddkP]])
util.map('n', '<m-j>', [[ddp]])

-- Push the current paragraph up and down.
util.map('n', '<m-K>', [[dap{{p]])
util.map('n', '<m-J>', [[dap}p]])

local swap_first_state = nil

local function get_swap_reg(motion)
    local command

    util.process_opfunc_command(motion, {
        line = function()
            command = [[silent normal! '[V']"zy]]
        end,
        char = function()
            command = [[silent normal! `[v`]"zy]]
        end,
        visual = function()
            command = string.format([[silent normal! `<%s`>"zy]], motion)
        end,
    })

    local backup_unnamed = vim.fn.getreginfo('"')
    local backup_z = vim.fn.getreginfo('z')

    vim.cmd(command)
    local reg = vim.fn.getreginfo('z')

    vim.fn.setreg('z', backup_z)
    vim.fn.setreg('"', backup_unnamed)

    return reg
end

local function do_swap_put(motion, reg)
    local command

    util.process_opfunc_command(motion, {
        line = function()
            command = [[silent normal! '[V']"zp]]
        end,
        char = function()
            command = [[silent normal! `[v`]"zp]]
        end,
        visual = function()
            command = string.format([[silent normal! `<%s`>"zp]], motion)
        end,
    })

    local backup_unnamed = vim.fn.getreginfo('"')
    local backup_z = vim.fn.getreginfo('z')

    vim.fn.setreg('z', reg)
    vim.cmd(command)

    vim.fn.setreg('z', backup_z)
    vim.fn.setreg('"', backup_unnamed)
end

local function select_swap_first(motion)
    local reg = get_swap_reg(motion)

    local is_visual = util.is_visual_motion(motion)
    local start_mark = is_visual and '<' or '['
    local end_mark = is_visual and '>' or ']'

    local start_pos = {
        line = vim.fn.line("'" .. start_mark),
        col = vim.fn.col("'" .. start_mark) - 1,
    }
    local end_pos = {
        line = vim.fn.line("'" .. end_mark),
        col = vim.fn.col("'" .. end_mark) - 1,
    }

    swap_first_state = {
        reg = reg,
        pos = vim.api.nvim_win_get_cursor(0 --[[window]]),
        motion = motion,
        start_mark = start_mark,
        end_mark = end_mark,
        start_pos = start_pos,
        end_pos = end_pos,
    }
end

local function perform_swap(motion)
    local reg = get_swap_reg(motion)

    -- Replace the text we're on.
    do_swap_put(motion, swap_first_state.reg)

    local pos = vim.api.nvim_win_get_cursor(0 --[[window]])

    vim.api.nvim_win_set_cursor(0 --[[window]], swap_first_state.pos)
    vim.api.nvim_buf_set_mark(
        0 --[[buffer]],
        swap_first_state.start_mark,
        swap_first_state.start_pos.line,
        swap_first_state.start_pos.col,
        {}
    )
    vim.api.nvim_buf_set_mark(
        0 --[[buffer]],
        swap_first_state.end_mark,
        swap_first_state.end_pos.line,
        swap_first_state.end_pos.col,
        {}
    )

    -- Replace the first text.
    do_swap_put(swap_first_state.motion, reg)

    -- Return back to where we were.
    vim.api.nvim_win_set_cursor(0 --[[window]], pos)

    swap_first_state = nil
end

function M.swap(motion)
    if motion == nil then
        vim.opt.opfunc = '__swap__swap_opfunc'
        return 'g@'
    end

    if swap_first_state == nil then
        select_swap_first(motion)
    else
        perform_swap(motion)
    end
end

-- Currently neovim won't repeat properly if you set the opfunc to a lua
-- function rather than a vim one. See
-- https://github.com/neovim/neovim/issues/17503.
vim.cmd [[
    function! __swap__swap_opfunc(motion) abort
        return v:lua.require('swap').swap(a:motion)
    endfunction
]]

util.map('x', '<leader>ss', [[:lua require('swap').swap(vim.fn.visualmode())<cr>]])
util.map('n', '<leader>ss', [[v:lua.require('swap').swap()]], {expr = true})

return M
