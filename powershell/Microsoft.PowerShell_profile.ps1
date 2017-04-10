##### IMPORT MODULES #####
# PSReadLine
Import-Module PSReadLine
Set-PSReadlineOption -EditMode Emacs

# posh-git
Import-Module posh-git

# Get-ChildItem-Color
. "~\Documents\WindowsPowerShell\Get-ChildItem-Color\Get-ChildItem-Color.ps1"
Set-Alias l Get-ChildItem-Color -Option AllScope
Set-Alias ls Get-ChildItem-Format-Wide -Option AllScope

##########################

# Start in the home directory
Set-Location ~

# Customize prompt
function prompt {
    $origLastExitCode = $LASTEXITCODE

    $curPath = $ExecutionContext.SessionState.Path.CurrentLocation.Path
    if ($curPath.ToLower().StartsWith($Home.ToLower()))
    {
        $curPath = "~" + $curPath.SubString($Home.Length)
    }
    Write-Host ($curPath + " ") -ForegroundColor Green -NoNewline

    Write-VcsStatus

    $LASTEXITCODE = $origLastExitCode
    "$('>' * ($nestedPromptLevel + 1)) "
}
$global:GitPromptSettings.BeforeText = '['
