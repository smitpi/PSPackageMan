
<#PSScriptInfo

.VERSION 0.1.0

.GUID a507c9b6-300a-4119-9aec-e005fc108733

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
Created [02/09/2022_19:43] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Add the parameter to PSDefaultParameters and also your profile. 

#> 


<#
.SYNOPSIS
Add the parameter to PSDefaultParameters and also your profile.

.DESCRIPTION
Add the parameter to PSDefaultParameters and also your profile.

.PARAMETER GitHubUserID
User with access to the gist.

.PARAMETER PublicGist
Select if the list is hosted publicly.

.PARAMETER GitHubToken
The token for that gist.

.PARAMETER RemoveConfig
Remove the config from your profile.

.EXAMPLE
Add-PSPackageManDefaultsToProfile -GitHubUserID $user -PublicGist

#>
Function Add-PSPackageManDefaultsToProfile {
		[Cmdletbinding(HelpURI = "https://smitpi.github.io/PSPackageMan/Add-PSPackageManDefaultsToProfile")]
	    [OutputType([System.Object[]])]
	PARAM(
		[Parameter(Mandatory = $true)]
		[string]$GitHubUserID, 
		[Parameter(ParameterSetName = 'Public')]
		[switch]$PublicGist,
		[Parameter(ParameterSetName = 'Private')]
		[string]$GitHubToken,
		[switch]$RemoveConfig
	)

	## TODO Add remove config from profile.

	if ($PublicGist) {
		$Script:PSDefaultParameterValues['*PSPackageMan*:GitHubUserID'] = "$($GitHubUserID)"
		$Script:PSDefaultParameterValues['*PSPackageMan*:PublicGist'] = $true
		$Script:PSDefaultParameterValues['*PSPackageMan*:Scope'] = "$($Scope)"

		$ToAppend = @"

#region PSPackageMan Defaults
`$PSDefaultParameterValues['*PSPackageMan*:GitHubUserID'] = "$($GitHubUserID)"
`$PSDefaultParameterValues['*PSPackageMan*:PublicGist'] = `$true
#endregion PSPackageMan
"@
	} else {
		$Script:PSDefaultParameterValues['*PSPackageMan*:GitHubUserID'] = "$($GitHubUserID)"
		$Script:PSDefaultParameterValues['*PSPackageMan*:GitHubToken'] = "$($GitHubToken)"
		$ToAppend = @"
		
#region PSPackageMan Defaults
`$PSDefaultParameterValues['*PSPackageMan*:GitHubUserID'] =  "$($GitHubUserID)"
`$PSDefaultParameterValues['*PSPackageMan*:GitHubToken'] =  "$($GitHubToken)"
#endregion PSPackageMan
"@
	}

	try {
		$CheckProfile = Get-Item $PROFILE -ErrorAction Stop
	} catch { $CheckProfile = New-Item $PROFILE -ItemType File -Force}
	
	$Files = Get-ChildItem -Path "$($CheckProfile.Directory)\*profile*"

	foreach ($file in $files) {	
		$tmp = Get-Content -Path $file.FullName | Where-Object { $_ -notlike '*PSPackageMan*'}
		$tmp | Set-Content -Path $file.FullName -Force
		if (-not($RemoveConfig)) {Add-Content -Value $ToAppend -Path $file.FullName -Force -Encoding utf8 }
		Write-Host '[Updated]' -NoNewline -ForegroundColor Yellow; Write-Host ' Profile File:' -NoNewline -ForegroundColor Cyan; Write-Host " $($file.FullName)" -ForegroundColor Green
	}

} #end Function