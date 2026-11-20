"""Painted round frames (option B, art bible §7.9): fit a painted ring candidate to the node geometry.

The painting model returns a ring on black. This measures the ring (its inner edge and its solid outer edge from the
median brightness over all angles, so petals and bosses do not count), scales it so its inner edge meets the hole of
the frame kind, cuts it out (solid annulus plus anything bright beyond it), adds the enamel land-tint line and a soft
drop shadow. Renders only; it never chooses content.
"""
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

import frames_sculpt as FS

THR = 0.10          # share of the ring's peak brightness that counts as "metal"


def measure(path):
    """(r_in, r_core, r_max) of the painted ring as shares of half the image."""
    im = Image.open(path).convert("L")
    a = np.asarray(im).astype(np.float64) / 255.0
    n = a.shape[0]
    c = n / 2
    yy, xx = np.mgrid[0:n, 0:n]
    r = np.hypot(xx - c + 0.5, yy - c + 0.5)
    t = np.arctan2(yy - c, xx - c)
    bins = 360
    rb = np.clip(r.astype(int), 0, int(c) - 1)
    tb = ((t + np.pi) / (2 * np.pi) * bins).astype(int) % bins
    grid = np.zeros((int(c), bins))
    cnt = np.zeros((int(c), bins))
    np.add.at(grid, (rb, tb), a)
    np.add.at(cnt, (rb, tb), 1)
    grid = grid / np.maximum(cnt, 1)
    med = np.median(grid, axis=1)
    mx = np.max(grid, axis=1)
    peak = med.max()
    on = np.where(med > peak * THR)[0]
    r_in, r_core = on.min(), on.max()
    on_any = np.where(mx > peak * THR * 1.5)[0]
    r_max = on_any.max()
    return r_in / c, r_core / c, r_max / c


def frame(path, kind, px, tint=None):
    """(RGBA frame at px, hole radius in px) for a painted candidate."""
    r_in, r_core, r_max = measure(path)
    S = px * FS.SS
    c = S / 2
    hole_want = FS.geom(kind, S)[2]
    scale = (hole_want / c) / (r_in * 1.02)               # the ring's inner edge overlaps the painting a little
    if r_max * scale > 0.97:                              # keep the whole ring inside the image
        scale = 0.97 / r_max
    hole = r_in * 1.02 * scale * c
    src = Image.open(path).convert("RGB")
    w = int(round(S * scale))
    src = src.resize((w, w), Image.LANCZOS)
    canvas = Image.new("RGB", (S, S), (0, 0, 0))
    off = (S - w) // 2
    if off >= 0:
        canvas.paste(src, (off, off))
    else:
        canvas = src.crop((-off, -off, -off + S, -off + S))
    arr = np.asarray(canvas).astype(np.float64) / 255.0
    lum = arr.mean(axis=2)
    yy, xx = np.mgrid[0:S, 0:S]
    r = np.hypot(xx - c, yy - c)
    core = (r >= hole) & (r <= r_core * scale * c)
    peak = np.percentile(lum[core], 95) if core.any() else 1.0
    bright = np.clip((lum / peak - THR) / (THR * 1.5), 0, 1)
    alpha = np.where(r < hole, 0, np.where(core, 1, bright))
    alpha = np.asarray(Image.fromarray((alpha * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(S * 0.0015))) / 255.0
    alpha = np.where(r < hole, 0, alpha)
    rgba = np.dstack([arr, alpha])
    img = Image.fromarray((rgba * 255).astype(np.uint8), "RGBA")
    # enamel land-tint line at the painting's edge
    if tint is not None:
        d = ImageDraw.Draw(img)
        lw = max(2, int(S * 0.012))
        rr = hole + lw * 0.6
        d.ellipse((c - rr, c - rr, c + rr, c + rr), outline=tuple(tint) + (235,), width=lw)
    sh = Image.fromarray((alpha * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(S * 0.018))
    o = int(S * 0.012)
    out = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    out.paste((0, 0, 0, 255), (o, o), sh.point(lambda v: int(v * 0.7)))
    hm = (r < hole).astype(np.uint8) * 255
    out.putalpha(Image.fromarray(np.minimum(np.asarray(out.getchannel("A")), 255 - hm).astype(np.uint8)))
    out.alpha_composite(img)
    return out.resize((px, px), Image.LANCZOS), hole / FS.SS


def node(painting, frame_path, kind, px, tint, zoom=1.0):
    """A painted icon in a painted frame, at px."""
    fr, hole = frame(frame_path, kind, px, tint)
    S = px * FS.SS
    hs = hole * FS.SS
    src = painting if isinstance(painting, Image.Image) else Image.open(painting).convert("RGB")
    w = int(hs * 2 / 0.86 * zoom)
    src = src.resize((w, w), Image.LANCZOS)
    layer = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    layer.paste(src, (int(S / 2 - w / 2), int(S / 2 - w / 2)))
    mask = Image.new("L", (S, S), 0)
    ImageDraw.Draw(mask).ellipse((S / 2 - hs, S / 2 - hs, S / 2 + hs, S / 2 + hs), fill=255)
    base = Image.composite(layer, Image.new("RGBA", (S, S), (0, 0, 0, 0)), mask).resize((px, px), Image.LANCZOS)
    # inner shadow, at this frame's own hole
    yy, xx = np.mgrid[0:px, 0:px].astype(np.float64)
    c = px / 2
    dd = hole - np.hypot(xx - c - hole * 0.05, yy - c - hole * 0.05)
    f = 0.25 + 0.75 * np.clip(dd / (hole * 0.22), 0, 1) ** 0.8
    a = np.asarray(base).astype(np.float32)
    a[..., :3] *= f[..., None]
    base = Image.fromarray(np.clip(a, 0, 255).astype(np.uint8), "RGBA")
    base.alpha_composite(fr)
    return base


# Road (travel node) colours by purity kind (art bible 7.5; Light and Darkness provisional).
LAND_HEX = {"hoa": "#E8442A", "thuy": "#3F6FE0", "moc": "#2FBF8A", "kim": "#DCE3EC", "tho": "#8F5A2E",
            "loi": "#A15CFF", "am": "#6B2D8F", "quang": "#FFE45C"}
FIVE = ["hoa", "tho", "kim", "thuy", "moc"]          # generating cycle order, for the hub's ring of colours
ROAD_KINDS = ["hoa", "tho", "kim", "thuy", "moc", "loi", "am", "quang", "hub",
              "hoa+tho", "kim+tho", "kim+thuy", "moc+thuy", "hoa+moc"]


def _hexrgb(h):
    return np.array([int(h[i:i + 2], 16) for i in (1, 3, 5)]) / 255.0


def colourize(path, kind):
    """A greyscale road motif mapped to a road kind's colours: one hue, a split pair, or the hub's five."""
    im = Image.open(path).convert("L")
    l = np.asarray(im).astype(np.float64) / 255.0
    n = l.shape[0]
    yy, xx = np.mgrid[0:n, 0:n] / n
    if kind == "hub":
        t = np.arctan2(yy - 0.5, xx - 0.5)
        w = [np.cos((t - (-np.pi / 2 + k * 2 * np.pi / 5) + np.pi) % (2 * np.pi) - np.pi).clip(0) ** 3 for k in range(5)]
        tot = sum(w) + 1e-9
        hue = sum(wk[..., None] * _hexrgb(LAND_HEX[e])[None, None, :] for wk, e in zip(w, FIVE)) / tot[..., None]
    elif "+" in kind:
        a, b = kind.split("+")
        s = np.clip(((xx + yy) / 2 - 0.40) / 0.20, 0, 1)
        s = s * s * (3 - 2 * s)
        hue = _hexrgb(LAND_HEX[a])[None, None, :] * (1 - s[..., None]) + _hexrgb(LAND_HEX[b])[None, None, :] * s[..., None]
    else:
        hue = np.broadcast_to(_hexrgb(LAND_HEX[kind]), (n, n, 3))
    body = np.clip(l / 0.62, 0, 1) ** 1.1
    core = np.clip((l - 0.62) / 0.38, 0, 1) ** 1.6
    col = hue * body[..., None] + (1 - hue) * core[..., None]
    return Image.fromarray((np.clip(col, 0, 1) * 255).astype(np.uint8), "RGB")


def road_hex(kind):
    """The rim tint for a road kind (a pair uses its first land; the hub a neutral gold)."""
    if kind == "hub":
        return "#E8D08A"
    return LAND_HEX[kind.split("+")[0]]


def road_candidate(node_id, n=2):
    """Which qi-pearl candidate a road node shows (user 2026-11-20: a random mix of 1 and 2), stable per node id."""
    return (node_id * 2654435761 >> 7) % n
