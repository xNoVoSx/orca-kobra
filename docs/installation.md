# Installation

[Deutsch](de/installation.md) · [Back to README](../README.md)

This guide installs the orca-kobra build next to (or instead of) a regular OrcaSlicer. It takes a
few minutes, most of it the first download of about 250 MB.

**Overview**

1. [Requirements](#1-requirements)
2. [Install with the launcher](#2-install-with-the-launcher)
3. [Set up Orca](#3-set-up-orca)
4. [Updates](#4-updates)
5. [Going back to the previous version](#5-going-back-to-the-previous-version)
6. [Launcher settings](#6-launcher-settings)
7. [Manual install without the launcher](#7-manual-install-without-the-launcher)
8. [Uninstall](#8-uninstall)

## 1. Requirements

- Linux x86_64 with a desktop environment (KDE, GNOME, …).
- `curl`, `python3`, `sha256sum` and `flock` (util-linux). `install.sh` checks for them.
- FUSE 2 for AppImages (package `fuse2` or `libfuse2`, depending on the distribution).
- Optional: `rsvg-convert` (librsvg) or ImageMagick (`magick`) — without them the icon is only
  installed as SVG, which some menus and taskbars do not show.

## 2. Install with the launcher

```bash
git clone https://github.com/xNoVoSx/orca-kobra && cd orca-kobra
tools/install.sh
```

`install.sh` works for the current user only (no `sudo`):

| What | Where |
|---|---|
| Launcher `orca-kobra` | `~/.local/bin/orca-kobra` |
| AppImages (latest and previous) | `~/Applications/OrcaSlicer-Kobra_<version>_<date>_<orca-commit>_x86_64.AppImage` |
| Link to the active version | `~/Applications/OrcaSlicer-Kobra.AppImage` |
| Menu entry "OrcaSlicer (Kobra)" | `~/.local/share/applications/orca-kobra.desktop` |
| Icon (SVG and PNG 16–512 px) | `~/.local/share/icons/hicolor/*/apps/orca-kobra.*` |
| Log | `~/.local/state/orca-kobra.log` |

On the first run it downloads the latest build and verifies its checksum. Afterwards
**"OrcaSlicer (Kobra)"** is in the application menu, with its own icon (Orca logo with an orange
spool badge) so you can tell it apart from a regular Orca. Right-click the entry for
*Nach Update suchen* (check for updates); it runs without a window, the result is in the log.

Running `tools/install.sh` again updates launcher, menu entry and icon — useful after a
`git pull`.

> [!NOTE]
> If `~/.local/bin` is not in your `PATH`, the menu entry still works; only the `orca-kobra`
> command in a terminal needs the full path.

## 3. Set up Orca

The build uses the normal Orca data folder `~/.config/OrcaSlicer`, so your printers, profiles,
plugins and settings are there right away. Do not run a regular Orca and the Kobra build at the
same time — both write the same settings file.

For the sync button to pick the right profile per ACE slot (patch 0001):

- Add the printer as usual (Anycubic Kobra S1 0.4 nozzle) and connect it to `http://<printer-ip>`.
- **Printer settings → Basic information → Advanced** (advanced mode): **Printer agent = Moonraker**.

The Spoolman profiles, the side panel and the usage preview come from the
[kobra-spoolman](https://github.com/xNoVoSx/kobra-spoolman/blob/main/docs/installation.md) plugin.

## 4. Updates

Every start of "OrcaSlicer (Kobra)" works like this:

1. The installed version starts **immediately** — the launcher never makes you wait.
2. In the background it asks GitHub for the latest release. If there is a newer one, a
   desktop notification appears (via `notify-send`) and it is downloaded and checked against its `.sha256`.
3. The new version is **active from the next start**. The previous one stays as a fallback,
   older ones are deleted.

Without internet or when GitHub is unreachable, the installed version simply starts. Only one
download runs at a time, even if you start Orca twice.

Useful commands:

```bash
orca-kobra --status   # installed and latest version, folder, log
orca-kobra --update   # check and download now (with progress bar), without starting Orca
```

What the launcher did is in `~/.local/state/orca-kobra.log` (German messages such as
`aktuell` = up to date, `lade` = downloading, `installiert` = installed).

## 5. Going back to the previous version

The launcher keeps the previous build in `~/Applications`. To use it, start it directly:

```bash
ls ~/Applications/OrcaSlicer-Kobra_*.AppImage
~/Applications/OrcaSlicer-Kobra_<previous>_x86_64.AppImage
```

The launcher itself always moves to the latest release, so starting from the menu switches back
to the newest build. If a build is broken, please
[open an issue](https://github.com/xNoVoSx/orca-kobra/issues) — the next nightly usually fixes it.

## 6. Launcher settings

Optional, in `~/.config/orca-kobra.conf` (a shell file with `VAR=value` lines):

| Variable | Default | Meaning |
|---|---|---|
| `ORCA_KOBRA_REPO` | `xNoVoSx/orca-kobra` | GitHub repository with the releases — set it to your fork to use your own builds ([build.md](build.md#building-in-a-fork)) |
| `ORCA_KOBRA_DIR` | `~/Applications` | Folder for the AppImages |
| `ORCA_KOBRA_KEEP` | `2` | Number of versions to keep (the latest plus fallbacks) |

## 7. Manual install without the launcher

Download the latest `OrcaSlicer-Kobra_…_x86_64.AppImage` and its `.sha256` from
[Releases](https://github.com/xNoVoSx/orca-kobra/releases/latest), then:

```bash
sha256sum -c OrcaSlicer-Kobra_*_x86_64.AppImage.sha256
chmod +x OrcaSlicer-Kobra_*_x86_64.AppImage
./OrcaSlicer-Kobra_*_x86_64.AppImage
```

You then update by hand the same way.

## 8. Uninstall

```bash
tools/install.sh --remove
```

This removes the launcher, the menu entry and the icon. The AppImages, the log and your Orca data
stay. To remove them as well:

```bash
rm -f ~/Applications/OrcaSlicer-Kobra* ~/Applications/.orca-kobra-update.lock
rm -f ~/.local/state/orca-kobra.log ~/.config/orca-kobra.conf
```

`~/.config/OrcaSlicer` is shared with every other Orca installation — only delete it if you want
to lose all Orca settings and profiles.
