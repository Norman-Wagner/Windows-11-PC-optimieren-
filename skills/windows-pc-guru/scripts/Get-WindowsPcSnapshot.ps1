#requires -Version 5.1

<#
.SYNOPSIS
Erfasst eine datensparsame, rein lesende Windows-Systemübersicht.

.DESCRIPTION
Liest technische Basisdaten, ohne Computername, Benutzername, Seriennummern,
MAC-/IP-Adressen oder persönliche Dateien zu erfassen. Das Skript nutzt kein
Netzwerk und verändert keine Systemeinstellung.

.PARAMETER IncludeRecentSystemEvents
Ergänzt Metadaten kritischer Systemereignisse ohne Nachrichtentext.

.PARAMETER EventHours
Begrenzt den Ereigniszeitraum. Standard: 24 Stunden.

.PARAMETER AsJson
Gibt das Ergebnis als JSON statt als PowerShell-Objekt aus.

.PARAMETER OutputPath
Speichert JSON an einem bereits vorhandenen Zielordner.

.PARAMETER Force
Erlaubt das Überschreiben einer vorhandenen Ausgabedatei.
#>
[CmdletBinding()]
param(
    [switch]$IncludeRecentSystemEvents,

    [ValidateRange(1, 168)]
    [int]$EventHours = 24,

    [switch]$AsJson,

    [string]$OutputPath,

    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-ReadOnlyProbe {
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
    )

    try {
        return @(& $Action)
    }
    catch {
        return @(
            [pscustomobject]@{
                Unavailable = $true
                ErrorType  = $_.Exception.GetType().Name
            }
        )
    }
}

function Test-CommandAvailable {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return $null -ne (Get-Command -Name $Name -ErrorAction SilentlyContinue)
}

$operatingSystem = Invoke-ReadOnlyProbe {
    Get-CimInstance -ClassName Win32_OperatingSystem |
        Select-Object Caption, Version, BuildNumber, OSArchitecture,
            @{ Name = 'LastBootUpTimeUtc'; Expression = {
                if ($null -ne $_.LastBootUpTime) {
                    $_.LastBootUpTime.ToUniversalTime().ToString('o')
                }
            } }
}

$computerSystem = Invoke-ReadOnlyProbe {
    Get-CimInstance -ClassName Win32_ComputerSystem |
        Select-Object Manufacturer, Model,
            @{ Name = 'TotalPhysicalMemoryGiB'; Expression = {
                [math]::Round($_.TotalPhysicalMemory / 1GB, 2)
            } }
}

$processors = Invoke-ReadOnlyProbe {
    Get-CimInstance -ClassName Win32_Processor |
        Select-Object Name, NumberOfCores, NumberOfLogicalProcessors,
            AddressWidth
}

$bios = Invoke-ReadOnlyProbe {
    Get-CimInstance -ClassName Win32_BIOS |
        Select-Object SMBIOSBIOSVersion,
            @{ Name = 'ReleaseDateUtc'; Expression = {
                if ($null -ne $_.ReleaseDate) {
                    $_.ReleaseDate.ToUniversalTime().ToString('o')
                }
            } }
}

$volumes = if (Test-CommandAvailable -Name 'Get-Volume') {
    Invoke-ReadOnlyProbe {
        Get-Volume |
            Where-Object { $null -ne $_.DriveLetter } |
            Sort-Object DriveLetter |
            Select-Object DriveLetter, FileSystem, HealthStatus,
                @{ Name = 'SizeGiB'; Expression = {
                    [math]::Round($_.Size / 1GB, 2)
                } },
                @{ Name = 'FreeGiB'; Expression = {
                    [math]::Round($_.SizeRemaining / 1GB, 2)
                } }
    }
}
else {
    @([pscustomobject]@{ Unavailable = $true; ErrorType = 'CommandNotFound' })
}

$physicalDisks = if (Test-CommandAvailable -Name 'Get-PhysicalDisk') {
    Invoke-ReadOnlyProbe {
        Get-PhysicalDisk |
            Select-Object FriendlyName, MediaType, BusType, HealthStatus,
                OperationalStatus,
                @{ Name = 'SizeGiB'; Expression = {
                    [math]::Round($_.Size / 1GB, 2)
                } }
    }
}
else {
    @([pscustomobject]@{ Unavailable = $true; ErrorType = 'CommandNotFound' })
}

$problemDevices = Invoke-ReadOnlyProbe {
    Get-CimInstance -ClassName Win32_PnPEntity |
        Where-Object {
            $null -ne $_.ConfigManagerErrorCode -and
            $_.ConfigManagerErrorCode -ne 0
        } |
        Select-Object PNPClass, Manufacturer, Status, ConfigManagerErrorCode
}

$networkAdapters = if (Test-CommandAvailable -Name 'Get-NetAdapter') {
    Invoke-ReadOnlyProbe {
        Get-NetAdapter |
            Sort-Object InterfaceDescription |
            Select-Object InterfaceDescription, Status, LinkSpeed
    }
}
else {
    @([pscustomobject]@{ Unavailable = $true; ErrorType = 'CommandNotFound' })
}

$defender = if (Test-CommandAvailable -Name 'Get-MpComputerStatus') {
    Invoke-ReadOnlyProbe {
        Get-MpComputerStatus |
            Select-Object AntivirusEnabled, RealTimeProtectionEnabled,
                BehaviorMonitorEnabled, IoavProtectionEnabled,
                AntivirusSignatureVersion,
                @{ Name = 'AntivirusSignatureLastUpdatedUtc'; Expression = {
                    if ($null -ne $_.AntivirusSignatureLastUpdated) {
                        $_.AntivirusSignatureLastUpdated.ToUniversalTime().
                            ToString('o')
                    }
                } }
    }
}
else {
    @([pscustomobject]@{ Unavailable = $true; ErrorType = 'CommandNotFound' })
}

$recentUpdates = Invoke-ReadOnlyProbe {
    Get-HotFix |
        Sort-Object InstalledOn -Descending |
        Select-Object -First 10 HotFixID, Description,
            @{ Name = 'InstalledOn'; Expression = {
                if ($null -ne $_.InstalledOn) {
                    $_.InstalledOn.ToString('yyyy-MM-dd')
                }
            } }
}

$recentSystemEvents = @()
if ($IncludeRecentSystemEvents) {
    $startTime = (Get-Date).AddHours(-1 * $EventHours)
    $recentSystemEvents = Invoke-ReadOnlyProbe {
        Get-WinEvent -FilterHashtable @{
            LogName   = 'System'
            Level     = 1, 2
            StartTime = $startTime
        } -ErrorAction Stop |
            Select-Object -First 100 TimeCreated, Id, ProviderName,
                LevelDisplayName
    }
}

$snapshot = [pscustomobject][ordered]@{
    SchemaVersion       = '1.0'
    CollectedAtUtc      = (Get-Date).ToUniversalTime().ToString('o')
    PrivacyNotice       = 'Keine Benutzer-, Computer-, Serien-, MAC-, IP- oder Dateiinhaltsdaten.'
    NetworkUsed         = $false
    FilesChanged        = $false
    OperatingSystem     = $operatingSystem
    ComputerSystem      = $computerSystem
    Processors          = $processors
    Bios                = $bios
    Volumes             = $volumes
    PhysicalDisks       = $physicalDisks
    ProblemDevices      = $problemDevices
    NetworkAdapters     = $networkAdapters
    DefenderStatus      = $defender
    RecentUpdates       = $recentUpdates
    RecentSystemEvents  = $recentSystemEvents
}

$json = $snapshot | ConvertTo-Json -Depth 8

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
    [pscustomobject]@{
        OutputPath = $fullOutputPath
        Bytes      = (Get-Item -LiteralPath $fullOutputPath).Length
    }
}
elseif ($AsJson) {
    $json
}
else {
    $snapshot
}
