#Requires -RunAsAdministrator

$modules = @(
  "psgsuite",
  "posh-git",
  "posh-ssh",
  "terminal-icons",
  "plaster",
  "modulebuilder"
)

# Powershell profile parent folder. This works with files and symlinks.
$profileDir = $PROFILE.CurrentUserCurrentHost | Split-Path
$profileParentDir = $profileDir.Substring(0, $profileDir.LastIndexOf('\'))

# Installing NuGet package provider...
Write-Host "Installing NuGet"
Install-PackageProvider -Name NuGet -Force | Out-Null

# Install modules
Write-Host "Installing modules"
foreach ($module in $modules){
  Install-Module -Name $module -Scope CurrentUser -Force
}

# Copy Modules dir from current Powershell env to alternative version env
Write-Host "Copying modules to all Powershell instances"
if ($PSVersionTable.PSVersion.Major -le '5'){
  Copy-Item -Path "$profileDir\Modules\" -Recurse -Destination "$profileParentDir\PowerShell\"
}
elseif ($PSVersionTable.PSVersion.Major -eq '7'){
  Copy-Item -Path "$profileDir\Modules\" -Recurse -Destination "$profileParentDir\WindowsPowerShell\"
}

$symlinks = @{
  "$profileParentDir\WindowsPowershell\profile.ps1"    = "$PSScriptRoot\Powershell\profile.ps1"
  "$profileParentDir\PowerShell\profile.ps1"    = "$PSScriptRoot\Powershell\profile.ps1"
  "$env:APPDATA\Code\User\settings.json"  = "$PSScriptRoot\VSCode\settings.json"
  "$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" = "$PSScriptRoot\Windows Terminal\settings.json"
}

# Install Oh My Posh
Write-Host "Installing Oh My Posh"
Set-ExecutionPolicy Bypass -Scope Process -Force
$null = Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1')) | Out-Null
Start-Sleep -Seconds 5
# Install the CascadiaCode front pack
& "$env:localappdata\Programs\oh-my-posh\bin\oh-my-posh.exe" font install CascadiaCode | Out-Null

# Create Symbolic Links
Write-Host "Creating Symbolic Links..."
foreach ($symlink in $symlinks.GetEnumerator()) {
    Get-Item -Path $symlink.Key -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    New-Item -ItemType SymbolicLink -Path $symlink.Key -Target (Resolve-Path $symlink.Value) -Force | Out-Null
}

Write-Host -ForegroundColor Yellow "You may need to install Powershell 7 manually - https://learn.microsoft.com/en-gb/powershell/scripting/install/installing-powershell-on-windows?#msi"
Write-Host -ForegroundColor Green "Setup complete"