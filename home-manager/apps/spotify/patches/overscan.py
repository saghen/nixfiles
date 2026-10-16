"""Render fewer off-screen tracklist rows.

Both tracklist virtualizers render 20 rows (~1100px) beyond each edge of the viewport, so opening a
playlist renders about twice the rows that are visible, all inside the click's task. This lowers the
overscan: filtering/sorting Liked Songs re-renders ~30% less, and fast flings still never show
unrendered rows (rows outside the rendered range show the tracklist placeholder pattern anyway).

usage: overscan.py xpui-modules.js [OVERSCAN] [--switch]   (--switch: window.__ovs overrides, for A/B)
"""
import re
import sys

path = sys.argv[1]
args = [a for a in sys.argv[2:] if not a.startswith("--")]
n = args[0] if args else "6"
val = f"window.__ovs??{n}" if "--switch" in sys.argv else n
src = open(path, encoding="utf-8").read()
src, k = re.subn(r'nrRowsOverscan:20([,}])', lambda m: f'nrRowsOverscan:{val}' + m.group(1), src)
if k != 2:
    print(f"overscan: WARNING expected 2 tracklist virtualizers, patched {k}", file=sys.stderr)
open(path, "w", encoding="utf-8").write(src)
print(f"overscan: patched {k} (overscan {n})")
