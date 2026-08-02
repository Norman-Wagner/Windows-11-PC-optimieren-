# Erweiterte Diagnose: gezielt, kurz, lokal

## Autoruns

Nutze Autoruns nur zur Sichtung, wenn der normale Autostart nicht erklärt, warum Start oder Anmeldung langsam sind. Prüfe zuerst Herausgeber, Signatur, Pfad und Zweck. Deaktiviere höchstens einen eindeutig unnötigen Eintrag mit Rückweg. Keine Massen-Deaktivierung von Diensten, Treibern, Winlogon- oder Sicherheitskomponenten.

## WPR und WPA

WPR/WPA nur bei einem klar wiederholbaren Engpass einsetzen: langsamer Start, Programmstart, Datenträger-Stau oder kurze Hänger. Vorher erklären:

- die Aufzeichnung wird lokal gespeichert;
- ETL-Dateien können technische Pfade und Aktivitäten enthalten;
- Zeitraum und Auslöser werden auf das Minimum begrenzt;
- Weitergabe nur nach Vorschau und Schwärzung.

Nach der Aufnahme zuerst prüfen: CPU, Datenträger, ReadyThread/Bootphasen oder blockierte I/O. Eine ETL-Datei ist kein Grund, ungeprüft Dienste oder Registry zu ändern.

## Process Explorer und Process Monitor

Process Explorer bei „Datei wird verwendet“, unerklärlichen Unterprozessen oder DLL-/Handle-Konflikten verwenden. Process Monitor nur gefiltert nach Prozessname, Zeitraum und Vorgang. Ungefilterte Mitschnitte sind laut, schwer auswertbar und können sensible Pfade enthalten.

## RAMMap

RAMMap erklärt, ob RAM durch Prozesse, Dateicache, Kernel oder Treiber belegt ist. Hohe Cache-Nutzung allein ist kein Fehler. Keine Funktion zum Leeren von Listen als Dauerlösung verwenden; erst Speicherleck, Treiberproblem oder zu knappen Arbeitsspeicher unterscheiden.

## Defender-Leistung

Bei hoher Last von Microsoft Defender zuerst die dafür vorgesehene Leistungsaufzeichnung nutzen. Eine Ausnahme darf niemals automatisch aus einem Treffer entstehen. Prüfe Vertrauenswürdigkeit, Signatur, Eigentümer, tatsächlichen Nutzen und kleinstmöglichen Bereich. Nach der Testphase Ausnahme wieder entfernen oder erneut begründen.

## Delivery Optimization

Bei begrenzter Internetleitung Upload und Download über die Windows-Einstellungen begrenzen oder Peer-Sharing prüfen. Updates, Defender-Signaturen oder Firewall nicht als „Leistungsoptimierung“ dauerhaft abschalten.
