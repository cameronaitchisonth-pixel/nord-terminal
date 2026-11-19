#!/usr/bin/env bash
# Apply Nord colors to Signal Desktop and keep them applied across Signal updates.
# Run:   sudo bash desktop/signal/install.sh [--force]   (--force re-applies after palette changes)
# Undo:  sudo rm /etc/apt/apt.conf.d/99signal-nord /usr/local/sbin/signal-nord-reapply
#        sudo cp /opt/Signal/resources/app.asar.orig /opt/Signal/resources/app.asar
#        (or just reinstall: sudo apt install --reinstall signal-desktop)
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "Run with sudo: sudo bash $0" >&2; exit 1; }
HERE="$(cd "$(dirname "$0")" && pwd)"

OWNER=${SUDO_USER:?run via sudo from your own account}
[[ -f $HERE/node_modules/@electron/asar/bin/asar.mjs ]] ||
    { echo "First run  npm install  in $HERE as yourself (it fetches @electron/asar)" >&2; exit 1; }
sed -e "s|@OWNER@|$OWNER|" -e "s|@SIGNAL_DIR@|$HERE|" "$HERE/signal-nord-reapply" > /usr/local/sbin/signal-nord-reapply
chown root:root /usr/local/sbin/signal-nord-reapply && chmod 755 /usr/local/sbin/signal-nord-reapply
cat > /etc/apt/apt.conf.d/99signal-nord <<'EOF'
// Re-apply Nord colors to Signal Desktop after package updates (see /usr/local/sbin/signal-nord-reapply)
DPkg::Post-Invoke { "[ -x /usr/local/sbin/signal-nord-reapply ] && /usr/local/sbin/signal-nord-reapply || true"; };
EOF
/usr/local/sbin/signal-nord-reapply "$@"
