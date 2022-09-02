---
external help file: PSPackageMan-help.xml
Module Name: PSPackageMan
online version:
schema: 2.0.0
---

# Search-PSPackageManApp

## SYNOPSIS
Will search the winget and chocolatey repositories for apps

## SYNTAX

### Set1 (Default)
```
Search-PSPackageManApp -SearchString <String[]> -PackageManager <String> [<CommonParameters>]
```

### MoreOptions
```
Search-PSPackageManApp -SearchString <String[]> -PackageManager <String> [-MoreOptions] [-ChocoSource <String>]
 [-Exact] [<CommonParameters>]
```

## DESCRIPTION
Will search the winget and chocolatey repositories for apps

## EXAMPLES

### EXAMPLE 1
```
Search-PSPackageManApp -SearchString office -PackageManager Winget
```

## PARAMETERS

### -SearchString
What app to search for.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Id, Name, PackageIdentifier

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

### -MoreOptions
Select for more search options.

```yaml
Type: SwitchParameter
Parameter Sets: MoreOptions
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
Parameter Sets: MoreOptions
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
Parameter Sets: MoreOptions
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
