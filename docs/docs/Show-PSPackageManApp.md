---
external help file: PSPackageMan-help.xml
Module Name: PSPackageMan
online version:
schema: 2.0.0
---

# Show-PSPackageManApp

## SYNOPSIS
Show an app to one of the predefined GitHub Gist Lists.

## SYNTAX

### Public
```
Show-PSPackageManApp -ListName <String[]> -GitHubUserID <String> [-PublicGist] [<CommonParameters>]
```

### Private
```
Show-PSPackageManApp -ListName <String[]> -GitHubUserID <String> [-GitHubToken <String>] [<CommonParameters>]
```

## DESCRIPTION
Show an app to one of the predefined GitHub Gist Lists.

## EXAMPLES

### EXAMPLE 1
```
Show-PSPackageManApp -ListName twee -GitHubUserID $user -PublicGist
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

### -PublicGist
Select if the list is hosted publicly.

```yaml
Type: SwitchParameter
Parameter Sets: Public
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -GitHubToken
The token for that gist.

```yaml
Type: String
Parameter Sets: Private
Aliases:

Required: False
Position: Named
Default value: None
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
