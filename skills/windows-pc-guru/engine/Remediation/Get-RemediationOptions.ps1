#requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string[]]$FindingId,
    [psobject]$CompatibilityContext,
    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$skillRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$catalogPath = Join-Path $skillRoot 'remediations\catalog.json'
$contextScript = Join-Path $skillRoot 'engine\Compatibility\Get-RemediationCompatibilityContext.ps1'
$compatibilityScript = Join-Path $skillRoot 'engine\Compatibility\Test-RemediationCompatibility.ps1'

if (-not (Test-Path -LiteralPath $catalogPath -PathType Leaf)) {
    throw "Remediation-Katalog nicht gefunden: $catalogPath"
}

$catalog = Get-Content -Raw -Encoding UTF8 -LiteralPath $catalogPath | ConvertFrom-Json
if ($catalog.SchemaVersion -ne '2.0') {
    throw 'Unerwartete Remediation-Katalogversion.'
}

if ($null -eq $CompatibilityContext) {
    $CompatibilityContext = & $contextScript
}

$matching = @($catalog.Remediations | Where-Object {
    $recipe = $_
    @($FindingId | Where-Object { $_ -in @($recipe.FindingIds) }).Count -gt 0
})

$options = foreach ($recipe in $matching) {
    $compatibility = & $compatibilityScript -Recipe $recipe -Context $CompatibilityContext
    [pscustomobject][ordered]@{
        Id = $recipe.Id
        FindingIds = @($recipe.FindingIds)
        Title = $recipe.Title
        Risk = $recipe.Risk
        Reversibility = $recipe.Reversibility
        RequiresAdmin = $recipe.RequiresAdmin
        RestartRequired = $recipe.RestartRequired
        ExecutionMode = $recipe.ExecutionMode
        ExpectedBenefit = $recipe.ExpectedBenefit
        Validation = $recipe.Validation
        Compatibility = $recipe.Compatibility
        CompatibilityResult = $compatibility
    }
}

$result = [pscustomobject][ordered]@{
    SchemaVersion = '2.0'
    NetworkUsed = $false
    FilesChanged = $false
    FindingIds = @($FindingId)
    OptionCount = @($options).Count
    CompatibleOptionCount = @($options | Where-Object { $_.CompatibilityResult.Allowed }).Count
    Options = @($options)
}

if ($AsJson) { $result | ConvertTo-Json -Depth 10 } else { $result }
