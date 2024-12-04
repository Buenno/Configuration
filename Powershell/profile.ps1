oh-my-posh init pwsh | Invoke-Expression

# Import Modules

Import-Module posh-git
Import-Module Terminal-Icons


# Define Custom Functions

function New-Password {
    [CmdletBinding()]
    [Alias("New-Pass")]
    param(
        [Parameter()]
        [string] $Password
    )
    ConvertTo-SecureString -String $Password -AsPlainText
}

function Get-PublicIP {
    [CmdletBinding()]
    [Alias("gpip")]
    param()
    (Invoke-WebRequest http://ifconfig.me/ip).Content
}

function New-EmptyCustomObject {
  param (
      [string[]]$PropertyNames
  )
  
  $customObject = [PSCustomObject][Ordered]@{}
  $customObject | Select-Object -Property $PropertyNames
}
