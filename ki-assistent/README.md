# KI-Assistent: Allgemeiner Skill für ChatGPT, Claude und Perplexity

Die Datei [`SKILL.md`](SKILL.md) enthält die komplette Rollen-, Regel- und
Ablaufbeschreibung des PC-Wartungs-Assistenten – als **plattformunabhängiger
Prompt**. Der Textblock ab „# Rolle" funktioniert überall per Copy-Paste;
der YAML-Kopf (`---`-Block) ist nur für Claude-Skills relevant und kann bei
anderen Plattformen mitkopiert oder weggelassen werden.

## Verwendung pro Plattform

### Claude (claude.ai / Claude Desktop / Claude Code)

- **Als Projekt:** Neues Projekt anlegen → den Inhalt von `SKILL.md` in die
  **Projektanweisungen** einfügen. Zusätzlich die Handbuch-Dateien
  (`01`–`06`, `vorlagen/`) als Projektwissen hochladen – dann kann Claude
  direkt auf die Phasen verweisen.
- **Als Skill (Claude Code / claude.ai-Skills):** Den Ordner `ki-assistent/`
  als Skill-Ordner verwenden – `SKILL.md` ist bereits im Skill-Format
  (YAML-Frontmatter mit `name` und `description`). In Claude Code z. B. unter
  `.claude/skills/windows-11-pc-wartung/SKILL.md` ablegen.

### ChatGPT (chatgpt.com)

- **Als eigenes GPT:** „GPT erstellen" → den Text ab „# Rolle" in die
  **Instructions** einfügen; die Handbuch-Dateien optional als
  Wissensdateien hochladen.
- **Ohne eigenes GPT:** Den Text einfach als erste Nachricht in einen neuen
  Chat einfügen („Du bist … halte dich an folgende Regeln") – wirkt für die
  gesamte Unterhaltung.

### Perplexity (perplexity.ai)

- **Als Space:** Neuen Space anlegen → den Text ab „# Rolle" in die
  **Custom Instructions / Anweisungen** des Space einfügen; Handbuch-Dateien
  als Dateien in den Space hochladen.
- **Ohne Space:** Text als erste Nachricht einfügen; bei längeren
  Unterhaltungen gelegentlich an die Regeln erinnern.

## Wichtige Hinweise

- **Kein KI-Dienst kann den PC fernsteuern.** Der Assistent nennt Befehle und
  wertet Ausgaben aus – ausführen muss sie der Nutzer selbst. (Ausnahme:
  lokal installierte Agenten wie Claude Code/Claude Desktop auf dem PC selbst,
  die mit Zustimmung Befehle ausführen können.)
- **Keine sensiblen Daten einfügen:** Beim Teilen von Befehlsausgaben keine
  Passwörter, Lizenzschlüssel, vollständigen Seriennummern oder dienstliche
  Dokumente mitschicken.
- Die Regeln in `SKILL.md` sind das Sicherheitsnetz: Backup vor Eingriff,
  nichts löschen ohne Freigabe, keine Tuning-Tools, Defender bleibt an –
  unabhängig davon, welche KI den Prompt ausführt.
