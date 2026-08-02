# Firmenmodus: Lokal ohne Cloud-KI

## Zweck und Geltung

Dieser Modus ist für Firmenrechner mit personenbezogenen, vertraulichen oder berufsbezogenen Daten bestimmt. Er erlaubt ausschließlich lokale, rein lesende Diagnosen mit den im Repository enthaltenen Skripten.

Er ersetzt keinen AVV, keine interne KI-Richtlinie und keine Prüfung durch die verantwortliche Stelle oder den Datenschutzbeauftragten.

## Harte Sperrregeln

Im Firmenmodus Lokal:

- keine Cloud-KI, keine KI-Apps, keine Browser-Plugins und keine Fernwartung zur Auswertung verwenden;
- keine Screenshots, Fotos, Dokumente, E-Mails, Chatverläufe, Browserdaten, Passwörter, Schlüssel, Tokens oder personenbezogene Daten hochladen oder hineinkopieren;
- keine ungekürzten Ereignisprotokolle, ETL-/WPR-Dateien, Absturzabbilder, vollständigen Pfade, IP-/MAC-Adressen, Seriennummern oder Geräte-IDs weitergeben;
- keine Verbindung zu GitHub, ChatGPT, Herstellersupport oder anderen externen Diensten aus einer Diagnose heraus herstellen;
- keine Analyse fremder Benutzerprofile oder Cloud-Ordner durchführen.

Eine technische Diagnose ist kein Grund, Angehörigen-, Kunden-, Mitarbeiter- oder Fallakten zu öffnen.

## Erlaubte lokale Werkzeuge

| Werkzeug | Zulässige Daten | Nicht zulässig |
| --- | --- | --- |
| Get-WindowsPcSnapshot.ps1 | aggregierte Hardware-, Windows-, Laufwerks-, Update- und Schutzstatusdaten | Benutzer-, Computer-, Serien-, MAC-, IP- oder Dateidaten |
| Measure-OptimizationBaseline.ps1 | aggregierte Leistungs-, Speicher- und Laufwerkswerte | Prozessnamen, Dateipfade, Netzwerkdaten |
| Test-DriverPackage.ps1 | nur eine bewusst gewählte lokale Installer-/Treiberdatei | Upload, Download oder Installation |
| Test-LocalOnlyPolicy.ps1 | Quelltext der lokalen Diagnose-Skripte | keine System- oder Nutzerdaten |

## Praktischer Ablauf

1. Test-LocalOnlyPolicy.ps1 ausführen. Bei einem Fund abbrechen und das Repository prüfen.
2. Nur das kleinste passende lokale Diagnoseskript starten.
3. Ergebnisse lokal ansehen. Bei Bedarf nur anonymisierte Kennzahlen auf Papier oder in eine interne Dokumentation übertragen.
4. WPR, Process Monitor und ähnliche Werkzeuge nur lokal, kurz und bei konkretem Fehler verwenden. Mitschnitte gelten als vertraulich.
5. Externe KI nur nach gesonderter Unternehmensfreigabe, passendem Vertrag und vorheriger Datenminimierung.

## Prüfbarkeit und Grenze

Das Repository prüft die enthaltenen Diagnose-Skripte statisch auf typische Netzwerk-, Download-, Fernsteuerungs- und Löschbefehle. Das verhindert keinen absichtlichen, verschleierten Schadcode und schützt nicht vor Daten, die ein Mensch manuell in einen Browser kopiert. Deshalb bleiben Zugriffsrechte, Geräteschutz und eine interne Arbeitsanweisung notwendig.
