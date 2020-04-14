##### CONFIGURE/LIST MODULES #####
# PSReadLine
Set-PSReadlineOption -EditMode Emacs
Set-PSReadlineOption -BellStyle Visual

# posh-git
# No config yet

##################################

# Start in the home directory if not invoked with arguments
if ([Environment]::GetCommandLineArgs().Length -eq 1) {
    Set-Location ~
}

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
    # The conditional prevents the posh-git module from being loaded every time
    # PowerShell is started. This way, it's only loaded the first time a git
    # repo is entered.
    if (Get-GitDirectory) {
        Write-VcsStatus
    }

    $LASTEXITCODE = $origLastExitCode

    # Display the prompt character
    If ($nestedPromptLevel -eq 0) {
        $promptChar = "$"
    } Else {
        $promptChar = ">"
    }
    "$($promptChar * ($nestedPromptLevel + 1)) "
}

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module $ChocolateyProfile
}

# Enable access to the HKEY_USERS registry hive
New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS > $null

if (Test-Path "~\.local_profile.ps1") {
    . "~\.local_profile.ps1"
}

##### FUNCTIONS #####

# An efficient alternative to "git rev-parse" to determine if you're in a git
# repo, and if so, what its path is.
function Get-GitDirectory {
    [OutputType([String])]
    $currDir = Get-Item -Path "."
    while ($currDir) {
        $gitDirPath = Join-Path $currDir.FullName ".git"
        if (Test-Path -LiteralPath $gitDirPath -PathType Container) {
            return $gitDirPath
        }
        $currDir = $currDir.Parent
    }
    return $null
}