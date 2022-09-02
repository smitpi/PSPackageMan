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
 
## Functions
- [`Add-PSPackageManAppToList`](https://smitpi.github.io/PSPackageMan/Add-PSPackageManAppToList) -- Add an app to one more of the predefined GitHub Gist Lists.
- [`Add-PSPackageManDefaultsToProfile`](https://smitpi.github.io/PSPackageMan/Add-PSPackageManDefaultsToProfile) -- Add the parameter to PSDefaultParameters and also your profile.
- [`Install-PSPackageManAppFromList`](https://smitpi.github.io/PSPackageMan/Install-PSPackageManAppFromList) -- Installs the apps from the GitHub Gist List.
- [`New-PSPackageManList`](https://smitpi.github.io/PSPackageMan/New-PSPackageManList) -- Creates a new list file on your GitHub Gist.
- [`Remove-PSPackageManAppFromList`](https://smitpi.github.io/PSPackageMan/Remove-PSPackageManAppFromList) -- Remove an app from one or more of the predefined GitHub Gist Lists.
- [`Remove-PSPackageManList`](https://smitpi.github.io/PSPackageMan/Remove-PSPackageManList) -- Deletes a list from your GitHub Gist.
- [`Search-PSPackageManApp`](https://smitpi.github.io/PSPackageMan/Search-PSPackageManApp) -- Will search the winget and chocolatey repositories for apps
- [`Show-PSPackageManApp`](https://smitpi.github.io/PSPackageMan/Show-PSPackageManApp) -- Show an app to one of the predefined GitHub Gist Lists.
- [`Show-PSPackageManAppList`](https://smitpi.github.io/PSPackageMan/Show-PSPackageManAppList) -- Show a List of all the GitHub Gist app Lists.
- [`Show-PSPackageManInstalledApp`](https://smitpi.github.io/PSPackageMan/Show-PSPackageManInstalledApp) -- This will display a list of installed apps, and their details in the repositories.
