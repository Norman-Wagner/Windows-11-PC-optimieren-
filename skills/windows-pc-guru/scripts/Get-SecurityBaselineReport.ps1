#requires -Version 5.1
<#
.SYNOPSIS
Erstellt einen lesenden Sicherheitsbericht für Windows 11 ohne Systemänderung.

.DESCRIPTION
Prüft Defender, Firewall, SmartScreen, UAC, Secure Boot, TPM, BitLocker und
den Update-Stand. Jeder Prüfpunkt liefert Status und Empfehlung. Es werden
keine Benutzer-, Computer-, Serien-, MAC-, IP-, Prozessnamen-, Dateipfad-
oder Netzwerkdaten ausgegeben. Fehlende Rechte führen zum Status 'Unbekannt',
niemals zum Abbruch.

Mit -HtmlPath wird der Bericht zusätzlich als druckbare, eigenständige
HTML-Datei an den vom Nutzer gewählten Pfad geschrieben (keine externen
Ressourcen, keine Skripte). Eine vorhandene Datei wird nur mit -Force
überschrieben.
#>
[CmdletBinding()]
param(
    [switch]$AsJson,
    [string]$HtmlPath,
    [switch]$Force
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
            -Befund "Nicht auslesbar ($($_.Exception.GetType().Name)), oft fehlen nur Adminrechte." `
            -Empfehlung $FallbackEmpfehlung
    }
}

function Get-RegistryValueOrNull {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Name
    )

    $item = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -ne $item) { $item.$Name } else { $null }
}

$checks = @()

$checks += Invoke-SafeCheck -Bereich 'Virenschutz (Defender)' `
    -FallbackEmpfehlung 'Status manuell prüfen: Einstellungen > Datenschutz und Sicherheit > Windows-Sicherheit > Viren- und Bedrohungsschutz.' `
    -Action {
        $mp = Get-MpComputerStatus
        $signatureAgeDays = [int][math]::Floor(((Get-Date) - $mp.AntivirusSignatureLastUpdated).TotalDays)
        if ($mp.RealTimeProtectionEnabled -and $mp.AntivirusEnabled -and $signatureAgeDays -le 7) {
            New-CheckResult -Bereich 'Virenschutz (Defender)' -Status 'OK' `
                -Befund "Echtzeitschutz aktiv, Signaturen $signatureAgeDays Tag(e) alt." `
                -Empfehlung 'Nichts zu tun.'
        } elseif (-not $mp.RealTimeProtectionEnabled -or -not $mp.AntivirusEnabled) {
            New-CheckResult -Bereich 'Virenschutz (Defender)' -Status 'Warnung' `
                -Befund 'Echtzeitschutz oder Virenschutz ist nicht aktiv.' `
                -Empfehlung 'Windows-Sicherheit öffnen und den Echtzeitschutz aktivieren. Ist bewusst ein anderes Schutzprogramm aktiv, dessen Status dort prüfen (Phase 3.2).'
        } else {
            New-CheckResult -Bereich 'Virenschutz (Defender)' -Status 'Warnung' `
                -Befund "Signaturen sind $signatureAgeDays Tage alt." `
                -Empfehlung 'In Windows-Sicherheit unter Viren- und Bedrohungsschutz nach Updates für die Sicherheitsinformationen suchen.'
        }
    }

$checks += Invoke-SafeCheck -Bereich 'Firewall' `
    -FallbackEmpfehlung 'Status manuell prüfen: Windows-Sicherheit > Firewall- und Netzwerkschutz.' `
    -Action {
        $profiles = @(Get-NetFirewallProfile)
        $disabled = @($profiles | Where-Object { -not $_.Enabled })
        if ($disabled.Count -eq 0) {
            New-CheckResult -Bereich 'Firewall' -Status 'OK' `
                -Befund "Alle $($profiles.Count) Firewall-Profile sind aktiv." `
                -Empfehlung 'Nichts zu tun.'
        } else {
            New-CheckResult -Bereich 'Firewall' -Status 'Warnung' `
                -Befund "$($disabled.Count) von $($profiles.Count) Firewall-Profilen sind deaktiviert." `
                -Empfehlung 'Windows-Sicherheit > Firewall- und Netzwerkschutz öffnen und die Firewall für alle Netzwerkprofile aktivieren (Phase 3.2).'
        }
    }

$checks += Invoke-SafeCheck -Bereich 'SmartScreen' `
    -FallbackEmpfehlung 'Status manuell prüfen: Windows-Sicherheit > App- und Browsersteuerung.' `
    -Action {
        $value = Get-RegistryValueOrNull -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' -Name 'SmartScreenEnabled'
        if ($null -eq $value) {
            New-CheckResult -Bereich 'SmartScreen' -Status 'Unbekannt' `
                -Befund 'Kein expliziter Registrierungswert gesetzt (häufig gilt dann die Standardeinstellung: aktiv).' `
                -Empfehlung 'Windows-Sicherheit > App- und Browsersteuerung öffnen und prüfen, dass die Zuverlässigkeitsprüfung aktiv ist.'
        } elseif ($value -eq 'Off') {
            New-CheckResult -Bereich 'SmartScreen' -Status 'Warnung' `
                -Befund 'SmartScreen ist ausgeschaltet.' `
                -Empfehlung 'Windows-Sicherheit > App- und Browsersteuerung öffnen und SmartScreen aktivieren (Phase 3.2).'
        } else {
            New-CheckResult -Bereich 'SmartScreen' -Status 'OK' `
                -Befund "SmartScreen ist aktiv (Modus: $value)." `
                -Empfehlung 'Nichts zu tun.'
        }
    }

$checks += Invoke-SafeCheck -Bereich 'Benutzerkontensteuerung (UAC)' `
    -FallbackEmpfehlung 'Status manuell prüfen: Ausführen-Dialog, dann UserAccountControlSettings eingeben.' `
    -Action {
        $enableLua = Get-RegistryValueOrNull -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableLUA'
        $consent = Get-RegistryValueOrNull -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'ConsentPromptBehaviorAdmin'
        if ($null -eq $enableLua) {
            New-CheckResult -Bereich 'Benutzerkontensteuerung (UAC)' -Status 'Unbekannt' `
                -Befund 'UAC-Einstellung nicht auslesbar.' `
                -Empfehlung 'Ausführen-Dialog öffnen und UserAccountControlSettings eingeben, um den Regler zu prüfen.'
        } elseif ($enableLua -eq 1 -and $consent -ne 0) {
            New-CheckResult -Bereich 'Benutzerkontensteuerung (UAC)' -Status 'OK' `
                -Befund 'UAC ist aktiv und fragt bei Adminrechten nach.' `
                -Empfehlung 'Nichts zu tun.'
        } elseif ($enableLua -eq 1 -and $consent -eq 0) {
            New-CheckResult -Bereich 'Benutzerkontensteuerung (UAC)' -Status 'Warnung' `
                -Befund 'UAC ist aktiv, aber ohne Nachfrage bei Adminrechten.' `
                -Empfehlung 'UserAccountControlSettings öffnen und den Regler mindestens auf die zweithöchste Stufe stellen.'
        } else {
            New-CheckResult -Bereich 'Benutzerkontensteuerung (UAC)' -Status 'Warnung' `
                -Befund 'UAC ist deaktiviert.' `
                -Empfehlung 'UserAccountControlSettings öffnen und UAC aktivieren – zentraler Schutz vor stillen Systemänderungen.'
        }
    }

$checks += Invoke-SafeCheck -Bereich 'Secure Boot' `
    -FallbackEmpfehlung 'Status ohne Adminrechte nicht auslesbar. In msinfo32 die Zeile Sicherer Startzustand prüfen.' `
    -Action {
        if ($null -eq (Get-Command Confirm-SecureBootUEFI -ErrorAction SilentlyContinue)) {
            New-CheckResult -Bereich 'Secure Boot' -Status 'Unbekannt' `
                -Befund 'Prüfbefehl auf diesem System nicht verfügbar.' `
                -Empfehlung 'In msinfo32 die Zeile Sicherer Startzustand prüfen.'
        } elseif (Confirm-SecureBootUEFI) {
            New-CheckResult -Bereich 'Secure Boot' -Status 'OK' `
                -Befund 'Secure Boot ist aktiv.' `
                -Empfehlung 'Nichts zu tun.'
        } else {
            New-CheckResult -Bereich 'Secure Boot' -Status 'Warnung' `
                -Befund 'Secure Boot ist deaktiviert.' `
                -Empfehlung 'Im UEFI/BIOS aktivieren – vorher Phase 2 (Backup) abschließen und die Anleitung des PC-Herstellers lesen.'
        }
    }

$checks += Invoke-SafeCheck -Bereich 'TPM' `
    -FallbackEmpfehlung 'Status ohne Adminrechte oft nicht auslesbar. Ausführen-Dialog: tpm.msc öffnen.' `
    -Action {
        $tpm = Get-CimInstance -Namespace 'root\cimv2\Security\MicrosoftTpm' -ClassName 'Win32_Tpm'
        if ($null -eq $tpm) {
            New-CheckResult -Bereich 'TPM' -Status 'Warnung' `
                -Befund 'Kein TPM gefunden.' `
                -Empfehlung 'Im UEFI/BIOS prüfen, ob das TPM (oft fTPM oder PTT genannt) deaktiviert ist. Windows 11 setzt TPM 2.0 voraus.'
        } elseif ($tpm.IsEnabled_InitialValue -and $tpm.IsActivated_InitialValue) {
            New-CheckResult -Bereich 'TPM' -Status 'OK' `
                -Befund 'TPM ist vorhanden und aktiv.' `
                -Empfehlung 'Nichts zu tun.'
        } else {
            New-CheckResult -Bereich 'TPM' -Status 'Warnung' `
                -Befund 'TPM ist vorhanden, aber nicht aktiv.' `
                -Empfehlung 'tpm.msc öffnen und den Status prüfen; die Aktivierung erfolgt im UEFI/BIOS.'
        }
    }

$checks += Invoke-SafeCheck -Bereich 'Laufwerksverschlüsselung (BitLocker)' `
    -FallbackEmpfehlung 'Status ohne Adminrechte nicht auslesbar. Einstellungen > Datenschutz und Sicherheit > Geräteverschlüsselung prüfen.' `
    -Action {
        $volumes = @(Get-BitLockerVolume)
        $system = @($volumes | Where-Object { $_.VolumeType -eq 'OperatingSystem' })
        $protected = @($system | Where-Object { "$($_.ProtectionStatus)" -eq 'On' })
        if ($system.Count -eq 0) {
            New-CheckResult -Bereich 'Laufwerksverschlüsselung (BitLocker)' -Status 'Unbekannt' `
                -Befund 'Kein Systemlaufwerk im BitLocker-Status gefunden.' `
                -Empfehlung 'Einstellungen > Datenschutz und Sicherheit > Geräteverschlüsselung prüfen.'
        } elseif ($protected.Count -eq $system.Count) {
            New-CheckResult -Bereich 'Laufwerksverschlüsselung (BitLocker)' -Status 'OK' `
                -Befund 'Das Systemlaufwerk ist verschlüsselt.' `
                -Empfehlung 'Wichtig: Der Wiederherstellungsschlüssel muss außerhalb des PCs gesichert sein (Phase 2).'
        } else {
            New-CheckResult -Bereich 'Laufwerksverschlüsselung (BitLocker)' -Status 'Warnung' `
                -Befund 'Das Systemlaufwerk ist nicht verschlüsselt.' `
                -Empfehlung 'Bei Diebstahl sind Daten sonst lesbar. Vor der Aktivierung Phase 2 (Backup und Schlüsselsicherung) abschließen.'
        }
    }

$checks += Invoke-SafeCheck -Bereich 'Update-Stand' `
    -FallbackEmpfehlung 'Einstellungen > Windows Update öffnen und nach Updates suchen.' `
    -Action {
        $dates = @(
            Get-CimInstance -ClassName Win32_QuickFixEngineering |
                ForEach-Object { $_.InstalledOn } |
                Where-Object { $null -ne $_ }
        )
        if ($dates.Count -eq 0) {
            New-CheckResult -Bereich 'Update-Stand' -Status 'Unbekannt' `
                -Befund 'Kein Installationsdatum für Qualitätsupdates auslesbar.' `
                -Empfehlung 'Einstellungen > Windows Update öffnen und den Verlauf prüfen (Phase 3.1).'
        } else {
            $ageDays = [int][math]::Floor(((Get-Date) - ($dates | Sort-Object -Descending | Select-Object -First 1)).TotalDays)
            if ($ageDays -le 45) {
                New-CheckResult -Bereich 'Update-Stand' -Status 'OK' `
                    -Befund "Letztes Qualitätsupdate vor $ageDays Tag(en)." `
                    -Empfehlung 'Nichts zu tun.'
            } else {
                New-CheckResult -Bereich 'Update-Stand' -Status 'Warnung' `
                    -Befund "Letztes Qualitätsupdate vor $ageDays Tagen." `
                    -Empfehlung 'Einstellungen > Windows Update öffnen und alle Sicherheitsupdates installieren (Phase 3.1).'
            }
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
    Interpretation = 'Warnungen sind Prüfaufträge, keine Diagnosen. Unbekannt bedeutet meist: nur mit Adminrechten oder manuell prüfbar. Vor jeder Änderung gilt Phase 2 (Backup).'
}

if (-not [string]::IsNullOrWhiteSpace($HtmlPath)) {
    $fullHtmlPath = [System.IO.Path]::GetFullPath($HtmlPath)
    if (@('.html', '.htm') -notcontains [System.IO.Path]::GetExtension($fullHtmlPath).ToLowerInvariant()) {
        throw 'Der HTML-Pfad muss auf .html oder .htm enden.'
    }
    $parentPath = Split-Path -Parent $fullHtmlPath
    if (-not (Test-Path -LiteralPath $parentPath -PathType Container)) {
        throw "Der Zielordner existiert nicht: $parentPath"
    }
    if ((Test-Path -LiteralPath $fullHtmlPath) -and -not $Force) {
        throw 'Die Ausgabedatei existiert bereits. Zum Überschreiben -Force verwenden.'
    }

    $statusColors = @{ OK = '#1a7f37'; Warnung = '#b35900'; Unbekannt = '#57606a' }
    $rows = foreach ($check in $checks) {
        $color = $statusColors[$check.Status]
        '<tr><td>{0}</td><td style="color:{1};font-weight:bold">{2}</td><td>{3}</td><td>{4}</td></tr>' -f `
            [System.Net.WebUtility]::HtmlEncode($check.Bereich), $color, `
            [System.Net.WebUtility]::HtmlEncode($check.Status), `
            [System.Net.WebUtility]::HtmlEncode($check.Befund), `
            [System.Net.WebUtility]::HtmlEncode($check.Empfehlung)
    }

    $html = @"
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="utf-8">
<title>Sicherheitsbericht Windows 11</title>
<style>
body { font-family: "Segoe UI", Arial, sans-serif; margin: 2rem; color: #1f2328; }
h1 { font-size: 1.4rem; } h2 { font-size: 1.1rem; }
table { border-collapse: collapse; width: 100%; margin-top: 1rem; }
th, td { border: 1px solid #d0d7de; padding: 0.5rem 0.6rem; text-align: left; vertical-align: top; }
th { background: #f6f8fa; }
p.meta { color: #57606a; font-size: 0.9rem; }
@media print { body { margin: 1rem; } }
</style>
</head>
<body>
<h1>Sicherheitsbericht Windows 11</h1>
<p class="meta">Erstellt (UTC): $([System.Net.WebUtility]::HtmlEncode($report.CollectedAtUtc))<br>
$([System.Net.WebUtility]::HtmlEncode($report.PrivacyNotice))</p>
<h2>Zusammenfassung: $($summary.OkCount) OK &middot; $($summary.WarnungCount) Warnung(en) &middot; $($summary.UnbekanntCount) Unbekannt</h2>
<table>
<tr><th>Bereich</th><th>Status</th><th>Befund</th><th>Empfehlung</th></tr>
$($rows -join "`n")
</table>
<p class="meta">$([System.Net.WebUtility]::HtmlEncode($report.Interpretation))</p>
</body>
</html>
"@

    Set-Content -LiteralPath $fullHtmlPath -Value $html -Encoding UTF8
    [pscustomobject]@{
        HtmlPath = $fullHtmlPath
        Bytes = (Get-Item -LiteralPath $fullHtmlPath).Length
    }
} elseif ($AsJson) {
    $report | ConvertTo-Json -Depth 6
} else {
    $report
}
