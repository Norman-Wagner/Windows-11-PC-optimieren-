#requires -Version 5.1

<#
.SYNOPSIS
Erzeugt reproduzierbare diagnostische Auffälligkeiten aus einem Windows-PC-Snapshot 2.0.

.DESCRIPTION
Die Regeln verändern das System nicht. Ein Finding ist ausdrücklich keine bestätigte Ursache.
Es werden nur vorhandene Messwerte bewertet; fehlende Daten erzeugen keine Ersatzannahmen.
#>
[CmdletBinding(DefaultParameterSetName = 'Object')]
param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Object')]
    [psobject]$Snapshot,

    [Parameter(Mandatory = $true, ParameterSetName = 'Path')]
    [ValidateNotNullOrEmpty()]
    [string]$SnapshotPath,

    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'New-DiagnosticFinding.ps1')

function Test-HasProperty {
    param(
        [AllowNull()][psobject]$Object,
        [Parameter(Mandatory = $true)][string]$Name
    )

    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Test-IsAvailableObject {
    param([AllowNull()][psobject]$Object)

    return $null -ne $Object -and -not (Test-HasProperty -Object $Object -Name 'Unavailable')
}

if ($PSCmdlet.ParameterSetName -eq 'Path') {
    if (-not (Test-Path -LiteralPath $SnapshotPath -PathType Leaf)) {
        throw "Snapshot nicht gefunden: $SnapshotPath"
    }
    $Snapshot = Get-Content -Raw -Encoding UTF8 -LiteralPath $SnapshotPath | ConvertFrom-Json
}

if (-not (Test-HasProperty -Object $Snapshot -Name 'SchemaVersion') -or $Snapshot.SchemaVersion -ne '2.0') {
    throw 'Die Diagnose-Engine erwartet Snapshot-SchemaVersion 2.0.'
}

$findings = [System.Collections.Generic.List[object]]::new()

if (Test-HasProperty -Object $Snapshot -Name 'Storage' -and Test-HasProperty -Object $Snapshot.Storage -Name 'Volumes') {
    $systemVolume = @($Snapshot.Storage.Volumes | Where-Object {
        Test-IsAvailableObject $_ -and $_.DriveLetter -eq 'C' -and $null -ne $_.FreePercent
    } | Select-Object -First 1)

    if ($systemVolume.Count -eq 1) {
        $freePercent = [double]$systemVolume[0].FreePercent
        if ($freePercent -lt 5) {
            $findings.Add((New-DiagnosticFinding -Id 'storage.system-critical-space' -Severity 'Critical' -Confidence 'High' -Summary 'Das Systemlaufwerk hat weniger als 5 Prozent freien Speicher.' -Evidence @{ DriveLetter = 'C'; FreePercent = $freePercent } -SuggestedProbe 'Speicherbelegung nach Kategorien lokal prüfen.'))
        }
        elseif ($freePercent -lt 10) {
            $findings.Add((New-DiagnosticFinding -Id 'storage.system-low-space' -Severity 'Warning' -Confidence 'High' -Summary 'Das Systemlaufwerk hat weniger als 10 Prozent freien Speicher.' -Evidence @{ DriveLetter = 'C'; FreePercent = $freePercent } -SuggestedProbe 'Speicherbelegung nach Kategorien lokal prüfen.'))
        }
    }

    $unhealthyVolumes = @($Snapshot.Storage.Volumes | Where-Object {
        Test-IsAvailableObject $_ -and $null -ne $_.HealthStatus -and $_.HealthStatus -notin @('Healthy', 'Unknown')
    })
    if ($unhealthyVolumes.Count -gt 0) {
        $findings.Add((New-DiagnosticFinding -Id 'storage.volume-health-warning' -Severity 'Warning' -Confidence 'High' -Summary 'Mindestens ein Volume meldet einen auffälligen Gesundheitszustand.' -Evidence @{ AffectedCount = $unhealthyVolumes.Count } -SuggestedProbe 'Datenträgerzustand mit Windows- und Herstellerdiagnose verifizieren.'))
    }

    if (Test-HasProperty -Object $Snapshot.Storage -Name 'PhysicalDisks') {
        $unhealthyDisks = @($Snapshot.Storage.PhysicalDisks | Where-Object {
            Test-IsAvailableObject $_ -and $null -ne $_.HealthStatus -and $_.HealthStatus -notin @('Healthy', 'Unknown')
        })
        if ($unhealthyDisks.Count -gt 0) {
            $findings.Add((New-DiagnosticFinding -Id 'storage.physical-disk-health-warning' -Severity 'Critical' -Confidence 'High' -Summary 'Mindestens ein physischer Datenträger meldet einen auffälligen Gesundheitszustand.' -Evidence @{ AffectedCount = $unhealthyDisks.Count } -SuggestedProbe 'Datensicherung priorisieren und Datenträgerdiagnose verifizieren.'))
        }
    }
}

if (Test-HasProperty -Object $Snapshot -Name 'Startup' -and Test-HasProperty -Object $Snapshot.Startup -Name 'Summary') {
    $startupSummary = @($Snapshot.Startup.Summary | Where-Object { Test-IsAvailableObject $_ } | Select-Object -First 1)
    if ($startupSummary.Count -eq 1 -and Test-HasProperty -Object $startupSummary[0] -Name 'StartupCommandCount') {
        $startupCount = [int]$startupSummary[0].StartupCommandCount
        if ($startupCount -ge 30) {
            $findings.Add((New-DiagnosticFinding -Id 'startup.high-count' -Severity 'Info' -Confidence 'Medium' -Summary 'Es wurden mindestens 30 Autostart-Einträge gezählt.' -Evidence @{ StartupCommandCount = $startupCount } -SuggestedProbe 'Autostarts einzeln nach Herausgeber, Zweck und Startauswirkung bewerten.'))
        }
    }
}

if (Test-HasProperty -Object $Snapshot -Name 'Security') {
    if (Test-HasProperty -Object $Snapshot.Security -Name 'Defender') {
        $defender = @($Snapshot.Security.Defender | Where-Object { Test-IsAvailableObject $_ } | Select-Object -First 1)
        if ($defender.Count -eq 1) {
            if (Test-HasProperty -Object $defender[0] -Name 'AntivirusEnabled' -and $defender[0].AntivirusEnabled -eq $false) {
                $findings.Add((New-DiagnosticFinding -Id 'security.antivirus-disabled' -Severity 'Critical' -Confidence 'High' -Summary 'Microsoft Defender Antivirus meldet AntivirusEnabled = false.' -Evidence @{ AntivirusEnabled = $false } -SuggestedProbe 'Prüfen, ob ein anderer verwalteter Virenschutz aktiv ist und warum Defender deaktiviert ist.'))
            }
            elseif (Test-HasProperty -Object $defender[0] -Name 'RealTimeProtectionEnabled' -and $defender[0].RealTimeProtectionEnabled -eq $false) {
                $findings.Add((New-DiagnosticFinding -Id 'security.realtime-protection-disabled' -Severity 'Warning' -Confidence 'High' -Summary 'Der Echtzeitschutz von Microsoft Defender ist deaktiviert.' -Evidence @{ RealTimeProtectionEnabled = $false } -SuggestedProbe 'Ursache und verwaltete Sicherheitsrichtlinien prüfen.'))
            }
        }
    }

    if (Test-HasProperty -Object $Snapshot.Security -Name 'FirewallProfiles') {
        $disabledFirewallProfiles = @($Snapshot.Security.FirewallProfiles | Where-Object {
            Test-IsAvailableObject $_ -and Test-HasProperty -Object $_ -Name 'Enabled' -and $_.Enabled -eq $false
        })
        if ($disabledFirewallProfiles.Count -gt 0) {
            $findings.Add((New-DiagnosticFinding -Id 'security.firewall-profile-disabled' -Severity 'Warning' -Confidence 'High' -Summary 'Mindestens ein Windows-Firewallprofil ist deaktiviert.' -Evidence @{ DisabledProfileCount = $disabledFirewallProfiles.Count } -SuggestedProbe 'Betroffene Profile und zentrale Richtlinien prüfen.'))
        }
    }
}

if (Test-HasProperty -Object $Snapshot -Name 'Updates' -and Test-HasProperty -Object $Snapshot.Updates -Name 'Reboot') {
    $reboot = @($Snapshot.Updates.Reboot | Where-Object { Test-IsAvailableObject $_ } | Select-Object -First 1)
    if ($reboot.Count -eq 1 -and Test-HasProperty -Object $reboot[0] -Name 'RebootPending' -and $reboot[0].RebootPending -eq $true) {
        $findings.Add((New-DiagnosticFinding -Id 'updates.reboot-pending' -Severity 'Info' -Confidence 'High' -Summary 'Windows meldet einen ausstehenden Neustart.' -Evidence @{ RebootPending = $true } -SuggestedProbe 'Vor weitergehender Diagnose einen kontrollierten Neustart einplanen, sofern betrieblich möglich.'))
    }
}

if (Test-HasProperty -Object $Snapshot -Name 'ProblemDevices') {
    $problemDevices = @($Snapshot.ProblemDevices | Where-Object { Test-IsAvailableObject $_ })
    if ($problemDevices.Count -gt 0) {
        $findings.Add((New-DiagnosticFinding -Id 'devices.problem-detected' -Severity 'Warning' -Confidence 'High' -Summary 'Mindestens ein Plug-and-Play-Gerät meldet einen Fehlercode.' -Evidence @{ AffectedCount = $problemDevices.Count } -SuggestedProbe 'Geräteklasse, Fehlercode und zeitlichen Zusammenhang prüfen.'))
    }
}

if (Test-HasProperty -Object $Snapshot -Name 'Performance') {
    if (Test-HasProperty -Object $Snapshot.Performance -Name 'Processor') {
        $processor = @($Snapshot.Performance.Processor | Where-Object { Test-IsAvailableObject $_ } | Select-Object -First 1)
        if ($processor.Count -eq 1 -and Test-HasProperty -Object $processor[0] -Name 'PercentProcessorTime') {
            $cpu = [double]$processor[0].PercentProcessorTime
            if ($cpu -ge 20) {
                $findings.Add((New-DiagnosticFinding -Id 'performance.high-processor-sample' -Severity 'Info' -Confidence 'Low' -Summary 'Die CPU-Auslastung war in der Momentaufnahme erhöht.' -Evidence @{ PercentProcessorTime = $cpu } -SuggestedProbe 'Mehrere Messungen im definierten Leerlaufzustand durchführen.'))
            }
        }
    }

    if (Test-HasProperty -Object $Snapshot.Performance -Name 'Memory' -and Test-HasProperty -Object $Snapshot.Performance.Memory -Name 'FreePhysicalMemoryPercent') {
        $freeMemoryPercent = $Snapshot.Performance.Memory.FreePhysicalMemoryPercent
        if ($null -ne $freeMemoryPercent -and [double]$freeMemoryPercent -lt 10) {
            $findings.Add((New-DiagnosticFinding -Id 'performance.low-free-memory-sample' -Severity 'Info' -Confidence 'Low' -Summary 'In der Momentaufnahme waren weniger als 10 Prozent des sichtbaren Arbeitsspeichers frei.' -Evidence @{ FreePhysicalMemoryPercent = [double]$freeMemoryPercent } -SuggestedProbe 'Speicherdruck über mehrere Messpunkte und Commit-Auslastung prüfen.'))
        }
    }
}

if (Test-HasProperty -Object $Snapshot -Name 'Reliability' -and Test-HasProperty -Object $Snapshot.Reliability -Name 'CriticalOrErrorCount') {
    $eventCount = $Snapshot.Reliability.CriticalOrErrorCount
    if ($null -ne $eventCount -and [int]$eventCount -ge 10) {
        $findings.Add((New-DiagnosticFinding -Id 'reliability.system-error-burst' -Severity 'Info' -Confidence 'Low' -Summary 'Im gewählten Zeitraum wurden mindestens zehn kritische oder Fehlerereignisse gezählt.' -Evidence @{ CriticalOrErrorCount = [int]$eventCount; EventWindowHours = $Snapshot.Reliability.EventWindowHours } -SuggestedProbe 'Ereignisse nach Quelle, Zeitpunkt und Symptom korrelieren; nicht allein aus der Anzahl diagnostizieren.'))
    }
}

$result = [pscustomobject][ordered]@{
    SchemaVersion = '1.0'
    SnapshotSchemaVersion = $Snapshot.SchemaVersion
    EvaluatedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
    NetworkUsed = $false
    FilesChanged = $false
    FindingCount = $findings.Count
    Findings = @($findings)
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 10
}
else {
    $result
}
