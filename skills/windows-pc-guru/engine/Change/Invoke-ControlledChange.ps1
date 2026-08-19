#requires -Version 5.1

<#
.SYNOPSIS
Erzeugt einen kontrollierten Änderungsplan und erzwingt Kompatibilitätsprüfung und explizite Freigabe.

.DESCRIPTION
Produktive Remediations aus dem Katalog sind derzeit ManualGuided und werden
nicht automatisch ausgeführt. Vor jedem produktiven Preview wird der lokale
Kompatibilitätskontext geprüft. Der interne TestHarness beweist den Lifecycle
Backup -> Apply -> Verify -> Rollback ausschließlich im Arbeitsspeicher.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RecipeId,
    [psobject]$CompatibilityContext,
    [switch]$Approve,
    [switch]$TestHarness,
    [switch]$SimulateVerifyFailure,
    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function New-ResultObject {
    param(
        [string]$Status,
        [bool]$Approved,
        [bool]$BackupCreated,
        [bool]$Applied,
        [bool]$Verified,
        [bool]$RolledBack,
        [AllowNull()][object]$Plan,
        [AllowNull()][object]$Backup,
        [AllowNull()][object]$FinalState,
        [AllowNull()][object]$Compatibility
    )

    [pscustomobject][ordered]@{
        SchemaVersion = '2.0'
        NetworkUsed = $false
        FilesChanged = $false
        RecipeId = $RecipeId
        Status = $Status
        Approved = $Approved
        BackupCreated = $BackupCreated
        Applied = $Applied
        Verified = $Verified
        RolledBack = $RolledBack
        Compatibility = $Compatibility
        Plan = $Plan
        Backup = $Backup
        FinalState = $FinalState
    }
}

if ($TestHarness) {
    if ($RecipeId -ne 'internal.test-noop') {
        throw 'Der TestHarness akzeptiert ausschließlich internal.test-noop.'
    }

    $plan = [pscustomobject][ordered]@{
        Id = $RecipeId
        Risk = 'G0'
        Reversibility = 'R1'
        ExecutionMode = 'TestHarness'
        RequiresApproval = $true
        WritesOperatingSystem = $false
    }

    if (-not $Approve) {
        $result = New-ResultObject -Status 'PreviewOnly' -Approved $false -BackupCreated $false -Applied $false -Verified $false -RolledBack $false -Plan $plan -Backup $null -FinalState 'Before' -Compatibility $null
    }
    else {
        $currentState = 'Before'
        $backup = [pscustomobject]@{ OriginalState = $currentState }
        $currentState = 'After'
        $verified = (-not $SimulateVerifyFailure -and $currentState -eq 'After')
        $rolledBack = $false

        if (-not $verified) {
            $currentState = $backup.OriginalState
            $rolledBack = $true
        }

        $status = if ($verified) { 'AppliedAndVerified' } else { 'VerificationFailedRolledBack' }
        $result = New-ResultObject -Status $status -Approved $true -BackupCreated $true -Applied $true -Verified $verified -RolledBack $rolledBack -Plan $plan -Backup $backup -FinalState $currentState -Compatibility $null
    }
}
else {
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

    $recipe = @($catalog.Remediations | Where-Object Id -eq $RecipeId | Select-Object -First 1)
    if ($recipe.Count -ne 1) {
        throw "Unbekannte Remediation-ID: $RecipeId"
    }

    $item = $recipe[0]
    if ($null -eq $CompatibilityContext) {
        $CompatibilityContext = & $contextScript
    }
    $compatibility = & $compatibilityScript -Recipe $item -Context $CompatibilityContext

    if (-not $compatibility.Allowed) {
        $status = if ($compatibility.Status -eq 'Blocked') { 'CompatibilityBlocked' } else { 'CompatibilityReviewRequired' }
        $result = New-ResultObject -Status $status -Approved $false -BackupCreated $false -Applied $false -Verified $false -RolledBack $false -Plan $null -Backup $null -FinalState $null -Compatibility $compatibility
    }
    else {
        $plan = [pscustomobject][ordered]@{
            Id = $item.Id
            Title = $item.Title
            Risk = $item.Risk
            Reversibility = $item.Reversibility
            RequiresAdmin = $item.RequiresAdmin
            RestartRequired = $item.RestartRequired
            ExecutionMode = $item.ExecutionMode
            ExpectedBenefit = $item.ExpectedBenefit
            Validation = $item.Validation
            RequiresApproval = $true
            CompatibilityStatus = $compatibility.Status
        }

        if (-not $Approve) {
            $result = New-ResultObject -Status 'PreviewOnly' -Approved $false -BackupCreated $false -Applied $false -Verified $false -RolledBack $false -Plan $plan -Backup $null -FinalState $null -Compatibility $compatibility
        }
        elseif ($item.ExecutionMode -eq 'ManualGuided') {
            $result = New-ResultObject -Status 'ManualExecutionRequired' -Approved $true -BackupCreated $false -Applied $false -Verified $false -RolledBack $false -Plan $plan -Backup $null -FinalState $null -Compatibility $compatibility
        }
        else {
            throw "Nicht unterstützter ExecutionMode: $($item.ExecutionMode)"
        }
    }
}

if ($AsJson) { $result | ConvertTo-Json -Depth 10 } else { $result }
