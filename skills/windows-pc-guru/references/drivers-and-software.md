# Treiber und Software

## Treiberentscheidung

Ein funktionierender Treiber wird nicht allein wegen einer höheren
Versionsnummer ersetzt. Prüfe zuerst:

- exaktes PC-/Mainboardmodell und Windows-Build,
- Hardware-ID, Anbieter, INF, Version und Datum,
- konkretes Problem oder Sicherheitsbulletin,
- OEM-Anpassungen bei Notebook, Komplett-PC und Hybridgrafik,
- Release Notes, Signatur, Sicherung und Rollback.

## Quellenreihenfolge

1. Windows Update und optionale Updates als geprüfte Quelle sichten.
2. Bei Notebook oder Komplett-PC die offizielle OEM-Supportseite für das exakte
   Modell bevorzugen, wenn das Paket gerätespezifische Anpassungen enthält.
3. Bei Selbstbau-PCs Mainboard-/Komponentenhersteller verwenden.
4. Generische GPU-, WLAN- oder Chipsatzpakete nur einsetzen, wenn sie zum Gerät
   passen und der OEM-Weg das konkrete Problem nicht löst.
5. Keine Downloadportale, Driver-Booster oder fremde Treiberarchive verwenden.

„Windows Update immer zuerst“ ist eine Sichtungsregel, kein Befehl, jedes
optionale Paket zu installieren.

## Lesende Bestandsaufnahme

Geeignete Befehle:

```powershell
pnputil /enum-devices /problem /deviceids
pnputil /enum-drivers /files
```

`pnputil` ist in Windows enthalten. Die Ausgabe kann Geräteinstanz-IDs
enthalten; vor externer Weitergabe kürzen oder schwärzen.

Vor einer genehmigten Treiberänderung:

- vorhandenes Paket gegebenenfalls mit `pnputil /export-driver` sichern;
- neuen Installer lokal verfügbar halten, besonders bei Netzwerk/WLAN;
- Datei mit
  `scripts/Test-DriverPackage.ps1 -LiteralPath <Datei>` prüfen;
- Gerätemanager-Rollback oder OEM-Wiederherstellung als Rückweg klären;
- genau ein Paket installieren, neu starten und Funktion testen.

Eine gültige Authenticode-Signatur bestätigt den signierten Inhalt und
Unterzeichner, aber nicht automatisch die Eignung für dieses Gerät.

## Rote Linien bei Treibern

- kein `pnputil /delete-driver ... /force` als Aufräummaßnahme;
- kein willkürliches Deaktivieren, Entfernen oder Neustarten von Geräten;
- keine Abschaltung von Signaturprüfung, Secure Boot oder Testmodus;
- kein BIOS-/UEFI-/Firmwareupdate ohne konkreten Grund, Netzstrom,
  Herstelleranleitung, BitLocker-Vorsorge und frische G4-Zustimmung;
- keinen funktionierenden OEM-Grafiktreiber ungeprüft durch ein generisches
  Paket ersetzen;
- keine „saubere Installation“ als Standard, wenn sie Einstellungen oder
  Komponenten entfernt.

## WinGet sicher verwenden

Zunächst nur prüfen:

```powershell
winget --info
winget source list
winget upgrade
winget show --id <PAKET-ID> --exact --source winget
```

Danach höchstens ein bestätigtes Paket mit exakter ID und Quelle installieren
oder aktualisieren. Zeige vorher Paket-ID, Herausgeber, Quelle, Version,
Lizenzvereinbarungen und erforderliche Rechte.

Nicht als Standard verwenden:

- `winget upgrade --all`;
- `--force`, `--ignore-security-hash`, `--include-unknown`,
  `--include-pinned` oder `--uninstall-previous`;
- automatisches Akzeptieren von Paket- oder Quellenvereinbarungen;
- `winget source reset --force`;
- bloßen Anzeigenamen statt exakter Paket-ID.

WinGet ist ein Paketmanager, kein Beweis dafür, dass jedes konfigurierte Paket
von Microsoft stammt.

## Deinstallation

Vor einer Deinstallation:

1. Zweck und Abhängigkeiten des Eintrags prüfen.
2. Systemruntimes, WebView, Visual-C++-Redistributables, .NET, Treiberpakete und
   OEM-Komponenten nicht pauschal entfernen.
3. Benutzerdaten, Lizenz, Konfiguration und Rückinstallationsquelle klären.
4. Exakten Eintrag und Wirkung zeigen, Zustimmung einholen, einzeln entfernen.
5. Anwendung und System nach jeder Entfernung testen.
