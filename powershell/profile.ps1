using namespace System.Management

# Set input and output encodings to UTF-8, since the default is IBM codepage
# 437 otherwise. This is important for properly redirecting command output to
# files. See https://github.com/PowerShell/PowerShell/issues/18156 and
# https://gist.github.com/jborean93/44b4688cc518d67bd7bc2192648384a3.
$OutputEncoding = [Console]::InputEncoding = [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -Colors @{InlinePrediction = "`e[38;5;247m"}
Set-PSReadLineOption -AddToHistoryHandler {
    param(
        [String] $Command
    )

    # Don't add to history if command starts with spaces.
    if ($Command -match '^\s+.+$') {
        return $false
    } else {
        return $true
    }
}

# See https://stackoverflow.com/questions/12291199/example-showing-how-to-override-tabexpansion2-in-windows-powershell-3-0
function TabExpansion2 {
    [CmdletBinding(DefaultParameterSetName = 'ScriptInputSet')]
    [OutputType([Automation.CommandCompletion])]
    Param(
        [Parameter(ParameterSetName = 'ScriptInputSet', Mandatory, Position = 0)]
        [String] $InputScript,

        [Parameter(ParameterSetName = 'ScriptInputSet', Position = 1)]
        [Int] $CursorColumn = $InputScript.Length,

        [Parameter(ParameterSetName = 'AstInputSet', Mandatory, Position = 0)]
        [Automation.Language.Ast] $Ast,

        [Parameter(ParameterSetName = 'AstInputSet', Mandatory, Position = 1)]
        [Automation.Language.Token[]] $Tokens,

        [Parameter(ParameterSetName = 'AstInputSet', Mandatory, Position = 2)]
        [Automation.Language.IScriptPosition] $PositionOfCursor,

        [Parameter(ParameterSetName = 'ScriptInputSet', Position = 2)]
        [Parameter(ParameterSetName = 'AstInputSet', Position = 3)]
        [Hashtable] $Options = $null
    )

    End
    {
        $completion = $null
        if ($PSCmdlet.ParameterSetName -eq 'ScriptInputSet')
        {
            $completion = [Automation.CommandCompletion]::CompleteInput(
                $InputScript,
                $CursorColumn,
                $Options
            )
        }
        else
        {
            $completion = [Automation.CommandCompletion]::CompleteInput(
                $Ast,
                $Tokens,
                $PositionOfCursor,
                $Options
            )
        }

        # Don't modify completion for the command itself, since we want ".\" to
        # precede that. Also handle if the command line begins with whitespace.
        $line = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref] $line, [ref] $null <#cursor#>)
        $line -match '^\s*' > $null
        if ($completion.ReplacementIndex -eq $matches[0].Length) {
            return $completion
        }

        $newCompletion = [Automation.CommandCompletion]::new(
            @(),
            $completion.CurrentMatchIndex,
            $completion.ReplacementIndex,
            $completion.ReplacementLength
        )

        foreach ($result in $completion.CompletionMatches) {
            $newResult = $result

            # Don't precede completed files/directories with ".\". This is more
            # unix-like.
            if (
                ($result.ResultType -eq [Automation.CompletionResultType]::ProviderItem -or
                    $result.ResultType -eq [Automation.CompletionResultType]::ProviderContainer) -and
                $result.CompletionText.StartsWith('.\')
            ) {
                $newResult = [Automation.CompletionResult]::new(
                    $result.CompletionText.SubString(2),
                    $result.ListItemText,
                    $result.ResultType,
                    $result.ToolTip
                )
            }

            $newCompletion.CompletionMatches.Add($newResult)
        }

        return $newCompletion
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
