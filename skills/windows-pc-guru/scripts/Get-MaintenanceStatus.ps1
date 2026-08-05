#requires -Version 5.1
<#
.SYNOPSIS
Prüft lesend, ob ein Windows-11-PC noch gepflegt ist.

.DESCRIPTION
Misst Laufzeit seit dem letzten Neustart, Alter des letzten Qualitätsupdates,
Alter der Defender-Signaturen, freien Speicherplatz und die Anzahl der
Autostart-Einträge. Jeder Messwert wird gegen dokumentierte Schwellwerte
bewertet. Es werden keine Benutzer-, Computer-, Serien-, MAC-, IP-,
Prozessnamen-, Dateipfad- oder Netzwerkdaten ausgegeben.

Schwellwerte:
- Laufzeit seit Neustart: mehr als 30 Tage -> Warnung
- Letztes Qualitätsupdate: mehr als 45 Tage -> Warnung
- Defender-Signaturen: mehr als 7 Tage -> Warnung
- Freier Speicherplatz je Laufwerk: unter 15 Prozent -> Warnung
- Autostart-Einträge: mehr als 15 -> Warnung
#>
[CmdletBinding()]
param(
    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function New-CheckResult {
    param(
        [Parameter(Mandatory = $true)][string]$Bereich,
        [Parameter(Mandatory = $true)][ValidateSet('OK', 'Warnung', 'Unbekannt')][string]$Status,
        [Parameter(Mandatory = $true)][string]$Befund,
        [Parameter(Mandatory = $true)][string]$Empfehlung
    )

    [pscustomobject][ordered]@{
        Bereich = $Bereich
        Status = $Status
        Befund = $Befund
        Empfehlung = $Empfehlung
    }
}

function Invoke-SafeCheck {
    param(
        [Parameter(Mandatory = $true)][string]$Bereich,
        [Parameter(Mandatory = $true)][string]$FallbackEmpfehlung,
        [Parameter(Mandatory = $true)][scriptblock]$Action
    )

    try {
        & $Action
    } catch {
        New-CheckResult -Bereich $Bereich -Status 'Unbekannt' `
            -Befund "Nicht auslesbar ($($_.Exception.GetType().Name))." `
            -Empfehlung $FallbackEmpfehlung
    }
}

$checks = @()

$checks += Invoke-SafeCheck -Bereich 'Laufzeit seit Neustart' `
    -FallbackEmpfehlung 'Im Task-Manager unter Leistung die Betriebszeit prüfen.' `
    -Action {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem
        $uptimeDays = [int][math]::Floor(((Get-Date) - $os.LastBootUpTime).TotalDays)
        if ($uptimeDays -le 30) {
            New-CheckResult -Bereich 'Laufzeit seit Neustart' -Status 'OK' `
                -Befund "Letzter Neustart vor $uptimeDays Tag(en)." `
                -Empfehlung 'Nichts zu tun.'
        } else {
            New-CheckResult -Bereich 'Laufzeit seit Neustart' -Status 'Warnung' `
                -Befund "Letzter Neustart vor $uptimeDays Tagen." `
                -Empfehlung 'Vollständigen Neustart einplanen, damit ausstehende Updates fertig installiert werden.'
        }
    }

$checks += Invoke-SafeCheck -Bereich 'Qualitätsupdates' `
    -FallbackEmpfehlung 'Einstellungen > Windows Update > Updateverlauf prüfen.' `
    -Action {
        $dates = @(
            Get-CimInstance -ClassName Win32_QuickFixEngineering |
                ForEach-Object { $_.InstalledOn } |
                Where-Object { $null -ne $_ }
        )
        if ($dates.Count -eq 0) {
            New-CheckResult -Bereich 'Qualitätsupdates' -Status 'Unbekannt' `
                -Befund 'Kein Installationsdatum auslesbar.' `
                -Empfehlung 'Einstellungen > Windows Update > Updateverlauf prüfen (Phase 3.1).'
        } else {
            $ageDays = [int][math]::Floor(((Get-Date) - ($dates | Sort-Object -Descending | Select-Object -First 1)).TotalDays)
            if ($ageDays -le 45) {
                New-CheckResult -Bereich 'Qualitätsupdates' -Status 'OK' `
                    -Befund "Letztes Qualitätsupdate vor $ageDays Tag(en)." `
                    -Empfehlung 'Nichts zu tun.'
            } else {
                New-CheckResult -Bereich 'Qualitätsupdates' -Status 'Warnung' `
                    -Befund "Letztes Qualitätsupdate vor $ageDays Tagen." `
                    -Empfehlung 'Einstellungen > Windows Update öffnen und Updates installieren (Phase 3.1).'
            }
        }
    }

$checks += Invoke-SafeCheck -Bereich 'Defender-Signaturen' `
    -FallbackEmpfehlung 'Windows-Sicherheit > Viren- und Bedrohungsschutz prüfen.' `
    -Action {
        $mp = Get-MpComputerStatus
        $signatureAgeDays = [int][math]::Floor(((Get-Date) - $mp.AntivirusSignatureLastUpdated).TotalDays)
        if ($signatureAgeDays -le 7) {
            New-CheckResult -Bereich 'Defender-Signaturen' -Status 'OK' `
                -Befund "Signaturen sind $signatureAgeDays Tag(e) alt." `
                -Empfehlung 'Nichts zu tun.'
        } else {
            New-CheckResult -Bereich 'Defender-Signaturen' -Status 'Warnung' `
                -Befund "Signaturen sind $signatureAgeDays Tage alt." `
                -Empfehlung 'In Windows-Sicherheit nach Updates für die Sicherheitsinformationen suchen; danach Windows Update prüfen.'
        }
    }

$checks += Invoke-SafeCheck -Bereich 'Freier Speicherplatz' `
    -FallbackEmpfehlung 'Im Explorer unter Dieser PC die Laufwerksfüllstände prüfen.' `
    -Action {
        $volumes = @(
            Get-Volume | Where-Object { $null -ne $_.DriveLetter -and $_.Size -gt 0 }
        )
        if ($volumes.Count -eq 0) {
            New-CheckResult -Bereich 'Freier Speicherplatz' -Status 'Unbekannt' `
                -Befund 'Keine Laufwerke mit Buchstaben gefunden.' `
                -Empfehlung 'Im Explorer unter Dieser PC die Laufwerksfüllstände prüfen.'
        } else {
            $low = @($volumes | Where-Object { (100 * $_.SizeRemaining / $_.Size) -lt 15 })
            if ($low.Count -eq 0) {
                New-CheckResult -Bereich 'Freier Speicherplatz' -Status 'OK' `
                    -Befund "Alle $($volumes.Count) Laufwerke haben mindestens 15 Prozent frei." `
                    -Empfehlung 'Nichts zu tun.'
            } else {
                $letters = ($low | Sort-Object DriveLetter | ForEach-Object { "$($_.DriveLetter):" }) -join ', '
                New-CheckResult -Bereich 'Freier Speicherplatz' -Status 'Warnung' `
                    -Befund "Unter 15 Prozent frei auf: $letters" `
                    -Empfehlung 'Einstellungen > System > Speicher öffnen und mit der Speicheroptimierung aufräumen (Phase 5.4).'
            }
        }
    }

$checks += Invoke-SafeCheck -Bereich 'Autostart' `
    -FallbackEmpfehlung 'Im Task-Manager die Registerkarte Autostart von Apps prüfen.' `
    -Action {
        $startupCount = @(Get-CimInstance -ClassName Win32_StartupCommand).Count
        if ($startupCount -le 15) {
            New-CheckResult -Bereich 'Autostart' -Status 'OK' `
                -Befund "$startupCount Autostart-Einträge." `
                -Empfehlung 'Nichts zu tun.'
        } else {
            New-CheckResult -Bereich 'Autostart' -Status 'Warnung' `
                -Befund "$startupCount Autostart-Einträge." `
                -Empfehlung 'Im Task-Manager nicht benötigte Einträge deaktivieren – nicht löschen (Phase 5.3).'
        }
    }

$summary = [pscustomobject][ordered]@{
    OkCount = @($checks | Where-Object { $_.Status -eq 'OK' }).Count
    WarnungCount = @($checks | Where-Object { $_.Status -eq 'Warnung' }).Count
    UnbekanntCount = @($checks | Where-Object { $_.Status -eq 'Unbekannt' }).Count
    CheckCount = @($checks).Count
}

$report = [pscustomobject][ordered]@{
    SchemaVersion = '1.0'
    CollectedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
    PrivacyNotice = 'Keine Benutzer-, Computer-, Serien-, MAC-, IP-, Prozessnamen-, Dateipfad- oder Netzwerkdaten.'
    NetworkUsed = $false
    FilesChanged = $false
    Summary = $summary
    Checks = $checks
    Interpretation = 'Die Routine dazu steht in Phase 7 (Wartungsroutine). Warnungen einzeln abarbeiten, nicht alles auf einmal ändern.'
}

if ($AsJson) {
    $report | ConvertTo-Json -Depth 6
} else {
    $report
}
