-- Improve quickfix aesthetics, taken from
-- https://github.com/kevinhwang91/nvim-bqf#format-new-quickfix

if vim.b.current_syntax ~= nil then
    -- Clear any previous syntax that was set, e.g. in the built-in `qf.vim`.
    vim.cmd.syntax 'clear'
end

vim.cmd [[
    syn match qfFileName /^[^│]*/ nextgroup=qfSeparatorLeft
    syn match qfSeparatorLeft /│/ contained nextgroup=qfLineNr
    syn match qfLineNr /[^│]*/ contained nextgroup=qfSeparatorRight
    syn match qfSeparatorRight '│' contained nextgroup=qfError,qfWarning,qfInfo,qfNote
    syn match qfError / E .*$/ contained
    syn match qfWarning / W .*$/ contained
    syn match qfInfo / I .*$/ contained
    syn match qfNote / [NH] .*$/ contained

    hi def link qfFileName Directory
    hi def link qfSeparatorLeft Delimiter
    hi def link qfSeparatorRight Delimiter
    hi def link qfLineNr LineNr
    hi def link qfError DiagnosticError
    hi def link qfWarning DiagnosticWarn
    hi def link qfInfo DiagnosticInfo
    hi def link qfNote DiagnosticHint
]]

vim.b.current_syntax = 'qf'
