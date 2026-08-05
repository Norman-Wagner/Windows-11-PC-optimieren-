# Roadmap: Vom Handbuch zum überprüfbaren Sicherheits- und Wartungswerkzeug

## Ausgangslage

Das Repository enthält ein sechsphasiges Handbuch, einen Agent-Skill mit
Referenzmaterial und drei lesende Diagnose-Skripte. Die Analyse zeigt drei
Lücken, die den praktischen Wert am stärksten begrenzen:

1. **Sicherheit ist Handarbeit.** Wer den Schutzstatus prüfen will, muss sich
   durch viele Einstellungsseiten klicken – es gibt kein Werkzeug, das den
   Zustand in einer Minute objektiv erfasst.
2. **Der Plan endet nach dem Aufräumen.** Ohne feste Wartungsroutine verfällt
   jede Optimierung innerhalb weniger Monate wieder.
3. **Vertrauen beruht auf Behauptung.** Die Skripte versprechen „nur lesen,
   keine Netzwerkzugriffe" – bewiesen wird das bisher nur durch eine statische
   Mustersuche, nicht durch automatisierte Funktionstests auf echtem Windows.

Die folgenden Funktionen schließen diese Lücken. Alles funktioniert **ohne KI**,
mit Windows-Bordmitteln, und respektiert die bestehenden Leitplanken:
nur lesen, nichts ohne Freigabe ändern, keine personenbezogenen Daten ausgeben,
keine Netzwerkzugriffe in Laufzeit-Skripten.

---

## F1: Sicherheits-Audit-Skript (`Get-SecurityBaselineReport.ps1`)

**Nutzen:** Der komplette Schutzstatus eines Windows-11-PCs (Defender,
Firewall, SmartScreen, UAC, Secure Boot, TPM, BitLocker, Updates) als ein
einziger, lesbarer Bericht mit Bewertung – statt zehn Einstellungsseiten.
Das ist der Kern von „maximale Sicherheit ohne KI": messbar statt gefühlt.

**Umsetzung:** Neues lesendes Skript unter `skills/windows-pc-guru/scripts/`,
gleiche Konventionen wie die bestehenden Skripte (Schema, Datenschutzhinweis,
Fehlertoleranz pro Prüfpunkt).

**Akzeptanzkriterien:**

- [x] Läuft ohne Adminrechte durch; Prüfpunkte, die Adminrechte bräuchten
  (z. B. Secure Boot), melden dann den Status `Unbekannt` statt abzubrechen.
- [x] Verändert nichts (`FilesChanged = false`) und nutzt kein Netzwerk
  (`NetworkUsed = false`).
- [x] Gibt keine Benutzer-, Computer-, Serien-, MAC-, IP- oder Pfaddaten aus.
- [x] Jeder Prüfpunkt liefert `Bereich`, `Status` (`OK` / `Warnung` /
  `Unbekannt`) und eine deutsche `Empfehlung` mit konkretem nächsten Schritt.
- [x] Zusammenfassung mit Zählern (`OkCount`, `WarnungCount`, `UnbekanntCount`).
- [x] `-AsJson` liefert gültiges JSON mit `SchemaVersion = 1.0`.
- [x] Besteht die Lokal-only-Prüfung (`Test-LocalOnlyPolicy.ps1`).
- [x] Wird im CI-Smoke-Test auf echtem Windows ausgeführt und geprüft.

## F2: Wartungs-Check-Skript (`Get-MaintenanceStatus.ps1`)

**Nutzen:** Beantwortet in einer Minute die Frage „ist dieser PC noch gepflegt?"
– letzter Neustart, Update-Stand, Defender-Signaturalter, freier Speicherplatz,
Anzahl Autostart-Einträge. Die Messgrundlage für jede Wartungsroutine.

**Umsetzung:** Neues lesendes Skript unter `skills/windows-pc-guru/scripts/`
nach denselben Konventionen; jeder Wert mit Schwellwert-Bewertung.

**Akzeptanzkriterien:**

- [x] Läuft ohne Adminrechte, verändert nichts, nutzt kein Netzwerk.
- [x] Gibt keine personenbezogenen oder gerätidentifizierenden Daten aus.
- [x] Bewertet jeden Messwert gegen dokumentierte Schwellwerte
  (z. B. freier Speicher < 15 % → `Warnung`).
- [x] `-AsJson` liefert gültiges JSON mit `SchemaVersion = 1.0`.
- [x] Besteht die Lokal-only-Prüfung und läuft im CI-Smoke-Test.

## F3: Wartungsroutine als Phase 7 (`07-wartungsroutine.md`)

**Nutzen:** Der Ablaufplan bekommt einen dauerhaften Abschluss: eine feste
monatliche (30 Minuten) und vierteljährliche (60 Minuten) Routine, damit
Sicherheit und Leistung erhalten bleiben, statt wieder zu verfallen.

**Akzeptanzkriterien:**

- [x] Monatliche und vierteljährliche Routine als abhakbare Schrittfolge,
  jede mit Zeitangabe und Werkzeug (Bordmittel oder F2-Skript).
- [x] Verweist auf die Phasen 2 (Backup prüfen), 3 (Updates) und 5 (Autostart).
- [x] In README (Schritt 8 des Ablaufplans) verlinkt.

## F4: Schnellstart – Basisschutz in 60 Minuten (`SCHNELLSTART.md`)

**Nutzen:** Nicht jeder hat Zeit für sechs Phasen. Der Schnellstart liefert
die wichtigsten Sicherheitsmaßnahmen als kompakte Schrittfolge für einen
Nachmittag – mit klarer Abgrenzung, was er **nicht** ersetzt.

**Akzeptanzkriterien:**

- [x] Maximal 7 Schritte, jeder mit Zeitangabe, gesamt ≤ 60 Minuten.
- [x] Deckt mindestens ab: Backup der wichtigsten Daten, Windows Update,
  Schutzstatus-Prüfung, Wiederherstellungspunkt.
- [x] Verweist für jeden Schritt auf die ausführliche Phase.
- [x] In der README verlinkt.

## F5: Druckbare Fortschritts-Checkliste (`vorlagen/fortschritts-checkliste.md`)

**Nutzen:** Der gesamte Ablaufplan (8 Schritte) als eine abhakbare Liste zum
Ausdrucken oder Mitführen – Projektstand auf einen Blick, auch für Helfer,
die den PC eines Angehörigen betreuen.

**Akzeptanzkriterien:**

- [x] Alle 8 Schritte des README-Ablaufplans mit ihren Kernaufgaben als
  Checkboxen, plus Felder für Datum und Notizen.
- [x] Konsistent mit den Phasen-Dokumenten verlinkt.

## F6: Automatisierte Testsuite auf echtem Windows (Pester + CI)

**Nutzen:** Die Sicherheitsversprechen („nur lesen, kein Netzwerk, keine
personenbezogenen Daten") werden durch automatisierte Tests auf einem echten
Windows-System **belegt** statt nur behauptet. Jeder Pull Request wird
dagegen geprüft.

**Akzeptanzkriterien:**

- [x] Pester-Tests unter `tests/` führen alle Diagnose-Skripte auf
  `windows-latest` aus und prüfen: gültiges JSON, `SchemaVersion`,
  `NetworkUsed = false`, `FilesChanged = false`, Datenschutzhinweis vorhanden.
- [x] Ein Test belegt, dass die Skripte keine Benutzer- oder Computernamen
  in der Ausgabe enthalten (Abgleich gegen `$env:USERNAME`/`$env:COMPUTERNAME`).
- [x] Ein Test belegt, dass die Sicherheits- und Wartungsberichte für jeden
  Prüfpunkt nur die erlaubten Statuswerte liefern.
- [x] Struktur-Tests prüfen ROADMAP, Aufgabenliste und die neuen Dokumente
  (Pflichtdateien, keine Platzhalter).
- [x] Die CI führt die Pester-Suite bei jedem Push und Pull Request aus;
  ein roter Test blockiert den Merge.
- [x] `Test-Repository.ps1` nimmt die neuen Dateien in die Pflichtliste auf.

---

## Meilensteine

| Meilenstein | Inhalt | Status |
|---|---|---|
| M1 | ROADMAP.md und [Aufgabenliste](AUFGABEN.md) | erledigt |
| M2 | F1 + F2 (Audit- und Wartungs-Skript) | erledigt |
| M3 | F3 + F4 + F5 (Wartungsroutine, Schnellstart, Checkliste) | erledigt |
| M4 | F6 (Pester-Testsuite, CI-Erweiterung) | erledigt |

Die detaillierte Aufgabenliste mit allen Einzelschritten steht in
[AUFGABEN.md](AUFGABEN.md).
