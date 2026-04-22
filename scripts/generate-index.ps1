$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$templatesDir = Join-Path $repoRoot "templates"
$jobTitlesPath = Join-Path $repoRoot "jobTitle.json"
$outputPath = Join-Path $repoRoot "index.json"

if (-not (Test-Path -LiteralPath $templatesDir)) {
    throw "Templates directory not found: $templatesDir"
}
if (-not (Test-Path -LiteralPath $jobTitlesPath)) {
    throw "Job title dictionary not found: $jobTitlesPath"
}

$templateFiles = Get-ChildItem -LiteralPath $templatesDir -Filter "*.role.json" | Sort-Object Name
$jobTitles = Get-Content -LiteralPath $jobTitlesPath -Raw | ConvertFrom-Json -Depth 100
$jobTitleMap = @{}
foreach ($entry in @($jobTitles)) {
    if ($null -ne $entry -and $null -ne $entry.aliases) {
        $key = [string]$entry.key
        $en = [string]$entry.aliases.en
        if (-not [string]::IsNullOrWhiteSpace($key) -and -not [string]::IsNullOrWhiteSpace($en)) {
            $jobTitleMap[$key] = $en
        }
    }
}

$templates = foreach ($file in $templateFiles) {
    $template = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json -Depth 100

    $styleValues = @()
    if ($null -ne $template.soul) {
        if ($template.soul.style -is [string]) {
            $styleValues = @([string]$template.soul.style)
        } else {
            $styleValues = @($template.soul.style)
        }
    }

    $avatar = $null
    if ($null -ne $template.avatar -and -not [string]::IsNullOrWhiteSpace($template.avatar)) {
        $avatarStr = [string]$template.avatar
        if ($avatarStr -notmatch '^data:') {
            $avatar = $avatarStr
        }
    }

    [PSCustomObject]@{
        file = $file.Name
        id = $template.id
        name = $template.name
        avatar = $avatar
        job = $template.job
        jobTitleKey = $template.job
        jobTitle = $(if ($jobTitleMap.ContainsKey([string]$template.job)) { $jobTitleMap[[string]$template.job] } else { $null })
        description = $template.description
        model = $template.model
        source = $template.source
        isBuiltin = $template.isBuiltin
        isActive = $template.isActive
        mcpCount = @($template.mcps).Count
        skillCount = @($template.skills).Count
        mcpKeys = @($template.mcps | ForEach-Object { $_.key } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        skillKeys = @($template.skills | ForEach-Object { $_.key } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        soul = [PSCustomObject]@{
            traits = @($template.soul.traits)
            attitudes = @($template.soul.attitudes)
            style = $styleValues
            custom = $template.soul.custom
        }
    }
}

$index = [PSCustomObject]@{
    schema = "openstaff.template-index.v1"
    generatedAtUtc = (Get-Date).ToUniversalTime().ToString("o")
    templateCount = @($templates).Count
    templates = @($templates)
}

$json = $index | ConvertTo-Json -Depth 100
Set-Content -LiteralPath $outputPath -Value $json -Encoding utf8NoBOM

Write-Host "Generated index: $outputPath (templates: $($index.templateCount))"
