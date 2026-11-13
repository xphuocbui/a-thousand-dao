# beast-carry — Raising the Tiger (Dưỡng Hổ): a spirit beast (linh thú) does the killing while you feed, heal and ward it. Realm: Nguyên Anh (nguyen_anh).

Fight file: `design/builds/engine-v3/builds/beast-carry.fight.json` (the v2 file plus `items`, one swapped-in item art and two Effects; `layers` since lowered, see Budget revision). The v2 file was itself a reconstruction from the guide (see `design/builds/engine-v2/beast-carry.md`), so "old" below means that file.

## Loadout

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon | Verdant Cycle Seal (Thanh Hoàn Ấn) `wood-cycle-seal` | 3 | Its art Seal of the Turning Season counts as a Verdant Cycle Scripture art (the build's main technique), plants Wood stacks and heals 2 % on its empowered firing; Wood buff modifiers |
| Armour | Phoenix Plume Armour (Phượng Vũ Giáp) `fire-phoenix-plume-armour` | 3 | Healing +14 %, health regeneration +20 %; Phoenix Mend turns every heal into Burn on the foe, so the healing the build already does adds damage |
| Ring | Cinder Ring (Hỏa Tẫn Giới) `fire-cinder-ring` | 1 | Stronger Fire buff stacks (Feed the Fire's identity), a little health |
| Ring | Sprout Ring (Manh Nha Giới) `wood-sprout-ring` | 1 | Health regeneration +20 %, stronger Wood buff |
| Necklace | Sap-Heart Pendant (Dịch Tâm Bội) `wood-sap-heart-pendant` | 2 | Healing +10 %, health regeneration +28 %, a Wood-aura reserve art |
| Extra 1 | Heartwood Bulwark (Tâm Mộc Thuẫn) `wood-heartwood-bulwark` | 3 | Sap Rises (up to +20 % healing from Wood stacks), +40 % health regeneration, a cast shield to cover the beast's owner |
| Extra 2–5 | empty | | Nothing in the catalogue served the beast (see Missing pieces); Gripping Root (Thousand Roots Banner) needs a Physical Wood hit, the beast's bite is Physical but not Wood, so it would fire nothing |

Thần thức (TT) of the extras: 15 against a limit of 45 × 1.0 (no `divine_sense` in the file) × (1 + than_thuc_pct/100); the Plume Armour's +4 % thần thức only raises it, so 15 ≤ 45 holds. Base slots cost none. Grades 1–3, all within the grade-4 cap.

Art slots: the Seal's art is slotted as `{"lib": "wood-seal-of-turning-seasons"}` as a third art. fight.py printed no `slots_over` note, so the realm has the room; I did not remove either old art.

## Before and after

`--matrix`, 20 fights per matchup.

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical nguyen_anh+0 | 1.5 | 18.5 | 20-0-0 | 20-0-0 |
| typical hoa_than+1 | 5.0 | 16.0 | 20-0-0 | 0-20-0 |
| top_end nguyen_anh+0 | 2.0 | 2.0 | 0-20-0 | 0-20-0 |
| top_end hoa_than+1 | 1.0 | 1.0 | 0-20-0 | 0-20-0 |

`--without` (this command runs only typical nguyen_anh+0; every one printed NO_CHANGE, 1.5 -> 1.5 s, 20 -> 20 wins):

| Removed | Result |
|---|---|
| `item:wood-cycle-seal` (the item that matters most: the only item art and a suite piece) | NO_CHANGE, 1.5 -> 1.5 s, wins 20 -> 20; the Seal never fired in that fight |
| `eff:Phoenix Mend` | NO_CHANGE, 1.5 -> 1.5 s, wins 20 -> 20 |
| `eff:Sap Rises` | NO_CHANGE, 1.5 -> 1.5 s, wins 20 -> 20 |

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Weapon or extra | Companion damage / companion speed modifier | The beast hits harder or faster; the build's whole damage | Beast gear, beast-taming quests | Missing | High |
| Any | Fire buff stack effect and duration | Feed the Fire stacks hold longer | Fire items (Cinder Ring has +10 % on the buff) | In the catalogue (small) | Medium |
| Armour | Phoenix Mend | Heals add Burn | Phoenix Plume Armour, event/craft/quest/npc | In the catalogue | Medium |
| Extra | Sap Rises | Up to +20 % healing from Wood stacks | Heartwood Bulwark | In the catalogue | Medium |
| Necklace | Healing and reserve | Fire-stack aura reserve (Hearth-Keeper Pendant: healing 6 %, Fire buff and debuff aura) as the alternative necklace | Fire catalogue | In the catalogue | Low |
| Extra | Beast-share modifier (more share of damage from the companion) | Straining Leash's engine fed by gear | Beast gear | Missing | High |
| Any | Down-prevention / beast shield | Keeps the tiger standing while you heal | Beast gear | Missing | High |

## Missing pieces

- A companion's weapon or collar giving companion damage, companion speed and a companion hit filter (Sure Bite, Marked Prey on companion hits): wood family, or `general`.
- A beast-ward item, a shield or redirect that protects the companion's health bar (the Shared-Heart Contract's Down and Rouse): wood family.
- An item Effect that feeds the beast's 0.5 s timer from art speed (Bonded Spirit): wood family.
- A Fire-stack utility item for the extra slots (more Fire buff stacks per cast, which the beast's Feed the Fire wants): fire family.

## UNMODELLED

- Shared-Heart Contract: the beast's own health bar, 30 % redirect, Down and Rouse are not an engine concept.
- Straining Leash: needs a companion share the engine cannot read.
- Bonded Spirit and Lent Hand: only the 0.5 s companion timer is written; art speed does not feed it.
- Sure Bite, Roused, Pack Hunt, Marked Prey, Rain on Both: no companion hit filter.
- Phoenix Shell and Heartwood Ward: item shields (cast, cooldown 4 s, up 3 s) are not drain wards, and I did not replace the realm default ward with an invented one.
- Verdant Aura (Sap-Heart Pendant reserve art): reserve shares and their grants are not run.
- Item plain modifiers with no engine stat (stack effect and duration, health regeneration, defence, khí huyết, linh lực, thần thức) printed as unmodelled; only attack and the like would have applied, and the gear here carried almost none.
- Gripping Root and Fan the Pyre were not written (not relied on).

## Observations

Gear did not matter in these fights. Three of four matchups are unchanged; only typical hoa_than+1 moved, 5.0 -> 4.0 s, both runs 20-0-0, and in the geared run the second-spring heal fired 0.3 times and the Seal once while warm-the-hearth did not fire at all. The three `--without` tests on typical nguyen_anh+0 all printed NO_CHANGE because the fight ends in 1.5 s, before any art's first firing, so neither Effect and neither item art ever ran; Phoenix Mend and Sap Rises are modelled but fired nothing (the Sap Rises scale needs Wood stacks, and the Seal that would give them did not fire in the short fight). The fights are far outside the 30-60 s band (1.0-4.0 s), and the top_end foes still kill the build in 1.0-2.0 s, because the realm's default body and ward are unchanged and the item shields are unmodelled. No item made the build degenerate; nothing in the geared run is strong enough to. Items that fired nothing: every item Effect and the Seal's art in three of four matchups. Most of the loadout's value (health regeneration, stack effect, defence, khí huyết) is in stats the engine does not read, so the true effect of this gear cannot be seen here.

## Budget revision (2026-11-13)

**What changed:** `layers` went from `[332, 300, 250, 110, 89]` to `[332, 40, 40, 20, 0]`. The claimed share of the typical-to-top-end gap fell from 94 % to 18 % (Nguyên Anh budget 23 %); `fight.py` now prints `layer_budget`.

**Why:** the techniques' passives and the items' modifiers already run as Effects, so the old L2-L5 numbers counted them twice. They were also a reconstruction from the v2 guide's multipliers, not Meridian Map points. L2-L4 are now the typical enemy's values (they claim nothing). L1 (332) is kept whole because the beast's bite is the concept; L5 (89, which stood in for the unmodelled Straining Leash) was cut first. No technique, item or art was removed.

**How the fights moved (20 fights each):**

| Matchup | Old mean s, wins | New mean s, wins |
|---|---|---|
| typical nguyen_anh+0 | 1.5 s, 20-0-0 | 18.5 s, 20-0-0 |
| top_end nguyen_anh+0 | 2.0 s, 0-20-0 | 2.0 s, 0-20-0 |
| typical hoa_than+1 | 4.3 s, 20-0-0 | 16.0 s, 0-20-0 |
| top_end hoa_than+1 | 1.0 s, 0-20-0 | 1.0 s, 0-20-0 |

The typical same-realm fight now sits in the 10-20 s target and the arts fire (warm-the-hearth 3.0, the Seal 6.0 per fight; second-spring 0.0 there, 1.9 against hoa_than+1). The build loses to both top-end foes and to a typical Hóa Thần foe; it needs pieces, not layers, to close that (see Missing pieces).

GEAR-DONE beast-carry
