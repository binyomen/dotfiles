local M = {}

local util = require 'vimrc.util'

M.formulas = {}

function M.unpack_for_lua(args, f)
    return f(unpack(args))
end

local function new_formula(name, f)
    M.formulas[name] = f

    vim.cmd(string.format([[
        function! %s(...) abort
            let l:Formula = v:lua.require('vimrc.table_formulas').formulas['%s']
            return v:lua.require('vimrc.table_formulas').unpack_for_lua(a:000, l:Formula)
        endfunction
    ]], name, name))
end

local get_cell_range = vim.fn['tablemode#spreadsheet#cell#GetCellRange']

new_formula('SumOfProducts', function(range)
    local range = get_cell_range(range)

    local num_rows = #range[1]
    local num_cols = #range

    local sum = 0
    for row = 1,num_rows do
        local product = 1
        for col = 1,num_cols do
            product = product * tonumber(range[col][row])
        end

        sum = sum + product
    end

    return sum
end)

new_formula('EncounterDifficulty', function(range, xp_thresholds)
    local range = get_cell_range(range)

    local xps = util.tbl_map(range, function(xp) return tonumber(xp) end)

    local total_xp = 0
    for _, xp in ipairs(xps) do
        total_xp = total_xp + xp
    end

    local multiplier = (function()
        local num_creatures = #xps
        if num_creatures == 1 then
            return 1
        elseif num_creatures == 2 then
            return 1.5
        elseif num_creatures < 7 then
            return 2
        elseif num_creatures < 11 then
            return 2.5
        elseif num_creatures < 15 then
            return 3
        else
            return 4
        end
    end)()

    local multiplied = total_xp * multiplier

    local difficulty = (function()
        if multiplied >= xp_thresholds[4] then
            return 'Deadly'
        elseif multiplied >= xp_thresholds[3] then
            return 'Hard'
        elseif multiplied >= xp_thresholds[2] then
            return 'Medium'
        else
            return 'Easy'
        end
    end)()

    return string.format('%s (%dXP × %d = %dXP)', difficulty, total_xp, multiplier, multiplied)
end)

return M
