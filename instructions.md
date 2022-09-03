# PSPackageMan
 
## Description
Creates a GitHub (Private or Public) Gist to host the details about your required apps. You can create more than one list to customize your reuirements. These lists are then used to install or upgrade apps on Windows using Chcocolatey or Winget. With this, you can install all your utilities on any machine unatended.
 
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
