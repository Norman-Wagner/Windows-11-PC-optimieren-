# Phase 5: Aufräumen und Optimieren

**Regel dieser Phase:** Es wird **nichts deinstalliert oder gelöscht ohne
ausdrückliche Freigabe.** Der Ablauf ist immer: Liste erstellen → gemeinsam
durchgehen → freigegebene Punkte einzeln umsetzen.

---

## 5.1 Programme deinstallieren (nur nach Freigabe)

**Schritt 1 – Kandidatenliste erstellen:** Die Programmliste aus Phase 1.5
(`programme-liste.txt`) durchgehen und jedes Programm einer Kategorie zuordnen:

- **Behalten** – wird aktiv genutzt.
- **Kandidat** – unklar oder lange nicht genutzt → gemeinsam entscheiden.
- **Entfernen (Vorschlag)** – typisch: vorinstallierte Testversionen
  (fremde Antiviren-Trials, Spiele-Bundles), doppelte Programme für denselben
  Zweck (drei PDF-Reader, zwei Brennprogramme), Toolbars.

⚠️ **Nicht anfassen:** Einträge wie „Microsoft Visual C++ Redistributable",
„.NET Runtime", „Microsoft Edge WebView2", Treiber-Pakete – das sind
Systembausteine, die andere Programme brauchen.

**Schritt 2 – Nach Freigabe einzeln deinstallieren** (**Adminrechte:** Windows
fragt): _Einstellungen → Apps → Installierte Apps → ⋯ → Deinstallieren._
Alternativ zuerst exakte Paket-ID und Quelle mit `winget list` und
`winget show --id <PAKET-ID> --exact` prüfen. Erst danach nach Freigabe:

```powershell
winget uninstall --id "<PAKET-ID>" --exact
```

Nach jeder Deinstallation kurz prüfen, ob alles Übrige noch läuft.

## 5.2 Speicherplatz freigeben (Bordmittel)

**Schritt 1 – Bereinigungsempfehlungen prüfen:** _Einstellungen → System →
Speicher → Bereinigungsempfehlungen_. Jede Kategorie einzeln öffnen und
auswählen.

Die klassische Datenträgerbereinigung kann ergänzend verwendet werden
(Adminrechte für Systemdateien):

```
cleanmgr /d C:
```

Im Dialog **„Systemdateien bereinigen"** anklicken. Häufig geeignete
Kandidaten sind temporäre Dateien, Miniaturansichten,
Übermittlungsoptimierungsdateien und Windows-Update-Bereinigung. Auch diese
Kategorien vor dem Bestätigen prüfen; keine Kategorie ist pauschal für jedes
System „gefahrlos“.

⚠️ „Papierkorb" nur ankreuzen, wenn sicher nichts mehr gebraucht wird.
⚠️ „Vorherige Windows-Installation(en)" erst nach Rücksprache – danach ist die
Rückkehr zur vorherigen Windows-Version nicht mehr möglich.

**Schritt 2 – Speicheroptimierung aktivieren (keine Adminrechte):**
_Einstellungen → System → Speicher → Speicheroptimierung_ einschalten:
löscht künftig automatisch temporäre Dateien und alte Papierkorb-Inhalte
(z. B. nach 30 Tagen). Die Option „Dateien im Ordner ‚Downloads' löschen"
auf **Nie** lassen.

**Schritt 3 – Große Ordner identifizieren (keine Adminrechte):**
_Einstellungen → System → Speicher_ zeigt, was den Platz belegt.
Große Funde nur notieren → Entscheidung in Phase 6.

## 5.3 Autostart entschlacken (nach gemeinsamer Durchsicht)

Task-Manager → **Autostart von Apps**. Bewertung der Liste aus Phase 1.6/3.8:

- **Aktiv lassen:** Sicherheit (Defender läuft ohnehin), Cloud-Sync (OneDrive,
  falls genutzt), Backup-Tools, Eingabegeräte-Software, Audio-Treiber.
- **Deaktivieren (typische Kandidaten):** Updater einzelner Programme, Spiele-
  Launcher, Chat-Programme, die man selbst startet, „Schnellstart-Helfer" von
  Druckern/Office.

Deaktivieren per Rechtsklick → **Deaktivieren** (das Programm bleibt installiert
und startbar – es startet nur nicht mehr automatisch; jederzeit umkehrbar).
Nach dem nächsten Neustart prüfen, ob alles Gewohnte noch funktioniert.

## 5.4 Hintergrund-Apps und Benachrichtigungen

- _Einstellungen → Apps → Installierte Apps → ⋯ → Erweiterte Optionen_: Bei
  Apps, die nicht im Hintergrund arbeiten müssen, „Hintergrund-App-Berechtigungen"
  auf **Nie** stellen (nur bei Store-Apps verfügbar).
- _Einstellungen → System → Benachrichtigungen_: Unnötige Absender abschalten –
  weniger Unterbrechungen, weniger Hintergrundaktivität.

## 5.5 Leistung: sichere Optimierungen

**Energiemodus (keine Adminrechte):** _Einstellungen → System → Netzbetrieb und
Energie_ → im Netzbetrieb „Ausbalanciert" oder „Beste Leistung".

**Visuelle Effekte (nur bei spürbar träger Oberfläche):**

```
sysdm.cpl
```

_Reiter Erweitert → Leistung → Einstellungen:_ „Für optimale Leistung anpassen",
dann „Schriftarten mit Kantenglättung" wieder aktivieren. Jederzeit umkehrbar.

**SSD-Pflege prüfen (Adminrechte):** _Start → „Laufwerke defragmentieren und
optimieren" (`dfrgui`)_: Für SSDs führt Windows automatisch **Trim** aus – prüfen,
dass die geplante Optimierung **Ein** ist. Nicht manuell „defragmentieren" –
für SSDs unnötig; Windows wählt selbst die richtige Methode.

⚠️ **Finger weg von:** Registry-Cleanern, RAM-Boostern, „Game-Turbo"-Tools,
Diensten manuell abschalten (`services.msc`) und Auslagerungsdatei-Experimenten.
Der Leistungsgewinn ist minimal bis null, das Schadenspotenzial hoch.

## 5.6 Erfolgskontrolle

- Startzeit gefühlt/gestoppt vor–nachher vergleichen.
- Task-Manager → **Leistung**: RAM-Auslastung im Leerlauf notieren.
- `perfmon /rel` nach einer Woche: bleibt die Kurve stabil oben?
- Freien Speicherplatz mit Phase 1.3 vergleichen und in der Checkliste festhalten.

Weiter mit [Phase 6: Ordnungssystem für Dateien](06-ordnungssystem-dateien.md).
