local util = require 'vimrc.util'

-- Diff two files.
util.user_command(
    'Diff',
    function(args)
        assert(#args.fargs == 2)

        local file1 = args.fargs[1]
        local file2 = args.fargs[2]

        vim.cmd(string.format('tabedit %s', file1))
        vim.cmd(string.format('vertical diffsplit %s', file2))
    end,
    {nargs = '+', complete = 'file'}
)
