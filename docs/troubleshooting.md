# Troubleshooting

[Deutsch](de/troubleshooting.md) · [Back to README](../README.md)

First look at `orca-kobra --status` and the launcher log `~/.local/state/orca-kobra.log`; Orca's
own logs are in `~/.config/OrcaSlicer/log/`.

## Launcher and updates

| Problem | Cause / solution |
|---|---|
| First start takes a while, nothing happens | The first build (about 250 MB) is downloading; a notification says so. Watch progress with `orca-kobra --update` in a terminal. |
| No update although a newer release exists | Updates are downloaded in the background and become active on the **next** start. `orca-kobra --status` shows installed and latest version. |
| Log: `GitHub nicht erreichbar oder kein Release` | No internet, GitHub down, or the API rate limit for anonymous requests (60 per hour) is used up. The installed version keeps working; it retries on the next start. |
| Log: `Pruefsumme passt nicht … verworfen` | The download was incomplete or damaged and was discarded. It is retried on the next start or with `orca-kobra --update`. |
| Log: `Update laeuft bereits` | Another start is already downloading. Nothing to do. |
| `Fehlt: flock` (or `curl`, `python3`, `sha256sum`) from `install.sh` | Install the missing tool with your package manager (`flock` is part of util-linux). |
| AppImage does not start, error mentions FUSE | Install FUSE 2 (`fuse2` / `libfuse2`). As a workaround: `~/Applications/OrcaSlicer-Kobra.AppImage --appimage-extract-and-run`. |
| A new build is broken | Start the previous version directly, see [installation](installation.md#5-going-back-to-the-previous-version), and open an issue. |

## Menu and icon

| Problem | Cause / solution |
|---|---|
| Menu entry has no or the old icon | The desktop still caches the old icon. Log out and back in. Without `rsvg-convert` or `magick` the icon exists only as SVG — install one and run `tools/install.sh` again. |
| Taskbar shows a generic icon while Orca runs | The window class does not match `StartupWMClass=orca-slicer` in the menu entry. Check the real class (X11: `xprop WM_CLASS`, then click the Orca window; KDE: window rules → *Detect window properties*) and open an issue with the value. |
| `orca-kobra: command not found` | `~/.local/bin` is not in `PATH`. Use the menu entry or the full path `~/.local/bin/orca-kobra`. |

## Orca and the patches

| Problem | Cause / solution |
|---|---|
| Sync button selects *Generic PLA* instead of the Spoolman profile | Printer agent is not *Moonraker* (Printer settings → Basic information → Advanced), you started a regular Orca instead of the Kobra build, or `lane_data` in Moonraker has no `filament_id`. Only base profiles (`inherits` empty) keep their own `filament_id`. |
| Plugin cannot read or write in `~/.config/OrcaSlicer` (access denied in `log/python_*.log`) | Orca without patch 0002. Start "OrcaSlicer (Kobra)". |
| kobra-spoolman panel shows no *Geplanter Verbrauch* | Orca without patch 0003 — update via the launcher. Otherwise slice again; the preview hides when the slice result is outdated. |
| Panel says *gleichmäßig verteilt* (loads spread evenly) | The build has an older patch 0003 without load counts. Update; the first build with it is `kobra-20260924-2257-87a5d20`. |
| Something is wrong in Orca itself | Check whether it also happens with an official [OrcaSlicer nightly](https://github.com/OrcaSlicer/OrcaSlicer/releases). If yes, report it upstream; if not, open an issue here. |

## Nightly build

| Problem | Cause / solution |
|---|---|
| Nightly failed with *Patch no longer applies* | Orca changed code that a patch touches. The last published AppImage stays available and keeps working. The patch has to be adapted, see [patches.md](patches.md#editing-a-patch). |
| Nightly failed while compiling | Usually an upstream change combined with a patch. Look at the failed run; if a patch is involved, adapt it like above. |
| No new release for days | The workflow only builds when Orca's `main` or the patches change; the run summary says *Nichts Neues* (nothing new). See [build.md](build.md#when-it-builds). |
