# nord-terminal

A [Nord](https://www.nordtheme.com/) terminal setup: Ghostty, tmux, Neovim (NvChad) and zsh with Starship,
plus matching themes for bat, delta, lazygit, yazi and btop. Everything switches between Nord light and Nord dark
together.

The [`desktop/`](#desktop-gnome) half themes the GNOME desktop around it the same way: GTK and shell theme, icons,
extensions, wallpapers, Firefox and more. Each half installs on its own.

<!-- Add a screenshot: save it as docs/screenshot.png and uncomment the next line -->
<!-- ![nord-terminal](docs/screenshot.png) -->

## What's in it

| Part | What you get |
|---|---|
| **Ghostty** | Nord light/dark themes that follow the system appearance, slightly see-through background, Maple Mono NF, no title bar (tmux is the chrome), copy on select |
| **tmux** | Colorful Nord status bar: each window gets its own color, a session pill that turns yellow while the prefix is held, and CPU / RAM / battery / date / host pills. Popups for lazygit, yazi, a session switcher and a fuzzy window picker. Sessions are saved every 15 minutes and restored when tmux starts |
| **Neovim** | NvChad 2.5 with Nord (dark) and OneNord Light, switching live with the system. LSPs for Python, web, shell, JSON/YAML and Markdown, format on save, in-buffer Markdown rendering, live browser preview and HTML export |
| **zsh + Starship** | Powerline-style Nord prompt that shrinks finished commands to `❯ cmd`, fzf and fzf-tab with Nord colors, autosuggestions, syntax highlighting, zoxide, eza |
| **CLI tools** | Nord configs for bat, delta (git diffs), lazygit, yazi and btop |
| **Xournal++ (optional)** | Nord_Dark and Nord_Light toolbars with Nord pen colors, a Nord color palette, and new pages on a dotted Polar Night background |
| **Extras (optional)** | Status-bar icons for AI coding sessions in tmux (⏳ working, 🔔 waiting for you, ✓ done) for Claude Code and opencode, and Nord themes for Claude Code |

## Requirements

- [Ghostty](https://ghostty.org), [tmux](https://github.com/tmux/tmux) 3.4+, [Neovim](https://neovim.io) 0.11+, zsh, git
- The [Maple Mono NF](https://github.com/subframe7536/maple-font) font (any Nerd Font works if you change `font-family` in `ghostty/config`)
- [Starship](https://starship.rs), [fzf](https://github.com/junegunn/fzf), [fd](https://github.com/sharkdp/fd),
  [ripgrep](https://github.com/BurntSushi/ripgrep), [eza](https://github.com/eza-community/eza),
  [bat](https://github.com/sharkdp/bat), [zoxide](https://github.com/ajeetdsouza/zoxide)
- Optional: [lazygit](https://github.com/jesseduffield/lazygit), [yazi](https://github.com/sxyazi/yazi),
  [btop](https://github.com/aristocratos/btop), [delta](https://github.com/dandavison/delta), `jq`,
  `pandoc` (Markdown preview/export in Neovim)

Missing tools are skipped: the shell and status bar still work without them, and `install.sh` lists what it didn't find.

## Install

```sh
git clone https://github.com/<you>/nord-terminal ~/nord-terminal
cd ~/nord-terminal
./install.sh --dry-run     # see what would change
./install.sh --deps        # link everything, and clone tpm + the zsh plugins
```

`install.sh` symlinks the files into place, so `git pull` updates your setup. Anything already there is moved to
`<name>.pre-nord-terminal.<date>` first, never deleted. You can install just some parts:

```sh
./install.sh tmux nvim ghostty
./install.sh all           # also the Claude Code and opencode extras
```

Parts: `ghostty tmux nvim zsh starship bat btop lazygit yazi delta bin claude opencode xournalpp`.

Then:

1. Start tmux and press <kbd>Ctrl</kbd>+<kbd>Space</kbd> then <kbd>I</kbd> to install the tmux plugins.
2. Start `nvim`: it downloads NvChad and the plugins on the first run. Then run `:MasonInstallAll`.
3. For delta: `git config --global core.pager delta && git config --global --add include.path ~/.config/delta/current.gitconfig`

| Repo | Installed at |
|---|---|
| `ghostty/` | `~/.config/ghostty/` |
| `tmux/tmux.conf`, `tmux/nord-*.conf` | `~/.tmux.conf`, `~/.config/tmux/` |
| `nvim/` | `~/.config/nvim/` |
| `zsh/zshrc`, `zsh/dircolors` | `~/.zshrc`, `~/.dircolors` |
| `starship/starship.toml` | `~/.config/starship.toml` |
| `bat/`, `delta/`, `lazygit/`, `yazi/`, `btop/themes/` | `~/.config/<tool>/` |
| `bin/` | `~/.local/bin/` |
| `xournalpp/` | `~/.config/xournalpp/` (`settings.xml` is merged into yours, not linked) |

## Light and dark

```sh
nord-term toggle     # or: nord-term light / nord-term dark / nord-term status
```

`nord-term` takes the mode from GNOME's light/dark setting, or the system appearance on macOS, and otherwise
keeps its own. Changing it recolors running tmux and Neovim and the next zsh prompt, and points bat, delta,
lazygit and btop at their light or dark config. Ghostty follows the system appearance by itself.

On GNOME, `nord-term watch` keeps following the system switch (for example the Quick Settings "Dark Style" button).
Run it as a user service to have it always on.

## Keys

**tmux** (prefix <kbd>Ctrl</kbd>+<kbd>Space</kbd>)

| Keys | Action |
|---|---|
| <kbd>Alt</kbd>+<kbd>1</kbd>…<kbd>9</kbd> | Go to window 1–9 |
| <kbd>Shift</kbd>+<kbd>←</kbd>/<kbd>→</kbd>, <kbd>Alt</kbd>+<kbd>Shift</kbd>+<kbd>H</kbd>/<kbd>L</kbd> | Previous / next window |
| <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>←</kbd>/<kbd>→</kbd> | Move the current window left / right |
| <kbd>Alt</kbd>+arrows, prefix <kbd>h</kbd><kbd>j</kbd><kbd>k</kbd><kbd>l</kbd> | Switch panes |
| <kbd>Ctrl</kbd>+<kbd>h</kbd><kbd>j</kbd><kbd>k</kbd><kbd>l</kbd> | Move between tmux panes and Neovim splits |
| prefix <kbd>"</kbd> / <kbd>%</kbd> | Split down / right, in the current folder |
| prefix <kbd>w</kbd> | Fuzzy window picker with live preview (<kbd>W</kbd>: the built-in tree) |
| prefix <kbd>f</kbd> | Session switcher |
| prefix <kbd>g</kbd> / <kbd>e</kbd> | lazygit / yazi popup in the current folder |
| prefix <kbd>Tab</kbd> | Last window |
| prefix <kbd>[</kbd>, then <kbd>v</kbd>, <kbd>y</kbd> | Copy mode (vi keys): select, copy |
| prefix <kbd>&</kbd> | Close the window |

**Ghostty**: <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>B</kbd> shows or hides the title bar. <kbd>Alt</kbd>+numbers and
<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+arrows go to tmux instead of Ghostty tabs.

**Neovim** (leader <kbd>Space</kbd>, NvChad defaults plus)

| Keys | Action |
|---|---|
| <kbd>;</kbd> | Command mode |
| <kbd>j</kbd><kbd>k</kbd> | Leave insert mode |
| <kbd>Space</kbd> <kbd>m</kbd> <kbd>r</kbd> | Markdown: toggle in-buffer rendering |
| <kbd>Space</kbd> <kbd>m</kbd> <kbd>p</kbd> | Markdown: live preview in the browser (updates as you type) |
| <kbd>Space</kbd> <kbd>m</kbd> <kbd>x</kbd> | Markdown: toggle a `- [ ]` checkbox |
| <kbd>Space</kbd> <kbd>m</kbd> <kbd>e</kbd> | Markdown: export to a standalone HTML file |
| `:FormatToggle` | Turn format on save off/on (`:FormatToggle!` for this buffer only) |

**zsh**: <kbd>Ctrl</kbd>+<kbd>T</kbd> files, <kbd>Alt</kbd>+<kbd>C</kbd> folders, <kbd>Ctrl</kbd>+<kbd>R</kbd>
history (all fzf); <kbd>Tab</kbd> completes through fzf; `z <dir>` jumps (zoxide); `y` opens yazi and changes to
the folder you quit in; `ls`/`ll`/`la`/`lt` are eza.

## AI session icons (optional)

The tmux status bar can show what an AI coding session in each window is doing: ⏳ working, 🔔 waiting for you,
✓ finished (cleared when you visit the window). The fuzzy window picker shows the same icons.

- **Claude Code**: `./install.sh claude bin`, then merge `extras/claude/settings-hooks.json` into
  `~/.claude/settings.json`. The same hooks also let tmux-resurrect resume each pane's own conversation after a restore.
- **opencode**: `./install.sh opencode bin` (a plugin in `~/.config/opencode/plugins/`).

## Desktop (GNOME)

Made for Ubuntu 24.04 with GNOME 46. Everything follows one light/dark switch: the Quick Settings "Dark Style"
button, or <kbd>Super</kbd>+<kbd>Shift</kbd>+<kbd>D</kbd>.

| Part | What you get |
|---|---|
| **Theme** | [Colloid](https://github.com/vinceliuice/Colloid-gtk-theme) Light/Dark Nord for GTK 3, GTK 4/libadwaita and the shell; Colloid Nord icons and cursors; Maple Mono NF as the system font |
| **nord-mode** | Switches the theme, icons, cursor, dock, launcher colors, GNOME Terminal and (through `nord-term`) the whole terminal side. Runs as a user service that follows GNOME's setting |
| **Extensions** | Blur my Shell (blurred top bar; the dock is plainly see-through), Just Perfection (quieter overview), Search Light (<kbd>Super</kbd>+<kbd>Space</kbd>), Space Bar, Vitals, Clipboard Indicator (<kbd>Super</kbd>+<kbd>Shift</kbd>+<kbd>V</kbd>), User Themes |
| **Nord Focus** | This repo's own extension: <kbd>Super</kbd>+<kbd>Shift</kbd>+<kbd>F</kbd> covers every monitor except the one you're on with a clock splash (or dims them) and mutes notifications. `nord-focus dim`, `splash`, `status` |
| **Wallpapers** | ~100 Nord wallpapers from [nordic-wallpapers](https://github.com/linuxdotexe/nordic-wallpapers), rotating hourly as light/dark pairs with no repeats (<kbd>Super</kbd>+<kbd>Shift</kbd>+<kbd>W</kbd> for the next pair). Edit `~/.config/nord-wallpaper/*.txt` to choose |
| **See-through apps** | `window-opacity` makes chosen apps translucent (Signal and the Claude app by default; rules in `~/.config/window-opacity.conf`) |
| **Firefox** | Nord browser chrome that follows light/dark, vertical tabs, Maple Mono for web pages, and a Nord start page with a clock, search box and shortcut tiles |
| **Icons** | Nord icons for apps whose launchers hard-code their own icon (snap Firefox and Ghostty, the Claude app) |
| **VS Code** | `desktop/vscode/settings.json`: Nord / Nord Light following the system, Maple Mono |
| **Signal** (sudo, optional) | Recolors Signal Desktop to Nord and re-applies it after every Signal update |
| **System** (sudo, optional) | zsh as login shell, a Nord boot splash (Plymouth) and a Nord login screen |

```sh
desktop/install.sh --dry-run      # see what would change
desktop/install.sh                # everything; or pick parts, e.g. desktop/install.sh themes settings
```

Parts: `themes extensions settings scripts wallpapers firefox fonts icons`. (Xournal++ is a part of the
terminal installer: `./install.sh xournalpp`.) The theme parts are cloned
from GitHub and installed with their own installers. Extensions come from extensions.gnome.org, and GNOME asks you
to confirm each one. Log out and back in afterwards so GNOME loads them.

The sudo extras are separate:

```sh
sudo bash desktop/system/install-system.sh           # login shell, boot splash, login screen
(cd desktop/signal && npm install) && sudo bash desktop/signal/install.sh   # Signal colors
```

Edit your start page shortcuts in `desktop/firefox/startpage/index.html`. To show it on new tabs, install the
[New Tab Override](https://addons.mozilla.org/firefox/addon/new-tab-override/) add-on with Custom URL
`http://127.0.0.1:8473/` and "Set focus to the web page" ticked. The installer runs a small local-only web server
for it, because Firefox add-ons can't open local files.

## Uninstall

Remove the symlinks the installers made and rename the `*.pre-nord-terminal.*` and `*.pre-nord-desktop.*`
backups back.

## Credits

[Nord](https://www.nordtheme.com/) by Arctic Ice Studio and Sven Greb, including
[nord-dircolors](https://github.com/nordtheme/dircolors) (MIT, `zsh/dircolors`). btop Nord theme by Justin Zobel.
Neovim config built on the [NvChad starter](https://github.com/NvChad/starter). Colloid GTK and icon themes by
[vinceliuice](https://github.com/vinceliuice). Wallpapers from
[nordic-wallpapers](https://github.com/linuxdotexe/nordic-wallpapers) (MIT).
Xournal++ toolbars adapted from [xournalpp-nord](https://github.com/juansegaes/xournalpp-nord) (GPL-3.0).
