# orca-kobra

Nightly build of **[OrcaSlicer](https://github.com/OrcaSlicer/OrcaSlicer) (main)** for Linux,
with a small set of patches for the **Anycubic Kobra S1 with ACE 2 Pro** (Rinkhals/Moonraker)
and the Spoolman integration via `ace-lane-bridge`.

Every night the build fetches the current Orca source, applies the patches from `patches/` and
publishes an AppImage under **Releases**. It only builds when Orca or the patches have
changed.

[Deutsch](README.de.md) · [Changelog](CHANGELOG.md) · [kobra-spoolman](https://github.com/xNoVoSx/kobra-spoolman)

## Patches

| File | Effect | Obsolete once … |
|---|---|---|
| `0001-moonraker-lane-data-filament-id.patch` | During filament sync, Orca's built-in Moonraker agent picks the preset by `filament_id` / `setting_id` from Moonraker's `lane_data` instead of by material type only. This puts the Spoolman profiles (`SM000010`, …) into the right slot automatically. Taken from Orca PR [#14423](https://github.com/OrcaSlicer/OrcaSlicer/pull/14423) (author: Broncosis). | #14423 is merged into Orca |
| `0002-plugin-audit-linux-config-dir.patch` | Plugin sandbox: on Linux, Orca's data folder is `~/.config/OrcaSlicer`. The `.config` part matched the denied keyword "conf", so plugins could not read or write anything in the whole data folder. Now only the part of the path below the allowed folder is checked; paths outside it and sensitive folders inside it (`cert`, `secret`, `conf`) stay blocked. With unit test. | Orca fixes the bug |
| `0003-plugin-host-slice-statistics.patch` | New plugin function `orca.host.slice_statistics()`: material usage of the last slice per filament (model, support, tower, flush, total in mm³, plus diameter, density and how often the filament is loaded) — the same numbers as Orca's preview legend. Read-only. The Kobra Spoolman plugin uses it to show the usage per slot after slicing and to warn when a spool is too short. | Orca's plugin API offers slice statistics itself |

If a patch has meanwhile been merged into Orca, the build skips it automatically (the release
notes then say "skipped (already in Orca)") and it can be deleted here.

## Install and update

Easiest with the launcher from `tools/`:

```bash
tools/install.sh
```

Afterwards the application menu has **"OrcaSlicer (Kobra)"** — with its own icon (Orca logo
with an orange spool badge, `tools/orca-kobra.svg`) so you can tell it apart from a regular Orca.
The launcher

- downloads the latest version to `~/Applications` on first run,
- otherwise starts the installed version right away and downloads a newer one in the background
  (checksum verified); it becomes active on the next start,
- keeps the previous version as a fallback and deletes older ones,
- simply starts the existing version when offline.

More commands: `orca-kobra --status`, `orca-kobra --update` (also via right-click in the menu),
log at `~/.local/state/orca-kobra.log`. Uninstall: `tools/install.sh --remove`.
The launcher's messages are in German.

Manual install works too: download the latest `OrcaSlicer-Kobra_…_x86_64.AppImage` from
**Releases**, `chmod +x` it and run it.

The AppImage uses the same data folder as any other Orca (`~/.config/OrcaSlicer`):
profiles, printers, plugins and settings are kept.

## What happens when a patch no longer applies?

Only the next nightly build fails and GitHub sends an email. The last published AppImage stays
in Releases and keeps working. The patch then has to be adapted to the new Orca source.

## Start a build manually

**Actions → Orca Kobra Nightly → Run workflow** (tick "force" to build even without changes).
The first run builds Orca's dependencies and takes accordingly long (several hours);
afterwards they come from the cache.

## Layout

```
patches/                    patches (git format-patch), applied in name order
scripts/apply-patches.sh    applies them, skips those already in Orca
tools/orca-kobra            launcher with automatic update
tools/install.sh            installs launcher, menu entry and icon
.github/workflows/nightly.yml
CHANGELOG.md                changes to patches, build and launcher
README.md / README.de.md    this description, English / German
```

The build steps match Orca's own Linux build (`build_linux.sh -ur`, `-drlL`, `-isrlL` on
Ubuntu 24.04 with Clang and lld).

## License

OrcaSlicer is licensed under AGPL-3.0; so are the patches here. The source of every build is
the Orca commit named in the release notes plus the patches in this repository.
