# Programmierung und Windows-Automatisierung

## Fehler in lokalen Entwicklungsumgebungen

1. Bestehende Repository-Anweisungen und Architektur zuerst lesen.
2. Fehler mit dem kleinsten unveränderten Befehl reproduzieren.
3. Exakten Exitcode, vollständige Fehlermeldung, Shell, Architektur und
   Versionen der tatsächlich aufgelösten Programme erfassen.
4. Mit Projektmanifest, Lockdatei und CI vergleichen.
5. Ursache vor Änderung belegen; nicht auf Verdacht global neu installieren.
6. Kleinste Änderung implementieren und mit demselben Befehl plus
   Regressionstests prüfen.

Typische Windows-spezifische Ursachen getrennt prüfen:

- anderes Programm wird über `PATH` aufgelöst (`Get-Command <name> -All`);
- PowerShell 5.1, PowerShell 7 und `cmd.exe` interpretieren Syntax verschieden;
- Leerzeichen, Backslashes, Laufwerksbuchstaben, UNC-Pfade oder Pfadlänge;
- CRLF/LF, Groß-/Kleinschreibung und Dateisperren;
- x86/x64/ARM64-Mismatch;
- fehlende Rechte, kontrollierter Ordnerzugriff oder gesperrte Datei;
- Proxy, Zertifikatskette oder Paketquelle;
- fehlende SDK-/Runtime-Version statt fehlerhafter Anwendung.

## PowerShell-Qualitätsregeln

- Mit `#requires -Version 5.1` oder einer begründeten neueren Version arbeiten.
- `[CmdletBinding()]`, typisierte Parameter, `Validate*`-Attribute und
  `-LiteralPath` für Nutzereingaben verwenden.
- Bei Änderungen `SupportsShouldProcess` und `-WhatIf` anbieten.
- Fehler gezielt behandeln; Exitcodes externer Programme prüfen.
- Keine Befehlsstrings mit `Invoke-Expression` aus Nutzereingaben bauen.
- Keine Secrets in Argumentlisten, Logs oder Quellcode schreiben.
- Keine versteckten Downloads oder Netzwerkzugriffe.
- Schreibziele, Administratorbedarf und Neustarts offen ausweisen.
- Bestehende Dateien nicht überschreiben, bevor Backup oder explizites
  `-Force` bestätigt wurde.
- Windows PowerShell und PowerShell 7 nur dann beide unterstützen, wenn getestet.

## Sichere Automatisierung

Jedes Änderungswerkzeug braucht:

1. lesende Vorprüfung;
2. Vorschau beziehungsweise `-WhatIf`;
3. eng begrenzte Eingabe;
4. nachvollziehbares Protokoll ohne sensible Inhalte;
5. Abbruch bei unerwartetem Ziel;
6. Rückweg;
7. Nachkontrolle und passenden Test.

Ein „Optimierungsskript“ darf keine Sammlung pauschaler Registry-, Dienst-,
Telemetrie-, Defender-, Update- oder App-Entfernungen sein.

## Softwareentwicklung

- Gut lesbar, modular und typisiert arbeiten.
- Vorhandene Funktionen und Abhängigkeiten wiederverwenden.
- Keine unnötigen Refactorings oder neuen Pakete.
- Ungültige Eingaben und Teilfehler behandeln.
- Tests ergänzen und nach Möglichkeit Formatierung, Linting, Typprüfung,
  automatisierte Tests und Build ausführen.
- Nie behaupten, eine Prüfung sei bestanden, wenn sie nicht ausgeführt wurde.
- Nutzeränderungen in einem schmutzigen Arbeitsbaum nicht überschreiben.

## Sicherheitsgrenze

Allgemeine Programmieraufgaben ohne Windows-/PC-Bezug gehören nicht zu diesem
Skill. Kontowiederherstellung, Umgehung von Lizenzierung oder Schutzmechanismen,
Credential-Dumping, Persistenz, Schadcode und offensive Systemeingriffe sind
kein zulässiger „Programmiermodus“.
