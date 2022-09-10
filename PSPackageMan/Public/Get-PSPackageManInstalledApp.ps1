
<#PSScriptInfo

.VERSION 0.1.0

.GUID 913bbbc5-5bea-4049-97df-1f8b80a9a8c9

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
Created [02/09/2022_19:58] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

#

<# 

.DESCRIPTION 
 This will display a list of installed apps, and their details in the repositories. 

#> 


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
