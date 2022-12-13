local util = require 'vimrc.util'

-- Convert files with Pandoc.
util.user_command(
    'PandocConvert',
    function(args)
        local file_name
        if util.buffer_is_file() then
            file_name = vim.fn.expand('%')
        else
            local buf_content = vim.api.nvim_buf_get_lines(0 --[[buffer]], 0, -1, true --[[strict_indexing]])
            file_name = vim.fn.tempname()
            vim.fn.writefile(buf_content, file_name)
        end

        local to_extension = args.args
        local output_file = string.format('%s.%s', vim.fn.tempname(), to_extension)

        local output = vim.fn.system {
            'pandoc',
            file_name,
            '--css=https://cdn.simplecss.org/simple.min.css',
            '--standalone',
            '-o',
            output_file,
        }
        if vim.v.shell_error ~= 0 then
            util.log_error(string.format('Pandoc command failed: %s', output))
            return
        end

        util.browse_to(output_file)
    end,
    {nargs = 1}
)

-- Produce mermaid images.
util.user_command(
    'MermaidBuild',
    function(args)
        local output_dir = util.default(args[1], 'img')
        local extension = util.default(args[2], 'png')
        local output_file = string.format(
            '%s/%s.%s',
            output_dir,
            vim.fn.expand('%:t:r'),
            extension
        )

        local output = vim.fn.system({
            'mmdc.cmd',
            '-i',
            vim.fn.expand('%'),
            '-o',
            output_file,
        })
        if vim.v.shell_error ~= 0 then
            util.log_error(string.format('Mermaid command failed: %s', output))
            return
        end
    end,
    {nargs = '*'}
)
