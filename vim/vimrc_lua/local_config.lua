local M = {}

local util = require 'vimrc.util'

_G.LOCAL_CONFIG = nil
_G.LOADED_CONFIGS = nil

-- Currently only one config per directory is supported.
local function add_configs_for_dir(dir, configs)
    local path = string.format('%s/nvim_local.lua', dir)
    if util.file_exists(path) then
        local content = vim.secure.read(path)
        if content ~= nil then
            table.insert(configs, {path = path, content = content})
        end
    end
end

local function find_local_configs()
    local configs = {}

    local prev_dir = nil
    local dir = vim.fn.getcwd()
    while prev_dir ~= dir do
        add_configs_for_dir(dir, configs)

        prev_dir = dir
        dir = vim.fn.fnamemodify(dir, ':h')
    end

    return configs
end

local function merge_configs(c1, c2)
    local result = vim.deepcopy(c1)

    for key, value in pairs(c2) do
        if result[key] == nil then
            result[key] = value
        elseif vim.tbl_islist(value) then
            local new_list = result[key]
            for _, item in ipairs(value) do
                table.insert(new_list, item)
            end

            result[key] = new_list
        elseif type(value) == 'table' then
            result[key] = merge_configs(result[key], value)
        elseif type(value) == 'function' then
            -- Replace the two functions with another function which calls both.
            local original_function = result[key]
            result[key] = function(...)
                original_function(...)
                value(...)
            end
        else
            result[key] = value
        end
    end

    return result
end

function M.load_configs()
    if _G.LOCAL_CONFIG ~= nil then
        return
    end

    local result = {}

    -- More deeply nested configs come first in the list. Handle those last so
    -- they have the opportunity to override anything.
    local configs = find_local_configs()
    for i = #configs,1,-1 do
        local config = configs[i]

        local f = assert(loadstring(config.content, config.path))
        result = merge_configs(result, f(config.path))
    end

    _G.LOADED_CONFIGS = configs
    _G.LOCAL_CONFIG = result
end

return M
