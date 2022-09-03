---
external help file: PSPackageMan-help.xml
Module Name: PSPackageMan
online version:
schema: 2.0.0
---

# Get-PSPackageManAppList

## SYNOPSIS
Show a List of all the GitHub Gist app Lists.

## SYNTAX

### Public
```
Get-PSPackageManAppList -GitHubUserID <String> [-PublicGist] [<CommonParameters>]
```

### Private
```
Get-PSPackageManAppList -GitHubUserID <String> [-GitHubToken <String>] [<CommonParameters>]
```

## DESCRIPTION
Show a List of all the GitHub Gist app Lists.

## EXAMPLES

### EXAMPLE 1
```
Get-PSPackageManAppList -GitHubUserID $user -PublicGist
```

## PARAMETERS

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
