# Spiritual root purity powers element stacks (decided direction, 2026-11-10)

Decided by the user on 2026-11-10; the GDD changes are still to draft (Spiritual Roots, Effects System, Meridian Map).

## The decisions

1. **Purity is the proficiency.** A root's element purity (10–100 at birth) is also its proficiency with that
   element's stacks. There is no separate stat. Purity can now **rise past 100 with no cap**, but every source of it is
   **low or rare**, so it is hard to accumulate.
2. **Stack power from purity:** each element's buff and debuff stacks are multiplied by `(1 + 0.002 × purity)`, its
   own "more" multiplier, apart from `stack_effect_pct`. Purity 50 gives +10 %, 100 gives +20 %, 300 gives +60 %.
3. **Ice and Water share at half rate:** Water purity also powers Ice's debuff at half rate, and Ice purity powers
   Water's buff at half rate.
4. **Elements you do not own** can gain purity from the tree, starting at 0.
5. **Meridian roads grant purity:** the roads of an element land grant only that element's purity, priced near a road
   node's value (a small tax for builds that do not use stacks, as PoE's travel nodes are). Blend-zone roads grant half
   of each neighbour's element; hub roads keep general stats.

## Consequences to settle while drafting (Claude's notes)

- **Owning an element:** decision 4 needs a rule. Recommendation: tree-granted purity in an element the root does not
  own powers its stacks only; it does not make the root own that element, so it changes no element count, pair bonus,
  speed curve or variant roll.
- **Purity above 100 touches other rules:** technique speed (average purity ÷ 100), variant chances (products of
  purities, already clamped at 1), a variant's purity (clamped 8–80 or 10–100) and the craft roles. Each needs a
  ruling: read the uncapped purity, or read it capped at 100 for that use. Recommendation: craft roles and technique
  speed read it capped at 100; stacks read it uncapped.
- **Variants:** a variant root's purity powers its own stacks (Thunder, Wind, Ice) the same way.
- **Sources:** the map's roads (5), plus rare pills, treasures or Đạo nodes; none common.
- **Pricing:** a point of purity is worth 0.2 % more stack power; the simulator (`tools/design/combat_sim/`) can price
  it against a stack build.
- **Applied 2026-11-10:** linh-can.md rule 8a, Formulas H, capped reads, edge cases, AC-LC-52/53, OQ 14; effects.md rule 9a line; kinh-mach-do.md road redraw rule.
