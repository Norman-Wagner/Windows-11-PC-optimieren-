# Sicherheits- und Datenschutz-Audit

## Ziel

Sicherheitskonfigurationen bewerten, ohne sie blind zu überschreiben. Microsoft Security Baselines und CIS Benchmarks sind Vergleichsgrundlagen, keine Ein-Klick-Konfiguration für private Einzelgeräte.

## Lesende Prüfung

Prüfe nur den konkreten Status:

- Windows Update und Defender-Schutzstatus;
- Firewall- und SmartScreen-Status;
- Gerätesicherheit einschließlich Secure Boot, soweit sichtbar;
- BitLocker-Status ohne Wiederherstellungsschlüssel;
- lokale Administratorkonten nur mit gesonderter Zustimmung;
- Remotezugriff, wenn ein konkreter Anlass besteht.

## Bewertung

| Befund | Einordnung | Nächster Schritt |
| --- | --- | --- |
| Schutz aktiv und aktuell | kein Eingriff | dokumentieren |
| Schutz absichtlich durch verwaltete Firmenlösung ersetzt | Kontext prüfen | nicht gegen Unternehmensvorgaben arbeiten |
| Schutz deaktiviert oder unbekannt | P1 | Ursache klären, keine Leistungsausrede akzeptieren |
| Baseline weicht ab | nicht automatisch ein Fehler | Zweck, Gerätetyp und Rückweg bewerten |

## Datenschutz

Diagnoseberichte enthalten keine Benutzer-, Serien-, MAC-, IP-, Schlüssel- oder vollständigen Dateipfaddaten. Exporte bleiben lokal, werden vor Weitergabe geprüft und nur mit Zweck sowie Löschzeitpunkt abgelegt.
