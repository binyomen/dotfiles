local M = {}

local util = require 'util'

-- Fix the closest previous spelling mistake.
util.map('n', '<leader>z=', [[mz[s1z=`z]])

return M
