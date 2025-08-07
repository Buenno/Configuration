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

Function Invoke-EntraSync {
    <#
    .SYNOPSIS
        Syncronise on-prem AD with Entra 
     
    .NOTES
        Name: Invoke-EntraSync
        Author: Toby Williams
        Version: 1.0
        DateCreated: 01/10/2024
     
    .EXAMPLE
        Invoke-EntraSync
     
    #>
     
    [CmdletBinding()]
    [Alias("Start-ADSyncSyncCycle")]
    [Alias("Invoke-ADSync")]
    [Alias("Invoke-AzureADSync")]
    param(
        [Parameter()]
        [System.Management.Automation.PSCredential]$Credential
    )
    
    BEGIN {
        $ErrorActionPreference = "Stop"
        $server = "GCDS"
        if (!$Credential){
            $Credential = Get-Credential
        }
    }
    
    PROCESS {
        try {
            Write-Host "Starting Entra AD sync..."
            $command = Invoke-Command -ComputerName $server -ScriptBlock {Start-ADSyncSyncCycle -PolicyType delta} -Credential $Credential
            if ($command.Result -eq "Success") {
                Write-Host "Sync completed successfully" -ForegroundColor Green
            }
            else {
                Write-Error "There was an issue executing the sync command. Check remote logs for more details." -ForegroundColor yellow
            }
        }
        catch {
            Write-Error "Sync failed. $_"
        }
    }
    
    END {}
}