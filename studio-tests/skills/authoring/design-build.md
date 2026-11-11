# Skill Test Spec: /design-build

## Skill Summary

`/design-build [concept]` turns a build concept into a complete cultivator build, modifiers first. It
reads the seed, loads the combat model and the modifier forge, offers directions framed as an enabler
plus a stack, sets a spine, forges the modifiers up the stack ladder, then assigns them to systems and
generates what carries them. It proves the build with `scripts/fight.py` (the combat simulator), reports each check as
`PASS`, `FAIL` or `NOT ASSESSED`, and on approval writes `design/builds/[slug].md`, its `.fight.json`,
ledger rows and catalogue rows. `/design-build promote [slug]` moves chosen pieces into the GDDs with
per-file approval. It never writes `assets/data/` for a field no code reads, and never edits
`meridian_tree.json`.

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/skill-test spec` — no fixture needed.

- [ ] Frontmatter has all required fields (`name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`)
- [ ] 2+ phase headings found
- [ ] Contains `PASS`, `FAIL` and `NOT ASSESSED`, and says `NOT ASSESSED` never counts as a pass
- [ ] Contains "May I write" language for the save and for each promoted file
- [ ] Next-step handoff present at the end
- [ ] Phase 5 (modifiers) comes before Phase 6 (assigning systems)
- [ ] The direction choice is always asked, in every automation mode

---

## Director Gate Checks

None. The skill resolves only `automation`, has no `Agent` tool in `allowed-tools`, and spawns no
director or specialist agent.

---

## Fixture Defaults

Every case's `project.yaml` sets `modes.rigor: minimal` and
`modes.automation: collaborative`, with no `project.local.yaml`, unless its own
Fixture says otherwise. Rules: `studio-tests/CLAUDE.md` § Fixture defaults.

---

## Test Cases

### Case 1: Happy Path — a concept with an enabler

**Fixture:**
- `design/gdd/combat.md`, `design/quick-specs/tree-modifier-catalogue.md` and the skill's references exist
- `design/builds/content-ledger.md` does not exist

**Input:** `/design-build an aura that rots the enemy, then stack around it`

**Expected behavior:**
1. Treats the seed as specific and offers 3 directions, each naming a channel, an enabler and a stack
2. Asks the direction with `AskUserQuestion`, then the realm, power, root and use
3. Shows a spine that includes channel and enabler before forging
4. Shows the modifier table across at least four forms, with a second home or `signature` on each new piece
5. Runs `fight.py --matrix` and a `--without` run on the identity piece
6. Asks once before writing the sheet, fight input, ledger and catalogue rows

**Assertions:**
- [ ] No file is written before the single approval
- [ ] The Reuse check reports `NOT ASSESSED`, because no ledger exists
- [ ] The ledger is created from `assets/content-ledger-template.md`
- [ ] Nothing is written to `assets/data/` or `meridian_tree.json`

**Case Verdict**: PASS / FAIL / PARTIAL / NOT ASSESSED

### Case 2: The calculator cannot be trusted

**Fixture:**
- `fight.py`'s constant table holds an anchor that no longer appears in `design/gdd/combat.md` or `combat-defence.md`

**Input:** `/design-build a build that stacks one thing`

**Expected behavior:**
1. Phase 2's `--selftest` prints `CONSTANT_DRIFT`
2. The skill carries on and designs the build
3. The fight check reports `NOT ASSESSED` and names the drifted key

**Assertions:**
- [ ] The fight check is not `PASS`
- [ ] The sheet's status line and the Phase 8 summary both name the gap

**Case Verdict**: PASS / FAIL / PARTIAL / NOT ASSESSED

### Case 3: The identity piece does nothing

**Fixture:**
- A build whose identity modifier targets L5 on a tick channel, which L5 does not touch

**Input:** the build reaches Phase 7

**Expected behavior:**
1. The `--without` run gives the same result as the full run
2. The Stack check reports `FAIL`, and the skill fixes it before showing the sheet

**Assertions:**
- [ ] The build is not saved with an identity piece that changes nothing
- [ ] The sheet does not claim the piece is the engine

**Case Verdict**: PASS / FAIL / PARTIAL / NOT ASSESSED

### Case 4: A strong build is not pulled back

**Fixture:**
- A build whose `m_static` is above the top-end anchor at its realm

**Input:** the build reaches Phase 7

**Expected behavior:**
1. The Scaling check notes `INFO` and does not fail
2. The skill does not shave the build's numbers

**Assertions:**
- [ ] Scaling is not `FAIL`
- [ ] No rebalance round is opened

**Case Verdict**: PASS / FAIL / PARTIAL / NOT ASSESSED

### Case 5: Reuse across builds

**Fixture:**
- `design/builds/content-ledger.md` lists a modifier that fits the new build

**Input:** `/design-build a concept that wants that modifier`

**Expected behavior:**
1. Phase 5 marks the want as `designed` and reuses the modifier by name
2. Phase 8 adds the build to the row's `Used by` and rewrites nothing else

**Assertions:**
- [ ] No near copy of the modifier is invented
- [ ] Existing ledger and catalogue rows are otherwise unchanged

**Case Verdict**: PASS / FAIL / PARTIAL / NOT ASSESSED

### Case 6: Promote

**Fixture:**
- `design/builds/x.md` lists one `Needs rule` piece and one art with no code reader

**Input:** `/design-build promote x`

**Expected behavior:**
1. Lists each piece with where it would go, and asks which to promote
2. Shows old and new GDD text, then asks "May I write this to `[filepath]`?" per file
3. Greps `src/` before any `assets/data/` write, and keeps the art in the GDD because nothing reads it
4. Reports each piece as promoted, skipped or blocked

**Assertions:**
- [ ] No GDD is changed without its own approval
- [ ] `assets/data/` is unchanged
- [ ] The ledger marks only what was promoted

**Case Verdict**: PASS / FAIL / PARTIAL / NOT ASSESSED

---

## Protocol Compliance

- [ ] Asks before every write
- [ ] Reads design docs by section
- [ ] Takes numbers from the sources on each run
- [ ] `NOT ASSESSED` outranks `PASS`, never counts as one, and is named in the output
- [ ] New sizes are labelled first guesses
- [ ] No name, character or signature technique from an existing work

---

## Coverage Notes

The quality of the creative output is judged by a person, not by this spec. `fight.py` has its own
check: `--selftest` verifies its constants against the Combat GDDs and replays the simulator's scenarios.
