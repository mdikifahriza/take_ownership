@echo off
setlocal
title Uninstalling Take Ownership Context Menu

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
    "Remove-Item -LiteralPath 'Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\Software\Classes\*\shell\runas' -Recurse -Force -ErrorAction SilentlyContinue;" ^
    "Remove-Item -LiteralPath 'Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\Software\Classes\*\shell\TakeOwnership' -Recurse -Force -ErrorAction SilentlyContinue;" ^
    "Remove-Item -LiteralPath 'Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\Software\Classes\Directory\shell\runas' -Recurse -Force -ErrorAction SilentlyContinue;" ^
    "Remove-Item -LiteralPath 'Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\Software\Classes\Directory\shell\TakeOwnership' -Recurse -Force -ErrorAction SilentlyContinue;" ^
    "Remove-Item -LiteralPath 'Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\runas' -Recurse -Force -ErrorAction SilentlyContinue;" ^
    "Write-Host ''; Write-Host 'SUCCESS: Take Ownership context menu removed successfully!' -ForegroundColor Green;"

echo.
pause

