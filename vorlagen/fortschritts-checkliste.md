# Fortschritts-Checkliste: Der gesamte Ablaufplan zum Abhaken

Zum Ausdrucken oder digitalen Abhaken. Die Schritte entsprechen dem
[Ablaufplan in der README](../README.md); jeder Schritt verlinkt die
ausführliche Anleitung. Reihenfolge einhalten.

**PC / Gerät:** ______________________  **Begonnen am:** ______________

---

## Schritt 1: Bestandsaufnahme ([Phase 1](../01-bestandsaufnahme.md))

- [ ] Hersteller, Modell, CPU, RAM, BIOS-Version notiert (`msinfo32`)
- [ ] Windows-Version und -Build notiert (`winver`)
- [ ] Datenträger und Füllstände notiert
- [ ] Programmliste erstellt
- [ ] Autostart-Liste erstellt
- [ ] [Bestandsaufnahme-Checkliste](bestandsaufnahme-checkliste.md) vollständig
- [ ] [Problemliste](problemliste.md) angelegt

Erledigt am: ______________  Notizen: ________________________________

## Schritt 2: Backup und Rückweg ([Phase 2](../02-backup-plan.md))

- [ ] Wichtige Daten extern gesichert (Documents, Desktop, Pictures …)
- [ ] Sicherung stichprobenartig geprüft (Dateien lassen sich öffnen)
- [ ] Wiederherstellungspunkt angelegt
- [ ] Wiederherstellungslaufwerk (USB) erstellt
- [ ] BitLocker-Wiederherstellungsschlüssel extern gesichert (falls aktiv)

Erledigt am: ______________  Notizen: ________________________________

## Schritt 3: Windows aktualisieren und reparieren ([Phase 3](../03-windows-pruefen-reparieren.md))

- [ ] Windows Update vollständig durchlaufen (bis „auf dem neuesten Stand")
- [ ] Systemdateien geprüft (`sfc /scannow`)
- [ ] Komponentenspeicher geprüft (`DISM /Online /Cleanup-Image /ScanHealth`)
- [ ] Datenträger geprüft
- [ ] Ereignisprotokoll auf wiederkehrende Fehler durchgesehen

Erledigt am: ______________  Notizen: ________________________________

## Schritt 4: Sicherheit prüfen und härten ([Phase 3.2](../03-windows-pruefen-reparieren.md) / [Audit](../skills/windows-pc-guru/references/security-baseline-audit.md))

- [ ] Viren- & Bedrohungsschutz: aktiv und grün
- [ ] Firewall: für alle Netzwerkprofile aktiv
- [ ] App- & Browsersteuerung (SmartScreen): aktiv
- [ ] Gerätesicherheit: Secure Boot und TPM aktiv
- [ ] Laufwerksverschlüsselung geprüft, Schlüssel gesichert
- [ ] Benutzerkonten: Zwei-Faktor-Anmeldung fürs Microsoft-Konto aktiv
- [ ] Optional: Sicherheitsbericht ohne Warnungen
      (`Get-SecurityBaselineReport.ps1`)

Erledigt am: ______________  Notizen: ________________________________

## Schritt 5: Treiber gezielt aktualisieren ([Phase 4](../04-treiber-aktualisieren.md))

- [ ] Optionale Treiber-Updates aus Windows Update geprüft
- [ ] Hersteller-Website auf Sicherheitsupdates geprüft
- [ ] Jeden Treiber einzeln installiert, mit Neustart und Test danach
- [ ] Rückweg getestet bzw. bekannt (Vorheriger Treiber / Wiederherstellung)

Erledigt am: ______________  Notizen: ________________________________

## Schritt 6: Aufräumen und optimieren ([Phase 5](../05-aufraeumen-optimieren.md))

- [ ] Programm-Kandidatenliste erstellt und durchgesprochen
- [ ] Freigegebene Programme einzeln deinstalliert
- [ ] Autostart entschlackt (deaktiviert, nicht gelöscht)
- [ ] Speicherplatz mit Bordmitteln freigegeben

Erledigt am: ______________  Notizen: ________________________________

## Schritt 7: Dateien ordnen ([Phase 6](../06-ordnungssystem-dateien.md))

- [ ] Zielstruktur festgelegt (Privat / Dienstlich)
- [ ] Dateien verschoben (nicht gelöscht), Struktur geprüft
- [ ] Fotos sortiert, Duplikate identifiziert
- [ ] Erst nach Prüfung und frischem Backup gelöscht

Erledigt am: ______________  Notizen: ________________________________

## Schritt 8: Nachmessen und Wartungsroutine ([Phase 7](../07-wartungsroutine.md))

- [ ] Vorher/Nachher verglichen (Startzeit, Verhalten, Baseline)
- [ ] Monatliche Routine in den Kalender eingetragen
- [ ] Vierteljährliche Routine in den Kalender eingetragen
- [ ] Erste monatliche Routine durchgeführt

Erledigt am: ______________  Notizen: ________________________________

---

**Alles abgehakt?** Dann gilt ab jetzt nur noch [Phase 7](../07-wartungsroutine.md):
30 Minuten im Monat statt eines Wochenendes im Jahr.
