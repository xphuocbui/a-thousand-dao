# Stage 6: Bách Vũ Các (`bach_vu`) — progress file

Method: `production/plans/stage6/_brief-record.md` (headless record pass, decisions auto-accepted).
Owner: `bach_vu` (Bách Vũ Các, the Pavilion of the Hundred Feathers; minor sect, vassal of Phượng Minh Cung, Wood/Fire).

## Scope (`depth_gap.py --sect bach_vu`)
- **Techniques (3 lineage + 1 new servant method):** `hundred-call-breath` (Yellow main, Wood+Fire, outer), `roosting-branch-canon` (Profound main, Wood, inner), `moulted-feather-fan` (Profound secret, Fire, inner), plus new `woven-cage-breath` (Yellow main, Metal+Earth, `tap_dich` servant stand-in for `hoan_truc_lung`).
- **Arts (6 depth + 1 new servant art = 6 active + 1 passive Effect):** `call-down`, `still-on-the-branch`, `loose-the-flock`, `under-the-wing`, `shed-feathers-burn`, `wire-snare-needle`; passive art `Hundred-Feather Fan` staged as a technique Effect (`unlock_layer: 2`) on `moulted-feather-fan`.
- **Items (3) & Sets (1):** `bvc-blue-luan-whistle` (`cam` 3), `bvc-ninety-nine-feather-fan` (`phien` 3), `bvc-moulted-feather-fan` (`phien` 2); set `bvc-bird-mother` (2 pieces).
- **Effects (3):** `Call of the Luan` (`bvc-blue-luan-whistle`), `All Birds Bow` (`bvc-bird-mother`), `Hundred-Feather Fan` (`moulted-feather-fan` L2 passive).
- **Beasts (4):** `tieu_loan`, `que_tuoc`, `mac_vu` (`ta_thanh_loan`), `quy_thuoc` (`ta_thanh_thuoc`) — already listed in `bach_vu.cast.json`; records remain in `bach_vu.beasts.json` until Stage 7 export.
- **Stand-ins (1):** `hoan_truc_lung` (`hoang_kim` 5 -> `woven-cage-breath` 5).
- **Cross-owner:** 0. **Ties unmapped / over cap:** 0. **Events:** 4 structured.

## Step 1: Mechanic table
| Record | Kind | Depth mechanic | Engine support | Decision / note |
|---|---|---|---|---|
| `hundred-call-breath` | Tech (T0 main) | Outer Wood+Fire breath | Existing | Size passives to 7.4 W (`attack_pct 3 [moc]`, `evade_pct 2`, `linh_luc_regen_inc_pct 3`) |
| `call-down` | Active art (L1) | Wild bird harries foe, small interrupt chance | Existing (`summon`, `timer {side: foe, which: next, by: 0.5}`, `chance: 0.3`) | Light Wood/Physical strike (`c_art 0.8`) + 4 s `summon` (`c 0.45`); companion hits while `wild_bird >= 1` have 30% chance (`per_pulse: 1`) to delay foe's next art 0.5 s |
| `still-on-the-branch` | Active art (L2) | Still stance: Composed -> evade + next art 0.5 s shorter | Existing (`state` tagged `composed`, `evade`, `timer {side: own, which: next, by: -0.5}`) | 5 s `composed` stance (`on-the-branch`) via pulse counter `branch_still` so it refreshes `-0.5 s` on re-cast; `+12` evade while in stance & `own.composed >= 1` |
| `roosting-branch-canon` | Tech (T1 main) | Inner Wood tamer canon | Existing | `khi_huyet_pct 12` bonus; passives 15.7 W (`attack 5 [moc]`, `attack 6 [companion]`, `stack_effect 8 [moc, debuff]`, `stack_duration 10 [moc, debuff]`, `health_regen_inc 8`, `healing 4`) |
| `loose-the-flock` | Active art (L1) | Quick bird hits laying Wood stacks; more birds at higher layers | Existing (`split`, `empower` on `own.tech_layer.roosting-branch-canon`, `luan_flock` counter) | Base 2 hits (layers 1–3), 3 hits at layer 4+, 4 hits at layer 7+; each hit lays 1 Wood stack (8 s); `luan_flock` adds 1 extra bird hit (`free_hit` + 1 Wood stack) |
| `under-the-wing` | Active art (L2) | Bird takes next hit (decoy), returns to heal | Existing (`decoy`, `decoy_struck`, `heal`) | Grants 1 decoy (`wing_decoy` counter); on `decoy_struck`, heals 5% max HP and decrements `wing_decoy` |
| `moulted-feather-fan` | Tech (T1 secret) | Inner Fire fan method | Existing | `attack_pct 8` bonus; passives 14.8 W (`attack 6 [hoa]`, `art_speed 8 [hoa]`, `stack_effect 10 [hoa, debuff]`, `stack_duration 12 [hoa, debuff]`, `crit_chance 4 [hoa]`) |
| `shed-feathers-burn` | Active art (L1) | Cone of burning feathers laying Fire stacks | Existing (`split`, `tags: ["fire", "fan", "feather", "split"]`) | 4 sub-hits (`c_art 1.5`), each laying 1 Burn stack (6 s) |
| `Hundred-Feather Fan` | Passive art (L2) | Fire stacks last longer per fan feather kind (grade) | Existing (`technique-effects`, `own.tech_layer.moulted-feather-fan`, `stack_dur`) | Staged as L2 technique Effect (`stack_dur +2 %` Fire debuff per `moulted-feather-fan` layer; no `item_grade` readable exists) |
| `woven-cage-breath` + `wire-snare-needle` | Tech (T0 main) + Active art (L1) | New servant method for `hoan_truc_lung` | Existing | Yellow Metal+Earth `tap_dich` method (7.8 W); 1 quick Metal Physical needle thrust (`c_art 1.5`, 1 Metal stack 6 s) |
| `Call of the Luan` | Item Effect (`bvc-blue-luan-whistle`) | Once/fight: birds return to full HP, next Loose the Flock sends 1 more bird | Existing (`pulse` `own.hp_share <= 0.8`, `heal`, `luan_flock`) | Companions lack HP (Combat rule 19), so "returns to full health" heals holder 8% max HP + arms `luan_flock: 1` (declared in both Effect and art) |
| `All Birds Bow` | Set Effect (`bvc-bird-mother`) | Bird strikes add 1 feather to next fan art; all 3 birds within 2 s -> 2 Slowed Time | Existing (`hit_landed` `kind: companion, tags: ["bird"]`, `each_for: 2`, `bow_feathers`, `slowed_time`) | Matches both `tags: ["fan"]` and `art_id: "fan-gust"`; `bird_strike_2s` (`each_for: 2`) triggers 2 Slowed Time (3 s) on 3 bird strikes in `< 2 s` |

`spatial_words_check.py`: 1 hit in `bach_vu.items.json` (`"foe within"` in `"strike the same foe within 2 s"`), a time-window false positive (no spatial rule); rephrased as `"in 2 s"` in staged files.

## Steps
- [x] 1. Verify first: mechanic table & spatial check done.
- [x] 2. Techniques and arts (staged in `design/stage6-staging/bach_vu/techniques/catalogue-sect-bach_vu.json` and `arts/part-sect-bach_vu.json`; art IDs, passive Effect reference, and `woven-cage-breath` written into `design/world/depth/sects/bach_vu.techniques.json`).
- [x] 3. Effects (staged 3 Effects in `design/stage6-staging/bach_vu/effects/bach_vu.effects.json`; all 3 pass standalone `engine.validate` and local counter/state declaration checks).
- [x] 4. Items and sets (staged 3 items and 1 set in `design/stage6-staging/bach_vu/items/catalogue-sect-bach_vu.json` and `sets-bach_vu.json`).
- [x] 5. Stand-ins (`hoan_truc_lung` switched from `hoang_kim` 5 to `woven-cage-breath` 5 in `design/world/depth/sects/bach_vu.cast.json`; `depth_gap.py` `stand_ins: 0`).
- [x] 6. Beasts verified (`ta_thanh_loan`: `tieu_loan`, `que_tuoc`, `mac_vu`; `ta_thanh_thuoc`: `quy_thuoc` already listed in `bach_vu.cast.json`; records stay in `bach_vu.beasts.json` until Stage 7 export).
- [x] 7. Holder check (`lint_techniques` 0 findings, `lint_arts` 0 findings, `lint_items` 0 findings, `depth_check` `findings: none`, `depth_gap --sect bach_vu` verified, `sect_fight bach_vu --seeds 5` at `--gap 0` and `--gap 1` 0 `REFUSED` across all 16 living holders and every art fires, plus companion and standalone probes).
- [x] 8. Review file (`production/plans/stage6/bach_vu-review.md`).
- [x] 9. Finish (`RECORD PASS DONE` and `production/plans/stage6/bach_vu.done`).

RECORD PASS DONE
