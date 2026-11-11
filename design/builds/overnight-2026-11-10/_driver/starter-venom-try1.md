# Session transcript: starter-venom-try1

> Final message of one headless `claude -p` session.

The Quiet Vine (Tĩnh Đằng Độc Kinh) is designed and proved on the simulator, with eight checks passing and one not assessed. It is a Wood poison build for a player, Luyện Khí to Kết Đan, ordinary power. It lays long, overlapping Poison batches and relies on regeneration to survive the wait.

**What the simulator showed**
- **Trúc Cơ, typical same-realm foe:** won 20–0 in 38.3 s with 76 % health left. The build never ran dry.
- **Kết Đan, typical same-realm foe:** won 20–0 in 24.3 s, below the 30–60 s band. It is slightly strong and I did not pull it back.
- **Identity piece (Rot Bloom, the 24-stack 20 s batch):**
  - Trúc Cơ: removing it changed the fight from 38.3 s to 63.4 s.
  - Kết Đan: removing it changed it from 24.3 s to 32.8 s.
- **Cleanser enemy:** the build lost 0–19, with 1 draw, at Trúc Cơ. That is the intended counter.
- **Higher-realm foes:** it loses to an enemy one realm up and to a top-end foe, as expected for an ordinary build.

**Check results**
- **Budgets (NOT ASSESSED):** arts, slots and artifacts passed. The technique's bonus budget could not be checked because its combat passives are not in `bonus_pool`.
- **Scaling:** by my own arithmetic, not script output, the layers sit 6–12 % under typical because L5 is empty on a tick build. It still wins 20–0.
- **Not modelled:** Root Drinks the Rot, Patient Venom's per-stack scaling (its cap is folded into L2 points), Sap Rises beyond the simulator's table, Seeds Left Behind, Spillover. `fight.py` also lists soul attacks, companions, triggers, conversion, other curses, guards and conditions, and escape as unmodelled. None of these is the engine.
- **Luyện Khí was not simulated.** The second realm run was Kết Đan.

**Pieces**
- **Direction chosen:** The Quiet Vine. I considered and rejected The Thorn Hide, The Grave Garden and The Hollow Sting, with two lines each in the sheet.
- **Technique:** the existing Thanh Mộc Địa Quyết as main, plus a new Quiet Vine Sutra carrying four arts.
- **Effects:** Seeds Left Behind answers the cleanser; Root Drinks the Rot is reused for leech.
- **Safety net:** Weeping Sap, Watched Rot and a Hot Spring Array.
- **Staging file:** 15 new pieces and 15 reused ones.

I wrote the fight input for the cleanser matchup and a Kết Đan fight file as extra files beside the one you specified.

Files are in `design/builds/overnight-2026-11-10/builds/`:
- `starter-venom.sheet.md`
- `starter-venom.md`
- `starter-venom.fight.json`
- `starter-venom.ket-dan.fight.json`
- `starter-venom.cleanser.fight.json`
- `starter-venom.staging.md`
- `starter-venom.suggestions.md`
- `starter-venom.ledger.md`

BUILD-RESULT: slug=starter-venom status=DONE staged_new=15 staged_reused=15 suggestions=2 checks_fail=0 checks_na=1
