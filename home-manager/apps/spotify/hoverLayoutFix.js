// hoverLayoutFix: don't animate layout properties that change on hover.
//
// Some cards transition layout properties on hover (e.g. the Home video cards' footer animates
// `height` for 0.4s). Scrolling moves cards under a stationary pointer, so every card passing by
// starts such a transition, and each animation frame relayouts the page (45-80ms per frame on
// Home, which made scrolling there spend ~5s in layout for 1.3s of wheel input).
//
// For every rule that transitions a layout property which some :hover/:focus-visible rule also
// sets on the same element (matched by the last class of the selectors), the property is swapped
// in `transition-property` for an inert custom property, keeping the other transition lists
// aligned. The value then changes instantly; non-layout transitions (opacity, colors) still run.
//
// Stylesheets are scanned once each as they load (route chunks add theirs on first visit); rules
// from earlier sheets are only re-checked when a new sheet adds hover rules for their classes.
(function hoverLayoutFix() {
  const LAYOUT = /^(height|width|max-height|max-width|min-height|min-width|padding(-.*)?|margin(-.*)?|top|left|right|bottom|inset(-.*)?|flex(-.*)?|grid-template-(rows|columns)|gap|row-gap|column-gap)$/;
  const HOVER = /:(hover|focus-visible|focus-within)\b/;
  const scanned = new WeakSet();
  const ours = new WeakSet();
  const hovered = new Map(); // class -> layout props set under hover
  const byClass = new Map(); // class -> transition rules targeting it
  const stats = { sheets: 0, rules: 0 };

  // last class in each selector of a selector list
  const subjects = (sel) =>
    sel.split(",").map((s) => {
      const m = s.trim().match(/\.([\w-]+)[^\s>+~.]*$/);
      return m && m[1];
    }).filter(Boolean);

  function eachRule(rules, fn) {
    for (let i = 0; i < rules.length; i++) {
      const r = rules[i];
      if (r.cssRules && !r.style) eachRule(r.cssRules, fn);
      else if (r.style && r.selectorText) fn(r);
    }
  }

  function fix(t) {
    if (t.fixed) return;
    const hp = new Set(t.classes.flatMap((c) => [...(hovered.get(c) || [])]));
    if (!hp.size) return;
    const props = t.rule.style.getPropertyValue("transition-property").split(",").map((p) => p.trim());
    // shorthand-ish matches: `padding` covers `padding-*` etc.
    const hit = (p) => LAYOUT.test(p) && [...hp].some((h) => h === p || h.startsWith(p + "-") || p.startsWith(h + "-"));
    if (!props.some(hit)) return;
    t.fixed = true;
    const next = props.map((p) => (hit(p) ? "--x-no-layout-transition" : p)).join(", ");
    const parent = t.rule.parentRule || t.rule.parentStyleSheet;
    const idx = [...parent.cssRules].indexOf(t.rule);
    try {
      parent.insertRule(`${t.rule.selectorText} { transition-property: ${next} !important; }`, idx + 1);
      ours.add(parent.cssRules[idx + 1]);
      stats.rules++;
    } catch (e) {
      console.warn("[hoverLayoutFix] insert failed", t.rule.selectorText, e);
    }
  }

  function scanSheet(sheet) {
    let rules;
    try { rules = sheet.cssRules; } catch { return; }
    scanned.add(sheet);
    stats.sheets++;
    const fresh = [], newHover = new Set();
    eachRule(rules, (r) => {
      if (ours.has(r)) return;
      if (HOVER.test(r.selectorText)) {
        for (const sel of r.selectorText.split(",")) {
          if (!HOVER.test(sel)) continue;
          for (const cls of subjects(sel)) {
            let set = hovered.get(cls);
            for (let i = 0; i < r.style.length; i++) {
              if (!LAYOUT.test(r.style[i])) continue;
              if (!set) hovered.set(cls, (set = new Set()));
              if (!set.has(r.style[i])) { set.add(r.style[i]); newHover.add(cls); }
            }
          }
        }
      }
      if (r.style.getPropertyValue("transition-property")) {
        const t = { rule: r, classes: subjects(r.selectorText), fixed: false };
        for (const c of t.classes) (byClass.get(c) || byClass.set(c, []).get(c)).push(t);
        fresh.push(t);
      }
    });
    for (const t of fresh) fix(t);
    for (const c of newHover) for (const t of byClass.get(c) || []) fix(t);
  }

  function scan() {
    for (const s of document.styleSheets) if (!scanned.has(s)) scanSheet(s);
  }

  scan();
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
  window.__hoverLayoutFix = { stats, scan };
})();
