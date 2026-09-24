# Patches

[Back to README](../README.md)

The patches live in [`patches/`](../patches/) as `git format-patch` files and are applied in name
order onto OrcaSlicer `main`. Each one is kept as small as possible and has a clear condition for
when it can be dropped. This page explains what each patch does, documents the plugin API added by
patch 0003 and describes how to edit, check and retire patches.

| Patch | Files touched | Upstream status |
|---|---|---|
| [0001](#0001-preset-matching-via-lane_datafilament_id) moonraker-lane-data-filament-id | `Preset.cpp/.hpp`, `PresetBundle.cpp`, `MoonrakerPrinterAgent.cpp` | Orca PR [#14423](https://github.com/OrcaSlicer/OrcaSlicer/pull/14423), open |
| [0002](#0002-plugin-sandbox-and-configorcaslicer) plugin-audit-linux-config-dir | `PluginAuditManager.cpp`, `test_plugin_audit.cpp` | not reported upstream yet |
| [0003](#0003-slice-statistics-for-plugins) plugin-host-slice-statistics | `PluginHostApp.cpp` | not proposed upstream yet |

## 0001: preset matching via `lane_data.filament_id`

**Problem.** Orca's Moonraker agent reads the filament slots from Moonraker's `lane_data`
(written by tools such as [ace-lane-bridge](https://github.com/xNoVoSx/kobra-spoolman)). Upstream
it only matches by material type, so the sync button puts *Generic PLA* into a slot even
when a matching user profile exists.

**Change.** Taken unchanged from Orca PR #14423 by Broncosis:

- New `PresetCollection::filament_id_by_id_or_name()` matches by `filament_id`, then `setting_id`,
  then the preset name (exact, then case-insensitive / base name).
- `MoonrakerPrinterAgent::fetch_moonraker_filament_data()` uses it for the `filament_id` and
  `setting_id` fields of `lane_data` before falling back to material matching.
- `PresetBundle::sync_ams_list()` and `get_ams_cobox_infos()` get a name-based fallback for user
  presets without `filament_id`.

**Notes.** Only base profiles (`inherits` empty) keep their own `filament_id`; profiles that
inherit from a system profile do not. kobra-spoolman therefore creates base profiles.
The printer agent must be set to *Moonraker*.

**Drop when** #14423 is merged. The build then reports the patch as *skipped (already in Orca)*.

## 0002: plugin sandbox and `~/.config/OrcaSlicer`

**Problem.** Orca's plugin sandbox (`PluginAuditManager`) denies file access to paths that contain
sensitive keywords such as `cert`, `secret` or `conf`. On Linux the data folder is
`~/.config/OrcaSlicer`, and its `.config` component matched `conf`. So every plugin file access
inside the data folder — profiles, plugin storage — was denied, although the data folder is an
allowed root.

**Change.** The keywords are only matched against the path components **below** the allowed root.
Paths outside every allowed root stay denied, and so do sensitive folders inside a root (for
example `resources/cert`). A unit test in `tests/slic3rutils/test_plugin_audit.cpp` covers both
cases.

**Drop when** Orca fixes the keyword matching itself.

## 0003: slice statistics for plugins

**Problem.** Plugins get `SlicingJobComplete`, but no access to the numbers shown in the preview
legend. The kobra-spoolman plugin needs them to compare a plate with what is left on the loaded
spools.

**Change.** A read-only function on the plugin host, built from the same `GCodeProcessor`
statistics the preview legend uses, plus a count of how often each filament is loaded.

**Drop when** Orca's plugin API offers slice statistics itself.

### API reference

```python
orca.host.slice_statistics(plate_index=-1, require_valid=True) -> dict | None
```

| Parameter | Meaning |
|---|---|
| `plate_index` | 0-based plate; `-1` is the current plate |
| `require_valid` | Return `None` if the plate's slice result is outdated. Pass `False` in a `SlicingJobComplete` handler: the plate's valid flag is only set **after** that event has been dispatched. |

Returns `None` if the plate does not exist, has no slice result, or the result is not valid and
`require_valid` is true. Otherwise:

| Key | Type | Meaning |
|---|---|---|
| `plate_index` | int | Plate the numbers belong to |
| `valid` | bool | Whether the slice result is up to date |
| `filaments` | list | One entry per filament used, see below |
| `total_filament_changes` | int | Filament changes, as in the preview legend |
| `total_flush_filament_changes` | int | Changes that flush, as in the preview legend |

Each entry of `filaments`:

| Key | Type | Meaning |
|---|---|---|
| `index` | int | 0-based filament index (slot 1 = 0) |
| `model_mm3` | float | Volume for the model |
| `support_mm3` | float | Volume for supports |
| `tower_mm3` | float | Volume for the prime tower |
| `flush_mm3` | float | Volume flushed into the tower or purge ("Flushed" in the legend) |
| `total_mm3` | float | Orca's total per extruder. It assigns the tower differently at tool changes; for per-filament totals like the legend, add model + support + flush + tower. |
| `loads` | int | How often the filament becomes the extruding one: first use plus every switch back to it. On a printer with a filament changer that is the number of loads. |
| `diameter` | float or None | Filament diameter in mm |
| `density` | float or None | Density in g/cm³ |

Grams from a volume: `grams = mm3 * density / 1000`. Length: `mm = mm3 / (pi * (diameter / 2) ** 2)`.

Example — excerpt of a plugin capability (registration as in Orca's plugin documentation). The
`getattr` keeps the plugin working on an Orca without this patch:

```python
import orca

class UsageCheck(orca.script.ScriptPluginCapabilityBase):
    def on_lifecycle_event(self, event, ctx):
        if event != orca.LifecycleEvent.SlicingJobComplete or ctx.code != orca.LifecycleEvtCode.Ok:
            return
        slice_statistics = getattr(orca.host, "slice_statistics", None)
        stats = slice_statistics(-1, False) if slice_statistics else None  # require_valid=False, see above
        if stats is None:
            return
        for f in stats["filaments"]:
            used = f["model_mm3"] + f["support_mm3"] + f["flush_mm3"] + f["tower_mm3"]
            grams = used * (f["density"] or 1.24) / 1000
            print(f"slot {f['index'] + 1}: {grams:.1f} g, loaded {f['loads']}x")
```

Firmware purge on load (for example by the ACE on a Kobra S1) is **not** part of Orca's
statistics; kobra-spoolman measures it on the printer and adds it per load.

## Editing a patch

You need a local clone of OrcaSlicer next to this repository. The paths below assume both live in
the same folder (`orca-src/` and `orca-kobra/`).

```bash
git clone --filter=blob:none https://github.com/OrcaSlicer/OrcaSlicer orca-src
git -C orca-src switch -c kobra-patches
git -C orca-src am "$PWD"/orca-kobra/patches/*.patch
```

If `git am` stops because a patch no longer applies, fix the conflict in `orca-src`, then
`git -C orca-src am --continue`.

Change the code and commit (amend the commit of the patch you are changing, or use
`git rebase` with `fixup`). Then export and replace the file in `patches/`:

```bash
out=$(mktemp -d)
git -C orca-src format-patch origin/main -o "$out"
ls "$out"      # format-patch names the files after the subject
cp "$out"/0003-*.patch orca-kobra/patches/0003-plugin-host-slice-statistics.patch
```

Keep the existing `000N-…` file names: the build applies patches in name order and the docs refer
to them by name.

### Checking against clean upstream

The build uses `git apply` (not `git am`), so check the patches the same way on a clean
`origin/main`:

```bash
git -C orca-src fetch origin
git -C orca-src worktree add --detach "$PWD"/orca-check origin/main
orca-kobra/scripts/apply-patches.sh orca-check orca-kobra/patches /dev/null
git -C orca-src worktree remove --force "$PWD"/orca-check
```

`apply-patches.sh <orca-source> [patch-dir] [report.md]` prints one line per patch — `applied`,
`skipped (already in Orca)` — and stops with an error if a patch no longer applies.

Compiling Orca locally takes a long time and needs its dependencies (`build_linux.sh -drlL`); it is
usually easier to push to a fork and let the nightly workflow build it ([build.md](build.md#building-in-a-fork)).

## Adding a patch

- Keep it small and focused on one thing, with a commit message that could go upstream as is.
- Prefer changes with a realistic chance of being merged into Orca, and open the upstream PR or
  issue when possible — every patch here is meant to disappear again.
- Name it `000N-short-description.patch` with the next free number.
- Add it to the tables in both READMEs and on this page, and to `CHANGELOG.md`.

## Retiring a patch

When Orca contains a patch, the nightly build reports it as *skipped (already in Orca)* in the
release notes. Then delete the file from `patches/`, remove it from both READMEs and this page, and
note it in `CHANGELOG.md`. Keep the numbers of the other patches unchanged.
