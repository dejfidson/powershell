﻿$nstPath = "HKLM:\SOFTWARE\Microsoft\Microsoft Dynamics NAV\90\Service"
$managementDllPath = Join-Path (Get-ItemProperty -path $nstPath).Path '\Microsoft.Dynamics.Nav.Management.dll'
Import-Module $managementDllPath -ErrorVariable errorVariable -ErrorAction SilentlyContinue

function Get-NAVServerConfigurationList {
[CmdletBinding()]
    param (
    [parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [String]$ServerInstance
    )
BEGIN
    {
    $ResultObjectArray = @()
    }
PROCESS
    {
    $CurrentServerInstance = Get-NAVServerInstance -ServerInstance $ServerInstance
    $CurrentConfig = $CurrentServerInstance | Get-NAVServerConfiguration -AsXml
    foreach ($Setting in $CurrentConfig.configuration.appSettings.add)
        {
        $ResultObject = New-Object System.Object
        $ResultObject | Add-Member -type NoteProperty -name ServiceInstance -value $CurrentServerInstance.ServerInstance
        $ResultObject | Add-Member -type NoteProperty -name Key -value $Setting.Key
        $ResultObject | Add-Member -Type NoteProperty -Name Value -Value $Setting.Value
        $ResultObjectArray += $ResultObject
        }
    }
END
    {
    $ResultObjectArray
    }
}

Get-NAVServerInstance |
Where-Object –FilterScript { $PSItem.Version –like ‘9.0*‘} |
Get-NAVServerConfigurationList | 
Where-Object Key -eq “ManagementServicesPort” |
Sort-Object -Property Value |
Format-Table -Property ServiceInstance,Value -AutoSize -Wrap