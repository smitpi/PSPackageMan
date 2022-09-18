
<#PSScriptInfo

.VERSION 0.1.0

.GUID 40df969c-445c-4caf-b43c-6cdd6288d91f

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
Created [02/09/2022_19:34] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Add an app to one more of the predefined GitHub Gist Lists. 

#> 


<#
.SYNOPSIS
 Add an app to one more of the predefined GitHub Gist Lists. 

.DESCRIPTION
 Add an app to one more of the predefined GitHub Gist Lists. 

.PARAMETER ListName
Name of the list.

.PARAMETER SearchString
Application name to search for.

.PARAMETER PackageManager
Which app manager to use (Chocolatey or winget)

.PARAMETER ChocoSource
Chocolatey source

.PARAMETER WingetSource
Winget source.

.PARAMETER GitHubUserID
User with access to the gist.

.PARAMETER GitHubToken
The token for that gist.

.PARAMETER MoreOptions
Select for more search options.

.PARAMETER ChocoSource
Chocolatey source

.PARAMETER Exact
Limits the search to the exact search string.

.EXAMPLE
Add-PSPackageManAppToList -ListName twee -Name speedtest -PackageManager Winget -GitHubUserID $User -GitHubToken $GitHubToken

#>
Function Add-PSPackageManAppToList {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSPackageMan/Add-PSPackageManAppToList')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(Mandatory)]
		[string[]]$ListName,
		[Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
		[Alias('Id', 'PackageIdentifier', 'Name')]
		[string[]]$SearchString,
		[ValidateSet('Chocolatey', 'Winget')]
		[Parameter(Mandatory, ValueFromPipelineByPropertyName)]
		[string]$PackageManager,
		[Parameter(Mandatory)]
		[string]$GitHubUserID,
		[Parameter(Mandatory)]
		[string]$GitHubToken,
		[string]$ChocoSource,
		[switch]$Exact
	)

	begin {
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
		[System.Collections.Generic.List[PSCustomObject]]$NewAppObject = @()
	}
	process {
		foreach ($NewApp in $SearchString) {
			try {
				Write-Color '[Searching]', " $($NewApp)" -Color Yellow, Gray
				Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESSES] NewApp $($newapp)"
				[System.Collections.Generic.List[PSCustomObject]]$SearchResult = @()
				$SearchParams = $PSBoundParameters
				[void]$SearchParams.Remove('ListName')
				[void]$SearchParams.Remove('GithubUserID')
				[void]$SearchParams.Remove('GitHubToken')
				[void]$SearchParams.Remove('SearchString')
				Search-PSPackageManApp -SearchString $NewApp @SearchParams | ForEach-Object {$SearchResult.Add($_)}
				if ($SearchResult.Count -eq 1) {
					Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESSES] Adding to object"
					$NewAppObject.Add([PSCustomObject]@{
							Name           = $SearchResult.Name
							Id             = $SearchResult.Id
							PackageManager = $PackageManager
							Source         = $SearchResult.source
						})
				} elseif ($SearchResult.Count -gt 1) {
					Write-Color 'Please pick from below for', " $($NewApp)" -Color Gray, Yellow -LinesBefore 2 -LinesAfter 1
					$index = 0
					$SearchResult | ForEach-Object {
						Write-Color "$($index)) ", "$($_.name)", " [$($_.version)]" -Color Yellow, Green, Cyan
						$index++ 
					}
					Write-Host ''
					[int]$PickIndex = Read-Host 'Choose'
					Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESSES] Adding to object"
					$NewAppObject.Add([PSCustomObject]@{
							Name           = $SearchResult[$PickIndex].Name
							Id             = $SearchResult[$PickIndex].Id
							PackageManager = $PackageManager
							Source         = $SearchResult[$PickIndex].source
						})
				} else {Write-Error 'No App Found'}
				Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESSES] Done adding $($newapp)"
			} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
		}		
	}
	end {
		foreach ($list in $ListName) {
			try {
				Write-Verbose "[$(Get-Date -Format HH:mm:ss) Checking Config File"
				$Content = (Invoke-WebRequest -Uri ($PRGist.files.$($List)).raw_url -Headers $headers).content | ConvertFrom-Json -ErrorAction Stop
			} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
			try {
				[System.Collections.Generic.List[PSCustomObject]]$AppObject = @()
				$Content.Apps | Where-Object {$_ -notlike $null} | ForEach-Object {
					if ($AppObject.Exists({ -not (Compare-Object $args[0].psobject.properties.value $_.psobject.Properties.value) })) {
						Write-Color 'Duplicate Found', " ListName: $($list)", " Name: $($_.name)" -Color Gray, DarkYellow, DarkCyan
					} else {$AppObject.Add($_)}
				}
				$NewAppObject | Where-Object {$_ -notlike $null} | ForEach-Object {
					if ($AppObject.Exists({ -not (Compare-Object $args[0].psobject.properties.value $_.psobject.Properties.value) })) {
						Write-Color 'Duplicate Found', " ListName: $($list)", " Name: $($_.name)" -Color Gray, DarkYellow, DarkCyan
					} else {$AppObject.Add($_)}
				}
			} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) END] Completing and sorting object"
			$Content.Apps = $AppObject
			$Content.ModifiedDate = "$(Get-Date -Format u)"
			$content.ModifiedUser = "$($env:USERNAME.ToLower())@$($env:USERDNSDOMAIN.ToLower())"
			try {
				Write-Verbose "[$(Get-Date -Format HH:mm:ss) END] Uploading to gist"
				$Body = @{}
				$files = @{}
				$Files["$($PRGist.files.$($List).Filename)"] = @{content = ( $Content | ConvertTo-Json | Out-String ) }
				$Body.files = $Files
				$Uri = 'https://api.github.com/gists/{0}' -f $PRGist.id
				$json = ConvertTo-Json -InputObject $Body
				$json = [System.Text.Encoding]::UTF8.GetBytes($json)
				$null = Invoke-WebRequest -Headers $headers -Uri $Uri -Method Patch -Body $json -ErrorAction Stop
				Write-Host '[Uploaded]' -NoNewline -ForegroundColor Yellow; Write-Host " List: $($List)" -NoNewline -ForegroundColor Cyan; Write-Host ' to Github Gist' -ForegroundColor Green
			} catch {Write-Error "Can't connect to gist:`n $($_.Exception.Message)"}
		}
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) DONE]"
	}
} #end Function
$scriptblock = {
	param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
	(Get-PSPackageManAppList).name }
Register-ArgumentCompleter -CommandName Add-PSPackageManAppToList -ParameterName ListName -ScriptBlock $scriptblock
Register-ArgumentCompleter -CommandName Add-PSPackageManAppToList -ParameterName ChocoSource -ScriptBlock {choco source --limit-output | ForEach-Object {$_.split('|')[0]}}
