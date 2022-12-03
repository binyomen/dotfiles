Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -Colors @{InlinePrediction = "`e[38;5;247m"}

# Don't precede completed files/directories with ".\" to be more unix-like.
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock {
    param(
        [Nullable[System.ConsoleKeyInfo]] $key,
        [Object] $arg
    )

    # First perform normal completion.
    [Microsoft.PowerShell.PSConsoleReadLine]::Complete($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref] $line, [ref] $cursor)
    while (($index = $line.IndexOf(' .\')) -ne -1) {
        # Then replace any instances of ".\" after a space.
        [Microsoft.PowerShell.PSConsoleReadLine]::Replace($index, 3, ' ')

        # Correct the cursor position.
        $newCursor = $null
        if ($cursor -gt $index + 2) {
            $newCursor = $cursor - 2
        } elseif ($cursor -gt $index + 1) {
            $newCursor = $cursor - 1
        } else {
            $newCursor = $cursor
        }
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($newCursor)

        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref] $line, [ref] $cursor)
    }
}

function prompt {
    $origLastExitCode = $LASTEXITCODE

    # Display the username and computer name.
    Write-Host "$env:UserName@$env:ComputerName" -ForegroundColor DarkGreen -NoNewline
    Write-Host ':' -ForegroundColor White -NoNewline

    # Display the path.
    $currPath = $ExecutionContext.SessionState.Path.CurrentLocation.Path
    if ($currPath.ToLower().StartsWith($HOME.ToLower()))
    {
        $currPath = '~' + $currPath.SubString($HOME.Length)
    }
    Write-Host $currPath -ForegroundColor Cyan -NoNewline

    # Display the Git status text. The conditional prevents the posh-git module
    # from being loaded every time PowerShell is started. This way, it's only
    # loaded the first time a git repo is entered.
    if (Get-GitDirectory) {
        Write-Host "$(Write-VcsStatus)" -NoNewline
    }

    if ($PSVersionTable.PSEdition -eq 'Desktop') {
        Write-Host '[Desktop]' -NoNewline -ForegroundColor Red
    }

    # Display the prompt character
    If ($nestedPromptLevel -eq 0) {
        $promptChar = '$'
    } Else {
        $promptChar = '>'
    }
    $promptCharText = "$($promptChar * ($nestedPromptLevel + 1)) "

    $LASTEXITCODE = $origLastExitCode
    $promptCharText
}

$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module $ChocolateyProfile
}

# Enable access to the HKEY_USERS registry hive.
New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS > $null

# Load a local profile if available.
if (Test-Path '~\.local_profile.ps1') {
    . '~\.local_profile.ps1'
}

# An efficient alternative to "git rev-parse" to determine if you're in a git
# repo, and if so, what its path is.
function Get-GitDirectory {
    [OutputType([String])]
    $currDir = Get-Item -Path '.'
    while ($currDir) {
        $gitDirPath = Join-Path $currDir.FullName '.git'
        if (Test-Path -LiteralPath $gitDirPath -PathType Container) {
            return $gitDirPath
        }
        $currDir = $currDir.Parent
    }
    return $null
}
