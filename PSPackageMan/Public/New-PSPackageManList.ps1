
<#PSScriptInfo

.VERSION 0.1.0

.GUID fde6ec4f-77aa-401b-afb9-9b01a0251bfe

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
Created [02/09/2022_19:51] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Creates a new list file on your GitHub Gist. 

#> 


<#
.SYNOPSIS
Creates a new list file on your GitHub Gist.

.DESCRIPTION
Creates a new list file on your GitHub Gist.

.PARAMETER ListName
The name of the new list.

.PARAMETER Description
A Short description for the list.

.PARAMETER GitHubUserID
User with access to the gist.

.PARAMETER GitHubToken
The token for that gist.

.EXAMPLE
New-PSPackageManList -ListName drie -Description "Die derde een" -GitHubUserID $user -GitHubToken $GitHubToken

#>
Function New-PSPackageManList {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSPackageMan/New-PSPackageManList')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(Mandatory)]
		[string]$ListName,
		[Parameter(Mandatory)]
		[string]$Description,
		[Parameter(Mandatory)]
		[string]$GitHubUserID, 
		[Parameter(Mandatory)]
		[string]$GitHubToken
	)

	Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Creating config"
	$NewConfig = [PSCustomObject]@{
		CreateDate   = (Get-Date -Format u)
		Description  = $Description
		Author       = "$($env:USERNAME.ToLower())"
		ModifiedDate = 'Unknown'
		ModifiedUser = 'Unknown'
		Apps         = [PSCustomObject]@{}
 } | ConvertTo-Json

	$ConfigFile = Join-Path $env:TEMP -ChildPath "$($ListName).json"
	Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Create temp file"
	if (Test-Path $ConfigFile) {
		Write-Warning "Config File exists, Renaming file to $($ListName)-$(Get-Date -Format yyyyMMdd_HHmm).json"	
		try {
			Rename-Item $ConfigFile -NewName "$($ListName)-$(Get-Date -Format yyyyMMdd_HHmm).json" -Force -ErrorAction Stop | Out-Null
		} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message);exit"}
	}
	try {
		$NewConfig | Set-Content -Path $ConfigFile -Encoding utf8 -ErrorAction Stop
	} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}


	try {
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Connecting to Gist"
		$headers = @{}
		$auth = '{0}:{1}' -f $GitHubUserID, $GitHubToken
		$bytes = [System.Text.Encoding]::ASCII.GetBytes($auth)
		$base64 = [System.Convert]::ToBase64String($bytes)
		$headers.Authorization = 'Basic {0}' -f $base64

		$url = 'https://api.github.com/users/{0}/gists' -f $GitHubUserID
		$AllGist = Invoke-RestMethod -Uri $url -Method Get -Headers $headers -ErrorAction Stop
		$PRGist = $AllGist | Select-Object | Where-Object { $_.description -like 'PSPackageMan-ConfigFile' }
	} catch {Write-Error "Can't connect to gist:`n $($_.Exception.Message)"}

		
	if ([string]::IsNullOrEmpty($PRGist)) {
		try {
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Uploading to gist"
			$Body = @{}
			$files = @{}
			$Files["$($ListName)"] = @{content = ( Get-Content (Get-Item $ConfigFile).FullName -Encoding UTF8 | Out-String ) }
			$Body.files = $Files
			$Body.description = 'PSPackageMan-ConfigFile'
			$json = ConvertTo-Json -InputObject $Body
			$json = [System.Text.Encoding]::UTF8.GetBytes($json)
			$null = Invoke-WebRequest -Headers $headers -Uri https://api.github.com/gists -Method Post -Body $json -ErrorAction Stop
			Write-Host '[Uploaded]' -NoNewline -ForegroundColor Yellow; Write-Host " $($ListName)" -NoNewline -ForegroundColor Cyan; Write-Host ' to Github Gist' -ForegroundColor Green

		} catch {Write-Error "Can't connect to gist:`n $($_.Exception.Message)"}
	} else {
		try {
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Uploading to Gist"
			$Body = @{}
			$files = @{}
			$Files["$($ListName)"] = @{content = ( Get-Content (Get-Item $ConfigFile).FullName -Encoding UTF8 | Out-String ) }
			$Body.files = $Files
			$Uri = 'https://api.github.com/gists/{0}' -f $PRGist.id
			$json = ConvertTo-Json -InputObject $Body
			$json = [System.Text.Encoding]::UTF8.GetBytes($json)
			$null = Invoke-WebRequest -Headers $headers -Uri $Uri -Method Patch -Body $json -ErrorAction Stop
			Write-Host '[Uploaded]' -NoNewline -ForegroundColor Yellow; Write-Host " $($ListName)" -NoNewline -ForegroundColor Cyan; Write-Host ' to Github Gist' -ForegroundColor Green
		} catch {Write-Error "Can't connect to gist:`n $($_.Exception.Message)"}
	}
	Write-Verbose "[$(Get-Date -Format HH:mm:ss) DONE]"
} #end Function
