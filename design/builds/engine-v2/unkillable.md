# The Thousand-Year Banyan (Thiên Niên Dung Thụ) — a tank whose healing outlives the fight and whose poison is the clock.

Fight file: `design/builds/engine-v2/builds/unkillable.fight.json` (Hóa Thần, `hoa_than`, 7 slots). The old build had no
fight file (the glob found none), so there is no other-realm file, and the layers, crit, body and n values were
rebuilt from the guide's own figures (layers about ×7, n_body 3, regeneration +6 pp, healing +30), not copied.
Root: Wood purity 80, Water purity 60.

## Pieces

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Spring Sap (6 Wood stacks, regen) | `seed-of-spring` | verdant-cycle-scripture (1) |
| Underground Spring (6 Water stacks) | none (`underground-spring` is a common art, only via a generated common technique) | lost |
| Banyan Shade (heal, refunds cost) | `second-spring` | verdant-cycle-scripture (4) |
| Shedding Bark (cleanse) | none | lost |
| Rot Deepens (Poison L2) | `harvest-bloom` (Poison harvest) | verdant-cycle-scripture (6) |
| Poison laying / Thorn-style lay | `blight-canker`, `bloodroot-pact`, `thornling-grove` | rotting-canopy-canon (2, 4, 6) |
| Wood regeneration form | `rooted-form` | verdant-cycle-scripture (2) |
| Clear Heart Ward, Mountain Screen, Thousand-Layer Cloud (art-slot wards) | none | dropped |
| Surplus Life, Still Water, Growth Rings, Sap Rises | kept as Effects (Surplus Life not expressible, see below) | n/a |

## Techniques and why

- **verdant-cycle-scripture** (Profound main, Wood): the whole suite fits the concept. Wood stacks and a banked Seed
  (regeneration), a heal that counts Springs, a regenerating form, and a Poison harvest. Four arts, all used.
- **rotting-canopy-canon** (Earth secret, Wood): the Poison engine, with `blight-canker` (Poison plus Stagnation),
  `bloodroot-pact` (Poison that heals on a Chaos tick) and `thornling-grove` (a summon that seeds Poison). Its
  `thorn-rain` is left out because `rooted-form` suppresses it.
- **unbroken-flesh-canon** (Yellow body): carried for its passives only (health regeneration inc +10, body shield +6,
  health +3); none of its arts fit a Wood bar, so it takes no slot. Its passives print as "no engine stat", so it adds
  nothing in the run.

## Lost in the move

- Underground Spring (Water buff, the pool) and Shedding Bark (cleanse): no library art. The Water purity now feeds nothing.
- Banyan Shade's "refunds its cost" is replaced by `second-spring`, which heals at 95 % or less but does not refund.
- Rot Deepens' flat Poison layer: `harvest-bloom` converts a Poison pile into hits instead.
- Four of the six old wards: only the realm's Common Ward is modelled.
- The enabler Surplus Life (overheal becomes Poison): the engine emits `overflow` only for linh lực, so it cannot be written.

## Results

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical Hóa Thần | 11.3 | 20-0-0 | never | 9.5 | canker-spread 49.3, root-drink 53.8, canker-wither 20.5, trig_budget 6.7, seed-sow 3.8 |
| top_end Hóa Thần | 1.6 | 0-20-0 | 1.6 | never | none printed |

## Without tests (typical, Hóa Thần)

| Run | Before | After |
|---|---|---|
| `--without tech:verdant-cycle-scripture` | 11.3 s, 20-0, foe dry 9.5 | 11.5 s, 20-0, foe dry 9.7 (its passives mostly print "no engine stat") |
| `--without still-water` (identity piece: the modelled Effect; Surplus Life itself is unmodelled) | 11.3 s, 20-0, foe dry 9.5 | 11.3 s, 20-0, foe dry 9.5 (never triggered; no linh lực overflow here) |

## UNMODELLED

- Surplus Life (Dư Sinh): needs a health-overflow readable; the engine only emits linh lực overflow.
- Rooted (Bám Rễ) price: evade fixed at 0 is not expressible.
- Spillover (Dật Độc): no action burns the foe's linh lực from a tick.
- Wards beyond the Common Ward: per-hit and reserved wards are not modelled.
- Underground Spring, Banyan Shade, Shedding Bark, Quiet Channels, Spring Never Fails, Hot Spring Array, pill, coating: not in the library or not modelled.
- Technique passives with no engine stat (stack effect/duration, health regeneration inc, body shield, health, art cost health, curse status duration); the `[moc]` art-speed scope applies to every art.

## Observations

The typical Hóa Thần fight ends in 11.3 s with 20 wins, far under the 30–60 s band, and the build never goes dry; the
foe dries at 9.5 s, so the kill comes through its linh lực, not a slow Poison, and fatigue is never reached. The
guide's "dead in about 25 s" and "last one standing at 66–72 s" do not hold in this run: the Poison and the thornling
summon kill faster than the guide expected, while the guide's central mechanism (Surplus Life turning overheal into
Poison) is absent, so this result does not test it. The guide's alpha-strike weakness does hold: the top_end foe
kills the build in 1.6 s, before any art fires, and all seven arts are NEVER_FIRED there. In the typical fight
`second-spring` fires only 0.1 per fight because the bar stays above 95 %. Removing the main technique's passives adds 0.2 s and
removing Still Water changes nothing, so neither drives this result. Several Effect numbers
(Growth Rings, Sap Rises, Still Water's amount) were my guesses at the engine's units, not tuned or checked.
