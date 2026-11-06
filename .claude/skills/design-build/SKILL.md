---
name: design-build
description: "Turns a build idea into a complete cultivator build: Công Pháp, arts, items, modifiers and lore. Takes a game concept, a lore concept or both, offers creative directions to choose from, then generates. Use whenever the user describes a build, playstyle, cultivator archetype, sect style or technique idea they want designed, even if they never say 'build'."
argument-hint: "[what the build should do, or its lore, or both]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Bash(bash "*/.claude/skills/design-build/../../hooks/yaml-helper.sh" resolve_config *)
model: opus
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys automation`

# Design Build

The user describes a build. This skill turns that seed into something with depth: a way of
fighting, a reason it exists in the world, and every piece needed to make it real. The value is
in the creative leap, so most of the effort goes into offering directions the user would not have
thought of, then making the chosen one hold together.

**Output:** `design/builds/[slug].md`, a design sheet. It writes nothing to `assets/data/`: many
fields, such as arts and new modifiers, have no code reading them yet.

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

Read `references/content-formats.md`, then the sources it lists for what this build touches. Read
`references/creative-lenses.md` before writing any suggestion. Design docs are read by section:
find headings with Grep (`^#`) and read those ranges.

Values change often, so take numbers from the data files and GDDs on each run, never from memory
of an earlier run.

## Phase 3: Suggest directions

Print **6 directions** in the chat, each one genuinely different. Six variations on one idea are
one suggestion, so vary the lens behind each (see `references/creative-lenses.md`), and let at
least one surprise: a reading of the seed the user did not ask for but might love.

For each direction give:

- **Name**, in English with Hán-Việt: `The Patient Blade (Ẩn Phong Đạo)`
- **The fantasy:** one line on how it feels.
- **How it wins:** the mechanism, in terms of the real fight (rule 10 timeline, linh lực, wards).
- **The signature moment:** the one thing a player would screenshot or tell a friend.
- **The price:** what it gives up, and what beats it.
- **Lore hook:** where it comes from. Skip this only when the user's lore already supplied it.
- **Fit:** `Fits today`, `Needs keys` or `Needs rules`, so the user sees the cost of the idea.

Then ask with `AskUserQuestion`. The tool holds four options and the user may see only the dialog,
so offer your four strongest, each with a self-contained description, and say in the question that
any of the six, a mix of two, or a new idea can go in the Other box.

Next, one multi-tab `AskUserQuestion` for what shapes the generation:

- **Realm span:** one realm, or the whole climb from Qi Refining to Deity Transformation.
- **Power level:** an ordinary cultivator's path, a top-end build, or a rare legend.
- **Spiritual root:** one you suggest for this direction (name it), or one the user supplies.
- **Use:** a player build to aim for, an NPC or sect archetype, or a boss.

If the user rejects all six, ask what was wrong in one line and offer six new ones. Rejection is
useful: it tells you which lens to leave.

## Phase 4: Set the spine

Before generating, write the build's spine and show it. It is four lines, and everything generated
later must serve it, which is what keeps a build from becoming a pile of good-sounding parts.

- **The loop:** what the build does, over and over.
- **The engine:** the one interaction that makes it more than its parts.
- **The sacrifice:** what it cannot do, and refuses to fix.
- **The arc:** how it changes from its first realm to its last, as play and as story.

Offer `[A] Build it` / `[B] Change something`. An extra round here is cheap, and regenerating a
full sheet is not.

## Phase 5: Generate

Fill `assets/build-sheet-template.md`. Generate only the sections this build uses: a build with no
companion has no companion section. Every piece must do one of three things: feed the engine, pay
for the sacrifice, or carry the arc. Cut anything that does none of these, however good it sounds.

Depth comes from connections. Prefer an art that changes what another art does over a bigger
number. Each item should make a reader think "oh, that's why", and the lore and the mechanics should
explain each other: if the technique's founder died of it, the build should have a way to die of it.

Label every piece:

- **Fits today:** uses only existing keys and rules.
- **Needs key:** a new stat key or tag, no rule change.
- **Needs rule:** changes or adds a rule in a GDD. Name the rule.

Reuse names from `design/quick-specs/tree-modifier-catalogue.md` where they fit. Numbers on anything
new are first guesses, and the sheet says so.

## Phase 6: Check it

Run these and fix what fails before showing the sheet. Each check reports `PASS`, `FAIL` or
`NOT ASSESSED`, with the reason. `NOT ASSESSED` means the check could not run, for example a pool
maximum with no entry in `bonus_pool` or a rule that has no value yet. It is not a softer `FAIL`,
and it never counts as a pass, so the sheet's status line and the Phase 7 summary name every one.
A check on a `Needs key` piece usually lands here, and that is an honest result.

1. **Budgets:** each technique inside its tier's bonus budget and single-bonus cap; each art inside
   the art lint; slots used within `slots_by_realm`; artifacts within `equip.max_slots` and thần thức.
2. **Validity:** real element, variant, realm, tier and base ids; a tier's `max_realm` reaches the
   span claimed; aux arts checked for harmony with the main method.
3. **A fight on paper:** walk 15 to 20 seconds of the timeline at one realm, tracking cooldowns and
   linh lực second by second. Most builds that look good fail here, usually by running dry at 4 s.
4. **Counterplay:** name a real enemy type (Combat rule 18) that beats it, and how. A build with no
   counter breaks Pillar 3, and a build with no way to win breaks the fantasy.
5. **Originality:** no name, character or signature technique lifted from an existing novel or game.

## Phase 7: Save and offer next steps

Show a summary of the build: spine, main pieces, check results, and the count of `Needs key` and
`Needs rule` items. Then ask "May I write this to `design/builds/[slug].md`?" and write on approval.

Close with `AskUserQuestion`, offering what fits:

- `Sharpen a piece`: rework one technique, art or item.
- `Make a rival`: design the build that hunts this one.
- `Add its new modifiers to the catalogue`: append them to `tree-modifier-catalogue.md`.
- `Try another direction`: return to the six from Phase 3.
- `Stop here`.

Adding a build to game data, or changing a GDD for a `Needs rule` item, is a separate piece of work
with its own approval. Say so when the user asks, and do not fold it into this skill.
