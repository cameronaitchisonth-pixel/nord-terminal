#!/usr/bin/env python3
"""Recolor Signal Desktop's stylesheets to the Nord palette.

Signal reuses the same gray values in light and dark mode (a light-mode background
is a dark-mode text color), so each gray maps to the Nord shade at the same position
on the scale; that keeps both modes readable. Contact/avatar colors are left alone.

Usage: nord-palette.py <extracted-app-dir>
"""
import pathlib
import re
import sys

MARKER = "/* nord-signal-patched */"

MAP = {
    # Grays, lightest to darkest -> Snow Storm ... Polar Night
    "#ffffff": "#ECEFF4", "#fff": "#ECEFF4",
    "#fafafa": "#E9EDF3", "#f6f6f6": "#E5E9F0", "#f5f5f5": "#E5E9F0",
    "#f0f1f6": "#E5E9F0", "#eeefef": "#E5E9F0", "#f0f0f0": "#DFE4EC",
    "#ebebeb": "#E5E9F0", "#e9e9e9": "#D8DEE9", "#e6e6e6": "#DDE2EA",
    "#e1e1e1": "#DDE2EA", "#dedede": "#CDD4E0", "#dcdcdc": "#D8DEE9",
    "#d7d7d9": "#D0D7E2", "#d2d2d2": "#C9D0DC", "#c6c6c6": "#B8C1D0",
    "#b9b9b9": "#A9B3C4", "#848484": "#7B88A1", "#737373": "#7B88A1",
    "#5e5e5e": "#616E88", "#5c5c5c": "#616E88", "#545454": "#56617A",
    "#4b4b4b": "#4C566A", "#4a4a4a": "#4C566A",
    # Dark surfaces sit on Nord's four Polar Night levels; nothing goes darker than
    # #2E3440, since Signal's pure-black and near-black backgrounds otherwise read as black.
    "#414141": "#434C5E", "#3c3c3c": "#434C5E", "#3b3b3b": "#434C5E",
    "#373737": "#434C5E", "#343434": "#434C5E", "#323232": "#434C5E",
    "#2e2e2e": "#3B4252", "#2d2d2d": "#3B4252", "#282828": "#3B4252",
    "#262626": "#3B4252", "#232323": "#3B4252",
    "#1e1e1e": "#353C4A", "#1b1b1b": "#353C4A",
    "#191919": "#2E3440", "#121212": "#2E3440",
    "#000000": "#2E3440", "#000": "#2E3440",
    # Focus rings / borders
    "#67697e": "#616E88", "#808190": "#7B88A1", "#e4e5f0": "#D8DEE9", "#c9cbda": "#B8C1D0",
    # Accent: Signal blue/indigo -> Nord frost
    "#2c6bed": "#5E81AC", "#6191f3": "#81A1C1", "#0552f0": "#4C6F9A",
    "#1f31ff": "#5E81AC", "#4655ff": "#5E81AC", "#2536f9": "#81A1C1", "#5563ff": "#81A1C1",
    "#0519ff": "#4C6F9A", "#3b4af4": "#4C6F9A", "#2e3ffa": "#88C0D0", "#616eff": "#88C0D0",
    "#b2b9ff": "#B7C8DC", "#a8b0ff": "#A9BDD5",
    # Status
    "#f44336": "#BF616A", "#f65560": "#D0737C",
}

HEX = re.compile(r"#(?:[0-9a-fA-F]{6}|[0-9a-fA-F]{3})\b")


def recolor(css: str) -> tuple[str, int]:
    count = 0

    def sub(m):
        nonlocal count
        new = MAP.get(m.group(0).lower())
        if new is None:
            return m.group(0)
        count += 1
        return new

    return HEX.sub(sub, css), count


def main(app_dir: str) -> None:
    sheets = pathlib.Path(app_dir, "stylesheets")
    total = 0
    for name in ("manifest.css", "manifest_bridge.css", "tailwind.css"):
        path = sheets / name
        if not path.exists():
            continue
        css = path.read_text()
        if MARKER in css:
            print(f"{name}: already patched")
            continue
        css, n = recolor(css)
        path.write_text(f"{MARKER}\n{css}")
        total += n
        print(f"{name}: {n} colors remapped")
    if total == 0:
        sys.exit("nothing remapped: Signal's stylesheets may have changed")


if __name__ == "__main__":
    main(sys.argv[1])
