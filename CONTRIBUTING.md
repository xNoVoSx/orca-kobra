# Contributing

Contributions are welcome - bug reports, ideas, documentation and patches.

## Where does it belong?

- Problems with the **bridge, the Kobra Spoolman plugin or the Spoolman setup** belong to
  [kobra-spoolman](https://github.com/xNoVoSx/kobra-spoolman).
- Problems that also happen with an **official OrcaSlicer nightly** belong to
  [OrcaSlicer](https://github.com/OrcaSlicer/OrcaSlicer/issues).
- Everything about the **patches, the nightly build and the launcher** belongs here.

## Development setup

Nothing to install for the repository itself. For patches you need a clone of OrcaSlicer; the
whole workflow (apply, edit, export, check against clean upstream) is in
[docs/patches.md](docs/patches.md#editing-a-patch).

Before a pull request:

```bash
shellcheck scripts/apply-patches.sh tools/install.sh tools/orca-kobra
actionlint
```

CI runs the same checks. Building Orca locally is optional; pushing to a fork and letting the
nightly workflow build it is usually easier ([docs/build.md](docs/build.md#building-in-a-fork)).

## Guidelines

- **Every patch should disappear again.** Keep patches small, focused and written so they could go
  upstream as they are; open the upstream PR or issue when possible.
- Keep the patch file names (`000N-...`); new patches get the next free number.
- Behaviour changes need a CHANGELOG entry. When a patch changes in content, note it there -
  the release notes only show its subject line.
- Docs are English with a German translation (`README.de.md`, `docs/de/`) - please keep both in
  sync where you can. Code comments and the launcher's messages are German (the project started
  that way).
