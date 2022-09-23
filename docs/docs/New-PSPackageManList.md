---
external help file: PSPackageMan-help.xml
Module Name: PSPackageMan
online version:
schema: 2.0.0
---

# New-PSPackageManList

## SYNOPSIS
Creates a new list file on your GitHub Gist.

## SYNTAX

```
New-PSPackageManList [-ListName] <String> [-Description] <String> [-GitHubUserID] <String>
 [-GitHubToken] <String> [<CommonParameters>]
```

## DESCRIPTION
Creates a new list file on your GitHub Gist.

## EXAMPLES

### EXAMPLE 1
```
New-PSPackageManList -ListName drie -Description "Die derde een" -GitHubUserID $user -GitHubToken $GitHubToken
```

## PARAMETERS

### -ListName
The name of the new list.

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

### -Description
A Short description for the list.

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

### -GitHubUserID
User with access to the gist.

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

### -GitHubToken
The token for that gist.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
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
