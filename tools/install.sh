#!/usr/bin/env bash
# Installiert den Starter "orca-kobra" mit Menueeintrag und Icon (nur fuer den eigenen Benutzer).
#
#   tools/install.sh            installieren / aktualisieren
#   tools/install.sh --remove   wieder entfernen (AppImages in ~/Applications bleiben)
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
BIN="$HOME/.local/bin"
APPS="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
ICONS="${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor/192x192/apps"
DIR="${ORCA_KOBRA_DIR:-$HOME/Applications}"

if [ "${1:-}" = "--remove" ]; then
    rm -f "$BIN/orca-kobra" "$APPS/orca-kobra.desktop" "$ICONS/orca-kobra.png"
    command -v update-desktop-database >/dev/null && update-desktop-database "$APPS" || true
    echo "Starter entfernt. AppImages liegen weiter in $DIR."
    exit 0
fi

for cmd in curl python3 sha256sum flock; do
    command -v "$cmd" >/dev/null || { echo "Fehlt: $cmd"; exit 1; }
done

mkdir -p "$BIN" "$APPS" "$ICONS"
install -m 755 "$HERE/orca-kobra" "$BIN/orca-kobra"

# Erste Version laden, falls noch keine da ist
if [ ! -x "$DIR/OrcaSlicer-Kobra.AppImage" ]; then
    "$BIN/orca-kobra" --update
fi

# Icon aus dem AppImage holen
tmp=$(mktemp -d)
( cd "$tmp" && "$DIR/OrcaSlicer-Kobra.AppImage" --appimage-extract 'OrcaSlicer.png' >/dev/null 2>&1 ) || true
if [ -f "$tmp/squashfs-root/OrcaSlicer.png" ]; then
    cp "$tmp/squashfs-root/OrcaSlicer.png" "$ICONS/orca-kobra.png"
fi
rm -rf "$tmp"

cat > "$APPS/orca-kobra.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=OrcaSlicer (Kobra)
GenericName=3D-Druck-Slicer
Comment=OrcaSlicer mit Kobra/Spoolman-Patches, aktualisiert sich selbst
Exec=$BIN/orca-kobra %F
Icon=orca-kobra
Terminal=false
Categories=Graphics;3DGraphics;Engineering;
MimeType=model/stl;model/3mf;application/vnd.ms-3mfdocument;application/prs.wavefront-obj;application/x-amf;model/step;
Keywords=3D;Drucker;Slicer;Orca;Kobra;
PrefersNonDefaultGPU=true
X-KDE-RunOnDiscreteGpu=true
Actions=Update;

[Desktop Action Update]
Name=Nach Update suchen
Exec=$BIN/orca-kobra --update
EOF
command -v update-desktop-database >/dev/null && update-desktop-database "$APPS" || true

echo "Fertig."
echo "  Starter:  $BIN/orca-kobra   (Menue: \"OrcaSlicer (Kobra)\")"
echo "  Status:   orca-kobra --status"
case ":$PATH:" in *":$BIN:"*) ;; *) echo "  Hinweis: $BIN ist nicht im PATH - der Menueeintrag funktioniert trotzdem." ;; esac
