local M = {}

local util = require 'util'

-- Make gf open the file even if it doesn't exist.
util.map('n', 'gf', '<cmd>e <cfile><cr>')

return M
