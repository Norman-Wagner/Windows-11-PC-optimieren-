#requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string[]]$FindingId,
    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$catalogPath = Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) 'remediations\catalog.json'
if (-not (Test-Path -LiteralPath $catalogPath -PathType Leaf)) {
    throw "Remediation-Katalog nicht gefunden: $catalogPath"
}

$catalog = Get-Content -Raw -Encoding UTF8 -LiteralPath $catalogPath | ConvertFrom-Json
if ($catalog.SchemaVersion -ne '1.0') {
    throw 'Unerwartete Remediation-Katalogversion.'
}

$options = @($catalog.Remediations | Where-Object {
    $recipe = $_
    @($FindingId | Where-Object { $_ -in @($recipe.FindingIds) }).Count -gt 0
})

$result = [pscustomobject][ordered]@{
    SchemaVersion = '1.0'
    NetworkUsed = $false
    FilesChanged = $false
    FindingIds = @($FindingId)
    OptionCount = $options.Count
    Options = $options
}

if ($AsJson) { $result | ConvertTo-Json -Depth 8 } else { $result }
