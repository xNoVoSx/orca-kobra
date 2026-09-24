# Changelog

Changes to patches, build and launcher. There are no version numbers of our own: every nightly
build is a release named after its date and Orca commit (`kobra-YYYYMMDD-HHMM-<orca-commit>`),
and its release notes list the applied patches. This file records what changed in this
repository, by date. Format based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

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
