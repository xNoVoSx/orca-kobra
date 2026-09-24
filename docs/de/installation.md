# Installation

[English](../installation.md) · [Zurück zur README](../../README.de.md)

Diese Anleitung installiert den orca-kobra-Build neben (oder statt) einem normalen OrcaSlicer. Das
dauert ein paar Minuten, das meiste davon ist der erste Download mit etwa 250 MB.

**Überblick**

1. [Voraussetzungen](#1-voraussetzungen)
2. [Mit dem Starter installieren](#2-mit-dem-starter-installieren)
3. [Orca einrichten](#3-orca-einrichten)
4. [Updates](#4-updates)
5. [Zurück zur vorherigen Version](#5-zurück-zur-vorherigen-version)
6. [Einstellungen des Starters](#6-einstellungen-des-starters)
7. [Von Hand installieren, ohne Starter](#7-von-hand-installieren-ohne-starter)
8. [Entfernen](#8-entfernen)

## 1. Voraussetzungen

- Linux x86_64 mit Desktop (KDE, GNOME, …).
- `curl`, `python3`, `sha256sum` und `flock` (util-linux). `install.sh` prüft sie.
- FUSE 2 für AppImages (Paket `fuse2` oder `libfuse2`, je nach Distribution).
- Optional: `rsvg-convert` (librsvg) oder ImageMagick (`magick`) – ohne sie wird das Icon nur als
  SVG installiert, und manche Menüs und Taskleisten zeigen das nicht.

## 2. Mit dem Starter installieren

```bash
git clone https://github.com/xNoVoSx/orca-kobra && cd orca-kobra
tools/install.sh
```

`install.sh` arbeitet nur für den aktuellen Benutzer (kein `sudo`):

| Was | Wo |
|---|---|
| Starter `orca-kobra` | `~/.local/bin/orca-kobra` |
| AppImages (neueste und vorherige) | `~/Applications/OrcaSlicer-Kobra_<version>_<datum>_<orca-commit>_x86_64.AppImage` |
| Verweis auf die aktive Version | `~/Applications/OrcaSlicer-Kobra.AppImage` |
| Menüeintrag „OrcaSlicer (Kobra)“ | `~/.local/share/applications/orca-kobra.desktop` |
| Icon (SVG und PNG 16–512 px) | `~/.local/share/icons/hicolor/*/apps/orca-kobra.*` |
| Protokoll | `~/.local/state/orca-kobra.log` |

Beim ersten Mal lädt es den neuesten Build und prüft die Prüfsumme. Danach steht
**„OrcaSlicer (Kobra)“** im Anwendungsmenü, mit eigenem Icon (Orca-Logo mit orangem
Spulen-Abzeichen), damit man ihn von einem normalen Orca unterscheidet. Per Rechtsklick auf den
Eintrag gibt es *Nach Update suchen*; das läuft ohne Fenster, das Ergebnis steht im Protokoll.

`tools/install.sh` noch einmal ausführen aktualisiert Starter, Menüeintrag und Icon – sinnvoll
nach einem `git pull`.

> [!NOTE]
> Ist `~/.local/bin` nicht im `PATH`, funktioniert der Menüeintrag trotzdem; nur der Befehl
> `orca-kobra` im Terminal braucht dann den vollen Pfad.

## 3. Orca einrichten

Der Build nutzt den normalen Orca-Datenordner `~/.config/OrcaSlicer`, deine Drucker, Profile,
Plugins und Einstellungen sind also sofort da. Einen normalen Orca und den Kobra-Build nicht
gleichzeitig laufen lassen – beide schreiben dieselbe Einstellungsdatei.

Damit der Sync-Knopf pro ACE-Slot das richtige Profil wählt (Patch 0001):

- Den Drucker wie gewohnt anlegen (Anycubic Kobra S1 0.4 nozzle) und mit `http://<drucker-ip>` verbinden.
- **Druckereinstellungen → Grundlegende Informationen → Erweitert** (Expertenmodus):
  **Printer Agent = Moonraker**.

Die Spoolman-Profile, das Seitenpanel und die Verbrauchsvorschau kommen vom Plugin aus
[kobra-spoolman](https://github.com/xNoVoSx/kobra-spoolman/blob/main/docs/de/installation.md).

## 4. Updates

Jeder Start von „OrcaSlicer (Kobra)“ läuft so ab:

1. Die installierte Version startet **sofort** – der Starter lässt dich nie warten.
2. Im Hintergrund fragt er GitHub nach dem neuesten Release. Gibt es ein neueres, erscheint eine
   Desktop-Meldung (über `notify-send`), es wird geladen und gegen seine `.sha256` geprüft.
3. Die neue Version ist **ab dem nächsten Start aktiv**. Die vorherige bleibt als Rückfall,
   ältere werden gelöscht.

Ohne Internet oder wenn GitHub nicht erreichbar ist, startet einfach die installierte Version. Es
läuft immer nur ein Download gleichzeitig, auch wenn du Orca zweimal startest.

Nützliche Befehle:

```bash
orca-kobra --status   # installierte und neueste Version, Ordner, Protokoll
orca-kobra --update   # jetzt suchen und laden (mit Fortschrittsbalken), ohne Orca zu starten
```

Was der Starter gemacht hat, steht in `~/.local/state/orca-kobra.log` (`aktuell`, `lade …`,
`installiert: …`).

## 5. Zurück zur vorherigen Version

Der Starter behält den vorherigen Build in `~/Applications`. Um ihn zu nutzen, direkt starten:

```bash
ls ~/Applications/OrcaSlicer-Kobra_*.AppImage
~/Applications/OrcaSlicer-Kobra_<vorherige>_x86_64.AppImage
```

Der Starter selbst geht immer auf das neueste Release; ein Start aus dem Menü nimmt also wieder
den neuesten Build. Ist ein Build kaputt, bitte ein
[Issue anlegen](https://github.com/xNoVoSx/orca-kobra/issues) – meist behebt es der nächste Nightly.

## 6. Einstellungen des Starters

Optional, in `~/.config/orca-kobra.conf` (Shell-Datei mit Zeilen `VAR=wert`):

| Variable | Standard | Bedeutung |
|---|---|---|
| `ORCA_KOBRA_REPO` | `xNoVoSx/orca-kobra` | GitHub-Repository mit den Releases – auf deinen Fork setzen, um eigene Builds zu nutzen ([build.md](../build.md#building-in-a-fork), englisch) |
| `ORCA_KOBRA_DIR` | `~/Applications` | Ordner für die AppImages |
| `ORCA_KOBRA_KEEP` | `2` | So viele Versionen behalten (die neueste plus Rückfall) |

## 7. Von Hand installieren, ohne Starter

Unter [Releases](https://github.com/xNoVoSx/orca-kobra/releases/latest) das neueste
`OrcaSlicer-Kobra_…_x86_64.AppImage` und seine `.sha256` laden, dann:

```bash
sha256sum -c OrcaSlicer-Kobra_*_x86_64.AppImage.sha256
chmod +x OrcaSlicer-Kobra_*_x86_64.AppImage
./OrcaSlicer-Kobra_*_x86_64.AppImage
```

Aktualisiert wird dann genauso von Hand.

## 8. Entfernen

```bash
tools/install.sh --remove
```

Das entfernt Starter, Menüeintrag und Icon. AppImages, Protokoll und deine Orca-Daten bleiben.
Um auch die zu entfernen:

```bash
rm -f ~/Applications/OrcaSlicer-Kobra* ~/Applications/.orca-kobra-update.lock
rm -f ~/.local/state/orca-kobra.log ~/.config/orca-kobra.conf
```

`~/.config/OrcaSlicer` teilt sich der Build mit jeder anderen Orca-Installation – nur löschen, wenn
alle Orca-Einstellungen und -Profile weg sollen.
