@echo off
setlocal EnableDelayedExpansion
title Take Ownership Tool

:: ============================================================
:: SELF-ELEVATE: Jika belum berjalan sebagai Administrator,
:: minta UAC lalu restart script ini dengan hak admin
:: ============================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Meminta hak Administrator via UAC...
    powershell -NoProfile -Command ^
        "Start-Process cmd.exe -ArgumentList '/c \"\"%~f0\"\" \"\"%~1\"\"' -Verb RunAs -Wait"
    exit /b
)

:: ============================================================
:: Sudah berjalan sebagai Administrator
:: ============================================================
set "TARGET=%~1"
if not defined TARGET (
    echo ========================================================
    echo  ERROR: Tidak ada target file atau folder yang dipilih.
    echo ========================================================
    pause
    exit /b 1
)

echo ========================================================
echo                 TAKE OWNERSHIP TOOL
echo          Berjalan sebagai: %USERNAME%
echo ========================================================
echo Target: "%TARGET%"
echo.

:: Cek apakah target adalah folder atau file
if exist "%TARGET%\*" (
    echo [*] Mendeteksi target sebagai FOLDER.
    echo.
    echo [1/2] Mengambil alih kepemilikan folder dan seluruh isinya...
    echo       ^(Semua file akan ditampilkan di bawah^)
    echo --------------------------------------------------------
    takeown /f "%TARGET%" /r /d y
    echo --------------------------------------------------------
    echo.
    echo [2/2] Memberikan izin akses penuh ^(Full Access^)...
    echo       administrators, %USERNAME%, dan Users
    echo --------------------------------------------------------
    icacls "%TARGET%" /grant administrators:F /t /c /l
    icacls "%TARGET%" /grant "%USERNAME%":F /t /c /l
    icacls "%TARGET%" /grant Users:F /t /c /l
    echo --------------------------------------------------------
) else (
    echo [*] Mendeteksi target sebagai FILE.
    echo.
    echo [1/2] Mengambil alih kepemilikan file...
    echo --------------------------------------------------------
    takeown /f "%TARGET%"
    echo --------------------------------------------------------
    echo.
    echo [2/2] Memberikan izin akses penuh ^(Full Access^)...
    echo --------------------------------------------------------
    icacls "%TARGET%" /grant administrators:F /c /l
    icacls "%TARGET%" /grant "%USERNAME%":F /c /l
    icacls "%TARGET%" /grant Users:F /c /l
    echo --------------------------------------------------------
)

echo.
echo ========================================================
echo  SELESAI! Hak akses dan kepemilikan berhasil diberikan.
echo  Tekan sembarang tombol untuk menutup jendela ini.
echo ========================================================
echo.
pause
exit /b 0
