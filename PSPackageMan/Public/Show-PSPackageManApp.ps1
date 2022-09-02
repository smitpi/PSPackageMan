
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
		[string]$ListName,
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

	try {
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) Checking Config File"
		$Content = (Invoke-WebRequest -Uri ($PRGist.files.$($ListName)).raw_url -Headers $headers).content | ConvertFrom-Json -ErrorAction Stop
	} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}

	[System.Collections.Generic.List[PSCustomObject]]$AppObject = @()
	$Content.Apps | ForEach-Object {[void]$AppObject.Add($_)}

	$AppObject

} #end Function
$scriptblock = {
	param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
	if ([bool]($PSDefaultParameterValues.Keys -like '*:GitHubUserID')) {(Show-PSPackageManAppList).name | Where-Object {$_ -like "*$wordToComplete*"}}
}
Register-ArgumentCompleter -CommandName Show-PSPackageManApp -ParameterName ListName -ScriptBlock $scriptblock