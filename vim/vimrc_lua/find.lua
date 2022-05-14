local util = require 'vimrc.util'

local fd_results
local refresh_timer

local function cancel_refresh_timer()
    if refresh_timer ~= nil then
        vim.loop.timer_stop(refresh_timer)
        refresh_timer = nil
    end
end

local function refresh_fd_results()
    vim.fn.jobstart({'fd', '--strip-cwd-prefix'}, {
        stdout_buffered = true,
        on_stdout =
            function(_, output)
                -- Cancel any current job to mark the results as stale.
                cancel_refresh_timer()

                -- We need to remove the list item, since it's an empty
                -- string representing EOF.
                fd_results = vim.list_slice(output, 1, #output - 1)

                -- Mark the results as stale after 10 seconds.
                refresh_timer = util.defer(10000, function()
                    fd_results = nil
                    refresh_fd_results()
                end)
            end,
    })
end

util.augroup('vimrc__fd_refresh', {
    {'CmdlineEnter', {pattern = ':', callback = refresh_fd_results}},
    {'CmdlineLeave', {pattern = ':', callback = function() cancel_refresh_timer() end}},
})

local function complete_find(arg_lead --[[cmd_line, cursor_pos]])
    if fd_results == nil then
        return vim.fn.systemlist({'fd', '--glob', '--strip-cwd-prefix', '*' .. arg_lead .. '*'})
    else
        return util.filter(fd_results, function(path)
            local pat = string.format([[\v.+%s.+]], string.gsub(arg_lead, '*', '.+'))
            return vim.fn.match(path, pat) ~= -1
        end)
    end
end

util.user_command(
    'Find',
    function(args)
        vim.cmd(string.format('find %s', args.args))
    end,
    {nargs = 1, complete = complete_find}
)

util.map('n', '<leader>f', ':Find ', {silent = false})
