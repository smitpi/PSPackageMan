# PSPackageMan
 
## Description
Creates a GitHub (Private or Public) Gist to host the details about your required apps. You can create more than one list to customize your requirements. These lists are then used to install or upgrade apps on Windows using Chocolatey or Winget. With this, you can install all your utilities on any machine unattended.
 
## Getting Started
- Install from PowerShell Gallery [PS Gallery](https://www.powershellgallery.com/packages/PSPackageMan)
```
Install-Module -Name PSPackageMan -Verbose
```
- or run this script to install from GitHub [GitHub Repo](https://github.com/smitpi/PSPackageMan)
```
$CurrentLocation = Get-Item .
$ModuleDestination = (Join-Path (Get-Item (Join-Path (Get-Item $profile).Directory 'Modules')).FullName -ChildPath PSPackageMan)
git clone --depth 1 https://github.com/smitpi/PSPackageMan $ModuleDestination 2>&1 | Write-Host -ForegroundColor Yellow
Set-Location $ModuleDestination
git filter-branch --prune-empty --subdirectory-filter Output HEAD 2>&1 | Write-Host -ForegroundColor Yellow
Set-Location $CurrentLocation
```
- Then import the module into your session
```
Import-Module PSPackageMan -Verbose -Force
```
- or run these commands for more help and details.
```
Get-Command -Module PSPackageMan
Get-Help about_PSPackageMan
```
Documentation can be found at: [Github_Pages](https://smitpi.github.io/PSPackageMan)
