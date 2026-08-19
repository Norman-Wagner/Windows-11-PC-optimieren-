# Remediation-Kompatibilität

Vor jedem produktiven Remediation-Preview muss der lokale Kompatibilitätskontext geprüft werden.

## Geprüfte Merkmale

- Windows-Familie
- Windows-Edition
- Windows-Build
- Architektur
- Gerätetyp
- erforderliche lokale Diagnosefähigkeiten

## Status

### Compatible

Alle für den Katalogeintrag erforderlichen Merkmale sind bekannt und unterstützt. Erst dann darf die Change Engine einen Preview-Plan erzeugen.

### Blocked

Mindestens ein bekanntes Merkmal widerspricht den Compatibility-Regeln, zum Beispiel Windows Server statt Windows 11, ein Build unter `MinBuild`, eine nicht unterstützte Architektur oder eine fehlende erforderliche Fähigkeit. Keinen Änderungsplan erzeugen und nicht fortfahren.

### ReviewRequired

Mindestens ein entscheidendes Merkmal ist nicht verlässlich bestimmbar. Unbekannte Edition, Build, Architektur oder Gerätetyp niemals stillschweigend als kompatibel behandeln. Technischen Kontext zuerst klären.

## Fail-closed-Regel

Nur `Compatible` setzt `Allowed = true`. `Blocked` und `ReviewRequired` setzen `Allowed = false`.

## Build-Grenzen

`MinBuild` und `MaxBuild` gehören zum einzelnen Katalogeintrag. Eine fehlende obere Grenze bedeutet nicht, dass zukünftige Builds automatisch fachlich freigegeben sind. Zeitabhängige oder buildabhängige Empfehlungen müssen bei Bedarf anhand aktueller offizieller Herstellerdokumentation überprüft werden.

## Fähigkeiten

`RequiredCapabilities` beschreibt lokal nachweisbare technische Voraussetzungen, nicht Benutzerrechte oder eine Ausführungserlaubnis. Eine vorhandene Fähigkeit ersetzt weder Zustimmung noch Risiko-, Reversibilitäts- oder Rückwegprüfung.
