-- Many commands here are taken from
-- https://vim.fandom.com/wiki/Swapping_characters,_words_and_lines, with
-- modifications by me.
--
-- The trick for forcing undo to restore the cursor position (see
-- "ia<bs><esc>l" in the mappings) is from
-- https://vim.fandom.com/wiki/Restore_the_cursor_position_after_undoing_text_change_made_by_a_script.

local util = require 'vimrc.util'

local swap_first_state = nil
local namespace = vim.api.nvim_create_namespace('vimrc.swap')

local function clear_swap_state()
    swap_first_state = nil
    vim.api.nvim_buf_clear_namespace(0 --[[buffer]], namespace, 0 --[[line_start]], -1 --[[line_end]])
end

local function select_swap_first(motion)
    local start_extmark = vim.api.nvim_buf_set_extmark(
        0 --[[buffer]],
        namespace,
        vim.fn.line("'[") - 1,
        vim.fn.col("'[") - 1,
        {}
    )
    local end_extmark = vim.api.nvim_buf_set_extmark(
        0 --[[buffer]],
        namespace,
        vim.fn.line("']") - 1,
        vim.fn.col("']") - 1,
        {}
    )

    local reg = util.get_opfunc_reg(motion)
    util.highlight_opfunc_range(namespace, 'Search', motion, reg)

    swap_first_state = {
        reg = reg,
        motion = motion,
        start_extmark = start_extmark,
        end_extmark = end_extmark,
    }
end

local function perform_swap(motion)
    local reg = util.get_opfunc_reg(motion)

    -- Replace the text we're on.
    util.put_opfunc_reg(motion, swap_first_state.reg)

    local pos = vim.api.nvim_win_get_cursor(0 --[[window]])
    local extmark = vim.api.nvim_buf_set_extmark(
        0 --[[buffer]],
        namespace,
        pos[1] - 1 --[[line]],
        pos[2] --[[col]],
        {}
    )

    local start_extmark = util.get_extmark_pos(swap_first_state.start_extmark, namespace)
    local end_extmark = util.get_extmark_pos(swap_first_state.end_extmark, namespace)
    vim.api.nvim_buf_set_mark(
        0 --[[buffer]],
        '[',
        start_extmark[1] + 1,
        start_extmark[2],
        {}
    )
    vim.api.nvim_buf_set_mark(
        0 --[[buffer]],
        ']',
        end_extmark[1] + 1,
        end_extmark[2],
        {}
    )

    -- Replace the first text.
    util.put_opfunc_reg(swap_first_state.motion, reg)

    -- Return to our original position. We might fail if the extmark no longer
    -- exists in the file. That's OK.
    local extmark_pos = util.get_extmark_pos(extmark, namespace)
    pcall(vim.api.nvim_win_set_cursor, 0 --[[window]], {extmark_pos[1] + 1, extmark_pos[2]})

    clear_swap_state()
end

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

-- Swap arbitrary text.
util.map({'n', 'x'}, {expr = true}, '<leader>ss', util.new_operator(function(motion)
    if swap_first_state == nil then
        select_swap_first(motion)
    else
        perform_swap(motion)
    end
end))

-- Cancel the pending swap.
util.map('n', {expr = true}, '<leader>sx', util.new_operator_with_inherent_motion('l', function()
    clear_swap_state()
end))

-- Swap current word with the next and previous, keeping the cursor in the same place.
util.map('n', {expr = true}, '<leader>sw', util.new_operator_with_inherent_motion('l', function()
    move_word_keep_cursor(true)
end))
util.map('n', {expr = true}, '<leader>sW', util.new_operator_with_inherent_motion('l', function()
    move_word_keep_cursor(false)
end))

-- Push the current word to the left or right.
util.map('n', {expr = true}, '<leader>sl', util.new_operator_with_inherent_motion('l', function()
    move_word(false)
end))
util.map('n', {expr = true}, '<leader>sr', util.new_operator_with_inherent_motion('l', function()
    move_word(true)
end))
util.map('n', '<m-h>', '<leader>sl', {remap = true})
util.map('n', '<m-l>', '<leader>sr', {remap = true})

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
