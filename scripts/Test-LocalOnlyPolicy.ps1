#requires -Version 5.1
<#
.SYNOPSIS
Prueft die enthaltenen Diagnose- und Engine-Skripte auf typische Netzwerk-, Download-,
Fernsteuerungs- und Loeschbefehle.

.DESCRIPTION
Die Pruefung liest nur den lokalen Quelltext der Laufzeitskripte. Sie stellt keine
Netzwerkverbindung her und veraendert keine Dateien.
#>
[CmdletBinding()]
param(
    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$skillRoot = Join-Path $repositoryRoot 'skills\windows-pc-guru'
$runtimeDirectories = @(
    (Join-Path $skillRoot 'scripts'),
    (Join-Path $skillRoot 'engine')
)
$patterns = @(
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
    'Clear-RecycleBin'
)

$runtimeScripts = @()
foreach ($runtimeDirectory in $runtimeDirectories) {
    if (Test-Path -LiteralPath $runtimeDirectory -PathType Container) {
        $runtimeScripts += @(Get-ChildItem -LiteralPath $runtimeDirectory -Filter '*.ps1' -File -Recurse)
    }
}

$findings = @()
foreach ($runtimeScript in $runtimeScripts) {
    $scriptText = Get-Content -Raw -Encoding UTF8 -LiteralPath $runtimeScript.FullName
    foreach ($pattern in $patterns) {
        if ($scriptText -match [regex]::Escape($pattern)) {
            $findings += [pscustomobject]@{
                Script = $runtimeScript.FullName.Substring($repositoryRoot.Length).TrimStart('\')
                Pattern = $pattern
            }
        }
    }
}

$result = [pscustomobject][ordered]@{
    SchemaVersion = '1.1'
    NetworkUsed = $false
    FilesChanged = $false
    ScriptsChecked = $runtimeScripts.Count
    Allowed = ($findings.Count -eq 0)
    Findings = $findings
    Notice = 'Statische Pruefung: Sie erkennt typische Muster, aber keinen absichtlich verschleierten Schadcode.'
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 4
} else {
    $result
}
