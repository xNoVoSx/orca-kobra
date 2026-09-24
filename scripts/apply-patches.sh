#!/usr/bin/env bash
# Wendet alle Patches aus patches/ auf einen Orca-Quellbaum an.
#
#   scripts/apply-patches.sh <orca-quellordner> [patch-ordner] [bericht.md]
#
# - passt ein Patch: wird angewendet
# - ist er schon in Orca enthalten (laesst sich rueckwaerts anwenden): wird uebersprungen
# - passt er gar nicht mehr: Abbruch mit Fehlermeldung (der Build schlaegt fehl,
#   das letzte funktionierende AppImage bleibt in den Releases)
set -euo pipefail

SRC=${1:?Orca-Quellordner fehlt}
PATCHES=$(realpath "${2:-patches}")
REPORT=${3:-patch-report.md}

: > "$REPORT"
shopt -s nullglob
list=("$PATCHES"/*.patch)
if [ ${#list[@]} -eq 0 ]; then
    echo "Keine Patches gefunden in $PATCHES" >&2
    exit 1
fi

for p in "${list[@]}"; do
    name=$(basename "$p")
    subject=$(awk '/^Subject:/ { s = $0; while ((getline line) > 0 && line ~ /^ /) s = s line; print s; exit }' "$p" \
              | sed -e 's/^Subject: *//' -e 's/^\[PATCH[^]]*\] *//')
    if git -C "$SRC" apply --check "$p" 2>/dev/null; then
        git -C "$SRC" apply "$p"
        echo "- applied: \`$name\` - $subject" | tee -a "$REPORT"
    elif git -C "$SRC" apply --reverse --check "$p" 2>/dev/null; then
        echo "- skipped (already in Orca): \`$name\` - $subject" | tee -a "$REPORT"
    else
        echo "::error title=Patch no longer applies::$name does not apply to the current Orca source"
        git -C "$SRC" apply --check -v "$p" || true
        exit 1
    fi
done
