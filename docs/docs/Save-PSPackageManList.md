---
external help file: PSPackageMan-help.xml
Module Name: PSPackageMan
online version:
schema: 2.0.0
---

# Save-PSPackageManList

## SYNOPSIS
Saves the Gist List to the local machine

## SYNTAX

### Public
```
Save-PSPackageManList -ListName <String[]> -Path <DirectoryInfo> -GitHubUserID <String> [-PublicGist]
 [<CommonParameters>]
```

### Private
```
Save-PSPackageManList -ListName <String[]> -Path <DirectoryInfo> -GitHubUserID <String> [-GitHubToken <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Saves the Gist List to the local machine

## EXAMPLES

### EXAMPLE 1
```
Save-PSPackageManList -ListName BaseApps,een,twee -Path C:\temp
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

### -Path
Directory where files will be saved.

```yaml
Type: DirectoryInfo
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

## NOTES

## RELATED LINKS
