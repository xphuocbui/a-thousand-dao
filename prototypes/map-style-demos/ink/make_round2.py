"""Builds body2.js (ink-wash round 2) from body.js: new sets and new map features."""
s = open('body.js', encoding='utf-8').read()

a = s.index('const SETS = ['); b = s.index('];', a) + 2
s = s[:a] + '''const SETS = [
  { id: "k4", seed: 17, name: "Scroll", vertical: true, boats: true, regions: true,
    paper: "#ece2cc", ink: "#201c18", grey: "#706a60", mist: "#f4ecdc", seal: "#a8281c", sealInk: "#f4ecdc",
    wash: null, font: "Palatino Linotype" },
  { id: "k5", seed: 18, name: "Gold on night paper", regions: true, boats: true,
    paper: "#191c26", ink: "#e2cf9c", grey: "#9a8f74", mist: "#262a38", seal: "#c03a2a", sealInk: "#e2cf9c",
    wash: null, font: "Cambria", landOp: 0.85 },
  { id: "k6", seed: 19, name: "Splashed ink", pomo: true, regions: true,
    paper: "#efe6d0", ink: "#15140f", grey: "#5e5a52", mist: "#f5eedf", seal: "#b02a1c", sealInk: "#f5eedf",
    wash: { m: "#3f7f86", f: "#5a8a5a", j: "#4a7a4a", d: "#c89a5a", v: "#b8603a", s: "#6a8070" }, font: "Palatino Linotype" },
];''' + s[b:]

# a sampan
s = s.replace('  sheet(p + "symbols"', '''  sprite(p + "boat", { w: 28, h: 16 },
    curve([1, 9, 7, 13, 21, 13, 27, 8], { fill: "ink", opacity: 0.85 }),
    curve([8, 9, 12, 5, 18, 5, 21, 9], { fill: "none", ink: { c: "ink", w: 1.2, taper: 0.4 } }),
    line([16, 9, 16, 3], { stroke: "ink", sw: 0.8 }), poly([13, 3.5, 16, 1, 19, 3.5], { fill: "ink" }),
    line([22, 9, 27, 1], { stroke: "ink", sw: 0.6 }),
    curve([0, 14, 8, 15, 20, 15, 28, 14], { ink: { c: "grey", w: 0.7, taper: 0.6, dry: 0.5 } }));
  sheet(p + "symbols"''', 1)

# splashed ink washes and region names, before the lakes
s = s.replace('    // lakes and rivers\n', '''    if (S.pomo) for (const [x, y] of land) { const c = MP.terrain[y][x]; const [cx, cy] = at(x, y);
      if (c === "m" || c === "v") items.push(circle(cx + (R() - 0.5) * 10, cy + (R() - 0.5) * 8, T * (0.7 + R() * 0.5), { fill: "ink", opacity: 0.16, blur: 7 }));
      if (c === "f" || c === "j") items.push(circle(cx, cy, T * 0.7, { fill: "ink", opacity: 0.09, blur: 6 })); }
    // lakes and rivers
''', 1)

# boats and region names after the open-sea waves
s = s.replace('    // roads: a faint dotted brush trail\n', '''    if (S.boats) { let n = 0;
      for (let i = 0; i < 80 && n < 3; i++) { const x = Math.floor(R() * MP.w), y = Math.floor(R() * MP.h);
        if (MP.terrain[y][x] === "~" && x > 1 && y > 1 && x < MP.w - 3) { const [cx, cy] = at(x, y);
          items.push(stamp(p + "boat", cx, cy, R() < 0.5 ? { anchor: "center", flip: "x" } : { anchor: "center" })); n++; } } }
    if (S.regions) for (const r of MP.regions) { const [cx, cy] = at(r.x, r.y);
      if (S.vertical) r.name.split(" ").forEach((w, i, arr) => items.push(text(cx, cy - (arr.length - 1) * 8 + i * 16, w, { size: 15, font: S.font, anchor: "middle", fill: "ink", opacity: 0.22, weight: "bold" })));
      else items.push(text(cx, cy + 4, r.name, { size: 15, font: S.font, anchor: "middle", fill: "ink", opacity: 0.2, weight: "bold" })); }
    // roads: a faint dotted brush trail
''', 1)

# vertical stacked place names on the scroll set
old = '''      items.push(text(cx, cy + 24, pl.name, { ...lab, fill: "paper", stroke: "paper", sw: 3, opacity: 0.9 }));
      items.push(text(cx, cy + 24, pl.name, { ...lab, fill: "ink" }));'''
new = '''      if (S.vertical) {
        const words = pl.name.split(" ");
        words.forEach((w, i) => { items.push(text(cx + 17, cy - 6 + i * 10, w, { ...lab, anchor: "start", fill: "paper", stroke: "paper", sw: 3, opacity: 0.9 }));
          items.push(text(cx + 17, cy - 6 + i * 10, w, { ...lab, anchor: "start", fill: "ink" })); });
      } else {
        items.push(text(cx, cy + 24, pl.name, { ...lab, fill: "paper", stroke: "paper", sw: 3, opacity: 0.9 }));
        items.push(text(cx, cy + 24, pl.name, { ...lab, fill: "ink" }));
      }'''
assert old in s
s = s.replace(old, new, 1)
s = s.replace('// Ink-wash (thủy mặc) map style demo: three seeded sets, a symbol sheet and a demo map per set.',
              '// Ink-wash (thủy mặc) map style demo, round 2: scroll with vertical names and boats (k4), gold on night paper (k5), splashed ink (k6).')
open('body2.js', 'w', encoding='utf-8', newline='\n').write(s)
g = open('gen.py', encoding='utf-8').read().replace("'body.js'", "'body2.js'").replace("'ink_sets.vx.js'", "'ink_sets2.vx.js'")
open('gen2.py', 'w', encoding='utf-8', newline='\n').write(g)
print('ok')
