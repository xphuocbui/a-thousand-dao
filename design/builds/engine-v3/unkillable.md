# The Thousand-Year Banyan (Thiên Niên Dung Thụ) — a tank whose healing outlives the fight and whose poison is the clock. Realm: Hóa Thần (`hoa_than`).

Fight file: `design/builds/engine-v3/builds/unkillable.fight.json` (the engine-v2 file plus `"items"`, one art swap and two Effects).
Root: Wood purity 80, Water purity 60. The build has no `divine_sense`, so the limit is 45 × 1.0; the items' own
than_thuc_pct (robe +6, banner +4) would lift it to 49.5, but the engine does not read it, so I count against 45.

## Loadout

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon | Verdant Cycle Seal (Thanh Hoàn Ấn) `wood-cycle-seal` | 3 | Its art Seal of the Turning Season counts as a Verdant Cycle Scripture art and plants and spends Seeds; it takes the slot of `second-spring`, which never fired |
| Armour | Ironbark Cuirass (Thiết Bì Giáp) `wood-ironbark-cuirass` | 2 | Regeneration +40, health +12, healing taken +10; the Physical shell is a cast ward the engine cannot run |
| Ring | Ring of the Slow Garden (Hoãn Viên Giới) `wood-slow-garden-ring` | 3 | Poison lasts 40 % longer and bites 16 % harder; Spillover (unmodelled) |
| Ring | Sprout Ring (Mạnh Nha Giới) `wood-sprout-ring` | 1 | Regeneration +20, Wood buff stronger, a little health |
| Necklace | Sap-Heart Pendant (Dịch Tâm Bội) `wood-sap-heart-pendant` | 2 | Healing +10 (the one modifier that runs), Wood buff and regeneration, a Wood-aura reserve |
| Extra, TT 6 | Grave-Silk Robe (Mộ Ti Bào) `wood-grave-silk-robe` | 4 unique | Grave-Silk Shroud puts Corpse Rot on the foe from t = 0 with no art slot; Poison modifiers; a Fire veil |
| Extra, TT 15 | Heartwood Bulwark (Tâm Mộc Thuẫn) `wood-heartwood-bulwark` | 3 | Carries Sap Rises (healing per Wood stack), which the build already ran as its own Effect; regeneration +40 |
| Extra, TT 20 | Thousand Roots Banner (Vạn Căn Kỳ) `wood-thousand-roots-banner` | 4 unique | Moc art speed +16, Poison strength +24, linh lực +10, a 15 % reserve art |
| Extras 4–6 | empty | — | Nothing left that fits the 45 and fires |

Thần thức: 6 + 15 + 20 = **41 of 45**. Grade 4 pieces are allowed at Hóa Thần.
Note on `eff:Sap Rises`: the old file's `sap-rises` is now written under the item's name and given the item's cap of 20 stacks.

## Before and after

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical Hóa Thần | 19.6 | 16.4 | 20-0-0 | 20-0-0 |
| top_end Hóa Thần | 2.0 | 2.0 | 0-20-0 | 0-20-0 |

The old file's figures differ from the 11.3 s in the engine-v2 guide (the library or engine moved since); the old file was re-run for this table.

| Run (typical) | Mean s | W-L-other | Foe dry s |
|---|---|---|---|
| geared | 16.4 | 20-0-0 | 15.5 |
| `--without item:wood-cycle-seal` (drops its modifiers, the art stays) | 17.1 | 20-0-0 | 16.3 |
| `--without eff:Grave-Silk Shroud` | 16.7 | 20-0-0 | 15.5 |
| `--without eff:Sap Rises` | 16.4 | 20-0-0 | 15.5 |

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Weapon | Seal of the Turning Season (art) | A fifth Verdant Cycle art | Wood-sect quest, craft | In the catalogue | High |
| Extra | Grave-Silk Shroud | Corpse Rot from t = 0 | Elder of a Wood or poison sect, or a sunken tomb | In the catalogue | High |
| Rings | `stack_effect_pct`, `stack_duration_pct` (moc) | Stronger, longer Poison and Wood buff | Craft, quest | In the catalogue, but the engine has no stat for them | Medium |
| Armour | `health_regen_inc_pct` | Faster health regeneration | Craft | In the catalogue, but the engine has no stat for it | Medium |
| Any | Overheal becomes Poison (Surplus Life) | The guide's central engine | none | Missing | High |
| Any | Cleanse on a cast (Shedding Bark) | Strips curses | none | Missing | Medium |
| Any | Water buff / spring pool (Underground Spring) | Feeds the Water purity | none | Missing | Low |
| Armour | Final Clause (`general-hundred-patch-armour`) | A free last art as you go Down | NPC, event | In the catalogue | Low |

## Missing pieces

- An item that turns health overflow into Poison (Surplus Life), owned by the wood family.
- A cleansing item for Shedding Bark, owned by the wood family.
- A Water buff or spring item (Underground Spring), owned by the water family.
- Armour whose ward is a heal or a drain the engine can run, owned by the wood family.

## UNMODELLED

- Surplus Life (Dư Sinh): needs a health-overflow readable; the engine only emits linh lực overflow.
- Rooted (Bám Rễ) price: evade fixed at 0 is not expressible.
- Spillover (Dật Độc), on the Ring of the Slow Garden: no action burns the foe's linh lực from a tick.
- Gripping Root (Thousand Roots Banner): needs a Physical Wood hit, which this build never lands.
- Wards: Ironbark Shell and Heartwood Ward are cast wards, the Grave-Silk Veil is a Fire ward; the build keeps the realm's Common Ward, and the old Common-Ward-only gaps stand.
- Reserve arts (Verdant Aura 12 %, Web of Roots 15 %) and the Shroud's 15 % reserve: not deducted, grants not run.
- Item modifiers with no engine stat (health regeneration inc, stack effect and duration, linh lực %, khí huyết, healing taken, defence %, thần thức %): not run. Only the pendant's healing +10 and the `art_speed` of the seal and banner (applied to every art) ran.
- Underground Spring, Banyan Shade, Shedding Bark and the rest of the old guide's list.

## Observations

Gear mattered a little: the typical fight fell from 19.6 s to 16.4 s with 20 wins in both, and the top_end foe still kills the build in 2.0 s before any art fires, so gear changed nothing there. The fight is under the 30–60 s band both before and after; the build never goes dry and ends at 100 % health, so the geared kill still comes through the foe's linh lực (foe dry at 15.5 s), not a long Poison. Most of what the Wood items give is modifiers the engine has no stat for, so the run mostly shows the seal's art speed and its extra suite art. The Grave-Silk Shroud ran, but removing it moved the result by only 0.3 s, and Sap Rises changed nothing because the bar stays full. Dropping the seal's modifiers (art still slotted) added 0.7 s. Nothing looks degenerate. `second-spring` is gone from the slots; the seal's art fired 3.0 times a fight, and no slotted art fired nothing on the typical foe. Against top_end all seven arts fire nothing, as before.
