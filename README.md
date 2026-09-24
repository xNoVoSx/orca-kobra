# orca-kobra

Nächtlicher Build von **[OrcaSlicer](https://github.com/OrcaSlicer/OrcaSlicer) (main)** für Linux,
mit einer kleinen Zahl von Patches für den **Anycubic Kobra S1 mit ACE 2 Pro** (Rinkhals/Moonraker)
und die Spoolman-Anbindung über die `ace-lane-bridge`.

Der Build holt jede Nacht den aktuellen Orca-Quellcode, wendet die Patches aus `patches/` an und
veröffentlicht ein AppImage unter **Releases**. Gebaut wird nur, wenn sich Orca oder die Patches
geändert haben.

## Patches

| Datei | Wirkung | Entfällt, wenn … |
|---|---|---|
| `0001-moonraker-lane-data-filament-id.patch` | Der eingebaute Moonraker-Agent wählt beim Filament-Sync das Profil über `filament_id` / `setting_id` aus Moonrakers `lane_data` statt nur über den Materialtyp. Damit landen die Spoolman-Profile (`SM000010`, …) automatisch im richtigen Slot. Übernommen aus Orca-PR [#14423](https://github.com/OrcaSlicer/OrcaSlicer/pull/14423) (Autor: Broncosis). | #14423 in Orca übernommen ist |
| `0002-plugin-audit-linux-config-dir.patch` | Plugin-Sandbox: Unter Linux liegt Orcas Datenordner in `~/.config/OrcaSlicer`. Der Teil `.config` passte auf das Sperrwort „conf“, sodass Plugins im gesamten Datenordner nichts lesen oder schreiben durften. Geprüft wird jetzt nur noch der Teil des Pfads unterhalb des erlaubten Ordners; Pfade außerhalb und sensible Ordner darin (`cert`, `secret`, `conf`) bleiben gesperrt. Mit Unit-Test. | Orca den Fehler behebt |

Ist ein Patch inzwischen in Orca enthalten, wird er beim Build automatisch übersprungen
(steht dann so in den Release-Notizen) und kann hier gelöscht werden.

## Installieren und aktualisieren

1. Unter **Releases** das neueste `OrcaSlicer-Kobra_…_x86_64.AppImage` herunterladen.
2. `chmod +x OrcaSlicer-Kobra_*.AppImage` und starten.

Das AppImage nutzt denselben Datenordner wie jedes andere Orca (`~/.config/OrcaSlicer`):
Profile, Drucker und Einstellungen bleiben erhalten. Zum Aktualisieren einfach das neue
AppImage herunterladen und das alte löschen.

## Was passiert, wenn ein Patch nicht mehr passt?

Dann schlägt nur der nächtliche Build fehl und GitHub schickt eine E-Mail. Das zuletzt
veröffentlichte AppImage bleibt in den Releases und funktioniert weiter. Der Patch muss dann an
den neuen Orca-Stand angepasst werden.

## Build von Hand starten

**Actions → Orca Kobra Nightly → Run workflow** (Häkchen „force“, um auch ohne Änderungen zu bauen).
Der erste Lauf baut Orcas Abhängigkeiten und dauert entsprechend lange (mehrere Stunden);
danach kommen sie aus dem Cache.

## Aufbau

```
patches/                    Patches (git format-patch), werden in Namensreihenfolge angewendet
scripts/apply-patches.sh    wendet sie an, überspringt bereits enthaltene
.github/workflows/nightly.yml
```

Die Build-Schritte entsprechen Orcas eigenem Linux-Build (`build_linux.sh -ur`, `-drlL`,
`-isrlL` auf Ubuntu 24.04 mit Clang und lld).

## Lizenz

OrcaSlicer steht unter der AGPL-3.0; die Patches hier ebenso. Der Quellcode jedes Builds ist
der in den Release-Notizen genannte Orca-Commit plus die Patches in diesem Repository.
