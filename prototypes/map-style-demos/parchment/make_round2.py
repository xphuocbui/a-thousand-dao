"""Builds body2.js (parchment round 2) from body.js: new sets and new map features."""
s = open('body.js', encoding='utf-8').read()

a = s.index('const SETS = ['); b = s.index('];', a) + 2
s = s[:a] + '''const SETS = [
  { id: "c4", seed: 44, name: "Explorer's chart", rhumb: true, boats: true, regions: true,
    paper: "#ead9b0", paperD: "#d5bd8c", ink: "#3d2a1a", inkL: "#6e5236", sea: "#d6c49a", land: "#eddcb4",
    road: "#7a3a22", wash: false, accent: "#8a2e1e", font: "Cambria", sealFill: "#8a2e1e" },
  { id: "c5", seed: 55, name: "Territory atlas", territories: true, regions: true,
    paper: "#f1e5c8", paperD: "#dcc79c", ink: "#33281c", inkL: "#665238", sea: "#9fc0c4", land: "#ebdfb8",
    road: "#7a5a3a", wash: true, accent: "#8a2a1e", font: "Constantia", sealFill: "#8a2a1e" },
  { id: "c6", seed: 66, name: "Engraved", engraved: true, regions: true,
    paper: "#f3ecda", paperD: "#e0d4b8", ink: "#141414", inkL: "#3a3a3a", sea: "#f3ecda", land: "#f7f1e2",
    road: "#141414", wash: false, accent: "#141414", font: "Palatino Linotype", sealFill: "#141414" },
];''' + s[b:]

# engraved: hatch the shadow faces of mountains
s = s.replace('poly([15, 3, 28, 24, 17, 24, 18, 15], { fill: "paperD", opacity: 0.9 }),',
              'poly([15, 3, 28, 24, 17, 24, 18, 15], S.engraved ? { fill: "land", hatch: { c: "ink", gap: 1.8, angle: 70, opacity: 0.8 } } : { fill: "paperD", opacity: 0.9 }),')
s = s.replace('poly([17, 2, 32, 28, 19, 28, 21, 16], { fill: "paperD", opacity: 0.9 }),',
              'poly([17, 2, 32, 28, 19, 28, 21, 16], S.engraved ? { fill: "land", hatch: { c: "ink", gap: 1.8, angle: 70, opacity: 0.8 } } : { fill: "paperD", opacity: 0.9 }),')

# a junk boat sprite
s = s.replace('  sheet(p + "symbols"', '''  sprite(p + "boat", { w: 30, h: 26 },
    curve([2, 18, 8, 23, 22, 23, 28, 17], { fill: "land", ink: { c: "ink", w: 1.3, wobble: 0.4 } }),
    line([2, 18, 28, 17], { stroke: "ink", sw: 1 }),
    line([14, 18, 14, 2], { stroke: "ink", sw: 1 }),
    poly([15, 3, 25, 6, 23, 16, 15, 16], { fill: "paperD", ink: { c: "ink", w: 1, wobble: 0.4 } }),
    (f) => [6, 9, 12].map((y) => line([15, y, 24.5, y + 1], { stroke: "inkL", sw: 0.6 })),
    poly([13, 6, 6, 9, 7, 16, 13, 16], { fill: "paperD", ink: { c: "ink", w: 1, wobble: 0.4 } }),
    curve([0, 24, 8, 25, 22, 25, 30, 24], { stroke: "inkL", sw: 0.6, opacity: 0.6 }));
  sheet(p + "symbols"''', 1)

# rhumb lines over the sea, before the coast ripples
s = s.replace('    // coastal ripple lines, then the land with an inked coast', '''    if (S.rhumb) {
      for (const [hx, hy] of [[W * 0.18, H * 0.82], [W * 0.84, H * 0.2]]) {
        for (let k = 0; k < 16; k++) { const ang = k * Math.PI / 8 + 0.013;
          const dx = Math.cos(ang), dy = Math.sin(ang);
          const t = Math.min(dx > 0 ? (W - 4 - hx) / dx : (4 - hx) / dx, dy > 0 ? (H - 4 - hy) / dy : (4 - hy) / dy);
          items.push(line([hx, hy, hx + dx * t, hy + dy * t], { stroke: k % 2 ? "#6e523659" : "#8a2e1e59", sw: 0.5 })); }
        items.push(circle(hx, hy, 3, { fill: "acc", opacity: 0.6 }));
      }
    }
    // coastal ripple lines, then the land with an inked coast''', 1)
s = s.replace('    for (const thr of [0.07, 0.16, 0.3]) for (const lp of ring(thr))',
              '    for (const thr of (S.engraved ? [0.03, 0.06, 0.1, 0.14, 0.19, 0.25, 0.32, 0.4] : [0.07, 0.16, 0.3])) for (const lp of ring(thr))')

# territories, region labels and boats, before roads
s = s.replace('    // roads\n', '''    // sect territories: land within reach of each sect seat, nearest seat wins
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
      const [cx, cy] = at(r.x, r.y); const str = r.name.toUpperCase().split("").join("\u00a0"); const L = str.length * 3.2;
      items.push(text(0, 0, str, { size: 8.5, font: S.font, fill: "inkL", anchor: "middle", along: [cx - L, cy + 3, cx, cy - 3, cx + L, cy + 3], offset: 0.5 }));
    }
    if (S.boats) {
      let n = 0;
      for (let i = 0; i < 60 && n < 3; i++) { const x = Math.floor(R() * MP.w), y = Math.floor(R() * MP.h);
        if (MP.terrain[y][x] === "~" && x > 1 && y > 1 && x < MP.w - 2) { const [cx, cy] = at(x, y);
          items.push(stamp(p + "boat", cx, cy, R() < 0.5 ? { anchor: "center", flip: "x" } : { anchor: "center" })); n++; } }
    }
    // roads
''', 1)
# corner ornaments for the explorer's chart border
s = s.replace('    scene(p + "map_" + MP.name, { w: W, h: H }, ...items);', '''    if (S.rhumb) for (const [ox, oy] of [[M - 10, M - 10], [W - M + 10, M - 10], [M - 10, H - M + 10], [W - M + 10, H - M + 10]])
      items.push(star(ox, oy, 4, 9, 3, { fill: "acc", stroke: "ink", sw: 0.8 }));
    scene(p + "map_" + MP.name, { w: W, h: H }, ...items);''', 1)
s = s.replace('// Painted-parchment map style demo: three seeded sets, a symbol sheet and a demo map per set.',
              '// Painted-parchment map style demo, round 2: rhumb lines and boats (c4), sect territories (c5), engraved relief (c6).')
open('body2.js', 'w', encoding='utf-8', newline='\n').write(s)
g = open('gen.py', encoding='utf-8').read().replace("'body.js'", "'body2.js'").replace("'parchment_sets.vx.js'", "'parchment_sets2.vx.js'")
open('gen2.py', 'w', encoding='utf-8', newline='\n').write(g)
print('ok')
