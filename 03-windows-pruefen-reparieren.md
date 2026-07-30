# Phase 3: Windows überprüfen und reparieren

**Voraussetzung:** Phase 1 (Bestandsaufnahme) und Phase 2 (Backup) sind abgeschlossen.
Alle Werkzeuge hier sind Windows-Bordmittel. Reihenfolge einhalten – jeder Schritt
einzeln ausführen, Ergebnis notieren, dann erst weiter.

---

## 3.1 Windows Update

**Adminrechte:** nur zum Installieren (Windows fragt automatisch).

1. _Einstellungen → Windows Update → Nach Updates suchen_.
2. Alle Qualitäts- und Sicherheitsupdates installieren, PC neu starten,
   erneut suchen – so lange, bis „Sie sind auf dem neuesten Stand" erscheint.
3. Danach unter _Windows Update → Erweiterte Optionen → Optionale Updates_
   nachsehen: Dort liegen oft **Treiber-Updates** – noch **nicht** installieren,
   die kommen geordnet in [Phase 4](04-treiber-aktualisieren.md).

⚠️ Große Funktionsupdates (z. B. Versionssprung auf 24H2/25H2) erst **nach**
Abschluss der Reparaturphase installieren, nicht mittendrin.

## 3.2 Windows-Sicherheit prüfen

**Keine Adminrechte zum Ansehen.**

1. _Einstellungen → Datenschutz und Sicherheit → Windows-Sicherheit_ öffnen.
2. Schutzstatus, Schutzanbieter und Hinweise prüfen: **Viren- &
   Bedrohungsschutz**, **Firewall- & Netzwerkschutz**, **App- &
   Browsersteuerung** und **Gerätesicherheit**. Bei einem bewusst installierten
   Drittanbieter-Virenschutz kann Defender ordnungsgemäß im passiven Modus sein.
3. Einen **vollständigen Scan** starten: _Viren- & Bedrohungsschutz → Scanoptionen
   → Vollständige Überprüfung_. Das kann 1–2 Stunden dauern und darf im
   Hintergrund laufen.

⚠️ Defender und Firewall bleiben in jedem Fall **aktiv**. Sollte hier ein fremdes
Antivirenprogramm auftauchen, das Sie nicht bewusst installiert haben → in die
Problemliste, Entscheidung gemeinsam treffen.

## 3.3 Systemdateien reparieren (DISM + SFC)

**Adminrechte erforderlich** – Terminal als Administrator öffnen
(Rechtsklick auf Start → „Terminal (Administrator)").

**Schritt 1 – Komponentenspeicher prüfen und reparieren:**

```
DISM /Online /Cleanup-Image /RestoreHealth
```

Prüft und repariert den Windows-Komponentenspeicher. Standardmäßig kann DISM
Windows Update als Reparaturquelle verwenden; in verwalteten oder
Offline-Umgebungen kann eine passende alternative Quelle nötig sein. Nicht
abbrechen, bis DISM ein Ergebnis ausgibt.

**Schritt 2 – Systemdateien prüfen und ersetzen:**

```
sfc /scannow
```

Vergleicht alle geschützten Systemdateien mit den (soeben reparierten)
Originalen und ersetzt beschädigte Dateien. Dauert 5–15 Minuten. Ergebnis
notieren:

- „keine Integritätsverletzungen" → alles in Ordnung.
- „beschädigte Dateien … erfolgreich repariert" → gut; Befehl nach einem
  Neustart noch einmal ausführen, bis keine Fehler mehr gemeldet werden.
- „konnte einige … nicht reparieren" → Ausgabe sichern, gemeinsam bewerten.

## 3.4 Laufwerksfehler prüfen

**Adminrechte erforderlich.**

**Schritt 1 – Nur prüfen (ändert nichts):**

```
chkdsk C:
```

Prüft das Dateisystem von C: im Lesemodus und meldet, ob Fehler vorliegen.

**Schritt 2 – Nur falls Schritt 1 weitere Prüfung empfiehlt:**

```
chkdsk C: /scan
```

Führt eine Onlineprüfung aus. `/scan` ist **kein pauschaler Reparaturbefehl**.
Falls CHKDSK eine Reparatur oder Offlineprüfung empfiehlt, zuerst Backup und
Datenträgerzustand prüfen und den vorgeschlagenen Reparaturschritt gesondert
freigeben. Eine Reparatur kann einen Neustart und die Sperrung des Laufwerks
erfordern.

⚠️ Meldet `chkdsk` wiederholt Fehler oder war in Phase 1.3 ein Datenträger nicht
„Healthy": zusätzlich beim SSD-/Festplattenhersteller den Gesundheitsstatus
prüfen (offizielles Tool des Herstellers, z. B. Samsung Magician, Crucial Storage
Executive) und **zuerst das Backup aktualisieren**. Ein sterbender Datenträger
wird nicht optimiert, sondern ersetzt.

## 3.5 Arbeitsspeicher testen (Windows-Speicherdiagnose)

**Adminrechte erforderlich; PC startet dabei neu** – vorher alles speichern:

```
mdsched
```

_Windows-Taste + R → `mdsched` → „Jetzt neu starten und nach Problemen suchen"._
Testet den RAM beim Neustart (10–30 Minuten). Das Ergebnis erscheint nach der
Anmeldung als Benachrichtigung. Fehler im RAM erklären zufällige Abstürze und
Bluescreens → sofort in die Problemliste (P1/P2).

## 3.6 Zuverlässigkeitsverlauf erneut lesen

**Keine Adminrechte:** `perfmon /rel` (wie Phase 1.8). Nach den Reparaturen aus
3.3–3.5 beobachten: Werden die roten Kreuze weniger? Wiederkehrende Absturzquellen
(immer dasselbe Programm/derselbe Treiber) einzeln in die Problemliste aufnehmen.

## 3.7 Ereignisanzeige (nur bei Bedarf)

**Keine Adminrechte zum Lesen:**

```
eventvwr.msc
```

Nur gezielt einsetzen, wenn 3.6 wiederkehrende Fehler zeigt: _Windows-Protokolle
→ System_, dort nach **Fehler**/**Kritisch** rund um den Zeitpunkt eines Absturzes
filtern (rechts „Aktuelles Protokoll filtern"). Quelle und Ereignis-ID notieren –
die Ereignisanzeige enthält viele harmlose Warnungen, nicht jeder Eintrag ist ein
Problem.

## 3.8 Autostart und Hintergrundprogramme (nur sichten)

- Task-Manager (**Strg + Umschalt + Esc**) → **Autostart von Apps**: Liste aus
  Phase 1.6 aktualisieren.
- Reiter **Prozesse**: Nach CPU bzw. Arbeitsspeicher sortieren und notieren, was
  im Leerlauf dauerhaft viel verbraucht.

**Deaktiviert wird erst in [Phase 5](05-aufraeumen-optimieren.md)** – nach
gemeinsamer Durchsicht, damit nichts Wichtiges (Cloud-Sync, Backup-Dienst)
abgeschaltet wird.

## 3.9 Energieeinstellungen prüfen

**Keine Adminrechte zum Ansehen:**

```
powercfg /getactivescheme
```

Zeigt den aktiven Energiesparplan. Für Desktop-PCs ist **Ausbalanciert** der
richtige Standard; bei Notebooks zusätzlich _Einstellungen → System →
Netzbetrieb und Energie_ prüfen (Energiemodus im Netzbetrieb: „Ausbalanciert"
oder „Beste Leistung").

**Zusätzlich – Akku-/Energiebericht als Datei (Adminrechte erforderlich):**

```powershell
powercfg /energy /output "$env:USERPROFILE\Desktop\energie-bericht.html"
```

Nur im Leerlauf und ohne offene Dokumente ausführen. Der Befehl beobachtet das
System 60 Sekunden und schreibt einen lokalen HTML-Bericht. Der Bericht kann
Geräte- und Nutzungsdetails enthalten und darf nicht ungeprüft weitergegeben
werden.

---

## Abschluss Phase 3

Problemliste aktualisieren: Was ist behoben, was bleibt offen? Danach weiter mit
[Phase 4: Treiber aktualisieren](04-treiber-aktualisieren.md).
