local util = require 'vimrc.util'

local function try_open_lua_file(file_name)
    local lua_dir = util.normalize_path(string.format('%s/lua/vimrc', vim.fn.stdpath('config')))
    local full_path = string.format('%s/%s', lua_dir, file_name)
    if not util.file_exists(full_path) then
        util.log_error(string.format('File "%s" does not exist.', full_path))
        return
    end

    vim.cmd(string.format([[vsplit %s]], full_path))
end

local LUA_PATH = string.format('%s/lua/vimrc', vim.fn.stdpath('config'))
local function complete_lua_files(arg_lead --[[cmd_line, cursor_pos]])
    local file_pattern = string.format('%s*.lua', arg_lead)
    local files = vim.fn.globpath(LUA_PATH, file_pattern, false, true)

    return util.tbl_map(files, function(path)
        return vim.fn.fnamemodify(path, ':t')
    end)
end

-- Open one of the lua configuration files.
util.user_command(
    'LFiles',
    function (args)
        try_open_lua_file(args.args)
    end,
    {nargs = 1, complete = complete_lua_files}
)

util.map('n', '<leader>ve', [[<cmd>silent NormalizeVSplit $MYVIMRC<cr>]])

util.map('n', '<leader>vs', function()
    -- Reload all modules starting with "vimrc."
    require('plenary.reload').reload_module('vimrc.')

    vim.cmd [[source $MYVIMRC]]
end)

util.map('n', '<leader>vl', [[<cmd>execute 'silent NormalizeVSplit ' . stdpath('config') . '/lua/vimrc/'<cr>]])
util.map('n', '<leader>vp', [[<cmd>execute 'silent NormalizeVSplit ' . stdpath('data') . '/site/pack/packer/'<cr>]])
