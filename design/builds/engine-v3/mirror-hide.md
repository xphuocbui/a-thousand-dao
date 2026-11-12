# Mirror Hide (Kính Bì), geared

A Thổ-Kim (Earth-Metal) block tank that stands behind stacked body layers and lets every blow come back at the enemy as a reprisal. Realm: Core Formation (Kết Đan). Built on Mountain Heart Canon (Sơn Tâm Kinh) and Iron Hide Manual (Thiết Bì Quyết); see `design/builds/engine-v2/mirror-hide.md` for the technique choices.

Fight file: `design/builds/engine-v3/builds/mirror-hide.fight.json`. Changes from the old file: the `items` list, Sinking Weight swapped for the anchor's Mooring Drop (`{"lib": "earth-mooring-drop"}`), the ward set to a drain ward from Boulder Shell (payload 105.3, ws 0, no other ward layers), and two engine Effects. Every number else is as it was.

## Loadout

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon | Mountain-Mooring Anchor (Hệ Sơn Mao) `earth-mountain-mooring-anchor` | 3 | Its art Mooring Drop counts as a Mountain Heart Canon art, lays Strata and moors the foe (spends 5 Strata for a 2.8× hit, Slowed Time and a delay on every foe art). It feeds Strata Hammer. |
| Armour | Boulder-Ring Mail (Cự Thạch Hoàn Giáp) `earth-boulder-ring-mail` | 3 | A Physical cast ward (Boulder Shell) where the build had none, and Iron Skin Renewed. |
| Ring 1 | Ring of Renewed Iron Skin (Thiết Bì Phục Giới) `body-iron-skin-ring` | 3 | Body shield +24 %, block rating +20, and the same Iron Skin Renewed (it does not stack past once a pulse). |
| Ring 2 | Clay Seal Ring (Nê Ấn Giới) `earth-clay-seal-ring` | 1 | Stronger Earth buff stacks, Physical resist, health. The only Earth ring. |
| Necklace | Necklace of Stone Debt (Thạch Trái Liên) `earth-stone-debt-necklace` | 3 | Health regeneration +30 %, leech, healing +12 %, Earth buff stacks +24 %. |

| Extra slot | Item | Grade | TT | Why it is here |
|---|---|---|---|---|
| Extra 1 | Unmoving Gate Shield (Bất Động Môn Thuẫn) `earth-unmoving-gate-shield` | 4 unique | 15 | Body shield +40 %, Physical resist, Shattering Ward (a broken shield bursts on the foe). Unmoved Stance would remove Mountain Stance's slowness. |
| Extras 2–4 | empty | | 0 | Nothing else in the catalogue serves the build (see Missing pieces). |

Thần thức total: 15 of at most 46.8 (45 × divine_sense 1.0 × (1 + 4 % than_thuc from the anchor and the mail)). No extra slot breaks the rule. Grades are within the Kết Đan cap of 4; the one unique item is grade 4.

## Before and after

Kết Đan file, `--matrix`, 20 fights per row. Old numbers were re-run on the current engine, so they differ from the v2 guide's table.

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical ket_dan+0 | 5.0 | 5.0 | 20-0-0 | 20-0-0 |
| typical nguyen_anh+1 | 7.1 | 7.5 | 20-0-0 | 20-0-0 |
| typical hoa_than+2 | 24.5 | 19.8 | 20-0-0 | 20-0-0 |
| top_end ket_dan+0 | 65.0 | 66.1 | 20-0-0 | 20-0-0 |
| top_end nguyen_anh+1 | 51.6 | 46.9 | 11-9-0 | 9-11-0 |
| top_end hoa_than+2 | 2.6 | 2.6 | 0-20-0 | 0-20-0 |

Geared, you run out of linh lực in the top_end rows (7.6 s at top_end ket_dan+0, 3.5 s at nguyen_anh+1, 2.0 s at hoa_than+2); the old file never ran dry.

`--without`, typical ket_dan+0 (the command tests only this row):

| Test | Mean s before | Mean s after | W-L | Result |
|---|---|---|---|---|
| `--without item:earth-mountain-mooring-anchor` | 5.0 | 5.0 | 20-0 → 20-0 | NO_CHANGE |
| `--without eff:Iron Skin Renewed` | 5.0 | 5.0 | 20-0 → 20-0 | NO_CHANGE |
| `--without eff:Shattering Ward` | 5.0 | 5.0 | 20-0 → 20-0 | NO_CHANGE |

Without the anchor, `earth-mooring-drop` still fired (1.0 per fight), because the file slots its art by hand; the test removed only the anchor's passives (which the engine mostly cannot run), so it says nothing about the art.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Weapon | Earth `stack_effect_pct` and `stack_duration_pct` on debuffs | Longer, bigger Sinking Weight and Mooring Drop stacks | Anchor (has +30 each); the Pressing Seal has +36/+40 | In the catalogue; the engine has no stat for it | High |
| Armour | A ward that stops Physical hits and adds Return | The Return channel the build lost | Earth or body family armour | Missing | High |
| Ring | Effect: a free Physical hit scaled by the hit stopped | The old "return" (Phản) | A body or earth ring | Missing | High |
| Extra | Effect that pays Strata for each hit taken | Feeds Strata Hammer, which fired only 3.4 times per top-end fight | An earth utility treasure | Missing (Planted Banner `earth-boundary-flag` is unread) | Medium |
| Necklace | Metal (Kim) pieces for the Iron Hide Manual | Metal Physical resist, block | Metal family armour or necklace | Metal pieces (`metal-tortoise-scale-armour`) are in the catalogue, not slotted | Medium |
| Ring | Linh lực regeneration or cost reduction | The geared build runs dry in top_end fights | Any family | In the catalogue as `linh_luc_regen_inc_pct` (Remembering Stone Pendant) but the engine has no stat | Medium |

## Missing pieces

- A Return-channel Effect (a free Physical hit scaled by the damage stopped, with a cap): body family, ring or armour.
- A Physical-and-Metal armour that pays Return from block: metal family (Tortoise Scale Shell has none).
- A health-payment art for the build, so Debt of Stone has something to read: body family.
- A treasure that banks clipped return (the old Held Reflection): earth or general family.

## UNMODELLED

- Return channel (Phản): no engine event scales a free hit by the size of the hit taken.
- Mirror-Scale Hide enabler, Held Reflection bank, Self-Wound Counts, Boil Returned, Bait curse: no engine event for them.
- Unmoved Stance (Gate Shield): the engine cannot remove the speed penalty of a library stance.
- Gate Screen ward (Gate Shield): a standing shield; only Boulder Shell is written as the drain ward.
- Debt of Stone (Stone Debt Necklace): the build pays no art in health, so it would never fire.
- Item passives with no engine stat: `stack_effect_pct`, `stack_duration_pct`, `than_thuc_pct`, `khi_huyet_pct`, `defense_pct`, `health_regen_inc_pct`, `body_shield_pct` (all five items), and the anchor's Earth-scoped `art_speed_pct` (the engine would apply it to every art).

## Observations

Gear moved little: five of six rows are within about ±1 s, and the one clear change was typical hoa_than+2 (24.5 s to 19.8 s, still 20-0). It lost one win in the top_end nguyen_anh+1 row (11-9 to 9-11), which is inside the 20-fight noise. Almost nothing the items carry is modelled: the plain modifiers all print as no engine stat, so what actually ran was the Mooring Drop art, the drain ward, Iron Skin Renewed and Shattering Ward. The typical rows stay at 5–8 s, well under 30–60 s, except hoa_than+2 at 19.8 s; the top_end same-realm row is 66.1 s, a little over the band. No item made the build degenerate. Mooring Drop replaced Sinking Weight and pulled more linh lực, so the build runs dry in all top_end rows where it used not to; Strata Hammer fires 3.4 times (was 10.0) at top_end ket_dan+0 and 0.8 at nguyen_anh+1, so the swap starved it, which is the opposite of the anchor's purpose. Iron Skin Renewed and Shattering Ward each gave NO_CHANGE in the typical row. Iron Skin Renewed was clipped 1.0 per fight at typical ket_dan+0 (the fight output reports the clip; I did not check why). I did not read per-Effect fire counts for Shattering Ward, so I cannot say whether it fired. NEVER_FIRED at typical ket_dan+0: bastion-reprisal and strata-hammer; at top_end hoa_than+2: all of the arts but mountain-stance.
