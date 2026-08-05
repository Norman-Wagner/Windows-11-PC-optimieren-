#requires -Version 5.1
<#
Funktionstests auf echtem Windows: führt alle Diagnose-Skripte aus und belegt
die Sicherheitsversprechen – gültiges Schema, kein Netzwerkzugriff, keine
Dateiänderung, keine Benutzer- oder Computernamen in der Ausgabe.
Auf anderen Betriebssystemen werden diese Tests übersprungen.
#>

BeforeDiscovery {
    $script:onWindows = ($env:OS -eq 'Windows_NT')
}

BeforeAll {
    $script:repositoryRoot = Split-Path -Parent $PSScriptRoot
    $script:skillScriptsPath = Join-Path $script:repositoryRoot 'skills/windows-pc-guru/scripts'

    function Assert-PrivacyInvariants {
        param(
            [Parameter(Mandatory = $true)][string]$Json,
            [Parameter(Mandatory = $true)]$Parsed
        )

        $Parsed.SchemaVersion | Should -Be '1.0'
        $Parsed.PrivacyNotice | Should -Match 'Keine Benutzer'
        $Parsed.NetworkUsed | Should -BeFalse
        $Parsed.FilesChanged | Should -BeFalse

        foreach ($name in @($env:USERNAME, $env:COMPUTERNAME)) {
            if (-not [string]::IsNullOrWhiteSpace($name) -and $name.Length -ge 4) {
                $Json | Should -Not -Match ([regex]::Escape($name))
            }
        }
    }

    function Assert-CheckReport {
        param([Parameter(Mandatory = $true)]$Parsed)

        $checks = @($Parsed.Checks)
        $checks.Count | Should -BeGreaterOrEqual 5
        foreach ($check in $checks) {
            $check.Status | Should -BeIn @('OK', 'Warnung', 'Unbekannt')
            $check.Bereich | Should -Not -BeNullOrEmpty
            $check.Befund | Should -Not -BeNullOrEmpty
            $check.Empfehlung | Should -Not -BeNullOrEmpty
        }

        $summary = $Parsed.Summary
        $summary.CheckCount | Should -Be $checks.Count
        ($summary.OkCount + $summary.WarnungCount + $summary.UnbekanntCount) |
            Should -Be $checks.Count
    }
}

Describe 'Sicherheitsbericht (Get-SecurityBaselineReport.ps1)' -Skip:(-not $script:onWindows) {
    BeforeAll {
        $script:securityJson = & (Join-Path $script:skillScriptsPath 'Get-SecurityBaselineReport.ps1') -AsJson |
            Out-String
        $script:securityReport = $script:securityJson | ConvertFrom-Json
    }

    It 'liefert gültiges JSON mit Schema, Datenschutz- und Read-only-Feldern' {
        Assert-PrivacyInvariants -Json $script:securityJson -Parsed $script:securityReport
    }

    It 'bewertet jeden Prüfpunkt mit erlaubtem Status und Empfehlung' {
        Assert-CheckReport -Parsed $script:securityReport
    }

    It 'exportiert einen druckbaren HTML-Bericht ohne Namen und mit Überschreibschutz' {
        $htmlPath = Join-Path $TestDrive 'sicherheitsbericht.html'
        $result = & (Join-Path $script:skillScriptsPath 'Get-SecurityBaselineReport.ps1') -HtmlPath $htmlPath
        $result.HtmlPath | Should -Be $htmlPath
        $htmlPath | Should -Exist

        $html = Get-Content -Raw -Encoding UTF8 -LiteralPath $htmlPath
        $html | Should -Match '<!DOCTYPE html>'
        $html | Should -Match 'Sicherheitsbericht Windows 11'
        $html | Should -Match 'Zusammenfassung'
        $html | Should -Not -Match '<script'
        $html | Should -Not -Match 'https?://'
        foreach ($name in @($env:USERNAME, $env:COMPUTERNAME)) {
            if (-not [string]::IsNullOrWhiteSpace($name) -and $name.Length -ge 4) {
                $html | Should -Not -Match ([regex]::Escape($name))
            }
        }

        { & (Join-Path $script:skillScriptsPath 'Get-SecurityBaselineReport.ps1') -HtmlPath $htmlPath } |
            Should -Throw -ExpectedMessage '*-Force*'
        { & (Join-Path $script:skillScriptsPath 'Get-SecurityBaselineReport.ps1') -HtmlPath (Join-Path $TestDrive 'bericht.txt') } |
            Should -Throw -ExpectedMessage '*.html*'
    }

    It 'prüft die zentralen Sicherheitsbereiche' {
        $bereiche = @($script:securityReport.Checks | ForEach-Object { $_.Bereich })
        ($bereiche -join ' ') | Should -Match 'Defender'
        ($bereiche -join ' ') | Should -Match 'Firewall'
        ($bereiche -join ' ') | Should -Match 'SmartScreen'
        ($bereiche -join ' ') | Should -Match 'UAC'
        ($bereiche -join ' ') | Should -Match 'Secure Boot'
        ($bereiche -join ' ') | Should -Match 'TPM'
        ($bereiche -join ' ') | Should -Match 'BitLocker'
        ($bereiche -join ' ') | Should -Match 'Update'
    }
}

Describe 'Wartungsbericht (Get-MaintenanceStatus.ps1)' -Skip:(-not $script:onWindows) {
    BeforeAll {
        $script:maintenanceJson = & (Join-Path $script:skillScriptsPath 'Get-MaintenanceStatus.ps1') -AsJson |
            Out-String
        $script:maintenanceReport = $script:maintenanceJson | ConvertFrom-Json
    }

    It 'liefert gültiges JSON mit Schema, Datenschutz- und Read-only-Feldern' {
        Assert-PrivacyInvariants -Json $script:maintenanceJson -Parsed $script:maintenanceReport
    }

    It 'bewertet jeden Prüfpunkt mit erlaubtem Status und Empfehlung' {
        Assert-CheckReport -Parsed $script:maintenanceReport
    }

    It 'misst Neustart, Updates, Signaturen, Speicherplatz und Autostart' {
        $bereiche = @($script:maintenanceReport.Checks | ForEach-Object { $_.Bereich })
        ($bereiche -join ' ') | Should -Match 'Neustart'
        ($bereiche -join ' ') | Should -Match 'Qualitätsupdates'
        ($bereiche -join ' ') | Should -Match 'Signaturen'
        ($bereiche -join ' ') | Should -Match 'Speicherplatz'
        ($bereiche -join ' ') | Should -Match 'Autostart'
    }
}

Describe 'Bestehende Diagnose-Skripte' -Skip:(-not $script:onWindows) {
    It 'der System-Snapshot hält die Datenschutzzusagen ein' {
        $json = & (Join-Path $script:skillScriptsPath 'Get-WindowsPcSnapshot.ps1') -AsJson | Out-String
        Assert-PrivacyInvariants -Json $json -Parsed ($json | ConvertFrom-Json)
    }

    It 'die Leistungs-Baseline hält die Datenschutzzusagen ein' {
        $json = & (Join-Path $script:skillScriptsPath 'Measure-OptimizationBaseline.ps1') -AsJson | Out-String
        Assert-PrivacyInvariants -Json $json -Parsed ($json | ConvertFrom-Json)
    }

    It 'die Paketprüfung liefert einen SHA-256-Wert ohne Installation' {
        $target = Join-Path $script:skillScriptsPath 'Test-DriverPackage.ps1'
        $result = & $target -LiteralPath $target -AsJson | Out-String | ConvertFrom-Json
        $result.SHA256 | Should -Match '^[A-F0-9]{64}$'
        $result.NetworkUsed | Should -BeFalse
        $result.InstalledAnything | Should -BeFalse
    }

    It 'die Lokal-only-Prüfung erlaubt alle Laufzeit-Skripte' {
        $policy = & (Join-Path $script:repositoryRoot 'scripts/Test-LocalOnlyPolicy.ps1') -AsJson |
            Out-String | ConvertFrom-Json
        $policy.Allowed | Should -BeTrue
        $policy.ScriptsChecked | Should -BeGreaterOrEqual 5
    }
}
