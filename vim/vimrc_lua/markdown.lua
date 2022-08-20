local M = {}

local util = require 'vimrc.util'

local namespace = vim.api.nvim_create_namespace('vimrc.markdown')

function M.slugify(text)
    local replacements = {
        {l = ' ', r = '-'},
        {l = '\n', r = '-'},
        {l = "'", r = ''},
        {l = '%.', r = ''},
    }
    for _, replacement in ipairs(replacements) do
        text = text:gsub(replacement.l, replacement.r)
    end

    text = text:lower()
    print(text)

    return text
end

local link_start_mark
local function link_mode()
    if link_start_mark then
        local link_end_mark = util.get_extmark_from_behind_cursor(namespace)

        local link_start_pos = util.get_extmark_pos(link_start_mark, namespace)
        link_start_pos[2] = link_start_pos[2] + 1
        local link_end_pos = util.get_extmark_pos(link_end_mark, namespace)
        link_end_pos[2] = link_end_pos[2] + 1

        local text = vim.api.nvim_buf_get_text(
            0 --[[buffer]],
            link_start_pos[1], link_start_pos[2],
            link_end_pos[1], link_end_pos[2],
            {}
        )[1]
        local slug = M.slugify(text)

        local link = string.format('[%s](%s.md)', text, slug)
        vim.api.nvim_buf_set_text(
            0 --[[buffer]],
            link_start_pos[1], link_start_pos[2],
            link_end_pos[1], link_end_pos[2],
            {link}
        )

        util.set_cursor_from_extmark(link_end_mark, namespace)

        link_start_mark = nil
        vim.b.vimrc__in_link_mode = false
    else
        link_start_mark = util.get_extmark_from_behind_cursor(namespace)

        vim.b.vimrc__in_link_mode = true
    end
end

function M.init_in_buffer()
    util.map('i', '<c-m>', link_mode, {buffer = true})
end

return M
