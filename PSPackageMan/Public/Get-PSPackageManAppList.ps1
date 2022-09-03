
<#PSScriptInfo

.VERSION 0.1.0

.GUID 048bfc2c-4a55-49ef-bb0f-f43476711baa

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
Created [02/09/2022_19:24] Initial Script Creating

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Show a List of all the GitHub Gist app Lists. 

#> 


<#
.SYNOPSIS
Show a List of all the GitHub Gist app Lists.

.DESCRIPTION
Show a List of all the GitHub Gist app Lists.

.PARAMETER GitHubUserID
User with access to the gist.

.PARAMETER PublicGist
Select if the list is hosted publicly.

.PARAMETER GitHubToken
The token for that gist.

.EXAMPLE
Get-PSPackageManAppList -GitHubUserID $user -PublicGist

#>
Function Get-PSPackageManAppList {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSPackageMan/Get-PSPackageManAppList')]
	[OutputType([System.Object[]])]
	PARAM(
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


	[System.Collections.ArrayList]$GistObject = @()
	Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Create object"
	$PRGist.files | Get-Member -MemberType NoteProperty | ForEach-Object {
		$Content = (Invoke-WebRequest -Uri ($PRGist.files.$($_.name)).raw_url -Headers $headers).content | ConvertFrom-Json -ErrorAction Stop
		if ($Content.modifiedDate -notlike 'Unknown') {
			$modifiedDate = [datetime]$Content.ModifiedDate
			$modifiedUser = $Content.ModifiedUser
		} else { 
			$modifiedDate = 'Unknown'
			$modifiedUser = 'Unknown'
		}
		[void]$GistObject.Add([PSCustomObject]@{
				Name         = $_.Name
				Description  = $Content.Description
				Date         = [datetime]$Content.CreateDate
				Author       = $Content.Author
				ModifiedDate = $modifiedDate
				ModifiedUser = $modifiedUser
			})
	}

	$GistObject
	Write-Verbose "[$(Get-Date -Format HH:mm:ss) DONE]"

} #end Function
