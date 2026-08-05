# Vorher/Nachher-Vergleich: Verbesserungen belegen statt behaupten

Dieses Projekt akzeptiert eine Verbesserung erst nach einer passenden
Nachmessung. Diese Vorlage hält beide Messungen nebeneinander fest.
Es gibt bewusst **keine mitgelieferten Referenzwerte** – jeder PC ist anders;
der einzige faire Vergleich ist derselbe PC vorher und nachher.

**Messregeln für einen fairen Vergleich:**

- Beide Messungen im selben Zustand: gleicher Strommodus (Netzteil oder
  Akku), nach vollständigem Neustart plus fünf Minuten Ruhe, ohne offene
  Programme.
- Die Vorher-Messung gehört an das Ende von
  [Phase 1](../01-bestandsaufnahme.md), die Nachher-Messung an das Ende von
  [Phase 5](../05-aufraeumen-optimieren.md).
- Baseline speichern (Zielpfad selbst wählen, Beispiel):

```powershell
pwsh -NoProfile -File .\skills\windows-pc-guru\scripts\Measure-OptimizationBaseline.ps1 -OutputPath "$env:USERPROFILE\Documents\baseline-vorher.json"
```

---

**PC / Gerät:** ______________________

| Messwert | Quelle | Vorher (Datum: ________) | Nachher (Datum: ________) |
|---|---|---|---|
| Startzeit bis Desktop nutzbar (Stoppuhr, Sekunden) | von Hand gemessen | | |
| Freier Arbeitsspeicher nach Neustart (`FreePhysicalMemoryMiB`) | Baseline-JSON | | |
| CPU-Last im Leerlauf (`PercentProcessorTime`) | Baseline-JSON | | |
| Prozessor-Warteschlange (`ProcessorQueueLength`) | Baseline-JSON | | |
| Anzahl Autostart-Einträge (`StartupCommandCount`) | Baseline-JSON | | |
| Freier Speicherplatz `C:` (`FreeGiB` / `FreePercent`) | Baseline-JSON | | |
| Sicherheitsbericht: Anzahl Warnungen | `Get-SecurityBaselineReport.ps1` | | |
| Wartungsbericht: Anzahl Warnungen | `Get-MaintenanceStatus.ps1` | | |

**Subjektiver Eindruck (ehrlich notieren, auch wenn er „kein Unterschied" lautet):**

- Vorher: ________________________________________________________________
- Nachher: _______________________________________________________________

**Bewertung:** Eine Änderung unterhalb der normalen Schwankung (Startzeit
±10 %, Speicherwerte ±5 %) ist kein belegter Erfolg. Zählbare Werte
(Autostart-Einträge, Warnungen, freier Speicherplatz) sind die
verlässlichsten Belege.
