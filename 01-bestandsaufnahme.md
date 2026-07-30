# Phase 1: Bestandsaufnahme

**Ziel:** Ein vollständiges Bild des PCs, bevor irgendetwas verändert wird.
In dieser Phase wird **nichts installiert, gelöscht oder geändert** – nur gelesen
und notiert. Alle Ergebnisse in die
[Bestandsaufnahme-Checkliste](vorlagen/bestandsaufnahme-checkliste.md) eintragen.

---

## 1.1 PC-Hersteller, Modell und Grundausstattung

**Schritt 1 – Systemübersicht öffnen (grafisch, keine Adminrechte):**

```
msinfo32
```

_Ausführen über: Windows-Taste + R, dann `msinfo32` eingeben._
Zeigt Hersteller, Modell, BIOS-Version, Prozessor, RAM und Windows-Build auf einen
Blick. Die Zeilen **Systemhersteller**, **Systemmodell**, **Prozessor**,
**Installierter physischer Speicher (RAM)** und **BIOS-Version/-Datum** notieren.

**Schritt 2 – Dieselben Daten als Text zum Kopieren (keine Adminrechte):**

```powershell
Get-ComputerInfo | Select-Object CsManufacturer, CsModel, CsProcessors, CsTotalPhysicalMemory, OsName, OsVersion, OsBuildNumber, BiosSMBIOSBIOSVersion
```

_Im Windows Terminal (PowerShell) ausführen._ Gibt Hersteller, Modell, CPU,
RAM-Gesamtgröße, Windows-Version/-Build und BIOS-Version als kopierbaren Text aus.

## 1.2 Grafikkarte

**Keine Adminrechte nötig:**

```
dxdiag
```

_Windows-Taste + R → `dxdiag`._ Im Reiter **Anzeige** stehen Grafikkarten-Modell,
Treiberversion und Treiberdatum. Bei Notebooks mit zwei GPUs (z. B. Intel + NVIDIA)
gibt es mehrere Anzeige-Reiter – beide notieren. Über „Alle Informationen
speichern…" lässt sich der komplette Bericht als Textdatei sichern.

## 1.3 Festplatten und freier Speicherplatz

**Schritt 1 – Laufwerke und Füllstand (keine Adminrechte):**

```powershell
Get-Volume | Where-Object DriveLetter | Sort-Object DriveLetter | Format-Table DriveLetter, FileSystemLabel, FileSystem, HealthStatus, @{n='Größe(GB)';e={[math]::Round($_.Size/1GB,1)}}, @{n='Frei(GB)';e={[math]::Round($_.SizeRemaining/1GB,1)}}
```

Listet alle Laufwerksbuchstaben mit Größe, freiem Platz und Gesundheitsstatus.
**Faustregel:** Auf dem Windows-Laufwerk (meist C:) sollten dauerhaft mindestens
15–20 % frei sein.

**Schritt 2 – Physische Datenträger und Typ (SSD/HDD) (keine Adminrechte):**

```powershell
Get-PhysicalDisk | Format-Table FriendlyName, MediaType, BusType, HealthStatus, @{n='Größe(GB)';e={[math]::Round($_.Size/1GB,0)}}
```

Zeigt, ob SSDs oder klassische Festplatten (HDD) verbaut sind und ob Windows sie
als „Healthy" meldet. `MediaType` = SSD/HDD, `HealthStatus` ≠ Healthy ist ein
Warnsignal → in die Problemliste.

## 1.4 Windows-11-Version

**Keine Adminrechte nötig:**

```
winver
```

_Windows-Taste + R → `winver`._ Zeigt Version (z. B. 24H2) und Build. Notieren –
wichtig für die Frage, ob das System noch Updates erhält.

## 1.5 Installierte Programme

**Schritt 1 – Vollständige Liste in Datei exportieren (keine Adminrechte):**

```powershell
winget list > "$env:USERPROFILE\Desktop\programme-liste.txt"
```

Erstellt auf dem Desktop die Datei `programme-liste.txt` mit allen erkannten
Programmen samt Version. Diese Liste ist später die Grundlage für die
Entscheidung, was wegkann – **es wird noch nichts deinstalliert.**

**Schritt 2 – Grafische Kontrolle:** _Einstellungen → Apps → Installierte Apps_,
nach Größe oder Installationsdatum sortieren. Kandidaten für „brauche ich nicht
mehr" nur **markieren/notieren**, nicht entfernen.

## 1.6 Autostart-Programme

**Keine Adminrechte nötig (Deaktivieren später erfordert je nach Eintrag Admin):**

1. **Strg + Umschalt + Esc** → Task-Manager öffnen.
2. Links den Reiter **Autostart von Apps** wählen.
3. Alle Einträge mit Status **Aktiviert** und ihrer **Startauswirkung**
   (Hoch/Mittel/Niedrig) notieren.

Noch nichts deaktivieren – erst in Phase 5 nach gemeinsamer Durchsicht.

## 1.7 Gerätefehler (Geräte-Manager)

**Keine Adminrechte zum Ansehen nötig:**

```
devmgmt.msc
```

_Windows-Taste + R → `devmgmt.msc`._ Nach Geräten mit **gelbem Warndreieck**
oder unter **Andere Geräte** suchen – das sind fehlende oder fehlerhafte Treiber.
Jeden Fund mit Gerätenamen in die Problemliste eintragen (Rechtsklick →
Eigenschaften → Fehlercode notieren).

## 1.8 Stabilität: Zuverlässigkeitsverlauf

**Keine Adminrechte nötig:**

```
perfmon /rel
```

_Windows-Taste + R → `perfmon /rel`._ Öffnet den Zuverlässigkeitsverlauf: eine
Zeitleiste mit Abstürzen (rote Kreuze), Warnungen und Updates der letzten Wochen.
Notieren: Welche Programme/Komponenten stürzen wiederholt ab? Gibt es ein Datum,
ab dem die Probleme begannen (z. B. nach einem bestimmten Update)?

## 1.9 Aktuelle Leistungsprobleme beschreiben

Kurz und konkret notieren (Vorlage in der Checkliste):

- Was genau ist langsam? (Start, Programme öffnen, Browser, Spiele, Dateizugriff …)
- Seit wann? (schleichend oder plötzlich, ggf. nach welchem Ereignis)
- Wie oft? (immer, nur nach dem Start, nur bei bestimmten Programmen)
- Gibt es Abstürze, Bluescreens, Einfrieren, Lüfterlärm, Hitze?

## 1.10 Wichtige private und dienstliche Daten lokalisieren

**Noch nichts verschieben** – nur erfassen, wo was liegt:

```powershell
Get-ChildItem "$env:USERPROFILE\Desktop", "$env:USERPROFILE\Documents", "$env:USERPROFILE\Downloads", "$env:USERPROFILE\Pictures", "$env:USERPROFILE\Videos" -Directory -ErrorAction SilentlyContinue | Select-Object FullName
```

Listet die Unterordner der Standard-Benutzerordner. Zusätzlich manuell prüfen und
notieren:

- Liegen Daten außerhalb des Benutzerprofils (z. B. direkt auf `C:\`, auf `D:` …)?
- Welche Ordner sind **privat**, welche **dienstlich**, welche gemischt?
- Gibt es Cloud-Ordner (OneDrive, Dropbox, Google Drive)? Sind sie synchronisiert?
- Wo liegen Fotos/Videos (Kamera-Importe, Handy-Backups, WhatsApp-Exporte …)?

## 1.11 Vorhandene Backups erfassen

Notieren, was es **heute schon** gibt:

- Externe Festplatten/USB-Sticks mit Datensicherungen (Datum der letzten Sicherung?)
- Cloud-Speicher (OneDrive & Co.): Was wird dort wirklich gesichert?
- Windows-Sicherungsfunktionen: _Einstellungen → Konten → Windows-Sicherung_
  (Status prüfen) und _Systemsteuerung → Sichern und Wiederherstellen (Windows 7)_
- Gibt es einen Wiederherstellungs-USB-Stick oder Systemabbilder?

**Wichtig:** Existiert kein aktuelles Backup, ist das automatisch **Priorität 1**
in der Problemliste – Phase 2 kommt dann vor allem anderen.

---

## 1.12 Priorisierte Problemliste erstellen

Alle Funde aus 1.1–1.11 in die [Problemlisten-Vorlage](vorlagen/problemliste.md)
übertragen und priorisieren:

| Priorität        | Bedeutung                            | Typische Beispiele                                                                           |
| ---------------- | ------------------------------------ | -------------------------------------------------------------------------------------------- |
| **P1 – Sofort**  | Datenverlust- oder Sicherheitsrisiko | Kein Backup; Datenträger nicht „Healthy"; Windows-Version ohne Support; Defender deaktiviert |
| **P2 – Wichtig** | Stabilität/Funktion beeinträchtigt   | Wiederholte Abstürze; Gerätefehler im Geräte-Manager; C: fast voll                           |
| **P3 – Mittel**  | Leistung und Komfort                 | Langer Systemstart; viele Autostart-Programme; veraltete Treiber ohne akute Fehler           |
| **P4 – Später**  | Ordnung und Struktur                 | Duplikate; unsortierte Fotos; Privat/Dienstlich vermischt                                    |

Erst wenn diese Liste steht, geht es weiter mit
[Phase 2: Backup- und Wiederherstellungsplan](02-backup-plan.md).
