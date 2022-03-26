local M = {}

local function merge_default_opts(opts)
    return vim.tbl_extend('force', {silent = true, noremap = true}, opts or {})
end

function M.map(mode, lhs, rhs, opts)
    local opts = merge_default_opts(opts)
    vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
end

function M.buf_map(buf, mode, lhs, rhs, opts)
    local opts = merge_default_opts(opts)
    vim.api.nvim_buf_set_keymap(buf, mode, lhs, rhs, opts)
end

function M.file_exists(path)
    local s = vim.loop.fs_stat(path)
    return s ~= nil and s.type == 'file'
end

function M.directory_exists(path)
    local s = vim.loop.fs_stat(path)
    return s ~= nil and s.type == 'directory'
end

function M.buf_delete(buf)
    -- Marking the buffer as unlisted and unloading it has the same effect as
    -- the :bdelete command.
    vim.api.nvim_buf_set_option(buf, 'buflisted', false)
    vim.api.nvim_buf_delete(buf, {unload = true})
end

function M.normalize_path(path)
    return vim.fn.simplify(vim.fn.resolve(vim.fn.expandcmd(path)))
end

vim.cmd [[command! -nargs=1 NormalizeEdit execute 'edit ' . v:lua.require('vimrc.util').normalize_path(<q-args>)]]

function M.replace_termcodes(s)
    return vim.api.nvim_replace_termcodes(s, true --[[from_part]], true --[[do_lt]], true --[[special]])
end

-- A useful shortcut that looks like a string prefix in C++.
_G.t = M.replace_termcodes

local LINE_MOTION = 'line'
local CHAR_MOTION = 'char'
local VISUAL_MOTION = 'v'
local VISUAL_LINE_MOTION = 'V'
local VISUAL_BLOCK_MOTION = t'<c-v>'

function M.is_visual_motion(motion)
    return
        motion == VISUAL_MOTION or
        motion == VISUAL_LINE_MOTION or
        motion == VISUAL_BLOCK_MOTION
end

function M.process_opfunc_command(motion, cases)
    if motion == LINE_MOTION then
        cases.line(motion)
    elseif motion == CHAR_MOTION then
        cases.char(motion)
    elseif M.is_visual_motion(motion) then
        cases.visual(motion)
    else
        error(string.format('Invalid motion: %s', motion))
    end
end

-- `pos` should be (0, 0)-indexed.
function M.get_extmark_from_pos(pos, namespace)
    return vim.api.nvim_buf_set_extmark(
        0 --[[buffer]],
        namespace,
        pos[1],
        pos[2],
        {}
    )
end

function M.get_extmark_from_cursor(namespace)
    local pos = vim.api.nvim_win_get_cursor(0 --[[window]])
    return M.get_extmark_from_pos({pos[1] - 1, pos[2]}, namespace)
end

function M.set_cursor_from_extmark(extmark, namespace)
    local extmark_pos = vim.api.nvim_buf_get_extmark_by_id(
        0 --[[buffer]],
        namespace,
        extmark,
        {}
    )
    vim.api.nvim_win_set_cursor(0 --[[window]], {extmark_pos[1] + 1, extmark_pos[2]})
end

-- If we've reloaded the module make sure we pick up from where we left off.
_G.__unique_id = _G.__unique_id or -1
function M.unique_id()
    _G.__unique_id = _G.__unique_id + 1
    return _G.__unique_id
end

M.opfuncs = {}
local function create_operator(op, inherent_motion)
    local id = M.unique_id()
    local vim_function_name = string.format('__opfunc_%d', id)

    -- Currently neovim won't repeat properly if you set the opfunc to a lua
    -- function rather than a vim one. See
    -- https://github.com/neovim/neovim/issues/17503.
    vim.cmd(string.format([[
        function! %s(motion) abort
            call v:lua.require('vimrc.util').opfuncs.%s(a:motion)
        endfunction
    ]], vim_function_name, vim_function_name))

    local opfunc = function(motion)
        if motion == nil then
            vim.opt.opfunc = vim_function_name
            return 'g@' .. inherent_motion
        end

        op(motion)
    end

    M.opfuncs[vim_function_name] = opfunc
    return opfunc
end

function M.new_operator(op)
    return create_operator(op, '')
end

function M.new_operator_with_inherent_motion(inherent_motion, op)
    return create_operator(inherent_motion, op)
end

return M
