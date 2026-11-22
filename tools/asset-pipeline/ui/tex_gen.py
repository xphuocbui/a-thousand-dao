"""Seamless UI textures (art bible 8.7): parchment and rosewood, 512 x 512, kept inside Section 4's limits so text
contrast holds (parchment #D8C7A0-#E3D4AE, rosewood #2A1A12-#40291B). Noise is built in the frequency domain, so it
tiles by construction. Seeded: the same output every run.

usage: python -I tex_gen.py <repo root>    writes assets/ui/textures/tex_parchment.png, tex_rosewood.png
"""
import os
import sys

import numpy as np
from PIL import Image

N = 512


def periodic_noise(rng, scale_x, scale_y, power=2.0):
    """Tileable noise in [0, 1]: white noise shaped by a 1/f^power spectrum, squashed per axis (anisotropic when the
    scales differ)."""
    fx = np.fft.fftfreq(N)[None, :] * scale_x
    fy = np.fft.fftfreq(N)[:, None] * scale_y
    f = np.sqrt(fx * fx + fy * fy)
    f[0, 0] = 1.0
    spec = (rng.normal(size=(N, N)) + 1j * rng.normal(size=(N, N))) / f ** power
    spec[0, 0] = 0.0
    out = np.real(np.fft.ifft2(spec))
    out -= out.min()
    return out / max(out.max(), 1e-9)


def blend(lo, hi, t):
    lo = np.array([int(lo[i:i + 2], 16) for i in (1, 3, 5)], dtype=np.float32)
    hi = np.array([int(hi[i:i + 2], 16) for i in (1, 3, 5)], dtype=np.float32)
    return lo[None, None, :] + (hi - lo)[None, None, :] * t[..., None]


def save(rgb, path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    Image.fromarray(np.clip(np.round(rgb), 0, 255).astype(np.uint8), "RGB").save(path, optimize=True)


def main():
    root = sys.argv[1] if len(sys.argv) > 1 else "."
    rng = np.random.default_rng(20261122)
    # parchment: soft mottling plus faint horizontal fibres; mostly near the light end
    mottle = periodic_noise(rng, 1.0, 1.0, 1.6)
    fibres = periodic_noise(rng, 0.25, 4.0, 1.2)
    grain = periodic_noise(rng, 1.0, 1.0, 0.6)
    t = 1.0 - (0.62 * mottle + 0.23 * fibres + 0.15 * grain)
    t = np.clip((t - t.min()) / (t.max() - t.min()), 0, 1) ** 0.6     # bias toward the light end
    save(blend("#D8C7A0", "#E3D4AE", t), os.path.join(root, "assets/ui/textures/tex_parchment.png"))
    # rosewood: long horizontal grain lines, slow figure, fine pores; mostly near the dark end
    # (a large x scale damps change along x, so the grain runs horizontally)
    figure = periodic_noise(rng, 2.5, 0.2, 1.5)
    lines = periodic_noise(rng, 8.0, 0.06, 0.9)
    pores = periodic_noise(rng, 3.0, 1.0, 0.35)
    t = 0.45 * figure + 0.4 * lines + 0.15 * pores
    t = np.clip((t - t.min()) / (t.max() - t.min()), 0, 1) ** 1.4      # bias toward the dark end
    save(blend("#2A1A12", "#40291B", t), os.path.join(root, "assets/ui/textures/tex_rosewood.png"))
    print("ok")


if __name__ == "__main__":
    main()
