// Painted-parchment map style demo, round 2: rhumb lines and boats (c4), sect territories (c5), engraved relief (c6).
// MAPS is injected above by gen.py from ../maps/maps.json.

const T = 24;            // units per map cell
const M = 30;            // margin for the border

const SETS = [
  { id: "c4", seed: 44, name: "Explorer's chart", rhumb: true, boats: true, regions: true,
    paper: "#ead9b0", paperD: "#d5bd8c", ink: "#3d2a1a", inkL: "#6e5236", sea: "#d6c49a", land: "#eddcb4",
    road: "#7a3a22", wash: false, accent: "#8a2e1e", font: "Cambria", sealFill: "#8a2e1e" },
  { id: "c5", seed: 55, name: "Territory atlas", territories: true, regions: true,
    paper: "#f1e5c8", paperD: "#dcc79c", ink: "#33281c", inkL: "#665238", sea: "#9fc0c4", land: "#ebdfb8",
    road: "#7a5a3a", wash: true, accent: "#8a2a1e", font: "Constantia", sealFill: "#8a2a1e" },
  { id: "c6", seed: 66, name: "Engraved", engraved: true, regions: true,
    paper: "#f3ecda", paperD: "#e0d4b8", ink: "#141414", inkL: "#3a3a3a", sea: "#f3ecda", land: "#f7f1e2",
    road: "#141414", wash: false, accent: "#141414", font: "Palatino Linotype", sealFill: "#141414" },
];

const WASH = { g: "#b8c88a", f: "#7fa070", j: "#6f9a5a", d: "#e2c27a", s: "#9aa07a", h: "#c8c08a",
  m: "#b0a088", v: "#c08060", i: "#f4f2ea", t: "#d4d0bc", b: "#e8d8a8" };

function rng(seed) {
  let a = seed >>> 0;
  return () => { a = (a + 0x6D2B79F5) >>> 0; let t = a; t = Math.imul(t ^ (t >>> 15), t | 1); t ^= t + Math.imul(t ^ (t >>> 7), t | 61); return ((t ^ (t >>> 14)) >>> 0) / 4294967296; };
}

const isLand = (c) => c !== "~" && c !== "w";

// Smooth coastlines: a Gaussian field over cell centres, contoured with marching squares.
function makeField(MP, pred, sigma, step, seed) {
  const W = MP.w * T, H = MP.h * T;
  const nx = Math.ceil(W / step) + 1, ny = Math.ceil(H / step) + 1;
  const cells = [];
  for (let y = 0; y < MP.h; y++) for (let x = 0; x < MP.w; x++) if (pred(MP.terrain[y][x], x, y)) cells.push([x * T + T / 2, y * T + T / 2]);
  const f = new Float32Array(nx * ny);
  const r2 = (3 * sigma) ** 2;
  for (let j = 0; j < ny; j++) for (let i = 0; i < nx; i++) {
    const px = i * step, py = j * step;
    let v = 0;
    for (const [cx, cy] of cells) { const d2 = (px - cx) ** 2 + (py - cy) ** 2; if (d2 < r2) v += Math.exp(-d2 / (2 * sigma * sigma)); }
    f[j * nx + i] = v + noise(px / 40, py / 40, seed) * 0.12;
  }
  return { f, nx, ny, step };
}
function contours(F, thr, ox, oy) {
  const { f, nx, ny, step } = F;
  const v = (i, j) => (i < 0 || j < 0 || i >= nx || j >= ny) ? -1 : f[j * nx + i];
  const segs = new Map();
  const key = (x, y) => Math.round(x * 100) + "," + Math.round(y * 100);
  const edge = (i0, j0, i1, j1) => { const a = v(i0, j0), b = v(i1, j1); const t = (thr - a) / (b - a); return [(i0 + (i1 - i0) * t) * step, (j0 + (j1 - j0) * t) * step]; };
  const add = (p, q) => { const kp = key(...p), kq = key(...q); (segs.get(kp) || segs.set(kp, []).get(kp)).push([q, kq, p]); (segs.get(kq) || segs.set(kq, []).get(kq)).push([p, kp, q]); };
  for (let j = -1; j < ny; j++) for (let i = -1; i < nx; i++) {
    const a = v(i, j) > thr, b = v(i + 1, j) > thr, c = v(i + 1, j + 1) > thr, d = v(i, j + 1) > thr;
    const idx = (a ? 8 : 0) | (b ? 4 : 0) | (c ? 2 : 0) | (d ? 1 : 0);
    if (idx === 0 || idx === 15) continue;
    const T_ = () => edge(i, j, i + 1, j), R_ = () => edge(i + 1, j, i + 1, j + 1), B_ = () => edge(i, j + 1, i + 1, j + 1), L_ = () => edge(i, j, i, j + 1);
    const tab = { 1: [[L_, B_]], 2: [[B_, R_]], 3: [[L_, R_]], 4: [[T_, R_]], 5: [[L_, T_], [B_, R_]], 6: [[T_, B_]], 7: [[L_, T_]],
      8: [[L_, T_]], 9: [[T_, B_]], 10: [[L_, B_], [T_, R_]], 11: [[T_, R_]], 12: [[L_, R_]], 13: [[B_, R_]], 14: [[L_, B_]] };
    for (const [g1, g2] of tab[idx]) add(g1(), g2());
  }
  const used = new Set(); const loops = [];
  for (const [k0, list] of segs) {
    for (const [q0, kq0, p0] of list) {
      const ek = k0 + ">" + kq0; if (used.has(ek)) continue;
      const pts = [p0, q0]; used.add(ek); used.add(kq0 + ">" + k0);
      let prevK = k0, curK = kq0, cur = q0;
      for (let n = 0; n < 5000; n++) {
        const nexts = (segs.get(curK) || []).filter(([q, kq]) => kq !== prevK && !used.has(curK + ">" + kq));
        if (!nexts.length) break;
        const [q, kq] = nexts[0]; used.add(curK + ">" + kq); used.add(kq + ">" + curK);
        if (kq === k0) break;
        pts.push(q); prevK = curK; curK = kq; cur = q;
      }
      if (pts.length > 6) loops.push(pts.filter((_, i) => i % 2 === 0).flatMap(([x, y]) => [x + ox, y + oy]));
    }
  }
  return loops;
}


for (const S of SETS) {
  const p = S.id + "_";
  pal({ paper: S.paper, paperD: S.paperD, ink: S.ink, inkL: S.inkL, sea: S.sea, land: S.land, road: S.road,
        acc: S.accent, seal: S.sealFill, white: "#fbf6ea" });
  const INK = { c: "ink", w: 1.6, wobble: 0.6, taper: 0.4 };
  const INKL = { c: "inkL", w: 1.1, wobble: 0.5, taper: 0.5 };

  // ---------- terrain symbols (each ~24 x 24 units, anchored at the cell centre) ----------
  sprite(p + "sym_mountain", { w: 30, h: 26 },
    poly([2, 24, 15, 3, 28, 24], { fill: "land" }),
    poly([15, 3, 28, 24, 17, 24, 18, 15], S.engraved ? { fill: "land", hatch: { c: "ink", gap: 1.8, angle: 70, opacity: 0.8 } } : { fill: "paperD", opacity: 0.9 }),
    curve([2, 24, 9, 14, 15, 3, 21, 12, 28, 24], { ink: { ...INK, w: 1.8 }, smooth: 0.2 }),
    (f) => Array.from({ length: 5 }, (_, i) => line([18 + i * 1.8, 10 + i * 3, 16 + i * 2.2, 22], { stroke: "inkL", sw: 0.7, opacity: 0.8 })));
  sprite(p + "sym_peak", { w: 34, h: 30 },
    poly([2, 28, 17, 2, 32, 28], { fill: "land" }),
    poly([17, 2, 32, 28, 19, 28, 21, 16], S.engraved ? { fill: "land", hatch: { c: "ink", gap: 1.8, angle: 70, opacity: 0.8 } } : { fill: "paperD", opacity: 0.9 }),
    poly([12, 10, 17, 2, 22, 10, 19, 9, 17, 11, 15, 9], { fill: "white" }),
    curve([2, 28, 10, 16, 17, 2, 25, 15, 32, 28], { ink: { ...INK, w: 2 }, smooth: 0.2 }),
    (f) => Array.from({ length: 6 }, (_, i) => line([21 + i * 1.7, 12 + i * 2.8, 19 + i * 2.2, 26], { stroke: "inkL", sw: 0.7, opacity: 0.8 })));
  sprite(p + "sym_volcano", { w: 32, h: 32 },
    poly([2, 30, 12, 10, 20, 10, 30, 30], { fill: "land" }),
    poly([16, 10, 20, 10, 30, 30, 19, 30], { fill: "paperD" }),
    curve([2, 30, 8, 18, 12, 10], { ink: INK, smooth: 0.3 }), curve([20, 10, 25, 20, 30, 30], { ink: INK, smooth: 0.3 }),
    ellipse(16, 10, 4, 1.5, { fill: "acc", opacity: 0.8 }),
    curve([16, 8, 13, 5, 17, 3, 14, 0], { ink: { ...INKL, w: 1.3 } }),
    curve([18, 14, 17, 22, 19, 29], { stroke: "acc", sw: 1.3, opacity: 0.8 }));
  sprite(p + "sym_hill", { w: 22, h: 12 },
    curve([1, 11, 6, 3, 11, 2, 16, 4, 21, 11], { ink: { ...INKL, w: 1.3 } }),
    line([13, 5, 15, 10], { stroke: "inkL", sw: 0.6 }), line([15, 6, 17, 10], { stroke: "inkL", sw: 0.6 }));
  sprite(p + "sym_tree", { w: 10, h: 14 },
    line([5, 8, 5, 13], { stroke: "ink", sw: 1 }),
    circle(5, 5.5, 4, { fill: "land", ink: { ...INKL, w: 1.1 } }),
    arc(5, 5.5, 3, 20, 160, { stroke: "inkL", sw: 0.8 }));
  sprite(p + "sym_pine", { w: 10, h: 15 },
    line([5, 11, 5, 14], { stroke: "ink", sw: 1 }),
    poly([5, 1, 9, 11, 1, 11], { fill: "land", ink: { ...INKL, w: 1 } }),
    line([5, 3, 7.5, 10], { stroke: "inkL", sw: 0.6 }));
  sprite(p + "sym_palm", { w: 14, h: 15 },
    curve([7, 14, 7.5, 9, 7, 5], { stroke: "ink", sw: 1 }),
    curve([7, 5, 3, 4, 1, 7], { ink: INKL }), curve([7, 5, 11, 4, 13, 7], { ink: INKL }),
    curve([7, 5, 5, 1, 2, 1], { ink: INKL }), curve([7, 5, 9, 1, 12, 1], { ink: INKL }));
  sprite(p + "sym_reeds", { w: 14, h: 10 },
    line([3, 9, 2, 2], { stroke: "inkL", sw: 0.8 }), line([6, 9, 6, 1], { stroke: "inkL", sw: 0.8 }),
    line([9, 9, 10, 3], { stroke: "inkL", sw: 0.8 }), line([0, 9, 14, 9], { stroke: "inkL", sw: 0.8, dash: [3, 2] }));
  sprite(p + "sym_dune", { w: 22, h: 8 },
    curve([1, 7, 7, 2, 12, 2, 21, 7], { ink: { ...INKL, w: 1 } }),
    circle(6, 6.5, 0.5, "inkL"), circle(14, 6, 0.5, "inkL"), circle(10, 7, 0.4, "inkL"));
  sprite(p + "sym_snow", { w: 12, h: 12 },
    radial(6, 6, 6, line([6, 6, 6, 1.5], { stroke: "inkL", sw: 0.7 })));
  sprite(p + "sym_tundra", { w: 16, h: 6 },
    line([1, 5, 5, 5], { stroke: "inkL", sw: 0.8 }), line([8, 3, 11, 3], { stroke: "inkL", sw: 0.8 }),
    circle(14, 5, 0.6, "inkL"));
  sprite(p + "sym_wave", { w: 14, h: 5 },
    curve([1, 4, 4, 1, 7, 4, 10, 1, 13, 4], { stroke: "inkL", sw: 0.8, opacity: 0.7 }));

  // ---------- place icons ----------
  const ICO = { w: 28, h: 28 };
  sprite(p + "ico_city", ICO,
    circle(14, 15, 11, { fill: "land", ink: { ...INK, w: 1.8 } }),
    circle(14, 15, 7.5, { fill: "none", stroke: "ink", sw: 0.8 }),
    radial(6, 14, 15, rect(12.5, 2.5, 3, 4, { fill: "ink" })),
    rect(11, 12, 6, 6, { fill: "acc" }), poly([10, 12, 14, 8, 18, 12], { fill: "ink" }));
  sprite(p + "ico_town", ICO,
    rect(3, 15, 8, 8, { fill: "land", ink: INK }), poly([2, 15, 7, 9, 12, 15], { fill: "acc", ink: INK }),
    rect(14, 12, 10, 11, { fill: "land", ink: INK }), poly([13, 12, 19, 5, 25, 12], { fill: "acc", ink: INK }),
    rect(17.5, 17, 3, 6, { fill: "ink" }));
  sprite(p + "ico_sect", ICO,
    rect(4, 23, 20, 3, { fill: "inkL" }),
    rect(8, 15, 12, 8, { fill: "land", ink: INK }), poly([3, 16, 14, 10, 25, 16], { fill: "acc", ink: INK }),
    rect(10, 6, 8, 5, { fill: "land", ink: INK }), poly([6, 7, 14, 1, 22, 7], { fill: "acc", ink: INK }),
    rect(12.5, 18, 3, 5, { fill: "ink" }));
  sprite(p + "ico_mine", ICO,
    curve([2, 25, 8, 9, 14, 5, 20, 9, 26, 25], { fill: "land", ink: INK }),
    poly([9, 25, 9, 16, 14, 12, 19, 16, 19, 25], { fill: "ink" }),
    line([5, 6, 13, 14], { stroke: "acc", sw: 1.6 }), line([23, 6, 15, 14], { stroke: "acc", sw: 1.6 }));
  sprite(p + "ico_abode", ICO,
    curve([2, 25, 6, 11, 14, 5, 22, 11, 26, 25], { fill: "land", ink: INK }),
    curve([9, 25, 10, 16, 14, 13, 18, 16, 19, 25], { fill: "ink" }),
    circle(21, 11, 1.4, { fill: "acc", glow: { r: 3, color: "acc" } }));
  sprite(p + "ico_ruin", ICO,
    rect(4, 10, 4, 15, { fill: "land", ink: INK }), rect(20, 14, 4, 11, { fill: "land", ink: INK }),
    poly([3, 10, 9, 10, 8, 7, 4, 8], { fill: "land", ink: INK }), rect(11, 21, 7, 4, { fill: "land", ink: INK }),
    text(14, 17, "?", { size: 10, font: S.font, anchor: "middle", fill: "acc", weight: "bold" }));
  sprite(p + "ico_blessed", ICO,
    radial(12, 14, 14, line([14, 14, 14, 2], { stroke: "acc", sw: 0.8, opacity: 0.8 })),
    circle(14, 12, 6, { fill: "land", ink: INK }), line([14, 18, 14, 25], { stroke: "ink", sw: 1.6 }),
    circle(12, 10, 1.2, "acc"));
  sprite(p + "ico_vein", ICO,
    poly([6, 25, 9, 11, 12, 25], { fill: "land", ink: INK }), poly([11, 25, 14, 5, 17, 25], { fill: "acc", ink: INK }),
    poly([16, 25, 19, 13, 22, 25], { fill: "land", ink: INK }));
  sprite(p + "seal", { w: 22, h: 22 },
    rect(2, 2, 18, 18, { fill: "seal", r: 2, ink: { c: "seal", w: 1, wobble: 0.8 } }),
    rect(5, 5, 12, 12, { fill: "none", stroke: "white", sw: 1.2 }),
    line([8, 8, 14, 8], { stroke: "white", sw: 1.2 }), line([11, 8, 11, 15], { stroke: "white", sw: 1.2 }),
    line([8, 14, 14, 14], { stroke: "white", sw: 1.2 }));
  sprite(p + "compass", { w: 70, h: 70 },
    circle(35, 35, 30, { fill: "none", stroke: "ink", sw: 1 }), circle(35, 35, 26, { fill: "none", stroke: "inkL", sw: 0.6 }),
    radial(8, 35, 35, poly([35, 35, 32, 30, 35, 12, 38, 30], { fill: "inkL" })),
    radial(4, 35, 35, poly([35, 35, 31, 29, 35, 4, 35, 35], { fill: "ink" }), poly([35, 35, 39, 29, 35, 4, 35, 35], { fill: "land" })),
    circle(35, 35, 3, { fill: "acc" }),
    text(35, 3, "B", { size: 9, font: S.font, anchor: "middle", fill: "ink", weight: "bold" }));

  sprite(p + "boat", { w: 30, h: 26 },
    curve([2, 18, 8, 23, 22, 23, 28, 17], { fill: "land", ink: { c: "ink", w: 1.3, wobble: 0.4 } }),
    line([2, 18, 28, 17], { stroke: "ink", sw: 1 }),
    line([14, 18, 14, 2], { stroke: "ink", sw: 1 }),
    poly([15, 3, 25, 6, 23, 16, 15, 16], { fill: "paperD", ink: { c: "ink", w: 1, wobble: 0.4 } }),
    (f) => [6, 9, 12].map((y) => line([15, y, 24.5, y + 1], { stroke: "inkL", sw: 0.6 })),
    poly([13, 6, 6, 9, 7, 16, 13, 16], { fill: "paperD", ink: { c: "ink", w: 1, wobble: 0.4 } }),
    curve([0, 24, 8, 25, 22, 25, 30, 24], { stroke: "inkL", sw: 0.6, opacity: 0.6 }));
  sheet(p + "symbols", [p + "sym_*"], { pad: 6, scale: 3 });
  sheet(p + "icons", [p + "ico_*", p + "seal", p + "compass"], { pad: 6, scale: 3 });

  // ---------- demo maps ----------
  for (const MP of MAPS) {
    const R = rng(S.seed * 101 + MP.name.charCodeAt(0));
    const W = MP.w * T + 2 * M, H = MP.h * T + 2 * M;
    const at = (x, y) => [M + x * T + T / 2, M + y * T + T / 2];
    const cellsOf = (pred) => {
      const out = [];
      for (let y = 0; y < MP.h; y++) for (let x = 0; x < MP.w; x++) if (pred(MP.terrain[y][x], x, y)) out.push([x, y]);
      return out;
    };
    const land = cellsOf((c) => isLand(c));
    // lakes: water cells the open sea cannot reach (flood fill from the map edge)
    const sea = new Set(); const stack = [];
    for (let x = 0; x < MP.w; x++) { stack.push([x, 0], [x, MP.h - 1]); }
    for (let y = 0; y < MP.h; y++) { stack.push([0, y], [MP.w - 1, y]); }
    while (stack.length) {
      const [x, y] = stack.pop(); const k = x + "," + y;
      if (x < 0 || y < 0 || x >= MP.w || y >= MP.h || sea.has(k) || isLand(MP.terrain[y][x])) continue;
      sea.add(k); stack.push([x + 1, y], [x - 1, y], [x, y + 1], [x, y - 1]);
    }
    const isLake = (c, x, y) => !isLand(c) && !sea.has(x + "," + y);
    const nearDeep = (x, y) => !isLake(MP.terrain[y][x], x, y);
    const lake = cellsOf((c, x, y) => isLake(c, x, y));
    const nearDeep2 = (x, y) => nearDeep(x, y);
    const LF = makeField(MP, (c, x, y) => isLand(c) || isLake(c, x, y), T * 0.62, 6, S.seed);
    const coast = contours(LF, 0.5, M, M);
    const ring = (thr) => contours(LF, thr, M, M);

    const items = [];
    items.push(rect(0, 0, W, H, { fill: "paper" }));
    items.push(rect(0, 0, W, H, { fill: "paper", grain: { freq: 0.9, octaves: 3, seed: S.seed }, blend: "multiply", opacity: 0.22 }));
    items.push(rect(0, 0, W, H, { fill: rad([["#00000000", 0.55], ["#5a3a1a33", 1]], { cx: 0.5, cy: 0.5, r: 0.75 }) }));
    if (S.seals) {
      items.push(...Array.from({ length: Math.floor((H - 2 * M) / 7) }, (_, i) => line([M, M + i * 7, W - M, M + i * 7], { stroke: "sea", sw: 1, opacity: 0.9 })));
    } else {
      items.push(rect(M, M, W - 2 * M, H - 2 * M, { fill: "sea", opacity: S.wash ? 0.55 : 0.3 }));
    }
    if (S.rhumb) {
      for (const [hx, hy] of [[W * 0.18, H * 0.82], [W * 0.84, H * 0.2]]) {
        for (let k = 0; k < 16; k++) { const ang = k * Math.PI / 8 + 0.013;
          const dx = Math.cos(ang), dy = Math.sin(ang);
          const t = Math.min(dx > 0 ? (W - 4 - hx) / dx : (4 - hx) / dx, dy > 0 ? (H - 4 - hy) / dy : (4 - hy) / dy);
          items.push(line([hx, hy, hx + dx * t, hy + dy * t], { stroke: k % 2 ? "#6e523659" : "#8a2e1e59", sw: 0.5 })); }
        items.push(circle(hx, hy, 3, { fill: "acc", opacity: 0.6 }));
      }
    }
    // coastal ripple lines, then the land with an inked coast
    for (const thr of (S.engraved ? [0.03, 0.06, 0.1, 0.14, 0.19, 0.25, 0.32, 0.4] : [0.07, 0.16, 0.3])) for (const lp of ring(thr)) items.push(blob(lp, { fill: "none", stroke: "inkL", sw: 0.7, opacity: 0.55, smooth: 0.8 }));
    for (const lp of coast) items.push(blob(lp, { fill: "land", ink: { c: "ink", w: 2, wobble: 0.6 }, smooth: 0.8 }));
    // biome washes (coloured set) or faint tints
    if (S.wash) {
      for (const [x, y] of land) {
        const c = MP.terrain[y][x]; const [cx, cy] = at(x, y);
        if (WASH[c]) items.push(circle(cx, cy, T * 0.8, { fill: WASH[c], opacity: 0.75, blur: 7 }));
      }
    }
    // lakes
    if (lake.length) {
      const LK = makeField(MP, (c, x, y) => isLake(c, x, y), T * 0.62, 6, S.seed + 5);
      for (const lp of contours(LK, 0.45, M, M)) items.push(blob(lp, { fill: "sea", ink: { c: "ink", w: 1.4, wobble: 0.5 }, smooth: 0.8 }));
    }
    // rivers
    for (const path of MP.river_paths) {
      const pts = []; path.forEach(([x, y], i) => { const [cx, cy] = at(x, y); pts.push(cx + noise(i * 0.7, 3, S.seed) * 5, cy + noise(3, i * 0.7, S.seed) * 5); });
      items.push(curve(pts, { ink: { c: "ink", w: 2.6, taper: 0.15, wobble: 0.8 }, smooth: 0.8 }));
      items.push(curve(pts, { stroke: "sea", sw: 1.2, opacity: 0.9, smooth: 0.8 }));
    }
    // symbols, drawn top to bottom so lower ones overlap
    const order = land.slice().sort((a, b) => a[1] - b[1] || a[0] - b[0]);
    for (const [x, y] of order) {
      const c = MP.terrain[y][x]; const [cx, cy] = at(x, y);
      const jx = (R() - 0.5) * 6, jy = (R() - 0.5) * 6;
      const st = (n, dx = 0, dy = 0, sc = 1) => items.push(stamp(p + n, cx + jx + dx, cy + jy + dy, { anchor: "center", scale: sc }));
      if (c === "m") st(R() < 0.35 ? "sym_peak" : "sym_mountain", 0, -4, 0.9 + R() * 0.3);
      else if (c === "v") st("sym_volcano", 0, -6, 1.1);
      else if (c === "h") st("sym_hill", 0, 0, 0.9 + R() * 0.3);
      else if (c === "f") { st(R() < 0.5 ? "sym_tree" : "sym_pine", -6, -3); st("sym_tree", 5, -1); st(R() < 0.5 ? "sym_pine" : "sym_tree", -1, 6); }
      else if (c === "j") { st("sym_palm", -5, -2); st("sym_palm", 5, 4, 0.9); }
      else if (c === "d") { st("sym_dune", 0, -2); if (R() < 0.5) st("sym_dune", 4, 6, 0.7); }
      else if (c === "s") { st("sym_reeds", -3, 0); if (R() < 0.6) st("sym_reeds", 5, 7, 0.8); }
      else if (c === "i") { if (R() < 0.45) st("sym_snow", 0, 0, 0.8); }
      else if (c === "t") { st("sym_tundra", 0, 0); }
    }
    // waves in open sea
    for (let i = 0; i < 26; i++) {
      const x = Math.floor(R() * MP.w), y = Math.floor(R() * MP.h);
      if (MP.terrain[y][x] === "~") { const [cx, cy] = at(x, y); items.push(stamp(p + "sym_wave", cx, cy, { anchor: "center" })); }
    }
    // sect territories: land within reach of each sect seat, nearest seat wins
    if (S.territories) {
      const sects = MP.places.filter((q) => q.kind === "sect" || q.kind === "city");
      const COL = ["#a8322a", "#2f5aa8", "#3a8a3a", "#8a3aa0"];
      sects.forEach((sc, si) => {
        const own = (c, x, y) => isLand(c) && Math.max(Math.abs(x - sc.x), Math.abs(y - sc.y)) <= 6 &&
          sects.every((o) => Math.hypot(x - o.x, y - o.y) >= Math.hypot(x - sc.x, y - sc.y) - 0.01);
        const TF = makeField(MP, own, T * 0.55, 6, S.seed + si);
        for (const lp of contours(TF, 0.55, M, M)) {
          items.push(blob(lp, { fill: COL[si % 4], opacity: 0.12, smooth: 0.8 }));
          items.push(blob(lp, { fill: "none", stroke: COL[si % 4], sw: 1.6, dash: [1, 3.5], opacity: 0.9, smooth: 0.8 }));
        }
      });
      const lx = M + 10, ly = H - M - 18 - sects.length * 14;
      items.push(rect(lx - 4, ly - 14, 170, sects.length * 14 + 20, { fill: "paper", ink: { c: "ink", w: 1, wobble: 0.4 } }));
      items.push(text(lx + 2, ly - 2, "Lãnh thổ (territories)", { size: 9, font: S.font, fill: "ink", weight: "bold" }));
      sects.forEach((sc, si) => { items.push(rect(lx + 2, ly + 6 + si * 14, 10, 7, { fill: COL[si % 4], opacity: 0.8 }));
        items.push(text(lx + 18, ly + 12 + si * 14, sc.name, { size: 8, font: S.font, fill: "ink" })); });
    }
    if (S.regions) for (const r of MP.regions) {
      const [cx, cy] = at(r.x, r.y); const str = r.name.toUpperCase().split("").join(" "); const L = str.length * 3.2;
      items.push(text(0, 0, str, { size: 8.5, font: S.font, fill: "inkL", anchor: "middle", along: [cx - L, cy + 3, cx, cy - 3, cx + L, cy + 3], offset: 0.5 }));
    }
    if (S.boats) {
      let n = 0;
      for (let i = 0; i < 60 && n < 3; i++) { const x = Math.floor(R() * MP.w), y = Math.floor(R() * MP.h);
        if (MP.terrain[y][x] === "~" && x > 1 && y > 1 && x < MP.w - 2) { const [cx, cy] = at(x, y);
          items.push(stamp(p + "boat", cx, cy, R() < 0.5 ? { anchor: "center", flip: "x" } : { anchor: "center" })); n++; } }
    }
    // roads
    for (const path of MP.road_paths) {
      const pts = []; path.forEach(([x, y], i) => { const [cx, cy] = at(x, y); pts.push(cx + noise(i * 0.6, 9, S.seed) * 3, cy + noise(9, i * 0.6, S.seed) * 3); });
      items.push(curve(pts, { stroke: "road", sw: 1.6, dash: [5, 3], smooth: 0.7 }));
    }
    // places and labels
    for (const pl of MP.places) {
      const [cx, cy] = at(pl.x, pl.y);
      items.push(stamp(p + "ico_" + pl.kind, cx, cy, { anchor: "center", scale: pl.kind === "city" ? 1.15 : 0.95 }));
      if (S.seals && (pl.kind === "sect" || pl.kind === "city" || pl.kind === "blessed")) items.push(stamp(p + "seal", cx + 13, cy - 13, { anchor: "center", scale: 0.55 }));
      const big = pl.kind === "city" || pl.kind === "sect";
      const lab = { size: big ? 10 : 8, font: S.font, anchor: "middle", weight: big ? "bold" : "normal" };
      items.push(text(cx, cy + 22, pl.name, { ...lab, fill: "paper", stroke: "paper", sw: 3, opacity: 0.85 }));
      items.push(text(cx, cy + 22, pl.name, { ...lab, fill: "ink" }));
    }
    // title cartouche, compass and border
    items.push(rect(M + 8, M + 6, 210, 30, { fill: "paper", ink: { c: "ink", w: 1.4, wobble: 0.6 } }));
    items.push(text(M + 113, M + 26, MP.title, { size: 12, font: S.font, anchor: "middle", fill: "ink", weight: "bold" }));
    items.push(stamp(p + "compass", W - M - 46, H - M - 46, { anchor: "center", scale: 0.9 }));
    items.push(rect(M - 10, M - 10, W - 2 * M + 20, H - 2 * M + 20, { fill: "none", stroke: "ink", sw: 2.2 }));
    items.push(rect(M - 5, M - 5, W - 2 * M + 10, H - 2 * M + 10, { fill: "none", stroke: "ink", sw: 0.8 }));
    if (S.rhumb) for (const [ox, oy] of [[M - 10, M - 10], [W - M + 10, M - 10], [M - 10, H - M + 10], [W - M + 10, H - M + 10]])
      items.push(star(ox, oy, 4, 9, 3, { fill: "acc", stroke: "ink", sw: 0.8 }));
    scene(p + "map_" + MP.name, { w: W, h: H }, ...items);
  }
}
