# ============================================================
# TakeOwnership.ps1
# Ambil alih kepemilikan file/folder via context menu
# ============================================================
param([string]$Target)

# Ambil target dari parameter atau dari $args jika ada
if ([string]::IsNullOrWhiteSpace($Target) -and $args.Count -gt 0) {
    $Target = $args[0]
}

# Bersihkan quotes dan trailing backslash agar aman di Windows
$Target = $Target.Trim('"').Trim("'").TrimEnd('\').TrimEnd('/')

# --- Self-elevate jika belum Administrator ---
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    $argList = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" `"$Target`""
    Start-Process powershell.exe -ArgumentList $argList -Verb RunAs
    exit
}

# --- Validasi target ---
if ([string]::IsNullOrWhiteSpace($Target) -or -not (Test-Path -LiteralPath $Target)) {
    Write-Host "========================================================" -ForegroundColor Red
    Write-Host " ERROR: Target tidak ditemukan atau path tidak valid!" -ForegroundColor Red
    Write-Host " Path: '$Target'" -ForegroundColor Yellow
    Write-Host "========================================================" -ForegroundColor Red
    Write-Host ""
    Read-Host "Tekan Enter untuk menutup"
    exit 1
}

Clear-Host
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "            TAKE OWNERSHIP TOOL" -ForegroundColor Cyan
Write-Host "    Berjalan sebagai: $env:USERNAME (Elevated Admin)" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Target : $Target" -ForegroundColor White
Write-Host ""

$isFolder = (Get-Item -LiteralPath $Target).PSIsContainer

if ($isFolder) {
    Write-Host "[*] Tipe: FOLDER (Direktori)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "[1/4] Mengambil kepemilikan folder utama..." -ForegroundColor Yellow
    & takeown /f "$Target" /d y

    Write-Host ""
    Write-Host "[2/4] Membuka izin root folder (membersihkan aturan DENY)..." -ForegroundColor Yellow
    & icacls "$Target" /remove:d Everyone 2>$null
    & icacls "$Target" /remove:d Users 2>$null
    & icacls "$Target" /remove:d "$env:USERNAME" 2>$null
    & icacls "$Target" /grant "Administrators:(OI)(CI)F" 2>$null
    & icacls "$Target" /grant "${env:USERNAME}:(OI)(CI)F" 2>$null

    Write-Host ""
    Write-Host "[3/4] Mengambil kepemilikan SELURUH file dan subfolder..." -ForegroundColor Yellow
    Write-Host "      (Setiap item akan ditampilkan di bawah)" -ForegroundColor Gray
    Write-Host "--------------------------------------------------------"
    & takeown /f "$Target" /r /d y
    Write-Host "--------------------------------------------------------"

    Write-Host ""
    Write-Host "[4/4] Memberikan Full Control ke seluruh isi folder..." -ForegroundColor Yellow
    Write-Host "--------------------------------------------------------"
    & icacls "$Target" /remove:d Everyone /t /c /l 2>$null
    & icacls "$Target" /remove:d Users /t /c /l 2>$null
    & icacls "$Target" /remove:d "$env:USERNAME" /t /c /l 2>$null
    & icacls "$Target" /grant "Administrators:(OI)(CI)F" /t /c /l
    & icacls "$Target" /grant "${env:USERNAME}:(OI)(CI)F" /t /c /l
    & icacls "$Target" /grant "Users:(OI)(CI)F" /t /c /l
    Write-Host "--------------------------------------------------------"
} else {
    Write-Host "[*] Tipe: FILE" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "[1/3] Mengambil kepemilikan file..." -ForegroundColor Yellow
    Write-Host "--------------------------------------------------------"
    & takeown /f "$Target"
    Write-Host "--------------------------------------------------------"

    Write-Host ""
    Write-Host "[2/3] Membersihkan aturan DENY..." -ForegroundColor Yellow
    & icacls "$Target" /remove:d Everyone /c /l 2>$null
    & icacls "$Target" /remove:d Users /c /l 2>$null
    & icacls "$Target" /remove:d "$env:USERNAME" /c /l 2>$null

    Write-Host ""
    Write-Host "[3/3] Memberikan Full Control..." -ForegroundColor Yellow
    Write-Host "--------------------------------------------------------"
    & icacls "$Target" /grant "Administrators:F" /c /l
    & icacls "$Target" /grant "${env:USERNAME}:F" /c /l
    & icacls "$Target" /grant "Users:F" /c /l
    Write-Host "--------------------------------------------------------"
}

Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host "  SUKSES! Hak akses penuh dan kepemilikan telah diberikan." -ForegroundColor Green
Write-Host "  Folder/File sekarang dapat dibuka, diedit, atau dihapus." -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
Write-Host ""
Read-Host "Tekan Enter untuk menutup jendela ini"
