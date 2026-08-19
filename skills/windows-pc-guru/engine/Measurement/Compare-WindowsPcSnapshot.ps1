#requires -Version 5.1

<#
.SYNOPSIS
Vergleicht zwei Windows-PC-Snapshots der SchemaVersion 2.0.

.DESCRIPTION
Berechnet ausgewählte Vorher-/Nachher-Differenzen und klassifiziert sie als
Improved, Regressed, Unchanged oder Inconclusive. Einzelne CPU- oder RAM-
Momentaufnahmen werden bewusst nicht als Beweis einer Verbesserung gewertet.
#>
[CmdletBinding(DefaultParameterSetName = 'Object')]
param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Object')]
    [psobject]$Before,
    [Parameter(Mandatory = $true, ParameterSetName = 'Object')]
    [psobject]$After,
    [Parameter(Mandatory = $true, ParameterSetName = 'Path')]
    [string]$BeforePath,
    [Parameter(Mandatory = $true, ParameterSetName = 'Path')]
    [string]$AfterPath,
    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Import-Snapshot {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Snapshot nicht gefunden: $Path"
    }
    Get-Content -Raw -Encoding UTF8 -LiteralPath $Path | ConvertFrom-Json
}

function Test-Property {
    param([AllowNull()][psobject]$Object, [Parameter(Mandatory = $true)][string]$Name)
    $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Get-FirstAvailable {
    param([AllowNull()][object]$Value)
    foreach ($item in @($Value)) {
        if ($null -ne $item -and -not (Test-Property -Object $item -Name 'Unavailable')) {
            return $item
        }
    }
    return $null
}

function New-Comparison {
    param(
        [string]$Id,
        [string]$Label,
        [AllowNull()]$BeforeValue,
        [AllowNull()]$AfterValue,
        [ValidateSet('HigherIsBetter','LowerIsBetter','Informational','BooleanResolved')]
        [string]$Direction,
        [double]$MeaningfulDelta = 0
    )

    $status = 'Inconclusive'
    $absoluteDelta = $null
    $relativeDeltaPercent = $null
    $note = $null

    if ($null -ne $BeforeValue -and $null -ne $AfterValue) {
        if ($Direction -eq 'Informational') {
            $status = 'Inconclusive'
            $note = 'Momentaufnahme oder Kontextwert; keine isolierte Erfolgsbewertung.'
        }
        elseif ($Direction -eq 'BooleanResolved') {
            if ([bool]$BeforeValue -and -not [bool]$AfterValue) { $status = 'Improved' }
            elseif (-not [bool]$BeforeValue -and [bool]$AfterValue) { $status = 'Regressed' }
            else { $status = 'Unchanged' }
        }
        else {
            $beforeNumber = [double]$BeforeValue
            $afterNumber = [double]$AfterValue
            $absoluteDelta = [math]::Round($afterNumber - $beforeNumber, 2)
            if ([math]::Abs($beforeNumber) -gt 0.0001) {
                $relativeDeltaPercent = [math]::Round(100 * $absoluteDelta / [math]::Abs($beforeNumber), 1)
            }

            if ([math]::Abs($absoluteDelta) -le $MeaningfulDelta) {
                $status = 'Unchanged'
            }
            elseif ($Direction -eq 'HigherIsBetter') {
                $status = if ($absoluteDelta -gt 0) { 'Improved' } else { 'Regressed' }
            }
            else {
                $status = if ($absoluteDelta -lt 0) { 'Improved' } else { 'Regressed' }
            }
        }
    }

    [pscustomobject][ordered]@{
        Id = $Id
        Label = $Label
        Before = $BeforeValue
        After = $AfterValue
        AbsoluteDelta = $absoluteDelta
        RelativeDeltaPercent = $relativeDeltaPercent
        Status = $status
        Note = $note
    }
}

if ($PSCmdlet.ParameterSetName -eq 'Path') {
    $Before = Import-Snapshot -Path $BeforePath
    $After = Import-Snapshot -Path $AfterPath
}

foreach ($snapshot in @($Before, $After)) {
    if (-not (Test-Property -Object $snapshot -Name 'SchemaVersion') -or $snapshot.SchemaVersion -ne '2.0') {
        throw 'Beide Snapshots müssen SchemaVersion 2.0 verwenden.'
    }
}

$beforeSystemVolume = Get-FirstAvailable -Value @($Before.Storage.Volumes | Where-Object { $_.DriveLetter -eq 'C' })
$afterSystemVolume = Get-FirstAvailable -Value @($After.Storage.Volumes | Where-Object { $_.DriveLetter -eq 'C' })
$beforeStartup = Get-FirstAvailable -Value $Before.Startup.Summary
$afterStartup = Get-FirstAvailable -Value $After.Startup.Summary
$beforeProcessor = Get-FirstAvailable -Value $Before.Performance.Processor
$afterProcessor = Get-FirstAvailable -Value $After.Performance.Processor
$beforeReboot = Get-FirstAvailable -Value $Before.Updates.Reboot
$afterReboot = Get-FirstAvailable -Value $After.Updates.Reboot

$comparisons = @(
    New-Comparison -Id 'storage.system-free-percent' -Label 'Freier Speicher auf C in Prozent' -BeforeValue $(if ($beforeSystemVolume) { $beforeSystemVolume.FreePercent } else { $null }) -AfterValue $(if ($afterSystemVolume) { $afterSystemVolume.FreePercent } else { $null }) -Direction HigherIsBetter -MeaningfulDelta 0.5
    New-Comparison -Id 'startup.count' -Label 'Autostart-Anzahl' -BeforeValue $(if ($beforeStartup) { $beforeStartup.StartupCommandCount } else { $null }) -AfterValue $(if ($afterStartup) { $afterStartup.StartupCommandCount } else { $null }) -Direction LowerIsBetter
    New-Comparison -Id 'devices.problem-count' -Label 'Geräte mit Fehlercode' -BeforeValue @($Before.ProblemDevices).Count -AfterValue @($After.ProblemDevices).Count -Direction LowerIsBetter
    New-Comparison -Id 'updates.reboot-pending' -Label 'Ausstehender Neustart' -BeforeValue $(if ($beforeReboot) { $beforeReboot.RebootPending } else { $null }) -AfterValue $(if ($afterReboot) { $afterReboot.RebootPending } else { $null }) -Direction BooleanResolved
    New-Comparison -Id 'performance.cpu-sample' -Label 'CPU-Momentaufnahme in Prozent' -BeforeValue $(if ($beforeProcessor) { $beforeProcessor.PercentProcessorTime } else { $null }) -AfterValue $(if ($afterProcessor) { $afterProcessor.PercentProcessorTime } else { $null }) -Direction Informational
    New-Comparison -Id 'performance.free-memory-percent' -Label 'Freier RAM in Prozent' -BeforeValue $Before.Performance.Memory.FreePhysicalMemoryPercent -AfterValue $After.Performance.Memory.FreePhysicalMemoryPercent -Direction Informational
    New-Comparison -Id 'reliability.event-count' -Label 'Kritische/Fehler-Ereignisse im Messfenster' -BeforeValue $Before.Reliability.CriticalOrErrorCount -AfterValue $After.Reliability.CriticalOrErrorCount -Direction Informational
)

$confirmed = @($comparisons | Where-Object { $_.Status -in @('Improved','Regressed') })
$overall = 'Inconclusive'
if (@($confirmed | Where-Object Status -eq 'Regressed').Count -gt 0) {
    $overall = 'RegressionDetected'
}
elseif (@($confirmed | Where-Object Status -eq 'Improved').Count -gt 0) {
    $overall = 'ImprovementDetected'
}

$result = [pscustomobject][ordered]@{
    SchemaVersion = '1.0'
    SnapshotSchemaVersion = '2.0'
    ComparedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
    NetworkUsed = $false
    FilesChanged = $false
    OverallStatus = $overall
    Comparisons = $comparisons
    Interpretation = 'Nur belastbare, richtungsbezogene Signale beeinflussen den Gesamtstatus. Momentaufnahmen bleiben unentschieden.'
}

if ($AsJson) { $result | ConvertTo-Json -Depth 8 } else { $result }
