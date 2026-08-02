#requires -Version 5.1
<#
.SYNOPSIS
Erfasst eine datensparsame Leistungs-Baseline ohne Systemänderung.

.DESCRIPTION
Liest aggregierte Leistungs- und Speicherwerte. Es werden keine Benutzer-, Computer-,
Serien-, MAC-, IP-, Prozessnamen-, Dateipfad- oder Netzwerkdaten ausgegeben.
Ein OutputPath wird nur auf ausdrücklichen Wunsch beschrieben.
#>
[CmdletBinding()]
param(
    [switch]$AsJson,
    [string]$OutputPath,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-ReadOnlyProbe {
    param([Parameter(Mandatory = $true)][scriptblock]$Action)
    try { @(& $Action) }
    catch { @([pscustomobject]@{ Unavailable = $true; ErrorType = $_.Exception.GetType().Name }) }
}

$operatingSystem = Invoke-ReadOnlyProbe {
    Get-CimInstance -ClassName Win32_OperatingSystem |
        Select-Object @{
            Name = 'LastBootUpTimeUtc'; Expression = {
                if ($null -ne $_.LastBootUpTime) { $_.LastBootUpTime.ToUniversalTime().ToString('o') }
            }
        }, @{
            Name = 'TotalVisibleMemoryMiB'; Expression = { [math]::Round($_.TotalVisibleMemorySize / 1KB, 0) }
        }, @{
            Name = 'FreePhysicalMemoryMiB'; Expression = { [math]::Round($_.FreePhysicalMemory / 1KB, 0) }
        }
}

$processor = Invoke-ReadOnlyProbe {
    Get-CimInstance -ClassName Win32_PerfFormattedData_PerfOS_Processor |
        Where-Object { $_.Name -eq '_Total' } |
        Select-Object @{ Name = 'PercentProcessorTime'; Expression = { $_.PercentProcessorTime } }
}

$system = Invoke-ReadOnlyProbe {
    Get-CimInstance -ClassName Win32_PerfFormattedData_PerfOS_System |
        Select-Object ContextSwitchesPersec, SystemCallsPersec, ProcessorQueueLength
}

$volumes = if ($null -ne (Get-Command Get-Volume -ErrorAction SilentlyContinue)) {
    Invoke-ReadOnlyProbe {
        Get-Volume | Where-Object { $null -ne $_.DriveLetter } |
            Sort-Object DriveLetter |
            Select-Object DriveLetter, HealthStatus, @{
                Name = 'FreeGiB'; Expression = { [math]::Round($_.SizeRemaining / 1GB, 1) }
            }, @{
                Name = 'FreePercent'; Expression = {
                    if ($_.Size -gt 0) { [math]::Round(100 * $_.SizeRemaining / $_.Size, 1) }
                }
            }
    }
} else {
    @([pscustomobject]@{ Unavailable = $true; ErrorType = 'CommandNotFound' })
}

$startupCount = Invoke-ReadOnlyProbe {
    [pscustomobject]@{
        StartupCommandCount = @(Get-CimInstance -ClassName Win32_StartupCommand).Count
    }
}

$baseline = [pscustomobject][ordered]@{
    SchemaVersion = '1.0'
    CollectedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
    PrivacyNotice = 'Keine Benutzer-, Computer-, Serien-, MAC-, IP-, Prozessnamen-, Dateipfad- oder Netzwerkdaten.'
    OperatingSystem = $operatingSystem
    Processor = $processor
    System = $system
    Volumes = $volumes
    Startup = $startupCount
    Interpretation = 'Einzelwerte sind eine Momentaufnahme. Für Vorher/Nachher denselben Zustand und dieselbe Nutzungssituation messen.'
}

$json = $baseline | ConvertTo-Json -Depth 6
if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
    $fullOutputPath = [System.IO.Path]::GetFullPath($OutputPath)
    $parentPath = Split-Path -Parent $fullOutputPath
    if (-not (Test-Path -LiteralPath $parentPath -PathType Container)) {
        throw "Der Zielordner existiert nicht: $parentPath"
    }
    if ((Test-Path -LiteralPath $fullOutputPath) -and -not $Force) {
        throw 'Die Ausgabedatei existiert bereits. Zum Überschreiben -Force verwenden.'
    }
    Set-Content -LiteralPath $fullOutputPath -Value $json -Encoding UTF8
    [pscustomobject]@{ OutputPath = $fullOutputPath; Bytes = (Get-Item -LiteralPath $fullOutputPath).Length }
} elseif ($AsJson) {
    $json
} else {
    $baseline
}
