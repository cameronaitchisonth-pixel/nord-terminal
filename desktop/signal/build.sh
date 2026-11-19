#!/usr/bin/env bash
# Build a Nord-colored copy of Signal Desktop's app bundle (run as your user, no root).
# Output: build/app.asar (+ app.asar.unpacked) next to this script
# Install it with:  sudo bash install.sh (in this folder)
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
SRC=/opt/Signal/resources/app.asar
NODE=$(command -v node || echo "$HOME/.local/bin/node")
ASAR="$HERE/node_modules/@electron/asar/bin/asar.mjs"
WORK="$HERE/build"

# Start from the stock bundle, even if the installed one is already patched
if grep -q "nord-signal-patched" "$SRC" 2>/dev/null; then
    SRC=/opt/Signal/resources/app.asar.orig
fi
[[ -f $SRC ]] || { echo "No stock Signal bundle found at $SRC" >&2; exit 1; }

rm -rf "$WORK"; mkdir -p "$WORK/stock"
# asar looks for native modules in "<bundle>.unpacked", so stage the stock bundle under
# its normal name next to Signal's real unpacked folder (needed when SRC is app.asar.orig)
ln -s "$SRC" "$WORK/stock/app.asar"
ln -s /opt/Signal/resources/app.asar.unpacked "$WORK/stock/app.asar.unpacked"
"$NODE" "$ASAR" extract "$WORK/stock/app.asar" "$WORK/app"
rm -rf "$WORK/stock"
/usr/bin/python3 "$HERE/nord-palette.py" "$WORK/app"
# Signal keeps its native modules (*.node) outside the bundle; keep that layout
"$NODE" "$ASAR" pack "$WORK/app" "$WORK/app.asar" --unpack "*.node"
rm -rf "$WORK/app"
dpkg-query -W -f='${Version}\n' signal-desktop > "$WORK/signal-version"
echo "Built $WORK/app.asar for Signal $(cat "$WORK/signal-version")"
