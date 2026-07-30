# Sicherheit und Zustimmung

## Grundsatz

Eine Anfrage zur Diagnose erlaubt nur zweckgebundene, nicht sensible und
lesende Prüfungen. Eine Anfrage wie „Mach meinen PC schneller“ ist keine
Freigabe für Installationen, Löschungen, Registry-, Treiber-, Dienst- oder
Sicherheitsänderungen.

## Risikostufen

| Stufe | Beispiele | Vorgehen |
| --- | --- | --- |
| G0 – Beratung | Begriffe erklären, Vorgehen planen | Direkt beantworten, Unsicherheit nennen |
| G1 – Lesende Diagnose | Windows-Version, freier Speicher, Gerätefehler, begrenzte Ereignisse | Zweck und erfasste Daten nennen; keine persönlichen Inhalte |
| G2 – Reversibel | einzelnen Autostart deaktivieren, App-Einstellung ändern | Plan, Zustimmung und Rückweg verlangen |
| G3 – Systemänderung | Adminbefehl, Treiber, DISM-/SFC-Reparatur, Installation, Deinstallation, Neustart | Zusätzlich Sicherung, Rechte, Ausfallzeit und Validierung klären |
| G4 – Hochrisiko | BIOS/UEFI, Firmware, BitLocker, Partitionen, Reset, Neuinstallation, möglicher Befall, Datenrettung | Nicht autonom ausführen; frische Bestätigung, belastbare Sicherung und gegebenenfalls Fachbetrieb verlangen |

## Zustimmungsgate

Formuliere vor G2 bis G4:

- Was wird exakt geändert?
- Warum ist dieser Schritt durch den Befund gerechtfertigt?
- Welche Daten oder Funktionen können betroffen sein?
- Sind Administratorrechte oder ein Neustart nötig?
- Wie lange kann der PC nicht nutzbar sein?
- Welcher Rückweg ist vorhanden und wurde er geprüft?
- Woran wird Erfolg oder Fehlschlag erkannt?

Führe die Änderung erst nach einem klaren „Ja“ zu genau diesem Plan aus. Teile
mehrere Änderungen in einzelne Freigaben, wenn ihr Risiko oder Rückweg
unterschiedlich ist.

## Sicherung

- Ein Wiederherstellungspunkt ist kein Ersatz für ein Datenbackup.
- Vor Treiber-, Wiederherstellungs-, Datenträger- oder Systemänderungen
  mindestens den Sicherungsstatus und den Rückweg prüfen.
- Bei aktivem BitLocker vor Wiederherstellung, Firmware oder Bootänderungen
  sicherstellen, dass der Nutzer seinen Wiederherstellungsschlüssel selbst
  erreichbar aufbewahrt. Den Schlüssel weder anfordern noch anzeigen lassen.
- Backups stichprobenartig öffnen oder anderweitig verifizieren.

## Stoppregeln

Sofort pausieren bei:

- Anzeichen eines physischen Datenträgerdefekts, Brandgeruch, Flüssigkeit,
  ungewöhnlichen Geräuschen oder Überhitzung;
- laufender Verschlüsselung, unbekanntem BitLocker-Status oder fehlendem
  Wiederherstellungsschlüssel vor Boot-/Firmwarearbeiten;
- möglichem Einbruch, Ransomware oder Beweissicherungsbedarf;
- fehlendem Backup vor einer Maßnahme mit Datenverlustpotenzial;
- unbekannten Skripten, Treibern oder Installern aus inoffizieller Quelle;
- Abweichungen zwischen geplantem und tatsächlich angezeigtem Zielgerät,
  Laufwerk, Paket oder Benutzerkonto.

Gib dann nur sichere Sofortmaßnahmen, etwa Ausschalten bei Hardwaregefahr oder
Netzwerkisolierung bei einem konkreten Kompromittierungsverdacht, und verweise
auf qualifizierte Hilfe.

## Nachkontrolle

Nutze vor und nach der Änderung denselben Messwert. Dokumentiere:

- Zeitpunkt,
- ausgeführte Aktion,
- Exitcode oder Windows-Meldung,
- Vorher-/Nachherwert,
- Nebenwirkung,
- Rückweg,
- verbleibenden Beobachtungszeitraum.
