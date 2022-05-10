local M = {}

local cm = require 'plenary.context_manager'
local util = require 'vimrc.util'

local TRUST_DIR = string.format('%s/local_config', vim.fn.stdpath('data'))
local TRUST_FILE = string.format('%s/trust.json', TRUST_DIR)

local FILE_MODE = 0b111111111 -- octal 777

_G.LOCAL_CONFIG = nil
_G.LOADED_CONFIGS = nil

local function ensure_trust_file()
    if not util.directory_exists(TRUST_DIR) then
        assert(vim.loop.fs_mkdir(TRUST_DIR, FILE_MODE))
    end

    if not util.file_exists(TRUST_FILE) then
        cm.with(cm.open(TRUST_FILE, 'w'), function(f)
            assert(f:write('{}'))
        end)
    end
end

local function read_file(file_name)
    return cm.with(cm.open(file_name), function (f)
        return assert(f:read('*a'))
    end)
end

local function read_trust_file()
    ensure_trust_file()
    local contents = read_file(TRUST_FILE)
    return vim.json.decode(contents)
end

local function write_trust_file(o)
    ensure_trust_file()
    cm.with(cm.open(TRUST_FILE, 'w'), function(f)
        assert(f:write(vim.json.encode(o)))
    end)
end

local function trust(config)
    local o = read_trust_file()

    if not o[config] then
        local contents = read_file(config)
        o[config] = {is_trusted = true, checksum = vim.fn.sha256(contents)}

        write_trust_file(o)
    end
end

local function distrust(config)
    local o = read_trust_file()

    if not o[config] then
        o[config] = {is_trusted = false}
        write_trust_file(o)
    end
end

local function is_trusted(config)
    local o = read_trust_file()
    if not o[config] or not o[config].is_trusted then
        return false
    end

    local current_checksum = vim.fn.sha256(read_file(config))
    if current_checksum ~= o[config].checksum then
        -- The checksums don't match anymore. Remove the object from the file
        -- and return false.
        o[config] = nil
        write_trust_file(o)

        return false
    end

    return true
end

local function is_untrusted(config)
    local o = read_trust_file()
    return o[config] and not o[config].is_trusted
end

-- Currently only one config per directory is supported.
local function add_configs_for_dir(dir, configs)
    local file_name = string.format('%s/nvim_local.lua', dir)
    if util.file_exists(file_name) then
        table.insert(configs, file_name)
    end
end

local function remove_untrusted_configs(configs)
    local final_configs = {}

    for _, config in ipairs(configs) do
        if is_trusted(config) then
            table.insert(final_configs, config)
        elseif not is_untrusted(config) then
            local choice = vim.fn.confirm(config, '&Ignore for now\n&Trust\n&Distrust', 1)
            if choice == 2 then
                trust(config)
                table.insert(final_configs, config)
            elseif choice == 3 then
                distrust(config)
            end
        end
    end

    return final_configs
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

    return remove_untrusted_configs(configs)
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

        local f = assert(loadfile(config))
        result = merge_configs(result, f(config))
    end

    _G.LOADED_CONFIGS = configs
    _G.LOCAL_CONFIG = result
end

return M
