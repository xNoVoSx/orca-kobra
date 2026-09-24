# Fehlersuche

[English](../troubleshooting.md) · [Zurück zur README](../../README.de.md)

Zuerst `orca-kobra --status` und das Protokoll des Starters `~/.local/state/orca-kobra.log`
ansehen; Orcas eigene Protokolle liegen in `~/.config/OrcaSlicer/log/`.

## Starter und Updates

| Problem | Ursache / Lösung |
|---|---|
| Erster Start dauert, nichts passiert | Der erste Build (etwa 250 MB) wird geladen; eine Meldung sagt das. Fortschritt im Terminal mit `orca-kobra --update`. |
| Kein Update, obwohl es ein neueres Release gibt | Updates werden im Hintergrund geladen und sind erst beim **nächsten** Start aktiv. `orca-kobra --status` zeigt installierte und neueste Version. |
| Protokoll: `GitHub nicht erreichbar oder kein Release` | Kein Internet, GitHub gestört oder das API-Limit für anonyme Anfragen (60 pro Stunde) ist aufgebraucht. Die installierte Version läuft weiter; beim nächsten Start neuer Versuch. |
| Protokoll: `Pruefsumme passt nicht … verworfen` | Der Download war unvollständig oder beschädigt und wurde verworfen. Neuer Versuch beim nächsten Start oder mit `orca-kobra --update`. |
| Protokoll: `Update laeuft bereits` | Ein anderer Start lädt schon. Nichts zu tun. |
| `Fehlt: flock` (oder `curl`, `python3`, `sha256sum`) bei `install.sh` | Fehlendes Programm über den Paketmanager installieren (`flock` gehört zu util-linux). |
| AppImage startet nicht, Fehlermeldung nennt FUSE | FUSE 2 installieren (`fuse2` / `libfuse2`). Notlösung: `~/Applications/OrcaSlicer-Kobra.AppImage --appimage-extract-and-run`. |
| Ein neuer Build ist kaputt | Die vorherige Version direkt starten, siehe [Installation](installation.md#5-zurück-zur-vorherigen-version), und ein Issue anlegen. |

## Menü und Icon

| Problem | Ursache / Lösung |
|---|---|
| Menüeintrag ohne oder mit altem Icon | Der Desktop hat das alte Icon noch im Cache. Ab- und wieder anmelden. Ohne `rsvg-convert` oder `magick` gibt es das Icon nur als SVG – eins davon installieren und `tools/install.sh` noch einmal ausführen. |
| Taskleiste zeigt beim laufenden Orca ein allgemeines Icon | Die Fensterklasse passt nicht zu `StartupWMClass=orca-slicer` im Menüeintrag. Echte Klasse prüfen (X11: `xprop WM_CLASS`, dann ins Orca-Fenster klicken; KDE: Fensterregeln → *Fenstereigenschaften ermitteln*) und mit dem Wert ein Issue anlegen. |
| `orca-kobra: command not found` | `~/.local/bin` ist nicht im `PATH`. Den Menüeintrag oder den vollen Pfad `~/.local/bin/orca-kobra` nutzen. |

## Orca und die Patches

| Problem | Ursache / Lösung |
|---|---|
| Sync-Knopf wählt *Generic PLA* statt des Spoolman-Profils | Printer Agent steht nicht auf *Moonraker* (Druckereinstellungen → Grundlegende Informationen → Erweitert), es läuft ein normaler Orca statt des Kobra-Builds, oder `lane_data` in Moonraker hat keine `filament_id`. Nur Basisprofile (`inherits` leer) behalten eine eigene `filament_id`. |
| Plugin kann in `~/.config/OrcaSlicer` nicht lesen oder schreiben (Zugriff verweigert in `log/python_*.log`) | Orca ohne Patch 0002. „OrcaSlicer (Kobra)“ starten. |
| kobra-spoolman-Panel zeigt kein *Geplanter Verbrauch* | Orca ohne Patch 0003 – über den Starter aktualisieren. Sonst neu slicen; die Vorschau verschwindet, wenn das Slice-Ergebnis veraltet ist. |
| Panel sagt *gleichmäßig verteilt* | Der Build hat einen älteren Patch 0003 ohne Ladevorgänge. Aktualisieren; der erste Build damit ist `kobra-20260924-2257-87a5d20`. |
| Etwas stimmt in Orca selbst nicht | Prüfen, ob es auch mit einem offiziellen [OrcaSlicer-Nightly](https://github.com/OrcaSlicer/OrcaSlicer/releases) passiert. Wenn ja, bei Orca melden; wenn nicht, hier ein Issue anlegen. |

## Nächtlicher Build

| Problem | Ursache / Lösung |
|---|---|
| Nightly mit *Patch no longer applies* fehlgeschlagen | Orca hat Code geändert, den ein Patch berührt. Das zuletzt veröffentlichte AppImage bleibt verfügbar und funktioniert weiter. Der Patch muss angepasst werden, siehe [patches.md](../patches.md#editing-a-patch) (englisch). |
| Nightly beim Kompilieren fehlgeschlagen | Meist eine Änderung in Orca zusammen mit einem Patch. Den fehlgeschlagenen Lauf ansehen; betrifft es einen Patch, wie oben anpassen. |
| Tagelang kein neues Release | Der Workflow baut nur, wenn sich Orcas `main` oder die Patches ändern; die Zusammenfassung des Laufs sagt dann *Nichts Neues*. Siehe [build.md](../build.md#when-it-builds) (englisch). |
