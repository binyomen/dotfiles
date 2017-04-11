##### CONFIGURE/LIST MODULES #####
# PSReadLine
Set-PSReadlineOption -EditMode Emacs

# posh-git
# No config yet

# Get-ChildItem-Color
. "~\Documents\WindowsPowerShell\Get-ChildItem-Color\Get-ChildItem-Color.ps1"
Set-Alias l Get-ChildItem-Color -Option AllScope
Set-Alias ls Get-ChildItem-Format-Wide -Option AllScope

##################################

# Start in the home directory
Set-Location ~

# Customize prompt
function prompt {
    $origLastExitCode = $LASTEXITCODE

    # Display the username and computername
    Write-Host "$env:UserName@$env:ComputerName" -ForegroundColor DarkGreen -NoNewline
    Write-Host ":" -ForegroundColor White -NoNewline

    # Display the path
    $currPath = $ExecutionContext.SessionState.Path.CurrentLocation.Path
    if ($currPath.ToLower().StartsWith($Home.ToLower()))
    {
        $currPath = "~" + $currPath.SubString($Home.Length)
    }
    Write-Host $currPath -ForegroundColor Cyan -NoNewline

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

# Aliases
# lo will use the original pipeable Get-ChildItem functionality
Set-Alias lo Get-ChildItem -Option AllScope
