# PSReadLine
Import-Module PSReadLine
Set-PSReadlineOption -EditMode Emacs

# posh-git
Import-Module posh-git

# Get-ChildItem-Color
. "~\Documents\WindowsPowerShell\Get-ChildItem-Color\Get-ChildItem-Color.ps1"
Set-Alias l Get-ChildItem-Color -Option AllScope
Set-Alias ls Get-ChildItem-Format-Wide -Option AllScope
