# Profil: Entwicklung und Builds

Prioritäten: reproduzierbare Toolchains, Build-Geschwindigkeit und Schutz vertraulicher Quelltexte.

- Erst Versionen, Lockdatei, PATH, Shell, Architektur und CI vergleichen.
- Entwicklungswerkzeuge pro Projekt statt global installieren, wenn möglich.
- Defender-Leistung nur messen; Ausnahmen sind Ausnahmefälle und müssen eng, zeitlich begrenzt und überprüfbar sein.
- Keine Tokens, SSH-Schlüssel, `.env`-Dateien oder private Repositories in Diagnoseberichte aufnehmen.
- Große Buildordner nur nach Zustimmung analysieren; vollständige Pfade als sensibel behandeln.
