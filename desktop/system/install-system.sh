#!/usr/bin/env bash
# Nord system-level setup: zsh, yazi preview helpers, boot splash, login screen.
# Run from a terminal:  sudo bash desktop/system/install-system.sh
#
# Undo:
#   boot splash:  sudo update-alternatives --set default.plymouth /usr/share/plymouth/themes/bgrt/bgrt.plymouth && sudo update-initramfs -u
#   login screen: sudo -u gdm env HOME=/var/lib/gdm3 dbus-run-session -- bash -c 'for k in background-picture-uri background-size background-color; do gsettings reset com.ubuntu.login-screen $k; done; for k in color-scheme icon-theme cursor-theme font-name; do gsettings reset org.gnome.desktop.interface $k; done'
#   shell:        chsh -s /bin/bash
set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "Run with sudo: sudo bash $0" >&2; exit 1; }
USER_NAME=${SUDO_USER:?run via sudo from your own account}
USER_HOME=$(getent passwd "$USER_NAME" | cut -d: -f6)
HERE="$(cd "$(dirname "$0")" && pwd)"
G=/usr/bin/gsettings

step() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }

step "Installing zsh and yazi preview helpers"
apt-get install -y zsh ffmpegthumbnailer poppler-utils jq p7zip-full imagemagick

step "Making zsh the login shell for $USER_NAME"
chsh -s /usr/bin/zsh "$USER_NAME"

step "Installing the Nord boot splash (Plymouth)"
rm -rf /usr/share/plymouth/themes/nord
cp -r "$HERE/plymouth-nord" /usr/share/plymouth/themes/nord
update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth \
    /usr/share/plymouth/themes/nord/nord.plymouth 200
update-alternatives --set default.plymouth /usr/share/plymouth/themes/nord/nord.plymouth
echo "Rebuilding the initramfs so the splash is used at boot (takes a minute)..."
update-initramfs -u

step "Theming the login screen (GDM)"
# The login screen can't read your home folder, so icons, cursors and the wallpaper go system-wide.
for t in Colloid-Nord Colloid-Nord-Dark Colloid-dark-cursors; do
    rm -rf "/usr/share/icons/$t"
    cp -a "$USER_HOME/.local/share/icons/$t" /usr/share/icons/
done
gtk-update-icon-cache -q /usr/share/icons/Colloid-Nord-Dark 2>/dev/null || true
install -Dm644 "$HERE/backgrounds/nord-login.png" /usr/share/backgrounds/nord/nord-login.png

sudo -u gdm env HOME=/var/lib/gdm3 XDG_CONFIG_HOME=/var/lib/gdm3/.config /usr/bin/dbus-run-session -- bash -c "
  $G set com.ubuntu.login-screen background-picture-uri 'file:///usr/share/backgrounds/nord/nord-login.png'
  $G set com.ubuntu.login-screen background-size 'cover'
  $G set com.ubuntu.login-screen background-color '#2E3440'
  $G set org.gnome.desktop.interface color-scheme 'prefer-dark'
  $G set org.gnome.desktop.interface icon-theme 'Colloid-Nord-Dark'
  $G set org.gnome.desktop.interface cursor-theme 'Colloid-dark-cursors'
  $G set org.gnome.desktop.interface font-name 'Inter 11'
"

step "Done"
echo "Log out and back in to start using zsh and the new GNOME extensions."
echo "The boot splash and login screen appear on your next restart."
