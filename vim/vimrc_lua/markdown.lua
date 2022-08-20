local M = {}

local util = require 'vimrc.util'

local namespace = vim.api.nvim_create_namespace('vimrc.markdown')

function M.slugify(text)
    local replacements = {
        {l = '\n', r = ' '},
        {l = ' ', r = '-'},
        {l = "'", r = ''},
        {l = '%.', r = ''},
    }
    for _, replacement in ipairs(replacements) do
        text = text:gsub(replacement.l, replacement.r)
    end

    text = text:lower()

    return text
end

local link_start_pos
local function link_mode()
    if link_start_pos then
        local link_end_mark = util.get_extmark_from_cursor(namespace)
        local link_end_pos = util.get_extmark_pos(link_end_mark, namespace)

        local text = table.concat(vim.api.nvim_buf_get_text(
            0 --[[buffer]],
            link_start_pos[1], link_start_pos[2],
            link_end_pos[1], link_end_pos[2],
            {}
        ), '\n')
        local slug = M.slugify(text)

        local link = string.format('[%s](%s.md)', text, slug)
        vim.api.nvim_buf_set_text(
            0 --[[buffer]],
            link_start_pos[1], link_start_pos[2],
            link_end_pos[1], link_end_pos[2],
            util.split(link, '\n')
        )

        util.set_cursor_from_extmark(link_end_mark, namespace)

        link_start_pos = nil
        vim.b.vimrc__in_link_mode = false
    else
        link_start_pos = vim.api.nvim_win_get_cursor(0 --[[window]])
        link_start_pos[1] = link_start_pos[1] - 1

        vim.b.vimrc__in_link_mode = true
    end
end

function M.init_in_buffer()
    util.map('i', '<c-m>', link_mode, {buffer = true})
end

return M
