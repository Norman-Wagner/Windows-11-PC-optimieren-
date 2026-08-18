#requires -Version 5.1

<#
.SYNOPSIS
Erfasst einen datensparsamen lokalen Kompatibilitätskontext fuer Remediations.

.DESCRIPTION
Liest ausschliesslich technische Betriebssystem- und Geraeteklassenmerkmale sowie
lokal verfuegbare Diagnosebefehle. Es werden keine Benutzer-, Computer-, Serien-,
MAC-, IP-, Datei- oder Inhaltsdaten erfasst. Das Skript nutzt kein Netzwerk und
veraendert keine Systemeinstellung.
#>
[CmdletBinding()]
param(
    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-FirstCimInstanceSafe {
    param([Parameter(Mandatory = $true)][string]$ClassName)

    try {
        return @(Get-CimInstance -ClassName $ClassName -ErrorAction Stop)[0]
    }
    catch {
        return $null
    }
}

function Get-EditionName {
    param([AllowNull()][string]$Caption)

    if ([string]::IsNullOrWhiteSpace($Caption)) { return 'Unknown' }
    if ($Caption -match '(?i)Pro for Workstations') { return 'ProWorkstations' }
    if ($Caption -match '(?i)Pro Education') { return 'ProEducation' }
    if ($Caption -match '(?i)Enterprise') { return 'Enterprise' }
    if ($Caption -match '(?i)Education') { return 'Education' }
    if ($Caption -match '(?i)\bHome\b') { return 'Home' }
    if ($Caption -match '(?i)\bPro\b') { return 'Pro' }
    return 'Unknown'
}

function Get-OsFamily {
    param([AllowNull()][string]$Caption)

    if ([string]::IsNullOrWhiteSpace($Caption)) { return 'Unknown' }
    if ($Caption -match '(?i)Windows 11') { return 'Windows11' }
    if ($Caption -match '(?i)Windows Server') { return 'WindowsServer' }
    if ($Caption -match '(?i)Windows') { return 'OtherWindows' }
    return 'Unknown'
}

function Get-NormalizedArchitecture {
    param(
        [AllowNull()][string]$OsArchitecture,
        [AllowNull()][string]$SystemType
    )

    $combined = "$OsArchitecture $SystemType"
    if ($combined -match '(?i)ARM64|ARM-based|ARM-basiert') { return 'arm64' }
    if ($combined -match '(?i)x64|64-Bit|64-bit|64 bit') { return 'x64' }
    if ($combined -match '(?i)x86|32-Bit|32-bit|32 bit') { return 'x86' }
    return 'Unknown'
}

function Get-DeviceType {
    param([AllowNull()][object]$PCSystemTypeEx)

    if ($null -eq $PCSystemTypeEx) { return 'Unknown' }

    switch ([int]$PCSystemTypeEx) {
        1 { return 'Desktop' }
        2 { return 'Laptop' }
        3 { return 'Workstation' }
        4 { return 'Server' }
        5 { return 'Server' }
        6 { return 'Other' }
        7 { return 'Server' }
        8 { return 'Tablet' }
        default { return 'Unknown' }
    }
}

function Test-CommandAvailable {
    param([Parameter(Mandatory = $true)][string]$Name)
    return $null -ne (Get-Command -Name $Name -ErrorAction SilentlyContinue)
}

$os = Get-FirstCimInstanceSafe -ClassName 'Win32_OperatingSystem'
$computerSystem = Get-FirstCimInstanceSafe -ClassName 'Win32_ComputerSystem'

$caption = if ($null -ne $os) { [string]$os.Caption } else { $null }
$buildNumber = $null
if ($null -ne $os -and $null -ne $os.BuildNumber -and [string]$os.BuildNumber -match '^\d+$') {
    $buildNumber = [int]$os.BuildNumber
}

$capabilities = @()
if (Test-CommandAvailable -Name 'Get-Volume') { $capabilities += 'Storage.VolumeInventory' }
if (Test-CommandAvailable -Name 'Get-PhysicalDisk') { $capabilities += 'Storage.PhysicalDiskInventory' }
if (Test-CommandAvailable -Name 'Get-MpComputerStatus') { $capabilities += 'Security.DefenderStatus' }
if (Test-CommandAvailable -Name 'Get-NetFirewallProfile') { $capabilities += 'Security.FirewallProfiles' }
if (Test-CommandAvailable -Name 'Get-WinEvent') { $capabilities += 'Reliability.SystemEventLog' }
if ($null -ne (Get-Command -Name 'Get-CimInstance' -ErrorAction SilentlyContinue)) {
    $capabilities += 'System.CimInventory'
    $capabilities += 'Devices.PnpInventory'
}

$result = [pscustomobject][ordered]@{
    SchemaVersion = '1.0'
    CollectedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
    PrivacyNotice = 'Keine Benutzer-, Computer-, Serien-, MAC-, IP-, Datei- oder Inhaltsdaten.'
    NetworkUsed = $false
    FilesChanged = $false
    OperatingSystem = [pscustomobject][ordered]@{
        Family = Get-OsFamily -Caption $caption
        Edition = Get-EditionName -Caption $caption
        BuildNumber = $buildNumber
        Architecture = Get-NormalizedArchitecture -OsArchitecture $(if ($null -ne $os) { [string]$os.OSArchitecture } else { $null }) -SystemType $(if ($null -ne $computerSystem) { [string]$computerSystem.SystemType } else { $null })
    }
    DeviceType = Get-DeviceType -PCSystemTypeEx $(if ($null -ne $computerSystem) { $computerSystem.PCSystemTypeEx } else { $null })
    Capabilities = @($capabilities | Sort-Object -Unique)
}

if ($AsJson) { $result | ConvertTo-Json -Depth 6 } else { $result }
