# Phase 2: Backup- und Wiederherstellungsplan

**Regel:** Kein Reparatur-, Aufräum- oder Treiberschritt beginnt, bevor diese
Phase abgeschlossen ist. Alles hier nutzt Windows-Bordmittel.

---

## 2.1 Die Strategie: 3-2-1-Prinzip (vereinfacht)

- **3** Kopien wichtiger Daten (Original + 2 Sicherungen)
- **2** verschiedene Medien (z. B. externe Festplatte + Cloud)
- **1** Kopie außer Haus bzw. getrennt vom PC (Cloud oder ausgelagerte Platte)

Für den Hausgebrauch reicht als Minimum: **eine externe Festplatte** (Dateiversionsverlauf
oder manuelle Kopie) **plus OneDrive** für die wichtigsten Ordner.

## 2.2 Sofort-Sicherung der wichtigsten Daten (vor allen Eingriffen)

Externe Festplatte anschließen (hier als Beispiel Laufwerk `E:`), dann **pro
Ordner einzeln** sichern:

```powershell
robocopy "$env:USERPROFILE\Documents" "E:\Sicherung-2026-07\Documents" /E /XJ /R:1 /W:1 /LOG:"E:\Sicherung-2026-07\log-documents.txt"
```

**Keine Adminrechte nötig** (für eigene Dateien). `robocopy` ist das robuste
Kopierwerkzeug von Windows: `/E` kopiert alle Unterordner, `/XJ` überspringt
Verknüpfungspunkte (verhindert Endlosschleifen), `/R:1 /W:1` begrenzt Wiederholversuche,
`/LOG` schreibt ein Protokoll. Den Befehl anschließend für `Desktop`, `Pictures`,
`Videos`, `Downloads` und alle in Phase 1.10 gefundenen Datenordner wiederholen
(jeweils Quell- und Zielordner anpassen).

⚠️ **Hinweis:** `robocopy` mit diesen Schaltern **löscht nichts** – es kopiert nur.
Die Schalter `/MIR` oder `/PURGE` bewusst **nicht** verwenden, sie würden im Ziel
Dateien löschen.

**Kontrolle:** Stichprobenartig 3–5 Dateien im Ziel öffnen (ein Foto, ein Dokument,
ein Video). Ein Backup, das nie getestet wurde, ist keins.

## 2.3 Systemwiederherstellungspunkt anlegen

**Adminrechte erforderlich.**

**Schritt 1 – Computerschutz prüfen/aktivieren:**

```
systempropertiesprotection
```

_Windows-Taste + R → `systempropertiesprotection`._ Für Laufwerk C: muss der
Schutz **Ein** sein. Falls aus: C: markieren → **Konfigurieren** → „Computerschutz
aktivieren", Speichernutzung ca. 5–10 %.

**Schritt 2 – Punkt erstellen:** Im selben Fenster **Erstellen…** → Name z. B.
`Vor Wartung 2026-07` → Erstellen.

Ein Wiederherstellungspunkt sichert **Systemdateien, Treiber und Registry** (nicht
die persönlichen Dateien) und erlaubt es, fehlgeschlagene Treiber- oder
Programmänderungen rückgängig zu machen.

## 2.4 Wiederherstellungslaufwerk (Notfall-USB-Stick)

**Adminrechte erforderlich.** USB-Stick mit mindestens 16 GB (⚠️ wird dabei
**komplett gelöscht** – vorher prüfen, dass nichts Wichtiges darauf liegt):

```
recoverydrive
```

_Windows-Taste + R → `recoverydrive`._ Haken bei „Sichert die Systemdateien auf
dem Wiederherstellungslaufwerk" setzen. Mit diesem Stick lässt sich der PC auch
dann starten und reparieren, wenn Windows gar nicht mehr hochfährt. Stick
beschriften und getrennt aufbewahren.

## 2.5 Dateiversionsverlauf einrichten (laufende Sicherung)

**Keine Adminrechte nötig.** Externe Festplatte dauerhaft oder regelmäßig anschließen:

1. _Systemsteuerung → Dateiversionsverlauf_ öffnen
   (Windows-Taste + R → `control /name Microsoft.FileHistory`).
2. Externes Laufwerk auswählen → **Einschalten**.

Der Dateiversionsverlauf sichert Bibliotheken, Desktop, Kontakte und Favoriten
automatisch und bewahrt **ältere Versionen** von Dateien auf – schützt also auch
vor versehentlichem Überschreiben.

## 2.6 OneDrive-Ordnersicherung (Cloud-Standbein)

**Keine Adminrechte nötig.** _Einstellungen → Konten → Windows-Sicherung →
OneDrive-Ordnersynchronisierung verwalten_ → Desktop, Dokumente und Bilder
aktivieren (soweit der Speicherplatz des Kontos reicht).

⚠️ **Hinweis für dienstliche Daten:** Dienstliche Dateien gehören in der Regel
**nicht** in eine private Cloud. Falls der Arbeitgeber Vorgaben macht (eigenes
OneDrive for Business, Verschlüsselung, Verbot privater Clouds), gelten diese –
im Zweifel dienstliche Ordner von der privaten OneDrive-Sicherung ausschließen.

## 2.7 Wiederherstellungsplan (was tun, wenn etwas schiefgeht)

| Problem                                    | Lösung                                                                                                   | Werkzeug                     |
| ------------------------------------------ | -------------------------------------------------------------------------------------------------------- | ---------------------------- |
| Treiber-/Programmänderung macht Ärger      | Systemwiederherstellung auf den Punkt aus 2.3                                                            | `rstrui` (Windows-Taste + R) |
| Einzelner Treiber problematisch            | Geräte-Manager → Gerät → Eigenschaften → Treiber → **Vorheriger Treiber**                                | `devmgmt.msc`                |
| Datei versehentlich gelöscht/überschrieben | Rechtsklick auf Ordner → **Vorgängerversionen wiederherstellen**                                         | Dateiversionsverlauf         |
| Windows startet nicht mehr                 | Vom Wiederherstellungs-USB-Stick (2.4) booten → Erweiterte Optionen → Systemwiederherstellung/Starthilfe | Recovery-Stick               |
| Totalausfall                               | Neuinstallation + Daten aus 2.2/2.5/2.6 zurückspielen                                                    | Backup-Medien                |

**Erst wenn 2.2 und 2.3 erledigt sind** (2.4–2.6 dringend empfohlen), weiter mit
[Phase 3: Windows überprüfen und reparieren](03-windows-pruefen-reparieren.md).
