
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

.PARAMETER LocalList
Select if the list is saved locally.

.PARAMETER Path
Directory where files are saved.

.EXAMPLE
Install-PSPackageManAppFromList -ListName twee -GitHubUserID $user -PublicGist

#>
Function Install-PSPackageManAppFromList {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSPackageMan/Install-PSPackageManAppFromList')]
	PARAM(
		[Parameter(Mandatory)]
		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[string[]]$ListName,
		[Parameter(Mandatory, ParameterSetName = 'Public')]
		[Parameter(Mandatory, ParameterSetName = 'Private')]
		[string]$GitHubUserID,
		[Parameter(ParameterSetName = 'Public')]
		[switch]$PublicGist,
		[Parameter(ParameterSetName = 'Private')]
		[string]$GitHubToken,
		[Parameter(ParameterSetName = 'local')]
		[switch]$LocalList,
		[Parameter(ParameterSetName = 'local')]
		[System.IO.DirectoryInfo]$Path
	)

	if ($GitHubUserID) {
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
	}
	[System.Collections.Generic.List[PSCustomObject]]$AppObject = @()
	foreach ($list in $ListName) {
		try {
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) Checking Config File"
			if ($LocalList) {
				$ListPath = Join-Path $Path -ChildPath "$($list).json"
				if (Test-Path $ListPath) { 
					Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Collecting Content"
					$Content = Get-Content $ListPath | ConvertFrom-Json
				} else {Write-Warning "List file $($List) does not exist"}
			} else {
				Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Collecting Content"
				$Content = (Invoke-WebRequest -Uri ($PRGist.files.$($List)).raw_url -Headers $headers).content | ConvertFrom-Json -ErrorAction Stop
			}
			$Content.Apps | Where-Object {$_ -notlike $null} | ForEach-Object {
				if ($AppObject.Exists({ -not (Compare-Object $args[0].psobject.properties.value $_.psobject.Properties.value) })) {
					Write-Color 'Duplicate Found', " ListName: $($list)", " Name: $($_.name)" -Color Gray, DarkYellow, DarkCyan
				} else {$AppObject.Add($_)}
			}
		} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
	}


	foreach ($app in $AppObject) {
		[int]$maxlength = ($AppObject.name | Measure-Object -Property length -Maximum).Maximum
		[int]$maxPackageManagerlength = ($AppObject.PackageManager | Measure-Object -Property length -Maximum).Maximum + ($AppObject.Source | Measure-Object -Property length -Maximum).Maximum + 3
		Remove-Variable CheckInstalled -ErrorAction SilentlyContinue
		$CheckWingetPackageMan = Get-Command winget.exe -ErrorAction SilentlyContinue
		$CheckChocoPackageMan = Get-Command choco.exe -ErrorAction SilentlyContinue
		if ($app.PackageManager -like 'Winget' -and $CheckWingetPackageMan) {
			try {
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
			} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
		} elseif ($app.PackageManager -like 'Chocolatey' -and $CheckChocoPackageMan) {
			try {
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
			} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
		} else {
			if (-not($CheckWingetPackageMan)) {Write-Error 'Winget is not installed.'}
			if (-not($CheckChocoPackageMan)) {Write-Error 'Chocolatey is not installed.'}
		}
	}
} #end Function
$scriptblock = {
	param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
	if ([bool]($PSDefaultParameterValues.Keys -like '*:GitHubUserID')) {(Get-PSPackageManAppList).name }
}
Register-ArgumentCompleter -CommandName Install-PSPackageManAppFromList -ParameterName ListName -ScriptBlock $scriptblock