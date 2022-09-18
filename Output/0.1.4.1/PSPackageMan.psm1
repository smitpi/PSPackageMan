#region Public Functions
#region Add-PSPackageManAppToList.ps1
######## Function 1 of 11 ##################
# Function:         Add-PSPackageManAppToList
# Module:           PSPackageMan
# ModuleVersion:    0.1.4.1
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/09/02 19:34:01
# ModifiedOn:       2022/09/18 19:49:53
# Synopsis:         Add an app to one more of the predefined GitHub Gist Lists.
#############################################
 
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
	Get-PSPackageManAppList | ForEach-Object {$_.Name} | Where-Object {$_ -like "*$wordToComplete*"}
}
Register-ArgumentCompleter -CommandName Add-PSPackageManAppToList -ParameterName ListName -ScriptBlock $scriptblock
Register-ArgumentCompleter -CommandName Add-PSPackageManAppToList -ParameterName ChocoSource -ScriptBlock {choco source --limit-output | ForEach-Object {$_.split('|')[0]}}
 
Export-ModuleMember -Function Add-PSPackageManAppToList
#endregion
 
#region Add-PSPackageManDefaultsToProfile.ps1
######## Function 2 of 11 ##################
# Function:         Add-PSPackageManDefaultsToProfile
# Module:           PSPackageMan
# ModuleVersion:    0.1.4.1
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/09/02 19:43:27
# ModifiedOn:       2022/09/02 21:27:58
# Synopsis:         Add the parameter to PSDefaultParameters and also your profile.
#############################################
 
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
		$PSDefaultParameterValues.Add('*PSPackageMan*:GitHubUserID',"$($GitHubUserID)")
		$PSDefaultParameterValues.Add('*PSPackageMan*:PublicGist',$true)

		$ToAppend = @"

#region PSPackageMan Defaults
`$PSDefaultParameterValues['*PSPackageMan*:GitHubUserID'] = "$($GitHubUserID)"
`$PSDefaultParameterValues['*PSPackageMan*:PublicGist'] = `$true
#endregion PSPackageMan

"@
	} else {
		$PSDefaultParameterValues.Add('*PSPackageMan*:GitHubUserID',"$($GitHubUserID)")
		$PSDefaultParameterValues.Add('*PSPackageMan*:GitHubToken',"$($GitHubToken)")
		
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
 
Export-ModuleMember -Function Add-PSPackageManDefaultsToProfile
#endregion
 
#region Get-PSPackageManAppList.ps1
######## Function 3 of 11 ##################
# Function:         Get-PSPackageManAppList
# Module:           PSPackageMan
# ModuleVersion:    0.1.4.1
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/09/02 19:24:07
# ModifiedOn:       2022/09/18 18:23:09
# Synopsis:         Show a List of all the GitHub Gist app Lists.
#############################################
 
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
 
Export-ModuleMember -Function Get-PSPackageManAppList
#endregion
 
#region Get-PSPackageManInstalledApp.ps1
######## Function 4 of 11 ##################
# Function:         Get-PSPackageManInstalledApp
# Module:           PSPackageMan
# ModuleVersion:    0.1.4.1
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/09/02 19:58:36
# ModifiedOn:       2022/09/10 03:41:27
# Synopsis:         This will display a list of installed apps, and their details in the repositories.
#############################################
 
<#
.SYNOPSIS
This will display a list of installed apps, and their details in the repositories.

.DESCRIPTION
This will display a list of installed apps, and their details in the repositories.

.PARAMETER PackageManager
Which package manager to query installed apps with.

.PARAMETER Export
Export the result to a report file. (Excel or html). Or select Host to display the object on screen.

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Get-PSPackageManInstalledApp -PackageManager AllManagers -Export HTML -ReportPath C:\temp

#>
Function Get-PSPackageManInstalledApp {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSPackageMan/Get-PSPackageManInstalledApp')]
	[OutputType([System.Object[]])]
	PARAM(
		[ValidateSet('Chocolatey', 'Winget', 'AllManagers')]
		[string]$PackageManager,
							
		[ValidateSet('Excel', 'HTML', 'Host')]
		[string]$Export = 'Host',

		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
	)

	function getwinget {
		Write-Host '[Collecting]' -ForegroundColor Yellow -NoNewline
		Write-Host ' Winget Apps List' -ForegroundColor Gray 
		try {
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) BEGIN] Starting Winget extract"
			Invoke-Expression -Command "winget export -o $($env:tmp)\winget-extract.json --accept-source-agreements" | Out-Null
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Winget config import"
			$importlist = Get-Content "$($env:tmp)\winget-extract.json" | ConvertFrom-Json
			$FinalList = $importlist.Sources.Packages | ForEach-Object {
				Write-Host "`t[Searching]" -ForegroundColor Yellow -NoNewline
				Write-Host " AppID: $($_.PackageIdentifier)" -ForegroundColor Gray 
				Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] AppID: $($_.PackageIdentifier)"		
				Search-PSPackageManApp -SearchString $_.PackageIdentifier -PackageManager Winget -Exact
			}
			$FinalList
		} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
	}
	function getchoco {
		Write-Host '[Collecting]' -ForegroundColor Yellow -NoNewline
		Write-Host ' Chocolatey Apps List' -ForegroundColor Gray 
		try {
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) BEGIN] Starting Choco extract"
			$allapps = choco list --local-only --limit-output
			$finallist = foreach ($app in $allapps) {
				$appdetail = $app -split '\|'
				Write-Host "`t[Searching]" -ForegroundColor Yellow -NoNewline
				Write-Host " AppID: $($appdetail[0])" -ForegroundColor Gray 
				Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] AppID: $($appdetail[0])"
				Search-PSPackageManApp -SearchString $appdetail[0] -PackageManager Chocolatey -Exact
			}
			$FinalList
		} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
	}

	if ($PackageManager -like 'Winget') { $Winget = getwinget}
	if ($PackageManager -like 'Chocolatey') { $Choco = getchoco}
	if ($PackageManager -like 'AllManagers') {
		$Winget = getwinget
		$Choco = getchoco
	}

	if ($Export -eq 'Excel') { 
		$ExcelOptions = @{
			Path             = $(Join-Path -Path $ReportPath -ChildPath "\InstalledApplist-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
			AutoSize         = $True
			AutoFilter       = $True
			TitleBold        = $True
			TitleSize        = '28'
			TitleFillPattern = 'LightTrellis'
			TableStyle       = 'Light20'
			FreezeTopRow     = $True
			FreezePane       = '3'
		}
		if ($winget) {$winget | Export-Excel -Title 'Winget Installed App list' -WorksheetName Winget @ExcelOptions}
		if ($Choco) {$Choco | Export-Excel -Title 'Choco Installed App list' -WorksheetName Choco @ExcelOptions}
	}
	if ($Export -eq 'HTML') { 
		$script:TableSettings = @{
			Style           = 'cell-border'
			TextWhenNoData  = 'No Data to display here'
			Buttons         = 'searchBuilder', 'pdfHtml5', 'excelHtml5'
			FixedHeader     = $true
			HideFooter      = $true
			SearchHighlight = $true
			PagingStyle     = 'full'
			PagingLength    = 10
		}
		$script:SectionSettings = @{
			BackgroundColor       = 'grey'
			CanCollapse           = $true
			HeaderBackGroundColor = '#2b1200'
			HeaderTextAlignment   = 'center'
			HeaderTextColor       = '#f37000'
			HeaderTextSize        = '15'
			BorderRadius          = '20px'
		}
		$script:TableSectionSettings = @{
			BackgroundColor       = 'white'
			CanCollapse           = $true
			HeaderBackGroundColor = '#f37000'
			HeaderTextAlignment   = 'center'
			HeaderTextColor       = '#2b1200'
			HeaderTextSize        = '15'
		}
		$script:TabSettings = @{
			TextTransform = 'uppercase'
			IconBrands    = 'mix'
			TextSize      = '16' 
			TextColor     = '#00203F'
			IconSize      = '16'
			IconColor     = '#00203F'
		}

		$ReportTitle = 'Installed Apps List'
		$HeadingText = "$($ReportTitle) [$(Get-Date -Format dd) $(Get-Date -Format MMMM) $(Get-Date -Format yyyy) $(Get-Date -Format HH:mm)]"
		New-HTML -TitleText $($ReportTitle) -FilePath $(Join-Path -Path $ReportPath -ChildPath "\InstalledApplist-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") {
			New-HTMLHeader {
				New-HTMLText -FontSize 20 -FontStyle normal -Color '#00203F' -Alignment left -Text $HeadingText
			}
			if ($winget) { New-HTMLTab -Name 'Winget Installed App list' @TabSettings -HtmlData {New-HTMLSection @TableSectionSettings { New-HTMLTable -DataTable $($winget) @TableSettings}}}
			if ($Choco) { New-HTMLTab -Name 'Choco Installed App list' @TabSettings -HtmlData {New-HTMLSection @TableSectionSettings { New-HTMLTable -DataTable $($Choco) @TableSettings}}}
		}
	}
	if ($Export -eq 'Host') { 
		if ($PackageManager -like 'Winget') { return $Winget}
		if ($PackageManager -like 'Chocolatey') { return $Choco}
		if ($PackageManager -like 'AllManagers') {
			return [PSCustomObject]@{
				Winget     = $Winget
				Chocolatey = $Choco
			}
		}
	}
	Write-Verbose "[$(Get-Date -Format HH:mm:ss) Complete]"
} #end Function
 
Export-ModuleMember -Function Get-PSPackageManInstalledApp
#endregion
 
#region Install-PSPackageManAppFromList.ps1
######## Function 5 of 11 ##################
# Function:         Install-PSPackageManAppFromList
# Module:           PSPackageMan
# ModuleVersion:    0.1.4.1
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/09/02 19:38:36
# ModifiedOn:       2022/09/18 19:49:53
# Synopsis:         Installs the apps from the GitHub Gist List.
#############################################
 
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

				$CheckInstalled = Invoke-Expression -Command 'winget list --accept-source-agreements' | Where-Object { $_ -match $app.id }
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
	Get-PSPackageManAppList | ForEach-Object {$_.Name} | Where-Object {$_ -like "*$wordToComplete*"}
}
Register-ArgumentCompleter -CommandName Install-PSPackageManAppFromList -ParameterName ListName -ScriptBlock $scriptblock
 
Export-ModuleMember -Function Install-PSPackageManAppFromList
#endregion
 
#region New-PSPackageManList.ps1
######## Function 6 of 11 ##################
# Function:         New-PSPackageManList
# Module:           PSPackageMan
# ModuleVersion:    0.1.4.1
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/09/02 19:51:19
# ModifiedOn:       2022/09/02 20:05:19
# Synopsis:         Creates a new list file on your GitHub Gist.
#############################################
 
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
 
Export-ModuleMember -Function New-PSPackageManList
#endregion
 
#region Remove-PSPackageManAppFromList.ps1
######## Function 7 of 11 ##################
# Function:         Remove-PSPackageManAppFromList
# Module:           PSPackageMan
# ModuleVersion:    0.1.4.1
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/09/02 19:54:14
# ModifiedOn:       2022/09/18 19:50:25
# Synopsis:         Remove an app from one or more of the predefined GitHub Gist Lists.
#############################################
 
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
	Get-PSPackageManAppList | ForEach-Object {$_.Name} | Where-Object {$_ -like "*$wordToComplete*"}
}
Register-ArgumentCompleter -CommandName Remove-PSPackageManAppFromList -ParameterName ListName -ScriptBlock $scriptblock
 
Export-ModuleMember -Function Remove-PSPackageManAppFromList
#endregion
 
#region Remove-PSPackageManList.ps1
######## Function 8 of 11 ##################
# Function:         Remove-PSPackageManList
# Module:           PSPackageMan
# ModuleVersion:    0.1.4.1
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/09/02 19:47:58
# ModifiedOn:       2022/09/18 19:49:53
# Synopsis:         Deletes a list from your GitHub Gist.
#############################################
 
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
	Get-PSPackageManAppList | ForEach-Object {$_.Name} | Where-Object {$_ -like "*$wordToComplete*"}
}
Register-ArgumentCompleter -CommandName Remove-PSPackageManList -ParameterName ListName -ScriptBlock $scriptblock
 
Export-ModuleMember -Function Remove-PSPackageManList
#endregion
 
#region Save-PSPackageManList.ps1
######## Function 9 of 11 ##################
# Function:         Save-PSPackageManList
# Module:           PSPackageMan
# ModuleVersion:    0.1.4.1
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/09/07 17:36:46
# ModifiedOn:       2022/09/18 19:49:53
# Synopsis:         Saves the Gist List to the local machine
#############################################
 
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
	Get-PSPackageManAppList | ForEach-Object {$_.Name} | Where-Object {$_ -like "*$wordToComplete*"}
}
Register-ArgumentCompleter -CommandName Save-PSPackageManList -ParameterName ListName -ScriptBlock $scriptblock
 
Export-ModuleMember -Function Save-PSPackageManList
#endregion
 
#region Search-PSPackageManApp.ps1
######## Function 10 of 11 ##################
# Function:         Search-PSPackageManApp
# Module:           PSPackageMan
# ModuleVersion:    0.1.4.1
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/09/02 19:30:25
# ModifiedOn:       2022/09/03 08:45:23
# Synopsis:         Will search the winget and chocolatey repositories for apps
#############################################
 
<#
.SYNOPSIS
Will search the winget and chocolatey repositories for apps

.DESCRIPTION
Will search the winget and chocolatey repositories for apps

.PARAMETER SearchString
What app to search for.

.PARAMETER PackageManager
Which app manager to use (Chocolatey or winget)

.PARAMETER ChocoSource
Chocolatey source, if a personal repository is used.

.PARAMETER Exact
Limits the search to the exact search string.

.PARAMETER ShowAppDetail
Show more detail about a selected app.

.EXAMPLE
Search-PSPackageManApp -SearchString office -PackageManager Winget

#>
Function Search-PSPackageManApp {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSPackageMan/Search-PSPackageManApp')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
		[ValidateNotNullOrEmpty()]
		[Alias('Id', 'Name', 'PackageIdentifier')]
		[string[]]$SearchString,
		[Parameter(Mandatory, ValueFromPipelineByPropertyName)]
		[ValidateSet('Chocolatey', 'Winget', 'AllManagers')]
		[string]$PackageManager,
		[string]$ChocoSource,
		[switch]$Exact,
		[switch]$ShowAppDetail
	)
	begin {
		function AppDetails {
			PARAM ($AppObject)

			Write-Color 'Please pick from below for' -Color Gray -LinesBefore 2 -LinesAfter 1
			$index = 0
			$AppObject | ForEach-Object {
				Write-Color "$($index)) ", "$($_.name)", " [$($_.version)]", " $($_.source)" -Color Yellow, Green, Cyan, Gray
				$index++ 
			}
			Write-Host ''
			[int]$AskApp = Read-Host 'Index Number for App Details'
			if ($AppObject[$AskApp].PackageManager -like 'Chocolatey') {
				[System.Collections.Generic.List[pscustomobject]]$Result = @()
				choco info $($AppObject[$AskApp].Name) --source $($AppObject[$AskApp].Source) | Where-Object { $result.add($_) }
				$ID = choco search $($AppObject[$AskApp].Name) --source $($AppObject[$AskApp].Source) --Exact --limit-output
				$descb = $Result.IndexOf(($Result | Where-Object {$_ -like '*Description:*'}))
				[PSCustomObject]@{
					Name        = $ID.split('|')[0]
					Version     = $ID.split('|')[1]
					Published   = ($Result | Where-Object {$_ -like '*Published:*'}).split('|')[1].replace('Published: ', $null).trim()
					Downloads   = ($Result | Where-Object {$_ -like '*Downloads:*'}).split('|')[0].replace('Number of Downloads: ', $null).trim()
					Summary     = ($Result | Where-Object {$_ -like '*Summary:*'}).replace('Summary: ', $null).trim()
					Description = (($Result[$descb..($Result.count - 2)]).replace('Description: ', $null) | Out-String).trim()
				}
			}
			if ($AppObject[$AskApp].PackageManager -like 'Winget') {
				Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESSES] starting winget search"
				$Command = "winget show --accept-source-agreements  `"$($AppObject[$AskApp].id)`""
				[System.Collections.Generic.List[pscustomobject]]$Result = @()
				Invoke-Expression -Command $Command | Where-Object { $result.add($_) }
				$descb = $Result.IndexOf(($Result | Where-Object {$_ -like 'Description:*'}))
				$desce = $Result.IndexOf(($Result | Where-Object {$_ -like 'License:*'}))
				[PSCustomObject]@{
					Name        = ($Result | Where-Object {$_ -like 'Found*'}).replace('Found ', $null)
					Version     = $Result | Where-Object {$_ -like 'Version:*'}
					Publisher   = $Result | Where-Object {$_ -like 'Publisher:*'}
					License     = $Result | Where-Object {$_ -like 'License:*'}
					Category    = $Result | Where-Object {$_ -like 'Category:*'}
					Pricing     = $Result | Where-Object {$_ -like 'Pricing:*'}
					Description = (($Result[$descb..($desce - 1)]).replace('Description:', $null) | Out-String).trim()
				}
			}
		}
		function chocosearch {
			PARAM($SearchString, $ChocoSource, $Exact)

			if (Get-Command choco.exe -ErrorAction SilentlyContinue) {
				try {
					Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESSES] Starting Choco search"
					[System.Collections.Generic.List[pscustomobject]]$ChocoObject = @()
					$source = 'chocolatey'
					$command = "choco search $($SearchString) --limit-output --order-by-popularity"
					if ($ChocoSource) {
						$source = $ChocoSource
						$command = $command + " --source $($ChocoSource)"
					} 
					if ($Exact) {
						$command = $command + ' --Exact'
					}
					$allapps = Invoke-Expression -Command $command
					Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESSES] Building choco output"
					foreach ($app in $allapps) {
						$appdetail = $app -split '\|'
						$ChocoObject.add([pscustomobject]@{
								Name           = $appdetail[0]
								Id             = $appdetail[0]
								version        = $appdetail[1]
								PackageManager = 'Chocolatey'
								source         = $Source
							})
					}
					Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESSES] Choco done"
					if ($ShowAppDetail) {AppDetails $ChocoObject}
					else {$ChocoObject}
				} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
			} else {Write-Warning "Chocolatey is not installed.`nInstall it from https://chocolatey.org/install "}
		}
		function wingetsearch {
			PARAM($SearchString, $DetailedResults, $Exact)
			if (Get-Command winget.exe -ErrorAction SilentlyContinue) {
				try {
					Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESSES] starting winget search"
					$Command = "winget search --accept-source-agreements  `"$($SearchString)`""
					if ($Exact) {$Command = $Command + ' --Exact'}
					[System.Collections.Generic.List[pscustomobject]]$Result = @()
					Invoke-Expression -Command $Command | Where-Object { $result.add($_) }
					if ($LASTEXITCODE -ne 0) {Write-Warning "Error searching Code: $($LASTEXITCODE)"}
					elseif ($Result -match 'No Package') {Write-Warning 'No package found matching input criteria.'}
					else {
						Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESSES] Building winget output"
						[System.Collections.Generic.List[pscustomobject]]$WingetObject = @()
						$begin = ($Result.IndexOf($Result -match '---') + 1)
						$end = $Result.count
						foreach ($line in ($Result[$($begin)..$($end)])) {
							if ($line -like '*Tag*' -or $line -like '*Moniker*') {
								$splited = $line.split(' ') | Where-Object {$_ -notlike $null}
								$WingetObject.add([pscustomobject]@{
										Name           = ($splited[0..($splited.count - 4)] -join ' ')
										id             = $splited[-5]
										version        = $splited[-4]
										PackageManager = 'Winget'
										source         = $splited[-1]
									})
							} else {
								$splited = $line.split(' ') | Where-Object {$_ -notlike $null}
								$WingetObject.add([pscustomobject]@{
										Name           = ($splited[0..($splited.count - 4)] -join ' ')
										id             = $splited[-3]
										version        = $splited[-2]
										PackageManager = 'Winget'
										source         = $splited[-1]
									})
							}
						}
						Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESSES] Winget done."
						if ($ShowAppDetail) {AppDetails $WingetObject}
						else {$WingetObject}					
     }
				} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
			} else {Write-Warning "Winget is not installed.`nInstall it from https://docs.microsoft.com/en-us/windows/package-manager/winget/ "}
		}
	}
	process {
		foreach ($search in $SearchString) {
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESSES] Starting search $($search)"
			if ($PackageManager -like 'AllManagers') {
				[PSCustomObject]@{
					Chocolatey = chocosearch -SearchString $search -ChocoSource $ChocoSource -Exact $Exact
					Winget     = wingetsearch -SearchString $search -DetailedResults $DetailedResults
				}
			}
			if ($PackageManager -like 'Chocolatey') {
				chocosearch -SearchString $search -ChocoSource $ChocoSource -Exact $Exact
			}
			if ($PackageManager -like 'Winget') {
				if (Get-Command winget -ErrorAction SilentlyContinue) {
					wingetsearch -SearchString $search -DetailedResults $DetailedResults -Exact $Exact
				} else {Write-Error 'Winget is not installed. Please install and retry the search.'}
			}
		}
		Write-Verbose "[$(Get-Date -Format HH:mm:ss) DONE]"
	}
	end {}
} #end Function

Register-ArgumentCompleter -CommandName Search-PSPackageManApp -ParameterName ChocoSource -ScriptBlock {choco source --limit-output | ForEach-Object {$_.split('|')[0]}}
Register-ArgumentCompleter -CommandName Search-PSPackageManApp -ParameterName WingetSource -ScriptBlock {(winget source list) -match 'http' -split '\s+' -notmatch 'http'}
 
Export-ModuleMember -Function Search-PSPackageManApp
#endregion
 
#region Show-PSPackageManApp.ps1
######## Function 11 of 11 ##################
# Function:         Show-PSPackageManApp
# Module:           PSPackageMan
# ModuleVersion:    0.1.4.1
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/09/02 19:26:44
# ModifiedOn:       2022/09/18 19:49:53
# Synopsis:         Show an app to one of the predefined GitHub Gist Lists.
#############################################
 
<#
.SYNOPSIS
Show an app to one of the predefined GitHub Gist Lists.

.DESCRIPTION
Show an app to one of the predefined GitHub Gist Lists.

.PARAMETER ListName
Name of the list.

.PARAMETER ShowAppDetail
Show more detail about a selected app.

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
		[string[]]$ListName,
		[switch]$ShowAppDetail,
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

	[System.Collections.Generic.List[PSCustomObject]]$AppObject = @()
	$index = 0
	foreach ($List in $ListName) {
		try {
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) Checking Config File"
			$Content = (Invoke-WebRequest -Uri ($PRGist.files.$($List)).raw_url -Headers $headers).content | ConvertFrom-Json -ErrorAction Stop
		} catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}

		$Content.Apps | ForEach-Object {
			$AppObject.Add([PSCustomObject]@{
					Index          = $index
					ListName       = $List
					Name           = $_.Name
					ID             = $_.id
					PackageManager = $_.PackageManager
					Source         = $_.Source
				})
			$index++
		}
	}
	if ($ShowAppDetail) {
		$AppObject | Format-Table -AutoSize -Wrap

		[int]$AskApp = Read-Host 'Index Number for App Details'
		if ($AppObject[$AskApp].PackageManager -like 'Chocolatey') {
			[System.Collections.Generic.List[pscustomobject]]$Result = @()
			choco info $($AppObject[$AskApp].Name) --source $($AppObject[$AskApp].Source) | Where-Object { $result.add($_) }
			$ID = choco search $($AppObject[$AskApp].Name) --source $($AppObject[$AskApp].Source) --Exact --limit-output
			$descb = $Result.IndexOf(($Result | Where-Object {$_ -like '*Description:*'}))
			[PSCustomObject]@{
				Name        = $ID.split('|')[0]
				Version     = $ID.split('|')[1]
				Published   = ($Result | Where-Object {$_ -like '*Published:*'}).split('|')[1].replace('Published: ', $null).trim()
				Downloads   = ($Result | Where-Object {$_ -like '*Downloads:*'}).split('|')[0].replace('Number of Downloads: ', $null).trim()
				Summary     = ($Result | Where-Object {$_ -like '*Summary:*'}).replace('Summary: ', $null).trim()
				Description = (($Result[$descb..($Result.count - 2)]).replace('Description: ', $null) | Out-String).trim()
			}
		}
		if ($AppObject[$AskApp].PackageManager -like 'Winget') {
			Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESSES] starting winget search"
			$Command = "winget show --accept-source-agreements  `"$($AppObject[$AskApp].id)`""
			[System.Collections.Generic.List[pscustomobject]]$Result = @()
			Invoke-Expression -Command $Command | Where-Object { $result.add($_) }
			$descb = $Result.IndexOf(($Result | Where-Object {$_ -like 'Description:*'}))
			$desce = $Result.IndexOf(($Result | Where-Object {$_ -like 'License:*'}))
			[PSCustomObject]@{
				Name        = ($Result | Where-Object {$_ -like 'Found*'}).replace('Found ', $null)
				Version     = $Result | Where-Object {$_ -like 'Version:*'}
				Publisher   = $Result | Where-Object {$_ -like 'Publisher:*'}
				License     = $Result | Where-Object {$_ -like 'License:*'}
				Category    = $Result | Where-Object {$_ -like 'Category:*'}
				Pricing     = $Result | Where-Object {$_ -like 'Pricing:*'}
				Description = (($Result[$descb..($desce - 1)]).replace('Description:', $null) | Out-String).trim()
			}
		}
	} else {$AppObject}

} #end Function
$scriptblock = {
	param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
	Get-PSPackageManAppList | ForEach-Object {$_.Name} | Where-Object {$_ -like "*$wordToComplete*"}
}
Register-ArgumentCompleter -CommandName Show-PSPackageManApp -ParameterName ListName -ScriptBlock $scriptblock
 
Export-ModuleMember -Function Show-PSPackageManApp
#endregion
 
#endregion
 
