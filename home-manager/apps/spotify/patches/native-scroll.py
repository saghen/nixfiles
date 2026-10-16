"""Replace Spotify's OverlayScrollbars wrapper component with a native scroller.

Spotify wraps every main scroll area (main view, library, right sidebar, queue, NPV...) in an
OverlayScrollbars instance. Each instance observes resizes/mutations of its content and, on every
update, interleaves style writes with layout reads (offset/client/scroll sizes, computed styles,
scroll positions), forcing synchronous style+layout of the whole document several times per
frame. This keeps the same DOM shape (host[data-overlayscrollbars~=host] > viewport) so Spotify's
CSS keeps applying, but the viewport is a plain `overflow: auto` element with no JS involvement.

usage: native-scroll.py xpui-modules.js
"""
import re
import sys

path = sys.argv[1]
src = open(path, encoding="utf-8").read()

# let tX=(0,s.memo)(function({className:e,children:t,options:i,style:r,onInstanceCreated:n,tabIndex:a}){...
#   ...(0,o.jsx)("div",{"data-overlayscrollbars-initialize":!0,style:r,ref:u,className:c()(e,"main-actionBar-ActionBarContainer"),tabIndex:a,children:t})})
pat = re.compile(
    r'(?P<name>[\w$]+)=\(0,(?P<react>[\w$]+)\.memo\)\(function\(\{className:(?P<cls>[\w$]+),children:(?P<ch>[\w$]+),'
    r'options:(?P<opt>[\w$]+),style:(?P<sty>[\w$]+),onInstanceCreated:(?P<cb>[\w$]+),tabIndex:(?P<tab>[\w$]+)\}\)\{'
    r'(?:(?!\}\)\}\),).)*?'
    r'\(0,(?P<jsx>[\w$]+)\.jsx\)\("div",\{"data-overlayscrollbars-initialize":!0,style:[\w$]+,ref:[\w$]+,'
    r'className:(?P<cn>[\w$]+)\(\)\([\w$]+,"main-actionBar-ActionBarContainer"\),tabIndex:[\w$]+,children:[\w$]+\}\)\}\)',
    re.S,
)
matches = list(pat.finditer(src))
if len(matches) != 1:
    print(f"native-scroll: WARNING expected 1 OverlayScrollbars wrapper, found {len(matches)}; not patching", file=sys.stderr)
    sys.exit(0)
m = matches[0]
g = m.groupdict()
R, J, C = g["react"], g["jsx"], g["cn"]
repl = (
    f'{g["name"]}=(0,{R}.memo)(function({{className:e,children:t,options:i,style:r,onInstanceCreated:n,tabIndex:a}}){{'
    f'let $u=(0,{R}.useRef)(null);'
    f'(0,{R}.useLayoutEffect)(()=>{{let $v=$u.current;$v&&n&&n({{elements:()=>({{target:$v.parentElement,host:$v.parentElement,viewport:$v,content:$v}})}})}},[]);'
    f'let $ov=d=>"hidden"===d||"visible"===d?d:"auto",$oo=i&&i.overflow||{{}};'
    f'return(0,{J}.jsx)("div",{{"data-overlayscrollbars":"host",style:r,className:{C}()(e,"main-actionBar-ActionBarContainer"),'
    f'children:(0,{J}.jsx)("div",{{"data-overlayscrollbars-viewport":"native overflowXHidden overflowYScroll",'
    f'"data-native-scroll":"",ref:$u,tabIndex:a,style:{{overflowX:$ov($oo.x),overflowY:$ov($oo.y)}},children:t}})}})}})'
)
src = src[: m.start()] + repl + src[m.end():]
open(path, "w", encoding="utf-8").write(src)
print(f"native-scroll: patched {g['name']} ({m.end() - m.start()} -> {len(repl)} bytes)")
