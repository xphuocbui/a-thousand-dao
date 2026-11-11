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


