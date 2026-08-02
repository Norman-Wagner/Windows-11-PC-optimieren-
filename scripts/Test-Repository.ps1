#requires -Version 5.1

[CmdletBinding()]
param(
    [switch]$RunDiagnosticsSmokeTest
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$skillRoot = Join-Path $repositoryRoot 'skills\windows-pc-guru'
$skillFile = Join-Path $skillRoot 'SKILL.md'

function Assert-True {
    param(
        [Parameter(Mandatory = $true)]
        [bool]$Condition,

        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

$requiredPaths = @(
    'README.md',
    'LICENSE.txt',
    'NOTICE.txt',
    '.codex-plugin\plugin.json',
    '.claude-plugin\plugin.json',
    '.github\agents\windows-pc-guru.agent.md',
    'skills\windows-pc-guru\SKILL.md',
    'skills\windows-pc-guru\agents\openai.yaml',
    'skills\windows-pc-guru\references\safety-and-consent.md',
    'skills\windows-pc-guru\references\symptom-triage.md',
    'skills\windows-pc-guru\references\windows-repair.md',
    'skills\windows-pc-guru\references\drivers-and-software.md',
    'skills\windows-pc-guru\references\programming-and-automation.md',
    'skills\windows-pc-guru\references\privacy-and-sensitive-data.md',
    'skills\windows-pc-guru\references\official-sources.md',
    'skills\windows-pc-guru\references\optimization-decision-matrix.md',
    'skills\windows-pc-guru\references\software-catalog.md',
    'skills\windows-pc-guru\references\advanced-diagnostics.md',
    'skills\windows-pc-guru\references\security-baseline-audit.md',
    'skills\windows-pc-guru\profiles\office.md',
    'skills\windows-pc-guru\profiles\development.md',
    'skills\windows-pc-guru\profiles\laptop.md',
    'skills\windows-pc-guru\profiles\gaming.md',
    'skills\windows-pc-guru\scripts\Get-WindowsPcSnapshot.ps1',
    'skills\windows-pc-guru\scripts\Test-DriverPackage.ps1',
    'skills\windows-pc-guru\assets\diagnosebericht-vorlage.md',
    'skills\windows-pc-guru\assets\aenderungsplan-vorlage.md',
    'scripts\Build-SkillPackage.ps1',
    'tests\behavior-cases.md'
)

foreach ($relativePath in $requiredPaths) {
    $absolutePath = Join-Path $repositoryRoot $relativePath
    Assert-True -Condition (Test-Path -LiteralPath $absolutePath) `
        -Message "Erforderliche Datei fehlt: $relativePath"
}

$skillText = Get-Content -Raw -Encoding UTF8 -LiteralPath $skillFile
$frontmatterMatch = [regex]::Match(
    $skillText,
    '(?s)\A---\r?\nname:\s*([^\r\n]+)\r?\ndescription:\s*([^\r\n]+)\r?\n---'
)

Assert-True -Condition $frontmatterMatch.Success `
    -Message 'SKILL.md hat kein gültiges, minimales YAML-Frontmatter.'

$skillName = $frontmatterMatch.Groups[1].Value.Trim()
$description = $frontmatterMatch.Groups[2].Value.Trim()

Assert-True -Condition ($skillName -eq 'windows-pc-guru') `
    -Message "Unerwarteter Skillname: $skillName"
Assert-True -Condition ($skillName -match '^[a-z0-9]+(?:-[a-z0-9]+)*$') `
    -Message 'Der Skillname ist nicht standardkonform.'
Assert-True -Condition ($skillName.Length -le 64) `
    -Message 'Der Skillname ist länger als 64 Zeichen.'
Assert-True -Condition ($description.Length -ge 80 -and $description.Length -le 1024) `
    -Message 'Die Skillbeschreibung muss 80 bis 1024 Zeichen lang sein.'
Assert-True -Condition ($skillText -notmatch '(?i)\[?TODO|PLACEHOLDER') `
    -Message 'SKILL.md enthält noch einen Platzhalter.'

$markdownLinks = [regex]::Matches($skillText, '\]\(([^)#]+\.md)(?:#[^)]+)?\)')
foreach ($link in $markdownLinks) {
    $target = Join-Path $skillRoot $link.Groups[1].Value
    Assert-True -Condition (Test-Path -LiteralPath $target) `
        -Message "Defekter relativer Link in SKILL.md: $($link.Groups[1].Value)"
}

$markdownFiles = Get-ChildItem -Path $repositoryRoot -Recurse -File `
    -Filter '*.md'
foreach ($markdownFile in $markdownFiles) {
    $markdownText = Get-Content -Raw -Encoding UTF8 `
        -LiteralPath $markdownFile.FullName
    $relativeLinks = [regex]::Matches(
        $markdownText,
        '\]\((?!https?://|mailto:|#)([^)#]+)(?:#[^)]+)?\)'
    )

    foreach ($relativeLink in $relativeLinks) {
        $decodedTarget = [uri]::UnescapeDataString(
            $relativeLink.Groups[1].Value.Trim('<', '>')
        )
        $targetPath = Join-Path $markdownFile.DirectoryName $decodedTarget
        Assert-True -Condition (Test-Path -LiteralPath $targetPath) `
            -Message "Defekter relativer Link in $($markdownFile.FullName): $decodedTarget"
    }
}

$openAiYamlPath = Join-Path $skillRoot 'agents\openai.yaml'
$openAiYaml = Get-Content -Raw -Encoding UTF8 -LiteralPath $openAiYamlPath
Assert-True -Condition ($openAiYaml -match 'display_name:\s*"Windows-PC-Guru"') `
    -Message 'agents/openai.yaml enthält keinen passenden display_name.'
Assert-True -Condition ($openAiYaml -match '\$windows-pc-guru') `
    -Message 'Der OpenAI-Standardprompt erwähnt den Skill nicht explizit.'

$jsonFiles = @(
    (Join-Path $repositoryRoot '.codex-plugin\plugin.json'),
    (Join-Path $repositoryRoot '.claude-plugin\plugin.json')
)

foreach ($jsonFile in $jsonFiles) {
    $null = Get-Content -Raw -Encoding UTF8 -LiteralPath $jsonFile |
        ConvertFrom-Json
}

$powerShellFiles = Get-ChildItem -Path $repositoryRoot -Recurse -File `
    -Filter '*.ps1'
foreach ($powerShellFile in $powerShellFiles) {
    $tokens = $null
    $parseErrors = $null
    $null = [System.Management.Automation.Language.Parser]::ParseFile(
        $powerShellFile.FullName,
        [ref]$tokens,
        [ref]$parseErrors
    )

    Assert-True -Condition ($parseErrors.Count -eq 0) `
        -Message "PowerShell-Syntaxfehler in $($powerShellFile.FullName): $($parseErrors -join '; ')"
}

$runtimeScripts = Get-ChildItem -Path (Join-Path $skillRoot 'scripts') -File `
    -Filter '*.ps1'
$forbiddenRuntimePatterns = @(
    'Invoke-Expression',
    'Invoke-WebRequest',
    'Invoke-RestMethod',
    'Start-BitsTransfer',
    'System.Net.WebClient',
    'System.Net.Http.HttpClient',
    'curl.exe',
    'wget.exe',
    'ftp.exe',
    'Start-Process',
    'Enter-PSSession',
    'New-PSSession',
    'Remove-Item',
    'Set-MpPreference',
    'Disable-WindowsOptionalFeature'
)

foreach ($runtimeScript in $runtimeScripts) {
    $runtimeText = Get-Content -Raw -Encoding UTF8 -LiteralPath $runtimeScript.FullName
    foreach ($pattern in $forbiddenRuntimePatterns) {
        Assert-True -Condition ($runtimeText -notmatch [regex]::Escape($pattern)) `
            -Message "Verbotenes Laufzeitmuster '$pattern' in $($runtimeScript.Name)."
    }
}

if ($RunDiagnosticsSmokeTest) {
    $snapshotScript = Join-Path $skillRoot 'scripts\Get-WindowsPcSnapshot.ps1'
    $snapshot = & $snapshotScript -AsJson | ConvertFrom-Json
    Assert-True -Condition ($snapshot.SchemaVersion -eq '1.0') `
        -Message 'Der Diagnose-Smoke-Test lieferte ein unerwartetes Schema.'
    Assert-True -Condition ($snapshot.PrivacyNotice -match 'Keine Benutzer') `
        -Message 'Der Diagnose-Smoke-Test enthält keinen Datenschutzhinweis.'
    Assert-True -Condition (-not $snapshot.NetworkUsed) `
        -Message 'Der Diagnose-Snapshot meldet unerwarteten Netzwerkzugriff.'

    $baselineScript = Join-Path $skillRoot 'scripts\Measure-OptimizationBaseline.ps1'
    $baseline = & $baselineScript -AsJson | ConvertFrom-Json
    Assert-True -Condition ($baseline.SchemaVersion -eq '1.0') `
        -Message 'Die Leistungs-Baseline lieferte ein unerwartetes Schema.'
    Assert-True -Condition ($baseline.PrivacyNotice -match 'Keine Benutzer') `
        -Message 'Die Leistungs-Baseline enthält keinen Datenschutzhinweis.'
    Assert-True -Condition (-not $baseline.NetworkUsed) `
        -Message 'Die Leistungs-Baseline meldet unerwarteten Netzwerkzugriff.'

    $localOnlyPolicy = & (Join-Path $repositoryRoot 'scripts\\Test-LocalOnlyPolicy.ps1') -AsJson | ConvertFrom-Json
    Assert-True -Condition $localOnlyPolicy.Allowed `
        -Message 'Die Lokal-only-Pruefung hat ein verbotenes Laufzeitmuster gefunden.'
    Assert-True -Condition (-not $localOnlyPolicy.NetworkUsed) `
        -Message 'Die Lokal-only-Pruefung meldet unerwarteten Netzwerkzugriff.'

    $driverScript = Join-Path $skillRoot 'scripts\Test-DriverPackage.ps1'
    $driverResult = & $driverScript -LiteralPath $driverScript -AsJson |
        ConvertFrom-Json
    Assert-True -Condition ($driverResult.SHA256 -match '^[A-F0-9]{64}$') `
        -Message 'Die Paketprüfung lieferte keinen gültigen SHA-256-Wert.'
    Assert-True -Condition (-not $driverResult.NetworkUsed) `
        -Message 'Die Paketprüfung meldet unerwarteten Netzwerkzugriff.'
    Assert-True -Condition (-not $driverResult.InstalledAnything) `
        -Message 'Die Paketprüfung meldet eine unerwartete Installation.'
}

Write-Host 'Repository-Validierung erfolgreich.'
