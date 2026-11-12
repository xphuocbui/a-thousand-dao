# The Brimming Hand (Mãn Tức Quyền), geared: a root-Earth brawler whose basic punch rides on a wall of body shields that burst back into hits. Realm: Nguyên Anh (nguyen_anh)

## Loadout

Budget: 45 × `divine_sense` (absent, 1.0) × (1 + 0 / 100) = 45 thần thức (TT). The build has no `than_thuc_pct` of its own (the anchor and the mail carry +2 each, which the engine does not read; not counted).

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon (base) | `earth-mountain-mooring-anchor` Mountain-Mooring Anchor (Hệ Sơn Mao) | 3 | Its art `earth-mooring-drop` belongs to Mountain Heart Canon, the build's main technique. It is slotted in place of `sinking-weight`. Its modifiers (Earth attack, art speed) are the only item numbers the engine reads. |
| Armour (base) | `earth-boulder-ring-mail` Boulder-Ring Mail (Cự Thạch Hoàn Giáp) | 3 | Physical resist, health regeneration and Iron Skin Renewed: the wall refills as the arts fire. |
| Ring (base) | `body-iron-skin-ring` Ring of Renewed Iron Skin (Thiết Bì Phục Giới) | 3 | Body shield +24 %, block, Iron Skin Renewed (the same Effect as on the mail, so it runs once). |
| Ring (base) | `earth-clay-seal-ring` Clay Seal Ring (Nê Ấn Giới) | 1 | Earth buff strength and 100 Physical resist; the best Earth ring the catalogue has at this grade. |
| Necklace (base) | `earth-remembering-stone-pendant` Pendant of the Remembering Stone (Thạch Ký Bội) | 2 | Earth buff strength, regeneration and a Still Stone Aura reserve (10 %). |
| Extra | `earth-unmoving-gate-shield` Unmoving Gate Shield (Bất Động Môn Thuẫn) | 4 (unique) | Shattering Ward: every body shield that breaks bursts on the foe. This is the build's concept. TT 15. |
| Extra | `body-flesh-seal` Seal of Unbroken Flesh (Bất Hoại Nhục Ấn) | 3 | Physical attack, body shield +20 %, Unbroken Flesh Canon art (not slotted). TT 30. |
| **Extras total** | | | **45 of 45 TT** |

## Before and after

Old = `engine-v2/builds/bare-fist.fight.json` re-run today (20 rolls each); the old guide's numbers (9.0 s typical) no longer match the engine, so these are the fresh ones.

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical, Nguyên Anh +0 | 15.1 | 13.1 | 20-0-0 | 20-0-0 |
| typical, Hóa Thần +1 | 31.8 | 29.2 | 20-0-0 | 20-0-0 |
| top_end, Nguyên Anh +0 | 12.8 | 13.9 | 0-20-0 | 0-20-0 |
| top_end, Hóa Thần +1 | 5.2 | 5.5 | 0-20-0 | 0-20-0 |

`--without` (typical, Nguyên Anh +0, geared 13.1 s, 20-0):

| Removed | Mean s | W-L-other | Result |
|---|---|---|---|
| `item:earth-mountain-mooring-anchor` | 14.9 | 20-0-0 | changed (+1.8 s) |
| `eff:Shattering Ward` | 13.1 | 20-0-0 | NO_CHANGE |
| `eff:Iron Skin Renewed` | 13.1 | 20-0-0 | NO_CHANGE |

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Weapon | `earth-mountain-pressing-seal` (unique) art `earth-mountain-presses-sky` | A heavier Earth engine art, the Mountain Seal keystone | Unique, holder per its record | In the catalogue (not tried: Ấn is a weapon base, and the weapon slot is taken) | Medium |
| Extra | Engine stat for body shield, stack strength and duration | The items' main numbers (body shield, Earth stacks) would count | Engine work | Missing from the engine, not the catalogue | High |
| Ring or extra | An Effect that makes a body shield break on purpose or refill after a break | Gives Shattering Ward something to fire on | Earth or body family | Missing | High |
| Armour | A body-shield ward that stacks with the Mountain Screen | Layered wards the engine runs | Body family | Missing | Low |
| Extra | `body-mountain-gate-shield` | A second body ward, 15 TT | Body family | In the catalogue; no room in the 45 TT | Low |

## Missing pieces

- A technique that drives the basic punch (Stored Breath, basic speed and coefficient): the Uncarved Stone Fist has no library twin; the body family should own an item or Effect for it.
- An item that makes a ward or shield *break* on a clock (so Shattering Ward and `bastion-reprisal` fire often): earth or body family.
- A utility treasure that adds `than_thuc_pct`, so more than 45 TT of extras fit: general family.

## UNMODELLED

- Unmoved Stance (gate shield): the build slots no stance, so it would fire nothing.
- Item wards Boulder Shell and Gate Screen: the engine models only the drain ward; the old one is kept.
- Remembering-stone pendant reserve (Still Stone Aura, 10 %): reserve shares and their grants are not run.
- Item modifiers with no engine stat (all `body_shield_pct`, `khi_huyet_pct`, `defense_pct`, `health_regen_inc_pct`, Earth `stack_effect_pct` and `stack_duration_pct`, `than_thuc_pct`): not run.
- Item art-speed with a tag scope: the engine applies it to every art, so the anchor's +12 % is slightly generous.
- The old file's own lines (Closed Hand Vow, Stored Breath and the rest, basic speed and coefficient, layered wards, `mountain-stance`) stay unmodelled as before.

## Observations

Gear mattered a little: the typical Nguyên Anh fight shortened from 15.1 to 13.1 s and the Hóa Thần +1 fight from 31.8 to 29.2 s, and removing the anchor (the only item whose numbers the engine reads, plus its art in place of `sinking-weight`) puts it back to 14.9 s. Against the top-end foe the gear made no difference to the result (still 0-20; 12.8 to 13.9 s, 5.2 to 5.5 s). Only the Hóa Thần +1 typical fight is inside 30-60 s (29.2 s, just short); the Nguyên Anh fight at 13.1 s is far below it. No item made the build degenerate. The two item Effects written as engine Effects, Iron Skin Renewed and Shattering Ward, both returned NO_CHANGE under `--without`: they fired nothing the fight could see, most likely because the engine's body shield (which its modifiers cannot raise, having no stat) rarely breaks or is never in play, so the wall stays unmeasured. `bastion-reprisal` still never fires against the top-end foe at Hóa Thần +1. The Unmoved Stance and the item wards fired nothing because they cannot run here.
