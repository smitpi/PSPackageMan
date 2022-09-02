# PSPackageMan
 
## Description
Uses a GithHub Gist List to manage installed software on Windows using Winget or Chocolatey
 
## Getting Started
- Install from PowerShell Gallery [PS Gallery](https://www.powershellgallery.com/packages/PSPackageMan)
```
Install-Module -Name PSPackageMan -Verbose
```
- or from GitHub [GitHub Repo](https://github.com/smitpi/PSPackageMan)
```
git clone https://github.com/smitpi/PSPackageMan (Join-Path (get-item (Join-Path (Get-Item $profile).Directory 'Modules')).FullName -ChildPath PSPackageMan)
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
