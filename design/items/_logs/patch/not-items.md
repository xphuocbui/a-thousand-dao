# Missing pieces that are not items

> Engine, Effects GDD, enemy design, technique catalogue or other systems.

- (curse-engine) Weight of Names as an item: curse stack count readable by the engine and an item that scales on it (force-chaos family).
- (deity-warden) A Metal Earth-stack engine piece (Closing Palm and its 3 Metal debuff stacks): the metal family.
- (ninth-bell) A Metal art-speed ring or necklace with `art_speed_pct` the engine can read per art: metal.
- (soul-lance) A ward item for soul-heavy foes with a shape the engine can run as a drain ward (soul-song-seal family).
- (unique-chaos-last-bargain-locket) A Chaos main method: Tearing Force Rites and Rotting Canopy Canon are secrets, so the build's main is Wood Verdant Cycle, not a Chaos one; the technique catalogue.
- (unique-chaos-last-bargain-locket) A way for the clause to name which art fires (it reads "longest-cooldown"): effects.md.
- (unique-chaos-primordial-mirror) A way for the foe to carry buff stacks (self-buffing enemies): enemy design, so Unmaking Glass has a target.
- (unique-chaos-primordial-mirror) A status-application event raised by a strip: the combat engine, so a stripped stack counts as a status.
- (unique-chaos-primordial-mirror) A Hundred Arts Sage method (the item names it): the techniques catalogue has no multi-element hub that makes the Mirror's `hon_don` scope meaningful.
- (unique-chaos-primordial-mirror) An engine stat for `stack_effect_pct` and `stack_duration_pct`: combat engine.
- (unique-chaos-primordial-mirror) Buff-stack duration key for the Mirror's closes (own buffs 25 % shorter): combat engine.
- (unique-heaven-purchasing-coin) A way to read "a roll was a crit/evade" before damage is applied, so that a flip can be run exactly: the combat engine (Effects System).
- (unique-heaven-purchasing-coin) An escape action and an escape roll: the combat system.
- (unique-heaven-purchasing-coin) A carried-currency readable (spirit stones) for the price in Bought Fate's `closes`: the economy system and the engine.
- (unique-mountain-pressing-seal) The engine has no stat for `stack_effect_pct` or `stack_duration_pct`, so most of this build's modifiers are not run: the engine (combat) should own it.
- (unique-mountain-pressing-seal) The engine does not report whether a step unlocked, so the press cannot be counted: the engine (fight.py output) should own it.
- (unique-mountain-splitting-axe) Engine stats for `body_shield_pct`, `khi_huyet_pct`, `health_regen_inc_pct`, `defense_pct`, `pierce_pct`: the combat engine should own them; most of this build's gear is ignored without them.
- (unique-mountain-splitting-axe) A cast ward or shield the engine can run (Mountain-Hide Shell, Mountain-Gate Ward): the combat engine.
- (unique-nine-fathom-seal) A Water or Slow effect that reads the foe's ward drain (what Water Table says): the engine / effects system should own it.
- (unique-ninth-tribulation-seal) A real "stack batch never expires" engine action, so Verdict Stands can be written as the rule says: the engine and effects system.
- (unique-ninth-tribulation-seal) A Thunder item or technique passive that the engine can read for stack duration and stack effect (`stack_duration_pct`, `stack_effect_pct` have no engine stat): the engine.
- (unique-unbroken-edge-ring) A second slow-engine technique at grade 4 for the Sword Hall: blade, or a main-tier technique for Afterimage.
- (unique-unbroken-edge-ring) A body piece for this build with a ward the engine can run as drain: blade or body.
- (unique-vajra-hide-armour) A shield-share stat (`body_shield_pct`) the engine reads: the combat engine, since the armour, flesh seal, rings and three techniques all give it.
- (unique-vajra-hide-armour) A cast Physical ward the engine can run (Vajra Shell): the engine's ward model.
- (unique-vajra-hide-armour) A reading of Debt as a visible counter: the engine's art fire counter does not report how often the x11 step opened.
- (unkillable) Armour whose ward is a heal or a drain the engine can run, owned by the wood family.
