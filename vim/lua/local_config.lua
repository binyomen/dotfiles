local M = {}

local CONFIG_ENV = {}

_G.LOCAL_CONFIG = nil
_G.LOADED_CONFIGS = nil

-- Currently only one config is supported.
local function add_configs_for_dir(dir, configs)
    local file_name = string.format('%s/nvim_local.lua', dir)
    local f = io.open(file_name)
    if f then
        f:close()
        table.insert(configs, file_name)
    end
end

local function remove_untrusted_configs(configs)
    local final_configs = {}

    for _, config in ipairs(configs) do
        local choice = vim.fn.confirm(config, '&Ignore for now\n&Trust\n&Distrust', 1)
        if choice == 2 then
            table.insert(final_configs, config)
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

function M.load_configs()
    if _G.LOCAL_CONFIG ~= nil then
        return
    end

    local result = {}

    -- More deeply nested configs come first in the list. Handle those last so
    -- they have the opportunity to override anything.
    local configs = find_local_configs()
    for i = #configs,1,-1 do
        local f = assert(loadfile(configs[i]))

        -- Restrict what the local config script has access to.
        setfenv(f, CONFIG_ENV)

        result = vim.tbl_extend('force', result, f())
    end

    _G.LOADED_CONFIGS = configs
    _G.LOCAL_CONFIG = result
end

return M
