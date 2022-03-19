local M = {}

local util = require 'util'

function M.complete_lua_files(--[[arg_lead, cmd_line, cursor_pos]])
    local lua_path = string.format('%s/lua', vim.fn.stdpath('config'))
    local files = vim.fn.globpath(lua_path, '**/*.lua', false, true)

    local results = vim.tbl_map(
        function(path)
            return vim.fn.fnamemodify(path, ':t')
        end,
        files)

    -- Returning as a newline separate string rather than a list means vim
    -- will handle arg_lead for us.
    return vim.fn.join(results, '\n')
end

function M.try_open_lua_file(file_name)
    local full_path = string.format('%s/lua/%s', vim.fn.stdpath('config'), file_name)
    if not util.file_exists(full_path) then
        vim.notify(string.format('File "%s" does not exist.', full_path), vim.log.levels.ERROR)
        return
    end

    vim.cmd(string.format([[edit %s]], full_path))
end

function M.lua_source()
    local buffer_path = vim.fn.expand('%')
    local extension = vim.fn.fnamemodify(buffer_path, ':e')
    if extension ~= 'lua' then
        vim.notify('LSource is only supported on lua files.', vim.log.levels.ERROR)
        return
    end

    local module_name = vim.fn.fnamemodify(buffer_path, ':t:r')
    package.loaded[module_name] = nil
    require(module_name)
end

function M.source()
    -- If we're in a lua file, source it first.
    if vim.opt_local.filetype:get() == 'lua' then
        M.lua_source()
    end

    vim.cmd [[source $MYVIMRC]]
end

function M.lua_echo(args)
    local chunk = string.format('return %s', args)
    local f = assert(loadstring(chunk))
    print(vim.inspect(f()))
end

-- Open one of the lua configuration files.
vim.cmd [[command! -nargs=1 -complete=custom,v:lua.package.loaded.config.complete_lua_files LFiles lua require('config').try_open_lua_file(<q-args>)]]

vim.cmd [[command! -nargs=0 LSource lua require('config').lua_source()]]
vim.cmd [[command! -nargs=* LEcho lua require('config').lua_echo(<q-args>)]]

util.map('n', '<leader>ve', [[<cmd>silent NormalizeEdit $MYVIMRC<cr>]])
util.map('n', '<leader>vs', [[<cmd>lua require('config').source()<cr>]])

util.map('n', '<leader>vl', [[<cmd>execute 'silent NormalizeEdit ' . stdpath('config') . '/lua/'<cr>]])
util.map('n', '<leader>vp', [[<cmd>execute 'silent NormalizeEdit ' . stdpath('data') . '/site/pack/packer/'<cr>]])

return M
