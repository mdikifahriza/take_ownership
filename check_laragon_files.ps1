Write-Host "=== DAFTAR SEMUA FILE & FOLDER DI C:\laragon ==="
Get-ChildItem "C:\laragon" -Recurse -Force | ForEach-Object {
    $acl = (Get-Acl $_.FullName).Owner
    Write-Host "$($_.FullName) | Owner: $acl"
}
