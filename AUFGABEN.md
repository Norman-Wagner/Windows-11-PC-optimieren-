# Aufgabenliste zur Umsetzung der [Roadmap](ROADMAP.md)

Jede Aufgabe ist einem Roadmap-Feature (F1–F6) zugeordnet. Erledigte Aufgaben
sind abgehakt; der Beleg ist jeweils die automatisierte Prüfung in der CI
(`validate`- und `tests`-Job auf echtem Windows).

## M1: Planung

- [x] Repository analysieren: Handbuch, Skill, Skripte, Validierung, CI.
- [x] Wertlücken benennen (Sicherheits-Messung, Wartung, Testbeleg).
- [x] `ROADMAP.md` mit Akzeptanzkriterien je Feature schreiben.
- [x] Diese Aufgabenliste anlegen und mit der Roadmap verlinken.

## M2: Diagnose-Skripte (F1, F2)

- [x] F1: `Get-SecurityBaselineReport.ps1` implementieren
  (Defender, Firewall, SmartScreen, UAC, Secure Boot, TPM, BitLocker,
  Update-Stand; je Prüfpunkt `Bereich`/`Status`/`Befund`/`Empfehlung`).
- [x] F1: Fehlertoleranz – fehlende Rechte führen zu `Unbekannt`,
  nie zum Abbruch.
- [x] F2: `Get-MaintenanceStatus.ps1` implementieren
  (Laufzeit seit Neustart, Update-Alter, Signaturalter, freier
  Speicherplatz, Autostart-Anzahl; Schwellwerte dokumentiert im Skript).
- [x] Beide Skripte: `SchemaVersion`, `PrivacyNotice`, `NetworkUsed = false`,
  `FilesChanged = false`, `-AsJson`-Ausgabe.
- [x] Beide Skripte gegen die Verbotsmuster der Lokal-only-Prüfung geprüft.

## M3: Dokumente (F3, F4, F5)

- [x] F3: `07-wartungsroutine.md` – monatliche und vierteljährliche Routine
  mit Zeitangaben, Bordmitteln und Verweisen auf Phase 2/3/5.
- [x] F4: `SCHNELLSTART.md` – Basisschutz in 60 Minuten, max. 7 Schritte,
  mit Abgrenzung zum vollständigen Ablaufplan.
- [x] F5: `vorlagen/fortschritts-checkliste.md` – alle 8 Schritte des
  Ablaufplans als druckbare Checkliste mit Datums- und Notizfeldern.
- [x] README aktualisieren: Schnellstart und Roadmap verlinken, Schritt 8
  des Ablaufplans auf Phase 7 zeigen lassen.

## M4: Tests und CI (F6)

- [x] `tests/Structure.Tests.ps1` – plattformunabhängig: Pflichtdateien,
  Verbotsmuster in Laufzeit-Skripten, Platzhalterfreiheit der neuen Dokumente.
- [x] `tests/Diagnostics.Tests.ps1` – nur Windows: führt alle vier
  Diagnose-Skripte aus und prüft JSON-Schema, Datenschutzfelder,
  erlaubte Statuswerte und dass weder Benutzer- noch Computername
  in der Ausgabe vorkommen.
- [x] `Test-Repository.ps1`: neue Pflichtdateien aufnehmen, Smoke-Test um
  F1/F2 erweitern.
- [x] CI-Workflow: zusätzlicher `tests`-Job (Pester auf `windows-latest`)
  bei jedem Push und Pull Request.

## Offene Ideen (nicht Teil dieser Roadmap)

- [ ] Sammlung anonymisierter Vorher/Nachher-Baselines als Referenzwerte.
- [ ] Übersetzung des Schnellstarts ins Englische.
- [ ] HTML-Export des Sicherheitsberichts für den Ausdruck.
