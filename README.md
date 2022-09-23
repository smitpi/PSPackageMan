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
 
## Functions
- [`Add-PSPackageManAppToList`](https://smitpi.github.io/PSPackageMan/Add-PSPackageManAppToList) -- Add an app to one more of the predefined GitHub Gist Lists.
- [`Add-PSPackageManDefaultsToProfile`](https://smitpi.github.io/PSPackageMan/Add-PSPackageManDefaultsToProfile) -- Add the parameter to PSDefaultParameters and also your profile.
- [`Get-PSPackageManAppList`](https://smitpi.github.io/PSPackageMan/Get-PSPackageManAppList) -- Show a List of all the GitHub Gist app Lists.
- [`Get-PSPackageManInstalledApp`](https://smitpi.github.io/PSPackageMan/Get-PSPackageManInstalledApp) -- This will display a list of installed apps, and their details in the repositories.
- [`Install-PSPackageManAppFromList`](https://smitpi.github.io/PSPackageMan/Install-PSPackageManAppFromList) -- Installs the apps from the GitHub Gist List.
- [`New-PSPackageManList`](https://smitpi.github.io/PSPackageMan/New-PSPackageManList) -- Creates a new list file on your GitHub Gist.
- [`Remove-PSPackageManAppFromList`](https://smitpi.github.io/PSPackageMan/Remove-PSPackageManAppFromList) -- Remove an app from one or more of the predefined GitHub Gist Lists.
- [`Remove-PSPackageManList`](https://smitpi.github.io/PSPackageMan/Remove-PSPackageManList) -- Deletes a list from your GitHub Gist.
- [`Save-PSPackageManList`](https://smitpi.github.io/PSPackageMan/Save-PSPackageManList) -- Saves the Gist List to the local machine
- [`Search-PSPackageManApp`](https://smitpi.github.io/PSPackageMan/Search-PSPackageManApp) -- Will search the winget and chocolatey repositories for apps
- [`Show-PSPackageManApp`](https://smitpi.github.io/PSPackageMan/Show-PSPackageManApp) -- Show an app to one of the predefined GitHub Gist Lists.
