
<#PSScriptInfo

.VERSION 0.1.0

.GUID 7e013f90-ca32-4eba-a3c2-77111db5744b

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
Created [02/09/2022_19:54] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Remove an app from one or more of the predefined GitHub Gist Lists. 

#> 


<#
.SYNOPSIS
Remove an app from one or more of the predefined GitHub Gist Lists.

.DESCRIPTION
Remove an app from one or more of the predefined GitHub Gist Lists.

.PARAMETER ListName
Name of the list.

.PARAMETER GitHubUserID
User with access to the gist.

.PARAMETER GitHubToken
The token for that gist.

.EXAMPLE
Remove-PSPackageManAppFromList -ListName twee,drie -Name speedtest -GitHubUserID $user -GitHubToken $GitHubToken

#>
Function Remove-PSPackageManAppFromList {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSPackageMan/Remove-PSPackageManAppFromList')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(Mandatory)]
		[string]$ListName,
		[Parameter(Mandatory)]
		[string]$GitHubUserID,
		[Parameter(Mandatory)]
		[string]$GitHubToken
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

		try {
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) Checking Config File"
			$Content = (Invoke-WebRequest -Uri ($PRGist.files.$($ListName)).raw_url -Headers $headers).content | ConvertFrom-Json -ErrorAction Stop
		} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}

		[System.Collections.Generic.List[PSCustomObject]]$AppObject = @()
		$Content.Apps | ForEach-Object {[void]$AppObject.Add($_)}
	}
	process {
		Write-Color 'Please pick from below'
		do {
			$index = 0
			$AppObject | ForEach-Object {
				Write-Color "$($index)) ", "$($_.name)", " [$($_.PackageManager)]" -Color Yellow, Green, Cyan
				$index++ 
			}
			Write-Host 'Press Q to exit'
			$PickIndex = Read-Host 'Choose'

			if ($PickIndex.ToLower() -notlike 'q') {$AppObject.Remove($AppObject[[int]$PickIndex])}
		} while ($PickIndex.ToLower() -notlike 'q')
	}
	end {
		$Content.Apps = $AppObject | Sort-Object -Property name
		$Content.ModifiedDate = "$(Get-Date -Format u)"
		$content.ModifiedUser = "$($env:USERNAME.ToLower())"
		try {
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Uploading to gist"
			$Body = @{}
			$files = @{}
			$Files["$($PRGist.files.$($ListName).Filename)"] = @{content = ( $Content | ConvertTo-Json | Out-String ) }
			$Body.files = $Files
			$Uri = 'https://api.github.com/gists/{0}' -f $PRGist.id
			$json = ConvertTo-Json -InputObject $Body
			$json = [System.Text.Encoding]::UTF8.GetBytes($json)
			$null = Invoke-WebRequest -Headers $headers -Uri $Uri -Method Patch -Body $json -ErrorAction Stop
			Write-Host '[Uploaded]' -NoNewline -ForegroundColor Yellow; Write-Host " List: $($ListName)" -NoNewline -ForegroundColor Cyan; Write-Host ' to Github Gist' -ForegroundColor Green
		} catch {Write-Error "Can't connect to gist:`n $($_.Exception.Message)"}
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) DONE]"
	}
} #end Function
$scriptblock = {
	param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
	if ([bool]($PSDefaultParameterValues.Keys -like '*:GitHubUserID')) {(Get-PSPackageManAppList).name }
}
Register-ArgumentCompleter -CommandName Remove-PSPackageManAppFromList -ParameterName ListName -ScriptBlock $scriptblock