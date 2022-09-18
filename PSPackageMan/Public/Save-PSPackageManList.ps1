
<#PSScriptInfo

.VERSION 0.1.0

.GUID d941bfaa-dde1-4c98-9d29-d075be6ac4d0

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
Created [07/09/2022_17:36] Initial Script

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Saves the Gist List to the local machine 

#> 


<#
.SYNOPSIS
Saves the Gist List to the local machine

.DESCRIPTION
Saves the Gist List to the local machine

.PARAMETER ListName
Name of the list.

.PARAMETER GitHubUserID
User with access to the gist.

.PARAMETER PublicGist
Select if the list is hosted publicly.

.PARAMETER GitHubToken
The token for that gist.

.PARAMETER Path
Directory where files will be saved.

.EXAMPLE
Save-PSPackageManList -ListName BaseApps,een,twee -Path C:\temp

#>
Function Save-PSPackageManList {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSPackageMan/Save-PSPackageManList')]
	PARAM(
		[Parameter(Mandatory)]
		[string[]]$ListName,
		[Parameter(Mandatory)]
		[System.IO.DirectoryInfo]$Path,
		[Parameter(Mandatory)]
		[string]$GitHubUserID, 
		[Parameter(ParameterSetName = 'Public')]
		[switch]$PublicGist,
		[Parameter(ParameterSetName = 'Private')]
		[string]$GitHubToken
	)

	try {
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Connect to gist"
		$headers = @{}
		$auth = '{0}:{1}' -f $GitHubUserID, $GitHubToken
		$bytes = [System.Text.Encoding]::ASCII.GetBytes($auth)
		$base64 = [System.Convert]::ToBase64String($bytes)
		$headers.Authorization = 'Basic {0}' -f $base64

		$url = 'https://api.github.com/users/{0}/gists' -f $GitHubUserID
		$AllGist = Invoke-RestMethod -Uri $url -Method Get -Headers $headers -ErrorAction Stop
		$PRGist = $AllGist | Select-Object | Where-Object { $_.description -like 'PSPackageMan-ConfigFile' }
	} catch {throw "Can't connect to gist:`n $($_.Exception.Message)"}

	foreach ($List in $ListName) {
		try {
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Checking Config File"
			$Content = (Invoke-WebRequest -Uri ($PRGist.files.$($List)).raw_url -Headers $headers).content | ConvertFrom-Json -ErrorAction Stop
		} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
		$Content | ConvertTo-Json -Depth 5 | Set-Content -Path (Join-Path $Path -ChildPath "$($list).json") -Force
		Write-Host '[Saved]' -NoNewline -ForegroundColor Yellow; Write-Host " $($List) " -NoNewline -ForegroundColor Cyan; Write-Host "to $((Join-Path $Path -ChildPath "$($list).json"))" -ForegroundColor Green
	}
	Write-Verbose "[$(Get-Date -Format HH:mm:ss) DONE]"
} #end Function
$scriptblock = {
	param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
	(Get-PSPackageManAppList).name }
Register-ArgumentCompleter -CommandName Save-PSPackageManList -ParameterName ListName -ScriptBlock $scriptblock