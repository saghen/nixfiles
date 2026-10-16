"""Make the entity-header title auto-fit cheap.

Spotify picks the largest font size from e.g. ["6rem","4.5rem","3rem","2rem"] at which the page
title fits on one line. For every candidate size it sets the size, measures the height with
`white-space: normal`, then again with `nowrap`: two forced document layouts per size, up to 8 per
fit, rerun on every header resize (sidebar/queue toggles) and every playlist/album/artist visit.

Instead: measure the nowrap width once at the first size, estimate each size by linear scaling
(all sizes are rem), and verify the pick with one more measurement (stepping down if the estimate
was off). Same result, usually 2 forced layouts.

usage: title-fit.py xpui-modules.js
"""
import re
import sys

path = sys.argv[1]
src = open(path, encoding="utf-8").read()

pat = re.compile(
    r'for\(let (?P<t>[\w$]+)=0;(?P=t)<(?P<i>[\w$]+)\.fontSizes\.length;(?P=t)\+\+\)\{'
    r'let (?P<r>[\w$]+)=(?P=i)\.fontSizes\[(?P=t)\];'
    r'(?P<s>[\w$]+)\.current\.style\.fontSize=(?P=r),(?P=s)\.current\.style\.whiteSpace="normal",(?P=s)\.current\.style\.textWrap="balance";'
    r'let (?P<n>[\w$]+)=(?P=s)\.current\.getBoundingClientRect\(\)\.height;'
    r'(?P=s)\.current\.style\.whiteSpace="nowrap";'
    r'let (?P<a>[\w$]+)=(?P=s)\.current\.getBoundingClientRect\(\)\.height;'
    r'if\((?P<e>[\w$]+)=(?P=t)===(?P=i)\.fontSizes\.length-1,(?P=n)===(?P=a)\)break\}'
)
matches = list(pat.finditer(src))
if len(matches) != 1:
    print(f"title-fit: WARNING expected 1 title fit loop, found {len(matches)}; not patching", file=sys.stderr)
    sys.exit(0)
m = matches[0]
g = m.groupdict()
S, I, E = g["s"], g["i"], g["e"]
repl = (
    f'{{let $el={S}.current,$fs={I}.fontSizes,$n=$fs.length;'
    f'$el.style.textWrap="balance";$el.style.whiteSpace="nowrap";$el.style.fontSize=$fs[0];'
    f'let $w=$el.scrollWidth,$cw=$el.clientWidth,$b=parseFloat($fs[0]),$k=$n-1;'
    f'for(let $t=0;$t<$n;$t++)if($w*parseFloat($fs[$t])/$b<=$cw+.5){{$k=$t;break}}'
    f'for(;$k<$n-1;$k++){{$el.style.fontSize=$fs[$k];if($el.scrollWidth<=$el.clientWidth)break}}'
    f'$el.style.fontSize=$fs[$k];{E}=$k===$n-1}}'
)
src = src[: m.start()] + repl + src[m.end():]
open(path, "w", encoding="utf-8").write(src)
print(f"title-fit: patched ({m.end() - m.start()} -> {len(repl)} bytes)")
