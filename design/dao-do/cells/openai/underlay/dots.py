"""Finds the ornament dots in an underlay image (measurement only). usage: python -I dots.py <img> <cx> <cy> <half> <out.json>
A pixel is 'ink' if bright; eroding the ink mask removes the thin lines and leaves the dots; each blob's centre is
converted to map coordinates (the image covers centre +- half)."""
import json, sys
from PIL import Image, ImageFilter
img, cx, cy, half, out = sys.argv[1], *map(float, sys.argv[2:5]), sys.argv[5]
im = Image.open(img).convert('RGB')
W, H = im.size
px = im.load()
mask = Image.new('L', im.size)
mp = mask.load()
for y in range(H):
    for x in range(W):
        r, g, b = px[x, y]
        if max(r, g, b) > 95:
            mp[x, y] = 255
core = mask.filter(ImageFilter.MinFilter(5))
cp = core.load()
seen = set()
blobs = []
for y in range(H):
    for x in range(W):
        if cp[x, y] and (x, y) not in seen:
            st, pts = [(x, y)], []
            seen.add((x, y))
            while st:
                a, b = st.pop()
                pts.append((a, b))
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    q = (a + dx, b + dy)
                    if 0 <= q[0] < W and 0 <= q[1] < H and cp[q] and q not in seen:
                        seen.add(q); st.append(q)
            mx = sum(p[0] for p in pts) / len(pts); my = sum(p[1] for p in pts) / len(pts)
            cr = [px[int(p[0]), int(p[1])] for p in pts]
            col = tuple(sum(c[i] for c in cr) // len(cr) for i in range(3))
            blobs.append({'px': [round(mx, 1), round(my, 1)], 'area': len(pts), 'rgb': col,
                          'xy': [round(cx - half + mx / W * 2 * half, 3), round(cy - half + my / H * 2 * half, 3)]})
json.dump(blobs, open(out, 'w'), indent=0)
print(len(blobs), 'blobs; areas', sorted(b['area'] for b in blobs)[:10], '...', sorted(b['area'] for b in blobs)[-6:])
