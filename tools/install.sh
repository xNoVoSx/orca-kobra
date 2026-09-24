#!/usr/bin/env bash
# Installiert den Starter "orca-kobra" mit Menueeintrag und Icon (nur fuer den eigenen Benutzer).
#
#   tools/install.sh            installieren / aktualisieren
#   tools/install.sh --remove   wieder entfernen (AppImages in ~/Applications bleiben)
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
BIN="$HOME/.local/bin"
APPS="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
ICONS="${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor"
ICON_SIZES="16 22 24 32 48 64 128 256 512"
DIR="${ORCA_KOBRA_DIR:-$HOME/Applications}"

if [ "${1:-}" = "--remove" ]; then
    rm -f "$BIN/orca-kobra" "$APPS/orca-kobra.desktop" "$ICONS/scalable/apps/orca-kobra.svg"
    for s in $ICON_SIZES 192; do rm -f "$ICONS/${s}x${s}/apps/orca-kobra.png"; done
    command -v update-desktop-database >/dev/null && update-desktop-database "$APPS" || true
    command -v xdg-icon-resource >/dev/null && xdg-icon-resource forceupdate || true
    echo "Starter entfernt. AppImages liegen weiter in $DIR."
    exit 0
fi

for cmd in curl python3 sha256sum flock; do
    command -v "$cmd" >/dev/null || { echo "Fehlt: $cmd"; exit 1; }
done

mkdir -p "$BIN" "$APPS" "$ICONS/scalable/apps"
install -m 755 "$HERE/orca-kobra" "$BIN/orca-kobra"

# Erste Version laden, falls noch keine da ist
if [ ! -x "$DIR/OrcaSlicer-Kobra.AppImage" ]; then
    "$BIN/orca-kobra" --update
fi

# Eigenes Icon (Orca-Logo mit Spulen-Abzeichen), damit man es im Menue vom normalen Orca
# unterscheidet: als SVG und - fuer Menues/Taskleisten, die kein SVG nehmen - als PNG in den
# ueblichen Groessen.
install -m 644 "$HERE/orca-kobra.svg" "$ICONS/scalable/apps/orca-kobra.svg"
rm -f "$ICONS/192x192/apps/orca-kobra.png"   # altes Icon (Orca-Original) aus frueheren Versionen
if command -v rsvg-convert >/dev/null; then
    render() { rsvg-convert -w "$1" -h "$1" "$HERE/orca-kobra.svg" -o "$2"; }
elif command -v magick >/dev/null; then
    render() { magick -background none -density 384 "$HERE/orca-kobra.svg" -resize "$1x$1" "$2"; }
else
    render() { return 1; }
    echo "  Hinweis: weder rsvg-convert noch magick gefunden - Icon nur als SVG installiert."
fi
for s in $ICON_SIZES; do
    mkdir -p "$ICONS/${s}x${s}/apps"
    render "$s" "$ICONS/${s}x${s}/apps/orca-kobra.png" || break
done

cat > "$APPS/orca-kobra.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=OrcaSlicer (Kobra)
GenericName=3D-Druck-Slicer
Comment=OrcaSlicer mit Kobra/Spoolman-Patches, aktualisiert sich selbst
Exec=$BIN/orca-kobra %F
Icon=orca-kobra
Terminal=false
StartupWMClass=orca-slicer
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
# Icon-Caches der Desktops (KDE, GNOME, ...) auffrischen, sonst bleibt das alte/leere Icon stehen
command -v xdg-icon-resource >/dev/null && xdg-icon-resource forceupdate || true

echo "Fertig."
echo "  Starter:  $BIN/orca-kobra   (Menue: \"OrcaSlicer (Kobra)\")"
echo "  Status:   orca-kobra --status"
case ":$PATH:" in *":$BIN:"*) ;; *) echo "  Hinweis: $BIN ist nicht im PATH - der Menueeintrag funktioniert trotzdem." ;; esac
