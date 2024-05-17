local M = {}

local treesitter_highlighter = require 'vim.treesitter.highlighter'

function M.default(v, default)
    if v == nil then
        if type(default) == 'function' then
            default = default()
        end

        return default
    else
        return v
    end
end

function M.vim_true(v)
    if v == nil then
        return false
    elseif type(v) == 'number' then
        return v ~= 0
    elseif type(v) == 'boolean' then
        return v
    else
        error('Invalid type for Vim boolean.')
    end
end

function M.vim_has(name)
    return vim.fn.has(name) == 1
end

function M.vim_executable(name)
    return vim.fn.executable(name) == 1
end

function M.vim_empty(name)
    return vim.fn.empty(name) == 1
end

function M.vim_pumvisible()
    return vim.fn.pumvisible() ~= 0
end

function M.echo(text, add_to_history)
    local add_to_history = M.default(add_to_history, false)
    vim.api.nvim_echo({{text}}, add_to_history, {})
end

function M.map(mode, lhs, rhs, opts)
    -- Allow an rhs function to be specified last for better formatting.
    if type(lhs) == 'table' then
        local temp = lhs
        lhs = rhs
        rhs = opts
        opts = temp
    end

    local opts = vim.tbl_extend('force', {silent = true}, M.default(opts, {}))
    vim.keymap.set(mode, lhs, rhs, opts)
end

function M.user_command(name, command, opts)
    vim.api.nvim_create_user_command(name, command, opts)
end

function M.augroup(name, autocmds)
    local augroup_id = vim.api.nvim_create_augroup(name, {})

    for _, autocmd in ipairs(autocmds) do
        local event = autocmd[1]
        local opts = vim.tbl_extend('error', autocmd[2], {group = augroup_id})
        vim.api.nvim_create_autocmd(event, opts)
    end

    return augroup_id
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
    vim.bo[buf].buflisted = false
    vim.api.nvim_buf_delete(buf, {unload = true})
end

function M.normalize_path(path)
    return vim.fn.simplify(vim.fn.resolve(vim.fn.expandcmd(path)))
end

local function normalize_command(name, command)
    M.user_command(
        name,
        function(args)
            local normalized_path = M.normalize_path(args.args)
            vim.cmd[command](normalized_path)
        end,
        {nargs = 1, complete = 'file'}
    )
end
normalize_command('NormalizeEdit', 'edit')
normalize_command('NormalizeSplit', 'split')
normalize_command('NormalizeVSplit', 'vsplit')
normalize_command('NormalizeTabEdit', 'tabedit')

-- A useful shortcut that looks like a string prefix in C++.
_G.t = vim.keycode

local LINE_MOTION = 'line'
local CHAR_MOTION = 'char'
local BLOCK_MOTION = 'block'

function M.process_opfunc_command(motion, cases)
    vim.validate {
        motion = {motion, 'string'},
        ['cases.line'] = {cases.line, 'function'},
        ['cases.char'] = {cases.char, 'function'},
        ['cases.block'] = {cases.block, 'function'},
    }
    if motion == LINE_MOTION then
        cases.line(motion)
    elseif motion == CHAR_MOTION then
        cases.char(motion)
    elseif motion == BLOCK_MOTION then
        cases.block(motion)
    else
        error(string.format('Invalid motion: %s', motion))
    end
end

function M.opfunc_normal_command(motion, normal_command)
    local command

    M.process_opfunc_command(motion, {
        line = function()
            command = string.format([['[V']%s]], normal_command)
        end,
        char = function()
            command = string.format([[`[v`]%s]], normal_command)
        end,
        block = function()
            command = string.format(t[[`[<c-v>`]%s]], normal_command)
        end,
    })

    vim.cmd.normal {command, bang = true, mods = {silent = true}}
end

function M.opfunc_ex_command(ex_command)
    local ex_command = vim.deepcopy(ex_command)
    ex_command.range = {vim.fn.line("'["), vim.fn.line("']")}
    vim.cmd(ex_command)
end

function M.motion_to_visual_char(motion)
    if motion == CHAR_MOTION then
        return 'v'
    elseif motion == LINE_MOTION then
        return 'V'
    elseif motion == BLOCK_MOTION then
        return t'<c-v>'
    else
        error(string.format('Invalid motion: %s', motion))
    end
end

function M.highlight_opfunc_range(namespace, group, motion, reg)
    local start_pos = vim.fn.getpos("'[")
    local finish_pos = vim.fn.getpos("']")

    local start = {start_pos[2] - 1, start_pos[3] - 1 + start_pos[4]}
    local finish = {finish_pos[2] - 1, finish_pos[3] - 1 + finish_pos[4]}

    local visual_char = M.motion_to_visual_char(motion)

    -- We need to finagle the input of vim.highlight.range a bit due to
    -- https://github.com/neovim/neovim/issues/18154 and
    -- https://github.com/neovim/neovim/issues/18155.
    if visual_char == 'V' then
        start[2] = 0
        finish[2] = 9999999
    elseif visual_char == t'<c-v>' then
        visual_char = reg.regtype
    end

    vim.highlight.range(
        0 --[[bufnr]],
        namespace,
        group,
        start,
        finish,
        {regtype = visual_char, inclusive = true}
    )
end

function M.get_opfunc_reg(motion)
    local backup_unnamed = vim.fn.getreginfo('"')
    local backup_z = vim.fn.getreginfo('z')

    M.opfunc_normal_command(motion, '"zy')
    local reg = vim.fn.getreginfo('z')

    vim.fn.setreg('z', backup_z)
    vim.fn.setreg('"', backup_unnamed)

    return reg
end

function M.put_opfunc_reg(motion, reg)
    local backup_unnamed = vim.fn.getreginfo('"')
    local backup_z = vim.fn.getreginfo('z')

    vim.fn.setreg('z', reg)
    M.opfunc_normal_command(motion, '"zp')

    vim.fn.setreg('z', backup_z)
    vim.fn.setreg('"', backup_unnamed)
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

function M.get_extmark_pos(extmark, namespace)
    return vim.api.nvim_buf_get_extmark_by_id(0 --[[buffer]], namespace, extmark, {})
end

function M.get_extmark_from_cursor(namespace)
    local pos = vim.api.nvim_win_get_cursor(0 --[[window]])
    return M.get_extmark_from_pos({pos[1] - 1, pos[2]}, namespace)
end

function M.set_cursor_from_extmark(extmark, namespace)
    local extmark_pos = M.get_extmark_pos(extmark, namespace)
    vim.api.nvim_win_set_cursor(0 --[[window]], {extmark_pos[1] + 1, extmark_pos[2]})
end

-- If we've reloaded the module make sure we pick up from where we left off.
_G.vimrc__unique_id = M.default(_G.vimrc__unique_id, -1)
function M.unique_id()
    _G.vimrc__unique_id = _G.vimrc__unique_id + 1
    return _G.vimrc__unique_id
end

M.opfuncs = {}
local function create_operator(inherent_motion, op)
    local opfunc_name = string.format('vimrc__opfunc_%d', M.unique_id())
    local opfunc_lambda = string.format(
        [[{motion -> v:lua.require('vimrc.util').opfuncs.%s(motion)}]],
        opfunc_name
    )

    local opfunc = function(motion)
        if motion == nil then
            vim.o.operatorfunc = opfunc_lambda
            return 'g@' .. inherent_motion
        end

        op(motion)

        -- In case anything in `op` changes the opfunc, reset it so we can
        -- still do repeat.
        vim.o.operatorfunc = opfunc_lambda
    end

    M.opfuncs[opfunc_name] = opfunc
    return opfunc
end

function M.new_operator(op)
    return create_operator('', op)
end

function M.new_operator_with_inherent_motion(inherent_motion, op)
    return create_operator(inherent_motion, op)
end

function M.log_debug(msg)
    vim.notify(msg, vim.log.levels.DEBUG)
end

function M.log_error(msg)
    vim.notify(msg, vim.log.levels.ERROR)
end

function M.log_info(msg)
    vim.notify(msg, vim.log.levels.INFO)
end

function M.log_trace(msg)
    vim.notify(msg, vim.log.levels.TRACE)
end

function M.log_warn(msg)
    vim.notify(msg, vim.log.levels.WARN)
end

function M.reg_put(reg)
    local backup_unnamed = vim.fn.getreginfo('"')
    local backup_z = vim.fn.getreginfo('z')

    vim.fn.setreg('z', reg)
    vim.cmd.normal {'"zp', bang = true}

    vim.fn.setreg('z', backup_z)
    vim.fn.setreg('"', backup_unnamed)
end

if M.vim_has('win32') then
    M.PATH_SEP = '\\'
else
    M.PATH_SEP = '/'
end

function M.enable_pwsh()
    vim.o.shell = 'pwsh'
    vim.o.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'
    vim.o.shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    vim.o.shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    vim.o.shellquote = ''
    vim.o.shellxquote = ''

    vim.o.shelltemp = false
end

function M.enable_cmd()
    vim.o.shell = 'cmd.exe'
    vim.o.shellcmdflag = '/s /c'
    vim.o.shellredir = '>%s 2>&1'
    vim.o.shellpipe = '>%s 2>&1'
    vim.o.shellquote = ''
    vim.o.shellxquote = '"'

    vim.o.shelltemp = true
end

function M.paste_image()
    if M.vim_has('win32') then
        M.enable_cmd()
    end

    vim.fn['mdip#MarkdownClipboardImage']()

    if M.vim_has('win32') then
        M.enable_pwsh()
    end
end

-- These functions just reverse the order of some builtin functions so that
-- they format nicer in code.
function M.defer(timeout, fn)
    return vim.defer_fn(fn, timeout)
end
function M.filter(t, func)
    return vim.tbl_filter(func, t)
end
function M.tbl_map(t, func)
    return vim.tbl_map(func, t)
end

function M.filter_map(list, f)
    local new_list = {}

    for _, item in ipairs(list) do
        local result = f(item)
        if result ~= nil then
            table.insert(new_list, result)
        end
    end

    return new_list
end

function M.enable_conceal_if_not_in_diff()
    if not vim.wo.diff then
        vim.wo.conceallevel = 2
    else
        vim.w.vimrc__reenable_conceal_when_diff_disabled = true
    end
end

function M.browse_to(uri)
    vim.fn['netrw#BrowseX'](uri, 0)
end

function M.split(s, sep)
    local result = {}

    local current = ''
    for i = 1,#s do
        local c = s:sub(i, i)
        if c == sep then
            table.insert(result, current)
            current = ''
        else
            current = current .. c
        end
    end

    table.insert(result, current)

    return result
end

function M.feedkeys(s, mode)
    vim.api.nvim_feedkeys(s, mode, false --[[escape_ks]])
end

function M.buffer_is_file(buf)
    local buf = M.default(buf, 0)

    local buftype = vim.bo[buf].buftype
    if buftype == 'nofile' or
        buftype == 'quickfix' or
        buftype == 'terminal' or
        buftype == 'prompt' then
        return false
    end

    local bufname = vim.api.nvim_buf_get_name(buf)
    if bufname == '' then
        return false
    end

    return M.file_exists(bufname)
end

function M.set_tab_size(tab_size, global_opt)
    local global_opt = M.default(global_opt, false)

    local opt
    if global_opt then
        opt = vim.o
    else
        opt = vim.bo
    end

    opt.tabstop = tab_size
    opt.softtabstop = tab_size
    opt.shiftwidth = tab_size
end

function M.treesitter_active(buffer)
    local buffer = M.default(buffer, vim.api.nvim_get_current_buf())
    return treesitter_highlighter.active[buffer]
end

function M.is_floating_window(window)
    local window = M.default(window, 0)
    return vim.api.nvim_win_get_config(window).relative ~= ''
end

M.MARKDOWN_STYLE = 'markdown'
M.RESTRUCTURED_TEXT_STYLE = 'reStructuredText'
local POSSIBLE_STYLES = {M.MARKDOWN_STYLE, M.RESTRUCTURED_TEXT_STYLE}

function M.set_table_style(style)
    if style == M.MARKDOWN_STYLE then
        vim.b.table_mode_corner = '|'
        vim.b.table_mode_corner_corner = '|'
        vim.b.table_mode_header_fillchar = '-'
    elseif style == M.RESTRUCTURED_TEXT_STYLE then
        vim.b.table_mode_corner = '+'
        vim.b.table_mode_corner_corner = '+'
        vim.b.table_mode_header_fillchar = '='
    else
        error('Invalid style.')
    end
end

local function complete_set_table_style(arg_lead --[[cmd_line, cursor_pos]])
    local arg_lead_lower = arg_lead:lower()

    return M.filter_map(POSSIBLE_STYLES, function(style)
        local result = style:lower():find(arg_lead_lower, 1 --[[init]], true --[[plain]])
        if result == 1 then
            return style
        else
            return nil
        end
    end)
end

M.user_command(
    'SetTableStyle',
    function(args)
        M.set_table_style(args.args)
    end,
    {nargs = 1, complete = complete_set_table_style}
)

return M
