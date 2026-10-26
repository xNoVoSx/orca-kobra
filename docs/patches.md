# Patches

[Back to README](../README.md)

The patches live in [`patches/`](../patches/) as `git format-patch` files and are applied in name
order onto OrcaSlicer `main`. Each one is kept as small as possible and has a clear condition for
when it can be dropped. This page explains what each patch does, documents the plugin API added by
patch 0003 and describes how to edit, check and retire patches.

| Patch | Files touched | Upstream status |
|---|---|---|
| [0003](#0003-slice-statistics-for-plugins) plugin-host-slice-statistics | `Plater.cpp`, `PluginHostApp.cpp`, `test_plugin_host_api.cpp` | Orca PR [#16423](https://github.com/OrcaSlicer/OrcaSlicer/pull/16423), open |
| [0004](#0004-minimum-size-for-docked-plugin-panels) plugin-dock-pane-min-size | `PluginHostUi.cpp` | cause fixed upstream in [#16257](https://github.com/OrcaSlicer/OrcaSlicer/pull/16257); kept until a saved collapsed layout is checked |

Dropped: 0001 `moonraker-lane-data-filament-id` (2026-10-26) – merged into Orca as
[#14423](https://github.com/OrcaSlicer/OrcaSlicer/pull/14423) (2026-10-26) in a slimmer form: a `lane_data`
`filament_id` (a string) goes to the shared AMS matcher as the tray id and matches a compatible root preset carrying
it; the name-based fallback was left out. kobra-spoolman's profiles are root presets with that id, so nothing changes.
0005 `gcode-header-first-layer-temps` (2026-10-15) – merged into Orca as
[#16422](https://github.com/OrcaSlicer/OrcaSlicer/pull/16422) (2026-10-14).
0002 `plugin-audit-linux-config-dir` (2026-10-13) – Orca matches the sandbox keywords as whole path components
since [#16243](https://github.com/OrcaSlicer/OrcaSlicer/pull/16243), so `~/.config/OrcaSlicer` is no longer blocked.

## 0003: slice statistics for plugins

**Problem.** Plugins get `SlicingJobComplete`, but no access to the numbers shown in the preview
legend. The kobra-spoolman plugin needs them to compare a plate with what is left on the loaded
spools.

**Change.** A read-only function on the plugin host, built from the same `GCodeProcessor`
statistics the preview legend uses, plus how often each filament is loaded and which filament
changes happen (from → to, with counts).

**Drop when** Orca's plugin API offers slice statistics itself.

## 0004: minimum size for docked plugin panels

**Problem.** A plugin panel docked beside the 3D view (`orca.host.ui.create_dock_panel`) has no
minimum size, and an idle handler stores the panel's current width as its best size in the saved
window layout. A panel that was squeezed once — for example while the main window was still being
laid out at start-up — was saved a few pixels wide and restored that way on every start (the
kobra-spoolman panel showed up about 2 mm wide).

**Change.** `Plater::priv::add_dock_pane` sets a minimum size (the requested size, capped at
220 × 160 DIP), applies it again after `LoadPaneInfo` (which restores the saved minimum too) and
falls back to the requested size when the saved layout is smaller than the minimum.

**Drop when** Orca gives docked plugin panes a minimum size itself.

### API reference

```python
orca.host.slice_statistics(plate_index=-1) -> dict | None
```

| Parameter | Meaning |
|---|---|
| `plate_index` | 0-based plate; `-1` is the current plate |

Returns `None` if the plate does not exist or has no valid slice result. The patch marks the slice
result valid before *SlicingJobComplete* is fired, so a handler of that event gets the numbers. Otherwise:

| Key | Type | Meaning |
|---|---|---|
| `plate_index` | int | Plate the numbers belong to |
| `filaments` | list | One entry per filament used, see below |
| `total_filament_changes` | int | Filament changes, as in the preview legend |
| `total_flush_filament_changes` | int | Changes that flush, as in the preview legend |
| `transitions` | list | Filament changes in order, grouped: `{"from": int or None, "to": int, "count": int}` with 0-based filament indices; `from` is `None` for the first filament of the print. Builds before 2026-10-01 lack this key. |

Each entry of `filaments`:

| Key | Type | Meaning |
|---|---|---|
| `index` | int | 0-based filament index (slot 1 = 0) |
| `model_mm3` | float | Volume for the model |
| `support_mm3` | float | Volume for supports |
| `tower_mm3` | float | Volume for the prime tower |
| `flush_mm3` | float | Volume flushed into the tower or purge ("Flushed" in the legend) |
| `total_mm3` | float | Orca's total per extruder. It assigns the tower differently at tool changes; for per-filament totals like the legend, add model + support + flush + tower. |
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
        stats = slice_statistics() if slice_statistics else None
        if stats is None:
            return
        for f in stats["filaments"]:
            used = f["model_mm3"] + f["support_mm3"] + f["flush_mm3"] + f["tower_mm3"]
            grams = used * (f["density"] or 1.24) / 1000
            print(f"slot {f['index'] + 1}: {grams:.1f} g")
```

Firmware purge on load (for example by the ACE on a Kobra S1) is **not** part of Orca's
statistics. kobra-spoolman estimates it per colour change from `transitions`, the slot colours and
the firmware's flush settings, and measures it on the printer.

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
