
<#PSScriptInfo

.VERSION 0.1.0

.GUID 14e2a758-e1e0-4ed8-b648-5d94701edefb

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
Created [02/09/2022_19:26] Initial Script Creating

.PRIVATEDATA

#>


<# 

.DESCRIPTION 
 Show an app to one of the predefined GitHub Gist Lists. 

#> 


<#
.SYNOPSIS
Show an app to one of the predefined GitHub Gist Lists.

.DESCRIPTION
Show an app to one of the predefined GitHub Gist Lists.

.PARAMETER ListName
Name of the list.

.PARAMETER ShowAppDetail
Show more detail about a selected app.

.PARAMETER GitHubUserID
User with access to the gist.

.PARAMETER PublicGist
Select if the list is hosted publicly.

.PARAMETER GitHubToken
The token for that gist.

.EXAMPLE
Show-PSPackageManApp -ListName twee -GitHubUserID $user -PublicGist

#>
Function Show-PSPackageManApp {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSPackageMan/Show-PSPackageManApp')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(Mandatory)]
		[string[]]$ListName,
		[switch]$ShowAppDetail,
		[Parameter(Mandatory)]
		[string]$GitHubUserID,
		[Parameter(ParameterSetName = 'Public')]
		[switch]$PublicGist,
		[Parameter(ParameterSetName = 'Private')]
		[string]$GitHubToken
	)
	try {
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) BEGIN] Starting $($myinvocation.mycommand)"
		$headers = @{}
		$auth = '{0}:{1}' -f $GitHubUserID, $GitHubToken
		$bytes = [System.Text.Encoding]::ASCII.GetBytes($auth)
		$base64 = [System.Convert]::ToBase64String($bytes)
		$headers.Authorization = 'Basic {0}' -f $base64

		Write-Verbose "[$(Get-Date -Format HH:mm:ss) Starting connect to github"
		$url = 'https://api.github.com/users/{0}/gists' -f $GitHubUserID
		$AllGist = Invoke-RestMethod -Uri $url -Method Get -Headers $headers -ErrorAction Stop
		$PRGist = $AllGist | Select-Object | Where-Object { $_.description -like 'PSPackageMan-ConfigFile' }
	} catch {Write-Error "Can't connect to gist:`n $($_.Exception.Message)"}

	[System.Collections.Generic.List[PSCustomObject]]$AppObject = @()
	$index = 0
	foreach ($List in $ListName) {
		try {
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) Checking Config File"
			$Content = (Invoke-WebRequest -Uri ($PRGist.files.$($List)).raw_url -Headers $headers).content | ConvertFrom-Json -ErrorAction Stop
		} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}

		$Content.Apps | ForEach-Object {
			$AppObject.Add([PSCustomObject]@{
					Index          = $index
					ListName       = $List
					Name           = $_.Name
					ID             = $_.id
					PackageManager = $_.PackageManager
					Source         = $_.Source
				})
			$index++
		}
	}
	if ($ShowAppDetail) {
		$AppObject | Format-Table -AutoSize -Wrap

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
	} else {$AppObject}

} #end Function
$scriptblock = {
	param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
	if ([bool]($PSDefaultParameterValues.Keys -like '*:GitHubUserID')) {(Get-PSPackageManAppList).name | Where-Object {$_ -like "*$wordToComplete*"}}
}
Register-ArgumentCompleter -CommandName Show-PSPackageManApp -ParameterName ListName -ScriptBlock $scriptblock