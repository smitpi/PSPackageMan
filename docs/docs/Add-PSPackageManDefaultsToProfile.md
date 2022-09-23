---
external help file: PSPackageMan-help.xml
Module Name: PSPackageMan
online version:
schema: 2.0.0
---

# Add-PSPackageManDefaultsToProfile

## SYNOPSIS
Add the parameter to PSDefaultParameters and also your profile.

## SYNTAX

### Public
```
Add-PSPackageManDefaultsToProfile -GitHubUserID <String> [-PublicGist] [-RemoveConfig] [<CommonParameters>]
```

### Private
```
Add-PSPackageManDefaultsToProfile -GitHubUserID <String> [-GitHubToken <String>] [-RemoveConfig]
 [<CommonParameters>]
```

## DESCRIPTION
Add the parameter to PSDefaultParameters and also your profile.

## EXAMPLES

### EXAMPLE 1
```
Add-PSPackageManDefaultsToProfile -GitHubUserID $user -PublicGist
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

### -RemoveConfig
Remove the config from your profile.

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
