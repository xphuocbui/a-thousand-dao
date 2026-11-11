### art-thief: Loan slots, copying the foe's art

- **Kind:** New system
- **Touches:** `design/gdd/combat.md` rule 13 (arts, cooldown timers and slot order), rule 10 (instant order), rule 9 (the trigger budget, for Spent Hand)
- **Proposal:** An enabler may turn every empty art slot into a loan slot at the start of the fight. When the foe casts a body or qi art, the oldest empty loan slot records a copy: the foe's tags plus `stolen`, a fidelity share of its coefficient (70 % base), half its cost share, a first firing at half its cooldown. The copy is an ordinary art for the copier: its cooldown, linh lực and all five layers are the copier's. One copy per art id; a full hand loses the oldest copy; soul, ward and escape arts cannot be copied; copies end with the fight.
- **Why the build needs it:** it is the whole of The Hollow Thief; nothing today lets one side use the other side's art.
- **Trade-off:** it makes a fight depend on what the foe casts, so a simulator must model the foe's casts as events; a foe with no art gives nothing, which is the intended counter. It can feed back on itself (two thieves copying each other), so one copy per art id and the fidelity cap matter.

### art-thief: The foe's art list known before the fight

- **Kind:** Rule change
- **Touches:** `design/gdd/combat.md` Open Question 4 (what a character can read about the foe while preparing), rule 12 (blind fights)
- **Proposal:** Allow a preparation piece to read the foe's most costly known art. In a blind fight it reads nothing unless a formation says so (the Standing Array keystone).
- **Why the build needs it:** Pre-Read, the Nguyên Anh answer to the slow start.
- **Trade-off:** it adds information to preparation and gives scouts a reason to exist, and it could trivialise ambushes unless blind fights stay blind.
