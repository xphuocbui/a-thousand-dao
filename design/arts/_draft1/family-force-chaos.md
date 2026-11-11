# Family: element-less Force (Chấn) and Chaos (Hỗn Độn)

7 signature arts in `family-force-chaos.json`. Lint: 0 findings. Numbers are first guesses inside the lint.

| Art | Mechanic shape | Hooks | One-line rule |
|---|---|---|---|
| Marrow-Siphon Palm (Tủy Hấp Chưởng) | Second pool: drain feeds you | qi burn, Force damage, tick damage, leech qi | Lays 2 Qi Disruption; half of every linh lực point your Force burn removes returns to you. |
| Ripening Curse (Thục Chú) | Curse pattern: payoff per distinct status | distinct statuses, curse slots, damage more | Lays Stagnation; hits 10 % harder per different status already on the foe. |
| Bloodletting Rite (Phóng Huyết Nghi) | Paying with health, then recouping | leech health, health cost reduction, healing | Pays 4 % health for a heavy chaos hit; 6 s of 20 % leech follows. |
| Hollow Husk Stance (Không Xác Thế) | Stance (state) | basic attack, basic speed, art cost | Toggle: basic attack +0.8 coefficient and 30 % faster, every art costs 35 % more. |
| Fraying Thread (Tơ Rã) | Build-up then cash-in (counter, no cap) | status application, element stacks, free-hit damage | Each status you land adds a Fray; firing spends all and tears for 0.7 chaos per 3 Fray. |
| Shearing Palm (Cắt Xé Chưởng) | Conversion | Force and Chaos damage, shield bypass, conversion | Half the palm becomes Chaos, so it passes shields and meets Chaos resistance. |
| Gathered Ruin Verdict (Tụ Phế Phán) | Held payload ("your next art") | status application, held payload, damage more | Each status you land banks 12 % more damage (5 max) for your next art, which spends it. |

## Library arts it replaces or builds on

- Replaces as authored: `force-wave` and `qi-shaking-palm` stay as commons; Shearing Palm and Marrow-Siphon Palm are
  the signature versions of the plain force palms (`sources` lists them). Ripening Curse supersedes `unravelling-seal`
  and `exposing-thread` as the curse-pattern art; Fraying Thread and the Verdict also draw on them.
- Kept as they are: the commons (`qi-shaking-palm`, `force-wave`, `chaos-bolt`, the soul commons) and the
  Sundered, Exposed, Stagnation, Heavy Breath, Silence, Sealed Meridian and Slowed Time applicators (`unravelling-seal`,
  `exposing-thread`, `stagnant-qi-seal`, `heavy-breath-mark`, `silencing-seal`, `binding-seal`, `dragging-moment`).
  Those are single-status control arts; they were left for a control family pass.
- Not repeated: soul arts, escape, cleanse and healing arts of part-c.

## What the engine could not express

- **Held payload that skips its own firing.** `held` banks and spends on named events; an Effect that banks on
  `art_fired` or `hit_landed` is spent by that same firing. Gathered Ruin Verdict therefore banks on `status_applied`
  and does not distinguish "applied by this art" from "applied earlier". Missing piece: a `held` option `next_only`.
- **Partial counter spend.** `counter` can add or set, but not subtract by a scaled amount, so Fraying Thread loses the
  remainder (Fray mod 3) on cashing in. Missing piece: `counter` `take` with `per`.
- **Status filter wildcard.** `status_applied` cannot be filtered to curses only (`tags` is not carried), so Fray and the
  Verdict also count element stack batches. Missing piece: event tags on `status_applied`.
- **Stance cost raise as a typed mod.** `cost_red` below zero is assumed to raise cost; the engine accepts the key but
  I did not run a fight to confirm the sign.
- **Qi burn target readout.** The Siphon returns half of the tick `amount`; whether the engine counts burned linh lực
  (not health damage) in that amount for `qi_disruption` needs a regress run.
- **Health cost vs the art lint.** The lint does not price `hp_cost` (Combat says an art paid in health lints as 2 ×
  `cost_share`); Bloodletting Rite sits at c_art 2.7, which is an unpriced bonus until the lint reads `hp_cost`.
- No sim run was made on any of these, only the schema lint.
