local util = require 'vimrc.util'

local in_cmdline_mode = false
local fd_results
local refresh_timer

local function cancel_refresh_timer()
    if refresh_timer ~= nil then
        vim.loop.timer_stop(refresh_timer)
        refresh_timer = nil
    end
end

local function refresh_fd_results(force_run)
    local force_run = util.default(force_run, false)
    if not in_cmdline_mode and not force_run then
        return
    end

    vim.fn.jobstart({'fd', '--strip-cwd-prefix'}, {
        stdout_buffered = true,
        on_stdout =
            function(_, output)
                -- Cancel any current job to refresh the results.
                cancel_refresh_timer()

                -- We need to remove the last item, since it's an empty
                -- string representing EOF.
                fd_results = vim.list_slice(output, 1, #output - 1)

                -- Refresh the results after 10 seconds.
                refresh_timer = util.defer(10000, function()
                    refresh_fd_results()
                end)
            end,
    })
end

-- Give an initial value for the results even though we're not in cmdline mode.
refresh_fd_results(true --[[force_run]])

util.augroup('vimrc__fd_refresh', {
    {'CmdlineEnter', {pattern = ':', callback =
        function()
            in_cmdline_mode = true
            refresh_fd_results()
        end,
    }},
    {'CmdlineLeave', {pattern = ':', callback =
        function()
            cancel_refresh_timer()
            in_cmdline_mode = false
        end,
    }},
})

local function complete_find(arg_lead --[[cmd_line, cursor_pos]])
    if fd_results == nil then
        return {}
    end

    return util.filter(fd_results, function(path)
        local pat = string.format([[\v.+%s.+]], string.gsub(arg_lead, '*', '.+'))
        return vim.fn.match(path, pat) ~= -1
    end)
end

util.user_command(
    'Find',
    function(args)
        vim.cmd(string.format('find %s', args.args))
    end,
    {nargs = 1, complete = complete_find}
)

util.map('n', '<leader>f', ':Find ', {silent = false})
