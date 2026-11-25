# Brief: build review for "working and fun" (world-depth pass)

User, 2026-11-25: "if a build theme or the build itself needs some more techniques, arts, wards, please feel free to
add it to the suggestion list. Or anything, not just these, anything to make the build working or fun."

Builds are the game (memory: a concept with modifiers stacked on it, sometimes opened by an enabler; the strongest arts
reach full power only through an engine). You review the **builds of tier A and B people and each sect's lineage as a
build family**. You look for what is missing for the build to work and to be fun, and you write it down. You change no
build.

## Read

- `design/world/depth/builds/README.md`: the wishlist format and scope (anything).
- `design/world/depth/builds/wishlist.md` and the other `wishlist-*.md` files there, so you don't repeat wishes
  already made. Add to an existing wish only with a new reason.
- For each sect in your batch:
  - its page section 5 (lineage) and `<key>.techniques.json`;
  - the arts its techniques carry (`design/arts/family-*.json` and the `new` arts in proposals);
  - its tier A and B people's `build` (archetype, main and aux techniques, gear, items, `tree.targets` and
    `targets_note`, `intent`, `note`);
  - the Đạo Đồ pieces their routes take (`design/world/depth/_inputs/dao_do/*.md`).
- Design references when you need them: `design/gdd/combat.md`, `design/gdd/effects.md`, `design/gdd/modifiers.md`
  (read by section).

## Ask of each lineage and each standout build

1. **Does it work?**
   - Does it have a way to deal damage, to survive, and to sustain linh lực over a 30-60 s fight (sustain is king)?
   - Do its pieces feed each other: is there an engine?
   - Is there an art it keeps naming but nobody has?
   - Is a stance or form missing, or a ward for a ward build, or a talisman for a talisman build?
2. **Is it fun?**
   - Does it have a moment: a combo, a turn, a counter, a payoff after a build-up, a choice in a fight?
   - Does it play differently from its neighbours?
   - What one piece would make it sing?
3. **Does it fit the world?** For example: a sect whose techniques never use its land, a lineage with no outer-gate
   art, or a master and disciple who play identically when they shouldn't.

## Write

Only `design/world/depth/builds/wishlist-review-<batch>.md`, in the README format.
- Group entries by sect.
- Give each a Kind: Technique, Art, Ward, Effect, Modifier, Item, Đạo Đồ piece or Other.
- Every entry names who needs it (keys) and has a "Fun" line where it applies.
- Aim for quality over count: about 2-5 entries per great sect, 0-2 per minor sect or group.
- Add a short summary at the top: the 3-5 strongest ideas in your batch.

Do not edit any other file. Do not commit. Do not run Godot. Report briefly (under 200 words): entry count and your top
ideas.
