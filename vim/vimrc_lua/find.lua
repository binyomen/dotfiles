local util = require 'vimrc.util'

local function complete_find(arg_lead --[[cmd_line, cursor_pos]])
    return vim.fn.systemlist({'fd', '--glob', '--strip-cwd-prefix', '*' .. arg_lead .. '*'})
end
util.user_command(
    'Find',
    function(args)
        vim.cmd(string.format('find %s', args.args))
    end,
    {nargs = 1, complete = complete_find}
)

util.map('n', '<leader>f', ':Find ', {silent = false})
