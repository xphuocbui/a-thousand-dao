# Job transcript: gear-unkillable (try 1)

I geared `unkillable` with eight Wood-family items and fought it again. Gear cut the typical Hóa Thần fight from 19.6 s to 16.4 s, 20 wins either way. The top_end foe still kills it in 2.0 s with 0 wins.

- **Old file:** its re-run gives 19.6 s, not the 11.3 s in the engine-v2 guide, probably because the library or engine has moved since. I used the re-run in the guide.
- **Fight length:** both runs are well under the 30–60 s band.
- **Loadout:**
  - Base slots: `wood-cycle-seal` (weapon), `wood-ironbark-cuirass` (armour), `wood-slow-garden-ring` and `wood-sprout-ring` (rings), `wood-sap-heart-pendant` (necklace).
  - Extras: `wood-grave-silk-robe` (6), `wood-heartwood-bulwark` (15) and `wood-thousand-roots-banner` (20), for 41 thần thức against the limit of 45. Three extra slots stay empty.
- **Art swap:** the seal's art `wood-seal-of-turning-seasons` takes the slot of `second-spring`, which never fired in the old run.
- **Effects written:**
  - `eff:Grave-Silk Shroud` puts Corpse Rot on the foe at the start of the fight.
  - `eff:Sap Rises` replaces the old `sap-rises`, so it now carries the item's cap of 20 stacks. That is a change to the old Effect.
- **`--without` results (typical foe):**

  | Run | Mean s |
  |---|---|
  | `item:wood-cycle-seal` | 17.1 |
  | `eff:Grave-Silk Shroud` | 16.7 |
  | `eff:Sap Rises` | 16.4 (no change) |

  `--without item:` only removes an item's modifiers; the seal's art stays slotted.
- **Modelled gear:** most of the gear's modifiers have no engine stat, so little of it ran. What ran was the pendant's healing +10, the art speed from the seal and banner (applied to every art), and the two Effects.
- **UNMODELLED:** Spillover, Gripping Root, the cast and Fire wards, the reserve arts, and Surplus Life.
- **Missing pieces:** an overheal-to-Poison item and a cleansing item (both wood), and a Water buff item (water).

`tools/design/combat_sim/_tmp_gear_unkillable.py` is a scratch script I created and tried to delete, but the run that would have deleted it was never approved. It is still there and can go.

Files are in `design/builds/engine-v3`:
- `builds/unkillable.fight.json`
- `unkillable.md`

GEAR-DONE unkillable

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/unkillable.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/unkillable.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/unkillable.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/unkillable.md) instead (Edit rules cover all file-editing tools).
```
