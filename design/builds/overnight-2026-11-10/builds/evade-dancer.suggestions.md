### evade-dancer: Hit-evaded event

- **Kind:** New concept (an event).
- **Touches:** combat.md Formulas I (evade roll and the line that an evaded hit fires no on-hit trigger); effects.md rule 9 (events an Effect can listen to) and rule 12 (counted chance).
- **Proposal:** an evaded hit fires one "hit evaded" event on the defender, readable by Effects. It stays bounded by `trig_budget` and `trigger_depth`, and the evaded hit still deals nothing, drains nothing and fires no on-hit trigger of the attacker. The Breakdown shows "evaded n of m hits".
- **Why the build needs it:** Evade Pays, Reply and Carried Off all listen to it. Without it, evade is only a defence stat.
- **Trade-off:** more event traffic per fight and a new bound to test; enemies with Effects on evade (NPCs) get the same power, so a high-evade NPC becomes harder to kill.

### evade-dancer: Evade points over the cap readable

- **Kind:** Rule addition.
- **Touches:** combat.md Formulas I (`p_evade = clamp(...)`, `evade_cap`).
- **Proposal:** report the points the clamp removed (evade − accuracy + realm step above `evade_cap`) as a readable value, for Overflow modifiers.
- **Why the build needs it:** Surplus Breeze turns clipped evade into art speed, the one reason to stack evade past the cap.
- **Trade-off:** evade over the cap is no longer wasted, which slightly raises the worth of evade stacking; the overflow is capped at +20 % art speed to bound it.
