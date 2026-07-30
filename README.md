# Windows-PC-Guru

Ein sicherer, deutschsprachiger Agent-Skill für Windows 11: **PC-Guru,
PC-Doktor, Programmierer und Softwareexperte in einem**, aber ohne
Tuning-Mythen und riskante Automatismen.

Der Skill diagnostiziert symptomorientiert, erklärt Befunde verständlich und
fordert vor jeder Änderung eine konkrete Freigabe. Er eignet sich für ChatGPT,
OpenAI Codex, Claude, GitHub Copilot und weitere Werkzeuge, die den offenen
[Agent-Skills-Standard](https://agentskills.io/) unterstützen.

Entwickelt und veröffentlicht von **Norman Wagner / WagnerConnect**.

## Was der Skill kann

- langsame, instabile oder nicht startende Windows-11-PCs eingrenzen;
- Update-, Treiber-, Speicher-, Netzwerk-, Akku- und Autostartprobleme prüfen;
- Bluescreens und Ereignisse zeitlich und ursachenbezogen auswerten;
- lokale Build-, PATH-, Laufzeit-, Shell- und Toolchain-Probleme lösen;
- sichere PowerShell-Automatisierungen mit Dry-Run und Rückweg entwickeln;
- Treiber-/Installerdateien lokal hashen und ihre Signatur prüfen;
- datensparsame, rein lesende Systemübersichten erstellen.

## Was er bewusst nicht tut

- keine Registry-Cleaner, Driver-Booster, Debloat- oder „Turbo“-Skripte;
- kein Abschalten von Defender, Firewall, SmartScreen, Secure Boot oder
  Signaturprüfung;
- keine Löschung, Installation, Treiber-, BIOS-, BitLocker- oder
  Partitionierungsänderung ohne konkrete Zustimmung und Rückweg;
- kein Zugriff auf E-Mails, Browserdaten oder persönliche Dateien als Teil
  einer normalen PC-Diagnose;
- keine erfundenen Diagnosen: Eine Verbesserung gilt erst nach Messung als
  bestätigt.

## Installation

Der kanonische Skill liegt unter
[`skills/windows-pc-guru/`](skills/windows-pc-guru/).

### ChatGPT

Den Ordner `skills/windows-pc-guru` als ZIP herunterladen und in ChatGPT unter
**Plugins > Skills > Create > Upload** hochladen. Skills sind je nach
ChatGPT-Tarif und Workspace-Einstellung verfügbar. OpenAI beschreibt Upload,
Prüfung und Freigabe im
[Help Center](https://help.openai.com/en/articles/20001066).

### OpenAI Codex

```powershell
npx skills add Norman-Wagner/Windows-11-PC-optimieren- --skill windows-pc-guru
```

Alternativ den Skill-Ordner nach
`~/.agents/skills/windows-pc-guru/` kopieren.

### Claude Code

Das gesamte Repository als Plugin testen:

```powershell
claude --plugin-dir .
```

Oder nur den Skill-Ordner nach
`.claude/skills/windows-pc-guru/` beziehungsweise
`~/.claude/skills/windows-pc-guru/` kopieren. Siehe
[Claude Code Skills](https://code.claude.com/docs/en/slash-commands).

### GitHub Copilot

Copilot erkennt Agent Skills projektbezogen unter `.github/skills`,
`.claude/skills` oder `.agents/skills`. Der gemeinsame Skill kann dorthin
installiert werden; zusätzlich enthält dieses Repository einen
Copilot-Agenten unter `.github/agents/`. Siehe
[GitHub Customization Cheat Sheet](https://docs.github.com/en/copilot/reference/customization-cheat-sheet).

### Andere Agenten

Werkzeuge mit Agent-Skills-Unterstützung können den Ordner direkt installieren.
Bei Systemen ohne Skill-Import dient `SKILL.md` als kopierbare Anweisung; die
PowerShell-Skripte bleiben lokal und werden nicht automatisch ausgeführt.

## Sicherheitsmodell

| Stufe | Beispiel | Erlaubnis |
| --- | --- | --- |
| G0 | Erklärung und Planung | direkt |
| G1 | nicht sensible, lesende Diagnose | zweckgebunden |
| G2 | reversible Einstellung | konkreter Plan + Zustimmung |
| G3 | Adminbefehl, Treiber, Installation, Neustart | zusätzlich Backup und Rückweg |
| G4 | BIOS, BitLocker, Partitionen, Reset, Befall | niemals autonom |

Die vollständigen Regeln stehen in
[`safety-and-consent.md`](skills/windows-pc-guru/references/safety-and-consent.md).

## Enthaltene Werkzeuge

- [`Get-WindowsPcSnapshot.ps1`](skills/windows-pc-guru/scripts/Get-WindowsPcSnapshot.ps1):
  rein lesende Übersicht ohne Computername, Benutzername, Seriennummer,
  MAC/IP oder persönliche Dateien; kein Netzwerkzugriff.
- [`Test-DriverPackage.ps1`](skills/windows-pc-guru/scripts/Test-DriverPackage.ps1):
  SHA-256 und Authenticode-Status einer bereits lokalen Datei; kein Download,
  keine Installation.

## Menschliches Windows-Handbuch

Zusätzlich zum Agent-Skill enthält das Repository einen schrittweisen Leitfaden:

1. [Bestandsaufnahme](01-bestandsaufnahme.md)
2. [Backup-Plan](02-backup-plan.md)
3. [Windows prüfen und reparieren](03-windows-pruefen-reparieren.md)
4. [Treiber aktualisieren](04-treiber-aktualisieren.md)
5. [Aufräumen und optimieren](05-aufraeumen-optimieren.md)
6. [Dateien organisieren](06-ordnungssystem-dateien.md)

Der Skill verwendet diese sechs Phasen nicht starr. Bei einem einzelnen
WLAN-, Build- oder Akku-Problem wählt er nur den passenden Diagnosepfad.

## Repository prüfen

```powershell
pwsh -NoProfile -File .\scripts\Test-Repository.ps1 -RunDiagnosticsSmokeTest
```

Die Prüfung validiert Skill-Metadaten, Referenzen, JSON-Manifeste,
PowerShell-Syntax und einen rein lesenden Diagnose-Smoke-Test.

Ein Upload-ZIP für ChatGPT oder Claude erzeugen:

```powershell
pwsh -NoProfile -File .\scripts\Build-SkillPackage.ps1
```

Das Skript validiert zuerst das Repository und erstellt anschließend
`dist/windows-pc-guru.zip` mit `SKILL.md` im ZIP-Wurzelverzeichnis.

## Lizenz und Verantwortung

Apache License 2.0, siehe [LICENSE.txt](LICENSE.txt). Die Inhalte sind eine technische
Arbeitshilfe und ersetzen keine Datensicherung, Herstellerfreigabe oder
Vor-Ort-Diagnose. Vor riskanten Änderungen bleiben Nutzerentscheidung,
passender Rückweg und aktuelle offizielle Quellen maßgeblich.
