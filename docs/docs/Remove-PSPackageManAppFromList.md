---
external help file: PSPackageMan-help.xml
Module Name: PSPackageMan
online version:
schema: 2.0.0
---

# Remove-PSPackageManAppFromList

## SYNOPSIS
Remove an app from one or more of the predefined GitHub Gist Lists.

## SYNTAX

```
Remove-PSPackageManAppFromList [-ListName] <String> [-GitHubUserID] <String> [-GitHubToken] <String>
 [<CommonParameters>]
```

## DESCRIPTION
Remove an app from one or more of the predefined GitHub Gist Lists.

## EXAMPLES

### EXAMPLE 1
```
Remove-PSPackageManAppFromList -ListName twee,drie -Name speedtest -GitHubUserID $user -GitHubToken $GitHubToken
```

## PARAMETERS

### -ListName
Name of the list.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
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
Position: 2
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
Position: 3
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
