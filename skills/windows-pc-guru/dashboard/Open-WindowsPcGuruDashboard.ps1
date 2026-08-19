#requires -Version 5.1

<#
.SYNOPSIS
Erzeugt eine lokale Windows-PC-Guru-Dashboard-Sitzung und öffnet sie im Standardbrowser.

.DESCRIPTION
Erfasst Snapshot 2.0 und Findings lokal, schreibt die Sitzungsdateien ausschließlich
in das Benutzer-TEMP-Verzeichnis und baut daraus eine eigenständige HTML-Datei.
Keine Netzwerkaufrufe und keine Änderung von Windows-Einstellungen.
#>
[CmdletBinding()]
param(
    [switch]$IncludeRecentSystemEvents,
    [ValidateRange(1, 168)]
    [int]$EventHours = 24,
    [switch]$NoOpen
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$dashboardRoot = $PSScriptRoot
$skillRoot = Split-Path -Parent $dashboardRoot
$snapshotScript = Join-Path $skillRoot 'scripts\Get-WindowsPcSnapshot.ps1'
$findingsScript = Join-Path $skillRoot 'engine\Diagnostics\Invoke-DiagnosticRules.ps1'
$indexPath = Join-Path $dashboardRoot 'index.html'
$stylePath = Join-Path $dashboardRoot 'styles.css'
$appPath = Join-Path $dashboardRoot 'app.js'

foreach ($required in @($snapshotScript, $findingsScript, $indexPath, $stylePath, $appPath)) {
    if (-not (Test-Path -LiteralPath $required -PathType Leaf)) {
        throw "Erforderliche Dashboard-Datei fehlt: $required"
    }
}

$sessionRoot = Join-Path $env:TEMP 'WindowsPcGuruDashboard'
if (-not (Test-Path -LiteralPath $sessionRoot -PathType Container)) {
    $null = New-Item -ItemType Directory -Path $sessionRoot
}

$snapshotPath = Join-Path $sessionRoot 'snapshot.json'
$findingsPath = Join-Path $sessionRoot 'findings.json'
$sessionPath = Join-Path $sessionRoot 'dashboard.html'

if ($IncludeRecentSystemEvents) {
    $snapshotJson = (& $snapshotScript -IncludeRecentSystemEvents -EventHours $EventHours -AsJson | Out-String).Trim()
}
else {
    $snapshotJson = (& $snapshotScript -AsJson | Out-String).Trim()
}

$null = $snapshotJson | ConvertFrom-Json
Set-Content -LiteralPath $snapshotPath -Value $snapshotJson -Encoding UTF8

$findingsJson = (& $findingsScript -SnapshotPath $snapshotPath -AsJson | Out-String).Trim()
$null = $findingsJson | ConvertFrom-Json
Set-Content -LiteralPath $findingsPath -Value $findingsJson -Encoding UTF8

$template = Get-Content -Raw -Encoding UTF8 -LiteralPath $indexPath
$styles = Get-Content -Raw -Encoding UTF8 -LiteralPath $stylePath
$app = Get-Content -Raw -Encoding UTF8 -LiteralPath $appPath

$snapshotBase64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($snapshotJson))
$findingsBase64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($findingsJson))

$bootstrap = @"
<script>
(function () {
  function decodeUtf8(base64) {
    var bytes = Uint8Array.from(atob(base64), function (c) { return c.charCodeAt(0); });
    return new TextDecoder('utf-8').decode(bytes);
  }
  function loadIntoInput(inputId, name, base64) {
    var transfer = new DataTransfer();
    transfer.items.add(new File([decodeUtf8(base64)], name, { type: 'application/json' }));
    var input = document.getElementById(inputId);
    input.files = transfer.files;
    input.dispatchEvent(new Event('change', { bubbles: true }));
  }
  loadIntoInput('snapshotInput', 'snapshot.json', '$snapshotBase64');
  loadIntoInput('findingsInput', 'findings.json', '$findingsBase64');
}());
</script>
"@

$sessionHtml = $template.Replace(
    '<link rel="stylesheet" href="styles.css">',
    "<style>`r`n$styles`r`n</style>"
).Replace(
    '<script src="app.js"></script>',
    "<script>`r`n$app`r`n</script>`r`n$bootstrap"
)

Set-Content -LiteralPath $sessionPath -Value $sessionHtml -Encoding UTF8

if (-not $NoOpen) {
    Invoke-Item -LiteralPath $sessionPath
}

[pscustomobject][ordered]@{
    Status = 'DashboardReady'
    DashboardPath = $sessionPath
    SnapshotPath = $snapshotPath
    FindingsPath = $findingsPath
    NetworkUsed = $false
    WindowsSettingsChanged = $false
    TemporaryFilesWritten = $true
}
