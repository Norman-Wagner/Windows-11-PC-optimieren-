# Windows-PC-Guru

Ein sicherer, deutschsprachiger Agent-Skill für Windows 11: Diagnose, Leistungsanalyse, Softwareentscheidung, Datenschutz und Optimierung ohne Tuning-Mythen oder riskante Automatismen.

Der Skill arbeitet symptomorientiert, verlangt vor Änderungen eine konkrete Freigabe und akzeptiert eine Verbesserung erst nach einer passenden Nachmessung.

## Was er kann

- langsame, instabile oder nicht startende Windows-11-PCs eingrenzen;
- Updates, Treiber, Speicher, Netzwerk, Akku, Autostart, Bluescreens und lokale Toolchains prüfen;
- Programmempfehlungen und klare Ablehnungen mit Begründung geben;
- ungewöhnliche, aber seriöse Diagnosewerkzeuge gezielt einsetzen: Autoruns, WPR/WPA, Process Explorer, Process Monitor und RAMMap;
- Defender-Leistung messen, ohne Schutz pauschal zu schwächen;
- datensparsame System- und Leistungsbaselines erstellen;
- einen versionierten Snapshot 2.0 mit Diagnosegruppen erzeugen;
- Snapshots mit deterministischen Regeln auf Auffälligkeiten prüfen, ohne diese als bestätigte Ursache auszugeben.

## Was er bewusst nicht tut

- keine Registry-Cleaner, Driver-Booster, RAM-Booster, Debloat- oder Game-Booster-Skripte;
- kein Abschalten von Defender, Firewall, SmartScreen, Secure Boot, BitLocker oder Signaturprüfung;
- keine Löschung, Installation, Treiber-, BIOS-, BitLocker- oder Partitionsänderung ohne Zustimmung und Rückweg;
- kein Zugriff auf E-Mails, Browserdaten oder persönliche Dateien als Teil einer normalen PC-Diagnose;
- keine erfundenen Diagnosen oder behaupteten Verbesserungen.

## Kernmaterial

Der kanonische Skill liegt unter [skills/windows-pc-guru](skills/windows-pc-guru/).

- [Entscheidungsmatrix](skills/windows-pc-guru/references/optimization-decision-matrix.md)
- [Programmkatalog](skills/windows-pc-guru/references/software-catalog.md)
- [Erweiterte Diagnose](skills/windows-pc-guru/references/advanced-diagnostics.md)
- [Sicherheits- und Datenschutz-Audit](skills/windows-pc-guru/references/security-baseline-audit.md)
- [Snapshot-Schema 2.0](skills/windows-pc-guru/schemas/windows-pc-snapshot.schema.json)
- [Deterministische Findings Engine](skills/windows-pc-guru/engine/Diagnostics/Invoke-DiagnosticRules.ps1)
- Profile: [Büro](skills/windows-pc-guru/profiles/office.md), [Entwicklung](skills/windows-pc-guru/profiles/development.md), [Notebook](skills/windows-pc-guru/profiles/laptop.md), [Spiele](skills/windows-pc-guru/profiles/gaming.md)

## Firmenmodus: lokal ohne Cloud-KI

Für Firmenrechner gibt es den verbindlichen [Firmenmodus Lokal](skills/windows-pc-guru/references/corporate-local-only.md). Er verbietet Cloud-KI, Uploads, Screenshots, Fernwartung und die Auswertung personenbezogener oder vertraulicher Inhalte. Vor der ersten Diagnose:

```powershell
pwsh -NoProfile -File .\scripts\Test-LocalOnlyPolicy.ps1
```

Bei `Allowed : False` nicht weiterarbeiten. Diese Prüfung erfasst die Diagnose-Skripte und die Findings Engine. Sie verhindert typische Netzwerk-, Download-, Fernsteuerungs- und Löschbefehle, ist aber kein Ersatz für Geräteschutz oder eine interne Datenschutzregel.

## Installation

Für Codex:

```powershell
npx skills add Norman-Wagner/Windows-11-PC-optimieren- --skill windows-pc-guru
```

Alternativ den Ordner `skills/windows-pc-guru` in ein Tool mit Agent-Skills-Unterstützung importieren. Die Skripte werden niemals automatisch ausgeführt.

## Snapshot und Findings

Snapshot 2.0 erzeugen:

```powershell
pwsh -NoProfile -File .\skills\windows-pc-guru\scripts\Get-WindowsPcSnapshot.ps1 -AsJson
```

Einen gespeicherten Snapshot regelbasiert auswerten:

```powershell
pwsh -NoProfile -File .\skills\windows-pc-guru\engine\Diagnostics\Invoke-DiagnosticRules.ps1 -SnapshotPath .\snapshot.json -AsJson
```

Ein Finding enthält Evidenz, Schweregrad und Confidence. `IsConfirmedCause` bleibt immer `false`; die Engine liefert Auffälligkeiten und nächste Prüfhinweise, keinen automatischen Kausalitätsbeweis.

## Messung

```powershell
pwsh -NoProfile -File .\skills\windows-pc-guru\scripts\Measure-OptimizationBaseline.ps1 -AsJson
```

Das Skript verändert nichts und gibt keine Benutzer-, Computer-, Serien-, MAC-, IP-, Prozessnamen-, Dateipfad- oder Netzwerkdaten aus. Für einen gespeicherten Vergleich wird ein vom Nutzer gewählter Zielpfad benötigt.

## Repository prüfen

```powershell
pwsh -NoProfile -File .\scripts\Test-Repository.ps1 -RunDiagnosticsSmokeTest
Invoke-Pester -Path .\tests -CI -Output Detailed
```

Die GitHub-Actions-Pipeline validiert Repository-Struktur, PowerShell-Syntax, lokale Datenschutzregeln, Snapshot 2.0, Findings Engine, PSScriptAnalyzer und Pester-Tests.

## Lizenz und Verantwortung

Apache License 2.0, siehe [LICENSE.txt](LICENSE.txt). Die Inhalte ersetzen keine Datensicherung, Herstellerfreigabe oder Vor-Ort-Diagnose.
