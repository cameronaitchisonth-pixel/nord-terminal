#!/usr/bin/env bash
# Nord desktop for Ubuntu 24.04 / GNOME 46. Run as yourself (no sudo); see README for the sudo extras.
#
#   desktop/install.sh                  everything below
#   desktop/install.sh themes settings  just those parts
#   desktop/install.sh --dry-run [...]  show what would happen, change nothing
#
# Parts:
#   themes      Colloid Nord GTK/shell theme, icons and cursors (cloned from GitHub and installed)
#   extensions  GNOME extensions (GNOME asks you to confirm each) + this repo's Nord Focus
#   settings    GNOME settings (gnome/settings.ini) and keyboard shortcuts
#   scripts     nord-mode, nord-wallpaper, nord-focus, window-opacity + their user services
#   wallpapers  the wallpaper rotation's images (from linuxdotexe/nordic-wallpapers)
#   firefox     userChrome/userContent, prefs and the Nord start page
#   fonts       Maple Mono NF for every app that asks for a generic font
#   icons       Nord icons for apps whose launchers hard-code their own icon
#
# Existing files are moved to <name>.pre-nord-desktop.<date>, never deleted.
set -euo pipefail

HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CONF="$HOME/.config"
SRC="${XDG_CACHE_HOME:-$HOME/.cache}/nord-desktop/src"
STAMP=$(date +%Y%m%d-%H%M%S)
G=/usr/bin/gsettings   # not conda's copy, which can't see GNOME's settings
DRY=0 parts=()

for arg in "$@"; do
    case $arg in
        --dry-run|-n) DRY=1 ;;
        -h|--help) sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        -*) echo "unknown option: $arg" >&2; exit 2 ;;
        *) parts+=("$arg") ;;
    esac
done
[[ ${#parts[@]} -gt 0 ]] || parts=(themes extensions settings scripts wallpapers firefox fonts icons)

run() { if ((DRY)); then echo "  would: $*"; else "$@"; fi; }

link() { # link <path under desktop/> <target>
    local src="$HERE/$1" dst=$2
    if [[ -L $dst && $(readlink "$dst") == "$src" ]]; then echo "  ok      ${dst/#$HOME/\~}"; return; fi
    run mkdir -p "$(dirname "$dst")"
    if [[ -e $dst || -L $dst ]]; then
        echo "  backup  ${dst/#$HOME/\~} -> ${dst/#$HOME/\~}.pre-nord-desktop.$STAMP"
        run mv "$dst" "$dst.pre-nord-desktop.$STAMP"
    fi
    echo "  link    ${dst/#$HOME/\~} -> desktop/$1"
    run ln -s "$src" "$dst"
}

clone() { # clone <github owner/repo> -> $SRC/<repo>
    local dir="$SRC/${1#*/}"
    if [[ -d $dir/.git ]]; then echo "  update  $1"; run git -C "$dir" pull -q --ff-only || true
    else echo "  clone   $1"; run mkdir -p "$SRC"; run git clone -q --depth 1 "https://github.com/$1" "$dir"; fi
}

keybinding() { # keybinding <id> <name> <binding> <command>
    local base=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings
    local path="$base/$1/" list
    list=$($G get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)
    if [[ $list != *"'$path'"* ]]; then
        if [[ $list == "@as []" || $list == "[]" ]]; then list="['$path']"; else list="${list%]}, '$path']"; fi
        run $G set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$list"
    fi
    local k="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$path"
    run $G set "$k" name "$2"; run $G set "$k" binding "$3"; run $G set "$k" command "$4"
    echo "  key     $3  $2"
}

notes=()
for part in "${parts[@]}"; do
    echo "$part"
    case $part in
        themes)
            clone vinceliuice/Colloid-gtk-theme
            clone vinceliuice/Colloid-icon-theme
            echo "  install Colloid-{Light,Dark}-Nord, Colloid-Nord icons, Colloid cursors"
            run bash "$SRC/Colloid-gtk-theme/install.sh" -c light dark --tweaks nord
            run bash "$SRC/Colloid-icon-theme/install.sh" -s nord
            run bash -c "cd \"$SRC/Colloid-icon-theme/cursors\" && ./install.sh" ;;
        extensions)
            run mkdir -p "$HOME/.local/share/gnome-shell/extensions"
            link gnome/nord-focus@nord-terminal "$HOME/.local/share/gnome-shell/extensions/nord-focus@nord-terminal"
            run glib-compile-schemas "$HERE/gnome/nord-focus@nord-terminal/schemas"
            while read -r uuid; do
                [[ -z $uuid || $uuid == \#* ]] && continue
                if gnome-extensions info "$uuid" >/dev/null 2>&1; then echo "  ok      $uuid"; continue; fi
                echo "  ask     $uuid (confirm in the GNOME dialog)"
                run gdbus call --session --dest org.gnome.Shell.Extensions --object-path /org/gnome/Shell/Extensions \
                    --method org.gnome.Shell.Extensions.InstallRemoteExtension "$uuid" >/dev/null || true
            done < "$HERE/gnome/extensions.txt"
            for uuid in $(grep -v '^#' "$HERE/gnome/extensions.txt") nord-focus@nord-terminal; do
                run gnome-extensions enable "$uuid" 2>/dev/null || true
            done
            notes+=("extensions: log out and back in once so GNOME loads the new extensions (on X11, Alt+F2 then r also works)") ;;
        settings)
            echo "  load    gnome/settings.ini"
            ((DRY)) || dconf load /org/gnome/ < "$HERE/gnome/settings.ini"
            keybinding nord-mode "Toggle Nord light/dark" "<Super><Shift>d" "$HOME/.local/bin/nord-mode toggle"
            keybinding nord-wallpaper "Next Nord wallpaper" "<Super><Shift>w" "$HOME/.local/bin/nord-wallpaper next"
            keybinding ghostty "Ghostty" "<Primary><Alt>t" "ghostty" ;;
        scripts)
            for f in "$HERE"/bin/*; do link "bin/$(basename "$f")" "$HOME/.local/bin/$(basename "$f")"; done
            link config/window-opacity.conf "$CONF/window-opacity.conf"
            for m in light dark mid; do link "config/nord-wallpaper/$m.txt" "$CONF/nord-wallpaper/$m.txt"; done
            for u in "$HERE"/systemd/*; do link "systemd/$(basename "$u")" "$CONF/systemd/user/$(basename "$u")"; done
            run systemctl --user daemon-reload
            run systemctl --user enable --now nord-mode.service nord-wallpaper.timer window-opacity.service
            [[ -x $HOME/.local/bin/nord-term ]] ||
                notes+=("scripts: install the terminal half too (../install.sh) so nord-mode also switches tmux, Neovim and the shell") ;;
        wallpapers)
            dir="$HOME/Pictures/Wallpapers" repo="$SRC/nordic-wallpapers"
            run mkdir -p "$dir"
            if [[ ! -d $repo/.git ]]; then
                echo "  clone   linuxdotexe/nordic-wallpapers (only the images in the pools)"
                run git clone -q --depth 1 --filter=blob:none --sparse https://github.com/linuxdotexe/nordic-wallpapers "$repo"
            fi
            run git -C "$repo" sparse-checkout set --no-cone $(grep -v '^#' "$HERE/wallpapers/nordic-paths.txt" | sed 's|^|/|')
            while read -r p; do
                [[ -z $p || $p == \#* ]] && continue
                [[ -f $dir/${p##*/} ]] || run cp "$repo/$p" "$dir/"
            done < "$HERE/wallpapers/nordic-paths.txt"
            run cp "$HERE/wallpapers/Abstract-Nord-light.png" "$dir/"
            # Light/dark pair in Settings > Appearance
            echo "  write   ~/.local/share/gnome-background-properties/nord.xml"
            if ((!DRY)); then
                mkdir -p "$HOME/.local/share/gnome-background-properties"
                sed "s|@WALLS@|$dir|g" "$HERE/wallpapers/nord.xml" > "$HOME/.local/share/gnome-background-properties/nord.xml"
            fi
            [[ -x $HOME/.local/bin/nord-wallpaper ]] && run "$HOME/.local/bin/nord-wallpaper" next ;;
        firefox)
            link firefox/startpage "$HOME/.local/share/nord-startpage"
            profiles=()
            for ini in "$HOME/snap/firefox/common/.mozilla/firefox/profiles.ini" "$HOME/.mozilla/firefox/profiles.ini"; do
                [[ -f $ini ]] || continue
                while read -r p; do profiles+=("$(dirname "$ini")/$p"); done < <(sed -n 's/^Path=//p' "$ini")
            done
            ((${#profiles[@]})) || { echo "  skip    no Firefox profile found (start Firefox once first)"; continue; }
            for prof in "${profiles[@]}"; do
                [[ -d $prof ]] || continue
                echo "  profile ${prof/#$HOME/\~}"
                link firefox/chrome/userChrome.css "$prof/chrome/userChrome.css"
                link firefox/chrome/userContent.css "$prof/chrome/userContent.css"
                if [[ -f $prof/user.js ]] && grep -q 'nord-startpage' "$prof/user.js"; then echo "  ok      user.js"
                else
                    echo "  append  user.js"
                    ((DRY)) || { echo; sed "s|@HOME@|$HOME|g" "$HERE/firefox/user.js"; } >> "$prof/user.js"
                fi
            done
            run systemctl --user daemon-reload
            run systemctl --user enable --now nord-startpage.service 2>/dev/null || true
            notes+=("firefox: restart Firefox. For the start page on new tabs, add 'New Tab Override' and set its Custom URL to http://127.0.0.1:8473/ with 'Set focus to the web page' ticked")
            notes+=("firefox: Dark Reader users can import firefox/darkreader-nord.json") ;;
        fonts)
            link config/fontconfig/fonts.conf "$CONF/fontconfig/fonts.conf"
            fc-list | grep -i "Maple Mono NF" >/dev/null || notes+=("fonts: install Maple Mono NF (https://github.com/subframe7536/maple-font)") ;;
        icons)
            # Some launchers point at their own image file, which no icon theme can restyle
            for name in firefox_firefox ghostty_ghostty; do
                src="/var/lib/snapd/desktop/applications/$name.desktop"
                [[ -f $src ]] || continue
                icon=$([[ $name == firefox_firefox ]] && echo firefox || echo com.mitchellh.ghostty)
                echo "  launch  $name -> Icon=$icon"
                ((DRY)) || { mkdir -p "$HOME/.local/share/applications";
                             sed "s|^Icon=.*|Icon=$icon|" "$src" > "$HOME/.local/share/applications/$name.desktop"; }
            done
            # Apps whose icon name isn't in Colloid: point it at the matching Colloid icon
            for theme in "$HOME"/.local/share/icons/Colloid-Nord{,-Light,-Dark}; do
                [[ -d $theme/apps/scalable ]] || continue
                run ln -sfn claude.svg "$theme/apps/scalable/claude-desktop.svg"
                run gtk-update-icon-cache -f -q "$theme"
            done ;;
        *)
            echo "  unknown part: $part (see desktop/install.sh --help)" >&2; exit 2 ;;
    esac
done

if ((!DRY)) && [[ -x $HOME/.local/bin/nord-mode ]]; then
    "$HOME/.local/bin/nord-mode" apply && echo && echo "Applied the $("$HOME/.local/bin/nord-mode" status) Nord theme."
fi

notes+=("system (sudo, optional): sudo bash $HERE/system/install-system.sh   (zsh as login shell, Nord boot splash and login screen)")
notes+=("signal (sudo, optional): see desktop/signal/install.sh to recolor Signal Desktop")
notes+=("vscode: merge desktop/vscode/settings.json into VS Code's settings")
echo
echo "Next steps:"
printf '  - %s\n' "${notes[@]}"
