# Job transcript: items-wind (try 1)

I wrote `design/items/catalogue-wind.json` with 10 wind items, and the lint reports 0 findings. I haven't run any of the arts in the fight sim, so how they play is untested.

| Grade | Items |
|---|---|
| 1 | Gale-Feather Fan (Phiến weapon), Gale-Step Ring |
| 2 | Slow-Hour Needle (Châm weapon), Cloud-Veil Robe (ward), Swallow-Tail Pendant (reserve art) |
| 3 | Four-Winds Banner (Kỳ utility, a new Effect and a reserve art), Windbreak Shield (ward), Ring of Hollow Echoes (Echo) |
| 4 (unique) | Nine-Gale Heron Fan, Cloud-Walker's Mantle |

- **Suites:** Stitch the Hour (the needle's art) joins `slow-hour-scripture` and Heron Takes Wing (the fan's art) joins `gale-courier-scripture`, both via `group`.
- **Gated payoffs:** Stitch the Hour hits 2.5× as hard when the foe has 3 Slowed Time or you hold 3 Echoes. Heron Takes Wing hits 3.5× once you hold 5 Feathers and either Swallow Stance is up or you fire three courier arts in one pulse.
- **New Effects (2 of 3 allowed):**
  - Wind at Your Back (Thuận Phong) gives a Wind buff stack on each evade.
  - Phantom Dodge (Ảnh Tị) is an enabler: landed basic attacks count as evades for your counters. Its closing cost is 10 pp less evade.
- **Unique items:** the two grade 4 items are never crafted and each has a `holder` line.
- **Wards:** all three are scaled starter wards with `check_from` set and the factor in `notes`. The factors are 0.8 on the robe's Qi-Scattering Robe, 1.25 on the shield's Golden Light Shield and 1.2 on the mantle's Iron Shirt.
- **Exception:** none used. The mantle carries a ward plus two Effects, which the lint accepts without an `exception`.
- **Spend:** every item is at or above its 80 % target except Slow-Hour Needle (82 %, 21.1 W), which is above it too.

ITEMS-DONE wind

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/items/catalogue-wind.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/items/catalogue-wind.json) instead (Edit rules cover all file-editing tools).
```
