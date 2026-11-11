"""Hand-authored demo maps for the map-style demos (Travel & Map GDD, 2026-11-11).

Three small maps, laid out by hand with shapes and paths, written to maps.json for every style to render:
  A  "Thanh Vân" : a temperate continent (snow north, mountains and a volcano, desert, jungle, swamp, a lake)
  B  "Bích Hải"  : an island chain (volcano isle, jungle isles, a sect island, a port town)
  C  "Băng Nguyên": a cold highland (glacier, tundra, mountains, a valley lake, a swamp delta)

Terrain chars: ~ deep sea, w shallow water / lake, b beach, g grass, f forest, j jungle, d desert, s swamp,
h hills, m mountain, v volcano, i snow / glacier, t tundra.
Roads and rivers are stored as 4-bit neighbour masks (N=1, E=2, S=4, W=8) so each style can auto-tile them.
"""
import json
import math
import random

W, H = 28, 18


def blank(c='~'):
    return [[c] * W for _ in range(H)]


def ellipse(g, cx, cy, rx, ry, c, wobble=0.0, rng=None, only=None):
    for y in range(H):
        for x in range(W):
            d = ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2
            if wobble and rng is not None:
                d += (rng.random() - 0.5) * wobble
            if d <= 1.0 and (only is None or g[y][x] in only):
                g[y][x] = c


def cells(g, pts, c):
    for x, y in pts:
        if 0 <= x < W and 0 <= y < H:
            g[y][x] = c


def path(points):
    """Manhattan path through waypoints (x first, then y), as a list of cells."""
    out = []
    for (x0, y0), (x1, y1) in zip(points, points[1:]):
        x, y = x0, y0
        if not out:
            out.append((x, y))
        while x != x1:
            x += 1 if x1 > x else -1
            out.append((x, y))
        while y != y1:
            y += 1 if y1 > y else -1
            out.append((x, y))
    return out


def masks(cellset):
    m = [[0] * W for _ in range(H)]
    s = set(cellset)
    for (x, y) in s:
        v = 0
        if (x, y - 1) in s: v |= 1
        if (x + 1, y) in s: v |= 2
        if (x, y + 1) in s: v |= 4
        if (x - 1, y) in s: v |= 8
        m[y][x] = v if v else 16  # 16 = isolated dot
    return m


def beaches(g):
    land = set('gfjdshmvit')
    out = [row[:] for row in g]
    for y in range(H):
        for x in range(W):
            if g[y][x] in 'gdj':
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < W and 0 <= ny < H and g[ny][nx] == '~':
                        out[y][x] = 'b'
                        break
    # shallow ring: deep sea next to land becomes shallow
    out2 = [row[:] for row in out]
    for y in range(H):
        for x in range(W):
            if out[y][x] == '~':
                for dx in (-1, 0, 1):
                    for dy in (-1, 0, 1):
                        nx, ny = x + dx, y + dy
                        if 0 <= nx < W and 0 <= ny < H and out[ny][nx] in land | {'b'}:
                            out2[y][x] = 'w'
    return out2


def finish(name, title, g, roads, rivers, places, regions=()):
    flat = lambda ps: [c for p in ps for c in p]
    return {
        'name': name, 'title': title, 'w': W, 'h': H,
        'terrain': [''.join(r) for r in g],
        'road': masks(flat(roads)), 'river': masks(flat(rivers)),
        'road_paths': roads, 'river_paths': rivers,
        'places': places, 'regions': list(regions),
    }


def map_a():
    rng = random.Random(11)
    g = blank()
    ellipse(g, 13.5, 8.5, 12.2, 7.6, 'g', 0.25, rng)
    ellipse(g, 6, 3, 4, 2.2, 'g', 0.2, rng)
    ellipse(g, 9, 1.5, 8, 2.2, 'i', 0.2, rng, only='g')          # snow north
    ellipse(g, 17, 3.5, 6, 2.6, 'm', 0.25, rng, only='gi')       # mountain range
    ellipse(g, 17, 6, 5, 1.6, 'h', 0.3, rng, only='g')           # foothills
    cells(g, [(19, 3), (20, 3)], 'v')                             # volcano
    ellipse(g, 7, 6, 3.4, 2.4, 'f', 0.3, rng, only='g')          # forest
    ellipse(g, 21, 10, 3.6, 2.6, 'd', 0.3, rng, only='gh')       # desert
    ellipse(g, 9, 13, 5, 2.3, 'j', 0.3, rng, only='g')           # jungle
    ellipse(g, 4.5, 10, 2.2, 2.2, 's', 0.3, rng, only='g')       # swamp
    ellipse(g, 13, 9, 1.6, 1.2, 'w', 0.0, rng, only='gfh')       # lake
    g = beaches(g)
    river = [path([(16, 4), (16, 7), (14, 7), (14, 8)]), path([(13, 10), (13, 14), (14, 14), (14, 16)])]
    roads = [path([(5, 8), (11, 8), (11, 11), (17, 11), (17, 8), (21, 8)]), path([(11, 11), (11, 15)]), path([(17, 8), (17, 6)])]
    places = [
        {'x': 11, 'y': 11, 'kind': 'city', 'name': 'Thanh Vân Thành'},
        {'x': 5, 'y': 8, 'kind': 'town', 'name': 'Liễu Trấn'},
        {'x': 17, 'y': 6, 'kind': 'sect', 'name': 'Vân Kiếm Tông'},
        {'x': 19, 'y': 4, 'kind': 'mine', 'name': 'Xích Thạch Khoáng'},
        {'x': 7, 'y': 5, 'kind': 'abode', 'name': 'Tùng Động'},
        {'x': 22, 'y': 11, 'kind': 'ruin', 'name': 'Sa Mạc Di Tích'},
        {'x': 9, 'y': 4, 'kind': 'blessed', 'name': 'Thanh Mộc Phúc Địa'},
        {'x': 21, 'y': 8, 'kind': 'town', 'name': 'Sa Khẩu Trấn'},
        {'x': 11, 'y': 15, 'kind': 'vein', 'name': 'Mộc Linh Mạch'},
    ]
    return finish('A', 'Thanh Vân (temperate continent)', g, roads, river, places, [
        {'x': 7, 'y': 1.6, 'name': 'Bắc Tuyết Nguyên'}, {'x': 16, 'y': 2.2, 'name': 'Xích Phong Sơn Mạch'},
        {'x': 6, 'y': 6.6, 'name': 'Thanh Lâm'}, {'x': 9, 'y': 13.6, 'name': 'Vạn Mộc Lâm'}, {'x': 21, 'y': 9.6, 'name': 'Hoàng Sa Mạc'}, {'x': 4.5, 'y': 10.6, 'name': 'Hắc Trạch'}])


def map_b():
    rng = random.Random(22)
    g = blank()
    ellipse(g, 6, 5, 4.2, 3.2, 'g', 0.3, rng)        # big west island
    ellipse(g, 5, 4, 2.2, 1.6, 'f', 0.3, rng, only='g')
    ellipse(g, 15, 3.5, 3, 2.2, 'j', 0.3, rng)       # jungle isle north
    ellipse(g, 21, 6, 2.6, 2.6, 'g', 0.2, rng)       # volcano isle
    ellipse(g, 21, 6, 1.6, 1.6, 'm', 0.1, rng, only='g')
    cells(g, [(21, 6)], 'v')
    ellipse(g, 12, 11, 4.5, 3, 'g', 0.3, rng)        # central isle
    ellipse(g, 13, 12, 2.5, 1.6, 'j', 0.3, rng, only='g')
    ellipse(g, 10, 10, 1.6, 1.2, 'h', 0.2, rng, only='g')
    ellipse(g, 23, 14, 2.6, 2, 'g', 0.2, rng)        # sect isle
    ellipse(g, 4, 14, 2.4, 1.6, 's', 0.2, rng)       # swamp isle
    ellipse(g, 26, 2, 1.4, 1.2, 'd', 0.0, rng)       # desert islet
    g = beaches(g)
    river = [path([(5, 3), (5, 6), (6, 6), (6, 8)])]
    roads = [path([(4, 5), (8, 5), (8, 7)]), path([(9, 11), (14, 11), (14, 13)])]
    places = [
        {'x': 8, 'y': 7, 'kind': 'town', 'name': 'Bích Hải Cảng'},
        {'x': 4, 'y': 5, 'kind': 'abode', 'name': 'Tây Đảo Động'},
        {'x': 9, 'y': 11, 'kind': 'city', 'name': 'Trung Châu Thành'},
        {'x': 14, 'y': 13, 'kind': 'vein', 'name': 'Thủy Linh Mạch'},
        {'x': 22, 'y': 7, 'kind': 'mine', 'name': 'Hỏa Đảo Khoáng'},
        {'x': 23, 'y': 14, 'kind': 'sect', 'name': 'Hải Nguyệt Tông'},
        {'x': 15, 'y': 3, 'kind': 'ruin', 'name': 'Cổ Thụ Di Tích'},
        {'x': 26, 'y': 2, 'kind': 'blessed', 'name': 'Kim Sa Phúc Địa'},
        {'x': 4, 'y': 14, 'kind': 'abode', 'name': 'Đầm Ẩn Cư'},
    ]
    return finish('B', 'Bích Hải (island chain)', g, roads, river, places, [
        {'x': 5.5, 'y': 2.4, 'name': 'Tây Đảo'}, {'x': 15, 'y': 4.6, 'name': 'Lục Đảo'}, {'x': 21, 'y': 3.6, 'name': 'Hỏa Đảo'},
        {'x': 12, 'y': 9.4, 'name': 'Trung Châu'}, {'x': 4, 'y': 12.4, 'name': 'Trạch Đảo'}, {'x': 23, 'y': 12, 'name': 'Nguyệt Đảo'}, {'x': 14, 'y': 16.4, 'name': 'Bích Hải'}])


def map_c():
    rng = random.Random(33)
    g = blank()
    ellipse(g, 13.5, 9, 12.5, 8, 'g', 0.25, rng)
    ellipse(g, 13, 2, 12, 3.4, 'i', 0.2, rng, only='g')          # glacier north
    ellipse(g, 13, 5.5, 11, 1.8, 't', 0.3, rng, only='g')        # tundra band
    ellipse(g, 6, 8, 4, 2.6, 'm', 0.3, rng, only='gt')           # west range
    ellipse(g, 21, 8, 4, 2.4, 'm', 0.3, rng, only='gt')          # east range
    ellipse(g, 13, 9, 3.2, 2.2, 'h', 0.2, rng, only='gt')        # valley hills
    ellipse(g, 13, 10, 1.5, 1.1, 'w', 0.0, rng, only='gh')       # valley lake
    ellipse(g, 9, 13, 3.5, 2, 'f', 0.3, rng, only='g')           # forest
    ellipse(g, 19, 14, 3.5, 2, 's', 0.3, rng, only='g')          # swamp delta
    g = beaches(g)
    river = [path([(13, 4), (13, 8)]), path([(14, 11), (14, 13), (17, 13), (17, 16)])]
    roads = [path([(5, 12), (13, 12), (13, 15)]), path([(13, 12), (22, 12), (22, 10)]), path([(9, 12), (9, 6), (11, 6)])]
    places = [
        {'x': 13, 'y': 12, 'kind': 'city', 'name': 'Bắc Nguyên Thành'},
        {'x': 5, 'y': 12, 'kind': 'town', 'name': 'Tùng Lâm Trấn'},
        {'x': 22, 'y': 10, 'kind': 'mine', 'name': 'Hàn Thiết Khoáng'},
        {'x': 11, 'y': 6, 'kind': 'sect', 'name': 'Băng Tâm Cung'},
        {'x': 7, 'y': 3, 'kind': 'ruin', 'name': 'Băng Phong Di Tích'},
        {'x': 18, 'y': 3, 'kind': 'blessed', 'name': 'Hàn Ngọc Phúc Địa'},
        {'x': 13, 'y': 15, 'kind': 'town', 'name': 'Nam Độ Trấn'},
        {'x': 20, 'y': 15, 'kind': 'abode', 'name': 'Đầm Lầy Động'},
        {'x': 16, 'y': 8, 'kind': 'vein', 'name': 'Hàn Linh Mạch'},
    ]
    return finish('C', 'Băng Nguyên (cold highland)', g, roads, river, places, [
        {'x': 13, 'y': 1.8, 'name': 'Vạn Niên Băng Xuyên'}, {'x': 13, 'y': 5.4, 'name': 'Hàn Nguyên'}, {'x': 5.5, 'y': 9.4, 'name': 'Tây Lĩnh'},
        {'x': 21, 'y': 9.4, 'name': 'Đông Lĩnh'}, {'x': 8.5, 'y': 14.4, 'name': 'Tùng Lâm'}, {'x': 19.5, 'y': 15.4, 'name': 'Nam Trạch'}])


if __name__ == '__main__':
    maps = [map_a(), map_b(), map_c()]
    # roads and rivers must sit on land; places must sit on land
    for m in maps:
        t = m['terrain']
        for p in m['places']:
            c = t[p['y']][p['x']]
            assert c not in '~', (m['name'], p, c)
    json.dump(maps, open(__file__.replace('build_maps.py', 'maps.json'), 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    for m in maps:
        print(m['name'], m['title'])
        rs = m['road']; rv = m['river']
        for y, row in enumerate(m['terrain']):
            line = ''
            for x, c in enumerate(row):
                pl = [p for p in m['places'] if p['x'] == x and p['y'] == y]
                if pl:
                    line += pl[0]['kind'][0].upper()
                elif rs[y][x]:
                    line += '='
                elif rv[y][x]:
                    line += '%'
                else:
                    line += c
            print('  ' + line)
