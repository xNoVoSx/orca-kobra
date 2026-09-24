# Build

[Back to README](../README.md)

All builds run on GitHub Actions in [`.github/workflows/nightly.yml`](../.github/workflows/nightly.yml).
The steps follow Orca's own Linux build (`build_linux.sh -ur`, `-drlL`, `-isrlL` on Ubuntu 24.04
with Clang and lld), so a patched build behaves like an official Orca nightly.

## When it builds

The workflow runs every night at 01:30 UTC and can be started by hand. The first job decides
whether there is anything to build:

- It reads the current commit of Orca's `main` branch.
- It hashes everything that affects the result: `patches/*.patch`, `scripts/*.sh` and
  `nightly.yml` itself.
- Both together form a marker `build-id: orca-<commit>-patches-<hash>`, which every release stores
  as a hidden comment in its notes.
- If one of the last 30 releases already carries this marker, nothing is built and the run summary
  says *Nichts Neues* (nothing new).

So a new release appears when Orca's `main` moved or a patch, the apply script or the workflow
changed. Changes to the docs, the launcher, `ci.yml` or the README do not trigger a build.

## Start a build manually

**Actions → Orca Kobra Nightly → Run workflow**, or with the GitHub CLI:

```bash
gh workflow run nightly.yml -R xNoVoSx/orca-kobra
gh workflow run nightly.yml -R xNoVoSx/orca-kobra -f force=true   # build even without changes
gh run watch -R xNoVoSx/orca-kobra
```

## Jobs

| Job | What it does |
|---|---|
| *Gibt es etwas Neues?* (check) | Orca commit, patch hash and marker as above; decides whether to build and picks the release tag. |
| *Abhaengigkeiten (Cache)* (deps) | Builds Orca's dependencies (`build_linux.sh -drlL`) only if they are not cached yet. The cache key is a hash of Orca's `deps/` folder, so it is rebuilt only when Orca changes its dependencies. The first run takes a few hours. |
| *AppImage bauen* (build) | Checks out Orca at the chosen commit, applies the patches with `scripts/apply-patches.sh`, restores the dependencies, builds Orca and the AppImage (`build_linux.sh -isrlL`) with ccache (3 GB), and publishes the release. |

With warm caches a build takes about 10 minutes; after larger upstream changes (less ccache hits)
up to about two hours.

## Applying the patches

`scripts/apply-patches.sh <orca-source> [patch-dir] [report.md]` goes through the patches in name
order:

| Result | Meaning |
|---|---|
| `applied` | The patch applies cleanly (`git apply --check`) and was applied. |
| `skipped (already in Orca)` | The patch applies in reverse, so Orca already contains it. Time to [retire it](patches.md#retiring-a-patch). |
| error *Patch no longer applies* | Neither works: Orca changed the code the patch touches. The build fails, no release is published, and the last release stays available. See [editing a patch](patches.md#editing-a-patch). |

The report goes into the run summary and the release notes.

## Releases

- Tag: `kobra-<YYYYMMDD>-<HHMM>-<orca-commit>` (UTC), title `Orca Kobra <date> (<orca-commit>)`.
- Assets: `OrcaSlicer-Kobra_<version>_<YYYYMMDD>_<orca-commit>_x86_64.AppImage` and its `.sha256`.
- Notes: Orca version and commit (link), the patch report, the hidden build marker.
- Each new release is marked *latest*; the launcher downloads exactly that one.
- Only the newest **5** releases are kept (`KEEP_RELEASES`); older ones and their tags are deleted.

The source of a build is the Orca commit in its notes plus the patches of this repository at the
time of the build — this is what the AGPL requires to be available.

## Building in a fork

1. Fork this repository and enable Actions in the fork (**Actions** tab).
2. Change or add patches, push, then start the workflow by hand (the first run builds the
   dependencies and takes a few hours; afterwards the nightly schedule keeps it up to date).
3. Point the launcher to your fork in `~/.config/orca-kobra.conf`:

   ```bash
   ORCA_KOBRA_REPO=<your-user>/orca-kobra
   ```

The workflow only needs the default `GITHUB_TOKEN` (permission `contents: write` for releases).

## CI

[`.github/workflows/ci.yml`](../.github/workflows/ci.yml) runs on every push and pull request:
`shellcheck` for the scripts and the launcher, `actionlint` for the workflows. It does not build
Orca.
