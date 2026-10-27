# ============================================================
# create-test-folder.ps1
# Buat folder test dengan ribuan file, dikunci KETAT:
# - Owner: SYSTEM
# - DENY Everyone (termasuk Administrators dan user saat ini)
# Sehingga benar-benar tidak bisa diakses/dihapus sebelum
# TakeOwnership dijalankan
# ============================================================

# --- Self-elevate ---
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$targetFolder = "C:\Users\TakeOwnershipTest"
$totalFiles   = 3000
$subFolders   = @("alpha", "beta", "gamma", "delta", "epsilon", "zeta")

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  BUAT FOLDER TEST TERKUNCI" -ForegroundColor Cyan
Write-Host "  Berjalan sebagai: $env:USERNAME" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "Target : $targetFolder"
Write-Host "File   : $totalFiles"
Write-Host ""

# --- 1. Hapus folder lama ---
Write-Host "[1/4] Membersihkan folder lama..." -ForegroundColor Yellow
if (Test-Path $targetFolder) {
    # Reset ACL dulu agar bisa dihapus
    & takeown /f $targetFolder /r /d y | Out-Null
    & icacls $targetFolder /grant "Administrators:F" /t /c /q | Out-Null
    Remove-Item $targetFolder -Recurse -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 500
}

# Buat struktur folder
New-Item -ItemType Directory -Path $targetFolder -Force | Out-Null
foreach ($sub in $subFolders) {
    New-Item -ItemType Directory -Path "$targetFolder\$sub"        -Force | Out-Null
    New-Item -ItemType Directory -Path "$targetFolder\$sub\nested" -Force | Out-Null
}
Write-Host "    Struktur folder siap." -ForegroundColor Green

# --- 2. Buat ribuan file ---
Write-Host ""
Write-Host "[2/4] Membuat $totalFiles file random..." -ForegroundColor Yellow

$extensions = @(".txt", ".log", ".dat", ".bin", ".tmp", ".csv")
$created = 0; $errors = 0

for ($i = 1; $i -le $totalFiles; $i++) {
    $sub    = $subFolders[(Get-Random -Maximum $subFolders.Count)]
    $nest   = if ((Get-Random -Maximum 2) -eq 0) { "\nested" } else { "" }
    $ext    = $extensions[(Get-Random -Maximum $extensions.Count)]
    $name   = "file_$(Get-Random -Maximum 999999)_$i$ext"
    $path   = "$targetFolder\$sub$nest\$name"

    $parent = Split-Path $path -Parent
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }

    $size    = Get-Random -Minimum 64 -Maximum 512
    $content = [System.Convert]::ToBase64String((1..$size | ForEach-Object { Get-Random -Maximum 256 }))

    try {
        [System.IO.File]::WriteAllText($path, $content)
        $created++
    } catch { $errors++ }

    if ($i % 500 -eq 0) {
        Write-Host "    ... $i / $totalFiles (ok: $created, err: $errors)" -ForegroundColor Gray
    }
}
Write-Host "    $created file dibuat, $errors error." -ForegroundColor Green

# --- 3. Set owner ke SYSTEM ---
Write-Host ""
Write-Host "[3/4] Mengubah owner ke SYSTEM..." -ForegroundColor Yellow
& takeown /f $targetFolder /r /d y /a | Out-Null  # /a = set ke Administrators group dulu
# Ganti ke SYSTEM via icacls ownership
# (takeown /a sets to Admins, we use SetOwner via .NET for SYSTEM)
$systemAccount = New-Object System.Security.Principal.NTAccount("NT AUTHORITY\SYSTEM")
try {
    $acl = Get-Acl $targetFolder
    $acl.SetOwner($systemAccount)
    Set-Acl -Path $targetFolder -AclObject $acl
    Write-Host "    Owner root folder -> SYSTEM" -ForegroundColor Gray
} catch {
    Write-Host "    WARN: Tidak bisa set owner SYSTEM pada root (lanjut...)" -ForegroundColor DarkYellow
}

# --- 4. Set ACL: DENY Everyone ---
Write-Host ""
Write-Host "[4/4] Mengunci ACL (DENY semua akses)..." -ForegroundColor Yellow

$denyRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "Everyone", "FullControl",
    "ContainerInherit,ObjectInherit", "None", "Deny"
)
$allowSystem = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "NT AUTHORITY\SYSTEM", "FullControl",
    "ContainerInherit,ObjectInherit", "None", "Allow"
)

function Lock-Item($path, $isDir) {
    try {
        if ($isDir) { $acl = New-Object System.Security.AccessControl.DirectorySecurity }
        else        { $acl = New-Object System.Security.AccessControl.FileSecurity }
        $acl.SetAccessRuleProtection($true, $false)   # putus inheritance
        $acl.AddAccessRule($allowSystem)               # SYSTEM bisa akses
        $acl.AddAccessRule($denyRule)                  # DENY Everyone lainnya
        Set-Acl -Path $path -AclObject $acl
    } catch {
        Write-Host "    WARN: $path" -ForegroundColor DarkYellow
    }
}

Lock-Item $targetFolder $true
$count = 0
Get-ChildItem -Path $targetFolder -Recurse | ForEach-Object {
    Lock-Item $_.FullName $_.PSIsContainer
    $count++
    if ($count % 500 -eq 0) { Write-Host "    ... $count item dikunci" -ForegroundColor Gray }
}

Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  SELESAI - Folder terkunci!" -ForegroundColor Green
Write-Host ""
Write-Host "  Folder : $targetFolder" -ForegroundColor White
Write-Host "  File   : $created file" -ForegroundColor White
Write-Host "  Owner  : SYSTEM" -ForegroundColor White
Write-Host "  ACL    : DENY Everyone, ALLOW SYSTEM only" -ForegroundColor White
Write-Host ""
Write-Host "  Coba klik kanan folder TakeOwnershipTest" -ForegroundColor Yellow
Write-Host "  lalu pilih [Take Ownership] untuk test!" -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Cyan
Read-Host "`nTekan Enter untuk menutup"
