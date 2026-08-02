# Softwarekatalog: Empfehlung, Einsatzgrenze und Ablehnung

## Empfohlen

| Werkzeug | Zweck | Einsatzgrenze | Begründung |
| --- | --- | --- | --- |
| Windows-Bordmittel | Task-Manager, Ressourcenmonitor, Zuverlässigkeitsverlauf, Speicher, Windows Update | erster Diagnoseweg | integriert, nachvollziehbar, keine zusätzliche Software |
| Autoruns (Microsoft Sysinternals) | vollständige Sichtung von Autostarts | nur prüfen, einzelne Einträge nach Beleg deaktivieren | zeigt weit mehr Autostartorte als der Task-Manager |
| Process Explorer (Microsoft Sysinternals) | Prozesse, Handles und geladene DLLs verstehen | nur bei konkretem App-/Dateiproblem | findet blockierende Prozesse statt zu raten |
| Process Monitor (Microsoft Sysinternals) | Datei-, Registry- und Prozesszugriffe analysieren | kurze, gefilterte Aufnahme; kann sensible Pfade enthalten | hohe Beweiskraft bei reproduzierbaren Fehlern |
| RAMMap (Microsoft Sysinternals) | Speicherbelegung erklären | Diagnose, niemals automatisches „RAM-Leeren“ | trennt Cache, Kernel, Treiber und Prozessspeicher |
| WPR/WPA (Windows Performance Toolkit) | Boot-, CPU-, Datenträger- und Reaktionsprobleme messen | nur bei reproduzierbarem Engpass; ETL lokal behandeln | liefert ETW-basierte Ursache statt Tuning-Vermutung |
| Defender Performance Analyzer | Defender-bedingte Last eingrenzen | nur nach Auffälligkeit; keine automatische Ausnahme | Microsoft-Werkzeug für genau diesen Befund |

## Nur nach konkretem Befund

| Maßnahme oder Software | Vorbedingung | Schutzregel |
| --- | --- | --- |
| OEM-Tool des PC-Herstellers | exaktes Modell, klarer Gerätebezug | nur offizielle Quelle; keine pauschalen „Optimierungen“ |
| WinGet | exakte Paket-ID, Quelle, Herausgeber und Lizenz geprüft | einzeln installieren/aktualisieren, nie `upgrade --all` |
| Defender-Ausnahme | Messung belegt erhebliche Last durch vertrauenswürdigen Prozess oder Buildpfad | kleinster Pfad, dokumentierter Zweck, Ablaufprüfung und Rückweg |
| Delivery-Optimization-Limit | Updates beeinträchtigen nachweislich die Leitung | Bandbreite begrenzen statt Sicherheitsupdates dauerhaft auszuschalten |
| Clean Boot | wiederholbarer Konfliktverdacht | Testzustand dokumentieren, Dienste schrittweise zurücknehmen |

## Ablehnen

| Kategorie | Warum | Sichere Alternative |
| --- | --- | --- |
| Registry-Cleaner | können gültige Einträge beschädigen; Nutzen nicht belegt | konkreten Fehler mit Hersteller-/Microsoft-Anleitung lösen |
| Driver-Booster und Treiberarchive | Modellbezug, Herkunft und Rollback oft unklar | Windows Update, OEM oder Komponentenhersteller |
| RAM-Booster / „Standby List Cleaner“ | kaschieren Symptome und stören Speicher-Caching | RAMMap oder Prozessanalyse, echte Ursache beheben |
| Game-Booster | deaktivieren oft Dienste oder Sicherheit für kaum belegbaren Nutzen | Spielprofil, GPU-Treiber und konkrete Engpassmessung |
| Debloat-Skripte aus Videos/GitHub | Änderungen oft breit, schwer prüfbar und schlecht rückbaubar | einzelne, dokumentierte Einstellung mit Zustimmung |
| Deaktivieren von Defender, Firewall, SmartScreen, Secure Boot oder BitLocker | Sicherheitsverlust überwiegt Bequemlichkeit | Konflikt oder Fund gezielt analysieren |
| Pauschales Abschalten von Windows Search, SysMain, Auslagerungsdatei oder Updates | kann Suche, Stabilität, Speicherverwaltung und Updates verschlechtern | nur bei belastbarem Einzelbefund prüfen |
