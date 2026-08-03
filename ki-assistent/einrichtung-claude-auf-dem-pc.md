# Claude direkt auf dem Windows-11-PC einrichten (Weg B)

Ziel: Claude läuft **auf dem PC selbst** und kann dort – mit Ihrer Bestätigung
pro Aktion – Diagnose- und Wartungsbefehle wirklich ausführen, statt sie nur
zu diktieren.

Voraussetzung: Ein Claude-Konto (claude.ai) mit Pro- oder Max-Abo.

---

## Variante 1: Claude Desktop-App (empfohlen für den Einstieg)

1. **Herunterladen:** <https://claude.ai/download> → Windows-Version
   installieren und mit dem Claude-Konto anmelden.
2. **Handbuch verfügbar machen:** Dieses Repository als ZIP herunterladen
   (GitHub → grüner Button **Code → Download ZIP**) und z. B. nach
   `C:\Users\<Name>\pc-wartung` entpacken.
3. **Arbeitsauftrag starten:** In der Desktop-App einen Datei-/Ordnerzugriff
   auf `C:\Users\<Name>\pc-wartung` gewähren und schreiben:
   > „Lies `ki-assistent/SKILL.md` und halte dich strikt daran.
   > Starte mit Phase 1 (Bestandsaufnahme) aus `01-bestandsaufnahme.md`."
4. Die App fragt vor jeder Aktion (Befehl ausführen, Datei lesen/schreiben)
   um Erlaubnis – **diese Nachfragen aktiviert lassen.**

## Variante 2: Claude Code (Terminal, volle Kontrolle)

1. **Installieren:** PowerShell öffnen (normale Rechte genügen) und ausführen:

   ```powershell
   irm https://claude.ai/install.ps1 | iex
   ```

   Alternativ mit Node.js: `npm install -g @anthropic-ai/claude-code`.
   Details: <https://claude.com/claude-code>

2. **Arbeitsordner anlegen und Handbuch holen** (ZIP wie oben entpacken oder,
   falls Git installiert ist, das private Repo klonen):

   ```powershell
   cd $env:USERPROFILE; mkdir pc-wartung; cd pc-wartung
   ```

3. **Skill einbinden:** Die Datei `ki-assistent/SKILL.md` aus diesem Repo
   nach `pc-wartung\.claude\skills\windows-11-pc-wartung\SKILL.md` kopieren –
   dann lädt Claude Code den Skill in diesem Ordner automatisch.

4. **Starten:**

   ```powershell
   claude
   ```

   Erste Nachricht:
   > „Nutze den Skill windows-11-pc-wartung. Starte Phase 1:
   > Bestandsaufnahme – führe die Erfassungsbefehle selbst aus und
   > erstelle die priorisierte Problemliste."

5. Claude Code fragt vor jedem Befehl um Erlaubnis. Für Admin-Schritte
   (`DISM`, `sfc`, `chkdsk`) das Terminal **als Administrator** starten –
   aber erst ab Phase 3, und erst wenn Phase 2 (Backup) erledigt ist.

---

## Sicherheitsregeln für den lokalen Betrieb

- **Berechtigungsnachfragen niemals pauschal abschalten** (kein
  „skip permissions"-Modus). Jeder Befehl wird einzeln bestätigt.
- Reihenfolge einhalten: **Phase 1 (nur lesen) → Phase 2 (Backup) →
  erst dann Reparatur/Aufräumen.**
- Löschen, Deinstallieren und Verschieben persönlicher Dateien bestätigt
  der Nutzer einzeln – der Skill schreibt das vor, die Nachfrage der App
  ist das zweite Netz.
- Windows Defender, Firewall und Co. bleiben aktiv; BIOS/Registry bleiben tabu.
- Bei Unsicherheit: Aktion ablehnen und nachfragen – abgelehnte Aktionen
  kann Claude erklären und anders lösen.
