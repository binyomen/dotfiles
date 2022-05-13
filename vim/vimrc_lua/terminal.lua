local util = require 'vimrc.util'

-- Use pwsh on Windows.
if util.vim_has('win32') then
    util.enable_pwsh()
end
