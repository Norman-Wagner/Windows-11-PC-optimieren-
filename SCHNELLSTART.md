# Schnellstart: Basisschutz in 60 Minuten

Für alle, die **jetzt** die wichtigsten Sicherheitsmaßnahmen umsetzen wollen
und die sechs Phasen später nachholen. Alles mit Windows-Bordmitteln, ohne
Adminkenntnisse, ohne Zusatzsoftware.

**Was dieser Schnellstart nicht ersetzt:** die vollständige
[Bestandsaufnahme](01-bestandsaufnahme.md), den [Backup-Plan](02-backup-plan.md)
nach dem 3-2-1-Prinzip, die [Reparaturphase](03-windows-pruefen-reparieren.md)
und das [Aufräumen](05-aufraeumen-optimieren.md). Er ist die Erste Hilfe,
nicht die Kur.

---

## Schritt 1: Wichtigste Daten sichern _(15 Minuten)_

Externe Festplatte oder großen USB-Stick anschließen (Beispiel: Laufwerk `E:`),
dann die wichtigsten Ordner kopieren:

```powershell
robocopy "$env:USERPROFILE\Documents" "E:\Schnellsicherung\Documents" /E /XJ /R:1 /W:1
robocopy "$env:USERPROFILE\Desktop"   "E:\Schnellsicherung\Desktop"   /E /XJ /R:1 /W:1
robocopy "$env:USERPROFILE\Pictures"  "E:\Schnellsicherung\Pictures"  /E /XJ /R:1 /W:1
```

Keine Adminrechte nötig. Details und weitere Ordner: [Phase 2.2](02-backup-plan.md).

## Schritt 2: Wiederherstellungspunkt anlegen _(5 Minuten)_

Windows-Taste + R → `systempropertiesprotection` → Laufwerk `C:` markieren →
ggf. _Konfigurieren → Computerschutz aktivieren_ → **Erstellen…** →
Name z. B. `Vor Schnellstart`. Details: [Phase 2.3](02-backup-plan.md).

## Schritt 3: Windows Update vollständig durchlaufen _(15 Minuten + Neustarts)_

_Einstellungen → Windows Update → Nach Updates suchen._ Installieren,
neu starten, **erneut suchen** – so lange, bis „Sie sind auf dem neuesten
Stand" erscheint. Details: [Phase 3.1](03-windows-pruefen-reparieren.md).

## Schritt 4: Schutzstatus komplett prüfen _(10 Minuten)_

_Einstellungen → Datenschutz und Sicherheit → Windows-Sicherheit:_ alle
Bereiche öffnen – **Viren- & Bedrohungsschutz**, **Firewall- &
Netzwerkschutz**, **App- & Browsersteuerung**, **Gerätesicherheit**. Alles
muss grün sein; Hinweise ernst nehmen, nichts abschalten.
Details: [Phase 3.2](03-windows-pruefen-reparieren.md).

Optional als Bericht (nur lesend, keine Adminrechte):

```powershell
pwsh -NoProfile -File .\skills\windows-pc-guru\scripts\Get-SecurityBaselineReport.ps1
```

## Schritt 5: Browser und gespeicherte Zugänge absichern _(10 Minuten)_

Im Browser prüfen: Updates installiert? (Edge: _Menü → Hilfe und Feedback →
Infos zu Microsoft Edge_). Danach in den Kontoeinstellungen des
Microsoft-Kontos die **Zwei-Faktor-Anmeldung** aktivieren, falls noch nicht
geschehen: <https://account.microsoft.com/security>.

## Schritt 6: Autostart entschlacken _(5 Minuten)_

Strg + Umschalt + Esc → Task-Manager → _Autostart von Apps_ → offensichtlich
Unnötiges **deaktivieren** (nicht deinstallieren, nicht löschen).
Details: [Phase 5.3](05-aufraeumen-optimieren.md).

---

**Danach:** Den vollständigen Ablaufplan in der [README](README.md) durchgehen
– insbesondere [Phase 2](02-backup-plan.md) für ein echtes Backup-Konzept und
[Phase 7](07-wartungsroutine.md), damit der Schutz erhalten bleibt. Den
Fortschritt festhalten in der
[Fortschritts-Checkliste](vorlagen/fortschritts-checkliste.md).
