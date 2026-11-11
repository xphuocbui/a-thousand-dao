# Review triage (overnight 2026-11-11)

Each batch review (`batch-*.md`, headless Sonnet, read-only) was triaged in-session. **Fixed** means the draft was
edited; **deferred** means the finding is real but waits on a decision or a later pass, and is listed here.

## Batch 01–14

**Fixed (high and medium):** Seal the Space no longer Silences `escape`. Mệnh: counted chance moved to its keystone
only (Fated Blow and Fated Dodge are every-8th counters). Empty Becomes Full is costed and rate-limited. Return to
One and Before Taiji are capped and defined in points. Swift as a Fleeing Hare, A Sun That Never Sets, Always the
Right Season, Endless Summer, Long Winter, Eternal Day, Golden Crow, Moon Palace, Starlit Eye, A World Apart,
Heaven's Secret, Child of Fortune, Mother of Elements, Stopped Heaven and The Formless Form now close something the
build uses. Bloom at Night counts Full phases; Endless Night shortens the cycle. Erosion is a curse (Eroded) with a
cap even under the capstone. Buff-stripping pieces point at the new R16. The Tinh meteor is inside `trig_budget`
and Stars count art hits only. The Two Fish Turn is defined (pairs, basic attack). The Fish Turn only helps. Union
arithmetic is defined. Stance minimum dwell is 4 s. First-hit bonuses are scoped to art hits. Batch durations were
added. "X % less damage" became "dampened (rule 6a)". Rewind is a Down-step refusal reading max(now, 5 s ago).
Unformed counts the largest element bonus per layer. Primal Mixing is defined. The duplicate capstone with
Ngũ Hành was split. Overcome and Balance were rescaled so they are reachable. Single Breath and Distant Light
became conditional. Jinx no longer duplicates Star's Shelter.

**Deferred:**
- **Theme-stats headers are partial** in every Way. The drawing pass sets `theme_stats` to exactly the keys the graph
  uses (dao.md rule 12). The text drafts list the main keys only.
- Wheel of the Year and other life-earned growth: see `_combos-and-risks.md` item 1 (a shared ceiling).
- Three timed-window majors (Âm Dương, Thái Dương, Thái Âm) still share a shape. Kept for now: each reads a
  different clock (day and night, the hours, the phases). Revisit when drawn.
- Flowers on the Crit: heal kept as a share of max health, not of damage dealt.

## Batch 15–26

**Fixed:** Down refusals set health to 1 and heal separately (Hỏa, Ngọc); the second refusal (Nirvana) flagged R5.
Drowned is a Force tick with one batch per pulse; The Sea Swallows has a fixed duration. Vụ's veil is only an
accuracy loss; Ám's opener is a time window (first 8 s) because "until hit" was empty. Six "stacks never expire"
capstones are differentiated: Kim caps at 30, Mộc decays 1 a pulse (and rivals Blossom), Thổ keeps it but caps
Earth dampening at 60 %. Free closes fixed (Immovable, Gravity Well, Lord of Shadows, Lava Body, Nine Furnaces);
Heaven's Mirror keeps Exposed. Cash-in pieces point at the new R19; non-events rewritten (R20); foe-stat changes
became owner modifiers or statuses (R21). Cap shifts labelled `Needs rule` (R14); Nine Heavens is now "crit over
the cap becomes crit damage". Carry the Tribulation's cap is reachable and the self-hit is flagged. Blossom heal
capped at 25 %. Plain-number minors given conditions. Ten Thousand Blades is 50 + 50 %. Wind Has No Floor rivals
Over the Limit. Judgement works against foes that do not curse. Mark for Death's kill rider moved to crits.

**Deferred:** theme-stats headers (as batch 01–14); Phong and Lôi dual-root facets (kept: they are the dual-root
bridge, single-root players have four other facets); Thổ/Băng timer roles both stay until R1 is decided.

## Batch 27–37

**Fixed:** pieces that read removed or non-existent things: `regen_cap` (The Undying Body), status- and soul-resistance
caps (Heart of the Lotus, Unshakable Soul), Chaos on a body shield (Calcify), full regeneration blocks (Last Breath,
Drink of the Springs, Death and Awakening, Titan → dampening). Haunt is a run-on wound reported to the caller, not a
damaging curse. Eternal Return returns once at half size. The Huyết health-to-shield loop is netted (30 %, cap 15 %),
health payment only below 50 % linh lực, and no line lowers the health-cost rate any more (Đao's Pay in Red too).
Life Is the Only Currency and Crimson Aegis are rivals. White Bone Demon closes regeneration; Draw the Bone fires every
Physical art. Refusals set health 1, then heal (Rebirth, Walk the Threshold); second refusals point at R5. Plates are
defined (value, ticks). Flesh Beats Treasure: the capstone replaces the major. Pure Water every 8 s, up to 15
stacks. Lotus Seeds per crossing, 3 a fight. Calming Scent within 5 pulses. Possessed lasts until the next art.
Ghost hits use Formulas E2. Corpse Rot now has a source in Sinh Tử. Tick-heals are pulse sums. Borrowed Power
repays on a fixed window. Compounding is linear. Fear and charm defined in the README.

**Deferred:** Down-refusal majors still sit in Sinh Tử, Luân Hồi and Hỏa (R5 limits them to one per fight; which
Way keeps the refusal *major* is a design call). Three "permanent gain from winning at the edge" majors (Sinh Tử,
Bỉ Ngạn, Huyết) wait on the life-earned ceiling (`_combos-and-risks.md` item 1). Six Paths as One and Walk All Six
kept as major and capstone (the capstone deepens the major).

## Batch 38–51

**Fixed:** Outlast no longer touches fatigue (Combat rule 10). Counted chance was removed from minors and from
the foe side (Measured, Fear, Form Is Emptiness); Mệnh and Kiếm keep the only keystone counts. Steady Power is
scoped to its own Way and sized below the usual conditionals. Heartless Strength works with no companion. Vows
count only if they forbid something you hold, at L5 +10 each (+14 and 4 Vows with the capstone). The Dream has
an explicit no-Down window and a defined restore (50 % of health lost), and only short arts fire in it; Never Wake
is a short repeat with no healing. Decoys are 2, absorb art hits of 15 %+ (read before defence), and rebuild
every 15 s. Cull spares bosses and tribulations, the capstone threshold is 12 % and closes all healing, and its
post-kill riders now act before the kill. Mutual Ruin is defined over damage taken and can be capped meaningfully.
Moods have a priority and decay. Love is a live damage bonus, not a share change. Sorrow uses an event. Nine Lives
is a refusal. Enthral and Corrupted are built from existing curses; Dusted folded into Earth's debuff. Killing
Intent is Thunder debuff stacks. Blood Sacrifice costs 3 months, and the capstone costs every time. Turned Demon is
limited to theme stats; Dao Heart is capped at +5 pp. Sudden Clarity and Sudden Insight no longer give the same
payload, and neither gives Dao nodes. Tempered by Red Dust is additive. Slow Burn is a flat per-pulse amount.
Compassion ignores regeneration; Merit has a scale. Petal Rain is one firing with a rounding rule. Fading Bloom
leaves fight-long batches alone. Curse-duration changes go to R22.

**Deferred:** curse immunities in Vô Tình and Thiền kept as different shapes (halving against a high-health
window); theme-stats headers as before.
