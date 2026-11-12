// Icon library for the fight screen (design/art/art-bible.md §7-8).
// Art icons: dark tile, one element hue as a radial glow, one subject with a near-white core and a hue rim, a family
// motif, a role mark, a fixed frame. Drawn in a 64-unit space and placed on a 256-unit master (tf scale 4).
// make_icons.py appends the recipes (one per art) and the ward and chip calls, then renders with vex.

const K = "#0b0d10", K2 = "#16191f", FR = "#1e2227", CORE = "#f4f1e8"
const HUE = { fire: "#e8442a", water: "#3f6fe0", wood: "#2fbf8a", metal: "#e3b341", earth: "#b9772e", ice: "#7ad7f0",
  thunder: "#a15cff", wind: "#a6ebd8", phys: "#c9c2b2", force: "#e58fb5", chaos: "#e0409a", soul: "#cfc4ff",
  buff: "#5bd66b", debuff: "#e5384f" }

// colour math
const hx = (h) => [1, 3, 5].map(i => parseInt(h.slice(i, i + 2), 16))
const toh = (c) => "#" + c.map(v => Math.max(0, Math.min(255, Math.round(v))).toString(16).padStart(2, "0")).join("")
const mix = (a, b, t) => { const x = hx(a), y = hx(b); return toh(x.map((v, i) => v + (y[i] - v) * t)) }
const alpha = (h, a) => h + Math.round(a * 255).toString(16).padStart(2, "0")
// a hue's five tones: deep, dark, mid (the table hex), light, white-hot
const tones = (h) => ({ d: mix(h, K, 0.82), k: mix(h, K, 0.55), m: h, l: mix(h, "#ffffff", 0.45), w: mix(h, "#ffffff", 0.8), h })

// deterministic random
const rnd = (seed) => { let s = (seed * 9301 + 49297) % 233280 || 7; return () => (s = (s * 16807) % 2147483647) / 2147483647 }
const seedOf = (str) => { let h = 7; for (const ch of str) h = (h * 31 + ch.charCodeAt(0)) % 100000; return h + 1 }

// ---------------------------------------------------------------- tile parts
function ground(P, cx = 32, cy = 32, muted = false) {
  return [rect(0, 0, 64, 64, { fill: rad([P.d, K2, K], { cx: cx / 64, cy: cy / 64, r: 0.85 }), r: 3 }),
    circle(cx, cy, 25, { fill: P.m, opacity: muted ? 0.28 : 0.45, blur: 10 }),
    circle(cx, cy, 13, { fill: P.l, opacity: muted ? 0.1 : 0.2, blur: 8 })]
}
function vignette() { return rect(0, 0, 64, 64, { fill: rad(["#00000000", "#00000000", "#000000c8"], { cx: 0.5, cy: 0.5, r: 0.74 }), r: 3 }) }
function frameArt() {
  return [vignette(), rect(0.75, 0.75, 62.5, 62.5, { stroke: FR, sw: 1.5, r: 3 }),
    line([3, 2.3, 61, 2.3], { stroke: "#ffffff40", sw: 0.5 }),
    rect(0.25, 0.25, 63.5, 63.5, { stroke: "#e9e4d655", sw: 0.5, r: 3.2 })]
}
const CH = 7
const chamfer = (i) => [CH + i, i, 64 - CH - i, i, 64 - i, CH + i, 64 - i, 64 - CH - i, 64 - CH - i, 64 - i, CH + i, 64 - i, i, 64 - CH - i, i, CH + i]
function frameWard(P) {
  return [poly(chamfer(1), { stroke: FR, sw: 2 }), poly(chamfer(3.2), { stroke: P.l, sw: 0.6, opacity: 0.55 }),
    poly(chamfer(0.3), { stroke: "#e9e4d655", sw: 0.5 })]
}
function rays(cx, cy, n, len, c, seed, op = 0.2) {
  const r = rnd(seed)
  return Array.from({ length: n }, (_, i) => {
    const a = (i / n) * Math.PI * 2 + r() * 0.5, l = len * (0.55 + r() * 0.5), w = 0.05 + r() * 0.05
    return poly([cx, cy, cx + Math.cos(a - w) * l, cy + Math.sin(a - w) * l, cx + Math.cos(a + w) * l, cy + Math.sin(a + w) * l],
      { fill: c, opacity: op * (0.5 + r() * 0.6), blur: 1.1 })
  })
}
function sparks(n, box, c, seed, maxR = 1) {
  const r = rnd(seed), [x0, y0, x1, y1] = box
  return Array.from({ length: n }, () => circle(x0 + r() * (x1 - x0), y0 + r() * (y1 - y0), 0.35 + r() * maxR * 0.7,
    { fill: c, opacity: 0.55 + r() * 0.45, glow: { r: 1.4, color: c } }))
}
const wisp = (pts, c, sw, op = 1) => [curve(pts, { stroke: c, sw: sw * 2.4, opacity: op * 0.3, blur: 1.4 }), curve(pts, { stroke: c, sw, opacity: op })]
// a lit energy shape: soft bloom, then a hot gradient body
const lit = (shapeFn, P, ang = 90, op = 1) => [shapeFn({ fill: P.m, opacity: 0.55 * op, blur: 2.4 }), shapeFn({ fill: lin([P.w, P.l, P.m], ang), opacity: op })]
// a dark silhouette rim-lit in the hue
const dark = (d, P, rim = 0.9) => [path(d, { fill: lin([K2, K], 120) }), path(d, { stroke: P.l, sw: rim, opacity: 0.95, glow: { r: 1.4, color: P.m } })]

// ---------------------------------------------------------------- family motifs
const MOTIF = {
  fire: (P, s) => [...sparks(6, [30, 4, 60, 30], P.w, s), ...sparks(4, [6, 6, 30, 22], P.l, s + 1, 0.8)],
  water: (P, s) => [arc(32, 50, 16, 250, 470, { stroke: P.l, sw: 0.7, opacity: 0.45 }), arc(32, 50, 23, 255, 465, { stroke: P.l, sw: 0.5, opacity: 0.3 })],
  earth: (P, s) => { const r = rnd(s); return Array.from({ length: 5 }, () => { const x = 8 + r() * 48, y = 6 + r() * 16, z = 1 + r() * 1.6
    return poly([x, y, x + z, y + z * 0.6, x + z * 0.3, y + z * 1.6, x - z * 0.8, y + z], { fill: P.l, opacity: 0.75 }) }) },
  metal: (P, s) => { const r = rnd(s); return Array.from({ length: 3 }, () => { const x = 10 + r() * 44, y = 8 + r() * 46
    return [line([x - 3, y, x + 3, y], { stroke: P.w, sw: 0.5, opacity: 0.9 }), line([x, y - 3, x, y + 3], { stroke: P.w, sw: 0.5, opacity: 0.9 }), circle(x, y, 0.8, { fill: "#fff", glow: { r: 1.5, color: P.l } })] }) },
  wood: (P, s) => [...wisp([6, 50, 10, 42, 8, 36, 12, 32], P.l, 0.7, 0.55), ...wisp([58, 14, 54, 20, 57, 26, 53, 30], P.l, 0.6, 0.45), ...sparks(4, [8, 8, 56, 56], P.w, s, 0.6)],
  ice: (P, s) => { const r = rnd(s); return Array.from({ length: 4 }, () => { const x = 8 + r() * 48, y = 6 + r() * 50, z = 1.2 + r() * 1.4
    return poly([x, y - z * 1.6, x + z * 0.6, y, x, y + z * 1.6, x - z * 0.6, y], { fill: P.w, opacity: 0.8, glow: { r: 1, color: P.l } }) }) },
  thunder: (P, s) => [line([8, 10, 12, 15, 9, 17, 14, 23], { stroke: P.w, sw: 0.6, opacity: 0.8, glow: { r: 1.2, color: P.l } }),
    line([56, 40, 52, 45, 55, 47, 50, 53], { stroke: P.l, sw: 0.5, opacity: 0.7 }), ...sparks(3, [10, 8, 56, 56], P.w, s, 0.5)],
  wind: (P, s) => [...wisp([4, 22, 18, 18, 34, 20, 50, 16], P.l, 0.6, 0.5), ...wisp([10, 48, 26, 46, 40, 50, 60, 46], P.l, 0.5, 0.4)],
  blade: (P, s) => [arc(32, 34, 26, 200, 330, { stroke: P.w, sw: 0.9, opacity: 0.55, glow: { r: 1.5, color: P.l } })],
  body: (P, s) => rays(32, 34, 16, 30, P.l, s, 0.16),
  force: (P, s) => [circle(32, 34, 20, { stroke: P.l, sw: 0.6, opacity: 0.45 }), circle(32, 34, 26, { stroke: P.l, sw: 0.4, opacity: 0.28 })],
  chaos: (P, s) => [line([6, 20, 14, 26, 11, 31], { stroke: P.l, sw: 0.6, opacity: 0.6 }), line([58, 38, 50, 44, 54, 50], { stroke: P.l, sw: 0.6, opacity: 0.6 }), ...sparks(4, [8, 8, 56, 56], P.l, s, 0.6)],
  soul: (P, s) => [...wisp([6, 40, 14, 30, 10, 22, 18, 12], P.w, 0.6, 0.45), ...wisp([58, 48, 50, 40, 56, 30, 48, 22], P.w, 0.5, 0.35), ...sparks(3, [10, 10, 54, 54], P.w, s, 0.6)],
}

// ---------------------------------------------------------------- role marks (top-left, 7 units)
const ROLE = {
  damage: () => [],
  stacks: (P) => [0, 1, 2].map(i => rect(5 + i * 2.4, 5, 1.2, 5, { fill: CORE, opacity: 0.7, r: 0.4 })),
  curse: (P) => [curve([6, 5, 6, 9, 8.5, 10.5, 10.5, 8.5], { stroke: CORE, sw: 1, opacity: 0.75 })],
  heal: (P) => [rect(7, 4.5, 1.4, 6, { fill: CORE, opacity: 0.75 }), rect(4.7, 6.8, 6, 1.4, { fill: CORE, opacity: 0.75 })],
  ward: (P) => [arc(8, 9, 3.5, 270, 450, { stroke: CORE, sw: 1.1, opacity: 0.75 })],
  soul: (P) => [circle(8, 8, 1.5, { fill: CORE, opacity: 0.8 }), path("M8 4 Q10 6.5 8 6.5 Q6 6.5 8 4 Z", { fill: CORE, opacity: 0.7 })],
  utility: (P) => [poly([8, 4.5, 11, 7.5, 8, 10.5, 5, 7.5], { fill: CORE, opacity: 0.7 })],
  control: (P) => [ellipse(6.5, 7.5, 2, 1.3, { stroke: CORE, sw: 0.8, opacity: 0.75 }), ellipse(9.8, 7.5, 2, 1.3, { stroke: CORE, sw: 0.8, opacity: 0.75 })],
  summon: (P) => [circle(6.5, 7.5, 1.2, { fill: CORE, opacity: 0.75 }), circle(10, 7.5, 1.2, { fill: CORE, opacity: 0.75 })],
}

// ---------------------------------------------------------------- subjects (centre about 32,34; 40-46 units across)
const PALM_OPEN = "M14 60 L20 48 Q22 43 26 41 L26 28 Q26 24 29 24 Q31 24 31 28 L31 36 L32 22 Q32 18 35 18 Q38 18 37.5 22 L37 35 L39 24 Q40 20 43 21 Q45.5 22 44.5 26 L42.5 37 L45.5 30 Q47 27 49.5 28.5 Q51 30 50 33 L46 46 Q43 53 36 56 L30 64 Z"
const FIST = "M16 46 Q14 36 20 32 L34 26 Q40 23 46 26 L52 30 Q55 33 53 37 L52 44 Q51 50 45 52 L34 54 Q26 56 22 52 Z"
const S = {
  palm: (P) => [circle(40, 30, 9, { fill: P.l, opacity: 0.55, blur: 3 }), ...rays(40, 30, 10, 20, P.w, 3, 0.22), ...dark(PALM_OPEN, P),
    circle(39, 39, 4.5, { fill: rad(["#fff", P.w, P.l], {}), opacity: 0.95, glow: { r: 3, color: P.m, strength: 2 } })],
  fist: (P) => [...rays(46, 30, 12, 22, P.w, 5, 0.25), ...dark(FIST, P),
    ...[0, 1, 2, 3].map(i => path(`M${26 + i * 6.5} ${28 - i * 0.6} Q${28 + i * 6.5} ${33 - i * 0.6} ${26 + i * 6.5} ${38 - i * 0.6}`, { stroke: P.l, sw: 0.6, opacity: 0.6 })),
    star(53, 30, 8, 7, 2.6, { fill: P.w, glow: { r: 3, color: P.m, strength: 2 } })],
  sword: (P) => [...lit((st) => poly([12, 54, 46, 20, 56, 9, 44, 18, 10, 52], st), P, 45), line([11, 53, 55, 10], { stroke: "#fff", sw: 0.55, opacity: 0.9 }),
    poly([20, 51, 10, 41, 8, 43, 18, 53], { fill: lin([P.l, P.k], 45), stroke: P.w, sw: 0.4 }), poly([11, 53, 6, 58, 8, 60, 13, 55], { fill: P.k, stroke: P.l, sw: 0.4 }),
    circle(56, 9, 1.8, { fill: "#fff", glow: { r: 3, color: P.l, strength: 2 } })],
  saber: (P) => [...lit((st) => path("M14 54 Q20 30 50 10 Q40 30 18 56 Z", st), P, 30), curve([16, 53, 24, 34, 49, 11], { stroke: "#fff", sw: 0.5, opacity: 0.85 }),
    rect(10, 53, 9, 3, { fill: P.k, stroke: P.l, sw: 0.4, r: 1 }), ...wisp([24, 60, 40, 52, 54, 34, 58, 20], P.l, 0.9, 0.6)],
  spear: (P) => [line([8, 58, 46, 20], { stroke: P.k, sw: 2.6 }), line([8, 58, 46, 20], { stroke: P.l, sw: 0.6, opacity: 0.8 }),
    ...lit((st) => path("M44 22 Q47 13 58 6 Q51 17 42 20 Z", st), P, 45), circle(44, 21, 2, { fill: P.l, opacity: 0.9 }),
    ...wisp([14, 44, 20, 50, 26, 44, 32, 50, 38, 42], P.w, 0.7, 0.6)],
  bow: (P) => [path("M20 6 Q46 33 20 60 L17 58 Q40 33 17 8 Z", { fill: P.m, opacity: 0.5, blur: 2 }),
    path("M20 6 Q46 33 20 60 L17 58 Q40 33 17 8 Z", { fill: lin([P.w, P.l, P.k], 0), stroke: P.w, sw: 0.4 }),
    rect(28.5, 29, 4, 8, { fill: P.k, stroke: P.l, sw: 0.4, r: 1 }),
    line([18, 7, 10, 33, 18, 59], { stroke: P.w, sw: 0.7, opacity: 0.95 }),
    line([8, 33, 52, 33], { stroke: P.m, sw: 4, opacity: 0.45, blur: 1.5 }), line([10, 33, 52, 33], { stroke: "#fff", sw: 1.4 }),
    ...lit((st) => poly([60, 33, 49, 27.5, 52, 33, 49, 38.5], st), P, 0), poly([8, 33, 15, 29, 13, 33, 15, 37], { fill: P.l }),
    ...sparks(4, [50, 24, 62, 42], P.w, 22, 0.6)],
  needles: (P) => [...[0, 1, 2, 3, 4].map(i => { const o = i * 6 - 12; return [line([12 + o * 0.3, 44 + o, 52 + o * 0.3, 24 + o], { stroke: P.m, sw: 2, opacity: 0.35, blur: 1 }),
    line([14 + o * 0.3, 43 + o, 52 + o * 0.3, 24 + o], { stroke: lin([P.k, P.w], 0), sw: 0.9 }), circle(52 + o * 0.3, 24 + o, 0.9, { fill: "#fff", glow: { r: 1.5, color: P.l } })] })],
  seal: (P) => [circle(32, 33, 20, { fill: P.m, opacity: 0.25, blur: 3 }), circle(32, 33, 19, { stroke: P.w, sw: 1.6, glow: { r: 2, color: P.m } }), circle(32, 33, 15.5, { stroke: P.l, sw: 0.6 }),
    ...Array.from({ length: 24 }, (_, i) => { const a = i / 24 * Math.PI * 2; return line([32 + Math.cos(a) * 16, 33 + Math.sin(a) * 16, 32 + Math.cos(a) * (i % 3 ? 17.3 : 18.5), 33 + Math.sin(a) * (i % 3 ? 17.3 : 18.5)], { stroke: P.l, sw: 0.5 }) }),
    tf({ rot: 45, origin: [32, 33] }, rect(24, 25, 16, 16, { stroke: P.w, sw: 1.2 })), path("M27 29 L37 29 M32 26 L32 40 M27 35 Q32 31 37 35 M28 40 L36 40", { stroke: "#fff", sw: 1.3, glow: { r: 1.5, color: P.m } })],
  talisman: (P) => [tf({ rot: -12, origin: [32, 33] }, rect(22, 8, 20, 50, { fill: lin([P.w, "#e8dcc0", "#c9b48a"], 90), r: 1 }),
    rect(22, 8, 20, 50, { fill: P.m, opacity: 0.12, r: 1 }), path("M32 13 L32 50 M26 18 L38 18 M27 26 Q32 22 37 26 M26 34 L38 34 M28 42 L36 46 M36 42 L28 46", { stroke: P.k, sw: 1.4 }),
    path("M22 52 Q26 56 28 54 Q31 59 34 55 Q37 59 39 54 Q41 57 42 52 L42 58 L22 58 Z", { fill: P.m, opacity: 0.9, glow: { r: 2, color: P.l } })), ...sparks(5, [24, 54, 48, 62], P.w, 4, 0.7)],
  bell: (P) => [arc(32, 30, 22, 300, 420, { stroke: P.l, sw: 0.8, opacity: 0.5 }), arc(32, 30, 27, 305, 415, { stroke: P.l, sw: 0.6, opacity: 0.35 }),
    ...dark("M32 10 Q36 10 36 14 L36 16 Q46 18 47 32 L48 44 Q50 48 54 50 L10 50 Q14 48 16 44 L17 32 Q18 18 28 16 L28 14 Q28 10 32 10 Z", P),
    path("M20 38 Q32 34 44 38", { stroke: P.l, sw: 0.7, opacity: 0.8 }), circle(32, 54, 3.2, { fill: P.w, glow: { r: 3, color: P.m, strength: 2 } })],
  song: (P) => [...wisp([6, 44, 16, 34, 28, 40, 40, 30, 52, 34, 60, 24], P.w, 1.2, 0.85), ...wisp([6, 52, 18, 44, 30, 50, 42, 42, 58, 44], P.l, 0.9, 0.7),
    ...wisp([10, 34, 22, 26, 34, 30, 48, 20], P.l, 0.7, 0.55), ...[[22, 22], [40, 18], [48, 40]].map(([x, y]) => [tf({ rot: -20, origin: [x, y] }, ellipse(x, y, 2.4, 1.8, { fill: P.w, glow: { r: 1.5, color: P.m } })), line([x + 2, y, x + 2, y - 8], { stroke: P.w, sw: 0.7 })])],
  hammer: (P) => [line([12, 58, 36, 30], { stroke: P.k, sw: 3.4 }), line([12, 58, 36, 30], { stroke: P.l, sw: 0.6, opacity: 0.7 }),
    tf({ rot: 40, origin: [40, 24] }, ...lit((st) => rect(28, 15, 24, 15, { ...st, r: 2 }), P, 90), rect(28, 15, 24, 3, { fill: "#fff", opacity: 0.55, r: 1 })),
    ...rays(48, 16, 8, 16, P.w, 6, 0.25)],
  mountain: (P) => [...lit((st) => poly([4, 54, 18, 30, 24, 36, 34, 16, 44, 32, 50, 26, 60, 54], st), P, 90),
    poly([34, 16, 38, 24, 34, 22, 30, 26], { fill: "#fff", opacity: 0.9 }), poly([18, 30, 21, 35, 18, 34, 15, 37], { fill: "#fff", opacity: 0.7 }),
    path("M4 54 L60 54", { stroke: P.k, sw: 2 }), path("M20 54 Q30 44 34 30 M40 54 Q44 42 48 34", { stroke: P.k, sw: 0.7, opacity: 0.6 })],
  flame: (P) => [path("M32 6 Q42 18 40 26 Q46 22 45 15 Q54 28 50 42 Q46 56 32 58 Q18 56 14 44 Q11 32 20 24 Q20 32 25 34 Q20 18 32 6 Z", { fill: P.m, opacity: 0.6, blur: 2.5 }),
    path("M32 6 Q42 18 40 26 Q46 22 45 15 Q54 28 50 42 Q46 56 32 58 Q18 56 14 44 Q11 32 20 24 Q20 32 25 34 Q20 18 32 6 Z", { fill: lin([P.l, P.m, P.k], 90) }),
    path("M32 24 Q40 34 38 44 Q36 52 32 52 Q26 52 25 46 Q24 38 32 24 Z", { fill: lin(["#fff", P.w, P.l], 90), glow: { r: 2, color: P.l } })],
  wave: (P) => { const W = [4, 60, 8, 44, 16, 30, 28, 18, 42, 12, 54, 16, 60, 26, 54, 24, 46, 22, 40, 26, 42, 34, 48, 38, 38, 42, 26, 48, 18, 60]
    return [blob(W, { fill: lin([P.m, P.k, P.d], 110), smooth: 0.85 }), clip(blob(W, { fill: "#000", smooth: 0.85 }), ...wisp([10, 50, 16, 36, 26, 24, 40, 17, 52, 18, 58, 25], P.w, 1.5, 0.85), ...wisp([14, 58, 20, 46, 30, 38, 38, 36], P.l, 1, 0.6)),
      ...sparks(5, [44, 6, 62, 22], P.w, 8, 0.7)] },
  cup: (P) => [path("M18 26 L46 26 Q46 44 32 46 Q18 44 18 26 Z", { fill: lin([P.l, P.k], 90), stroke: P.w, sw: 0.8 }), rect(29, 46, 6, 6, { fill: P.k, stroke: P.l, sw: 0.5 }), rect(22, 52, 20, 3, { fill: P.k, stroke: P.l, sw: 0.5, r: 1 }),
    ellipse(32, 26, 14, 3, { fill: P.w, glow: { r: 2, color: P.m } }), path("M44 26 Q50 30 49 38 Q48 44 51 50", { stroke: P.l, sw: 1.4, glow: { r: 1, color: P.m } }),
    path("M20 26 Q15 32 16 40", { stroke: P.l, sw: 1, opacity: 0.8 }), ...sparks(5, [18, 12, 46, 24], P.w, 9, 0.6)],
  sprout: (P) => [ellipse(32, 50, 12, 6, { fill: P.k, stroke: P.l, sw: 0.6 }), path("M32 50 Q31 38 33 28", { stroke: P.l, sw: 1.6 }),
    ...lit((st) => path("M33 30 Q22 30 16 20 Q28 16 33 30 Z", st), P, 90), ...lit((st) => path("M33 34 Q44 34 50 22 Q38 18 33 34 Z", st), P, 90),
    path("M33 30 L20 21 M33 34 L46 24", { stroke: P.k, sw: 0.5, opacity: 0.7 }), circle(33, 27, 2, { fill: "#fff", glow: { r: 3, color: P.l, strength: 2 } })],
  bloom: (P) => [...Array.from({ length: 6 }, (_, i) => tf({ rot: i * 60, origin: [32, 32] }, ...lit((st) => path("M32 32 Q24 22 32 10 Q40 22 32 32 Z", st), P, 90, 0.95))),
    circle(32, 32, 5, { fill: rad(["#fff", P.w, P.l], {}), glow: { r: 3, color: P.m, strength: 2 } }), ...sparks(6, [26, 26, 38, 38], "#fff", 11, 0.4)],
  vine: (P) => [...wisp([10, 56, 14, 40, 26, 34, 34, 42, 30, 50, 22, 46, 26, 38, 40, 30, 50, 34, 54, 22, 46, 14], P.l, 2, 0.95),
    ...[[18, 44], [32, 38], [44, 31], [50, 22]].map(([x, y], i) => tf({ rot: i * 50, origin: [x, y] }, poly([x, y, x + 3, y - 4, x + 1, y + 1], { fill: P.w }))),
    ...[[24, 36], [48, 30]].map(([x, y]) => [tf({ rot: -30, origin: [x, y] }, ellipse(x, y, 4, 2, { fill: lin([P.l, P.m], 90) }))])],
  root: (P) => [...lit((st) => path("M30 8 L34 8 L35 26 Q46 30 54 46 Q44 38 37 34 L40 56 Q34 46 32 36 Q30 46 24 56 L27 34 Q20 38 10 46 Q18 30 29 26 Z", st), P, 90), ...sparks(5, [10, 48, 54, 60], P.w, 13, 0.6)],
  bolt: (P) => [...lit((st) => poly([36, 4, 18, 34, 30, 34, 22, 60, 46, 26, 34, 26, 42, 4], st), P, 100), poly([36, 8, 24, 31, 33, 31, 28, 50, 41, 29, 31, 29, 38, 8], { fill: "#fff", opacity: 0.6 })],
  cloud: (P) => [...lit((st) => blob([8, 34, 12, 24, 22, 20, 30, 12, 42, 14, 50, 22, 58, 28, 56, 38, 8, 38], { ...st, smooth: 0.9 }), P, 270, 0.9),
    poly([32, 36, 24, 50, 31, 50, 26, 62, 40, 44, 33, 44, 38, 36], { fill: "#fff", glow: { r: 3, color: P.m, strength: 2 } })],
  crystal: (P) => [...lit((st) => poly([32, 6, 40, 22, 38, 52, 32, 60, 26, 52, 24, 22], st), P, 0), ...lit((st) => poly([18, 24, 24, 32, 22, 50, 16, 54, 12, 46, 13, 32], st), P, 0, 0.85),
    ...lit((st) => poly([46, 24, 51, 32, 52, 46, 48, 54, 42, 50, 41, 32], st), P, 0, 0.85), line([32, 8, 32, 58], { stroke: "#fff", sw: 0.5, opacity: 0.8 })],
  feather: (P) => [...lit((st) => path("M14 56 Q16 30 46 8 Q56 20 46 34 Q36 46 14 56 Z", st), P, 45), path("M14 56 Q30 34 46 8", { stroke: P.k, sw: 1 }),
    ...[0, 1, 2, 3, 4].map(i => line([20 + i * 5, 48 - i * 8, 28 + i * 5, 46 - i * 7], { stroke: P.k, sw: 0.5, opacity: 0.6 })), ...wisp([20, 60, 30, 56, 40, 58, 52, 52], P.l, 0.6, 0.6)],
  swirl: (P) => [...wisp([32, 58, 26, 52, 36, 46, 24, 40, 40, 34, 20, 28, 44, 22, 18, 16, 48, 10], P.w, 1.4, 0.9), ...wisp([34, 58, 28, 50, 38, 44, 28, 38], P.l, 1, 0.6), ...sparks(5, [14, 8, 50, 30], P.w, 14, 0.6)],
  stance: (P) => [circle(32, 14, 4.5, { fill: K2, stroke: P.l, sw: 0.8 }), ...dark("M32 19 Q26 19 24 26 L14 34 L16 37 L25 32 L24 44 L18 58 L28 58 L32 46 L36 58 L46 58 L40 44 L39 32 L48 37 L50 34 L40 26 Q38 19 32 19 Z", P),
    ellipse(32, 60, 16, 2, { fill: P.m, opacity: 0.5, blur: 1.5 }), circle(32, 36, 3, { fill: P.w, glow: { r: 4, color: P.m, strength: 2 } })],
  dash: (P) => [...[2, 1].map(i => tf({ x: -i * 9, opacity: 0.25 + 0.15 * (2 - i) }, path("M36 16 Q41 16 41 20 Q41 24 36 24 Q32 23 32 20 Q32 16 36 16 Z M35 25 L46 33 L44 36 L37 31 L36 41 L46 48 L44 52 L32 44 L24 54 L20 51 L28 40 L28 31 L20 34 L18 31 Z", { fill: P.l }))),
    circle(36, 20, 4, { fill: K2, stroke: P.l, sw: 0.8 }), ...dark("M35 25 L46 33 L44 36 L37 31 L36 41 L46 48 L44 52 L32 44 L24 54 L20 51 L28 40 L28 31 L20 34 L18 31 Z", P),
    ...wisp([6, 38, 18, 36, 26, 37], P.w, 0.7, 0.7), ...wisp([4, 46, 16, 45, 22, 46], P.w, 0.6, 0.5)],
  eye: (P) => [path("M6 34 Q32 10 58 34 Q32 58 6 34 Z", { fill: lin([P.k, P.d], 90), stroke: P.l, sw: 1, glow: { r: 2, color: P.m } }),
    circle(32, 34, 9, { fill: rad([P.w, P.m, P.k], {}) }), ellipse(32, 34, 2.4, 7, { fill: K }), circle(29, 31, 1.4, { fill: "#fff" }),
    ...[0, 1, 2].map(i => curve([14 + i * 14, 20 - (i === 1 ? 6 : 0), 16 + i * 14, 14 - (i === 1 ? 6 : 0), 12 + i * 14, 10 - (i === 1 ? 6 : 0)], { stroke: P.l, sw: 0.7, opacity: 0.7 }))],
  lotus: (P) => [...[-50, -25, 0, 25, 50].map((a, i) => tf({ rot: a, origin: [32, 48] }, ...lit((st) => path("M32 48 Q24 34 32 18 Q40 34 32 48 Z", st), P, 90, i === 2 ? 1 : 0.8))),
    ellipse(32, 50, 18, 3, { fill: P.k, stroke: P.l, sw: 0.6 }), circle(32, 40, 3, { fill: "#fff", glow: { r: 4, color: P.l, strength: 2 } }), ...sparks(5, [20, 8, 44, 24], P.w, 15, 0.6)],
  spirit: (P) => [...lit((st) => path("M32 10 Q44 10 44 24 L44 40 Q46 48 52 54 Q44 54 40 50 Q38 56 32 58 Q28 52 26 50 Q20 54 12 54 Q18 48 20 40 L20 24 Q20 10 32 10 Z", st), P, 90, 0.85),
    ellipse(27, 24, 2.2, 3, { fill: K }), ellipse(37, 24, 2.2, 3, { fill: K }), path("M28 32 Q32 35 36 32", { stroke: K, sw: 1 }), ...sparks(5, [10, 10, 54, 40], P.w, 16, 0.6)],
  lance: (P) => [line([6, 58, 58, 6], { stroke: P.m, sw: 7, opacity: 0.35, blur: 3 }), line([8, 56, 56, 8], { stroke: lin([P.l, "#fff"], 45), sw: 2.6 }),
    ...lit((st) => poly([56, 8, 46, 12, 52, 18], st), P, 45), ...[0, 1, 2].map(i => circle(18 + i * 10, 46 - i * 10, 3 - i * 0.6, { stroke: P.w, sw: 0.6, opacity: 0.6 }))],
  hourglass: (P) => [rect(16, 8, 32, 3, { fill: P.k, stroke: P.l, sw: 0.5, r: 1 }), rect(16, 54, 32, 3, { fill: P.k, stroke: P.l, sw: 0.5, r: 1 }),
    path("M20 11 Q20 26 32 32 Q20 38 20 54 L44 54 Q44 38 32 32 Q44 26 44 11 Z", { fill: alpha(P.l, 0.15), stroke: P.w, sw: 1, glow: { r: 2, color: P.m } }),
    path("M24 16 L40 16 Q38 26 32 30 Q26 26 24 16 Z", { fill: lin([P.w, P.m], 90) }), path("M24 52 Q28 44 32 42 Q36 44 40 52 Z", { fill: lin([P.l, P.m], 90) }), line([32, 31, 32, 44], { stroke: P.w, sw: 0.6, dash: [1, 1] })],
  chain: (P) => [...[0, 1, 2, 3].map(i => tf({ x: 10 + i * 11, y: 46 - i * 10, rot: -40 + (i % 2) * 90, origin: [0, 0] },
    ellipse(0, 0, 7, 4, { stroke: P.k, sw: 3 }), ellipse(0, 0, 7, 4, { stroke: lin([P.w, P.m], 90), sw: 1.6 }))), ...sparks(4, [8, 8, 56, 56], P.w, 17, 0.6)],
  shield: (P) => [...lit((st) => path("M32 8 L52 16 Q52 42 32 58 Q12 42 12 16 Z", st), P, 90, 0.9), path("M32 13 L47 19 Q47 40 32 52 Q17 40 17 19 Z", { fill: lin([P.k, P.d], 90), stroke: P.w, sw: 0.7 }),
    path("M32 18 L32 46 M24 28 L40 28", { stroke: P.l, sw: 1.6, glow: { r: 1.5, color: P.m } })],
  drop: (P) => [...lit((st) => path("M32 6 Q46 28 46 38 Q46 52 32 54 Q18 52 18 38 Q18 28 32 6 Z", st), P, 90), tf({ rot: 20, origin: [26, 36] }, ellipse(26, 36, 3, 6, { fill: "#fff", opacity: 0.55 }))],
  brazier: (P) => [path("M18 36 L46 36 L42 48 L22 48 Z", { fill: lin([P.k, K], 90), stroke: P.l, sw: 0.7 }), line([22, 48, 18, 58], { stroke: P.l, sw: 1.2 }), line([42, 48, 46, 58], { stroke: P.l, sw: 1.2 }), line([32, 48, 32, 58], { stroke: P.l, sw: 1.2 }),
    tf({ scale: 0.6, origin: [32, 36], y: -6 }, ...S_flame(P)), ...sparks(5, [20, 4, 44, 18], P.w, 18, 0.7)],
  phoenix: (P) => [...lit((st) => path("M32 50 Q22 36 6 34 Q16 28 28 34 Q22 22 14 10 Q30 16 32 32 Q34 16 50 10 Q42 22 36 34 Q48 28 58 34 Q42 36 32 50 Z", st), P, 90),
    path("M32 50 Q30 56 26 60 M32 50 Q34 56 38 60 M32 50 L32 60", { stroke: P.l, sw: 1, glow: { r: 1.5, color: P.m } }), circle(32, 30, 2.4, { fill: "#fff", glow: { r: 3, color: P.l, strength: 2 } })],
  core: (P) => [...[0, 1, 2].map(i => tf({ rot: i * 60, origin: [32, 34] }, ellipse(32, 34, 22 - i * 2, 8 + i * 4, { stroke: P.l, sw: 0.6, opacity: 0.5 }))),
    circle(32, 34, 9, { fill: rad(["#fff", P.w, P.l, P.m], {}), glow: { r: 6, color: P.m, strength: 3 } }), ...rays(32, 34, 10, 24, P.w, 19, 0.2)],
  thread: (P) => [line([14, 54, 50, 14], { stroke: lin([P.l, "#fff"], 45), sw: 1.4, glow: { r: 1.5, color: P.m } }), tf({ rot: 45, origin: [48, 16] }, ellipse(48, 16, 1.6, 3, { stroke: P.k, sw: 0.8 })),
    ...wisp([48, 16, 58, 26, 46, 40, 30, 34, 22, 46, 10, 40], P.w, 0.8, 0.8), ...[[30, 34], [22, 46]].map(([x, y]) => line([x - 2, y - 2, x + 2, y + 2], { stroke: P.l, sw: 0.5 }))],
  orb: (P) => [...wisp([6, 58, 14, 50, 22, 44, 30, 40], P.l, 2.4, 0.5), ...wisp([10, 54, 18, 48, 28, 41], P.w, 1, 0.7),
    circle(40, 30, 11, { fill: P.m, opacity: 0.5, blur: 3 }), circle(40, 30, 9, { fill: rad(["#fff", P.w, P.l, P.m], {}), glow: { r: 4, color: P.m, strength: 2 } })],
  tablet: (P) => [rect(18, 8, 28, 48, { fill: lin([P.k, K], 90), stroke: P.l, sw: 0.8, r: 3 }), rect(21, 11, 22, 42, { stroke: P.l, sw: 0.4, opacity: 0.6, r: 2 }),
    path("M26 17 L38 17 M32 14 L32 26 M26 30 L38 30 M27 36 Q32 33 37 36 M26 44 L38 50 M38 44 L26 50", { stroke: P.w, sw: 1.3, glow: { r: 1.5, color: P.m } })],
  husk: (P) => [path("M32 8 Q48 8 48 28 Q48 44 40 54 L24 54 Q16 44 16 28 Q16 8 32 8 Z", { fill: lin([P.k, K], 90), stroke: P.l, sw: 0.9, glow: { r: 1.5, color: P.m } }),
    path("M23 26 Q27 22 30 27 Q27 30 23 26 Z M34 27 Q37 22 41 26 Q37 30 34 27 Z", { fill: P.w, glow: { r: 2, color: P.m } }), path("M28 42 Q32 38 36 42", { stroke: P.l, sw: 1 }),
    circle(32, 34, 20, { stroke: P.l, sw: 0.5, opacity: 0.4, dash: [2, 2] })],
  cleave: (P) => [arc(32, 34, 22, 220, 400, { stroke: P.m, sw: 7, opacity: 0.4, blur: 2 }), arc(32, 34, 22, 220, 400, { stroke: lin([P.w, P.l], 0), sw: 3 }),
    ...lit((st) => poly([12, 52, 40, 18, 46, 14, 44, 22, 16, 56], st), P, 45), tf({ rot: -50, origin: [13, 52] }, rect(9, 51, 9, 3, { fill: P.k, stroke: P.l, sw: 0.4 }))],
  wedge: (P) => [rect(8, 40, 48, 18, { fill: lin([P.k, K], 90), stroke: P.l, sw: 0.5 }), path("M30 40 L26 50 L32 58 M30 40 L36 48 L34 58", { stroke: P.w, sw: 0.8, glow: { r: 1.5, color: P.m } }),
    ...lit((st) => poly([24, 8, 40, 8, 32, 42], st), P, 90), ...sparks(6, [20, 34, 44, 44], P.w, 20, 0.7)],
  mantle: (P) => [...lit((st) => path("M20 12 Q32 18 44 12 L52 22 L46 26 L48 56 L16 56 L18 26 L12 22 Z", st), P, 90, 0.85), path("M32 18 L32 56 M18 26 L46 26", { stroke: P.k, sw: 0.8 }),
    ...[0, 1, 2].map(i => poly([22 + i * 8, 34, 26 + i * 8, 40, 22 + i * 8, 46, 18 + i * 8, 40], { fill: "#fff", opacity: 0.6 }))],
  scroll: (P) => [rect(14, 16, 36, 32, { fill: lin(["#efe6cf", "#c9b48a"], 90), r: 1 }), rect(10, 13, 6, 38, { fill: P.k, stroke: P.l, sw: 0.5, r: 2 }), rect(48, 13, 6, 38, { fill: P.k, stroke: P.l, sw: 0.5, r: 2 }),
    path("M22 24 L40 24 M22 30 L36 30 M22 36 L40 36", { stroke: "#2a241c", sw: 1 }), circle(36, 42, 5, { fill: P.m, glow: { r: 2, color: P.l } }), path("M34 40 L38 44 M38 40 L34 44", { stroke: P.w, sw: 0.8 })],
  cairn: (P) => [...lit((st) => ellipse(32, 50, 18, 7, st), P, 90, 0.85), ...lit((st) => ellipse(32, 38, 13, 6, st), P, 90, 0.9), ...lit((st) => ellipse(32, 27, 9, 5, st), P, 90), ...lit((st) => ellipse(32, 18, 5, 3.5, st), P, 90),
    ellipse(29, 26, 1.3, 1, { fill: "#fff", glow: { r: 2, color: P.l } }), ellipse(35, 26, 1.3, 1, { fill: "#fff", glow: { r: 2, color: P.l } })],
  millstone: (P) => [...lit((st) => circle(32, 34, 20, st), P, 90, 0.85), circle(32, 34, 5, { fill: K, stroke: P.w, sw: 0.8 }),
    ...Array.from({ length: 8 }, (_, i) => { const a = i / 8 * Math.PI * 2; return line([32 + Math.cos(a) * 7, 34 + Math.sin(a) * 7, 32 + Math.cos(a + 0.4) * 19, 34 + Math.sin(a + 0.4) * 19], { stroke: P.k, sw: 1 }) }),
    arc(32, 34, 25, 40, 140, { stroke: P.w, sw: 0.9, opacity: 0.7 }), arc(32, 34, 25, 220, 320, { stroke: P.w, sw: 0.9, opacity: 0.7 })],
  // a seated cultivator drawing a column of breath up from the dantian
  breath: (P) => [...wisp([32, 30, 28, 22, 36, 16, 28, 10, 34, 4], P.w, 1.6, 0.9), ...wisp([32, 30, 38, 22, 30, 16, 38, 9], P.l, 1, 0.6),
    circle(32, 31, 4.2, { fill: K2, stroke: P.l, sw: 0.8 }),
    ...dark("M32 36 Q24 36 22 44 L20 50 Q12 52 10 56 L54 56 Q52 52 44 50 L42 44 Q40 36 32 36 Z", P),
    path("M14 56 Q32 50 50 56", { stroke: P.l, sw: 0.8, opacity: 0.8 }),
    circle(32, 47, 3, { fill: rad(["#fff", P.w, P.l], {}), glow: { r: 4, color: P.m, strength: 2 } }), ...sparks(4, [20, 6, 44, 26], P.w, 21, 0.6)],
  haze: (P) => [...[0, 1, 2, 3].map(i => curve([6, 18 + i * 9, 18, 15 + i * 9, 30, 21 + i * 9, 42, 15 + i * 9, 58, 19 + i * 9], { stroke: P.l, sw: 1.2, opacity: 0.35 + i * 0.12, blur: 0.6 })),
    circle(32, 32, 7, { fill: rad([P.w, P.m], {}), glow: { r: 4, color: P.m, strength: 2 } }), ellipse(32, 32, 1.8, 5, { fill: K })],
  blood: (P) => [...lit((st) => path("M32 8 Q44 26 44 36 Q44 50 32 52 Q20 50 20 36 Q20 26 32 8 Z", { ...st }), { ...P, m: "#c0263a", l: "#ff6b6b", w: "#ffc0c0" }, 90),
    ...wisp([10, 56, 22, 52, 34, 58, 46, 52, 56, 56], P.l, 0.8, 0.7), ellipse(27, 34, 2.5, 5, { fill: "#fff", opacity: 0.5 })],
}
function S_flame(P) { return S.flame(P) }

// ---------------------------------------------------------------- modifiers
const MOD = {
  echo: (items) => [tf({ x: -7, y: 4, opacity: 0.32 }, ...items), ...items],
  quick: (P) => [0, 1, 2].map(i => line([4, 20 + i * 12, 14, 20 + i * 12], { stroke: P.w, sw: 0.6, opacity: 0.45 })),
  heavy: (P) => [ellipse(32, 58, 22, 3, { stroke: P.w, sw: 0.8, opacity: 0.6, glow: { r: 1.5, color: P.m } }), ...rays(32, 58, 9, 10, P.l, 23, 0.3)],
  held: (P) => [arc(32, 34, 28, 30, 330, { stroke: P.w, sw: 0.6, opacity: 0.5, dash: [3, 2] })],
  summon: (P) => [circle(32, 56, 9, { stroke: P.l, sw: 0.6, opacity: 0.55 }), ellipse(32, 56, 14, 3, { stroke: P.l, sw: 0.5, opacity: 0.45 })],
}

// ---------------------------------------------------------------- the three asset kinds
function artIcon(r) {
  const P = tones(HUE[r.hue]), s = seedOf(r.id)
  let subject = S[r.subject](P)
  if (r.mods.includes("echo")) subject = MOD.echo(subject)
  const muted = r.tier === "common"
  sprite("art_" + r.id.replace(/-/g, "_"), { w: 256, h: 256, scale: 0.5 },
    tf({ scale: 4 },
      ...ground(P, 32, 32, muted), ...(MOTIF[r.motif] ? MOTIF[r.motif](P, s) : []),
      ...(r.mods.includes("summon") ? MOD.summon(P) : []), ...(r.mods.includes("held") ? MOD.held(P) : []),
      tf({ opacity: muted ? 0.92 : 1 }, ...subject),
      ...(r.mods.includes("quick") ? MOD.quick(P) : []), ...(r.mods.includes("heavy") ? MOD.heavy(P) : []),
      ...(ROLE[r.role] ? ROLE[r.role](P) : []), ...frameArt()))
}
function wardIcon(id, hue, subject) {
  const P = tones(HUE[hue])
  sprite("ward_" + id, { w: 256, h: 256, scale: 0.375 },
    tf({ scale: 4 }, clip(poly(chamfer(0.3), { fill: "#000" }), ...ground(P, 32, 33), circle(32, 33, 22, { stroke: P.l, sw: 0.6, opacity: 0.4 }),
      circle(32, 33, 27, { stroke: P.l, sw: 0.4, opacity: 0.25 }), ...S[subject](P), vignette()), ...frameWard(P)))
}
// chips: 24-unit, exported at 48 px. Buff: rounded, up-notch, solid rim. Debuff: chamfered TL/BR, down-notch, dashed rim.
const GLYPH = {
  fire: (c, l) => [path("M12 3.5 Q17 9 16 13 Q18.5 11.5 18 8.5 Q21.5 14 19 18.5 Q16.5 21.5 12 21.5 Q7.5 21.5 5.5 18 Q4 13.5 7.5 10 Q7.5 13.5 9.5 13.5 Q8 8 12 3.5 Z", { fill: lin([l, c], 90) }), path("M12 13 Q14.5 15.5 14 18.5 Q12 20.5 10 18.5 Q9.5 15.5 12 13 Z", { fill: "#fff", opacity: 0.85 })],
  water: (c, l) => [path("M12 3 Q18.5 11.5 18.5 15 Q18.5 21 12 21 Q5.5 21 5.5 15 Q5.5 11.5 12 3 Z", { fill: lin([l, c], 90) }), tf({ rot: 20, origin: [9.4, 15] }, ellipse(9.4, 15, 1.3, 2.6, { fill: "#fff", opacity: 0.7 }))],
  wood: (c, l) => [path("M6 20 Q6 8 19 5 Q20 16 9 19 Z", { fill: lin([l, c], 60) }), path("M6 20 Q11 13 17 7.5", { stroke: "#0b0d10", sw: 0.9 }), path("M4 21 Q3 15 6 12", { stroke: l, sw: 1.2 })],
  metal: (c, l) => [poly([5, 15, 8, 9, 16, 9, 19, 15], { fill: lin([l, c], 90) }), poly([5, 15, 19, 15, 19, 18, 5, 18], { fill: c }), line([9, 10.5, 15, 10.5], { stroke: "#fff", sw: 0.8, opacity: 0.8 })],
  earth: (c, l) => [poly([3, 20, 9, 9, 12, 13, 15, 7, 21, 20], { fill: lin([l, c], 90) }), poly([15, 7, 16.5, 10, 15, 9.5, 13.6, 11], { fill: "#fff", opacity: 0.85 }), line([3, 20, 21, 20], { stroke: c, sw: 1.2 })],
  ice: (c, l) => [...[0, 60, 120].map(a => tf({ rot: a, origin: [12, 12] }, line([12, 3.5, 12, 20.5], { stroke: l, sw: 1.6 }), line([10, 6, 12, 8, 14, 6], { stroke: l, sw: 1.1 }), line([10, 18, 12, 16, 14, 18], { stroke: l, sw: 1.1 }))), circle(12, 12, 1.4, { fill: "#fff" })],
  thunder: (c, l) => [poly([13.5, 2.5, 6, 13, 11, 13, 8.5, 21.5, 18, 10, 13, 10, 16, 2.5], { fill: lin(["#fff", l, c], 90) })],
  wind: (c, l) => [curve([4, 9, 10, 8, 15, 9, 17.5, 6.5, 15, 5], { stroke: l, sw: 1.6 }), curve([3, 13, 12, 12.5, 19, 13, 20.5, 10.5], { stroke: l, sw: 1.6 }), curve([5, 17, 11, 16.5, 14, 17.5, 15.5, 19.5, 13.5, 20.5], { stroke: l, sw: 1.6 })],
}
function chip(kind, el) {
  const buff = kind === "buff", c = HUE[kind], l = mix(c, "#ffffff", 0.35), g = mix(c, K, 0.86)
  const shape = buff ? rect(1, 1, 22, 22, { r: 5, fill: rad([g, K], { cx: 0.5, cy: 0.45, r: 0.8 }) })
    : poly([5.5, 1, 23, 1, 23, 18.5, 18.5, 23, 1, 23, 1, 5.5], { fill: rad([g, K], { cx: 0.5, cy: 0.45, r: 0.8 }) })
  const rim = buff ? rect(1, 1, 22, 22, { r: 5, stroke: c, sw: 1.1 }) : poly([5.5, 1, 23, 1, 23, 18.5, 18.5, 23, 1, 23, 1, 5.5], { stroke: c, sw: 1.1, dash: [2.2, 1.2] })
  const notch = buff ? poly([9.5, 1, 12, -1.6, 14.5, 1], { fill: c }) : poly([9.5, 23, 12, 25.6, 14.5, 23], { fill: c })
  const pip = buff ? poly([19.5, 6.5, 21.2, 3.6, 22.9, 6.5], { fill: "#fff", opacity: 0.85 }) : poly([19.5, 17.5, 21.2, 20.4, 22.9, 17.5], { fill: "#fff", opacity: 0.85 })
  sprite(kind + "_" + el, { w: 26, h: 28, scale: 48 / 26 },
    tf({ x: 1, y: 2 }, shape, tf({ x: 1.2, y: 1.2, scale: 0.9, glow: { r: 1.2, color: c } }, ...GLYPH[el](c, l)), rim, notch, pip))
}
