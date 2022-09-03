
<#PSScriptInfo

.VERSION 0.1.0

.GUID c02fc81d-e44b-4b4d-b3ff-706331250071

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
Created [02/09/2022_19:30] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Will search the winget and chocolatey repositories for apps 

#> 


<#
.SYNOPSIS
Will search the winget and chocolatey repositories for apps

.DESCRIPTION
Will search the winget and chocolatey repositories for apps

.PARAMETER SearchString
What app to search for.

.PARAMETER PackageManager
Which app manager to use (Chocolatey or winget)

.PARAMETER MoreOptions
Select for more search options.

.PARAMETER ChocoSource
Chocolatey source

.PARAMETER Exact
Limits the search to the exact search string.

.EXAMPLE
Search-PSPackageManApp -SearchString office -PackageManager Winget

#>
Function Search-PSPackageManApp {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSPackageMan/Search-PSPackageManApp')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
		[ValidateNotNullOrEmpty()]
		[Alias('Id', 'Name', 'PackageIdentifier')]
		[string[]]$SearchString,
		[Parameter(Mandatory, ValueFromPipelineByPropertyName)]
		[ValidateSet('Chocolatey', 'Winget', 'AllManagers')]
		[string]$PackageManager,
		[Parameter(ParameterSetName = 'MoreOptions')]
		[switch]$MoreOptions,
		[Parameter(ParameterSetName = 'MoreOptions')]
		[string]$ChocoSource,
		[Parameter(ParameterSetName = 'MoreOptions')]
		[switch]$Exact,
		[Parameter(ParameterSetName = 'MoreOptions')]
		[switch]$ShowAppDetail
	)
	begin {
		function AppDetails {
			PARAM ($AppObject)

			Write-Color 'Please pick from below for' -Color Gray -LinesBefore 2 -LinesAfter 1
			$index = 0
			$AppObject | ForEach-Object {
				Write-Color "$($index)) ", "$($_.name)", " [$($_.version)]", " $($_.source)" -Color Yellow, Green, Cyan, Gray
				$index++ 
			}
			Write-Host ''
			[int]$AskApp = Read-Host 'Index Number for App Details'
			if ($AppObject[$AskApp].PackageManager -like 'Chocolatey') {
				[System.Collections.Generic.List[pscustomobject]]$Result = @()
				choco info $($AppObject[$AskApp].Name) --source $($AppObject[$AskApp].Source) | Where-Object { $result.add($_) }
				$ID = choco search $($AppObject[$AskApp].Name) --source $($AppObject[$AskApp].Source) --Exact --limit-output
				$descb = $Result.IndexOf(($Result | Where-Object {$_ -like '*Description:*'}))
				[PSCustomObject]@{
					Name        = $ID.split('|')[0]
					Version     = $ID.split('|')[1]
					Published   = ($Result | Where-Object {$_ -like '*Published:*'}).split('|')[1].replace('Published: ', $null).trim()
					Downloads   = ($Result | Where-Object {$_ -like '*Downloads:*'}).split('|')[0].replace('Number of Downloads: ', $null).trim()
					Summary     = ($Result | Where-Object {$_ -like '*Summary:*'}).replace('Summary: ', $null).trim()
					Description = (($Result[$descb..($Result.count - 2)]).replace('Description: ', $null) | Out-String).trim()
				}
			}
			if ($AppObject[$AskApp].PackageManager -like 'Winget') {
				Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESSES] starting winget search"
				$Command = "winget show --accept-source-agreements  `"$($AppObject[$AskApp].id)`""
				[System.Collections.Generic.List[pscustomobject]]$Result = @()
				Invoke-Expression -Command $Command | Where-Object { $result.add($_) }
				$descb = $Result.IndexOf(($Result | Where-Object {$_ -like 'Description:*'}))
				$desce = $Result.IndexOf(($Result | Where-Object {$_ -like 'License:*'}))
				[PSCustomObject]@{
					Name        = ($Result | Where-Object {$_ -like 'Found*'}).replace('Found ', $null)
					Version     = $Result | Where-Object {$_ -like 'Version:*'}
					Publisher   = $Result | Where-Object {$_ -like 'Publisher:*'}
					License     = $Result | Where-Object {$_ -like 'License:*'}
					Category    = $Result | Where-Object {$_ -like 'Category:*'}
					Pricing     = $Result | Where-Object {$_ -like 'Pricing:*'}
					Description = (($Result[$descb..($desce - 1)]).replace('Description:', $null) | Out-String).trim()
				}
			}
		}
		function chocosearch {
			PARAM($SearchString, $ChocoSource, $Exact)

			if (Get-Command choco.exe -ErrorAction SilentlyContinue) {
				try {
					Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESSES] Starting Choco search"
					[System.Collections.Generic.List[pscustomobject]]$ChocoObject = @()
					$source = 'chocolatey'
					$command = "choco search $($SearchString) --limit-output --order-by-popularity"
					if ($ChocoSource) {
						$source = $ChocoSource
						$command = $command + " --source $($ChocoSource)"
					} 
					if ($Exact) {
						$command = $command + ' --Exact'
					}
					$allapps = Invoke-Expression -Command $command
					Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESSES] Building choco output"
					foreach ($app in $allapps) {
						$appdetail = $app -split '\|'
						$ChocoObject.add([pscustomobject]@{
								Name           = $appdetail[0]
								Id             = $appdetail[0]
								version        = $appdetail[1]
								PackageManager = 'Chocolatey'
								source         = $Source
							})
					}
					Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESSES] Choco done"
					if ($ShowAppDetail) {AppDetails $ChocoObject}
					else {$ChocoObject}
				} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
			} else {Write-Warning "Chocolatey is not installed.`nInstall it from https://chocolatey.org/install "}
		}
		function wingetsearch {
			PARAM($SearchString, $DetailedResults, $Exact)
			if (Get-Command winget.exe -ErrorAction SilentlyContinue) {
				try {
					Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESSES] starting winget search"
					$Command = "winget search --accept-source-agreements  `"$($SearchString)`""
					if ($Exact) {$Command = $Command + ' --Exact'}
					[System.Collections.Generic.List[pscustomobject]]$Result = @()
					Invoke-Expression -Command $Command | Where-Object { $result.add($_) }
					if ($LASTEXITCODE -ne 0) {Write-Warning "Error searching Code: $($LASTEXITCODE)"}
					elseif ($Result -match 'No Package') {Write-Warning 'No package found matching input criteria.'}
					else {
						Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESSES] Building winget output"
						[System.Collections.Generic.List[pscustomobject]]$WingetObject = @()
						$begin = ($Result.IndexOf($Result -match '---') + 1)
						$end = $Result.count
						foreach ($line in ($Result[$($begin)..$($end)])) {
							if ($line -like "*Tag*" -or $line -like "*Moniker*"){
								$splited = $line | Split-String -Separator ' ' -RemoveEmptyStrings
								$WingetObject.add([pscustomobject]@{
										Name           = ($splited[0..($splited.count - 4)] -join ' ')
										id             = $splited[-5]
										version        = $splited[-4]
										PackageManager = 'Winget'
										source         = $splited[-1]
									})
							}
							else {
							$splited = $line | Split-String -Separator ' ' -RemoveEmptyStrings
							$WingetObject.add([pscustomobject]@{
									Name           = ($splited[0..($splited.count - 4)] -join ' ')
									id             = $splited[-3]
									version        = $splited[-2]
									PackageManager = 'Winget'
									source         = $splited[-1]
								})
							}
						}
						Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESSES] Winget done."
						if ($ShowAppDetail) {AppDetails $WingetObject}
						else {$WingetObject}					}
				} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
			} else {Write-Warning "Winget is not installed.`nInstall it from https://docs.microsoft.com/en-us/windows/package-manager/winget/ "}
		}
	}
	process {
		foreach ($search in $SearchString) {
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESSES] Starting search $($search)"
			if ($PackageManager -like 'AllManagers') {
				[PSCustomObject]@{
					Chocolatey = chocosearch -SearchString $search -ChocoSource $ChocoSource -Exact $Exact
					Winget     = wingetsearch -SearchString $search -DetailedResults $DetailedResults
				}
			}
			if ($PackageManager -like 'Chocolatey') {
				chocosearch -SearchString $search -ChocoSource $ChocoSource -Exact $Exact
			}
			if ($PackageManager -like 'Winget') {
				if (Get-Command winget -ErrorAction SilentlyContinue) {
					wingetsearch -SearchString $search -DetailedResults $DetailedResults -Exact $Exact
				} else {Write-Error 'Winget is not installed. Please install and retry the search.'}
			}
		}
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) DONE]"
	}
	end {}
} #end Function

Register-ArgumentCompleter -CommandName Search-PSPackageManApp -ParameterName ChocoSource -ScriptBlock {choco source --limit-output | ForEach-Object {$_.split('|')[0]}}
Register-ArgumentCompleter -CommandName Search-PSPackageManApp -ParameterName WingetSource -ScriptBlock {(winget source list) -match 'http' -split '\s+' -notmatch 'http'}
