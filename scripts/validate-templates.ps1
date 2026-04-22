$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$templatesDir = Join-Path $repoRoot "templates"
$jobTitlesPath = Join-Path $repoRoot "jobTitle.json"
$requiredLocales = @("en", "zh", "ja", "fr", "es", "de")
$errors = New-Object System.Collections.Generic.List[string]

function Add-ValidationError {
    param([string]$message)
    $script:errors.Add($message)
}

function Read-JsonFile {
    param([string]$path)

    if (-not (Test-Path -LiteralPath $path)) {
        Add-ValidationError "Missing file: $path"
        return $null
    }

    try {
        return Get-Content -LiteralPath $path -Raw | ConvertFrom-Json -Depth 100
    } catch {
        Add-ValidationError "Invalid JSON in file: $path. $($_.Exception.Message)"
        return $null
    }
}

function Get-JobTitleKeySet {
    param([string]$path)

    $set = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $entriesRaw = Read-JsonFile -path $path
    if ($null -eq $entriesRaw) {
        return $set
    }

    $entries = @($entriesRaw)
    if ($entries.Count -eq 0) {
        Add-ValidationError "jobTitle.json must not be empty."
        return $set
    }

    $keys = New-Object System.Collections.Generic.List[string]
    foreach ($entry in $entries) {
        if ($null -eq $entry) {
            Add-ValidationError "jobTitle.json contains a null item."
            continue
        }

        $props = @($entry.PSObject.Properties.Name)
        if (-not ($props -contains "key")) {
            Add-ValidationError "jobTitle.json contains an item without 'key'."
            continue
        }
        if (-not ($props -contains "aliases")) {
            Add-ValidationError "jobTitle.json item '$($entry.key)' is missing 'aliases'."
            continue
        }

        $key = [string]$entry.key
        if ([string]::IsNullOrWhiteSpace($key)) {
            Add-ValidationError "jobTitle.json contains an empty key."
            continue
        }
        $keys.Add($key)

        if ($null -eq $entry.aliases) {
            Add-ValidationError "jobTitle.json item '$key' has null aliases."
            continue
        }

        $aliasProps = @($entry.aliases.PSObject.Properties.Name)
        foreach ($locale in $requiredLocales) {
            if (-not ($aliasProps -contains $locale)) {
                Add-ValidationError "jobTitle.json item '$key' is missing locale '$locale'."
                continue
            }
            $label = [string]$entry.aliases.$locale
            if ([string]::IsNullOrWhiteSpace($label)) {
                Add-ValidationError "jobTitle.json item '$key' has empty alias for locale '$locale'."
            }
        }
        if (-not $set.Add($key)) {
            Add-ValidationError "jobTitle.json has duplicate key '$key'."
        }
    }

    $sortedKeys = @($keys | Sort-Object)
    if ([string]::Join("|", $keys) -ne [string]::Join("|", $sortedKeys)) {
        Add-ValidationError "jobTitle.json must be sorted by key."
    }

    return $set
}

function Validate-SoulKeys {
    param(
        [string]$fileName,
        [pscustomobject]$soul,
        [string]$fieldName
    )

    if ($null -eq $soul) {
        Add-ValidationError "'$fileName' is missing 'soul'."
        return
    }

    $value = $soul.$fieldName
    if ($null -eq $value) {
        Add-ValidationError "'$fileName' soul is missing '$fieldName'."
        return
    }

    $values = @()
    if ($value -is [string]) {
        if ($fieldName -eq "style") {
            $values = @([string]$value)
        } else {
            Add-ValidationError "'$fileName' soul.$fieldName must be an array of keys."
            return
        }
    } else {
        $values = @($value)
    }

    $duplicates = $values | Group-Object | Where-Object { $_.Count -gt 1 } | Select-Object -ExpandProperty Name
    foreach ($duplicate in $duplicates) {
        Add-ValidationError "'$fileName' soul.$fieldName contains duplicate key '$duplicate'."
    }

    foreach ($key in $values) {
        $stringKey = [string]$key
        if ([string]::IsNullOrWhiteSpace($stringKey)) {
            Add-ValidationError "'$fileName' soul.$fieldName contains empty key."
        }
    }
}

$validJobTitles = Get-JobTitleKeySet -path $jobTitlesPath

if (-not (Test-Path -LiteralPath $templatesDir)) {
    Add-ValidationError "Missing templates directory: $templatesDir"
} else {
    $templateFiles = Get-ChildItem -LiteralPath $templatesDir -Filter "*.role.json" | Sort-Object Name

    if ($templateFiles.Count -eq 0) {
        Add-ValidationError "No template files found in $templatesDir"
    }

    $requiredFields = @(
        "schema",
        "id",
        "name",
        "job",
        "description",
        "avatar",
        "model",
        "modelConfig",
        "source",
        "isBuiltin",
        "isActive",
        "soul",
        "mcps",
        "skills"
    )

    foreach ($templateFile in $templateFiles) {
        $template = Read-JsonFile -path $templateFile.FullName
        if ($null -eq $template) {
            continue
        }

        $fileName = $templateFile.Name
        $templateProperties = @($template.PSObject.Properties.Name)

        foreach ($field in $requiredFields) {
            if (-not ($templateProperties -contains $field)) {
                Add-ValidationError "'$fileName' is missing required field '$field'."
            }
        }

        if ($template.schema -ne "openstaff.role-sync.v2") {
            Add-ValidationError "'$fileName' has unsupported schema '$($template.schema)'."
        }

        $parsedGuid = [guid]::Empty
        $idValue = [string]$template.id
        if (-not [guid]::TryParse($idValue, [ref]$parsedGuid)) {
            Add-ValidationError "'$fileName' has invalid GUID id '$idValue'."
        }

        if ([string]::IsNullOrWhiteSpace([string]$template.job)) {
            Add-ValidationError "'$fileName' has empty job."
        } elseif ($validJobTitles.Count -gt 0 -and -not $validJobTitles.Contains([string]$template.job)) {
            Add-ValidationError "'$fileName' job '$($template.job)' is not defined in jobTitle.json key."
        }

        if ($template.description -isnot [string]) {
            Add-ValidationError "'$fileName' field 'description' must be a string."
        }

        if ($template.source -notin @("builtin", "custom")) {
            Add-ValidationError "'$fileName' has invalid source '$($template.source)'. Expected 'builtin' or 'custom'."
        }

        if ($template.isBuiltin -isnot [bool]) {
            Add-ValidationError "'$fileName' field 'isBuiltin' must be boolean."
        }

        if ($template.isActive -isnot [bool]) {
            Add-ValidationError "'$fileName' field 'isActive' must be boolean."
        }

        $modelConfigRaw = $template.modelConfig
        if ([string]::IsNullOrWhiteSpace([string]$modelConfigRaw)) {
            Add-ValidationError "'$fileName' has empty modelConfig."
        } else {
            try {
                if ($modelConfigRaw -is [string]) {
                    $null = $modelConfigRaw | ConvertFrom-Json -Depth 100
                } else {
                    $null = $modelConfigRaw | ConvertTo-Json -Depth 100 | ConvertFrom-Json -Depth 100
                }
            } catch {
                Add-ValidationError "'$fileName' contains invalid modelConfig JSON."
            }
        }

        Validate-SoulKeys -fileName $fileName -soul $template.soul -fieldName "traits"
        Validate-SoulKeys -fileName $fileName -soul $template.soul -fieldName "attitudes"
        Validate-SoulKeys -fileName $fileName -soul $template.soul -fieldName "style"

        if ($null -ne $template.soul -and $template.soul.custom -ne $null -and $template.soul.custom -isnot [string]) {
            Add-ValidationError "'$fileName' soul.custom must be null or string."
        }

        foreach ($listField in @("mcps", "skills")) {
            $items = $template.$listField
            if ($null -eq $items) {
                Add-ValidationError "'$fileName' field '$listField' must be an array."
                continue
            }
            if ($items -is [string]) {
                Add-ValidationError "'$fileName' field '$listField' must be an array, not a string."
                continue
            }

            foreach ($item in @($items)) {
                if ($null -eq $item) {
                    Add-ValidationError "'$fileName' field '$listField' contains a null item."
                    continue
                }
                $itemProperties = @($item.PSObject.Properties.Name)
                if (-not ($itemProperties -contains "key")) {
                    Add-ValidationError "'$fileName' field '$listField' contains an item without 'key'."
                    continue
                }
                if ([string]::IsNullOrWhiteSpace([string]$item.key)) {
                    Add-ValidationError "'$fileName' field '$listField' contains an empty key."
                }
            }
        }
    }
}

if ($errors.Count -gt 0) {
    foreach ($errorItem in $errors) {
        Write-Host "ERROR: $errorItem" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "Template validation failed with $($errors.Count) error(s)." -ForegroundColor Red
    exit 1
}

$templateCount = (Get-ChildItem -LiteralPath $templatesDir -Filter "*.role.json").Count
Write-Host "Template validation passed for $templateCount template(s)." -ForegroundColor Green
