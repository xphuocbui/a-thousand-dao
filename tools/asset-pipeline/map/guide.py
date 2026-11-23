"""Guide render of the continent for the map art (production/plans/overnight-2026-11-22.md step 5): natural biome
colours, hill shading lit from the top left (art bible Section 2: golden hour, raking light), rivers and lakes from the
water layer, the sea darkening with depth. No markers, no labels, no settlements: the image model paints over it and
the engine places the place art. 4 px per game tile (the base's fine layers), 2160 x 1440.

usage: python -I tools/asset-pipeline/map/guide.py <repo root> [out png]
Reads design/map/continent-11/base/fine_biome.png, fine_elevation.png, fine_water.png.
"""
import os
import sys

import numpy as np
from PIL import Image, ImageFilter

# natural colours per biome id (meta.json legend), chosen to read as a real landscape seen from the air
BIOME_RGB = {
    0: (74, 104, 58),     # temperate forest
    1: (112, 140, 66),    # bamboo forest
    2: (46, 92, 48),      # jungle
    3: (128, 152, 82),    # grassland
    4: (166, 160, 98),    # steppe
    5: (206, 182, 128),   # desert
    6: (214, 208, 190),   # salt flats
    7: (160, 104, 70),    # badlands
    8: (92, 104, 66),     # swamp
    9: (66, 98, 76),      # mangrove
    10: (128, 124, 96),   # highland
    11: (150, 146, 140),  # high mountain
    12: (104, 118, 90),   # karst
    13: (82, 70, 64),     # volcano
    14: (150, 154, 132),  # tundra
    15: (232, 236, 238),  # glacier
    16: (98, 84, 96),     # miasma
    17: (58, 98, 132),    # lake
    18: (40, 74, 112),    # sea
}


def main():
    root = sys.argv[1] if len(sys.argv) > 1 else "."
    base = os.path.join(root, "design/map/continent-11/base")
    out = sys.argv[2] if len(sys.argv) > 2 else os.path.join(root, "design/map/continent-11/art/guide_4x.png")
    biome = np.array(Image.open(os.path.join(base, "fine_biome.png")))
    elev = np.array(Image.open(os.path.join(base, "fine_elevation.png"))).astype(np.float32) - 10000.0   # metres
    water = np.array(Image.open(os.path.join(base, "fine_water.png")))
    h, w = biome.shape
    rgb = np.zeros((h, w, 3), np.float32)
    for bid, col in BIOME_RGB.items():
        rgb[biome == bid] = col
    # soften biome borders so the guide reads as land, not a chart
    img = Image.fromarray(rgb.astype(np.uint8)).filter(ImageFilter.GaussianBlur(1.6))
    rgb = np.asarray(img).astype(np.float32)
    land = elev > 0
    # snow on the highest ground
    snow = np.clip((elev - 3200.0) / 900.0, 0, 1)[..., None] * land[..., None]
    rgb = rgb * (1 - snow) + np.array([236, 238, 240], np.float32) * snow
    # hill shading: light from the top left (azimuth 315, altitude 40)
    e = np.where(land, elev, 0.0)
    gy, gx = np.gradient(e, 100.0)          # metres per fine cell, exaggerated
    az, alt = np.radians(315.0), np.radians(40.0)
    slope = np.arctan(np.hypot(gx, gy) * 1.4)
    aspect = np.arctan2(-gx, gy)
    shade = np.sin(alt) * np.cos(slope) + np.cos(alt) * np.sin(slope) * np.cos(az - aspect)
    shade = np.clip(0.55 + 0.6 * (shade - 0.55), 0.35, 1.25)
    rgb = np.where(land[..., None], rgb * shade[..., None], rgb)
    # the sea: deeper is darker; a light fringe at the coast
    sea = (water & 1) > 0
    depth = np.clip(-elev / 3000.0, 0, 1)
    sea_col = np.array([70, 112, 150], np.float32) * (1 - depth[..., None]) + np.array([28, 54, 92], np.float32) * depth[..., None]
    rgb = np.where(sea[..., None], sea_col, rgb)
    lake = (water & 2) > 0
    rgb = np.where(lake[..., None], np.array([62, 104, 140], np.float32), rgb)
    river = (water & 4) > 0
    rgb = np.where(river[..., None], np.array([70, 116, 156], np.float32), rgb)
    os.makedirs(os.path.dirname(out), exist_ok=True)
    Image.fromarray(np.clip(rgb, 0, 255).astype(np.uint8)).save(out, optimize=True)
    print("guide", out, (w, h))


if __name__ == "__main__":
    main()
