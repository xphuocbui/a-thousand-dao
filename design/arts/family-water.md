# Water (Thủy) signature arts

8 authored arts in `family-water.json` (3 standalone, 5 engine, two suites);
`python -I tools/design/arts/lint_arts.py design/arts/family-water.json` gives 0 findings. Theme: sustain, flow, tides
that build and release, linh lực return. The common Water arts (Still Water Palm, Tide Pulse, Underground Spring,
Drawing Breath, Still Pool Mending) stay as they are. Second draft: keeps the first draft's eight ideas, adds engine
steps and empowers, trims Backwash Seal to Water arts only, and gives Marrow to Dew a low-health payoff.

| Art | Power | Mechanic shape | Hooks | Engine (how to feed it) | One-line rule |
|---|---|---|---|---|---|
| Swelling Tide Palm (Doanh Triều Chưởng) | engine | Build-up, cash-in (uncapped counter) + split | water arts fired, healing received, split hits, foe water stacks | Tide from any Water art, from being healed, from Deep Lake pulses; 5 Tide **and** 3 Water stacks (5 waves, x2.8, eats own Water stacks for a free hit each) **or** 3 Tide **and** health ≤ 60 % (3 waves, x2.5) | Tide grows with every Water art and heal; at 5 it breaks as five waves. |
| Gathering Wave (Tụ Ba) | engine | Held payload ("your next hit") | art speed, hit count, banked cap, tide, slowed time | Crest (x3.5 hit + 2-wave surge) with 2 Tide **and** (Deep Lake **or** foe at 2 Slowed Time), **or** 3 Tide (spent) **and** health ≤ 70 % | Banks waves for the next hit; fed, it crests and banks a surge. |
| Deep Lake Stance (Thâm Hồ Thế) | engine | Stance / form + release | water stacks, tide, regeneration, low health | Leave the lake with 6 Water stacks (spent, a free hit each), **or** 4 Tide, **or** half health: one big hit (x3.2) + heal | In the lake: sustain and Tide, -30 % damage; leaving it floods out. |
| Brimming Cup (Doanh Bôi) | engine | Shield and overflow as a weapon (2 steps) | overflow, shield size, shield breaks, low health | Step 2: 1 Tide **and** (linh lực ≥ 70 % **or** lake). Step 3 (x5.0): 3 Tide **and** (shield standing **or** half health) | Restores, shields, spills; fed twice it crashes down and renews the shield. |
| Drag of the Deep (Thâm Uyên Kéo) | engine | Delay, Slowed Time curse pattern (2 steps) | slowed time, timer delay, foe water stacks, foe dry | Step 2 (x2.4): foe 3 Slowed Time **or** nearly dry **or** 2 litany arts this pulse. Step 3 (x6.0): 5 Slowed Time **and** 2 litany arts this pulse; eats your own Water stacks for linh lực (foe has no Water debuff) | Stacks Slowed Time; fed, it delays every art and drinks the foe's stacks. |
| Seep-Through Palm (Thấm Cốt Chưởng) | standalone | Conversion (half Physical) | physical and water damage, art speed | - (complete alone) | Hits body and ward at once; each hit speeds your other arts 0.4 s. |
| Marrow to Dew (Tủy Hóa Lộ) | standalone | Paying with health + conditional payoff | health cost, low health, healing received | - (complete alone) | Pay 5 % health for 20 % linh lực; +3 % per 10 % health missing; heals return linh lực. |
| Backwash Seal (Hồi Lưu Ấn) | standalone | Echo / repeat | water arts fired, heavy arts to echo, echo power | - (complete alone) | Every 3rd Water art repeats at half and returns 2 % linh lực. |

## Suite: Still Moon Tide Scripture (`still-moon-tide-scripture`, Tĩnh Nguyệt Triều Kinh)

Swelling Tide Palm, Gathering Wave, Deep Lake Stance, Brimming Cup. All share the `tide` counter and the Deep Lake state.
The Lake adds a Tide and a Water stack every pulse; Tide opens the Wave's crest, the Cup's steps and the Lake's own
release, and the Palm spends it; the Cup's overflow and the Wave's heals feed Tide through healing and Water arts. Enter
the lake, fire Wave and Cup to bank Tide, then leave through the Lake's flood and break the Palm.

## Suite: Undertow Litany (`undertow-litany`, Hạ Lưu Kệ)

Drag of the Deep, Seep-Through Palm, Marrow to Dew. Drag's step 2 opens when two litany arts landed in the same pulse
(Seep's 0.4 s speed-up and Marrow's quick restore make that easy); Marrow keeps the linh lực pool up while Drag drinks
the foe's.

## Library arts replaced

- Water Curtain (Thủy Liêm Chướng) → Brimming Cup.
- Ebb and Flow (Triều Tịch) → Marrow to Dew and Deep Lake Stance.
- Kept as they are: Spring at the Well's Mouth, Drowning Palm, Ninth-Weight Lance.

## Not expressed or not verified

- Lint checks schema only; I did not run the fight engine on these. Check there: `scale` over `own.hp_missing_share`
  with `per` 0.1; `counter.add: -5` in an empower `pay`; the empower order in Swelling Tide Palm and Gathering Wave
  (written so a paid empower never unlocks a later one); a free hit inside `consume.then`; state mod units of
  Deep Lake (`regen` and `hregen` fractions, `healing` percent, `dmg_more` fraction).
- Free hits (waves, surges, releases) count against the trigger budget and cap, so large Tide or surge banks may clip.
  The lint's engine_payoff covers only the coefficient, not the waves and surges.
- Missing pieces: a variable `split` that grows with a counter (waves = Tide, limitless); a tag-scoped `suppress` for
  stances (Deep Lake cannot silence only Water damage arts, it uses a flat damage penalty); conversion of damage into
  healing or linh lực; a Water summon (living tide) needs a companion heal target; `steps` cannot branch to different
  payouts per feed route (each route pays the same `pay`).
- No summon in this family; the shape is covered elsewhere.
