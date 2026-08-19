#requires -Version 5.1

<#
.SYNOPSIS
Prueft, ob eine Remediation mit dem lokalen Windows-Kontext vereinbar ist.
#>
[CmdletBinding(DefaultParameterSetName = 'Object')]
param(
    [Parameter(Mandatory = $true)]
    [psobject]$Recipe,
    [Parameter(Mandatory = $true, ParameterSetName = 'Object')]
    [psobject]$Context,
    [Parameter(Mandatory = $true, ParameterSetName = 'Path')]
    [string]$ContextPath,
    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($PSCmdlet.ParameterSetName -eq 'Path') {
    if (-not (Test-Path -LiteralPath $ContextPath -PathType Leaf)) {
        throw "Kompatibilitaetskontext nicht gefunden: $ContextPath"
    }
    $Context = Get-Content -Raw -Encoding UTF8 -LiteralPath $ContextPath | ConvertFrom-Json
}

if ($Context.SchemaVersion -ne '1.0') {
    throw 'Unerwartete Kontextversion.'
}

$compatibility = $Recipe.Compatibility
if ($null -eq $compatibility) {
    throw "Remediation $($Recipe.Id) enthaelt keine Compatibility-Metadaten."
}

$blockReasons = @()
$reviewReasons = @()

if (@($compatibility.OsFamilies).Count -gt 0 -and $Context.OperatingSystem.Family -notin @($compatibility.OsFamilies)) {
    if ($Context.OperatingSystem.Family -eq 'Unknown') {
        $reviewReasons += 'Betriebssystemfamilie konnte nicht sicher bestimmt werden.'
    }
    else {
        $blockReasons += "Betriebssystemfamilie '$($Context.OperatingSystem.Family)' ist nicht unterstuetzt."
    }
}

if (@($compatibility.Editions).Count -gt 0 -and $Context.OperatingSystem.Edition -notin @($compatibility.Editions)) {
    if ($Context.OperatingSystem.Edition -eq 'Unknown') {
        $reviewReasons += 'Windows-Edition konnte nicht sicher bestimmt werden.'
    }
    else {
        $blockReasons += "Windows-Edition '$($Context.OperatingSystem.Edition)' ist nicht unterstuetzt."
    }
}

if (@($compatibility.Architectures).Count -gt 0 -and $Context.OperatingSystem.Architecture -notin @($compatibility.Architectures)) {
    if ($Context.OperatingSystem.Architecture -eq 'Unknown') {
        $reviewReasons += 'Architektur konnte nicht sicher bestimmt werden.'
    }
    else {
        $blockReasons += "Architektur '$($Context.OperatingSystem.Architecture)' ist nicht unterstuetzt."
    }
}

if (@($compatibility.DeviceTypes).Count -gt 0 -and $Context.DeviceType -notin @($compatibility.DeviceTypes)) {
    if ($Context.DeviceType -eq 'Unknown') {
        $reviewReasons += 'Geraetetyp konnte nicht sicher bestimmt werden.'
    }
    else {
        $blockReasons += "Geraetetyp '$($Context.DeviceType)' ist nicht unterstuetzt."
    }
}

if ($null -ne $compatibility.MinBuild) {
    if ($null -eq $Context.OperatingSystem.BuildNumber) {
        $reviewReasons += 'Windows-Build konnte nicht sicher bestimmt werden.'
    }
    elseif ([int]$Context.OperatingSystem.BuildNumber -lt [int]$compatibility.MinBuild) {
        $blockReasons += "Windows-Build $($Context.OperatingSystem.BuildNumber) liegt unter MinBuild $($compatibility.MinBuild)."
    }
}

if ($null -ne $compatibility.MaxBuild) {
    if ($null -eq $Context.OperatingSystem.BuildNumber) {
        $reviewReasons += 'Windows-Build konnte nicht sicher bestimmt werden.'
    }
    elseif ([int]$Context.OperatingSystem.BuildNumber -gt [int]$compatibility.MaxBuild) {
        $blockReasons += "Windows-Build $($Context.OperatingSystem.BuildNumber) liegt ueber MaxBuild $($compatibility.MaxBuild)."
    }
}

$missingCapabilities = @()
foreach ($capability in @($compatibility.RequiredCapabilities)) {
    if ($capability -notin @($Context.Capabilities)) {
        $missingCapabilities += $capability
    }
}
if ($missingCapabilities.Count -gt 0) {
    $blockReasons += "Erforderliche lokale Faehigkeiten fehlen: $($missingCapabilities -join ', ')."
}

$status = 'Compatible'
$allowed = $true
if ($blockReasons.Count -gt 0) {
    $status = 'Blocked'
    $allowed = $false
}
elseif ($reviewReasons.Count -gt 0) {
    $status = 'ReviewRequired'
    $allowed = $false
}

$result = [pscustomobject][ordered]@{
    SchemaVersion = '1.0'
    RecipeId = $Recipe.Id
    Status = $status
    Allowed = $allowed
    BlockReasons = @($blockReasons)
    ReviewReasons = @($reviewReasons)
    ContextSchemaVersion = $Context.SchemaVersion
    NetworkUsed = $false
    FilesChanged = $false
}

if ($AsJson) { $result | ConvertTo-Json -Depth 6 } else { $result }
