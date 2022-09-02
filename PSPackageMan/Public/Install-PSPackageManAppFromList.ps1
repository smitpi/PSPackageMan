
<#PSScriptInfo

.VERSION 0.1.0

.GUID 0eb3c0fe-9d79-402f-92bd-2f0e9ed239e0

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
Created [02/09/2022_19:38] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
  Installs the apps from the GitHub Gist List. 

#> 


<#
.SYNOPSIS
Installs the apps from the GitHub Gist List.

.DESCRIPTION
Installs the apps from the GitHub Gist List.

.PARAMETER ListName
Name of the list.

.PARAMETER GitHubUserID
User with access to the gist.

.PARAMETER PublicGist
Select if the list is hosted publicly.

.PARAMETER GitHubToken
The token for that gist.

.EXAMPLE
Install-PSPackageManAppFromList -ListName twee -GitHubUserID $user -PublicGist

#>
Function Install-PSPackageManAppFromList {
	[Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSPackageMan/Install-PSPackageManAppFromList')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(Mandatory = $true)]
		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[string[]]$ListName,
		[Parameter(Mandatory = $true)]
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

	foreach ($list in $ListName) {
		try {
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) Checking Config File"
			$Content = (Invoke-WebRequest -Uri ($PRGist.files.$($list)).raw_url -Headers $headers).content | ConvertFrom-Json -ErrorAction Stop
		} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}

		[System.Collections.Generic.List[PSCustomObject]]$AppObject = @()
		$Content.Apps | ForEach-Object {[void]$AppObject.Add($_)}

		foreach ($app in $Content.Apps) {
			[int]$maxlength = ($content.Apps.name | Measure-Object -Property length -Maximum).Maximum
			[int]$maxPackageManagerlength = ($content.Apps.PackageManager | Measure-Object -Property length -Maximum).Maximum + ($content.Apps.Source | Measure-Object -Property length -Maximum).Maximum + 3
			Remove-Variable CheckInstalled -ErrorAction SilentlyContinue
			if ($app.PackageManager -like 'Winget') {			
				Write-Host '[Installing]' -NoNewline -ForegroundColor Yellow
				Write-Host (" {0,-$($maxPackageManagerlength)}" -f "[$($app.PackageManager)]:$($app.Source)") -ForegroundColor DarkGray -NoNewline
				Write-Host (" {0,$($maxlength)}:" -f $($app.Name) ) -ForegroundColor Cyan -NoNewline

				$CheckInstalled = Invoke-Expression -Command 'winget list' | Where-Object { $_ -match $app.id }
				if ([string]::IsNullOrEmpty($CheckInstalled)) {
					$Command = "winget install --accept-source-agreements --accept-package-agreements --silent --id $($app.id) --source $($app.Source)" 
					$null = Invoke-Expression -Command $Command | Where-Object { $_ }
					if ($LASTEXITCODE -ne 0) {Write-Host ('{0} ' -f ' Failed') -ForegroundColor Red}
					if ($LASTEXITCODE -eq 0) {Write-Host ('{0} ' -f ' Completed') -ForegroundColor Green}
				} else {
					Write-Host ('{0} ' -f ' Already Installed') -ForegroundColor Yellow -NoNewline
					$CheckUpgrade = Invoke-Expression -Command "winget upgrade --accept-source-agreements --accept-package-agreements --silent --id $($app.id) --source $($app.Source)"
					if ($CheckUpgrade -like 'No applicable update found.') {Write-Host ('{0} ' -f ' No Upgrade') -ForegroundColor DarkCyan}
					else {Write-Host ('{0} ' -f ' Upgrade Complete') -ForegroundColor DarkGreen}
				}
			} elseif ($app.PackageManager -like 'Chocolatey') {
				Write-Host '[Installing]' -NoNewline -ForegroundColor Yellow
				Write-Host (" {0,-$($maxPackageManagerlength)}" -f "[$($app.PackageManager)]:$($app.Source)") -ForegroundColor DarkGray -NoNewline
				Write-Host (" {0,$($maxlength)}:" -f $($app.Name) ) -ForegroundColor Cyan -NoNewline

				$CheckInstalled = (choco list --local-only --limit-output $app.Name) -split '\|'
				$CheckOnline = (choco search $app.name --limit-output) -split '\|'
				if ([string]::IsNullOrEmpty($CheckInstalled)) {			
					choco upgrade $($app.name) --source $($app.Source) --accept-license --limit-output -y | Out-Null
					if ($LASTEXITCODE -ne 0) {Write-Host ('{0} ' -f ' Failed') -ForegroundColor Red}
					if ($LASTEXITCODE -eq 0) {Write-Host ('{0} ' -f ' Completed') -ForegroundColor Green}
				} else {
					Write-Host ('{0} ' -f ' Already Installed') -ForegroundColor Yellow -NoNewline
					if ([version]$CheckOnline[-1] -gt [version]$CheckInstalled[-1]) {
						choco upgrade $($app.name) --source $($app.Source) --accept-license --limit-output -y | Out-Null
						Write-Host ('{0} ' -f ' Upgrade Complete') -ForegroundColor DarkGreen
					} else {Write-Host ('{0} ' -f ' No Upgrade') -ForegroundColor DarkCyan}
				}
			}
		}
	}
} #end Function
$scriptblock = {
	param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
	if ([bool]($PSDefaultParameterValues.Keys -like '*:GitHubUserID')) {(Show-PSPackageManAppList).name | Where-Object {$_ -like "*$wordToComplete*"}}
}
Register-ArgumentCompleter -CommandName Install-PSPackageManAppFromList -ParameterName ListName -ScriptBlock $scriptblock