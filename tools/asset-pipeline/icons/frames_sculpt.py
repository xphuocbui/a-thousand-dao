"""Sculpted round frames for the Đạo Đồ nodes (art bible §7.9): a height map per frame kind, lit from the top-left.

Each frame is built as heights (beads, bevelled bands, studs, a twisted rope, trigram bars, jade petals) and a
material per pixel (bronze, jade, enamel). Normals come from the height gradient; the colour is diffuse plus a warm
specular highlight, darkened in the recesses (a cheap ambient occlusion) and with a fine brushed grain. The enamel
groove next to the painting is the land tint (coloured in-engine in the game; here baked from `tint`).
Deterministic: the grain uses a fixed seed. Renders only; it never chooses content.
"""
import math

import numpy as np
from PIL import Image, ImageFilter

SS = 4
# inner radius of the painting, as a share of the ring's outer radius
HOLE = {"road": 0.70, "small": 0.76, "notable": 0.70, "capability": 0.68, "keystone": 0.62, "start": 0.60}
# ring outer radius as a share of half the image (room for the drop shadow and the capability petals)
OUTER = {"road": 0.92, "small": 0.92, "notable": 0.92, "capability": 0.80, "keystone": 0.93, "start": 0.93}
BRONZE = np.array([0.70, 0.52, 0.30])
PATINA = np.array([0.10, 0.07, 0.045])
JADE = np.array([0.20, 0.58, 0.44])
LIGHT = np.array([-0.48, -0.62, 0.62])
LIGHT = LIGHT / np.linalg.norm(LIGHT)
HALF = (LIGHT + np.array([0, 0, 1.0]))
HALF = HALF / np.linalg.norm(HALF)


def _box(a, r, axis):
    if r < 1:
        return a
    pad = [(0, 0), (0, 0)]
    pad[axis] = (r + 1, r)
    c = np.cumsum(np.pad(a, pad, mode="edge"), axis=axis)
    n = a.shape[axis]
    hi = np.take(c, np.arange(2 * r + 1, 2 * r + 1 + n), axis=axis)
    lo = np.take(c, np.arange(0, n), axis=axis)
    return (hi - lo) / (2 * r + 1)


def _blur(a, sigma):
    """Gaussian blur of a float array (three box passes per axis)."""
    r = max(0, int(round(sigma * 0.87)))
    for _ in range(3):
        a = _box(_box(a, r, 0), r, 1)
    return a


def geom(kind, S):
    """(centre, ring outer radius, hole radius) in pixels for an S-pixel image."""
    c = S / 2
    R = c * OUTER[kind]
    return c, R, R * HOLE[kind]


def _bead(u, c, w, h):
    return h * np.sqrt(np.clip(1 - ((u - c) / w) ** 2, 0, 1))


def _plateau(u, a, b, h, bev):
    up = np.clip((u - a) / bev, 0, 1)
    dn = np.clip((b - u) / bev, 0, 1)
    t = np.minimum(up, dn)
    return h * t * t * (3 - 2 * t)


def _dome(x, y, px, py, s, h):
    d2 = ((x - px) ** 2 + (y - py) ** 2) / (s * s)
    return h * np.sqrt(np.clip(1 - d2, 0, 1))


def _angdist(t, a):
    return np.abs((t - a + np.pi) % (2 * np.pi) - np.pi)


def _heights(kind, S):
    c, R, hole = geom(kind, S)
    yy, xx = np.mgrid[0:S, 0:S].astype(np.float64)
    x, y = xx - c, yy - c
    r = np.hypot(x, y)
    t = np.arctan2(y, x)
    band = R - hole
    u = (r - hole) / band                       # 0 at the painting's edge, 1 at the ring's outer edge
    inside = (u >= 0) & (u <= 1)
    h = np.zeros((S, S))
    mat = np.zeros((S, S), dtype=np.int8)       # 0 bronze, 1 jade, 2 enamel
    if kind == "road":
        h += _plateau(u, 0.0, 1.0, 0.30, 0.18) + _bead(u, 0.80, 0.20, 0.55) + _bead(u, 0.14, 0.14, 0.40)
        groove = (u > 0.34) & (u < 0.50)
    elif kind == "small":
        h += _plateau(u, 0.0, 1.0, 0.35, 0.16) + _bead(u, 0.84, 0.16, 0.60) + _bead(u, 0.12, 0.12, 0.45)
        groove = (u > 0.30) & (u < 0.44)
    elif kind == "notable":
        h += _plateau(u, 0.0, 1.0, 0.40, 0.10) + _bead(u, 0.90, 0.10, 0.65) + _bead(u, 0.10, 0.10, 0.50)
        h += _bead(u, 0.62, 0.07, 0.25)
        for k in range(4):
            a = math.pi / 4 + k * math.pi / 2
            rr = hole + band * 0.62
            h = np.maximum(h, _dome(x, y, math.cos(a) * rr, math.sin(a) * rr, band * 0.20, 0.95))
        groove = (u > 0.22) & (u < 0.34)
    elif kind == "capability":
        h += _plateau(u, 0.0, 1.0, 0.40, 0.10) + _bead(u, 0.90, 0.10, 0.65) + _bead(u, 0.10, 0.10, 0.50)
        groove = (u > 0.22) & (u < 0.34)
        # eight jade lotus petals: leaf-shaped bumps from the band out past the ring
        for k in range(8):
            a = k * math.pi / 4
            ad = _angdist(t, a)
            reach = (r - (hole + band * 0.45)) / (band * 1.15)        # 0..1 along the petal
            rc = np.clip(reach, 0, 1)
            width = 0.26 * np.sin(rc * math.pi) ** 0.7 * (1 - rc) ** 0.35
            m = (reach > 0) & (reach < 1) & (ad < width)
            ph = 0.80 * np.sqrt(np.clip(1 - (ad / np.maximum(width, 1e-6)) ** 2, 0, 1)) * np.sin(rc * math.pi) ** 0.4
            ph = ph - np.where(ad < 0.018, 0.18, 0)                   # midrib
            ph = np.where(m, ph + 0.35, 0)
            take = ph > h
            h = np.where(take, ph, h)
            mat = np.where(take & m, 1, mat)
        inside = inside | (mat == 1)
    elif kind == "keystone":
        h += _plateau(u, 0.0, 1.0, 0.38, 0.08) + _bead(u, 0.93, 0.07, 0.70) + _bead(u, 0.08, 0.08, 0.55)
        rope = _bead(u, 0.40, 0.07, 0.45) * (0.55 + 0.45 * np.cos(t * 60 + (u - 0.40) * 70))
        h = np.maximum(h, 0.38 + rope)
        for k in range(12):
            a = k * math.pi / 6
            rr = hole + band * 0.70
            h = np.maximum(h, _dome(x, y, math.cos(a) * rr, math.sin(a) * rr, band * 0.13, 0.95))
        groove = (u > 0.16) & (u < 0.25)
    else:  # start: eight raised trigram bars on a wide band
        h += _plateau(u, 0.0, 1.0, 0.35, 0.08) + _bead(u, 0.93, 0.07, 0.65) + _bead(u, 0.08, 0.08, 0.50)
        for k in range(8):
            a = k * math.pi / 4
            ad = _angdist(t, a)
            for j, uc in enumerate((0.36, 0.55, 0.74)):
                broken = (k + j) % 3 == 0
                inbar = (ad < 0.15) & (np.abs(u - uc) < 0.055)
                if broken:
                    inbar = inbar & (ad > 0.035)
                h = np.where(inbar, np.maximum(h, 0.35 + _plateau(u, uc - 0.055, uc + 0.055, 0.45, 0.03)), h)
        groove = (u > 0.16) & (u < 0.24)
    if kind != "capability" or True:
        g = groove & inside
        h = np.where(g, h - 0.22, h)
        mat = np.where(g & (mat == 0), 2, mat)
    rng = np.random.default_rng(11)
    ham = _blur(rng.standard_normal((S, S)), S * 0.006)
    ham = ham / (np.abs(ham).max() + 1e-9)
    h = h + np.where(mat == 0, ham * 0.05, 0)
    return h * band * 0.35, mat, inside, (c, R, hole)


def _grain(S, seed=7):
    rng = np.random.default_rng(seed)
    yy, xx = np.mgrid[0:S, 0:S].astype(np.float64)
    t = np.arctan2(yy - S / 2, xx - S / 2)
    r = np.hypot(yy - S / 2, xx - S / 2) / S
    g = np.zeros((S, S))
    for _ in range(10):                            # brushed along the ring: varies with radius, not angle
        g += np.sin(r * rng.uniform(80, 400) + rng.uniform(0, 6.3)) * rng.uniform(0.2, 1)
    g += 0.6 * np.sin(t * rng.integers(3, 9) + rng.uniform(0, 6.3))
    return g / np.abs(g).max()


def frame(kind, px=256, tint=None):
    """One sculpted frame: RGBA at px, transparent inside the hole, soft drop shadow beneath."""
    S = px * SS
    h, mat, inside, (c, R, hole) = _heights(kind, S)
    hs = _blur(h, S * 0.004)
    gy, gx = np.gradient(hs)
    n = np.dstack([-gx, -gy, np.ones_like(hs)])
    n /= np.linalg.norm(n, axis=2, keepdims=True)
    diff = np.clip(n @ LIGHT, 0, 1)
    spec = np.clip(n @ HALF, 0, 1)
    hmax = max(h.max(), 1e-6)
    hn = np.clip(h / hmax, 0, 1)
    blur = _blur(h, S * 0.02)
    ao = np.clip(1 - np.maximum(blur - h, 0) / hmax * 1.6, 0.35, 1)
    tint_c = np.array(tint if tint is not None else (236, 210, 160)) / 255.0
    alb = BRONZE[None, None, :] * (0.55 + 0.45 * hn[..., None]) + PATINA[None, None, :] * (1 - hn[..., None]) * 0.5
    alb = alb * (1 + 0.07 * _grain(S)[..., None])
    alb = np.where((mat == 1)[..., None], JADE[None, None, :] * (0.7 + 0.3 * hn[..., None]), alb)
    alb = np.where((mat == 2)[..., None], tint_c[None, None, :] * 0.95, alb)
    shininess = np.where(mat == 2, 90, np.where(mat == 1, 50, 28))
    spec_s = np.where(mat == 0, 0.55, 0.85)
    sheen = np.where(mat == 0, diff ** 4 * 0.55, diff ** 2 * 0.15)          # metal: a broad bright sheen on lit faces
    col = alb * (0.10 + 0.85 * diff[..., None] + sheen[..., None]) * ao[..., None]         + (spec ** shininess * spec_s)[..., None] * np.array([1.0, 0.93, 0.80])
    # a faint cool rim light from the lower right so the far edge of each bead still reads
    rim = np.clip(n @ (np.array([0.5, 0.6, 0.62]) / np.linalg.norm([0.5, 0.6, 0.62])), 0, 1) ** 6 * 0.18
    col = np.clip(col + rim[..., None] * np.array([0.6, 0.7, 0.9]), 0, 1)
    a = inside.astype(np.float32)
    rgba = np.dstack([col, a]).astype(np.float32)
    img = Image.fromarray((rgba * 255).astype(np.uint8), "RGBA")
    # drop shadow: the frame's own alpha, blurred and offset down-right
    sh_a = Image.fromarray((a * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(S * 0.018))
    off = int(S * 0.012)
    shadow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    shadow.paste((0, 0, 0, 255), (off, off), sh_a.point(lambda v: int(v * 0.75)))
    out = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    out.alpha_composite(shadow)
    # the shadow must not darken the painting's hole: cut it there (the inner shadow is drawn on the painting)
    holemask = Image.new("L", (S, S), 255)
    yy, xx = np.mgrid[0:S, 0:S]
    hm = (np.hypot(xx - c, yy - c) < hole).astype(np.uint8) * 255
    out.putalpha(Image.fromarray(np.minimum(np.asarray(out.getchannel("A")), 255 - hm).astype(np.uint8)))
    out.alpha_composite(img)
    return out.resize((px, px), Image.LANCZOS)


def inner_shadow(img, kind):
    """Darken the painting toward the hole's edge, more on the top-left (the rim's lit side casts it), so it sits sunk in."""
    px = img.size[0]
    c, R, hole = geom(kind, px)
    yy, xx = np.mgrid[0:px, 0:px].astype(np.float64)
    # shadow centre shifted down-right: the top-left edge is the deepest
    d = hole - np.hypot(xx - c - hole * 0.05, yy - c - hole * 0.05)
    w = hole * 0.22
    f = np.clip(d / w, 0, 1) ** 0.8
    f = 0.25 + 0.75 * f
    arr = np.asarray(img).astype(np.float32)
    arr[..., :3] *= f[..., None]
    return Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGBA")
