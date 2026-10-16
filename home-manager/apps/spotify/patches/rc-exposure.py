"""Notify remote-config access listeners once per flag per configuration, not on every read.

Every feature-flag read calls the exposure access listeners (analytics: "this experiment flag was
seen"), which reset a debounce timer, compute a group id, log and register a FinalizationRegistry
entry - on every read. Track rows read several flags each, so opening a playlist spends several ms
in setTimeout/clearTimeout alone. The listener already reports each group id once, so calling it only
on the first read of each flag per configuration object sends the same exposure events.

usage: rc-exposure.py XPUI_DIR [--switch]   (--switch: window.__rcAll restores per-read calls, for A/B)
"""
import os
import re
import sys

xpui = sys.argv[1]
SWITCH = "--switch" in sys.argv
pat = re.compile(r'getValue\(([\w$]+)\)\{let ([\w$]+)=([\w$]+)\(\1\);if\("#"!==\1\[0\]\)for\(let ([\w$]+) of this\.accessListeners\)')
FIRST = '(window.__rcFirst||(window.__rcFirst=(()=>{const m=new WeakMap;return(c,k)=>{let s=m.get(c);if(!s)m.set(c,s=new Set);return!s.has(k)&&!!s.add(k)}})()))'
total = 0
for f in sorted(os.listdir(xpui)):
    if not f.endswith(".js"):
        continue
    p = os.path.join(xpui, f)
    s = open(p, encoding="utf-8").read()
    s2, n = pat.subn(lambda m: f'getValue({m.group(1)}){{let {m.group(2)}={m.group(3)}({m.group(1)});if("#"!=={m.group(1)}[0]&&{"(window.__rcAll||" if SWITCH else "("}{FIRST}(this,{m.group(1)})))for(let {m.group(4)} of this.accessListeners)', s)
    if n:
        os.chmod(p, 0o644)
        open(p, "w", encoding="utf-8").write(s2)
        print(f"rc-exposure: patched {f} ({n})")
        total += n
if not total:
    print("rc-exposure: WARNING no match; not patching", file=sys.stderr)
