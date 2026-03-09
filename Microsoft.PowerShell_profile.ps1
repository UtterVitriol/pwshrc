##################
# Change the directories to be blue text instead of highlighted blue
##################
$PSStyle.FileInfo.Directory = "`e[38;2;97;175;239m"

##################
# Ctrl+RightArrow adds one word from suggestion.
##################
Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -ScriptBlock {
    param($key, $arg)
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    if ($cursor -lt $line.Length)
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::ForwardWord($key, $arg)
    } else
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptNextSuggestionWord($key, $arg) 
    }
}

##################
# Ctrl+y Accepts whole suggestion.
##################
Set-PSReadLineKeyHandler -Key Ctrl+y -Function AcceptSuggestion

##################
# Ctrl+n Accepts next suggestion.
##################
Set-PSReadLineKeyHandler -Key Ctrl+n -Function AcceptNextSuggestionWord

##################
# Similar to bash ctrl+u.
##################
Set-PSReadLineKeyHandler -Key Ctrl+u -Function BackwardDeleteLine

##################
# Alias that activates the vs developer shell
##################
function MyDevx64
{
    & "C:\Program Files\Microsoft Visual Studio\18\Community\Common7\Tools\Launch-VsDevShell.ps1" -SkipAutomaticLocation
}
Set-Alias -name devsh -value MyDevx64

##################
# Sets function and chord that changes to the directory
# that lf was last on when quit
##################
function lfcd
{
    # lf keybind zh shows hidden files.
    lf -print-last-dir $args | Set-Location
}

Set-PSReadLineKeyHandler -Chord Ctrl+o -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('lfcd')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

##################
# Random Aliases
##################

# firefox
Set-Alias -Name firefox -Value "C:\Program Files\Mozilla Firefox\firefox.exe"

# ls -l
Function NoHidden
{ 
    param(
        [string[]]$path
    )
    Get-ChildItem $path | Where-Object { $_.Name -NotLike ".*" }
}
set-alias -name l -value NoHidden

# ls -la
Function Hidden
{
    param(
        [string[]]$path
    )
    Get-ChildItem -Force $path
}
Set-Alias -Name ll -Value Hidden

# wc
Set-Alias -Name wc -Value Measure-Object

# WinDbg
Set-Alias -Name windbg -Value "C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\windbg.exe"
Set-Alias -Name windbg86 -Value "C:\Program Files (x86)\Windows Kits\10\Debuggers\x86\windbg.exe"

# touch
Set-Alias -Name touch -Value New-Item

Set-Alias -Name ghidra -Value "C:\Program Files\Ghidra\ghidraRun.bat"

# recycle
function Send-ToRecycleBin
{
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]$Path
    )

    process
    {
        foreach ($p in $Path)
        {
            # Resolve wildcards to full paths
            Get-Item -Path $p | ForEach-Object {
                $shell = New-Object -ComObject Shell.Application
                $shell.Namespace(0).ParseName($_.FullName).InvokeVerb("delete")
            }
        }
    }
}
Set-Alias -Name recycle -Value Send-ToRecycleBin

function Get-RecycleBin
{
    $recycleBin = (New-Object -ComObject Shell.Application).Namespace(10)
    $recycleBin.Items() | ForEach-Object {
        [PSCustomObject]@{
            Name         = $_.Name
            OriginalPath = $_.ExtendedProperty("OriginalLocation")
            DeletedDate  = $_.ExtendedProperty("DeletionDate")
            Size         = $_.Size
        }
    }
}

function Open-RecycleBin
{
    Start-Process shell:RecycleBinFolder
}

function Clear-RecycleBin
{
    $shell = New-Object -ComObject Shell.Application
    $shell.Namespace(10).Items() | ForEach-Object {
        Remove-Item -Path $_.Path -Recurse -Force -Confirm:$false
    }
}

function Remove-RecycleBinItem
{
    param(
        [Parameter(Mandatory)]
        [string]$Filter
    )

    $shell = New-Object -ComObject Shell.Application
    $recycleBin = $shell.Namespace(10)

    $recycleBin.Items() | 
        Where-Object { $_.Name -like $Filter } | 
        ForEach-Object {
            if ($_.IsFolder)
            {
                [System.IO.Directory]::Delete($_.Path, $true)
            } else
            {
                [System.IO.File]::Delete($_.Path)
            }
        }
}

function Restore-RecycleBin
{
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $shell = New-Object -ComObject Shell.Application
    $item = $shell.Namespace(10).Items() | Where-Object { $_.Name -eq $Name }

    if ($null -eq $item)
    {
        Write-Error "Item '$Name' not found in Recycle Bin."
        return
    }

    $item.InvokeVerb("undelete")
}

function Add-StartMenuEntry
{
    param(
        [Parameter(Mandatory)]
        [string]$BinaryPath,
        [switch]$AllUsers
    )

    $name = [System.IO.Path]::GetFileNameWithoutExtension($BinaryPath)
    $startMenu = if ($AllUsers)
    {
        "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
    } else
    {
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
    }

    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut("$startMenu\$name.lnk")
    $shortcut.TargetPath = $BinaryPath
    $shortcut.Description = $name
    $shortcut.WorkingDirectory = Split-Path $BinaryPath
    $shortcut.Save()
}

##################
# Init oh-my-posh
##################
oh-my-posh init pwsh --config "$home\.config\tokyo.omp.json" | Invoke-Expression
