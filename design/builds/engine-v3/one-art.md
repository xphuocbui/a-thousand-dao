# The Empty Hall (Không Đường): carry one art and leave every other slot empty, so each empty slot speeds the art up and rings a Metal stack onto the foe.

Realm: Deity Transformation (Hóa Thần, `hoa_than`). File: `builds/one-art.fight.json`. Geared from `design/builds/engine-v2/builds/one-art.fight.json`; the only changes are `"items"` and one engine Effect.

## Loadout

All five pieces sit in the base slots. The six extra slots are left empty on purpose: the build's Empty Hall and Vow of the One Stroke pay per empty slot, and the thần thức budget is not the limit (45 × 1.0 × (1 + 0 %) = 45 allowed, 0 used).

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon | Hundred-Edge Flying Sword (Bách Nhận Phi Kiếm) `metal-hundred-edge-flying-sword` | 3 | Sword attack, sword art speed and Metal debuff-stack strength and duration. Its own art (Hundred-Edge Flight) is not slotted, so the build stays one art. |
| Armour | Tortoise-Scale Armour (Quy Lân Giáp) `metal-tortoise-scale-armour` | 3 | Metal family armour: Physical resistance, health and a ward. |
| Ring 1 | Ring of the Returning Edge (Phong Hồi Giới) `metal-ring-of-returning-edge` | 3 | Physical crit chance and damage, Metal art speed, and the Effect Edge Returns the Breath. |
| Ring 2 | Iron Temper Ring (Thiết Thối Giới) `metal-iron-temper-ring` | 1 | Physical crit chance, health, Metal buff strength. |
| Necklace | Whetstone Jade Pendant (Thạch Mài Ngọc Bội) `metal-whetstone-jade-pendant` | 2 | Linh lực and regeneration; its reserve art Keen Edge Aura adds Metal debuff strength and art speed. |
| Extra 1–6 | empty | – | Kept empty for the Empty Hall. |
| **Thần thức** | 0 of 45 | | Within the limit. |

## Before and after

`--matrix` of the old file and the geared file (20 seeds each).

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical, same realm | 12.0 | 10.2 | 20-0-0 | 20-0-0 |
| top_end, same realm | 2.0 | 2.0 | 0-20-0 | 0-20-0 |

Other readings, typical: health left 94 % old, 100 % geared; foe dry at 11.3 s old, 9.2 s geared; cleave fires 4.1 old, 3.2 geared; trig_budget clip 3.1 old, 1.4 geared. Top_end: you are dry at 2.0 s in both and the cleave never fires (NEVER_FIRED) in both.

`--without` (geared, typical):

| Removed | Mean s | W-L-other | Foe dry | Health left | Cleave fires |
|---|---|---|---|---|---|
| none | 10.2 | 20-0-0 | 9.2 | 100 % | 3.2 |
| `item:metal-ring-of-returning-edge` (the item that matters most) | 10.9 | 20-0-0 | 10.1 | 100 % | 3.5 |
| `item:metal-hundred-edge-flying-sword` | 10.6 | 20-0-0 | 10.0 | 100 % | 3.4 |
| `eff:Edge Returns the Breath` | 10.2 | 20-0-0 | 9.2 | 100 % | 3.2 (NO_CHANGE) |

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Weapon | stack strength and duration (Metal debuff) | Longer, stronger Metal stacks for the cleave to cash in | Sword drops, Hundred Blades Canon disciples | In: `metal-hundred-edge-flying-sword` (engine does not read stack stats) | Medium |
| Ring | Physical crit and crit damage | Higher crit, more damage per cleave | Craft, NPC | In: `metal-ring-of-returning-edge` | High |
| Weapon (unique) | Effect Marked Prey | Extra damage on a marked foe | Quest, event | In: `blade-thousand-cut-sword` (grade 4, not run here) | Low |
| Any slot | art speed for a single art | Faster cleave without filling extra slots | – | Missing | High |
| Any slot | an Effect that rewards empty slots | Makes gear worth wearing for this build | – | Missing | High |

## Missing pieces

- A ring or pendant that adds to the single art's coefficient or cooldown, so the base slots can help without leaving the one-art idea (Metal family).
- A Metal item whose Effect scales with empty slots, so geared and empty play agree (Metal family).
- A Metal armour with a plain Metal-damage ward and no health spend, since the Tortoise-Scale Shell does not change this blind fight (Metal family).

## UNMODELLED

- Vow of the One Stroke: no key for the extra coefficient, and arts take no overrides.
- Empty Hall rings: only the 6 Metal stacks are modelled; the free echo hit of each ring is not.
- Called Blow: a fixed 33.3 % chance; the real meter is deterministic.
- Six wards: modelled as the realm's typical Common Ward.
- Single-Notch Sword: reduced to +30 art speed and Blood Drinker 6 %.
- Open Sky, Whole Weight and plain armour: folded into layers L2 80 and L3 40; no preparation.
- Item Tortoise-Scale Shell ward (Physical 105.3, cast 0.0555): it is not better than the build's Common Ward by the file's own ward numbers, and the engine's nearest drain ward is the existing one, so it is not modelled.
- Item Effect Iron Skin Renewed: the build does not rely on it.
- Keen Edge Aura reserve art: the 15 % reserve is not deducted and its grants are not run.
- Item modifiers with no engine stat: stack effect and duration, health (khi_huyet), defence, health regeneration, linh lực. Sword and Metal art speed apply to every art.
- Technique passives as in the old file.

## Observations

Gear shortened the typical fight from 12.0 s to 10.2 s with 20 wins in both and top_end still lost in 2.0 s with the cleave never firing, so gear moved the easy fight and not the hard one. The fight is well under the 30–60 s band in both files. No item made the build degenerate. Removing the Ring of the Returning Edge or the sword each cost 0.4–0.7 s, so both do something small; Edge Returns the Breath fired nothing measurable, because the build is never dry against the typical foe. The old file here gives 12.0 s, not the 8.1 s the old guide reports; its guide said its file was missing, so this guide's numbers come from the file on disk. Filling base slots may cost the Empty Hall some empty-slot value, which the engine cannot see (the Vow is unmodelled). Each number is one run of 20 seeds, not a verdict.

GEAR-DONE one-art
