---
external help file: PSPackageMan-help.xml
Module Name: PSPackageMan
online version:
schema: 2.0.0
---

# Add-PSPackageManAppToList

## SYNOPSIS
Add an app to one more of the predefined GitHub Gist Lists.

## SYNTAX

```
Add-PSPackageManAppToList -ListName <String[]> -SearchString <String[]> -PackageManager <String>
 -GitHubUserID <String> -GitHubToken <String> [-MoreOptions] [-ChocoSource <String>] [-Exact]
 [<CommonParameters>]
```

## DESCRIPTION
Add an app to one more of the predefined GitHub Gist Lists.

## EXAMPLES

### EXAMPLE 1
```
Add-PSPackageManAppToList -ListName twee -Name speedtest -PackageManager Winget -GitHubUserID $User -GitHubToken $GitHubToken
```

## PARAMETERS

### -ListName
Name of the list.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchString
Application name to search for.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Id, PackageIdentifier, Name

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -PackageManager
Which app manager to use (Chocolatey or winget)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -GitHubUserID
User with access to the gist.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GitHubToken
The token for that gist.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MoreOptions
Select for more search options.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ChocoSource
Chocolatey source

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Exact
Limits the search to the exact search string.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object[]
## NOTES

## RELATED LINKS
