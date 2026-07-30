# Nützliche Tools und öffentliche Repositories (optionale Ergänzungen)

Das Handbuch kommt vollständig mit Windows-Bordmitteln aus. Die folgenden Tools
sind **optionale** Ergänzungen für einzelne Aufgaben – ausgewählt nach den
Sicherheitsregeln dieses Projekts: offizielle Quellen (Microsoft) oder etablierte
Open-Source-Projekte mit einsehbarem Quellcode. Keine „Tuning-Suiten",
Registry-Cleaner oder Treiber-Booster.

**Installationsregel:** Quelle, exakte Paket-ID, Herausgeber und Signatur
prüfen. WinGet kann mehrere Quellen verwenden und ist kein Beweis, dass jedes
Paket von Microsoft stammt. Nur über WinGet mit bewusst gewählter Quelle oder
die offizielle Projekt-/Herstellerseite installieren – nie über Download-Portale.

---

## Von Microsoft (offiziell)

### Microsoft PowerToys · Open Source

- Repo: <https://github.com/microsoft/PowerToys> · Doku: <https://learn.microsoft.com/de-de/windows/powertoys/>
- Installation erst nach `winget show --id Microsoft.PowerToys --exact` und
  Freigabe: `winget install --id Microsoft.PowerToys --exact --source winget`
- Nützlich für dieses Projekt:
  - **PowerRename** – Massen-Umbenennung mit Suchen/Ersetzen, Regex und Undo –
    ideal für die Foto-Umbenennung nach dem Schema `JJJJ-MM Ereignis` (Phase 6.5).
  - **FancyZones** – Fensterlayouts, hilfreich beim Sortieren mit zwei
    Explorer-Fenstern nebeneinander.
  - **File Locksmith** – zeigt, welcher Prozess eine Datei blockiert
    (praktisch beim Aufräumen, wenn sich etwas „nicht löschen lässt").
  - **Image Resizer** – Fotos direkt im Explorer verkleinern.

### Sysinternals Suite (Microsoft) · kostenlos

- Download: <https://learn.microsoft.com/de-de/sysinternals/>
- Nützlich für dieses Projekt:
  - **Autoruns** – zeigt _alle_ Autostart-Punkte (weit mehr als der Task-Manager);
    nur zur Analyse in Phase 1.6/5.3 verwenden, Einträge deaktivieren statt löschen.
  - **Process Explorer** – detaillierte Sicht auf Hintergrundprozesse (Phase 3.8).

### winget (App-Installer, in Windows 11 enthalten)

- Doku: <https://learn.microsoft.com/de-de/windows/package-manager/winget/>
- Wird im Handbuch bereits für Bestandsaufnahme und gezielte Deinstallation
  genutzt. `winget upgrade` zeigt zunächst Kandidaten. Jedes Paket anschließend
  mit exakter ID und Quelle prüfen und einzeln freigeben; kein unbeaufsichtigtes
  `winget upgrade --all`.

---

## Open Source (Community, Quellcode einsehbar)

### Duplikate finden – czkawka / dupeGuru

- **czkawka**: <https://github.com/qarmin/czkawka> – sehr schneller
  Duplikat-Finder (Rust) mit Vorschau; findet auch _ähnliche_ Bilder, leere
  Ordner und defekte Dateien. Ergänzt das PowerShell-Skript aus Phase 6.3,
  wenn die Sammlung groß ist.
- **dupeGuru**: <https://github.com/arsenetar/dupeguru> – bewährter
  Duplikat-Finder mit Musik- und Bildmodus (perzeptuelles Hashing erkennt
  nahezu identische Fotos).
- ⚠️ Bei beiden gilt Regel 3 des Handbuchs: Funde zuerst als Bericht sichten,
  löschen nur nach ausdrücklicher Freigabe und mit aktuellem Backup.

### Speicherplatz visualisieren – WinDirStat

- Repo: <https://github.com/windirstat/windirstat> ·
  Installation: `winget install WinDirStat.WinDirStat`
- Zeigt grafisch, welche Ordner/Dateitypen den Platz belegen – anschaulicher
  als _Einstellungen → Speicher_ (Phase 5.2). Nur analysieren, nichts direkt
  aus dem Tool heraus löschen.

### Fotoverwaltung – digiKam (lokal)

- **digiKam**: <https://github.com/KDE/digikam> · <https://www.digikam.org/> –
  vollwertige lokale Fotoverwaltung: Verschlagwortung, Metadaten,
  **eingebaute Duplikat-/Ähnlichkeitssuche**, RAW-Unterstützung. Gute Ergänzung
  zu Phase 6.5, wenn die Sammlung fünfstellig wird.

---

## Bewusst NICHT empfohlen

Entsprechend der Sicherheitsregeln des Handbuchs verzichten wir auf:

- **Registry-Cleaner und „Tuning-Suiten"** – minimaler Nutzen, reales Risiko.
- **Treiber-Updater von Drittanbietern** – Treiber kommen nur über Windows
  Update und Hersteller-Websites (Phase 4).
- **Tweak-Skripte, die Windows-Dienste/Telemetrie „entschlacken"** – sie
  verändern Sicherheits- und Update-Funktionen und hinterlassen schwer
  diagnostizierbare Zustände.

---

## Quellen der Recherche

- [Microsoft PowerToys – Microsoft Learn](https://learn.microsoft.com/en-us/windows/powertoys/)
- [PowerRename – Microsoft Learn](https://learn.microsoft.com/en-us/windows/powertoys/powerrename)
- [WinGet – Microsoft Learn](https://learn.microsoft.com/en-us/windows/package-manager/winget/)
- [Sysinternals – Microsoft Learn](https://learn.microsoft.com/en-us/sysinternals/)
- [digiKam – offizielles Projekt](https://www.digikam.org/)
- [Czkawka – offizielles Repository](https://github.com/qarmin/czkawka)
- [dupeGuru – offizielles Repository](https://github.com/arsenetar/dupeguru)
- [WinDirStat – offizielles Repository](https://github.com/windirstat/windirstat)
