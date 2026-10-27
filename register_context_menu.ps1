$ErrorActionPreference = 'Stop'

$cmdPath = "C:\tools\take_ownership\TakeOwnership.cmd"
$powershellCmd = "powershell.exe -NoProfile -WindowStyle Hidden -Command `"Start-Process cmd.exe -ArgumentList '/c \`"`"$cmdPath\`"`" \`"`"%1\`"`"' -Verb RunAs`""

# 1. Daftarkan untuk SEMUA FILE (*)
$fileKey = "HKCU:\Software\Classes\*\shell\TakeOwnership"
New-Item -Path $fileKey -Force | Out-Null
Set-ItemProperty -Path $fileKey -Name "(Default)" -Value "Take Ownership"
Set-ItemProperty -Path $fileKey -Name "Icon" -Value "imageres.dll,-78"
Set-ItemProperty -Path $fileKey -Name "HasLUAShield" -Value ""

$fileCmdKey = "$fileKey\command"
New-Item -Path $fileCmdKey -Force | Out-Null
Set-ItemProperty -Path $fileCmdKey -Name "(Default)" -Value $powershellCmd

# 2. Daftarkan untuk SEMUA FOLDER (Directory)
$dirKey = "HKCU:\Software\Classes\Directory\shell\TakeOwnership"
New-Item -Path $dirKey -Force | Out-Null
Set-ItemProperty -Path $dirKey -Name "(Default)" -Value "Take Ownership"
Set-ItemProperty -Path $dirKey -Name "Icon" -Value "imageres.dll,-78"
Set-ItemProperty -Path $dirKey -Name "HasLUAShield" -Value ""

$dirCmdKey = "$dirKey\command"
New-Item -Path $dirCmdKey -Force | Out-Null
Set-ItemProperty -Path $dirCmdKey -Name "(Default)" -Value $powershellCmd

Write-Host "Context menu 'Take Ownership' berhasil didaftarkan di klik kanan file & folder!"
