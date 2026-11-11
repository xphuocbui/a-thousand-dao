---
name: design-build
description: "Turns a build concept into a complete cultivator build, modifiers first: finds the enabling effect, forges the modifiers that stack on it, then gives them to techniques, arts, items, tree clusters, Đạo or new concepts, and proves it on the fight timeline. Use whenever the user describes a build, playstyle, cultivator archetype, sect style, enabling item or technique idea they want designed, even if they never say 'build'. Also promotes a saved build's pieces into the GDDs."
argument-hint: "[build concept, lore, or both] | promote [slug]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Bash(bash "*/.claude/skills/design-build/../../hooks/yaml-helper.sh" resolve_config *), Bash(python .claude/skills/design-build/scripts/fight.py *)
model: opus
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys automation`

# Design Build

This game is built around builds. Like Path of Exile, a build is **a concept with modifiers stacked on
it**, sometimes opened by one enabling piece: an armour that grants a death aura, then everything the
aura wants. Items, techniques (công pháp), arts, the tree, Đạo and roots all exist to serve that.

So this skill works from the build outward. It takes a concept, works out what the fight rewards it for,
forges the modifiers, and only then decides which system carries each one. If the game lacks something
the build needs, the skill proposes it. The value is in the creative leap and in knowing the rules well
enough to make the leap land.

**Output:** `design/builds/[slug].md` (the sheet), `design/builds/[slug].fight.json` (its fight input),
and additions to `design/builds/content-ledger.md` and the modifier catalogue. It writes nothing to
`assets/data/`: many fields, such as arts and new modifiers, have no code reading them yet.

If `$ARGUMENTS` starts with `promote`, go to **Promote**, at the end.

Every `AskUserQuestion` call follows `.claude/docs/automation-modes.md`, with one exception: the
choice of direction in Phase 3 is the point of the skill, so it is always asked, in every mode.

---

## Phase 1: Read the seed

Sort what the user gave into one of four shapes. This decides what the suggestions must add.

| Seed | Example | What the suggestions must supply |
|---|---|---|
| **Game concept** | "drain their linh lực until the ward fails" | The lore: who would fight this way, and why |
| **Lore concept** | "a widow who cultivates grief for her dead sect" | The mechanics: what grief does in a fight |
| **Both** | "a blind swordsman who hits harder the longer he waits" | The fusion: where the two reinforce or strain each other |
| **Vague or empty** | "something cool with poison" | Both, and more range between the options |

If `$ARGUMENTS` is empty, ask for the seed in plain text: what the build should do, what its story
is, or both. One sentence is enough. Do not interview the user before suggesting; suggestions are
a faster way to find out what they want than questions are.

## Phase 2: Load the rules

Read these before suggesting anything. A creative idea that ignores the rules is the commonest failure
of this skill. **Read each file once.** They do not change during the run, so never read one again;
every re-read is paid again on every later turn.

1. `references/combat-model.md`: how the fight rewards a build.
2. `references/modifier-forge.md`: how modifiers and enablers are made.
3. `references/creative-lenses.md`: how to avoid the literal answer.
4. `design/quick-specs/tree-modifier-catalogue.md`: the modifiers and keystones that already exist.
5. `design/builds/content-ledger.md` if it exists: what earlier builds already made. Reuse it.

Then run `python .claude/skills/design-build/scripts/fight.py --numbers` for the numbers a build is
designed against (layers and caps, the art lint, costs, regeneration, fatigue, wards and the ward and body
layers, element stacks), each checked against the GDD text. Use these, not memory of an earlier run. If it
prints `NOT_VERIFIED`, read only the drifted GDD lines it names. Run `fight.py --selftest` too: if it reports
`CONSTANT_DRIFT`, `SIM_DRIFT`, `SELFTEST_FAIL` or `LOADER_FAIL`, or Python is missing, carry on, but the
fight check in Phase 7 is `NOT ASSESSED` and the sheet says why.

**What not to read.** GDDs, data files and catalogues are large, and the digest above covers the numbers:

- **GDDs** (`design/gdd/*.md`): Grep only, for one rule or Effect, and read at most about 40 lines around
  the hit. Reasons to look: to cite the rule a `Needs rule` piece changes, or to reuse an Effect from
  `effects.md` (Status Catalogue, Starter Effects) or a Way from `dao.md` (Catalogue). Never read a GDD's
  Core Rules or Formulas whole.
- **Data** (`assets/data/*.json`): Grep for the id or name you need.
- **Other builds' sheets and guides, earlier runs, session logs, simulator source**: do not read them. The
  ledger and catalogues say what exists.

`references/system-roles.md`, `references/content-formats.md` and the sheet template are for Phase 6: read
each once there.

**Write in few steps.** Write the sheet (and any other output file) whole with one Write when its content
is ready, then fix it with a few Edits. Building a file one line at a time costs one full turn per line.

## Phase 3: Find the enabler and the stack

Print directions in the chat, each one genuinely different: **6 for a vague seed, 3 for a specific
concept**, because a specific concept needs different readings, not a survey. Vary the lens behind each,
and let at least one surprise: a reading the user did not ask for but might love.

For each direction give:

- **Name**, in English with Hán-Việt: `The Patient Blade (Ẩn Phong Đạo)`
- **The fantasy:** one line on how it feels.
- **Channel:** how the damage or the win arrives (`combat-model.md`, Damage channels).
- **Enabler:** what opens it and what that closes, or `none` if it is a stack of what exists.
- **The stack:** the three or four modifier ideas that define it, including its strangest one.
- **The signature moment:** the one thing a player would screenshot or tell a friend.
- **The price:** what it gives up, and what beats it.
- **Lore hook:** where it comes from. Skip this only when the user's lore already supplied it.
- **Fit:** `Fits today`, `Needs keys` or `Needs rules`. This shows what the idea asks of the game. It is
  not a mark against it.

Then ask with `AskUserQuestion`. The tool holds four options and the user may see only the dialog,
so offer your strongest (at most four), each with a self-contained description, and say in the question
that any direction, a mix of two, or a new idea can go in the Other box.

Next, one multi-tab `AskUserQuestion` for what shapes the generation:

- **Realm span:** one realm, or the whole climb from Qi Refining to Deity Transformation.
- **Power level:** an ordinary cultivator's path, a top-end build, or a rare legend.
- **Spiritual root:** one you suggest for this direction (name it), or one the user supplies.
- **Use:** a player build to aim for, an NPC or sect archetype, or a boss.

If the user rejects all of them, ask what was wrong in one line and offer new ones. Rejection is
useful: it tells you which lens to leave.

## Phase 4: Set the spine

Before forging, write the build's spine and show it. Everything later must serve it, which is what
keeps a build from becoming a pile of good-sounding parts.

- **The channel:** how it wins, in the terms of `combat-model.md`, and which layers and caps that means.
- **The enabler:** what opens the build and what it closes, or `none`.
- **The loop:** what the build does, over and over.
- **The engine:** the one interaction that makes it more than its parts.
- **The sacrifice:** what it cannot do, and refuses to fix.
- **The arc:** how it changes from its first realm to its last, as play and as story.

Offer `[A] Forge it` / `[B] Change something`. An extra round here is cheap, and regenerating a
full sheet is not.

## Phase 5: Forge the modifiers

This is the most important phase. Do it before thinking about items or techniques.

1. **Climb the stack ladder** (`modifier-forge.md`) for the build's channel. For each rung, write what the
   build wants.
2. **Check what exists.** Look each want up in the data, the catalogue and the ledger. Mark it `exists`,
   `designed` or `missing`. Reuse before inventing, and reuse by name.
3. **Forge what is missing.** Use the forms table and the creative moves. Start from a rule, not a theme
   word. The ladder sets the count, usually 10 to 16 modifiers, across **at least four forms**.
4. **Test each new modifier** against the seven tests in the forge. Name its second home. A piece with no
   second home is labelled `signature`, and a build gets few of those.

Show the modifier table in the chat: rung, modifier, form, channel, layer, scope, size, status and second
home. Offer `[A] Good, give them homes` / `[B] Change some` / `[C] Push it further`. `[C]` means a stranger
stack: replace the most ordinary rungs and look for another identity piece.

## Phase 6: Give the pieces homes

Read `references/system-roles.md` and `references/content-formats.md` once, then Grep the sources they
list for what this build touches (Phase 2's "What not to read" holds here too). Assign every modifier to the system that should carry it, spread across systems, then
generate what carries them. Fill `assets/build-sheet-template.md`. Generate only the sections this build
uses: a build with no companion has no companion section.

Create whichever of these the build needs: the enabler, techniques, arts, wards, artifacts, talismans,
pills, formations, a companion, hidden cluster ideas, a Đạo or a Đạo branch, and new concepts. Every piece
must do one of three things: feed the engine, pay for the sacrifice, or carry the arc. Cut anything that
does none of these, however good it sounds.

Depth comes from connections. Prefer an art that changes what another art does over a bigger
number. Each item should make a reader think "oh, that's why", and the lore and the mechanics should
explain each other: if the technique's founder died of it, the build should have a way to die of it.

Label every piece:

- **Fits today:** uses only existing keys and rules.
- **Needs key:** a new stat key or tag, no rule change.
- **Needs rule:** changes or adds a rule in a GDD. Name the rule.

Two limits hold whatever the build wants. Tree nodes are never authored: a tree need becomes a cluster idea
in the catalogue. A change to Combat's layers or caps is allowed only as a flagged `Needs rule` proposal
that names the trade-off, and it does not open a rebalance.

Numbers on anything new are first guesses, and the sheet says so.

## Phase 7: Prove it

Write `design/builds/[slug].fight.json` (format in `content-formats.md`), then run
`python .claude/skills/design-build/scripts/fight.py design/builds/[slug].fight.json --matrix`.
It runs the build on `tools/design/combat_sim/sim.py`, the simulator the Combat GDDs cite, over 20 fixed
seeds. Add `--timeline` to see one fight pulse by pulse. Do this at the build's defining realm and at one
other realm. Then remove the identity piece with `--without "[its id]"`; the `identity` lines compare the
two runs. The script gives observations; the verdicts below are yours. A field the file format does not
know stops the run (`UNKNOWN_FIELD`): put that piece in `unmodelled` and model the nearest thing it can.

Run these and fix what fails before showing the sheet. Each check reports `PASS`, `FAIL` or
`NOT ASSESSED`, with the reason. `NOT ASSESSED` means the check could not run. It is not a softer `FAIL`,
and it never counts as a pass, so the sheet's status line and the Phase 8 summary name every one. A check
on a `Needs key` piece usually lands here, and that is an honest result.

1. **Budgets:** each technique inside its tier's bonus budget and single-bonus cap; each art inside the
   art lint; slots used within `slots_by_realm`; artifacts within `equip.max_slots` and thần thức.
2. **Validity:** real element, variant, realm, tier and base ids; a tier's `max_realm` reaches the
   span claimed; aux arts checked for harmony with the main method.
3. **Stack:** every ladder rung is filled or named as a sacrifice; no modifier targets something its
   channel does not use; the stack has four or more forms and an identity piece; each layer's total is
   stated, with which layers are empty and what that costs. **The identity test:** the `--without` run
   must change the fight: an `identity ... changed` line in at least one matchup the build claims. If every
   line reads `NO_CHANGE`, the piece does nothing and the sheet's claim is wrong, whatever it says. If the
   piece cannot be removed because it is unmodelled, this part is `NOT ASSESSED`.
4. **Scaling:** compare `m_static` and the layers with the typical and top-end anchors. Only a build that
   falls short of its stated power level fails. A build above the anchors is noted as `INFO` and is not
   pulled back, since only the macro targets matter.
5. **The fight:** the matrix shows the loop actually happens. It fails when the build runs dry before its
   engine works, when its key art shows `NEVER_FIRED`, or when a condition is never true. Name every
   `cap_hit` and `lint_over`. Same-realm fights against a typical foe should last 30–60 s for a typical
   build; a top-end build may end them in its first volley or two, and a top-end mirror lasts as long as a
   typical one (Combat rule 18). A `CONSTANT_DRIFT` or `SIM_DRIFT` line or a failed selftest makes this
   `NOT ASSESSED`. Each `UNMODELLED` line, and the `model_note` list of what the simulator does not model,
   names a piece the fight did not test, and the sheet lists them. If an unmodelled piece is the engine,
   this check is `NOT ASSESSED`.
6. **Reuse:** each new piece has a second home, signature pieces are few, and the build reuses earlier
   pieces where the ledger has any that fit. With no ledger yet, this reports `NOT ASSESSED` for reuse.
7. **NPC use:** the generator could use each new modifier, and one line of a Breakdown can explain it.
8. **Counterplay:** name a real enemy type (Combat rule 18) that beats it, and how. A build with no
   counter breaks Pillar 3, and a build with no way to win breaks the fantasy.
9. **Originality:** no name, character or signature technique lifted from an existing novel or game.
   Borrowing a structure from another game is fine, and borrowing its names is not.

## Phase 8: Save and hand off

Show a summary of the build: spine, enabler, the identity piece, main pieces, fight results, check
results, and the count of `Needs key` and `Needs rule` items. List the exact changes to the shared files.

Then ask once: "May I write the sheet and fight input to `design/builds/[slug]`, add these rows to
`design/builds/content-ledger.md`, and add these modifiers to `design/quick-specs/tree-modifier-catalogue.md`?"
On approval, write them. Create the ledger from `assets/content-ledger-template.md` if it is missing. Never
remove or rewrite an existing catalogue or ledger row; a build that reuses a piece adds its name to the
row's `Used by`.

Close with `AskUserQuestion`, offering what fits:

- `Sharpen a piece`: rework one modifier, technique, art or item.
- `Make a rival`: design the build that hunts this one.
- `Try another direction`: return to the directions from Phase 3.
- `Promote pieces`: move approved pieces into the GDDs (below).
- `Stop here`.

## Promote

`/design-build promote [slug]` moves a saved build's pieces toward the real game. It is separate because
it changes approved design documents. If no slug is given, list the sheets in `design/builds/`. If the sheet
is missing, stop and say so.

1. Read the sheet's New Content Needed table and the ledger. Show each piece with its label and where it
   would go: a stat key in `design/gdd/character-stats.md`, a rule in a named GDD, an open question, or a
   content entry.
2. Ask which pieces to promote. Skipped pieces stay as they are.
3. For each chosen piece, show the old and new GDD text, then ask "May I write this to `[filepath]`?" and
   write on approval, one file at a time. Follow `.claude/rules/design-docs.md`, keep Dependencies
   bidirectional, and add new entities to `design/registry/entities.yaml` the same way.
4. Never write `assets/data/` for a field that no code reads. Grep `src/` for the field first. If nothing
   reads it, the piece stays in the GDD and the report says so.
5. Mark promoted pieces in the ledger, and report each piece as promoted, skipped or blocked, with why.

Finish by recommending `/design-review [path]` for each GDD changed and `/propagate-design-change [path]`
when a promoted rule touches an existing decision.
