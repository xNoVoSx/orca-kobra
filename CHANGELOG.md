# Changelog

Changes to patches, build and launcher. There are no version numbers of our own: every nightly
build is a release named after its date and Orca commit (`kobra-YYYYMMDD-HHMM-<orca-commit>`),
and its release notes list the applied patches. This file records what changed in this
repository, by date. Format based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Removed
- Patch 0005 `gcode-header-first-layer-temps`: merged into Orca as
  [#16422](https://github.com/OrcaSlicer/OrcaSlicer/pull/16422) (2026-10-14); Orca's own version would conflict with it.
- Patch 0002 `plugin-audit-linux-config-dir`: Orca matches the sandbox keywords as whole path components since
  [#16243](https://github.com/OrcaSlicer/OrcaSlicer/pull/16243) (2026-10-09), so `~/.config/OrcaSlicer` is no longer
  blocked. Its test failed against the new matching.

### Fixed
- The nightly build failed on 2026-10-14: Orca's hot reload of preset bundles
  ([#15424](https://github.com/OrcaSlicer/OrcaSlicer/pull/15424)) changed the plugin host test file, so patch 0003 no longer applied. Patches
  0001, 0003 and 0004 rebased onto Orca `main` b75af485c (code unchanged, only the context); checked with
  `scripts/apply-patches.sh` against a clean `main`.
- docs/patches.md described the API of patch 0003 before Orca's review (`require_valid`, `valid`, `loads`); now as built.
- The nightly build failed since 2026-10-11: Orca replaced `app_language()` with `app_info()` and added more plugin host
  functions ([#16324](https://github.com/OrcaSlicer/OrcaSlicer/pull/16324)), so patch 0003 no longer applied. Rebased;
  checked with a local build of Orca `main` plus all patches and Orca's test suite.
- Patch 0005 has a unit test (`tests/fff_print/test_gcode.cpp`, fails without the patch).

### Changed
- Patch 0003 after Orca's review ([#16423](https://github.com/OrcaSlicer/OrcaSlicer/pull/16423)):
  `slice_statistics(plate_index=-1)` without `require_valid` and without `loads`; the plate's slice result is marked
  valid before *SlicingJobComplete* fires, so the event handler reads it with the defaults. The description is the
  function's docstring. The Kobra Spoolman plugin 0.7.2 works with old and new builds.
- Patch 0005 after Orca's review ([#16422](https://github.com/OrcaSlicer/OrcaSlicer/pull/16422)): the temperatures are
  taken once before the object loop, so printing by object writes the first object's filament (it wrote the last
  one's); test for it.
- Bug report form asks for what is needed to reproduce (like OrcaSlicer's): build, OS, printer, whether it also
  happens in the official nightly, steps / what happened / what was expected, logs, project file.

### Fixed
- The nightly build failed since 2026-10-03: Orca removed unused includes in
  `PluginAuditManager.cpp` and `PluginHostApp.cpp`, so patches 0002 and 0003 no longer applied.
  Both are rebased onto the current `main` (context only, no change in behaviour); 0001 gets new
  line numbers.

### Added
- Patch 0005 `gcode-header-first-layer-temps`: the first-layer temperature lines at the end of the
  G-code describe the filaments actually printed (bed: highest of the used filaments with the
  matching bed formula) instead of filament 1. GoKlipper used filament 1's bed temperature for its
  flow calibration.
- Patch 0004 `plugin-dock-pane-min-size`: docked plugin panels keep a minimum size, and a window
  layout saved while a panel was collapsed no longer brings it back a few pixels wide.

### Changed
- Patch 0003: `slice_statistics()` also returns `transitions` — every filament change of the plate
  as `{from, to, count}` (`from` is `None` for the first filament). kobra-spoolman uses it to
  estimate the ACE's purge per colour change.

### Added
- Documentation structured like kobra-spoolman: `docs/installation.md` and
  `docs/troubleshooting.md` (with German versions in `docs/de/`), `docs/patches.md` (each patch in
  detail, API reference for `slice_statistics()`, editing and retiring patches) and `docs/build.md`
  (when the nightly builds, jobs, releases, building in a fork).
- `LICENSE` with the full AGPL-3.0 text (the README already named the license).
- `CONTRIBUTING.md`, issue templates (bug report, feature request, links to kobra-spoolman and
  OrcaSlicer) and a pull request template.
- CI workflow `ci.yml`: `shellcheck` for scripts and launcher, `actionlint` for the workflows.
- `.editorconfig`; `.gitattributes` normalises line endings and keeps patch files byte for byte.

### Changed
- Documentation in English first: `README.md` is English, the German version moved to
  `README.de.md` (both are kept up to date). This changelog is English.
- README rewritten in the layout of kobra-spoolman: badges, overview diagram, patch table,
  requirements, quick start, documentation index.
- Release notes and the patch report of the nightly build are in English
  ("applied", "skipped (already in Orca)").
- Nightly: finding the built AppImage no longer parses `ls` and fails with a clear error if there
  is none.
- Launcher and `install.sh`: optional tools (`notify-send`, `update-desktop-database`,
  `xdg-icon-resource`) are called through explicit `if` blocks instead of `A && B || true`.

## 2026-09-25

### Added
- Own icon `tools/orca-kobra.svg` (Orca logo with an orange spool badge) to tell the Kobra build
  apart from a regular Orca. `install.sh` installs it as SVG and as PNG in all common sizes,
  refreshes the icon caches and removes the old icon.
- Menu entry with `StartupWMClass=orca-slicer` so the taskbar shows the icon as well.

### Changed
- Patch 0003: `slice_statistics()` additionally returns `loads` per filament, i.e. how often the
  filament is loaded during the print. The Kobra Spoolman plugin (0.3.1 and later) uses it to
  compute the firmware purge per slot exactly instead of spreading it evenly. First build with
  it: `kobra-20260924-2257-87a5d20`.

## 2026-09-24

### Added
- Patch 0003 `plugin-host-slice-statistics`: new plugin function `orca.host.slice_statistics()`
  with the material usage of the last slice per filament (model, support, tower, flush, total),
  the same numbers as Orca's preview legend. Read-only.
- Launcher `tools/orca-kobra` with automatic update: downloads a newer version in the background
  (checksum verified), active from the next start, keeps the previous one as a fallback.
  `--status`, `--update`, log at `~/.local/state/orca-kobra.log`.
- `tools/install.sh`: installs launcher and menu entry, `--remove` uninstalls both.
- Initial version: nightly build of Orca main as AppImage (`nightly.yml`, only builds when Orca or
  the patches change), `scripts/apply-patches.sh` (skips patches already in Orca) and the patches
  - 0001 `moonraker-lane-data-filament-id`: the Moonraker agent picks the preset by
    `lane_data.filament_id` (from Orca PR #14423),
  - 0002 `plugin-audit-linux-config-dir`: the plugin sandbox blocked the whole data folder
    because of `.config`.

### Changed
- GitHub Actions updated to `actions/checkout@v7` and `actions/cache@v6`.
