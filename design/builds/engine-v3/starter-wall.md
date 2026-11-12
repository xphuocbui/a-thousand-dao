# The Patient Wall (Nại Bích): an Earth-root cultivator, very hard to kill, who wins slowly on ward, body and regeneration. Realm: Foundation Establishment (Trúc Cơ, `truc_co`).

Fight file: `design/builds/engine-v3/builds/starter-wall.fight.json`. Everything in the engine-v2 file is kept; this version adds `"items"`, one art swap and two item Effects. No number was tuned.

## Loadout

Grade cap at this realm is 3; no unique item is worn. `divine_sense` is absent (1.0). The extra-slot limit is 45 × 1.0 × (1 + 0/100) = 45, counting the build's own than_thuc_pct as 0 (the items' own +2, +2 and +3 would lift it to about 48; the loadout does not need that).

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon | Mountain-Mooring Anchor (Hệ Sơn Mao), `earth-mountain-mooring-anchor` | 3 | Its art Mooring Drop (Mao Trầm Địa; `earth-mooring-drop`) counts as a Mountain Heart Canon art, lays 2 Strata and, with 5 Strata and the stance up, moors the foe. Slotted in place of `sinking-weight`. |
| Armour | Boulder-Ring Mail (Cự Thạch Hoàn Giáp), `earth-boulder-ring-mail` | 3 | Physical resistance, health regeneration +25 % and Iron Skin Renewed; its Boulder Shell ward is smaller than the build's drain ward, so the ward is not replaced. |
| Ring 1 | Ring of Renewed Iron Skin (Thiết Bì Phục Giới), `body-iron-skin-ring` | 3 | Body shield +24 %, block, health regeneration; carries Iron Skin Renewed again (the Effect fires once per pulse, so two copies do not stack). |
| Ring 2 | Clay Seal Ring (Nê Ấn Giới), `earth-clay-seal-ring` | 1 | Earth buff stack effect +12 %, Physical resistance, health pool. |
| Necklace | Pendant of the Remembering Stone (Thạch Ký Bội), `earth-remembering-stone-pendant` | 2 | Earth buff stack effect +20 %, linh lực regeneration +10 %, defence; reserve art Still Stone Aura. |
| Extra 1 | Boundary Flag of the Field Lord (Điền Chủ Giới Kỳ), `earth-boundary-flag` — TT 20 | 2 | Planted Banner: Earth parts deal 2 % more per 4 Earth buff stacks, and the stance keeps Earth buff stacks on you. |
| Extra 2 | Mountain-Gate Shield (Sơn Môn Thuẫn), `body-mountain-gate-shield` — TT 15 | 2 | A cast body shield beside the body shield, block +20, body shield +10 %. |
| Extra 3 | empty | | Nothing fit in the 10 thần thức left that served the wall. |

Thần thức spent: 20 + 15 = **35 of 45**.

## Before and after

Old = the engine-v2 file run today (the engine has moved since the v2 guide, which printed 31.7 s at Trúc Cơ; the old column below is the fresh run). 20 fights per row.

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical Trúc Cơ (same realm) | 37.1 | 30.8 | 20-0-0 | 20-0-0 |
| typical Kết Đan +1 | 21.5 | 65.7 | 0-20-0 | 1-6-13 |
| typical Nguyên Anh +2 | 4.7 | 7.9 | 0-20-0 | 0-20-0 |
| top_end Trúc Cơ | 2.0 | 2.0 | 0-20-0 | 0-20-0 |
| top_end Kết Đan +1 | 1.0 | 1.6 | 0-20-0 | 0-20-0 |
| top_end Nguyên Anh +2 | 1.0 | 1.0 | 0-20-0 | 0-20-0 |

Typical Trúc Cơ, geared: you are never dry, the foe runs dry at 22.9 s (old 29.7 s), health left 100 %. At Kết Đan +1 the "other" column is fights that hit the time limit.

`--without` (typical Trúc Cơ, geared, 30.8 s, 20-0-0):

| Removed | Result |
|---|---|
| `item:earth-mountain-mooring-anchor` | 37.4 s, 20-0-0, foe dry 29.7. The art stays slotted (it is in the file), so this removes only the anchor's passives; the fight is 6.6 s longer, back to the old file's length. |
| `eff:Iron Skin Renewed` | 30.8 s, 20-0-0, no change (identity NO_CHANGE) |
| `eff:Planted Banner` | 30.8 s, 20-0-0, no change in mean; foe dry 23.6 instead of 22.9 |

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Weapon (Kết Đan) | Mountain Presses the Sky, art `earth-mountain-presses-sky` | The Mountain Seal's keystone art; a bigger engine piece than Mooring Drop | Unique item `earth-mountain-pressing-seal` (grade 4, only at Kết Đan) | In the catalogue | High at Kết Đan |
| Extra / ward gear (Kết Đan) | Shattering Ward, Unmoved Stance (new) | Bursts a broken shield and holds the stance | Unique `earth-unmoving-gate-shield` (grade 4) | In the catalogue | High at Kết Đan |
| Necklace | Debt of Stone (new) | Health-payer Effect; does not suit a wall that never pays health | `earth-stone-debt-necklace` | In the catalogue | Low |
| Ring | Health regeneration and body shield modifiers | More sustain | Craft or quest | Partly (Iron Skin ring, Boulder mail) | Medium |
| Armour | Cast Physical ward larger than 342.5 drain points | Would replace the drain ward | Earth or body armour | Missing | Medium |
| Any | Heal when health is at or below 60 % | Replaces the lost Mending Breath | Earth or body item art | Missing | Medium |
| Extra | Stone Does Not Hurry-like Per modifier on the basic attack | Slow-fight damage | Earth item | Missing | Low |

## Missing pieces

- A heal art (health ≤ 60 %) for an Earth wall, replacing Mending Breath: owned by the earth family (body as second choice).
- An armour ward above the starter drain ward for a body-and-Earth wall: owned by the body family.
- An Earth ring or extra piece that feeds Strata directly (a counter source other than arts): owned by the earth family.

## UNMODELLED

- Mountain-Gate Ward (cast body shield, σ 0.18): the file has no cast shield of that kind, and the build's drain ward is larger.
- Boulder Shell (cast Physical ward, 105.3 points): below the drain ward (342.5), so the drain ward stays.
- Item plain modifiers (defence, resistance, khi huyết, stack effect and duration, body shield, block, health regeneration, thần thức): the file keeps every number, so none are added to `layers`; the engine has no stat for stack effect, stack duration, body shield, khi huyết or defence anyway.
- Still Stone Aura (the pendant's reserve art): the engine reports it as not deducted and its grants not run.
- Hộ Sơn Trận (formation, home ground only), Kim Cương Phù (prepared defence) and Stone Does Not Hurry (needs a new key): as in the old file.
- Mountain-Mooring Anchor's art_speed_pct is Earth-scoped, but the engine applies it to every art (reported by the engine).

## Observations

Gear changed the typical same-realm fight modestly: 37.1 s to 30.8 s, still 20-0 with 100 % health left, which is at the edge of the 30-60 s band (just above it). The shorter fight comes from the anchor's passives (removing the anchor item puts it back to 37.4 s), not from the art, which the file already counted; the engine reads the anchor's Earth-scoped art speed as speed on every art. One realm up the geared wall is no longer a clean loss: 1 win, 6 losses and 13 fights that hit the time limit at 65.7 s, so the wall now outlasts that foe, which makes it the slow, hard-to-kill build in the concept, but not a degenerate one, since it cannot kill. Nguyên Anh +2 and the top-end foes still end in 1-8 s. Nothing went degenerate. Of the items, Iron Skin Renewed fired but changed nothing (its refill was clipped 0.3 times per fight and the shield is rarely empty), Planted Banner changed only the foe's dry time (22.9 s against 23.6 s), and the plain-modifier items fired nothing because the engine has no stat for most of their modifiers. NEVER_FIRED: at Nguyên Anh +2 strata-hammer; at every top_end row all four arts. The two Effects and the anchor's art matter little here; the sustain this build wants is in modifiers the engine cannot yet read.

GEAR-DONE starter-wall
