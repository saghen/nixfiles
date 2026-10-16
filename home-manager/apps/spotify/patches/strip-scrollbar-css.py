"""Drop ::-webkit-scrollbar selectors from a theme's CSS so Chromium's native overlay scrollbars apply.

Any matching ::-webkit-scrollbar rule turns an element's scrollbar into a classic custom scrollbar
that takes layout space; with the native-scroll patch that would narrow every scroll area by the
scrollbar width compared to OverlayScrollbars. Selectors are removed from selector lists; rules
left with no selectors are dropped.

usage: strip-scrollbar-css.py user.css
"""
import re
import sys

path = sys.argv[1]
src = open(path, encoding="utf-8").read()
removed = 0


def strip(m):
    global removed
    sels = [s for s in m.group(1).split(",")]
    keep = [s for s in sels if "::-webkit-scrollbar" not in s]
    removed += len(sels) - len(keep)
    if not keep:
        return ""
    return "\n" + ",".join(keep).strip() + " {" + m.group(2) + "}"


# flat rules only (theme CSS); nested @media blocks are matched rule by rule inside them
src = re.sub(r"([^{}@/][^{}]*?)\{([^{}]*)\}", lambda m: strip(m) if "::-webkit-scrollbar" in m.group(1) else m.group(0), src)
open(path, "w", encoding="utf-8").write(src)
print(f"strip-scrollbar-css: removed {removed} selectors")
