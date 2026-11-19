#!/usr/bin/env bash
# Link this repo's configs into place. Existing files are moved aside first, never deleted.
#
#   ./install.sh                      everything except the Claude Code / opencode extras
#   ./install.sh tmux nvim ghostty    just those parts
#   ./install.sh all                  everything, extras included
#   ./install.sh --dry-run [...]      show what would happen, change nothing
#   ./install.sh --deps [...]         also clone tpm and the zsh plugins (needs git)
#
# Parts: ghostty tmux nvim zsh starship bat btop lazygit yazi delta bin claude opencode xournalpp
set -euo pipefail

REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CONF="$HOME/.config"
STAMP=$(date +%Y%m%d-%H%M%S)
DRY=0 DEPS=0 parts=()

for arg in "$@"; do
    case $arg in
        --dry-run|-n) DRY=1 ;;
        --deps) DEPS=1 ;;
        -h|--help) sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        all) parts+=(ghostty tmux nvim zsh starship bat btop lazygit yazi delta bin claude opencode xournalpp) ;;
        -*) echo "unknown option: $arg" >&2; exit 2 ;;
        *) parts+=("$arg") ;;
    esac
done
[[ ${#parts[@]} -gt 0 ]] || parts=(ghostty tmux nvim zsh starship bat btop lazygit yazi delta bin)

run() { if ((DRY)); then echo "  would: $*"; else "$@"; fi; }

# link <repo path> <target>: back up whatever is there, then symlink
link() {
    local src="$REPO/$1" dst=$2
    if [[ -L $dst && $(readlink "$dst") == "$src" ]]; then
        echo "  ok      ${dst/#$HOME/\~}"
        return
    fi
    run mkdir -p "$(dirname "$dst")"
    if [[ -e $dst || -L $dst ]]; then
        echo "  backup  ${dst/#$HOME/\~} -> ${dst/#$HOME/\~}.pre-nord-terminal.$STAMP"
        run mv "$dst" "$dst.pre-nord-terminal.$STAMP"
    fi
    echo "  link    ${dst/#$HOME/\~} -> $1"
    run ln -s "$src" "$dst"
}

clone() { # clone <url> <dir>
    if [[ -d $2 ]]; then echo "  ok      ${2/#$HOME/\~}"; return; fi
    echo "  clone   $1"
    run git clone --depth 1 "$1" "$2"
}

notes=()
for part in "${parts[@]}"; do
    echo "$part"
    case $part in
        ghostty)
            link ghostty/config "$CONF/ghostty/config"
            link ghostty/themes "$CONF/ghostty/themes" ;;
        tmux)
            link tmux/tmux.conf "$HOME/.tmux.conf"
            link tmux/nord-dark.conf "$CONF/tmux/nord-dark.conf"
            link tmux/nord-light.conf "$CONF/tmux/nord-light.conf"
            ((DEPS)) && clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
            notes+=("tmux: start tmux and press Ctrl+Space then I (capital i) to install the plugins") ;;
        nvim)
            link nvim "$CONF/nvim"
            notes+=("nvim: the first start downloads NvChad and the plugins; then run :MasonInstallAll") ;;
        zsh)
            link zsh/zshrc "$HOME/.zshrc"
            link zsh/dircolors "$HOME/.dircolors"
            if ((DEPS)); then
                z="$HOME/.local/share/zsh/plugins"
                clone https://github.com/Aloxaf/fzf-tab "$z/fzf-tab"
                clone https://github.com/zsh-users/zsh-autosuggestions "$z/zsh-autosuggestions"
                clone https://github.com/zsh-users/zsh-syntax-highlighting "$z/zsh-syntax-highlighting"
                clone https://github.com/zsh-users/zsh-completions "$z/zsh-completions"
            fi ;;
        starship)
            link starship/starship.toml "$CONF/starship.toml" ;;
        bat)
            link bat/config-dark "$CONF/bat/config-dark"
            link bat/config-light "$CONF/bat/config-light" ;;
        btop)
            link btop/themes/nord-dark.theme "$CONF/btop/themes/nord-dark.theme"
            link btop/themes/nord-light.theme "$CONF/btop/themes/nord-light.theme"
            # btop rewrites btop.conf on exit, so it is edited in place rather than linked
            if [[ -f $CONF/btop/btop.conf ]]; then
                grep -q '^color_theme = "nord-auto"' "$CONF/btop/btop.conf" ||
                    { echo "  set     color_theme in ~/.config/btop/btop.conf";
                      run sed -i.pre-nord-terminal."$STAMP" 's/^color_theme = .*/color_theme = "nord-auto"/' "$CONF/btop/btop.conf"; }
            else
                echo "  write   ~/.config/btop/btop.conf"
                ((DRY)) || printf 'color_theme = "nord-auto"\ntheme_background = false\ntruecolor = true\n' > "$CONF/btop/btop.conf"
            fi ;;
        lazygit)
            link lazygit/config-dark.yml "$CONF/lazygit/config-dark.yml"
            link lazygit/config-light.yml "$CONF/lazygit/config-light.yml" ;;
        yazi)
            link yazi/yazi.toml "$CONF/yazi/yazi.toml" ;;
        delta)
            link delta/nord-dark.gitconfig "$CONF/delta/nord-dark.gitconfig"
            link delta/nord-light.gitconfig "$CONF/delta/nord-light.gitconfig"
            git config --global --get-all include.path 2>/dev/null | grep -q 'delta/current.gitconfig' ||
                notes+=("delta: add it to git with  git config --global core.pager delta && git config --global --add include.path ~/.config/delta/current.gitconfig") ;;
        bin)
            for f in "$REPO"/bin/*; do link "bin/$(basename "$f")" "$HOME/.local/bin/$(basename "$f")"; done
            [[ :$PATH: == *":$HOME/.local/bin:"* ]] || notes+=("bin: add ~/.local/bin to your PATH") ;;
        claude)
            link extras/claude/themes/nord-dark.json "$HOME/.claude/themes/nord-dark.json"
            link extras/claude/themes/nord-light.json "$HOME/.claude/themes/nord-light.json"
            notes+=("claude: merge extras/claude/settings-hooks.json into ~/.claude/settings.json for the tmux status icons") ;;
        opencode)
            link extras/opencode/tmux-state.js "$CONF/opencode/plugins/tmux-state.js" ;;
        xournalpp)
            x="$CONF/xournalpp"
            link xournalpp/toolbar.ini "$x/toolbar.ini"
            link xournalpp/palette.gpl "$x/palette.gpl"
            link xournalpp/plugins/NordTablet "$x/plugins/NordTablet"
            link xournalpp/xournalpp-nord "$HOME/.local/bin/xournalpp-nord"
            # Xournal++ rewrites settings.xml on exit, so the Nord settings are merged in rather than linked
            echo "  merge   Nord settings into ~/.config/xournalpp/settings.xml"
            if ((!DRY)); then
                [[ -f $x/settings.xml ]] && cp "$x/settings.xml" "$x/settings.xml.pre-nord-terminal.$STAMP"
                python3 -I "$REPO/xournalpp/apply-settings.py" "$REPO/xournalpp/settings.xml" "$x/settings.xml"
            fi
            # Start Xournal++ through xournalpp-nord, so pages and black/white ink follow light/dark
            app=/usr/share/applications/com.github.xournalpp.xournalpp.desktop
            if [[ -f $app ]]; then
                echo "  launch  Xournal++ app entry -> xournalpp-nord"
                ((DRY)) || { mkdir -p "$HOME/.local/share/applications"
                    sed "s|^Exec=xournalpp[^ ]*|Exec=$HOME/.local/bin/xournalpp-nord|" "$app" \
                        > "$HOME/.local/share/applications/com.github.xournalpp.xournalpp.desktop"; }
            fi
            notes+=("xournalpp: quit Xournal++ before installing (it overwrites settings.xml on exit)")
            if command -v otd >/dev/null; then
                notes+=("xournalpp: bind your tablet's express keys with  xournalpp/tablet-buttons")
            else
                notes+=("xournalpp: for tablet express keys, install OpenTabletDriver (https://opentabletdriver.net), then run xournalpp/tablet-buttons")
            fi ;;
        *)
            echo "  unknown part: $part (see ./install.sh --help)" >&2; exit 2 ;;
    esac
done

echo
if ((DRY)); then
    echo "Dry run: nothing changed."
else
    "$REPO/bin/nord-term" apply && echo "Applied the $("$REPO/bin/nord-term" status) Nord palette."
fi

missing=()
for cmd in ghostty tmux nvim zsh starship fzf fd rg eza bat zoxide lazygit yazi btop delta jq; do
    command -v "$cmd" >/dev/null || missing+=("$cmd")
done
fc-list 2>/dev/null | grep -i "Maple Mono NF" >/dev/null || missing+=("font: Maple Mono NF")
((${#missing[@]})) && notes+=("not found (install what you use): ${missing[*]}")

if ((${#notes[@]})); then
    echo
    echo "Next steps:"
    printf '  - %s\n' "${notes[@]}"
fi
