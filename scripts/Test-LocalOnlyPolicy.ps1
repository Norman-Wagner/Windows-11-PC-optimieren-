#requires -Version 5.1
<#
.SYNOPSIS
Prueft die enthaltenen Diagnose-Skripte auf typische Netzwerk-, Download-,
Fernsteuerungs- und Loeschbefehle.

.DESCRIPTION
Die Pruefung liest nur den lokalen Quelltext der Skripte. Sie stellt keine
Netzwerkverbindung her und veraendert keine Dateien.
#>
[CmdletBinding()]
param(
    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$runtimeDirectory = Join-Path $repositoryRoot 'skills\windows-pc-guru\scripts'
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

$findings = @()
Get-ChildItem -LiteralPath $runtimeDirectory -Filter '*.ps1' -File |
    ForEach-Object {
        $scriptText = Get-Content -Raw -Encoding UTF8 -LiteralPath $_.FullName
        foreach ($pattern in $patterns) {
            if ($scriptText -match [regex]::Escape($pattern)) {
                $findings += [pscustomobject]@{
                    Script = $_.Name
                    Pattern = $pattern
                }
            }
        }
    }

$result = [pscustomobject][ordered]@{
    SchemaVersion = '1.0'
    NetworkUsed = $false
    FilesChanged = $false
    ScriptsChecked = @(Get-ChildItem -LiteralPath $runtimeDirectory -Filter '*.ps1' -File).Count
    Allowed = ($findings.Count -eq 0)
    Findings = $findings
    Notice = 'Statische Pruefung: Sie erkennt typische Muster, aber keinen absichtlich verschleierten Schadcode.'
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 4
} else {
    $result
}
