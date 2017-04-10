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

    # Display the username and computername
    Write-Host "$env:UserName@$env:ComputerName" -ForegroundColor Blue -NoNewline
    Write-Host ":" -ForegroundColor Blue -NoNewline

    # Display the path
    $curPath = $ExecutionContext.SessionState.Path.CurrentLocation.Path
    if ($curPath.ToLower().StartsWith($Home.ToLower()))
    {
        $curPath = "~" + $curPath.SubString($Home.Length)
    }
    Write-Host $curPath -ForegroundColor Green -NoNewline

    # Display the Git status text
    Write-VcsStatus

    $LASTEXITCODE = $origLastExitCode

    # Display the prompt character
    If ($nestedPromptLevel -eq 0) {
        $promptChar = "$"
    } Else {
        $promptChar = ">"
    }
    "$($promptChar * ($nestedPromptLevel + 1)) "
}
