# Phase 6: Ordnungssystem – Privat/Dienstlich trennen, Fotos sortieren, Duplikate finden

**Regeln dieser Phase:**

- **Vor jedem Verschieben, Umbenennen oder Zusammenführen wird gefragt.**
  Der Ablauf ist immer: analysieren → Vorschlag → Freigabe → umsetzen.
- Verschieben statt löschen: Originale bleiben erhalten, bis das neue System
  geprüft ist. Gelöscht wird erst ganz am Ende – nach Freigabe und mit aktuellem
  Backup (Phase 2).
- Alle Werkzeuge: Explorer, `robocopy`, PowerShell – keine Zusatzsoftware nötig.

---

## 6.1 Ziel-Ordnungssystem (Vorschlag)

Eine flache, sprechende Struktur unterhalb des Benutzerordners (oder auf einer
Datenpartition wie `D:`), die auch in fünf Jahren noch verständlich ist:

```
Dokumente/
├── Privat/
│   ├── Finanzen/          (Konto, Steuern → Unterordner pro Jahr: 2024, 2025 …)
│   ├── Versicherungen/
│   ├── Wohnen/            (Miete/Eigentum, Verträge, Nebenkosten)
│   ├── Gesundheit/
│   ├── Familie/
│   └── Anleitungen-Belege/ (Geräte, Garantien, Kaufbelege)
├── Dienstlich/
│   ├── <Arbeitgeber/Projektname>/
│   ├── Verträge-Personal/  (Arbeitsvertrag, Gehalt, Zeugnisse)
│   └── Fortbildung/
└── _Eingang/               (Sammelstelle für Unsortiertes – wöchentlich leeren)

Bilder/
├── Fotos/
│   ├── 2024/
│   │   ├── 2024-06 Urlaub Ostsee/
│   │   └── 2024-12 Weihnachten/
│   └── 2025/ …
├── Screenshots/
└── Scans/

Videos/
└── 2025/ … (gleiche Jahres-/Ereignislogik wie Fotos)
```

**Prinzipien:**

- **Erst Privat/Dienstlich, dann Thema, dann Jahr** – so bleibt die Trennung oben sichtbar.
- **Fotos: Jahr → „JJJJ-MM Ereignis"** – sortiert sich chronologisch von selbst.
- **Dateinamen mit Datum vorn:** `2026-07-15 Rechnung Autowerkstatt.pdf` –
  eindeutig sortierbar, auch außerhalb des Ordners verständlich.
- **Maximal 3–4 Ebenen tief** – tiefere Verschachtelung wird nicht mehr gepflegt.
- Der Ordner **`_Eingang/`** verhindert, dass der Desktop und `Downloads` wieder
  zur Dauerablage werden.

⚠️ **Dienstliche Daten:** Vorgaben des Arbeitgebers beachten (Aufbewahrung,
private Cloud-Sync meist nicht erlaubt). Dienstliche Ordner ggf. von der
OneDrive-Sicherung ausnehmen (Phase 2.6).

## 6.2 Bestand analysieren (ohne etwas zu verändern)

**Übersicht über die größten Platzfresser (keine Adminrechte):**

```powershell
Get-ChildItem $env:USERPROFILE -Directory | ForEach-Object { [PSCustomObject]@{ Ordner = $_.Name; 'GB' = [math]::Round((Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum/1GB,2) } } | Sort-Object GB -Descending
```

Misst die Größe jedes Ordners im Benutzerprofil. Das Ergebnis zeigt, wo sich die
Arbeit lohnt. Für weitere Orte (`D:\`, externe Platten) den Pfad anpassen.

## 6.3 Duplikate finden (nur berichten, nichts löschen)

**Keine Adminrechte.** Dieses Skript vergleicht Dateien **inhaltlich** (per
SHA-256-Prüfsumme, nicht nur nach Name) und schreibt einen Bericht auf den
Desktop – es verändert und löscht **nichts**:

```powershell
$ordner = "$env:USERPROFILE\Documents", "$env:USERPROFILE\Pictures", "$env:USERPROFILE\Desktop", "$env:USERPROFILE\Downloads"
Get-ChildItem $ordner -Recurse -File -ErrorAction SilentlyContinue |
  Group-Object Length | Where-Object Count -gt 1 |
  ForEach-Object { $_.Group } |
  Get-FileHash -Algorithm SHA256 -ErrorAction SilentlyContinue |
  Group-Object Hash | Where-Object Count -gt 1 |
  ForEach-Object { $_.Group | Select-Object @{n='Gruppe';e={$_.Hash.Substring(0,8)}}, Path } |
  Export-Csv "$env:USERPROFILE\Desktop\duplikate-bericht.csv" -NoTypeInformation -Encoding UTF8
```

_Ablauf:_ Erst werden nur Dateien gleicher Größe vorausgewählt (schnell), dann
per Prüfsumme bestätigt. Gleiche „Gruppe" in der CSV = identischer Inhalt.
Bei großen Fotosammlungen kann das eine Weile dauern.

**Auswertung gemeinsam:** Die Datei `duplikate-bericht.csv` in Excel öffnen.
Pro Gruppe wird entschieden, **welcher Pfad das Original bleibt** (in der Regel
der Ort im neuen Ordnungssystem). Erst nach dieser Durchsicht und ausdrücklicher
Freigabe werden Kopien gelöscht – Papierkorb an, Backup aktuell.

## 6.4 Neue Struktur anlegen und befüllen (nach Freigabe)

**Schritt 1 – Leere Zielstruktur anlegen (keine Adminrechte, ändert keine Bestandsdaten):**

```powershell
$basis = "$env:USERPROFILE\Documents"
"Privat\Finanzen","Privat\Versicherungen","Privat\Wohnen","Privat\Gesundheit","Privat\Familie","Privat\Anleitungen-Belege","Dienstlich","_Eingang" | ForEach-Object { New-Item -ItemType Directory -Path (Join-Path $basis $_) -Force | Out-Null }
```

**Schritt 2 – Ordnerweise umziehen.** Pro Quellordner: kurze Durchsicht →
Zuordnung (privat/dienstlich, Thema) → Freigabe → dann **kopieren, prüfen,
Original erst später löschen**:

```powershell
robocopy "C:\Alter\Ordner" "$env:USERPROFILE\Documents\Privat\Finanzen" /E /XJ /R:1 /W:1
```

Kopiert (löscht nichts). Nach Stichprobe im Ziel wird der Quellordner zunächst
nur in `_Alt-zur-Kontrolle` umbenannt; endgültig gelöscht wird er erst, wenn das
neue System zwei bis vier Wochen im Alltag funktioniert hat.

## 6.5 Fotos und Videos nach Datum sortieren

**Schritt 1 – Analyse (nichts wird verändert):** Dieses Skript zeigt nur, wie
viele Fotos pro Jahr/Monat vorhanden sind (nach Aufnahme-/Änderungsdatum):

```powershell
Get-ChildItem "$env:USERPROFILE\Pictures" -Recurse -File -Include *.jpg,*.jpeg,*.png,*.heic,*.mp4,*.mov -ErrorAction SilentlyContinue | Group-Object { $_.LastWriteTime.ToString('yyyy-MM') } | Sort-Object Name | Format-Table Name, Count
```

**Schritt 2 – Nach Freigabe:** Pro Monat einen Ordner `Fotos\JJJJ\JJJJ-MM` anlegen
und die Dateien **kopieren** (wieder `robocopy`, wie 6.4). Ereignisnamen
(„2024-06 Urlaub Ostsee") werden anschließend manuell ergänzt – das Datum liefert
die Technik, den Namen liefert die Erinnerung.

⚠️ WhatsApp-Bilder, Screenshots und Kamera-Importe vorher grob trennen –
sonst landen 2 000 Chat-Bilder zwischen den Urlaubsfotos.

## 6.6 Das System am Leben halten (Dauerbetrieb)

- **Wöchentlich 10 Minuten:** `_Eingang/` und `Downloads/` leeren, Neues einsortieren.
- **Neue Fotos:** einmal im Monat vom Handy in `Fotos\JJJJ\JJJJ-MM …` übernehmen.
- **Desktop-Regel:** Der Desktop ist Arbeitsfläche, kein Archiv – was bleiben
  soll, bekommt einen Platz im System.
- **Jahreswechsel:** Neue Jahresordner anlegen; Abgeschlossenes (alte Verträge,
  erledigte Projekte) in einen Unterordner `Archiv/` im jeweiligen Themenordner.
- **Backup-Check (Phase 2) vierteljährlich:** Läuft der Dateiversionsverlauf?
  Stichprobe aus der Sicherung öffnen.

---

**Damit ist der Gesamtdurchlauf abgeschlossen.** Die Problemliste sollte jetzt
leer oder auf P4-Restpunkte geschrumpft sein. Halbjährlich lohnt ein Kurzdurchlauf
von Phase 3.1–3.2 (Updates, Sicherheit) und ein Blick in `perfmon /rel`.
