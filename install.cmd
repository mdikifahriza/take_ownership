@echo off
setlocal
cd /d "%~dp0"
title Installing Take Ownership Context Menu

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
    "$dir = $PSScriptRoot; if (-not $dir) { $dir = (Get-Location).Path };" ^
    "$ps1 = Join-Path $dir 'TakeOwnership.ps1';" ^
    "if (-not (Test-Path -LiteralPath $ps1)) { Write-Host 'ERROR: TakeOwnership.ps1 not found in current folder!' -ForegroundColor Red; pause; exit 1 };" ^
    "$cmdStr = 'powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Normal -File \"\"' + $ps1 + '\"\" \"%1\"';" ^
    "$cmdStrBg = 'powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Normal -File \"\"' + $ps1 + '\"\" \"%V\"';" ^
    "Remove-Item -LiteralPath 'Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\Software\Classes\*\shell\TakeOwnership' -Recurse -Force -ErrorAction SilentlyContinue;" ^
    "Remove-Item -LiteralPath 'Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\Software\Classes\Directory\shell\TakeOwnership' -Recurse -Force -ErrorAction SilentlyContinue;" ^
    "$paths = @('HKCU:\Software\Classes\*\shell\runas', 'HKCU:\Software\Classes\Directory\shell\runas');" ^
    "foreach ($p in $paths) {" ^
    "  New-Item -Path $p -Force | Out-Null;" ^
    "  Set-ItemProperty -Path $p -Name '(Default)' -Value 'Take Ownership';" ^
    "  Set-ItemProperty -Path $p -Name 'Icon' -Value 'imageres.dll,-78';" ^
    "  Set-ItemProperty -Path $p -Name 'HasLUAShield' -Value '';" ^
    "  Set-ItemProperty -Path $p -Name 'NoWorkingDirectory' -Value '';" ^
    "  $cmdKey = Join-Path $p 'command';" ^
    "  New-Item -Path $cmdKey -Force | Out-Null;" ^
    "  Set-ItemProperty -Path $cmdKey -Name '(Default)' -Value $cmdStr;" ^
    "  Set-ItemProperty -Path $cmdKey -Name 'IsolatedCommand' -Value $cmdStr;" ^
    "};" ^
    "$bg = 'HKCU:\Software\Classes\Directory\Background\shell\runas';" ^
    "New-Item -Path $bg -Force | Out-Null;" ^
    "Set-ItemProperty -Path $bg -Name '(Default)' -Value 'Take Ownership Folder Ini';" ^
    "Set-ItemProperty -Path $bg -Name 'Icon' -Value 'imageres.dll,-78';" ^
    "Set-ItemProperty -Path $bg -Name 'HasLUAShield' -Value '';" ^
    "Set-ItemProperty -Path $bg -Name 'NoWorkingDirectory' -Value '';" ^
    "$bgCmd = Join-Path $bg 'command';" ^
    "New-Item -Path $bgCmd -Force | Out-Null;" ^
    "Set-ItemProperty -Path $bgCmd -Name '(Default)' -Value $cmdStrBg;" ^
    "Set-ItemProperty -Path $bgCmd -Name 'IsolatedCommand' -Value $cmdStrBg;" ^
    "Write-Host ''; Write-Host 'SUCCESS: Take Ownership context menu installed successfully!' -ForegroundColor Green; Write-Host 'Script location: ' $ps1 -ForegroundColor Cyan;"

echo.
pause

