# Stage 6: Trấn Sa Đường (progress file)

Method: `production/plans/world-depth-implementation.md` Stage 6, "the per-sect method", and `production/plans/stage6/_brief-record.md` (headless job, decisions auto-accepted).

## Scope (`python -B -I tools/design/world/depth_gap.py --sect tran_sa`)
- **3 techniques:** `sand-wall-primer` (Yellow main, `tho`, outer gate, 6 layers), `sand-holding-sabre-canon` (Profound main, `tho`/`kim`, inner and above, 9 layers), `sword-washing-temper` (Profound secret, `kim`/`tho`, smiths/elders, 9 layers). Existing in lineage: `iron-hide-manual` (`catalogue-metal.json`).
- **4 new arts:** `hold-the-line` ("Hold the Line (Thủ Tuyến)"), `hold-the-sand` ("Hold the Sand (Trấn Sa)"), `answering-cut` ("Answering Cut (Ứng Đao)"), `spring-quench` ("Quench (Thối)", renamed from `quench` to avoid collision with `part-a.json`).
- **3 items:** `ts-lone-smoke-sabre`, `ts-quench-hammer`, `ts-caravan-shield`.
- **1 set:** `ts-fathers-road` (2 pieces, `vien_co_yen`).
- **2 Effects:** `Smoke on the Road` (`ts-lone-smoke-sabre`), `The Rider Comes In` (`ts-fathers-road`).
- **0 stand-ins, 0 beasts, 1 cross-owner ref (`loose-north` `ho_dien_liet` -> `sand-wall-primer`, closes when promoted), 2 structured events (`N-tran_sa-01`, `N-tran_sa-02`).**

## Step 1: Mechanic table & spatial check
`spatial_words_check.py --sect tran_sa`: 1 soft hit in `tran_sa.techniques.json :: sand-wall-primer :: techniques.concept :: beside` ("a shield beside a camel" — narrative concept prose, not a fight rule).

| Record | Kind | Depth rule / concept | Engine mapping | Status / Ruling |
|---|---|---|---|---|
| `sand-wall-primer` | technique | Yellow main, Earth, outer guard method; body wall and shield while Composed | `tier: 0`, `names: ["tho"]`, `bonuses: []`, new passives sized `7.8 W` of `8.0 W` (`defense_pct 3`, `block_rating 6`, `khi_huyet_pct 4`), `abilities`: `hold-the-line` (`unlock_layer: 1`) | Existing words; auto-accepted passives & layer |
| `sand-holding-sabre-canon` | technique | Profound main, Earth + Metal, block/slow/counter-cut | `tier: 1`, `names: ["tho", "kim"]`, new `bonuses: [defense_pct 10]`, new passives sized `14.8 W` of `16.0 W` (`block_rating 10`, `attack_pct 6 [physical]`, `stack_duration_pct 15 [tho, debuff]`, `status_duration_pct 10 [curse]`), `abilities`: `answering-cut` (L1), `hold-the-sand` (L2) | Existing words; auto-accepted bonus, passives & layers |
| `sword-washing-temper` | technique | Profound secret, Metal + Earth, smiths' temper; hit taken hardens skin, hit landed adds temper stack | `tier: 1`, `names: ["kim", "tho"]`, new `bonuses: [attack_pct 10]`, new passives sized `14.7 W` of `16.0 W` (`stack_effect_pct 14 [kim, buff]`, `stack_duration_pct 15 [kim, buff]`, `pierce_pct 5`, `resist_pct 100 [physical]`), `abilities`: `spring-quench` (L1) | Existing words; auto-accepted bonus, passives & layer |
| `hold-the-line` | art | Guard: takes less damage while Composed | Earth `ward` art (`c_art: 0.0`, `cost_share: 0.03`, `cooldown: 5.0`, `buff: [1, 8.0]`) raising an `8 %` body shield on cast + `always` (`own.composed >= 1`) `dampen_taken: 12`; no stance so it never conflicts with `red-sand-sabre-primer` or other stances | Existing words |
| `hold-the-sand` | art | Field ring of heavy sand: while up, foe slowed and charges stopped | Earth `control` art (`c_art: 0.0`, `cost_share: 0.04`, `cooldown: 5.0`, `guards: [own.field_up < 1]`) setting Field state `hold-the-sand` (plus combined `hold-the-sand-iron` with `iron-hide-stance` for `vien_co_yen` and `ninh_ha_vien`, duplicating `iron-hide-temper` on `was_hit`). Each pulse while `own.field_up >= 1`: +1 Earth debuff (`6 s`), +1 `slowed_time` (`2 s`, uncapped), and if `foe.pressing >= 1` or `own.foe_pressed >= 1` delays foe's next art `0.4 s` | Existing words; combined stance handles `iron-hide-manual` |
| `answering-cut` | art | Counter: after blocking a hit, next sabre cut deals extra Physical damage and breaks attacker's guard | Metal `damage` `phys` art (`c_art: 1.6`, `cost_share: 0.04`, `cooldown: 4.0`, `tags: ["metal", "sword", "sabre", "counter"]`); `blocked` (`event.amount > 0`) sets `answering_guard = 1`; `empower` consumes `answering_guard` for `c_mult: 1.5` (`2.4`) and `off_guard` (`2 s`) | Existing words |
| `spring-quench` | art | Consumes weapon temper stacks for one heavy Metal cut that pierces armour (plus technique's hit-taken skin / hit-landed temper) | Unique ID `spring-quench` (`quench` taken in `part-a.json`). Metal `damage` `phys` art (`c_art: 1.8`, `cost_share: 0.05`, `cooldown: 5.0`, `bypass: 0.25`); `was_hit` (`event.amount > 0`, `per_pulse: 2`) grants +1 Earth buff (`8 s`); `hit_landed` (`not_art_id: "spring-quench"`, `per_pulse: 3`) grants +1 Metal buff (`10 s`); `art_fired` consumes all Metal buffs (`dmg_more +0.15` per stack on `spring-quench`) + arms `pen 150` (`art_id: "spring-quench"`) & `pierce 35` until hit resolves | Existing words |
| `Smoke on the Road` | item Effect | While Hold the Sand ring (Field) is up, when struck, next Answering Cut cannot miss | `was_hit` (`own.field_up >= 1`, `event.amount > 0`) sets `smoke_road = 1`; `always` (`smoke_road >= 1`) adds `acc: 100`; cleared on `hit_landed` (`art_id: "answering-cut"`) | Existing words (`approx` logged: `acc` has no art filter) |
| `The Rider Comes In` | set Effect | After block, attacker gains Earth slow stack; next counter-cut deals 25 % more to slowed foe | `blocked` (`event.amount > 0`) grants +1 Earth debuff (`8 s`) on foe and sets `rider_counter_cut = 1`; `always` (`rider_counter_cut >= 1` and (`foe.debuff.earth >= 1` or `foe.status.slowed_time >= 1`)) adds `dmg_more: 0.25` (`art_id: "answering-cut"`); cleared on `hit_landed`/`was_evaded` (`art_id: "answering-cut"`) | Existing words |
| 3 items, 1 set | items/sets | `ts-lone-smoke-sabre`, `ts-quench-hammer`, `ts-caravan-shield`; `ts-fathers-road` | `sources: ["npc"]`, `unique: true`, R6 `exception` on all 3 (`phi_kiem`, `an`, `thuan`) | Existing fields |

## Steps
- [x] 1. Verify first: mechanic table, `spatial_words_check.py`, `depth_gap.py`.
- [x] 2. Techniques and arts (staged under `design/stage6-staging/tran_sa/`), plus art IDs in `design/world/depth/sects/tran_sa.techniques.json`.
- [x] 3. Effects (staged under `design/stage6-staging/tran_sa/effects/tran_sa.effects.json`).
- [x] 4. Items and sets (staged under `design/stage6-staging/tran_sa/items/`).
- [x] 5. Stand-ins: verified 0.
- [x] 6. Beasts: verified 0.
- [x] 7. Holder check: `lint_arts` (0 findings), `lint_techniques` (0 findings), `lint_items` (0 findings), standalone Effect validation (2/2 passed), `sect_fight.py tran_sa` (`--gap 0` and `--gap 1`: every art fires, every Effect runs on real holders), and targeted evade/without probes.
- [x] 8. Review file: `production/plans/stage6/tran_sa-review.md` written.
- [x] 9. Finish: `RECORD PASS DONE` and `production/plans/stage6/tran_sa.done`.

RECORD PASS DONE
