# Đạo Đồ v3, the islands version of 2026-11-19 (saved by the user's word: "good good now save and commit please")

The v2 lands (`../v2-night-2026-11-19/`) with the islands, hub, rim tower and keystones redone with the user on
2026-11-19. The official version is still `../../official-2026-11-18/` (the user said "save", not "make it official").

- `dao-do-map.json`: 6,996 nodes (1,561 notables, 24 keystones), 853 pieces; 0 crossings, only the base map's 4
  spacing warnings, all pieces pass R0-R4. Built by `tools/design/dao_do_rework/cells/integrate.sh` (checked identical
  byte for byte); `base-map.json` is the base map it was built on; `source/` the cell files compiled, `tree.svg` the
  viewer drawing, `whole.png` and `<land>.png` renders.
- What changed from v2:
  - **Sun (931)**: traced from the underlay the user picked (`openai/underlay/sun/inout-3.png`: the Fusang 2 tree
    inside the outer ring, Corona 1's flames outside). Flames: `sun_trace.py` (twin flames at every ring node). Tree:
    `sun_hand.py`, hand-traced branch by branch. Under a looser spacing for the Sun only (rules 3.2 exception).
  - **Moon (933)** and **Thunder (932)**: traced from the user's picks Moon 2 and Thunder 3 (`moon_trace.py`,
    `thunder_trace.py`), nodes re-spaced evenly along the drawn lines, then more beaded swirls, clouds and bolts in the
    same theme.
  - **Chaos (hub)**: OpenAI's five-arm spiral (`openai/oai2_chaos.py`).
  - **Earth's rim pagoda (902)**: OpenAI's (`openai/pagoda/oai_pagoda2.py`); the old wedge pagoda removed from
    `lands/earth.py`.
  - **Keystones**: the 10 old ones folded onto their roads (their dead-end spur nodes removed from the base map), 14
    new: a pair on each land's rim at about 28 degrees, a pair by the Sun's road in, Thunder's arc tip, a pendant under
    the Moon (`lands/*.py`, `keystones_islands.py`); 24 in all.
- Open: the Sun has about 490 nodes against the Moon's 230 and Thunder's 330 (the price of the picture's density); the
  Sun and Chaos both turn as pinwheels was a point for the user's eye before the Sun was traced.
