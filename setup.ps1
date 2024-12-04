#Requires -RunAsAdministrator

$symlinks = @{
  "$PROFILE.CurrentUserAllHosts"          = ".\Powershell\profile.ps1"
  "$env:APPDATA\Code\User\settings.json"  = ".\VSCode\settings.json"
}

# Create Symbolic Links
Write-Host "Creating Symbolic Links..."
foreach ($symlink in $symlinks.GetEnumerator()) {
    Get-Item -Path $symlink.Key -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    New-Item -ItemType SymbolicLink -Path $symlink.Key -Target (Resolve-Path $symlink.Value) -Force | Out-Null
}