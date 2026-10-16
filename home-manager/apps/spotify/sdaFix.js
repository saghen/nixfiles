// sdaFix: stop scroll-driven animations from ticking the compositor forever.
//
// Chromium runs scroll-driven (animation-timeline: scroll()/view()/--named) animations of
// compositor-friendly properties (opacity, transform, translate, scale, rotate) on the compositor
// thread, and the cc AnimationHost then ticks every vsync for as long as they exist - even when
// nothing scrolls, the app is paused, or the window sits on a hidden workspace. Spotify has
// hundreds of these (home carousels' edge fades/chevrons, NPV, lyrics, cinema mode).
//
// The same animation driven through a registered custom property is resolved on the main thread
// only when the scroll offset changes, so: for each such @keyframes K we emit `sda-K` that animates
// `--sda-K-<prop>` instead, and right after every rule using K on a scroll timeline we insert the
// same selector with `animation-name` rewritten and `<prop>: var(--sda-K-<prop>) !important`.
// Rules are inserted next to the originals (same sheet, same @media/@supports), so cascade
// order and conditions are preserved.
(function sdaFix() {
  const TYPES = {
    opacity: { syntax: "<number>", initial: "1" },
    transform: { syntax: "<transform-list>", initial: "scale(1)" },
    translate: { syntax: "<length-percentage>+", initial: "0px" },
    scale: { syntax: "<number>+", initial: "1" },
    rotate: { syntax: "<angle>", initial: "0deg" },
  };
  const done = new WeakSet();
  const registered = new Set();
  const stats = { sheets: 0, keyframes: 0, rules: 0 };

  const isScrollTimeline = (tl) =>
    tl && tl.split(",").some((t) => (t = t.trim()) && t !== "auto" && t !== "none");

  function keyframesIn(rules, out) {
    for (const r of rules) {
      if (r.type === CSSRule.KEYFRAMES_RULE) out.set(r.name, r);
      else if (r.cssRules) keyframesIn(r.cssRules, out);
    }
    return out;
  }

  function register(name, type, from) {
    if (registered.has(name)) return;
    registered.add(name);
    try {
      CSS.registerProperty({ name, syntax: type.syntax, inherits: false, initialValue: from ?? type.initial });
    } catch {
      try {
        CSS.registerProperty({ name, syntax: type.syntax, inherits: false, initialValue: type.initial });
      } catch {}
    }
  }

  // Build `sda-K` in `sheet` from keyframes rule `kf`; returns remapped props or null.
  const converted = new Map();
  function convert(sheet, kf) {
    if (converted.has(kf.name)) return converted.get(kf.name);
    const props = new Set();
    for (const k of kf.cssRules) for (let i = 0; i < k.style.length; i++) if (TYPES[k.style[i]]) props.add(k.style[i]);
    if (!props.size) return converted.set(kf.name, null), null;
    const frames = [];
    for (const k of kf.cssRules) {
      const decls = [];
      for (let i = 0; i < k.style.length; i++) {
        const p = k.style[i];
        const v = k.style.getPropertyValue(p);
        decls.push(TYPES[p] ? `--sda-${kf.name}-${p}: ${v}` : `${p}: ${v}`);
      }
      frames.push(`${k.keyText} { ${decls.join("; ")} }`);
    }
    for (const p of props) {
      const first = [...kf.cssRules].find((k) => k.style.getPropertyValue(p));
      register(`--sda-${kf.name}-${p}`, TYPES[p], first && first.style.getPropertyValue(p).trim());
    }
    sheet.insertRule(`@keyframes sda-${kf.name} { ${frames.join(" ")} }`, sheet.cssRules.length);
    stats.keyframes++;
    const res = [...props];
    converted.set(kf.name, res);
    return res;
  }

  function patchRules(sheet, rules, kfs) {
    for (let i = 0; i < rules.length; i++) {
      const r = rules[i];
      if (r.cssRules && r.type !== CSSRule.KEYFRAMES_RULE) patchRules(sheet, r.cssRules, kfs);
      if (!r.style || !r.selectorText || done.has(r)) continue;
      const names = r.style.getPropertyValue("animation-name");
      if (!names || !isScrollTimeline(r.style.getPropertyValue("animation-timeline"))) continue;
      done.add(r);
      const decls = [];
      const newNames = names.split(",").map((n) => {
        n = n.trim();
        const kf = kfs.get(n) || globalKeyframes().get(n);
        const props = kf && convert(sheet, kf);
        if (!props) return n;
        for (const p of props) decls.push(`${p}: var(--sda-${n}-${p}) !important`);
        return `sda-${n}`;
      });
      if (!decls.length) continue;
      const parent = r.parentRule || sheet;
      try {
        parent.insertRule(`${r.selectorText} { animation-name: ${newNames.join(", ")}; ${decls.join("; ")} }`, i + 1);
        done.add(parent.cssRules[i + 1]);
        i++;
        stats.rules++;
      } catch (e) {
        console.warn("[sdaFix] insert failed", r.selectorText, e);
      }
    }
  }

  let gkf = null;
  function globalKeyframes() {
    if (gkf) return gkf;
    gkf = new Map();
    for (const s of document.styleSheets) {
      try { keyframesIn(s.cssRules, gkf); } catch {}
    }
    return gkf;
  }

  function scan() {
    gkf = null;
    for (const s of document.styleSheets) {
      if (done.has(s)) continue;
      let rules;
      try { rules = s.cssRules; } catch { continue; }
      done.add(s);
      stats.sheets++;
      patchRules(s, rules, keyframesIn(rules, new Map()));
    }
  }

  scan();
  // Spotify lazy-loads per-feature CSS chunks; catch them as they arrive.
  let pending = false;
  const later = () => {
    if (pending) return;
    pending = true;
    setTimeout(() => { pending = false; scan(); }, 0);
  };
  new MutationObserver((ms) => {
    for (const m of ms)
      for (const n of m.addedNodes)
        if (n.nodeName === "STYLE") later();
        else if (n.nodeName === "LINK") n.addEventListener("load", later, { once: true });
  }).observe(document.head, { childList: true });
  window.__sdaFix = { stats, scan };
})();
