# nord-terminal

A [Nord](https://www.nordtheme.com/) terminal setup: Ghostty, tmux, Neovim (NvChad) and zsh with Starship,
plus matching themes for bat, delta, lazygit, yazi and btop. Everything switches between Nord light and Nord dark
together.

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

Parts: `ghostty tmux nvim zsh starship bat btop lazygit yazi delta bin claude opencode`.

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

## Uninstall

Remove the symlinks the installer made and rename the `*.pre-nord-terminal.*` backups back.

## Credits

[Nord](https://www.nordtheme.com/) by Arctic Ice Studio and Sven Greb, including
[nord-dircolors](https://github.com/nordtheme/dircolors) (MIT, `zsh/dircolors`). btop Nord theme by Justin Zobel.
Neovim config built on the [NvChad starter](https://github.com/NvChad/starter).
