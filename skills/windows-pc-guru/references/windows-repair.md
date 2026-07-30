# Windows prüfen und reparieren

## Diagnose und Reparatur trennen

| Zweck | Lesend oder gering eingreifend | Reparatur nach G3-Freigabe |
| --- | --- | --- |
| Komponentenabbild | `DISM /Online /Cleanup-Image /CheckHealth`, bei Bedarf `/ScanHealth` | `DISM /Online /Cleanup-Image /RestoreHealth` |
| Systemdateien | `sfc /verifyonly` | `sfc /scannow` |
| Dateisystem | `chkdsk C:` oder gezielt `chkdsk C: /scan` als Onlineprüfung | Reparaturoption nur nach Backup und anhand der tatsächlichen CHKDSK-Empfehlung |
| Ereignisse | zeitlich begrenztes `Get-WinEvent` oder Ereignisanzeige | Protokolle nicht löschen |

`/scan` nicht als pauschalen Reparaturbefehl beschreiben. Spezifische
Reparaturschalter können das Laufwerk sperren oder einen Neustart verlangen.

## Empfohlene Reihenfolge bei Korruptionssymptomen

1. Offene Arbeit speichern, Windows Update und ausstehenden Neustart prüfen.
2. Nur bei konkretem Anlass `DISM ... /CheckHealth` ausführen.
3. Bei unklarem Zustand `DISM ... /ScanHealth` ausführen.
4. Ergebnis bewerten. Vor `/RestoreHealth` Netzwerk-/Reparaturquelle,
   Administratorrechte und Protokollpfade erläutern.
5. Nach erfolgreichem DISM `sfc /scannow` ausführen.
6. Exitcodes und relevante Auszüge aus
   `%windir%\Logs\DISM\dism.log` beziehungsweise
   `%windir%\Logs\CBS\CBS.log` lokal sichern und personenbezogene Pfade vor
   einer Weitergabe schwärzen.

Eine alternative DISM-Quelle muss exakt zum Windows-Build und zur Edition
passen. Keine zufällige ISO oder fremde `install.wim` verwenden.

## Windows Update

- Fehlercode und Update-Kennung erfassen.
- Freien Speicher und Neustartstatus prüfen.
- Mit „Hilfe anfordern“ beziehungsweise der offiziellen
  Updateproblembehandlung beginnen.
- Feature-Updates nicht mitten in eine andere Reparaturkette mischen.
- Die Windows-11-Funktion „Probleme mittels Windows Update beheben“ kann die
  aktuelle Version neu installieren und Apps, Dateien und Einstellungen
  erhalten. Trotzdem als G3 behandeln: Backup, Netzstrom, Internet und
  ausdrückliche Zustimmung.

## Sicherheit

- Aktiven Schutzanbieter respektieren; ein Drittanbieter-Virenschutz kann
  Defender in den passiven Modus versetzen.
- Schutzstatus und Schutzverlauf prüfen, ohne Schutzfunktionen abzuschalten.
- Schnellscan zuerst; Vollscan nur bei begründetem Bedarf.
- Defender Offline startet den PC neu. Vorher Arbeit speichern und Zustimmung
  einholen.
- Funde nicht ungeprüft zulassen, ausschließen oder löschen.

## Speicher und Autostart

- Windows-Einstellungen unter **System > Speicher** und
  **Bereinigungsempfehlungen** bevorzugen.
- Storage Sense löscht je nach Konfiguration Papierkorb-, Download- oder
  Cloudinhalte. Jede Kategorie sichtbar prüfen.
- Autostart in Einstellungen oder Task-Manager einzeln deaktivieren und
  dokumentieren; nicht aus der Registry löschen.
- Clean Boot nur nach dem offiziellen Ablauf und mit dokumentierter Rückkehr
  zum normalen Start verwenden.
- `winget upgrade --all` und pauschale Deinstallationen sind kein
  Optimierungsstandard.

## Energie und Akku

- `powercfg /batteryreport` erzeugt einen lokalen Bericht mit Nutzungsdaten.
- `powercfg /energy` nur im Leerlauf und ohne offene Dokumente ausführen.
- Berichte können Gerätenamen und Nutzungsdetails enthalten; nicht automatisch
  hochladen.
- Energiepläne nicht pauschal auf Höchstleistung setzen. Bei Notebooks zuerst
  Ausbalanciert beziehungsweise Energieempfehlungen prüfen.

## Wiederherstellung

- System Restore betrifft Systemdateien und Einstellungen, ist aber kein
  Datenbackup.
- Das neuere Point-in-time Restore kann Apps, lokale Dateien, Kennwörter,
  Zertifikate und Schlüssel auf einen früheren Stand zurücksetzen.
- Vor Reset, Restore oder Neuinstallation separate Datensicherung und
  erreichbaren BitLocker-Wiederherstellungsschlüssel bestätigen.
- Recovery Drive, Reset und Installationsmedium können Daten oder Apps
  entfernen. Ziel und gewählte Option vor dem letzten Bestätigen wiederholen.

## Verbotene Abkürzungen

- keine Registry-Cleaner oder pauschalen Registry-Optimierungen;
- kein manuelles Löschen aus `WinSxS`, `Windows\Installer` oder dem Driver Store;
- kein `DISM /StartComponentCleanup /ResetBase` als normale Bereinigung;
- kein `DISM /RevertPendingActions` auf einem laufenden Windows;
- kein Abschalten von Update, Defender, Firewall, SmartScreen oder
  Manipulationsschutz;
- kein `vssadmin delete shadows`;
- keine unbegrenzten WPR-Aufzeichnungen oder ungefragten ETL-Uploads.
