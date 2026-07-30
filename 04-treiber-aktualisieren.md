# Phase 4: Treiber aktualisieren – sichere Reihenfolge

**Grundsätze:**

- Nur Quellen verwenden: **Windows Update** und **offizielle Hersteller-Websites**.
  Keine „Driver-Booster"-Tools – sie installieren häufig falsche oder gebündelte
  Software und sind ein Sicherheitsrisiko.
- **Vor jedem Treiberpaket:** Wiederherstellungspunkt vorhanden? (Phase 2.3 –
  bei Bedarf neuen anlegen: `systempropertiesprotection` → Erstellen…)
- **Nach jedem Treiber:** Neustart, kurz testen, erst dann der nächste.
  Niemals mehrere Treiberkategorien gleichzeitig installieren – sonst ist bei
  Problemen unklar, welcher Treiber schuld ist.
- **Funktioniert ein Gerät einwandfrei**, ist ein Update nur sinnvoll, wenn es
  Sicherheitskorrekturen bringt oder ein konkretes Problem aus der Problemliste
  adressiert. „Never change a running system" gilt besonders für Audio und Netzwerk.
- ⚠️ **Rückweg kennen:** Macht ein Treiber Probleme → `devmgmt.msc` → Gerät →
  Eigenschaften → Treiber → **Vorheriger Treiber**, oder Systemwiederherstellung.

**Vorbereitung – exakte Hardware feststellen** (aus Phase 1: Hersteller/Modell aus
`msinfo32`, GPU aus `dxdiag`). Bei Fertig-PCs und Notebooks (Dell, HP, Lenovo …)
ist die **Support-Seite des PC-Herstellers** die erste Adresse; bei Selbstbau-PCs
die Seite des **Mainboard-Herstellers** (Modell steht in `msinfo32` unter
„BaseBoard-Produkt").

---

## Schritt 1: Windows Update (Basis)

_Einstellungen → Windows Update → Erweiterte Optionen → Optionale Updates →
Treiberupdates._ **Adminrechte:** Windows fragt bei Bedarf.

Hier liegen von Microsoft geprüfte Treiber – die sicherste Quelle. Angebotene
Treiberupdates einzeln installieren, neu starten. Für viele PCs ist danach schon
alles Wesentliche aktuell.

## Schritt 2: PC- bzw. Mainboard-Hersteller

Die Support-Seite des Herstellers mit der exakten Modell- oder Seriennummer
aufrufen (z. B. Dell SupportAssist-Seite, HP Support, Lenovo Support, bzw.
ASUS/MSI/Gigabyte/ASRock für Mainboards). Dort werden Treiber passend zum Gerät
gelistet. Nur Treiber laden, die **neuer** sind als die installierte Version –
und nur die Kategorien, die es im Gerät wirklich gibt.

⚠️ **BIOS-/UEFI-Updates** werden auf diesen Seiten ebenfalls angeboten:
**nicht automatisch mitmachen.** Nur bei konkretem Grund (Sicherheitslücke,
behobener Fehler aus der Problemliste) und nach Rücksprache – ein
fehlgeschlagenes BIOS-Update kann den PC unbrauchbar machen.

## Schritt 3: Chipsatz

Chipsatz-Treiber zuerst unter den Geräte-Treibern, denn sie sind die Grundlage
für alles Weitere (USB, Energieverwaltung, interne Verbindungen):

- **Intel-System:** Herstellerseite aus Schritt 2, alternativ Intel-Website
  („Chipset Device Software").
- **AMD-System:** Herstellerseite aus Schritt 2, alternativ amd.com → Chipsatz-Treiber
  passend zum Sockel/Chipsatz.

**Adminrechte erforderlich**, danach Neustart.

## Schritt 4: Grafikkarte

Quelle je nach GPU (Modell aus `dxdiag`):

- **NVIDIA:** nvidia.de → Treiber (Game Ready oder Studio) für das exakte Modell.
- **AMD:** amd.com → Support → Treiber (Adrenalin).
- **Intel (integriert/Arc):** intel.de → Download-Center, oder – bei Notebooks –
  bevorzugt die Version des Notebook-Herstellers.

Bei der Installation die Option **„Saubere Installation"/„Benutzerdefiniert"**
wählen, keine Zusatz-Software abwählen, die nicht gebraucht wird. Neustart, dann
testen (Video abspielen, ggf. Spiel starten).

## Schritt 5: Netzwerk, WLAN und Bluetooth

Nur aktualisieren bei konkreten Problemen (Abbrüche, langsames WLAN,
Bluetooth-Aussetzer) oder Sicherheitshinweisen. Quelle: PC-/Mainboard-Hersteller
aus Schritt 2; bei Intel-WLAN alternativ Intel-Website.

⚠️ **Vorher den Treiber-Installer herunterladen und lokal speichern** – wenn das
Netzwerk-Update schiefgeht, ist der PC sonst offline und der alte wie der neue
Treiber unerreichbar. Rückweg: Geräte-Manager → „Vorheriger Treiber".

## Schritt 6: Audio

Zum Schluss und nur bei Bedarf (kein Ton, Knacken, fehlende Ausgänge). Quelle:
PC-/Mainboard-Hersteller (meist Realtek-Paket). Nach der Installation Neustart
und Soundtest.

---

## Abschluss Phase 4

1. `devmgmt.msc` öffnen: keine gelben Warndreiecke mehr? Reste in die Problemliste.
2. Zuverlässigkeitsverlauf (`perfmon /rel`) einige Tage beobachten – bleibt es stabil?
3. Neuen Wiederherstellungspunkt anlegen: `Nach Treiberupdates 2026-07`.

Weiter mit [Phase 5: Aufräumen und Optimieren](05-aufraeumen-optimieren.md).
