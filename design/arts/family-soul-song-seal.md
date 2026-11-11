# Family: Soul, Song, Seal (Thần Thức, Khúc, Ấn / Phù)

> 8 authored arts: 3 standalone, 5 engine. Lint: 0 findings (`python -I tools/design/arts/lint_arts.py design/arts/family-soul-song-seal.json`).
> Built from `_draft1`: the seven draft arts are kept and upgraded; Blood-Ink Writ is new. Raw ideas, numbers first guesses.

| Art | Power | Mechanic shape | Engine (how to feed it) | Hooks | One-line rule |
|---|---|---|---|---|---|
| Tolling Bell Requiem (Điếu Chung Khúc) | engine | Build-up and echo (Toll counter, fires once per Toll) | Great Peal: 3 Tolls (any soul hit feeds them), OR 1 Slackened Soul on the foe, OR another canon art fired this pulse. Death Knell: 5 Tolls AND (2 Slackened Soul OR you at 40 % health) | soul hits, art speed, trigger damage, x_soul, low health | Each soul hit adds a Toll; each ring strikes once per Toll, and a fed ring becomes a Peal then a Knell |
| Lamp-Oil Lance (Đăng Du Thương) | engine | Second pool (divine sense) and a curse payoff | Fully Lit: 6 Tolls AND (foe at 2 Slackened Soul, OR foe dry of linh lực, OR 4 Tolls, OR Bell rang in the last 2 s) (tune 2) | divine sense, slackened stacks, foe linh lực, cost reduction | Paid in thần thức; refunds linh lực per Slackened Soul; fully lit it strikes heavy and refunds 8 % |
| Ambush Talisman (Phục Kích Phù) | engine | Held payload (up to 3 talismans spring on the next hit) | Snare: 3 Seals, OR Exposed foe, OR another ledger seal this pulse. Death Trap: 4 Seals AND (foe at 50 % health OR you at 40 % health) | seal count, timer delay, hit count, exposed, low health | Talismans wait and spring on your next hit; fed, the talisman hits 3x then 7x |
| Frozen Hour Seal (Đình Thời Ấn) | engine | Delay and Slowed Time (steals the foe's time) | Hour Stopped: 2 Seals AND (1 Slowed Time on the foe, OR Ambush set in the last 3 s, OR 4 Seals) | slowed time stacks, cooldown reduction, curse duration, art speed | Slowed Time on the foe speeds your other arts; fed, 5x force and a 2 s cut to all your other arts |
| Branding Seal (Lạc Ấn) | engine | Conversion (40 % to Soul, 100 % when fed) | Sunk to the Soul: 2 Seals AND (2 Slackened Soul, OR foe at 50 % health, OR another ledger seal this pulse) | conversion, soul damage, thick wards, heavy arts, crit | A heavy seal that is partly Soul; fed, 4x and wholly Soul |
| Marching Dirge (Hành Quân Khúc) | standalone | Stance with a finale (toggle) | n/a | art speed, basic speed, trigger damage, stance switching | March 20 % faster and 20 % dearer; ending it pays a free hit per Measure |
| Thorn Lullaby (Cức Mộng Ru) | standalone | Healing as a weapon | n/a | healing received, regeneration, leech, x_soul | Heals and shields; every heal you receive thorns the foe's soul |
| Blood-Ink Writ (Huyết Mặc Phù) | standalone | Health payment and a curse pattern | n/a | curse count, distinct statuses, health cost, healing | 8 % health paid; Withering and Stagnation; seals gain per different foe status |

Gated payoff lines (lint `engine_payoff`): Ambush step 2 x3.4, Frozen Hour x3.6, Branding x3.4 on the art's c_art. Ambush step 1 is x1.5 on c_art, with three more free hits from the held banks. The two soul arts pay through `free_hit` in `pay` (c 3.0, 7.0, 3.5 Soul), which the c_art lint does not measure; they read as roughly 3-6x a plain soul art of the same cost.

## Suite 1: Hollow Bell Canon (`hollow-bell-canon`): soul rhythm
Bell and Lance. The Bell builds Tolls from any soul hit and its Peal fires on the Lance's slackening; the Lance is Fully Lit by 4 Tolls or by the Bell ringing within 2 s, and slackens the foe, which in turn unlocks the Bell's Peal. Two arts, one loop: slacken, ring, light, ring. Other soul sources (Lullaby thorns) feed Tolls too.

## Suite 2: Nine Seal Ledger (`nine-seal-ledger`): seals and talismans
Ambush, Frozen Hour and Branding share a Seal counter (each seal art adds one, gated steps spend them), and each reads the others: Ambush's Snare unlocks on another ledger seal fired the same pulse; Frozen Hour reads the Ambush set 3 s ago; Branding wants the Slackened Soul the Bell canon lays, so the two suites cross. Blood-Ink Writ is a standalone that boosts any seal art.

## Library arts replaced
`bell-of-waking`, `lamp-threading-needle` (Bell); `heart-lamp-lance`, `ninth-weight-lance` (Lance); `straw-binding` (Ambush); `dragging-moment` (Frozen Hour); `unravelling-seal` (Branding). Dirge, Lullaby and Blood-Ink have no source. The `common` arts of this family stay as they are.

## What the engine could not express
- A step or empower cannot override `soul_pct`, so soul arts (c_art 0) have no `c_mult` payoff; the Bell and Lance pay through `free_hit` in `pay` instead. Missing piece: `soul_pct` / `soul_part` multiplier in OVERRIDE.
- Free hits from `pay` share the trigger budget and cap, so a big Peal may be clipped; the lint cannot see it.
- Blood-Ink's "stronger per distinct status" uses `mod` key `dmg_more` with a `tags` scope; the lint only validates it by the engine schema, not that the tag scoping is honoured. `hp_cost` is added on top of linh lực cost; a "replace linh lực cost" form is missing.
- `foe.qi_share` is used as the foe's "dry" readable; confirm it exists in the readable list (lint passed it).
- Dirge: whether firing a second time inside the stance toggles correctly depends on `state` toggle ordering relative to the finale Effect (finale is written to read the state before the toggle; untested in a fight).
