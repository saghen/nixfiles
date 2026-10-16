"""Check entity header metadata visibility in the next animation frame instead of mid-commit.

The entity header (playlist/album/artist pages) runs a dependency-less layout effect on every render
that calls checkVisibility() on each metadata child. That forces a style recalc in the middle of the
commit, which the frame then has to redo after the remaining DOM work (~29ms per queue toggle, since
toggling the queue re-renders the header). Deferring the check to requestAnimationFrame runs it once
the commit is done, just before the frame's own style pass, so the recalc is shared; the attribute
still lands before that frame paints.

usage: header-visibility-raf.py XPUI_DIR [--switch]   (--switch: window.__hvSync restores, for A/B)
"""
import os
import re
import sys

xpui = sys.argv[1]
SWITCH = "--switch" in sys.argv
pat = re.compile(r'\(0,([\w$]+)\.useLayoutEffect\)\(\(\)=>\{(let ([\w$]+)=([\w$]+)\.current;if\(!\3\|\|!\("checkVisibility"in HTMLElement\.prototype\)\)return;.{0,300}?\.toggleAttribute\("data-invisible",![\w$]+\))\}\)')
total = 0
for f in sorted(os.listdir(xpui)):
    if not f.endswith(".js"):
        continue
    p = os.path.join(xpui, f)
    s = open(p, encoding="utf-8").read()
    def repl(m):
        body = m.group(2)
        deferred = f'let $id=requestAnimationFrame(()=>{{{body}}});return()=>cancelAnimationFrame($id)'
        if SWITCH:
            deferred = f'if(window.__hvSync){{{body};return}}' + deferred
        return f'(0,{m.group(1)}.useLayoutEffect)(()=>{{{deferred}}})'
    s2, n = pat.subn(repl, s)
    if n:
        os.chmod(p, 0o644)
        open(p, "w", encoding="utf-8").write(s2)
        print(f"header-visibility-raf: patched {f} ({n})")
        total += n
if not total:
    print("header-visibility-raf: WARNING no match; not patching", file=sys.stderr)
