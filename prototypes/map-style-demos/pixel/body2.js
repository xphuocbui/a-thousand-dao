// Pixel-art map style demo, round 2: glyph tiles (p4) and foam shorelines with labels (p5, p6).
// MAPS is injected above by gen.py from ../maps/maps.json.

const SETS = [
  { id: "p4", seed: 404, name: "Glyph (DF / Qud-like)", glyph: true,
    k: "#0b0b0f", grass: "#4fd16b", forest: "#2fae4a", jungle: "#8be04a", sand: "#e8c86a", swamp: "#6aa06a",
    rock: "#b0b0c0", snow: "#f0f6ff", lava: "#ff5a2a", shallow: "#3aa0ff", deep: "#2050c0", wood: "#c08040",
    roof: "#ff4060", gold: "#ffd040", magic: "#d070ff", dirt: "#a08060" },
  { id: "p5", seed: 505, name: "Warm cultivation", shore: true,
    k: "#24180f", grass: "#8db35a", forest: "#4f8a3a", jungle: "#3f9a4a", sand: "#e2c48a", swamp: "#6f7a4a",
    rock: "#9a8f86", snow: "#f2efe6", lava: "#f0602a", shallow: "#5fb0c8", deep: "#2f6a96", wood: "#8a5a34",
    roof: "#b8402e", gold: "#f0c04a", magic: "#c070d0", dirt: "#c49a62" },
  { id: "p6", seed: 606, name: "Winter night", shore: true,
    k: "#0a0e1a", grass: "#5a7a8a", forest: "#2f4a5a", jungle: "#35605a", sand: "#a8a8b8", swamp: "#3a4a52",
    rock: "#6a7088", snow: "#dfe8f6", lava: "#ff7040", shallow: "#3a6a9a", deep: "#16284a", wood: "#4a3a3a",
    roof: "#8a3048", gold: "#f6d070", magic: "#90c0ff", dirt: "#7a7a8a" },
];

const T = 16;

for (const S of SETS) {
  const p = S.id + "_";
  const SEED = S.seed;
  pal({ k: S.k });
  shades("qrs", S.grass, { spread: 0.42 });   // grass dark -> light
  shades("FGH", S.forest, { spread: 0.42 });
  shades("JKL", S.jungle, { spread: 0.42 });
  shades("tuv", S.sand, { spread: 0.26 });
  shades("MNO", S.swamp, { spread: 0.42 });
  shades("RST", S.rock, { spread: 0.42 });
  shades("wxy", S.snow, { spread: 0.3 });
  shades("lmn", S.lava, { spread: 0.42 });
  shades("BCD", S.shallow, { spread: 0.42 });
  shades("PQZ", S.deep, { spread: 0.42 });
  shades("WXY", S.wood, { spread: 0.42 });
  shades("AE", S.roof, { spread: 0.42 });
  shades("UV", S.gold, { spread: 0.42 });
  shades("pz", S.magic, { spread: 0.42 });
  shades("cde", S.dirt, { spread: 0.42 });

  // ---- brush parts ----
  sprite(p + "_tuft1", "q.q\n.q.");
  sprite(p + "_tuft2", ".s.\nsrs");
  sprite(p + "_tuft3", "q");
  sprite(p + "_wave1", "Q.Q\n.Q.");
  sprite(p + "_wave2", "PPP");
  sprite(p + "_ripple", "DDD");
  sprite(p + "_pebble", "u");
  sprite(p + "_frond1", ".L.\nLKL\n.K.");
  sprite(p + "_frond2", "K.K\n.J.\nK.K");
  sprite(p + "_reed", "O\nO\nN");
  sprite(p + "_spark", "y");
  sprite(p + "_tun", "S.S");

  // a round tree crown, lit from the top-left
  sprite(p + "_tree", { w: 7, h: 7, outline: "k" }, (c) => {
    c.circ(3, 3, 3, "G");
    c.px(4, 4, "F"); c.px(5, 3, "F"); c.px(3, 5, "F"); c.px(5, 4, "F"); c.px(4, 5, "F");
    c.px(2, 1, "H"); c.px(1, 2, "H"); c.px(2, 2, "H");
  });
  sprite(p + "_bush", { w: 6, h: 5, outline: "k" }, ellipse(3, 2, 3, 2, "K"), px(2, 1, "L"), px(1, 2, "L"), hline(2, 4, 3, "J"));
  sprite(p + "_palm", { w: 7, h: 7, outline: "k" }, (c) => {
    c.line(3, 6, 3, 3, "W");
    c.line(0, 2, 3, 3, "K"); c.line(6, 2, 3, 3, "K"); c.line(1, 0, 3, 3, "L"); c.line(5, 0, 3, 3, "L");
  });

  if (!S.glyph) {
  // ---- terrain tiles ----
  sprite(p + "t_grass", { w: T, h: T }, rect(0, 0, T, T, "r"),
    scatter(p + "_tuft*", 0, 0, T, T, 5, { seed: SEED }));
  sprite(p + "t_hills", { w: T, h: T }, rect(0, 0, T, T, "r"),
    ellipse(5, 10, 5, 3, "s"), ellipse(6, 11, 5, 3, "r"), hline(1, 13, 10, "q"),
    ellipse(11, 5, 4, 2, "s"), ellipse(12, 6, 4, 2, "r"), hline(8, 7, 8, "q"));
  sprite(p + "t_forest", { w: T, h: T }, rect(0, 0, T, T, "q"), (c) => {
    const r = c.rng(SEED);
    const spots = [[0, 0], [8, 1], [3, 7], [10, 8], [-1, 11], [6, 12]];
    for (const [x, y] of spots) c.stamp(p + "_tree", x + Math.floor(r() * 2), y + Math.floor(r() * 2));
  });
  sprite(p + "t_jungle", { w: T, h: T }, rect(0, 0, T, T, "J"), (c) => {
    const r = c.rng(SEED);
    const spots = [[-1, -1], [6, 0], [11, 2], [1, 6], [8, 7], [-1, 11], [4, 11], [10, 11]];
    for (const [x, y] of spots) c.stamp(p + (r() < 0.6 ? "_palm" : "_bush"), x + Math.floor(r() * 2), y + Math.floor(r() * 2));
  });
  sprite(p + "t_desert", { w: T, h: T }, rect(0, 0, T, T, "u"), (c) => {
    const r = c.rng(SEED);
    const o = Math.floor(r() * 4);
    c.line(1, 5 + o, 7, 3 + o, "v"); c.line(7, 3 + o, 13, 6 + o, "t");
    c.line(3, 12, 8, 10, "v"); c.line(8, 10, 14, 13, "t");
  });
  sprite(p + "t_beach", { w: T, h: T }, rect(0, 0, T, T, "v"),
    scatter(p + "_pebble", 0, 0, T, T, 2, { seed: SEED }));
  sprite(p + "t_swamp", { w: T, h: T }, rect(0, 0, T, T, "N"),
    ellipse(5, 5, 3, 2, "B"), ellipse(11, 11, 4, 2, "B"), px(4, 4, "C"), px(10, 10, "C"),
    scatter(p + "_reed", 0, 0, T, T, 5, { seed: SEED, on: "N" }));
  sprite(p + "t_mountain_a", { w: T, h: T }, rect(0, 0, T, T, "q"),
    poly([0, 15, 8, 1, 16, 15], "R"), poly([0, 15, 8, 1, 8, 15], "S"),
    poly([5, 6, 8, 1, 11, 6, 9, 5, 8, 6, 7, 5], "y"), line(8, 2, 8, 14, "T"));
  sprite(p + "t_mountain_b", { w: T, h: T }, rect(0, 0, T, T, "q"),
    poly([0, 15, 5, 4, 10, 15], "R"), poly([0, 15, 5, 4, 5, 15], "S"),
    poly([6, 15, 11, 6, 16, 15], "R"), poly([6, 15, 11, 6, 11, 15], "S"),
    poly([3, 7, 5, 4, 7, 7, 5, 6], "y"), poly([10, 8, 11, 6, 12, 8], "y"));
  sprite(p + "t_mountain_c", { w: T, h: T }, rect(0, 0, T, T, "q"),
    poly([1, 15, 7, 5, 9, 6, 15, 15], "R"), poly([1, 15, 7, 5, 8, 6, 8, 15], "S"),
    line(7, 6, 5, 12, "T"), hline(2, 14, 12, "q"));
  group(p + "t_mountain", [p + "t_mountain_a", p + "t_mountain_a", p + "t_mountain_b", p + "t_mountain_c"]);
  sprite(p + "t_volcano", { w: T, h: T }, rect(0, 0, T, T, "R"),
    poly([0, 15, 6, 3, 10, 3, 16, 15], "R"), poly([0, 15, 6, 3, 8, 3, 8, 15], "S"),
    rect(6, 2, 4, 2, "m"), hline(7, 2, 2, "n"), line(8, 4, 6, 12, "l"), line(9, 4, 10, 9, "m"),
    noise(0, 13, 16, 3, "l", 0.15, SEED));
  sprite(p + "t_snow", { w: T, h: T }, rect(0, 0, T, T, "x"),
    line(2, 4, 6, 6, "w"), line(9, 11, 13, 9, "w"), scatter(p + "_spark", 0, 0, T, T, 4, { seed: SEED }));
  sprite(p + "t_tundra", { w: T, h: T }, rect(0, 0, T, T, "w"),
    scatter(p + "_tun", 0, 0, T, T, 6, { seed: SEED }), scatter(p + "_tuft3", 0, 0, T, T, 4, { seed: SEED + 2 }));
  sprite(p + "t_deep", { w: T, h: T }, rect(0, 0, T, T, "Q"),
    scatter(p + "_wave*", 0, 0, T, T, 3, { seed: SEED }));
  sprite(p + "t_shallow", { w: T, h: T }, rect(0, 0, T, T, "C"),
    scatter(p + "_ripple", 0, 0, T, T, 3, { seed: SEED }));

  } else {
  // ---- glyph terrain tiles (one or two hand-drawn glyphs on black) ----
  sprite(p + "_g_grass", "s.s\ns.s"); sprite(p + "_g_comma", ".r\nr.");
  sprite(p + "_g_tree", ".GGG.\nGGGGG\nGGGGG\n.GGG.\n..W..");
  sprite(p + "_g_pine", "..F..\n.FFF.\nFFFFF\n..W..");
  sprite(p + "_g_palm", "LLLLL\nL.L.L\n..W..\n..W..");
  sprite(p + "_g_mtn", "...T...\n..T.R..\n.T...R.\nT.....R");
  sprite(p + "_g_peak", "...y...\n..yTR..\n.TTTRR.\nTTTTRRR");
  sprite(p + "_g_hill", ".sss.\ns...s");
  sprite(p + "_g_wave", ".CC..C\nC..CC.");
  sprite(p + "_g_deep", ".Z..Z\nZ.ZZ.");
  sprite(p + "_g_dune", ".vvv.\nv...v"); sprite(p + "_g_dot", "u");
  sprite(p + "_g_reed", "O.O\nO.O\nN.N");
  sprite(p + "_g_snow", "y.y\n.y.\ny.y"); sprite(p + "_g_tun", "x.x");
  sprite(p + "_g_volc", "..lnl..\n..R.R..\n.R...R.\nR.....R");
  pal({ 0: "#081a3a", 1: "#0c2c50", 2: "#10281a", 3: "#08200e", 4: "#0e2c12", 5: "#2c2410", 6: "#16220f", 7: "#1c1c28", 8: "#24303e", 9: "#300e08" });
  const BGK = { t_grass: "2", t_hills: "2", t_forest: "3", t_jungle: "4", t_desert: "5", t_beach: "5", t_swamp: "6",
    t_volcano: "9", t_snow: "8", t_tundra: "8", t_deep: "0", t_shallow: "1" };
  const G = (name, ...parts) => sprite(p + name, { w: T, h: T }, rect(0, 0, T, T, BGK[name] || "k"), ...parts);
  G("t_grass", scatter(p + "_g_grass", 2, 2, 12, 12, 2, { seed: SEED }), scatter(p + "_g_comma", 2, 2, 12, 12, 1, { seed: SEED + 1 }));
  G("t_hills", stamp(p + "_g_hill", 2, 4), stamp(p + "_g_hill", 9, 10));
  G("t_forest", stamp(p + "_g_tree", 1, 1), stamp(p + "_g_pine", 9, 3), stamp(p + "_g_tree", 5, 9));
  G("t_jungle", stamp(p + "_g_palm", 1, 2), stamp(p + "_g_palm", 9, 7), stamp(p + "_g_tree", 2, 10, { swap: { G: "K" } }));
  G("t_desert", stamp(p + "_g_dune", 3, 4), scatter(p + "_g_dot", 1, 1, 14, 14, 3, { seed: SEED }));
  G("t_beach", scatter(p + "_g_dot", 1, 1, 14, 14, 4, { seed: SEED, swap: { u: "v" } }));
  G("t_swamp", stamp(p + "_g_reed", 3, 3), stamp(p + "_g_wave", 7, 10, { swap: { C: "M" } }));
  sprite(p + "t_mountain_a", { w: T, h: T }, rect(0, 0, T, T, "7"), stamp(p + "_g_peak", 4, 5));
  sprite(p + "t_mountain_b", { w: T, h: T }, rect(0, 0, T, T, "7"), stamp(p + "_g_mtn", 1, 3), stamp(p + "_g_mtn", 8, 9));
  sprite(p + "t_mountain_c", { w: T, h: T }, rect(0, 0, T, T, "7"), stamp(p + "_g_mtn", 4, 6));
  group(p + "t_mountain", [p + "t_mountain_a", p + "t_mountain_b", p + "t_mountain_c"]);
  G("t_volcano", stamp(p + "_g_volc", 4, 5));
  G("t_snow", scatter(p + "_g_snow", 2, 2, 12, 12, 2, { seed: SEED }));
  G("t_tundra", scatter(p + "_g_tun", 2, 2, 12, 12, 3, { seed: SEED }));
  G("t_deep", stamp(p + "_g_deep", 5, 6));
  G("t_shallow", stamp(p + "_g_wave", 5, 6));
  }

  // ---- auto-tiled rivers and roads (mask N=1 E=2 S=4 W=8; 16 = lone) ----
  for (let m = 1; m <= 16; m++) {
    const arms = (c, w, col, edge) => {
      const a = (T - w) / 2;
      c.rect(a, a, w, w, col);
      if (m & 1) c.rect(a, 0, w, a, col);
      if (m & 2) c.rect(a + w, a, T - a - w, w, col);
      if (m & 4) c.rect(a, a + w, w, T - a - w, col);
      if (m & 8) c.rect(0, a, a, w, col);
      if (edge) {
        if (m & 1) { c.vline(a - 1, 0, a, edge); c.vline(a + w, 0, a, edge); }
        if (m & 4) { c.vline(a - 1, a + w, T - a - w, edge); c.vline(a + w, a + w, T - a - w, edge); }
        if (m & 2) { c.hline(a + w, a - 1, T - a - w, edge); c.hline(a + w, a + w, T - a - w, edge); }
        if (m & 8) { c.hline(0, a - 1, a, edge); c.hline(0, a + w, a, edge); }
      }
    };
    sprite(p + "river_" + m, { w: T, h: T }, (c) => { arms(c, 6, "C", "B"); }, (c) => {
      if (m & 1 || m & 4) c.vline(7, 2, 3, "D");
      if (m & 2 || m & 8) c.hline(2, 8, 3, "D");
    });
    sprite(p + "road_" + m, { w: T, h: T }, (c) => { arms(c, 4, "d", "c"); }, (c) => {
      if (m & 1 || m & 4) { c.px(7, 3, "e"); c.px(8, 11, "e"); }
      if (m & 2 || m & 8) { c.px(3, 8, "e"); c.px(11, 7, "e"); }
    });
  }

  // ---- shore foam on water tiles next to land (mask N=1 E=2 S=4 W=8) ----
  for (let m = 1; m <= 15; m++) sprite(p + "shore_" + m, { w: T, h: T }, (c) => {
    if (m & 1) { c.hline(0, 0, T, "y"); c.hline(0, 1, T, "D"); }
    if (m & 4) { c.hline(0, T - 1, T, "y"); c.hline(0, T - 2, T, "D"); }
    if (m & 8) { c.vline(0, 0, T, "y"); c.vline(1, 0, T, "D"); }
    if (m & 2) { c.vline(T - 1, 0, T, "y"); c.vline(T - 2, 0, T, "D"); }
  });

  // ---- place icons (outlined, 16 -> 18 px) ----
  sprite(p + "i_city", { w: T, h: T, outline: "k" },
    rect(1, 6, 14, 9, "S"), rect(1, 6, 14, 1, "T"),
    (c) => { for (let x = 1; x < 15; x += 3) c.rect(x, 4, 2, 2, "S"); },
    rect(4, 8, 4, 3, "A"), rect(9, 8, 4, 3, "E"), hline(4, 8, 4, "E"),
    rect(6, 12, 4, 3, "k"), px(7, 12, "W"), px(8, 12, "W"));
  sprite(p + "i_town", { w: T, h: T, outline: "k" },
    rect(1, 9, 6, 5, "X"), poly([0, 9, 4, 5, 8, 9], "A"), rect(3, 11, 2, 3, "W"),
    rect(9, 7, 6, 7, "X"), poly([8, 7, 12, 2, 16, 7], "E"), poly([8, 7, 12, 2, 12, 7], "A"), rect(11, 10, 2, 4, "W"));
  sprite(p + "i_sect", { w: T, h: T, outline: "k" },
    rect(2, 13, 12, 2, "S"), rect(4, 9, 8, 4, "Y"), poly([1, 10, 8, 6, 15, 10], "U"),
    rect(5, 4, 6, 3, "Y"), poly([2, 5, 8, 1, 14, 5], "V"), px(8, 0, "U"), rect(7, 10, 2, 3, "W"));
  sprite(p + "i_mine", { w: T, h: T, outline: "k" },
    ellipse(8, 10, 7, 5, "S"), ellipse(7, 9, 5, 4, "T"), rect(5, 9, 6, 6, "k"),
    rect(4, 8, 1, 7, "W"), rect(11, 8, 1, 7, "W"), rect(4, 8, 8, 1, "X"), px(13, 13, "U"), px(14, 14, "V"));
  sprite(p + "i_abode", { w: T, h: T, outline: "k" },
    ellipse(8, 10, 7, 6, "R"), ellipse(7, 9, 5, 5, "S"), ellipse(8, 12, 3, 4, "k"),
    rect(6, 11, 4, 4, "W"), px(9, 13, "U"), px(12, 8, "U"), px(12, 9, "V"));
  sprite(p + "i_ruin", { w: T, h: T, outline: "k" },
    rect(2, 6, 3, 9, "S"), rect(2, 6, 1, 9, "T"), rect(11, 9, 3, 6, "S"), rect(11, 9, 1, 6, "T"),
    rect(6, 12, 4, 3, "R"), rect(1, 4, 5, 2, "S"), px(7, 8, "p"), px(8, 7, "z"), px(9, 9, "p"));
  sprite(p + "i_blessed", { w: T, h: T, outline: "k" },
    rect(7, 9, 2, 6, "W"), circ(8, 6, 5, "G"), circ(7, 5, 3, "H"),
    px(3, 3, "U"), px(13, 4, "U"), px(5, 1, "V"), px(11, 2, "V"), px(8, 6, "V"));
  sprite(p + "i_vein", { w: T, h: T, outline: "k" },
    poly([3, 15, 5, 6, 7, 15], "p"), poly([7, 15, 9, 3, 11, 15], "z"), poly([10, 15, 12, 8, 14, 15], "p"),
    line(9, 4, 9, 13, "D"), px(5, 8, "D"));
  sprite(p + "_bg_glow", { w: 18, h: 18 }, circ(9, 9, 8, "y"));

  const TER = { "~": "t_deep", w: "t_shallow", b: "t_beach", g: "t_grass", f: "t_forest", j: "t_jungle",
    d: "t_desert", s: "t_swamp", h: "t_hills", m: "t_mountain", v: "t_volcano", i: "t_snow", t: "t_tundra" };
  const map = {};
  for (const [ch, name] of Object.entries(TER)) map[ch === "~" ? "o" : ch] = p + name;

  sheet(p + "tiles", Object.values(TER).map((n) => p + (n === "t_mountain" ? "t_mountain_a" : n)).concat([p + "t_mountain_b", p + "t_mountain_c"]), { cols: 15, pad: 2 });
  sheet(p + "icons", ["city", "town", "sect", "mine", "abode", "ruin", "blessed", "vein"].map((n) => p + "i_" + n), { cols: 8, pad: 2 });

  for (const M of MAPS) {
    const grid = M.terrain.map((r) => r.replace(/~/g, "o")).join("\n");
    scene(p + "map_" + M.name, { w: M.w * T, h: M.h * T, bg: "P" },
      layer("terrain", tilemap(grid, { map, size: T, reseed: true, seed: SEED })),
      ...(S.shore ? [layer("shore", (c) => {
        const L = (x, y) => y >= 0 && y < M.h && x >= 0 && x < M.w && !"~w".includes(M.terrain[y][x]);
        for (let y = 0; y < M.h; y++) for (let x = 0; x < M.w; x++) {
          if (!"~w".includes(M.terrain[y][x])) continue;
          const m = (L(x, y - 1) ? 1 : 0) | (L(x + 1, y) ? 2 : 0) | (L(x, y + 1) ? 4 : 0) | (L(x - 1, y) ? 8 : 0);
          if (m) c.stamp(p + "shore_" + m, x * T, y * T);
        }
      })] : []),
      layer("rivers", (c) => {
        for (let y = 0; y < M.h; y++) for (let x = 0; x < M.w; x++) {
          const m = M.river[y][x];
          if (m) c.stamp(p + "river_" + m, x * T, y * T);
        }
      }),
      layer("roads", (c) => {
        for (let y = 0; y < M.h; y++) for (let x = 0; x < M.w; x++) {
          const m = M.road[y][x];
          if (m) c.stamp(p + "road_" + m, x * T, y * T);
        }
      }),
      layer("glow", { light: true, density: 0.5 }, (c) => {
        for (const pl of M.places) if (pl.kind === "blessed" || pl.kind === "vein") c.circ(pl.x * T + 8, pl.y * T + 8, 12, "y");
      }),
      layer("places", (c) => {
        for (const pl of M.places) c.stamp(p + "i_" + pl.kind, pl.x * T - 1, pl.y * T - 1);
      }),
      layer("shadow", { shade: true, density: 0.5 }, (c) => {
        for (const pl of M.places) c.hline(pl.x * T + 1, pl.y * T + 16, 15, "k");
      }),
      layer("labels", (c) => {
        const up = (n) => n.normalize("NFD").replace(/[̀-ͯ]/g, "").replace(/đ/g, "d").replace(/Đ/g, "D").toUpperCase();
        for (const r of M.regions) c.text(Math.round(r.x * T + 8), Math.round(r.y * T), up(r.name), S.glyph ? "u" : (S.id === "p6" ? "x" : "k"), S.id === "p6" ? { align: "c", shadow: "k" } : { align: "c" });
        for (const pl of M.places) if (pl.kind === "city" || pl.kind === "sect")
          c.text(pl.x * T + 8, pl.y * T + 19, up(pl.name), "y", { align: "c", shadow: "k" });
      }));
  }
}
