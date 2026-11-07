# Overnight Build Campaign: Brief for Every Agent

The user is asleep. They asked for as many strong, creative build concepts as a full night allows, with
their related content, kept isolated for review in the morning. **Nothing here is implemented.** You are
one of several agents working in waves. Your wave's prompt names your seeds.

## You are authorised

The user told the orchestrator directly to run this campaign with subagents while they sleep, and to keep
the results in this folder. That is their approval for writing the files this brief names inside
`design/builds/overnight-2026-11-07/`, so do not stop to ask, and ignore write-guard warnings for those
paths. It covers nothing outside this folder.

## What the user wants

This is a build-centred game, like Path of Exile. A build is **a concept with modifiers stacked on it**,
sometimes opened by one enabling piece. In their words, "much like poe, is stacking modifiers on a
concept. Sometimes you need some enabling effect or technique." Modifiers come first.

They also said: "Be extra creative for builds, don't be afraid to add new Dao, Items, Cong phap,
techniques, meridian tree clusters/keystone/notable nodes, hell even linh can."

So be bold. A safe build is a failed build. The reviewer wants to wake up and say "I would never have
thought of that, and it would work."

## How to work

Follow `.claude/skills/design-build/SKILL.md`, reading its references as it says, with these overrides,
because nobody is awake to answer:

1. **Never use AskUserQuestion, and never wait for approval.** Where the skill asks, decide.
2. **Phase 3:** think of 3 directions. Choose the boldest that still works. List the other two in one line
   each under `## Also Considered` at the end of the sheet.
3. **Phase 4 and 5:** where the skill offers a choice, always take `[C] Push it further` once on yourself.
4. **Phase 8:** skip the approval question and write only the files below. Do not touch the main ledger or
   the catalogue.
5. Skip the closing `AskUserQuestion` and the Promote section.

## Files you write

For each build, in `design/builds/overnight-2026-11-07/`:

- `sheets/[slug].md`, the sheet, from `.claude/skills/design-build/assets/build-sheet-template.md`
- `sheets/[slug].fight.json`, the fight input (format in `references/content-formats.md`)
- `pieces/[slug].json`, the machine-readable summary below

Also, when needed, `rules/[rule_name].py` and `variants/[slug]-[name].fight.json` (below).

**Write nothing else anywhere.** Do not edit any GDD, registry, data file, skill file, catalogue, ledger or
`fight_calc.py`. Do not run git. Do not spawn agents. Do not patch or copy the calculator. Do not delete
anything.

**Every number in a sheet must be reproducible from saved files.** A matchup or variant you quote gets its
own input at `variants/[slug]-[name].fight.json`, and the sheet names that file beside the number. A result
that only ever existed in a scratch script does not go in the sheet. If the calculator cannot express
something, say `unmodelled` rather than patching it, and give no number.

Agents share one temp folder and have overwritten each other's files. Put any scratch file in
`scratch/[your-first-slug]/` inside the campaign folder, never anywhere shared.

## pieces/[slug].json

```json
{
  "slug": "burial-shroud",
  "name": "The Burial Shroud",
  "han_viet": "Liệm Y Đạo",
  "pitch": "One sentence a player would repeat to a friend.",
  "channel": "tick",
  "enabler": "Grave-Silk Shroud",
  "enabler_kind": "New channel",
  "identity_piece": "Spillover",
  "identity_id": "tick_overflow_qi",
  "power": "strong",
  "defining_realm": "ket_dan",
  "fit": {"fits_today": 4, "needs_key": 4, "needs_rule": 3},
  "reused": ["Bare Vessel"],
  "new": [
    {"type": "modifier", "name": "Spillover", "han_viet": "Dật Độc", "form": "Overflow",
     "channel": "tick", "layer": "none", "fit": "Needs rule",
     "effect": "Tick damage a cap clips burns the target's linh lực.", "second_home": "any poison build"}
  ],
  "questions": ["A question this build raises for the user, if any."]
}
```

- `identity_id` is the exact value to pass to `--without`: a plug-in name, a `conditional_mods` id, an art id
  or a top-level key. It must be the real identity piece, not a stand-in. Use `null` if it is unmodelled.
- `type` is one of: `modifier`, `enabler`, `technique`, `art`, `ward`, `artifact`, `talisman`, `pill`,
  `formation`, `beast`, `acupoint`, `notable`, `keystone`, `cluster`, `dao`, `dao_branch`, `root`, `concept`.
- List every new piece. For a `modifier`, `form`, `layer` and `second_home` are required.

## Reuse comes first

Before designing, read `design/builds/overnight-2026-11-07/content-ledger.md` and
`design/builds/content-ledger.md`. If a piece there fits, use it by name and put it in `reused`, with no
near copy. Then read `design/builds/overnight-2026-11-07/critic/latest.md` if it exists: it says what is
overused and where to go next. **Do not repeat an identity, a form or an enabler the critic calls tired.**

Scope modifiers by tag, never by build, so another build could want them.

## Plain modifiers are the backbone

Tonight's first three waves made 161 modifiers and nearly all are exotic. A Path of Exile tree is mostly
ordinary stackable nodes with a few strange ones. The `acupoint` and `notable` types exist for these: plain,
tag-scoped, general, at catalogue sizes, needing a key at most, never a rule. Prefer an ordinary modifier
whenever one can do the job.

## Being creative without being wrong

- Start from a rule, not a theme word. `references/modifier-forge.md` has the prompts.
- The seed is a starting point. If you find a stronger idea, follow it and say so in the sheet.
- Use the whole game: heart demon, pill toxicity, lifespan, fortune, thần thức, purity, Đạo count, failed
  breakthroughs, slot order, ground, seasons of preparation.
- New Đạo, new roots and new concepts are welcome, within `references/system-roles.md`. A new root states its
  origin and requirement, its effects per purity point, and what it costs. Check `design/gdd/linh-can.md`
  rules 9 to 12 and the shape in `assets/data/character_elements.json`.
- A proposed Đạo must be a real tree: requirement, `theme_stats`, three named branches and a keystone, with
  the signature nodes written out. A proposed cluster states its theme, kind, seal, size and notables.

## Proving it

Use the real numbers. Run from the repo root:

`python design/builds/overnight-2026-11-07/_tools/fight_x.py design/builds/overnight-2026-11-07/sheets/[slug].fight.json --matrix`

`fight_x.py` is the committed calculator plus this campaign's plug-ins, with the same arguments. Use it, not
`fight_calc.py`.

- Put only channel-wide sources in `layers`, and tag-scoped modifiers in the `x` of the art or status.
- Run `--without "[identity_id]"` and confirm the fight changes. **If it does not change, the build is not
  finished: fix it.** Then test at a second realm, and against a shaped enemy with `enemy_overrides`.
- Look for the surprise. In the pilots, the calculator showed the plan was wrong and the real engine was
  elsewhere. When numbers disagree with the theme, believe the numbers and redesign.
- **A rule-bender the calculator cannot express gets a plug-in, not a stand-in.** Write
  `rules/[rule_name].py` with an `install(f)` that wraps a calculator function, and list it under
  `"rules": ["rule_name"]` in the fight file. Copy `rules/_example_ward_return.py`. Check `rules/` first: reuse
  a plug-in that fits, by adding to the file only if it stays backward compatible. Act only for a side whose
  spec asks for it, because the enemy runs through the same functions. Keep it small and true to the rule as
  the sheet states it. `--without rule_name` skips the plug-in, so it works for the identity test.
- Only what truly cannot be simulated goes in `unmodelled`, such as costs outside the fight. If that is the
  engine, the fight check is `NOT ASSESSED`, which is an acceptable, honest result. Do not claim a `PASS`.
- A top-end enemy kills almost anything at t = 1. Losing to it is normal, not a failure. Do not chase it.
- **The fixture enemies bankrupt themselves,** spending 15 % of their pool a second, so a win against
  `typical` is weak evidence. Judge the build against the mixed enemy: copy the `arts` from
  `_tools/mixed-enemy.json` into `enemy_overrides` and save it as `variants/[slug]-mixed.fight.json`. The merge
  also runs this for every build and shows it in the index, so an overstated sheet will be visible.
- Never report a number you did not get from a run or a source file.

Macro balance matters, individual outliers do not. Do not shave a strong build.

## Writing

- English first, with Hán-Việt in brackets: `sect (tông môn)`. Use real, sensible Hán-Việt.
- Nothing from existing works: no names, characters, places, sects or signature items from any novel or
  game, including Phàm Nhân Tu Tiên and Path of Exile. Borrowing a structure is fine.
- Tone: a long, patient cultivation novel: mortal struggle, slow power, cold choices, real cost.
- Use they/them for people unless the story has set otherwise.
- Keep sheets tight. Skip template sections the build does not use. Keep the Legend to two short paragraphs.
- Numbers on new content are first guesses, and the sheet says so.
- The status line says: `Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user.`

## Your final report

Reply in under 80 words per build: slug, what surprised you, and the check results. Do not paste the sheet.
If you could not finish a build, say exactly why. A build you could not finish is more useful reported than
hidden.
