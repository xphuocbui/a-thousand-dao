# The Unmaker (Hủy Nguyên Giả), built on the Mirror of Primordial Chaos (Hỗn Nguyên Kính)

A Ruin Ledger curse stacker that tries to strip the foe's element stacks and book each one as a status for its Fray and distinct-status reads. Realm: Core Formation (Kết Đan, ket_dan), grade 4 at most. Root (linh căn): Earth (Thổ, `purity` earth 80).

## How it works

- The engine is the Ruin Ledger Scripture (Phế Trướng Kinh): Fraying Thread counts a Fray for every status or stack batch you land, and at 6 Fray it tears for 3 times the force. Ripening Curse hits 3 % harder per different status on the foe. Gathered Ruin Verdict banks 3 % damage more per batch.
- Mountain Heart Canon (Sơn Tâm Kinh) is the main method; Sinking Weight lays Earth stacks on the foe, a second batch for the Fray. The weapon, the Balance-Sheet Seal (Kết Toán Ấn), adds Settle the Account, a fourth Ruin Ledger art.
- The Mirror's Effect, Unmaking Glass, strips 1 buff stack from the foe's largest pile on a hit (once a pulse) and counts it as a status landed. It has nothing to read unless the foe holds buff stacks.
- Its plain modifiers are Chaos-scoped attack and debuff-stack strength; the engine reads none of the scoped ones as they stand (see UNMODELLED).
- Its reserve art Still Reflection (Tĩnh Ảnh) is not deducted or run.

## Loadout

| Slot | Item | Grade | Why |
|---|---|---|---|
| Unique (extra, TT 18) | `force-chaos-primordial-mirror` Mirror of Primordial Chaos (Hỗn Nguyên Kính) | 4 | Unmaking Glass; +4 % thần thức; reserve art Still Reflection |
| Weapon | `force-chaos-ledger-seal` Balance-Sheet Seal (Kết Toán Ấn) | 3 | Chaos attack +16 and its art Settle the Account, a Ruin Ledger art that feeds Fray |
| Armour | `force-chaos-hollow-robe` Hollow Robe (Không Y) | 2 | Chaos resistance +100 and +6 % thần thức; its Force ward is not run (typical ward kept) |
| Ring 1 | `force-chaos-hollow-ring` Hollow Ring (Không Giới) | 1 | Chaos attack +8, stronger debuffs |
| Ring 2 | `force-chaos-open-vein-ring` Open-Vein Ring (Khai Mạch Giới) | 3 | Health regeneration; its Blood Drinker is not written |
| Necklace | `force-chaos-ledger-murmur-pendant` Ledger-Murmur Pendant (Phế Thanh Bội) | 2 | Chaos attack +12, debuff strength, linh lực regeneration; reserve art Murmuring Debts |
| Extra 2 (TT 15) | `force-chaos-ledger-branding-iron` Ledger Branding Iron (Phế Trướng Lạc Thiết) | 2 | Curse attack +14, curse speed +8, +4 % thần thức; Marked Prey not written |

Extra slots used: 2 of 4 (the other two are empty). Thần thức: 18 + 15 = 33 against a limit of 45 × (1 + (4 + 6 + 4) / 100) = 51.3.

**Techniques:** main `mountain-heart-canon`; auxiliary `ruin-ledger-scripture` (one auxiliary slot left empty).
**Arts (5 of 5):** `fraying-thread`, `ripening-curse`, `gathered-ruin-verdict` (Ruin Ledger), `force-chaos-settle-the-account` (the weapon's), `sinking-weight` (Mountain Heart, layer 2).
Layers [112, 40, 40, 20, 10] (typical ket_dan anchor), crit, ward and body at the anchor.

## Fights

20 fights each, `--matrix` (the matrix's own opponents).

| Matchup | Mean s | W-L-other | You dry | Foe dry |
|---|---|---|---|---|
| typical ket_dan+0 | 8.9 | 20-0-0 | never | 8.3 |
| typical nguyen_anh+1 | 8.1 | 0-20-0 | 7.6 | never |
| typical hoa_than+2 | 4.0 | 0-20-0 | 4.0 | never |
| top_end ket_dan+0 | 2.0 | 0-20-0 | 1.6 | never |
| top_end nguyen_anh+1 | 1.0 | 0-20-0 | 1.0 | never |
| top_end hoa_than+2 | 1.0 | 0-20-0 | 1.0 | never |

Health left at typical ket_dan+0: 100 %.

`--without` (every matchup was identical to the full build in mean, record and dry times):

| Test | Result |
|---|---|
| `--without item:force-chaos-primordial-mirror` | same as above everywhere (8.9 s, 20-0-0 at typical ket_dan+0) |
| `--without eff:Unmaking Glass` | same everywhere |
| `--without tech:mountain-heart-canon` | same everywhere |

So in this sim the unique is worth nothing measurable. `--without item:` removes only the item's plain modifiers; its Effect is the separate test.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Any | foe buff stacks to strip | Something for Unmaking Glass to read | element families, foe design | missing | high |
| Any | `stack_effect_pct` [debuff], `status_duration_pct` | Stronger and longer Fray batches (five pieces carry them) | engine stat | in catalogue, engine has no stat | high |
| Extra | Marked Prey (Branding Iron) | Harder hits per distinct status | Branding Iron | in catalogue, Effect not written | medium |
| Ring | Blood Drinker | Health back for a Ruin Ledger build | Open-Vein Ring | in catalogue, Effect not written | low |
| Armour | a Force ward the engine can run | Hollow Veil | Hollow Robe | in catalogue, ward not run | low |
| Technique | a second auxiliary | The slot is empty | Deep Vein Scripture, others | in catalogue | medium |
| Extra | two empty extra slots | 18 thần thức of room (33 of 51.3) | any piece | in catalogue | low |

## Missing pieces

- A way for the foe to carry buff stacks (self-buffing enemies): enemy design, so Unmaking Glass has a target.
- A status-application event raised by a strip: the combat engine, so a stripped stack counts as a status.
- A Hundred Arts Sage method (the item names it): the techniques catalogue has no multi-element hub that makes the Mirror's `hon_don` scope meaningful.
- An engine stat for `stack_effect_pct` and `stack_duration_pct`: combat engine.
- Buff-stack duration key for the Mirror's closes (own buffs 25 % shorter): combat engine.

## UNMODELLED

- Unmaking Glass raising status_applied: the engine's strip does not raise it; only the Fray counter is fed.
- Unmaking Glass closes, own buff stacks 25 % shorter: no engine key.
- Mirror, Seal, Hollow Ring, Pendant, Iron: `stack_effect_pct`, `status_duration_pct`: no engine stat.
- `hon_don` attack scope and curse-scoped art speed, cost: the engine reads them for every art or not at all.
- `linh_luc_pct`, `than_thuc_pct`, `khi_huyet_pct`, `defense_pct`, `status_resist_pct`, `health_regen_inc_pct`: no engine stat.
- Reserve arts Still Reflection and Murmuring Debts: reserve not deducted, grants not run.
- Hollow Veil ward: only drain wards run, the typical ward is kept.
- Marked Prey and Blood Drinker: not written, the build does not rely on them.
- Mountain Heart Canon passives body_shield, stack_effect, stack_duration: no engine stat.

## Observations

The unique does not make this build: with the item, with its Effect, or without the main technique, every matchup is identical, so the gap is zero. The likely reason is that the typical enemy carries no buff stacks, so Unmaking Glass's condition never holds (the run does not print Effect firings, so this is inferred, not observed); its plain modifiers are mostly unmodelled or scoped to `hon_don`, which no art here carries. The Mountain Heart Canon's engine arts (Strata Hammer and the rest) were left out, so removing the technique removes only passives the engine cannot read. Fights at the same realm last 8.9 s, well below the 30-60 s band; the foe dries at 8.3 s and you never do, with 100 % health left. Against a higher realm you lose every time (8.1 s at nguyen_anh+1, 4.0 s at hoa_than+2). Fray had little time to build: the Ruin Ledger arts fire 1-3 times per fight. Gathered Ruin Verdict, Settle the Account and Sinking Weight never fired at typical hoa_than+2, and nothing fired against top_end. Nothing looks degenerate. No number was tuned.

UNIQUE-DONE unique-chaos-primordial-mirror
