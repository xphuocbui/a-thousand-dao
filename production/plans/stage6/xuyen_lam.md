# Stage 6: Xuyên Lâm Môn (`xuyen_lam`) — progress file

Method: `production/plans/stage6/_brief-record.md` (headless record pass, decisions auto-accepted).
Owner: `xuyen_lam` (Xuyên Lâm Môn, the Gate Through the Forest; R3 no-lean minor sect under Thính Vũ Lâu).

## Scope (`depth_gap.py --sect xuyen_lam`)
- **Techniques (3):** `straw-sandal-step-primer` (Yellow main, outer), `calm-wind-staff-canon` (Profound main, already early-promoted by `thinh_vu` in `b01` with active arts `walk-slowly`, `who-is-afraid`, `one-straw-cape` and `The Long Road` passive stub), `unheeding-rain-heart-method` (Profound secret, head & Road Mother). Existing body/secret art in lineage: `hundred-echo-palm-scripture`.
- **Arts (7 total in depth):** 3 already promoted (`walk-slowly`, `who-is-afraid`, `one-straw-cape`), 2 new active arts (`lighter-than-a-horse`, `neither-wind-nor-rain`), 2 passive arts as technique Effects (`The Long Road` d23, `Do Not Listen`).
- **Items (6) & Sets (3):** `xl-bamboo-staff`, `xl-straw-cape`, `xl-guide-lamp`, `xl-salt-carrier-jacket`, `xl-pass-pendant`, `xl-road-mother-jade`; sets `xl-calm-wind-and-waves`, `xl-thunder-fort`, `xl-lamp-and-road`.
- **Effects (6 total):** 2 technique passive arts (`The Long Road`, `Do Not Listen`), 2 item Effects (`Rain on the Leaves`, `Lamp on the Road`), 2 full-set Effects (`Step Before the Strike`, `The Lamp Does Not Go Out`).
- **Stand-ins:** 0. **Beasts:** 0. **Cross-owner inbound:** 2 (`truong_da_dao` in `loose-south` -> `straw-sandal-step-primer`; `uc_da_diep` in `thinh_vu` -> `calm-wind-staff-canon`). **Cross-owner outbound:** 0.

## Step 1: Mechanic table
| Record | Kind | Depth mechanic | Engine support | Decision / note |
|---|---|---|---|---|
| `straw-sandal-step-primer` | Tech (T0 main) | Element-free footwork primer | Existing (`names` proxy `["kim","moc","tho"]`, element-free arts) | Matches `calm-wind-staff-canon` proxy (`body-element-free-names` Stage 7/9 ruling) |
| `calm-wind-staff-canon` | Tech (T1 main) | Already early-promoted in `b01` | Existing | Keep IDs, passives, bonuses, abilities, `The Long Road` (L5); update notes |
| `unheeding-rain-heart-method` | Tech (T1 secret) | Element-free mind method | Existing (`names` proxy `["kim","moc","tho"]`, element-free arts) | Carries `Do Not Listen` (L1 passive) + `neither-wind-nor-rain` (L2 active) |
| `lighter-than-a-horse` | Active art | Pressing, faster, harder to hit; first foe act in window delays foe's next art | Existing (`movement`, `pressing` state guarded on `state.any == 0`, `art_speed`, `basic_speed`, `evade`, `was_hit`/`evaded`/`foe_pressed`, `timer next +0.5`) | Guard state entry on `own.state.any == 0` so `walk-slowly` is never overwritten; listen on art `was_hit`/`evaded` + `pulse` `foe_pressed` |
| `walk-slowly` / `who-is-afraid` / `one-straw-cape` | Active arts | Already in `design/arts/part-sect-xuyen_lam.json` | Existing | Preserve untouched; add `"id"` into `xuyen_lam.techniques.json` |
| `The Long Road` (`d23`) | Tech Effect (L5) | While Pressing, arts cost 5 % less + 1 % per Walk Slowly stack | Existing (`always`, `own.pressing >= 1`, `cost_red: 0.05` + scaled `0.01`) | Additive `cost_red` (engine cap 0.95) approximates compounding; declares `walk_slowly` counter |
| `Do Not Listen` | Tech Effect (L1) | Passive ward reducing soul dmg & charm; rises on meeting them, fades 10 %/s | Existing (`always` `soul_res` + `status_resist [charmed]`, `decay_share: 0.1`, `soul_taken`, `pulse` `own.status.charmed >= 1`, `was_hit [song]`) | Typical foe uses no soul/charm/song; verified via `PROBE_SOUL_CHARM` (+13.6 s survival) |
| `neither-wind-nor-rain` | Active art (L2) | Once/fight control status ignored, next staff strike cannot miss | Existing (`art_fired` mind-guard + curse cleanse; once/fight `pulse` cleanses control curse & arms `neither_wind_sure`; next `staff` `art_fired` grants 1 ms `acc: 500`) | Active ward art satisfies `lint_techniques` (`abilities` non-empty) and fires on `phi_thoa_y`; shrug verified via `PROBE_SOUL_CHARM` |
| `Rain on the Leaves` | Item Effect (`xl-bamboo-staff`) | While Pressing, foe art hitting you gives 1 Walk Slowly stack | Existing (`was_hit`, `kind: art`, `own.pressing >= 1`, `counter walk_slowly +1`) | Exact; declares `walk_slowly` counter for standalone compile |
| `Lamp on the Road` | Item Effect (`xl-guide-lamp`) | Foe cannot be unseen; once/fight leave at no cost | Existing (two `fight_start` records: `:sight` `acc: 20` & `escape: 50` for 300 s; `:escape_free` `next_art_cost: 0.0 [escape]`) | Split into two records to prevent `temp_mods` wipe; verified via `PROBE_LAMP_EVADE` (19/20 vs 11/20) & `PROBE_LAMP_ESCAPE` (20/20 free vs 14/20) |
| `Step Before the Strike` | Set Effect (`xl-thunder-fort`) | Each evade: next staff strike deals 30 % as Lightning and cannot be blocked | Existing (`evaded` arms `step_before`; `staff` `art_fired` grants 1 ms `ignore_block: 1`; `staff` `hit_landed` adds `return_damage {share: 0.30, dtype: "lightning"}`) | No live `convert` mod; 30 % Lightning shock preserves full Physical + crit/stack scaling |
| `The Lamp Does Not Go Out` | Set Effect (`xl-lamp-and-road`) | Each evade lights lamp +3 s (1 % HP/s); <=25 % HP self-lit & doubled (2 %/s) | Existing (`evaded` `lamp_lit +3`, `pulse` `heal 0.01` / `0.02`, `lamp_lit -1`) | Exact, uncapped `lamp_lit` |

`spatial_words_check.py`: 5 hits in `xuyen_lam`, all false positives in prose/tie notes (`Still` in `build_use`, `knock down` in method `concept`, `planted`/`behind her`/`beside` in tie notes). No fight rule affected.

## Steps
- [x] 1. Verify first: mechanic table & spatial check done.
- [x] 2. Techniques and arts (staged in `design/stage6-staging/xuyen_lam/techniques/catalogue-sect-xuyen_lam.json` and `arts/part-sect-xuyen_lam.json`; IDs inserted in `design/world/depth/sects/xuyen_lam.techniques.json`).
- [x] 3. Effects (staged 6 Effects in `design/stage6-staging/xuyen_lam/effects/xuyen_lam.effects.json`; all 6 pass standalone compile check).
- [x] 4. Items and sets (staged 6 items & 3 sets in `design/stage6-staging/xuyen_lam/items/catalogue-sect-xuyen_lam.json` and `sets-xuyen_lam.json`).
- [x] 5. Stand-ins (0 open).
- [x] 6. Beasts (0 open).
- [x] 7. Holder check: `lint_techniques` 0 findings, `lint_arts` 0 findings, `lint_items` 0 findings, `depth_check` 0 `xuyen_lam` findings, `depth_gap --sect xuyen_lam` verified, `sect_fight xuyen_lam --seeds 5` gap 0 & gap 1 (18/18 cast, 0 `REFUSED`, all slotted arts fire), plus 7 standalone probes (caught and fixed `Lamp on the Road` same-record `temp_mods` wipe and `lighter-than-a-horse` integer-second `foe_pressed` window).
- [x] 8. Review file (`production/plans/stage6/xuyen_lam-review.md`).
- [x] 9. Finish (`RECORD PASS DONE` and `production/plans/stage6/xuyen_lam.done`).

RECORD PASS DONE
