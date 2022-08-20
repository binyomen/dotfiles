local M = {}

function M.create_link(text)
    local replacements = {
        {l = ' ', r = '-'},
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

function M.init_in_buffer()
end

return M
