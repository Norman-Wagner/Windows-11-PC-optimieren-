#requires -Version 5.1

<#
.SYNOPSIS
Erzeugt einen kontrollierten Änderungsplan und erzwingt explizite Freigabe.

.DESCRIPTION
Produktive Remediations aus dem Katalog sind derzeit ManualGuided und werden
nicht automatisch ausgeführt. Der interne TestHarness beweist den Lifecycle
Backup -> Apply -> Verify -> Rollback ausschließlich im Arbeitsspeicher.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RecipeId,
    [switch]$Approve,
    [switch]$TestHarness,
    [switch]$SimulateVerifyFailure,
    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function New-Result {
    param(
        [string]$Status,
        [bool]$Approved,
        [bool]$BackupCreated,
        [bool]$Applied,
        [bool]$Verified,
        [bool]$RolledBack,
        [AllowNull()][object]$Plan,
        [AllowNull()][object]$Backup,
        [AllowNull()][object]$FinalState
    )

    [pscustomobject][ordered]@{
        SchemaVersion = '1.0'
        NetworkUsed = $false
        FilesChanged = $false
        RecipeId = $RecipeId
        Status = $Status
        Approved = $Approved
        BackupCreated = $BackupCreated
        Applied = $Applied
        Verified = $Verified
        RolledBack = $RolledBack
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
        $result = New-Result -Status 'PreviewOnly' -Approved $false -BackupCreated $false -Applied $false -Verified $false -RolledBack $false -Plan $plan -Backup $null -FinalState 'Before'
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
        $result = New-Result -Status $status -Approved $true -BackupCreated $true -Applied $true -Verified $verified -RolledBack $rolledBack -Plan $plan -Backup $backup -FinalState $currentState
    }
}
else {
    $catalogPath = Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) 'remediations\catalog.json'
    if (-not (Test-Path -LiteralPath $catalogPath -PathType Leaf)) {
        throw "Remediation-Katalog nicht gefunden: $catalogPath"
    }

    $catalog = Get-Content -Raw -Encoding UTF8 -LiteralPath $catalogPath | ConvertFrom-Json
    $recipe = @($catalog.Remediations | Where-Object Id -eq $RecipeId | Select-Object -First 1)
    if ($recipe.Count -ne 1) {
        throw "Unbekannte Remediation-ID: $RecipeId"
    }

    $item = $recipe[0]
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
    }

    if (-not $Approve) {
        $result = New-Result -Status 'PreviewOnly' -Approved $false -BackupCreated $false -Applied $false -Verified $false -RolledBack $false -Plan $plan -Backup $null -FinalState $null
    }
    elseif ($item.ExecutionMode -eq 'ManualGuided') {
        $result = New-Result -Status 'ManualExecutionRequired' -Approved $true -BackupCreated $false -Applied $false -Verified $false -RolledBack $false -Plan $plan -Backup $null -FinalState $null
    }
    else {
        throw "Nicht unterstützter ExecutionMode: $($item.ExecutionMode)"
    }
}

if ($AsJson) { $result | ConvertTo-Json -Depth 8 } else { $result }
