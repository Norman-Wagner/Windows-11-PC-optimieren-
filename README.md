# Windows-11-PC: Reparatur, Aufräumen, Optimierung und Neuorganisation

Dieses Handbuch führt Schritt für Schritt durch die sichere Reparatur, Bereinigung,
Optimierung und Neuorganisation eines Windows-11-PCs – ausschließlich mit
Windows-Bordmitteln und offiziellen Herstellerquellen.

## Ziele

- Der PC läuft stabil und fehlerfrei.
- Alle Treiber sind aktuell und stammen aus offiziellen Quellen.
- Unnötige Programme und Daten sind (nach Freigabe) entfernt.
- Die Leistung ist so hoch wie möglich – ohne riskante Eingriffe.
- Private und dienstliche Dateien sind klar getrennt.
- Fotos und Videos sind übersichtlich sortiert.
- Doppelte und dreifache Dateien sind erkannt und dokumentiert.
- Es existiert ein langfristig verständliches Ordnungssystem.

## Sicherheitsregeln (gelten für alle Phasen)

1. **Erst Bestandsaufnahme, dann Handeln.** Kein Eingriff ohne vollständiges Bild.
2. **Erst Backup, dann Änderung.** Vor jedem Eingriff muss ein funktionierender
   Backup- und Wiederherstellungsplan stehen (siehe [Phase 2](02-backup-plan.md)).
3. **Nichts wird gelöscht oder deinstalliert ohne ausdrückliche Zustimmung.**
   Jede Lösch-Empfehlung ist als Vorschlag markiert und wartet auf Freigabe.
4. **Keine dubiosen Tuning-, Treiber- oder Registry-Programme.** Es kommen nur
   Windows-Bordmittel, Microsoft-Tools (inkl. Sysinternals) und offizielle
   Hersteller-Websites zum Einsatz.
5. **Risiken werden vorab benannt.** Jeder Schritt mit möglichen Nebenwirkungen
   trägt einen ⚠️-Hinweis mit Erklärung der Folgen.
6. **BIOS, Registry, Partitionen und Sicherheitseinstellungen bleiben unangetastet**,
   sofern nicht zwingend erforderlich – und dann nur mit vorheriger Warnung.
7. **Windows Defender, Firewall und Sicherheitsfunktionen bleiben aktiv.**
8. **Persönliche Dateien werden nur nach Rückfrage verschoben, umbenannt oder
   zusammengeführt.** Bis dahin: nur analysieren und dokumentieren.

## Aufbau des Handbuchs

| Phase | Dokument                                                                           | Inhalt                                                                   |
| ----- | ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| 1     | [01-bestandsaufnahme.md](01-bestandsaufnahme.md)                                   | Hardware, Software, Fehler und Daten erfassen; priorisierte Problemliste |
| 2     | [02-backup-plan.md](02-backup-plan.md)                                             | Backup- und Wiederherstellungsplan **vor** allen Eingriffen              |
| 3     | [03-windows-pruefen-reparieren.md](03-windows-pruefen-reparieren.md)               | Windows mit Bordmitteln prüfen und reparieren                            |
| 4     | [04-treiber-aktualisieren.md](04-treiber-aktualisieren.md)                         | Treiber in sicherer Reihenfolge aktualisieren                            |
| 5     | [05-aufraeumen-optimieren.md](05-aufraeumen-optimieren.md)                         | Programme, Autostart, Speicherplatz und Energieprofil optimieren         |
| 6     | [06-ordnungssystem-dateien.md](06-ordnungssystem-dateien.md)                       | Privat/Dienstlich trennen, Fotos/Videos sortieren, Duplikate finden      |
| –     | [vorlagen/bestandsaufnahme-checkliste.md](vorlagen/bestandsaufnahme-checkliste.md) | Ausfüllbare Checkliste für Phase 1                                       |
| –     | [vorlagen/problemliste.md](vorlagen/problemliste.md)                               | Vorlage für die priorisierte Problemliste                                |
| –     | [ressourcen.md](ressourcen.md)                                                     | Optionale Tools: Microsoft- und Open-Source-Ergänzungen                  |
| –     | [ki-assistent/SKILL.md](ki-assistent/SKILL.md)                                     | Allgemeiner KI-Skill/Prompt für ChatGPT, Claude und Perplexity           |

## Arbeitsweise

- **Ein Befehl nach dem anderen.** Jeder Befehl steht einzeln, mit kurzer
  Erklärung, was er bewirkt, und dem Hinweis, ob Administratorrechte nötig sind.
- **Eingabeaufforderung vs. PowerShell:** Wo nicht anders angegeben, funktionieren
  die Befehle im **Windows Terminal** (Rechtsklick auf Start → „Terminal (Administrator)"
  für Admin-Befehle, sonst „Terminal").
- **Ergebnisse notieren.** Die Ausgaben der Bestandsaufnahme in die
  Checklisten-Vorlagen eintragen – sie sind die Grundlage aller späteren Entscheidungen.
- **Reihenfolge einhalten.** Erst Phase 1 und 2 vollständig abschließen, bevor in
  Phase 3–6 etwas am System verändert wird.
