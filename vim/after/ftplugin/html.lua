require('vimrc.util').set_tab_size(2)

vim.schedule(function()
    vim.fn['textobj#quote#init'] {educate = 0}
end)
