local M = {}

local util = require 'vimrc.util'

local namespace = vim.api.nvim_create_namespace('vimrc.markdown')

function M.slugify(text)
    local replacements = {
        {l = '\n', r = ' '},
        {l = ' ', r = '-'},
        {l = '/', r = '-'},
        {l = "'", r = ''},
        {l = '%.', r = ''},
        {l = '’', r = ''},
    }
    for _, replacement in ipairs(replacements) do
        text = text:gsub(replacement.l, replacement.r)
    end

    text = text:lower()

    return text
end

local link_start_pos

local function clear_link_mode_state()
    link_start_pos = nil
    vim.api.nvim_buf_clear_namespace(0 --[[buffer]], namespace, 0 --[[line_start]], -1 --[[line_end]])
    vim.b.vimrc__in_link_mode = false
end

local function link_mode_start()
    local succeeded, msg = pcall(function()
        if link_start_pos then
            util.feedkeys('[[', 'nt')
            return
        end

        link_start_pos = vim.api.nvim_win_get_cursor(0 --[[window]])
        link_start_pos[1] = link_start_pos[1] - 1

        vim.b.vimrc__in_link_mode = true
    end)

    if not succeeded then
        clear_link_mode_state()
        assert(false, msg)
    end
end

local function link_mode_end()
    local succeeded, msg = pcall(function()
        if not link_start_pos then
            util.feedkeys(']]', 'nt')
            return
        end

        local link_end_mark = util.get_extmark_from_cursor(namespace)
        local link_end_pos = util.get_extmark_pos(link_end_mark, namespace)

        local text = table.concat(vim.api.nvim_buf_get_text(
            0 --[[buffer]],
            link_start_pos[1], link_start_pos[2],
            link_end_pos[1], link_end_pos[2],
            {}
        ), '\n')

        local slug
        if (text:find('|', 1 --[[init]], true --[[plain]])) then
            local tokens = vim.split(text, '|', {plain = true})
            slug = tokens[1]
            text = tokens[2]
        else
            slug = M.slugify(text)
        end

        local link = string.format('[%s](%s.md)', text, slug)
        vim.api.nvim_buf_set_text(
            0 --[[buffer]],
            link_start_pos[1], link_start_pos[2],
            link_end_pos[1], link_end_pos[2],
            util.split(link, '\n')
        )

        util.set_cursor_from_extmark(link_end_mark, namespace)
    end)

    clear_link_mode_state()
    assert(succeeded, msg)
end

function M.init_in_buffer()
    util.map('i', '[[', link_mode_start, {buffer = true})
    util.map('i', ']]', link_mode_end, {buffer = true})
end

return M
