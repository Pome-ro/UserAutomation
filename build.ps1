[cmdletbinding()]
param(
    [string[]]$Tasks = 'default'
)
if (!(Get-Module -Name Pester -ListAvailable)) {Write-Host "Installing Pester.."; Install-Module -Name Pester -Scope AllUsers -Verbose }
if (!(Get-Module -Name psake -ListAvailable)) {Write-Host "Installing PSake..";Install-Module -Name psake -Scope AllUsers -Verbose }
if (!(Get-Module -Name PSDeploy -ListAvailable)) {Write-Host "Installing PSDeploy..";Install-Module -Name PSDeploy -Scope AllUsers -Verbose }

Invoke-PSake -buildFile .\psake.build.ps1 -taskList $tasks -nologo