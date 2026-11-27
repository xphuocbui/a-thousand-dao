# Stage 6: Hộ Lâm Đường (`ho_lam`, progress file)

Method: `production/plans/world-depth-implementation.md` Stage 6 ("The per-sect method"), `production/plans/stage6/_brief-record.md`, and `production/plans/stage6/bang_tam.md`.
Decisions are auto-accepted against the design rules and logged in `production/plans/stage6/ho_lam-review.md` and `ho_lam.done`.

## Scope (`python -I tools/design/world/depth_gap.py --sect ho_lam`)
- 3 proposal techniques: `raft-and-root-primer` (Tier 0 main, Wood/Water), `night-beside-the-tree` (Tier 1 secret, Wood), `spring-flood-raft-art` (Tier 1 secret, Water). Existing in lineage: `verdant-cycle-scripture` (`catalogue-wood.json`), `seed-and-soil-primer` (`catalogue-sect-thuy_vi.json`, already committed under `thuy_vi`, used by `phu_hau_tho` under R4 exception).
- 4 new arts (`log-on-the-current`, `the-forest-listens`, `bark-closes`, `the-flood-takes-it`); 3 existing arts referenced (`rooted-form`, `second-spring`, `swelling-tide-palm`).
- 4 items (`hlm-asking-axe`, `hlm-first-light-heart`, `hlm-lead-raft-banner`, `hlm-white-wax-robe`), 1 set (`hlm-first-light`), 3 Effects (`One Stroke`, `The Tree Did Not Answer`, `The Forest Closes`).
- 0 beasts, 0 stand-ins (all 18 living members already hold real techniques), 4 structured events (`N-ho_lam-01`..`04`).
- `spatial_words_check.py --sect ho_lam`: 0 non-soft rule-field hits (`rooted` only in `build_use` / `note` / `intent`; `beside` is `soft` in technique `concept` and `ties.note`).

## Steps
- [x] 1. Verify first: mechanic table (below) and `spatial_words_check.py`.
- [x] 2. Techniques and arts (staged under `design/stage6-staging/ho_lam/`), plus `"id"` fields inserted into `design/world/depth/sects/ho_lam.techniques.json`.
- [x] 3. Effects (staged in `design/stage6-staging/ho_lam/effects/ho_lam.effects.json`).
- [x] 4. Items and sets (staged in `design/stage6-staging/ho_lam/items/catalogue-sect-ho_lam.json` and `sets-ho_lam.json`).
- [x] 5. Stand-ins: 0 needed (all 18 living members already use real techniques; `phu_hau_tho`'s `seed-and-soil-primer` is already committed under `thuy_vi`).
- [x] 6. Beasts: 0 (`ho_lam` has no beasts).
- [x] 7. Holder check (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\ho_lam`):
      - `lint_arts.py`: 4 arts checked, 0 findings (`log-on-the-current empower 1: x1.41 of the lint, gated`).
      - `lint_techniques.py`: 3 techniques checked, 0 findings (`7.7 / 8`, `10.4 / 16`, `8.5 / 16` W).
      - `lint_items.py`: 4 items checked, 0 findings (`4 of 4` unique; R6 `exception` on `hlm-asking-axe` and `hlm-white-wax-robe`; fixed `water` -> `thuy` scope on `hlm-lead-raft-banner`).
      - `sect_fight.py ho_lam --seeds 5` (`--gap 0` and `--gap 1`): all 13 authored-build holders ran with 0 `REFUSED` and 0 `NEVER_FIRED` on any new art. Fixed `the-forest-listens` (pressed-trigger via `was_hit`/`evaded`/`was_evaded` instead of `pulse` `foe_pressed`) and `the-flood-takes-it` (`cd 2.5, c_art 1.5` so 3-in-a-row Water streak lands organically).
      - Targeted probes verified `The Forest Closes` (`mountain-cleave`), `The Tree Did Not Answer` (`--gap 1`), `log-on-the-current` empower (with `deep-lake-stance`), `the-flood-takes-it` `flood-streak-break`, and standalone `bark-closes` stance entry/exit.
- [x] 8. Review file (`production/plans/stage6/ho_lam-review.md`).
- [x] 9. Finish (`RECORD PASS DONE` and `production/plans/stage6/ho_lam.done`).

## Step 1: Mechanic table

| Record | Rule mechanic | Engine support / ruling |
|---|---|---|
| `log-on-the-current` (art) | Heavy Wood hit; foe's soonest art waits 0.5 s; if Water stack on you, strikes again at half | Existing words: `timer {side: foe, which: next, by: 0.5}` on `hit_landed` (`per_pulse: 1`); `empower` on `own.buff.water >= 1` with `split: [1.0, 0.5]` |
| `the-forest-listens` (art) | For 6 s your next art against the foe cannot miss; foe who pressed while it lasts takes 1 Wood stack | Existing words: 6 s `forest_listens_sec` counter; `art_fired` (`not_art_id`, `own.since_act <= 0`) grants `mod {acc: 500}` and clears `forest_listens_sure`; `was_hit` (`kind: art`), `evaded` (`kind: art`), and `was_evaded` (`per_pulse: 1`) lay 1 Wood debuff (8 s) |
| `bark-closes` (art) | 4 s: take 25 % less damage, heal a little each second, evade 0, cannot be Pressing | Existing words: `bark_sec` counter (4 pulses) gives `mod {dampen_taken: 25, no_evade: 1}` on `always` and `heal {share: 0.02}` on `pulse`; enters `composed` stance `bark-closes` only when `own.state.any == 0` so `rooted-form`'s `rooted` stance and pulse effects are never masked |
| `the-flood-takes-it` (art) | Water hit: foe's soonest art waits 0.3 s + 2 Slowed Time; 3 Water arts in a row breaks foe's guard | Existing words: `statuses: [{id: slowed_time, stacks: 2, dur: 3}]`; `timer {side: foe, which: next, by: 0.3}`; `water_streak` incremented on Water art `hit_landed` (`per_firing: 1`), reset on non-Water art `hit_landed` (`kind: art, not_tags: [water]`), at `>= 3` applies `exposed` (3 s) and resets |
| `One Stroke` (item Effect) | First hit each fight deals 30 % more damage if not moved for 2 s before it | Existing words: `own.composed >= 1` (`composed_after` = 2 s) + `one_stroke_done == 0` -> `always` `mod {dmg_more: 0.3}`, spent on `hit_landed`; read as first Composed hit (since `t = 0` starts with `composed == 0`) |
| `The Tree Did Not Answer` (item Effect) | Once a fight at killing blow, stay at 10 % HP; after that the pendant gives no healing | Existing words: `down` (`per_fight: 1`) -> `refuse_down {hp_share: 0.1}` + `heartwood_spent = 1`; `always` while `heartwood_spent >= 1` -> `mod {healing: -12, hregen_inc: -36}` (cancels the pendant's own healing modifiers, matching `Grown, Not Made`) |
| `The Forest Closes` (set Effect) | After each axe stroke brace for 6 s: evade 0, regenerate 2 % HP/s, attacker gains 1 Wood stack | Existing words: `art_fired` on `mountain-cleave` (base `phu` common art) sets `forest_closes_sec = 6`; `always` `mod {no_evade: 1}`; `pulse` `heal {share: 0.02}` + decrement; `was_hit` (`per_pulse: 2`) lays 1 Wood debuff (8 s) |
| Items R6 & uniqueness | 2 items (`hlm-asking-axe`, `hlm-white-wax-robe`) are weapon/body_gear with no authored art/ward | Auto-accepted per standing ruling R6 & rule 20f: `sources: ["npc"]`, `unique: true`, `exception` mark on axe & robe |

RECORD PASS DONE
