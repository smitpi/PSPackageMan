
<#PSScriptInfo

.VERSION 0.1.0

.GUID 0e87739f-4ddd-4a2e-89d8-e354dcab5b58

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
Created [02/09/2022_19:47] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Deletes a list from your GitHub Gist. 

#> 


<#
.SYNOPSIS
Deletes a list from your GitHub Gist.

.DESCRIPTION
Deletes a list from your GitHub Gist.

.PARAMETER ListName
The name of the list to remove.

.PARAMETER GitHubUserID
User with access to the gist.

.PARAMETER GitHubToken
The token for that gist.

.EXAMPLE
Remove-PSPackageManList -ListName Attempt1

#>
Function Remove-PSPackageManList {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSPackageMan/Remove-PSPackageManList')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(Mandatory)]
		[string]$ListName,
		[Parameter(Mandatory)]
		[string]$GitHubUserID,
		[Parameter(Mandatory)]
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


	Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Create object"
	$CheckExist = $PRGist.files | Get-Member -MemberType NoteProperty | Where-Object {$_.name -like $ListName}
	if (-not([string]::IsNullOrEmpty($CheckExist))) {
		try {
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Remove list from Gist"
			$Body = @{}
			$files = @{}
			$Files["$($ListName)"] = $null
			$Body.files = $Files
			$Uri = 'https://api.github.com/gists/{0}' -f $PRGist.id
			$json = ConvertTo-Json -InputObject $Body
			$json = [System.Text.Encoding]::UTF8.GetBytes($json)
			$null = Invoke-WebRequest -Headers $headers -Uri $Uri -Method Patch -Body $json -ErrorAction Stop
			Write-Host '[Removed]' -NoNewline -ForegroundColor Yellow; Write-Host " $($ListName)" -NoNewline -ForegroundColor Cyan; Write-Host ' from Github Gist' -ForegroundColor DarkRed
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] updated gist."
		} catch {Write-Error "Can't connect to gist:`n $($_.Exception.Message)"}
	}
	Write-Verbose "[$(Get-Date -Format HH:mm:ss) DONE]"

} #end Function
$scriptblock = {
	param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
	if ([bool]($PSDefaultParameterValues.Keys -like '*:GitHubUserID')) {(Show-PSPackageManAppList).name | Where-Object {$_ -like "*$wordToComplete*"}}
}
Register-ArgumentCompleter -CommandName Remove-PSPackageManList -ParameterName ListName -ScriptBlock $scriptblock