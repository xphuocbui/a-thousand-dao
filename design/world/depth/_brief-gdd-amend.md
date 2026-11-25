# Brief: amend one GDD from the world-depth rulings (2026-11-25)

The user ruled on the world-depth proposals group by group and then said (2026-11-25): "yes please go. i approve all
writes just go". So you amend your GDD **in place, without stopping for per-section approval**. Write it well: this is
the design record the code will be built from.

## Read first

1. `design/world/depth/DECISIONS-2026-11-25.md`: every ruling. These are binding.
2. `design/world/depth/rules-proposals.md`: R1-R8, the rules as proposed. A ruling wins where the two differ.
3. The sources your prompt names (e.g. `traits-v2.md`, `builds/duel-readings.md`, `schema.md`).
4. `design/gdd/linh-can.md`, the header line "Amended 2026-11-25" and rule 2 / Formulas A2 / D4: the finished example
   of this pass. Match its style for marking amendments.
5. Your GDD: find headings with Grep (`^#`, content mode) and read the sections you change by range. The 40 KB
   whole-read guard refuses whole reads of large docs.
6. `.claude/rules/design-docs.md` and `design/CLAUDE.md`: the GDD section standards.

## Do

- **Header.** Add a line after the status block:
  `> **Amended 2026-11-25** (user rulings, world-depth pass: design/world/depth/DECISIONS-2026-11-25.md groups …): <one sentence>.`
- **Rules.** Amend the rules in place.
  - Mark new or changed rules `(new, 2026-11-25)` or `(amended 2026-11-25)`.
  - Keep each rule unambiguous, and say why when the user's words explain it (quote them).
  - Don't rewrite unrelated text.
- **Formulas.** Every number gets the standard Formula block: the formula, a variables table (type, range, source,
  description), the output range and a worked example. Use the measured or proposed values from the depth folder.
  Where a value is a guess, say "guess".
- **Keep the rest of the doc in step:**
  - parameter keys and Tuning Knobs (safe ranges, what each moves);
  - Edge Cases (say what happens);
  - Dependencies and the Interactions table;
  - Acceptance Criteria, continuing the GDD's numbering and format, testable, marked BLOCKING or ADVISORY like its
    neighbours;
  - Open Questions, continuing the numbering. Use them for anything the rulings left open, the engine features a rule
    needs, and code effects for other systems.
- **Content.** Where your GDD owns content the pass wrote (a cast, a chronicle, lineages, items), point to the depth
  files as the authored source, with a pointer and counts. Don't copy them in.
- **Bidirectional dependencies.** If your amendment makes your system read another, add a line to your Dependencies.
  List the back-links other GDDs owe in your report; another writer adds them.

## Rules

- Edit **only your GDD file(s)** (named in your prompt). No other GDD, no registry, no systems index, no game data, no
  code. Do not commit. Do not run `/design-review`: the user wants one review pass at the end.
- **`design/gdd/sects.md` holds another session's uncommitted 3-line bullet**, "Formation teaching (built
  2026-11-24)", near line 157. Never touch or move it.
- Prefix scratchpad files with your GDD's slug.
- Report (under 250 words):
  - the sections changed;
  - new ACs (ids);
  - new Open Questions;
  - registry entries your amendment introduces (name, value, owner);
  - back-links owed by other GDDs.
