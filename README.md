# Windows-PC-Guru

Ein sicherer, deutschsprachiger Agent-Skill für Windows 11: Diagnose, Leistungsanalyse, Softwareentscheidung, Datenschutz und Optimierung ohne Tuning-Mythen oder riskante Automatismen.

Der Skill arbeitet symptomorientiert, verlangt vor Änderungen eine konkrete Freigabe und akzeptiert eine Verbesserung erst nach einer passenden Nachmessung.

## Ablaufplan: Maximale Sicherheit und Optimierung – ganz ohne KI

Das Handbuch funktioniert vollständig ohne KI und ohne Zusatzsoftware: Alle
Schritte nutzen Windows-Bordmittel und lassen sich von Hand abarbeiten.
**Reihenfolge einhalten** – jeder Schritt baut auf dem vorherigen auf, und vor
jeder Änderung existiert ein Backup und ein Rückweg. Wenig Zeit? Der
[Schnellstart](SCHNELLSTART.md) liefert den Basisschutz in 60 Minuten. Den
Fortschritt festhalten: [Fortschritts-Checkliste](vorlagen/fortschritts-checkliste.md).

1. **Bestandsaufnahme** – erst lesen, nichts ändern: Hardware, Windows-Stand,
   Programme und Autostart erfassen und in die
   [Checkliste](vorlagen/bestandsaufnahme-checkliste.md) eintragen.
   → [Phase 1](01-bestandsaufnahme.md)
2. **Backup und Rückweg schaffen** – Daten nach dem 3-2-1-Prinzip sichern,
   Wiederherstellungspunkt anlegen, Wiederherstellungslaufwerk erstellen.
   Ohne diesen Schritt beginnt keine Reparatur.
   → [Phase 2](02-backup-plan.md)
3. **Windows aktualisieren und reparieren** – alle Sicherheitsupdates
   installieren, Systemdateien mit `sfc` und `DISM` prüfen, Datenträger und
   Ereignisprotokoll kontrollieren.
   → [Phase 3](03-windows-pruefen-reparieren.md)
4. **Sicherheit prüfen und härten** – Windows-Sicherheit komplett durchgehen:
   Viren- & Bedrohungsschutz, Firewall, SmartScreen, Gerätesicherheit
   (Secure Boot, TPM), BitLocker-Status und Benutzerkonten. Nichts davon
   abschalten – fehlenden Schutz aktivieren.
   → [Phase 3, Abschnitt 3.2](03-windows-pruefen-reparieren.md) und
   [Sicherheits-Audit](skills/windows-pc-guru/references/security-baseline-audit.md)
5. **Treiber gezielt aktualisieren** – nur über Windows Update und offizielle
   Hersteller-Websites, einen Treiber nach dem anderen, mit Neustart und Test
   dazwischen. Keine Driver-Booster.
   → [Phase 4](04-treiber-aktualisieren.md)
6. **Aufräumen und optimieren** – überflüssige Programme nach Freigabe
   deinstallieren, Autostart entschlacken, Speicherplatz freigeben. Keine
   Registry-Cleaner, keine Tuning-Suiten.
   → [Phase 5](05-aufraeumen-optimieren.md)
7. **Dateien ordnen** – Privat und Dienstlich trennen, Fotos sortieren,
   Duplikate finden; verschieben statt löschen.
   → [Phase 6](06-ordnungssystem-dateien.md)
8. **Nachmessen und Wartungsroutine festlegen** – Startzeit und Verhalten mit
   der Bestandsaufnahme vergleichen, danach die feste Routine: monatlich
   30 Minuten, vierteljährlich 60 Minuten – mit lesenden Prüf-Skripten als
   Abkürzung. Optionale seriöse Werkzeuge: [Ressourcen](ressourcen.md)
   → [Phase 7](07-wartungsroutine.md)

## Was er kann

- langsame, instabile oder nicht startende Windows-11-PCs eingrenzen;
- Updates, Treiber, Speicher, Netzwerk, Akku, Autostart, Bluescreens und lokale Toolchains prüfen;
- Programmempfehlungen und klare Ablehnungen mit Begründung geben;
- ungewöhnliche, aber seriöse Diagnosewerkzeuge gezielt einsetzen: Autoruns, WPR/WPA, Process Explorer, Process Monitor und RAMMap;
- Defender-Leistung messen, ohne Schutz pauschal zu schwächen;
- datensparsame System- und Leistungsbaselines erstellen.

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
- Profile: [Büro](skills/windows-pc-guru/profiles/office.md), [Entwicklung](skills/windows-pc-guru/profiles/development.md), [Notebook](skills/windows-pc-guru/profiles/laptop.md), [Spiele](skills/windows-pc-guru/profiles/gaming.md)

## Firmenmodus: lokal ohne Cloud-KI

Für Firmenrechner gibt es den verbindlichen [Firmenmodus Lokal](skills/windows-pc-guru/references/corporate-local-only.md). Er verbietet Cloud-KI, Uploads, Screenshots, Fernwartung und die Auswertung personenbezogener oder vertraulicher Inhalte. Vor der ersten Diagnose:

```powershell
pwsh -NoProfile -File .\scripts\Test-LocalOnlyPolicy.ps1
```

Bei `Allowed : False` nicht weiterarbeiten. Diese Prüfung verhindert typische Netzwerk- und Downloadbefehle in den enthaltenen Diagnose-Skripten, ist aber kein Ersatz für Geräteschutz oder eine interne Datenschutzregel.

## Installation

Für Codex:

```powershell
npx skills add Norman-Wagner/Windows-11-PC-optimieren- --skill windows-pc-guru
```

Alternativ den Ordner `skills/windows-pc-guru` in ein Tool mit Agent-Skills-Unterstützung importieren. Die Skripte werden niemals automatisch ausgeführt.

## Messung und Prüfberichte

```powershell
pwsh -NoProfile -File .\skills\windows-pc-guru\scripts\Measure-OptimizationBaseline.ps1 -AsJson
```

Das Skript verändert nichts und gibt keine Benutzer-, Computer-, Serien-, MAC-, IP-, Prozessnamen-, Dateipfad- oder Netzwerkdaten aus. Für einen gespeicherten Vergleich wird ein vom Nutzer gewählter Zielpfad benötigt.

Zwei weitere lesende Berichte nach denselben Datenschutzregeln:

```powershell
# Schutzstatus mit Bewertung und Empfehlung je Prüfpunkt (Schritt 4 des Ablaufplans)
pwsh -NoProfile -File .\skills\windows-pc-guru\scripts\Get-SecurityBaselineReport.ps1

# Pflegezustand gegen feste Schwellwerte (Phase 7, Wartungsroutine)
pwsh -NoProfile -File .\skills\windows-pc-guru\scripts\Get-MaintenanceStatus.ps1
```

## Roadmap und Qualitätssicherung

Die Weiterentwicklung ist in der [ROADMAP](ROADMAP.md) mit Akzeptanzkriterien
je Funktion dokumentiert, die Umsetzung in der [Aufgabenliste](AUFGABEN.md).
Eine Pester-Testsuite unter [tests/](tests/) führt alle Diagnose-Skripte bei
jedem Push auf echtem Windows aus und belegt: gültiges Schema, keine
Netzwerkzugriffe, keine Dateiänderungen, keine Benutzer- oder Computernamen
in der Ausgabe.

## Repository prüfen

```powershell
pwsh -NoProfile -File .\scripts\Test-Repository.ps1 -RunDiagnosticsSmokeTest
```

Die Prüfung validiert Skill-Metadaten, Referenzen, JSON-Manifeste, PowerShell-Syntax und die lesenden Diagnose-Skripte.

## Lizenz und Verantwortung

Apache License 2.0, siehe [LICENSE.txt](LICENSE.txt). Die Inhalte ersetzen keine Datensicherung, Herstellerfreigabe oder Vor-Ort-Diagnose.
