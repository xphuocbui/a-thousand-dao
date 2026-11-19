```python
import math
from celllib import road

THEME = 'island'


def mix(a, b, t):
    return (a[0] + t * (b[0] - a[0]), a[1] + t * (b[1] - a[1]))


def polar(c, r, degrees):
    t = math.radians(degrees)
    return (c[0] + r * math.sin(t), c[1] + r * math.cos(t))


def rotate(p, c, radians):
    x, y = p[0] - c[0], p[1] - c[1]
    u, v = math.cos(radians), math.sin(radians)
    return (c[0] + u * x - v * y, c[1] + v * x + u * y)


def along(a, b, c, t):
    ax, ay = a[0] - c[0], a[1] - c[1]
    bx, by = b[0] - c[0], b[1] - c[1]
    sweep = math.atan2(ax * by - ay * bx, ax * bx + ay * by)
    return rotate(a, c, t * sweep)


def bow_centre(a, b, rise):
    # The signed sagitta is measured along the chord normal (-dy, dx).
    dx, dy = b[0] - a[0], b[1] - a[1]
    d = math.hypot(dx, dy)
    k = (rise * rise - d * d / 4) / (2 * rise * d)
    m = mix(a, b, 0.5)
    return (m[0] - k * dy, m[1] + k * dx)


def chain(links, keys, centre):
    links.extend((a, b, centre) for a, b in zip(keys, keys[1:]))


def penumbra_seal():
    orbit = (0.0, -116.98)
    radius = 9.0
    seal = polar(orbit, radius, 0)
    join = polar(orbit, radius, 13)
    seal_radius = math.hypot(join[0] - seal[0], join[1] - seal[1])
    a = math.degrees(math.atan2(join[0] - seal[0], join[1] - seal[1]))
    b = (a + 180) / 2
    angles = (0, a / 2, a, b, 180, 360 - b, 360 - a, 360 - a / 2)
    keys = [f'seal{i}' for i in range(len(angles))]
    nodes = {
        key: (polar(seal, seal_radius, angle), 'notable' if i == 4 else 'small')
        for i, (key, angle) in enumerate(zip(keys, angles))
    }
    links = []
    chain(links, keys + [keys[0]], seal)
    for side, root in ((1, keys[2]), (-1, keys[6])):
        wing = [root]
        for i, angle in enumerate((28, 43, 58)):
            key = f'wing{side}_{i}'
            nodes[key] = (polar(orbit, radius, side * angle),
                          'notable' if i == 2 else 'small')
            wing.append(key)
        chain(links, wing, orbit)

    a, b = road(617), nodes[keys[0]][0]
    nodes['entry0'] = (mix(a, b, 0.43), 'small')
    nodes['entry1'] = (mix(a, b, 0.72), 'small')
    chain(links, [617, 'entry0', 'entry1', keys[0]], None)
    return nodes, links


def celestial_vault():
    east, west = 616, 623
    a, b = road(east), road(west)
    centre = (0.0, -101.4)
    nodes, links = {}, []
    rim = [f'vault{i}' for i in range(1, 10)]
    for i, key in enumerate(rim, 1):
        nodes[key] = (along(a, b, centre, i / 10),
                      'notable' if i == 5 else 'small')
    chain(links, [east] + rim + [west], centre)

    for side, root in ((1, rim[2]), (-1, rim[6])):
        p = nodes[root][0]
        c = (p[0] + side * 1.55, p[1] + 5.6)
        curl = [root]
        for i in (1, 2):
            key = f'inward{side}_{i}'
            nodes[key] = (rotate(p, c, math.radians(-side * 26 * i)),
                          'notable' if i == 2 else 'small')
            curl.append(key)
        chain(links, curl, c)
    return nodes, links


def tide_lens(outer, inner, side):
    a, b = road(outer), road(inner)
    guide = bow_centre(a, b, side * 2.2)
    keys = ['approach', 'near', 'heart', 'far', 'return']
    nodes = {}
    for key, t in zip(keys, (0.13, 0.26, 0.50, 0.74, 0.87)):
        nodes[key] = (along(a, b, guide, t),
                      'notable' if key == 'heart' else 'small')
    links = []
    chain(links, [outer] + keys + [inner], guide)

    a, b = nodes['near'][0], nodes['far'][0]
    rim = bow_centre(a, b, side * 1.6)
    for i in (1, 2):
        nodes[f'phase{i}'] = (along(a, b, rim, i / 3), 'small')
    chain(links, ['near', 'phase1', 'phase2', 'far'], rim)
    return nodes, links


def veil_crossing(outer, inner, side):
    a, b = road(outer), road(inner)
    c = bow_centre(a, b, side * 1.85)
    keys = [f'cross{i}' for i in range(1, 6)]
    nodes = {
        key: (along(a, b, c, i / 6), 'notable' if i == 3 else 'small')
        for i, key in enumerate(keys, 1)
    }
    links = []
    chain(links, [outer] + keys + [inner], c)
    return nodes, links


def sweep(anchor, centre, step, count):
    a = road(anchor)
    keys = [f'sweep{i}' for i in range(1, count + 1)]
    nodes = {
        key: (rotate(a, centre, math.radians(i * step)),
              'notable' if i == count else 'small')
        for i, key in enumerate(keys, 1)
    }
    links = []
    chain(links, [anchor] + keys, centre)
    return nodes, links


def horn_sliver(anchor, side):
    a = road(anchor)
    x, y = a[0], a[1] + 109.0
    r = math.hypot(x, y)
    ux, uy = x / r, y / r
    tx, ty = side * uy, -side * ux
    c = (a[0] - 2.5 * ux + 3.6 * tx, a[1] - 2.5 * uy + 3.6 * ty)
    return sweep(anchor, c, -side * 21, 3)


def wandering_phase():
    # Opposite sagittas in the same proportion give a common tangent.
    first, last = 629, 635
    a, b = road(first), road(last)
    inflection = mix(a, b, 5 / 9)
    nodes, links = {}, []
    start = first
    for p, q, steps, offset, sign in (
        (a, inflection, 5, 0, 1),
        (inflection, b, 4, 5, -1),
    ):
        c = bow_centre(p, q, sign * 0.22 * math.hypot(q[0] - p[0], q[1] - p[1]))
        keys = [start]
        for i in range(1, steps + 1):
            j = offset + i
            if j == 9:
                keys.append(last)
            else:
                key = f'phase{j}'
                nodes[key] = (along(p, q, c, i / steps),
                              'notable' if j in (3, 6) else 'small')
                keys.append(key)
        chain(links, keys, c)
        start = keys[-1]
    return nodes, links


moon = {
    'penumbra_seal': penumbra_seal(),
    'vault_of_quiet_stars': celestial_vault(),
    'wandering_phase': wandering_phase(),
}

for suffix, side, lower, inner, shoulder, hinge, horn in (
    ('east',  1, 593, 611, 594, 614, 600),
    ('west', -1, 603, 618, 604, 621, 610),
):
    moon[f'{suffix}_tide_lens'] = tide_lens(lower, inner, side)
    moon[f'{suffix}_veil_crossing'] = veil_crossing(shoulder, hinge, side)
    moon[f'{suffix}_receding_light'] = sweep(
        hinge, (side * 14.25, -113.7), side * 24, 4
    )
    moon[f'{suffix}_silver_horn'] = horn_sliver(horn, side)

CELLS = {933: moon}
```

I lowered the vault so its crown reads in full, and gave the two nearly straight veil crossings a deeper sweep while keeping their shared inner-road junctions. The central seal and the side circle were already strong, so I left their geometry alone.