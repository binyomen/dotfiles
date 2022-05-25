local M = {}

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

return M
