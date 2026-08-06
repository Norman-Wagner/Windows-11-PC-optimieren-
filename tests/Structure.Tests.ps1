#requires -Version 5.1
<#
Plattformunabhängige Struktur-Tests: Pflichtdateien, Verbotsmuster in den
Laufzeit-Skripten, Platzhalterfreiheit und Roadmap-Konsistenz.
#>

BeforeAll {
    $script:repositoryRoot = Split-Path -Parent $PSScriptRoot
}

Describe 'Pflichtdateien' {
    It 'enthält <_>' -ForEach @(
        'README.md'
        'ROADMAP.md'
        'AUFGABEN.md'
        'SCHNELLSTART.md'
        'QUICKSTART.md'
        'pinguin-anleitung.html'
        '07-wartungsroutine.md'
        'vorlagen/fortschritts-checkliste.md'
        'vorlagen/vorher-nachher-vergleich.md'
        'skills/windows-pc-guru/SKILL.md'
        'skills/windows-pc-guru/scripts/Get-WindowsPcSnapshot.ps1'
        'skills/windows-pc-guru/scripts/Measure-OptimizationBaseline.ps1'
        'skills/windows-pc-guru/scripts/Get-SecurityBaselineReport.ps1'
        'skills/windows-pc-guru/scripts/Get-MaintenanceStatus.ps1'
        'skills/windows-pc-guru/scripts/Test-DriverPackage.ps1'
        'scripts/Test-Repository.ps1'
        'scripts/Test-LocalOnlyPolicy.ps1'
        'tests/behavior-cases.md'
    ) {
        Join-Path $script:repositoryRoot $_ | Should -Exist
    }
}

Describe 'Laufzeit-Skripte (nur lesend, lokal)' {
    BeforeDiscovery {
        $runtimeDirectory = Join-Path (Split-Path -Parent $PSScriptRoot) 'skills/windows-pc-guru/scripts'
        $runtimeScripts = @(Get-ChildItem -LiteralPath $runtimeDirectory -Filter '*.ps1' -File)
    }

    BeforeAll {
        $script:runtimeScriptCount = @(Get-ChildItem -LiteralPath (
            Join-Path (Split-Path -Parent $PSScriptRoot) 'skills/windows-pc-guru/scripts'
        ) -Filter '*.ps1' -File).Count
    }

    It 'es gibt mindestens fünf Laufzeit-Skripte' {
        $script:runtimeScriptCount | Should -BeGreaterOrEqual 5
    }

    It '<_.Name> enthält keine Netzwerk-, Lösch- oder Fernsteuerungsmuster' -ForEach $runtimeScripts {
        $forbiddenPatterns = @(
            'Invoke-Expression'
            'Invoke-WebRequest'
            'Invoke-RestMethod'
            'Start-BitsTransfer'
            'System.Net.WebClient'
            'System.Net.Http.HttpClient'
            'curl.exe'
            'wget.exe'
            'ftp.exe'
            ('Start-Proc' + 'ess')
            'Enter-PSSession'
            'New-PSSession'
            ('Remove-' + 'Item')
            'Clear-RecycleBin'
            'Set-MpPreference'
            'Disable-WindowsOptionalFeature'
        )
        $scriptText = Get-Content -Raw -Encoding UTF8 -LiteralPath $_.FullName
        foreach ($pattern in $forbiddenPatterns) {
            $scriptText | Should -Not -Match ([regex]::Escape($pattern))
        }
    }

    It '<_.Name> deklariert einen Datenschutzhinweis' -ForEach (
        $runtimeScripts | Where-Object { $_.Name -ne 'Test-DriverPackage.ps1' }
    ) {
        Get-Content -Raw -Encoding UTF8 -LiteralPath $_.FullName |
            Should -Match 'Keine Benutzer-'
    }

    It 'Test-DriverPackage.ps1 erklärt, dass es nichts lädt oder installiert' {
        Get-Content -Raw -Encoding UTF8 -LiteralPath (
            Join-Path (Split-Path -Parent $PSScriptRoot) 'skills/windows-pc-guru/scripts/Test-DriverPackage.ps1'
        ) | Should -Match 'lädt und installiert nichts'
    }
}

Describe 'Neue Dokumente' {
    It '<_> enthält keine Platzhalter' -ForEach @(
        'ROADMAP.md'
        'AUFGABEN.md'
        'SCHNELLSTART.md'
        'QUICKSTART.md'
        '07-wartungsroutine.md'
        'vorlagen/fortschritts-checkliste.md'
        'vorlagen/vorher-nachher-vergleich.md'
    ) {
        $text = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $script:repositoryRoot $_)
        $text | Should -Not -Match '(?i)\bTODO\b|PLACEHOLDER|\bTBD\b'
    }

    It 'die ROADMAP beschreibt die Funktionen F1 bis F6 mit Akzeptanzkriterien' {
        $roadmap = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $script:repositoryRoot 'ROADMAP.md')
        foreach ($feature in 1..6) {
            $roadmap | Should -Match "## F$($feature):"
        }
        ([regex]::Matches($roadmap, '\*\*Akzeptanzkriterien:\*\*')).Count |
            Should -BeGreaterOrEqual 6
    }

    It 'der README-Ablaufplan hat acht Schritte und verlinkt Phase 7 und Schnellstart' {
        $readme = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $script:repositoryRoot 'README.md')
        $readme | Should -Match '## Ablaufplan'
        foreach ($step in 1..8) {
            $readme | Should -Match "(?m)^$step\.\s+\*\*"
        }
        $readme | Should -Match '07-wartungsroutine\.md'
        $readme | Should -Match 'SCHNELLSTART\.md'
    }

    It 'der Schnellstart hat höchstens sieben Schritte' {
        $quickstart = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $script:repositoryRoot 'SCHNELLSTART.md')
        ([regex]::Matches($quickstart, '(?m)^## Schritt \d+')).Count |
            Should -BeLessOrEqual 7
    }

    It 'der englische Quick Start spiegelt den Schnellstart' {
        $quickstartDe = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $script:repositoryRoot 'SCHNELLSTART.md')
        $quickstartEn = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $script:repositoryRoot 'QUICKSTART.md')
        $stepsEn = ([regex]::Matches($quickstartEn, '(?m)^## Step \d+')).Count
        $stepsDe = ([regex]::Matches($quickstartDe, '(?m)^## Schritt \d+')).Count
        $stepsEn | Should -Be $stepsDe
        $quickstartEn | Should -Match 'SCHNELLSTART\.md'
        $quickstartDe | Should -Match 'QUICKSTART\.md'
    }

    It 'die vorlesbare Anleitung lädt nichts nach und greift nicht auf das Netz zu' {
        $page = Get-Content -Raw -Encoding UTF8 -LiteralPath (
            Join-Path $script:repositoryRoot 'pinguin-anleitung.html'
        )

        $page | Should -Match '<!DOCTYPE html>'
        $page | Should -Not -Match 'https?://'
        foreach ($networkApi in @('fetch(', 'XMLHttpRequest', 'WebSocket', 'sendBeacon', 'EventSource', 'importScripts')) {
            $page | Should -Not -Match ([regex]::Escape($networkApi))
        }
        $page | Should -Not -Match '@import'
    }

    It 'die vorlesbare Anleitung verlinkt nur vorhandene Dateien' {
        $page = Get-Content -Raw -Encoding UTF8 -LiteralPath (
            Join-Path $script:repositoryRoot 'pinguin-anleitung.html'
        )

        $targets = [regex]::Matches($page, 'href="([^"#][^"]*)"') |
            ForEach-Object { $_.Groups[1].Value } |
            Sort-Object -Unique

        @($targets).Count | Should -BeGreaterOrEqual 8
        foreach ($target in $targets) {
            Join-Path $script:repositoryRoot $target | Should -Exist
        }
    }

    It 'die vorlesbare Anleitung deckt alle acht Schritte ab und kann sie vorlesen' {
        $page = Get-Content -Raw -Encoding UTF8 -LiteralPath (
            Join-Path $script:repositoryRoot 'pinguin-anleitung.html'
        )

        foreach ($step in 1..8) {
            $page | Should -Match "id=`"s$step`""
            $page | Should -Match "data-say-target=`"s$step`""
        }
        ([regex]::Matches($page, 'data-say=')).Count | Should -BeGreaterOrEqual 12
    }

    It 'die Vergleichsvorlage verspricht keine Pauschal-Referenzwerte' {
        $vergleich = Get-Content -Raw -Encoding UTF8 -LiteralPath (
            Join-Path $script:repositoryRoot 'vorlagen/vorher-nachher-vergleich.md'
        )
        $vergleich | Should -Match 'keine mitgelieferten Referenzwerte'
        $vergleich | Should -Match 'Vorher'
        $vergleich | Should -Match 'Nachher'
    }
}
