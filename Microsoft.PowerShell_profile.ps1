##################
# Init oh-my-posh
##################
oh-my-posh init pwsh --config "$env:LocalAppData\Programs\oh-my-posh\themes\tokyo.omp.json" | Invoke-Expression

##################
# Ctrl+RightArrow adds one word from suggestion.
##################
Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -ScriptBlock {
  param($key, $arg)
  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
  if ($cursor -lt $line.Length) {
    [Microsoft.PowerShell.PSConsoleReadLine]::ForwardWord($key, $arg)
  }
  else { [Microsoft.PowerShell.PSConsoleReadLine]::AcceptNextSuggestionWord($key, $arg) }
}

##################
# Ctrl+y Accepts whole suggestion.
##################
Set-PSReadLineKeyHandler -Key Ctrl+y -Function AcceptSuggestion

##################
# Similar to bash ctrl+u.
##################
Set-PSReadLineKeyHandler -Key Ctrl+u -Function BackwardDeleteLine

##################
# ls -l
##################
Function NoHidden { 
  param(
    [string[]]$path
  )
  Get-ChildItem $path | where {$_.Name -NotLike ".*"}
}
set-alias -name l -value NoHidden

##################
# Alias that activates the vs developer shell
##################
function MyDevx64 {
 &{ Import-Module "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\Microsoft.VisualStudio.DevShell.dll";
  Enter-VsDevShell 7eee0d47 -SkipAutomaticLocation -DevCmdArguments "-arch=x64 -host_arch=x64";}
}
Set-Alias -name devsh -value MyDevx64

##################
# Sets function and chord that changes to the directory
# that lf was last on when quit
##################
function lfcd{
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
# ls -la
Set-Alias -Name ll -Value get-childitem

# wc
Set-Alias -Name wc -Value Measure-Object

# Move to recycle bin instead of delete
Set-Alias -Name trash -Value Remove-ItemSafely

# WinDbg
Set-Alias -Name windbg -Value "C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\windbg.exe"
Set-Alias -Name windbg86 -Value "C:\Program Files (x86)\Windows Kits\10\Debuggers\x86\windbg.exe"


# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

##################
# I'm cool.
##################
fastfetch
