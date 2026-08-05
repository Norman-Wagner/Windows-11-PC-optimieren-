# Phase 7: Wartungsroutine – damit es so bleibt

**Ziel:** Sicherheit und Leistung erhalten. Ohne feste Routine verfällt jede
Optimierung innerhalb weniger Monate: Updates bleiben liegen, der Autostart
wächst, Backups veralten unbemerkt.

**Grundsatz:** Die Routine ist rein prüfend. Für alles, was dabei auffällt,
gelten weiterhin die Regeln der jeweiligen Phase – erst Backup und Freigabe,
dann ändern.

---

## Monatliche Routine (etwa 30 Minuten)

- [ ] **Neustart durchführen** – vollständig, kein Energiesparmodus. Damit
  werden ausstehende Updates fertig installiert. _(2 Minuten + Wartezeit)_
- [ ] **Windows Update prüfen:** _Einstellungen → Windows Update → Nach
  Updates suchen_, alles installieren, bei Bedarf erneut neu starten
  ([Phase 3.1](03-windows-pruefen-reparieren.md)). _(10 Minuten)_
- [ ] **Schutzstatus prüfen:** _Windows-Sicherheit_ öffnen – alle Bereiche
  müssen grün sein ([Phase 3.2](03-windows-pruefen-reparieren.md)). _(5 Minuten)_
- [ ] **Backup prüfen:** Liegt die letzte Sicherung höchstens einen Monat
  zurück? Stichprobe: eine Datei aus dem Backup öffnen
  ([Phase 2](02-backup-plan.md)). _(10 Minuten)_
- [ ] **Speicherplatz prüfen:** Im Explorer unter _Dieser PC_ – unter 15 %
  frei ist ein Handlungssignal ([Phase 5.4](05-aufraeumen-optimieren.md)). _(2 Minuten)_

**Abkürzung mit Skript (optional, keine Adminrechte, nur lesend):**

```powershell
pwsh -NoProfile -File .\skills\windows-pc-guru\scripts\Get-MaintenanceStatus.ps1
```

Das Skript bewertet Neustart-, Update- und Signaturalter, Speicherplatz und
Autostart gegen feste Schwellwerte und nennt zu jeder Warnung den passenden
Handbuch-Abschnitt. Es ändert nichts.

## Vierteljährliche Routine (etwa 60 Minuten)

- [ ] **Monatliche Routine** zuerst vollständig durchgehen.
- [ ] **Sicherheitsbericht erstellen** (nur lesend):

  ```powershell
  pwsh -NoProfile -File .\skills\windows-pc-guru\scripts\Get-SecurityBaselineReport.ps1
  ```

  Jede Warnung mit der genannten Empfehlung abarbeiten – eine nach der
  anderen, mit den Regeln aus [Phase 3.2](03-windows-pruefen-reparieren.md).
- [ ] **Autostart durchsehen:** Task-Manager → _Autostart von Apps_ – neue
  Einträge seit dem letzten Mal? Nicht Benötigtes deaktivieren
  ([Phase 5.3](05-aufraeumen-optimieren.md)).
- [ ] **Programme durchsehen:** _Einstellungen → Apps_ – seit Monaten
  Unbenutztes auf die Kandidatenliste ([Phase 5.1](05-aufraeumen-optimieren.md)).
- [ ] **Wiederherstellungspunkt prüfen:** `systempropertiesprotection` –
  ist der Schutz für `C:` aktiv? ([Phase 2](02-backup-plan.md))
- [ ] **Treiber nur bei Problemen:** Kein Routine-Update. Nur wenn ein
  konkretes Problem besteht, nach [Phase 4](04-treiber-aktualisieren.md)
  vorgehen.

## Jährlich zusätzlich (etwa 30 Minuten)

- [ ] **Backup-Strategie überdenken:** Reicht der Platz? Funktioniert die
  externe Platte? Eine Testwiederherstellung durchführen ([Phase 2](02-backup-plan.md)).
- [ ] **Windows-Version prüfen:** `winver` – wird die installierte Version
  noch mit Sicherheitsupdates versorgt? Funktionsupdates gezielt und mit
  Backup einplanen ([Phase 3.1](03-windows-pruefen-reparieren.md)).
- [ ] **Ordnungssystem pflegen:** Neue Dateien in die Struktur aus
  [Phase 6](06-ordnungssystem-dateien.md) einsortieren, statt den Desktop
  wachsen zu lassen.

---

**Merksatz:** Ein gepflegter PC braucht 30 Minuten im Monat. Ein
vernachlässigter PC braucht irgendwann ein Wochenende – oder Phase 1 bis 6
komplett von vorn.
