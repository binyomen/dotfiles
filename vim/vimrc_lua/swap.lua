local M = {}

-- Many commands here are taken from
-- https://vim.fandom.com/wiki/Swapping_characters,_words_and_lines, with
-- modifications by me.
--
-- The trick for forcing undo to restore the cursor position (see
-- "ia<bs><esc>l" in the mappings) is from
-- https://vim.fandom.com/wiki/Restore_the_cursor_position_after_undoing_text_change_made_by_a_script.

local util = require 'vimrc.util'

local swap_first_state = nil
local namespace = vim.api.nvim_create_namespace('swap')

local function get_extmark_pos(extmark)
    return vim.api.nvim_buf_get_extmark_by_id(0 --[[buffer]], namespace, extmark, {})
end

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
    local start_mark_string = is_visual and '<' or '['
    local end_mark_string = is_visual and '>' or ']'

    local start_extmark = vim.api.nvim_buf_set_extmark(
        0 --[[buffer]],
        namespace,
        vim.fn.line("'" .. start_mark_string) - 1,
        vim.fn.col("'" .. start_mark_string) - 1,
        {}
    )
    local end_extmark = vim.api.nvim_buf_set_extmark(
        0 --[[buffer]],
        namespace,
        vim.fn.line("'" .. end_mark_string) - 1,
        vim.fn.col("'" .. end_mark_string) - 1,
        {}
    )

    swap_first_state = {
        reg = reg,
        motion = motion,
        start_mark_string = start_mark_string,
        end_mark_string = end_mark_string,
        start_extmark = start_extmark,
        end_extmark = end_extmark,
    }
end

local function perform_swap(motion)
    local reg = get_swap_reg(motion)

    -- Replace the text we're on.
    do_swap_put(motion, swap_first_state.reg)

    local pos = vim.api.nvim_win_get_cursor(0 --[[window]])
    local extmark = vim.api.nvim_buf_set_extmark(
        0 --[[buffer]],
        namespace,
        pos[1] - 1 --[[line]],
        pos[2] --[[col]],
        {}
    )

    local start_extmark = get_extmark_pos(swap_first_state.start_extmark)
    local end_extmark = get_extmark_pos(swap_first_state.end_extmark)
    vim.api.nvim_buf_set_mark(
        0 --[[buffer]],
        swap_first_state.start_mark_string,
        start_extmark[1] + 1,
        start_extmark[2],
        {}
    )
    vim.api.nvim_buf_set_mark(
        0 --[[buffer]],
        swap_first_state.end_mark_string,
        end_extmark[1] + 1,
        end_extmark[2],
        {}
    )

    -- Replace the first text.
    do_swap_put(swap_first_state.motion, reg)

    -- Return to our original position.
    local extmark_pos = get_extmark_pos(extmark)
    vim.api.nvim_win_set_cursor(0 --[[window]], {extmark_pos[1] + 1, extmark_pos[2]})

    swap_first_state = nil
    vim.api.nvim_buf_clear_namespace(0 --[[buffer]], namespace, 0 --[[line_start]], -1 --[[line_end]])
end

M.swap = util.new_operator(function(motion)
    if swap_first_state == nil then
        select_swap_first(motion)
    else
        perform_swap(motion)
    end
end)

local function move_word_keep_cursor(forward)
    -- This is necessary to restore our cursor to the original position after
    -- an undo.
    vim.cmd(t'normal! ia<bs><esc>l')

    local pos = vim.api.nvim_win_get_cursor(0 --[[window]])

    -- If we're moving backwards move to the beginning of the word so we don't
    -- just find our own word.
    if not forward then
        vim.cmd [[normal! "_yiw]]
    end

    vim.cmd(t'normal <leader>ssiw')

    local flags = forward and 'z' or 'b'
    vim.fn.search([[\w\+]], flags)

    vim.cmd(t'normal <leader>ssiw')

    vim.api.nvim_win_set_cursor(0 --[[window]], pos)
end

local function move_word(forward)
    vim.cmd(t'normal <leader>ssiw')

    -- If we're moving backwards move to the beginning of the word so we don't
    -- just find our own word.
    if not forward then
        vim.cmd [[normal! "_yiw]]
    end

    local flags = forward and 'z' or 'b'
    vim.fn.search([[\w\+]], flags)

    vim.cmd(t'normal <leader>ssiw')
end

M.next_word_keep_cursor = util.new_operator_with_inherent_motion('l', function()
    return move_word_keep_cursor(true)
end)

M.previous_word_keep_cursor = util.new_operator_with_inherent_motion('l', function()
    return move_word_keep_cursor(false)
end)

M.next_word = util.new_operator_with_inherent_motion('l', function()
    return move_word(true)
end)

M.previous_word = util.new_operator_with_inherent_motion('l', function()
    return move_word(false)
end)

-- Swap arbitrary text.
util.map('x', '<leader>ss', [[:lua require('vimrc.swap').swap(vim.fn.visualmode())<cr>]])
util.map('n', '<leader>ss', [[v:lua.require('vimrc.swap').swap()]], {expr = true})

-- Swap current word with the next and previous, keeping the cursor in the same place.
util.map('n', '<leader>sw', [[v:lua.require('vimrc.swap').next_word_keep_cursor()]], {expr = true})
util.map('n', '<leader>sW', [[v:lua.require('vimrc.swap').previous_word_keep_cursor()]], {expr = true})

-- Push the current word to the left or right.
util.map('n', '<leader>sl', [[v:lua.require('vimrc.swap').previous_word()]], {expr = true})
util.map('n', '<leader>sr', [[v:lua.require('vimrc.swap').next_word()]], {expr = true})
util.map('n', '<m-h>', '<leader>sl', {noremap = false})
util.map('n', '<m-l>', '<leader>sr', {noremap = false})

-- Swap current character with next and previous, keeping the cursor in the
-- same place.
util.map('n', '<leader>sc', 'xph')
util.map('n', '<leader>sC', 'xhPl')

-- Push the current character to the left and right.
util.map('n', '<m-H>', 'xhP')
util.map('n', '<m-L>', 'xp')

-- Push the current character up and down.
util.map('n', '<m-K>', 'xkvpjPk')
util.map('n', '<m-J>', 'xjvpkPj')

-- Push the current line up and down.
util.map('n', '<m-k>', 'ddkP')
util.map('n', '<m-j>', 'ddp')

-- Push the current paragraph up and down.
util.map('n', '<m-[>', 'dap{{p')
util.map('n', '<m-]>', 'dap}p')

return M
