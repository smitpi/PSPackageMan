
<#PSScriptInfo

.VERSION 0.1.0

.GUID 913bbbc5-5bea-4049-97df-1f8b80a9a8c9

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS ps

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [02/09/2022_19:58] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 This will display a list of installed apps, and their details in the repositories. 

#> 


<#
.SYNOPSIS
This will display a list of installed apps, and their details in the repositories.

.DESCRIPTION
This will display a list of installed apps, and their details in the repositories.

.PARAMETER PackageManager
Which package manager to query installed apps with.

.EXAMPLE
Show-PSPackageManInstalledApp -PackageManager AllManagers

#>
Function Show-PSPackageManInstalledApp {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSPackageMan/Show-PSPackageManInstalledApp')]
	[OutputType([System.Object[]])]
	PARAM(
		[ValidateSet('Chocolatey', 'Winget', 'AllManagers')]
		[string]$PackageManager
	)

	function getwinget {
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) BEGIN] Starting Winget extract"
		Invoke-Expression -Command "winget export -o $($env:tmp)\winget-extract.json" | Out-Null
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Winget config import"
		$importlist = Get-Content "$($env:tmp)\winget-extract.json" | ConvertFrom-Json
		$FinalList = $importlist.Sources.Packages | ForEach-Object {
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] AppID: $($_.PackageIdentifier)"		
			Search-PSPackageManApp -SearchString $_.PackageIdentifier -PackageManager Winget -MoreOptions -Exact
		}
		$FinalList
	}
	function getchoco {
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) BEGIN] Starting Choco extract"
		$allapps = choco list --local-only --limit-output
		$finallist = foreach ($app in $allapps) {
			$appdetail = $app -split '\|'
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] AppID: $($appdetail[0])"
			Search-PSPackageManApp -SearchString $appdetail[0] -PackageManager Chocolatey -MoreOptions -Exact
		}
		$FinalList
	}

	if ($PackageManager -like 'Winget') { return getwinget}
	if ($PackageManager -like 'Chocolatey') { return getchoco}
	if ($PackageManager -like 'AllManagers') {
		return [PSCustomObject]@{
			Winget     = getwinget
			Chocolatey = getchoco
		}
	}
	Write-Verbose "[$(Get-Date -Format HH:mm:ss) Complete]"
} #end Function
