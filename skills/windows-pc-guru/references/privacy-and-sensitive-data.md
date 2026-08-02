# Datenschutz und sensible Diagnosedaten

## Firmenmodus ohne Cloud-KI

Für Firmenrechner ohne freigegebenen AVV/DPA und KI-Rahmen gilt [corporate-local-only.md](corporate-local-only.md). Die darin genannten Sperrregeln haben Vorrang. Eine Chat- oder KI-Anweisung „nur keine Dateien lesen“ ist keine technische oder vertragliche Absicherung.

## Datensparsamkeit

Erfasse nur, was eine konkrete Hypothese prüft. Ein kompletter Export von
Ereignisprotokollen, Browserprofilen, Benutzerordnern oder installierten
Programmen ist kein Standard.

Ohne eigene, frische Zustimmung nicht lesen:

- E-Mails, Messenger, Browserhistorie, Cookies oder gespeicherte Anmeldungen;
- Dokumente, Fotos, Videos oder Cloudinhalte;
- Passwortmanager, Schlüssel, Tokens oder Lizenzdaten;
- dienstliche Daten, Mandanten-/Kundendaten oder fremde Benutzerprofile;
- vollständige Absturzabbilder und ETL-Aufzeichnungen.

## Nicht in Berichte aufnehmen

- Passwörter, Wiederherstellungs-, Produkt- oder API-Schlüssel;
- vollständige Seriennummern, MAC-Adressen oder Geräteinstanz-IDs;
- öffentliche IP-Adressen, E-Mail-Adressen und Kontonamen;
- vollständige lokale Benutzerpfade;
- Dokumenttitel, Dateinamen oder Nachrichteninhalte ohne Notwendigkeit.

Verwende Platzhalter wie `<BENUTZER>`, `<GERÄT>`, `<LAUFWERK>` und
`<PAKET-ID>`. Kürze Logs auf das relevante Zeitfenster und die relevanten
Felder.

## Diagnosewerkzeuge

- `Get-WindowsPcSnapshot.ps1` vermeidet Computername, Benutzername,
  Seriennummer, MAC/IP und persönliche Dateipfade.
- Batterie-, Energie-, CBS-, DISM-, Defender-, Ereignis- und WPR-Berichte
  können trotzdem identifizierende Details enthalten.
- WPR/ETL nur bei reproduzierbarem Problem, zeitlich begrenzt und lokal
  verwenden. Nie automatisch hochladen.
- Duplikat- oder Dateiscans nur für einen ausdrücklich gewählten Ordner
  durchführen. Hashberichte mit vollständigen Pfaden wie sensible Dateien
  behandeln.

## Lokale Speicherung und Weitergabe

1. Nutzer wählt Speicherort und Aufbewahrungsdauer.
2. Vor Weitergabe Vorschau erzeugen und identifizierende Felder schwärzen.
3. Keine Diagnosedaten an Drittanbieter senden, wenn eine lokale Auswertung
   genügt.
4. Temporäre Exporte nach Abschluss nur mit Zustimmung löschen.
5. In öffentlichen Issues oder Chats nur minimale, bereinigte Auszüge teilen.

## E-Mail- und Browserzugriff

Eine allgemeine PC-Diagnose autorisiert keinen Zugriff auf Postfach oder
Browserdaten. Ist ein solcher Zugriff wirklich nötig, zeige vorher den
technischen Ansatz, begrenze ihn auf Lesen, einen konkreten Zeitraum und den
kleinstmöglichen Datenumfang und hole unmittelbar davor eine gesonderte
Zustimmung ein.
