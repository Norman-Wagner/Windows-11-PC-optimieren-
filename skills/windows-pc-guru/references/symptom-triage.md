# Symptomorientierte Triage

Wähle den kleinsten Diagnosepfad, der die wichtigsten Hypothesen trennt.
Warnungen in der Ereignisanzeige sind allein kein Fehlernachweis.

## PC startet nicht

1. Kläre: kein Strom, kein Bild, Bootschleife, Bluescreen oder Windows-Anmeldung?
2. Frage nach letzter Hardware-, Treiber-, Update- oder Verschlüsselungsänderung.
3. Notiere den exakten Fehlertext beziehungsweise Stoppcode.
4. Verändere Bootreihenfolge, BIOS, Partitionen oder BitLocker nicht autonom.
5. Verwende die Microsoft-Recovery-Entscheidungshilfe aus
   [official-sources.md](official-sources.md).

## Langsamer Start oder träger PC

1. Miss das konkrete Symptom und den Zeitpunkt; „langsam“ ist kein Messwert.
   Ohne vom Nutzer gelieferte oder aktuell erhobene Daten keine RAM-, SSD-,
   CPU-, Programm- oder Autostartwerte behaupten.
2. Prüfe freien Speicher, Task-Manager, Autostartauswirkung,
   Zuverlässigkeitsverlauf und Update-/Neustartstatus.
3. Prüfe erst danach Datenträger-, Temperatur-, Treiber- oder
   Hintergrundprozess-Hypothesen.
4. Deaktiviere keine Dienste und entferne keine Software in der Diagnosephase.

## Absturz, Einfrieren oder Bluescreen

1. Erfasse Stoppcode, Uhrzeit, auslösende Tätigkeit und letzte Änderung.
2. Prüfe den Zuverlässigkeitsverlauf und nur Ereignisse im passenden Zeitfenster.
3. Korrelieren wiederkehrender Treiber-/Modulname, WHEA-Ereignisse und
   Hardwareänderungen; einen Einzelfund nicht überinterpretieren.
4. Bei wiederkehrenden WHEA-, Speicher- oder Datenträgerfehlern Sicherung
   priorisieren und Hardwarediagnose eskalieren.

## Wenig Speicherplatz

1. Zeige die Windows-Speicherübersicht und Bereinigungsempfehlungen.
2. Prüfe Kategorien einzeln. Downloads, Papierkorb, Cloudinhalte,
   `Windows.old` und persönliche Dateien benötigen eigene Zustimmung.
3. Lösche nie manuell aus `WinSxS`, `Windows\Installer`, dem Driver Store oder
   anderen Systemordnern.
4. Verwende Storage Sense nur mit sichtbar geprüften Regeln.

## Netzwerk, WLAN oder Bluetooth

1. Trenne Internet-, Router-, DNS-, Adapter-, Treiber- und
   Energiesparprobleme.
2. Vergleiche ein anderes Gerät und, falls möglich, Ethernet mit WLAN.
3. Erfasse Adapterstatus, Fehlerzeitpunkt und Verhalten nach Standby.
4. Starte nicht mit Netzwerk-Reset oder Treiberentfernung; sichere vor einem
   Treiberwechsel den vorhandenen und den neuen Installer lokal.

## Windows Update

1. Erfasse Update-Kennung, Fehlercode, Verlauf, freien Speicher und
   Neustartstatus.
2. Nutze zuerst die integrierte Problembehandlung beziehungsweise „Hilfe
   anfordern“.
3. Verwende DISM/SFC nur bei passenden Korruptionssymptomen.
4. Eine Reparaturinstallation ist eine G3-Maßnahme mit Netzstrom, Internet,
   Backup und Zustimmung.

## Verdacht auf Schadsoftware

1. Bestätige den Anlass: Defender-Fund, fremde Anmeldung, Verschlüsselung,
   Pop-ups oder bloße Langsamkeit.
2. Bei akutem Einbruch oder Ransomware Netzwerk trennen, nichts bereinigen und
   Beweissicherung beziehungsweise Fachhilfe priorisieren.
3. Andernfalls Schutzstatus und Schutzverlauf prüfen, Signaturen aktualisieren
   und mit Schnellscan beginnen.
4. Vollständiger oder Offline-Scan nur nach Hinweis auf Dauer beziehungsweise
   Neustart und mit Zustimmung.

## Lokaler Build oder Entwicklerwerkzeug

1. Reproduziere mit dem kleinsten Befehl und bewahre die vollständige
   Fehlermeldung.
2. Erfasse Repository-Status, Tool- und Laufzeitversion, Architektur, Shell,
   PATH-Herkunft und Exitcode.
3. Vergleiche mit Projektdateien und CI, bevor global installiert oder PATH
   verändert wird.
4. Behandle Abhängigkeit, Berechtigung, Pfadlänge, Leerzeichen, Zeilenenden,
   Proxy und Virenschutz als getrennte Hypothesen.
5. Lies
   [programming-and-automation.md](programming-and-automation.md).

## Hardwareverdacht

Stoppe Optimierung und priorisiere Datenrettung beziehungsweise Fachdiagnose
bei klickendem Datenträger, SMART-/Windows-Warnung, wiederkehrenden WHEA-Fehlern,
Brandgeruch, Flüssigkeit, instabiler Stromversorgung oder kritischer
Überhitzung. Ein `Healthy`-Status von `Get-PhysicalDisk` schließt einen Defekt
nicht aus.
