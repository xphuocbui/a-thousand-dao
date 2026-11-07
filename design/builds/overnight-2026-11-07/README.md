# Overnight Build Campaign: Start Here

> **To be re-evaluated and filtered (user decision 2026-11-07).** This campaign went builds-first. Its builds and content are not adopted: they will be filtered against the Modifier System, the redesigned Meridian Map and the Đạo catalogue once those exist, and reused as test cases. Its Đạo trees are not adopted. The rule findings in `decisions.md` stand on their own. See `design/gdd/systems-index.md`, "Build design order".
>
> **Status**: Proposals only. Nothing here is implemented or in game data, and no GDD, registry, catalogue or data file was changed by this campaign. Not committed.
> **Last updated**: 2026-11-07 morning, after the campaign ended. 69 builds. Counts: see `index.md`.

## Read these, in this order

1. **`decisions.md` (10 minutes):** the 12 rulings that matter, 19 faults in existing GDDs, and quick yeses. If you read one file, read this.
2. **`wheel.md`:** every plain modifier path on one Meridian Map, with the five element borders. This is the page for your tree rework.
3. **`index.md`:** every build on one line, with its pitch. **`panel.md`:** each build against five kinds of enemy.
4. **Builds to read first**, below.
5. **`content-ledger.md`:** every new piece by type. **`daos/`:** full Đạo trees. **`critic/`:** independent reviews, blunt ones.

## The big findings

**Your modifier idea works, and it has a shape.** The first three waves produced only exotic signature pieces, so the campaign turned to what you asked for first: ordinary stackable modifiers. There are now about 400 plain acupoint and notable rows across twelve paths, with no rule changes needed. Remove any single row and the fight barely moves; remove five and it is usually lost. That is the stacking you described.

**The plain paths are strongest across their borders.** The five element paths already meet at natural borders on your map, each with its own theme: Wood and Fire is stacks and ticks, Fire and Earth is heavy arts, Earth and Metal is gear, Metal and Water is crit, Water and Wood is income. Crossing two paths at a border took builds from winning 1 or 2 of 5 enemy types to 4 or 5, with plain rows only.

**Plain rows are not too weak. The exotic pieces are underpriced.** At equal W, plain lines win 5 of 5 on three of four builds, while Already-Waited's priced pieces alone win 0 of 5. See `plain-vs-exotic.md`.

**One cheap art is the strongest kit, but only on the common ward.** The cheapest short art filling every slot (cost 0.04, 0.5 s) beat every slow kit and even an enemy built to punish it. But plain builds with slow arts beat it at equal W once a per-hit or per-pulse ward exists, in a real cycle (`kit-hunt.md`). On the common ward with cooldowns of 1 s or more, 0 of 8,000 random lines beat it. So **the ward spell catalogue, Combat Open Question 18, may be the most valuable thing to design next**, and `kit-options.md` recommends leaving the art lint alone until then.

**Pillar 3 holds.** The three most dangerous builds each die to plain pieces at their own realm, and each hunter beats only its own target: Third Tug, Dug Stone and The Proctor.

## Builds to read first

| Build | Why |
|---|---|
| [The Best Plan](sheets/best-plan.md) | The careful coward, the heart of this genre. Flees everything, and it is funny |
| [The Herd Child](sheets/herd-child.md) | The family plough buffalo outranks you and stands over you when you fall |
| [Already Waited](sheets/already-waited.md) | The critics' best idea: heart demon pays cooldowns, at the cost of seasons |
| [Forum Build](sheets/forum-build.md) | The exploit a player would post, and the one-sentence rule that answers it |
| [The Ant General](sheets/ant-general.md) | Mediocre alone, terrifying with an army, and it exposed a hole in Formulas K |
| [Drink the Lightning](sheets/drink-the-lightning.md) | Built only for Heavenly Tribulation, with a reusable `rules/tribulation.py` for your boss work |
| [The Transplant](sheets/the-transplant.md) | A root cut from a corpse that must be fed donors. The best linh căn of the night |
| [Thirteenth Summer](sheets/thirteenth-summer.md) | Awake one year in thirteen |
| [The Mortal](sheets/the-mortal.md) | Survives a top-end because the top-end's own blow ruins it, then dies to an elder |
| [Under the Eaves](sheets/under-the-eaves.md) | Seven 4-second lamps that beat the cheap kit: proof that slow can win |
| [Daily Lesson](sheets/daily-lesson.md) | The clearest Plain Stack, and the best pair of rival lines |
| [The Banked Well](sheets/banked-well.md) | The best border hybrid, on the two elements that fight |

## Rule discoveries

All of these are in `decisions.md` with answers to choose from. None was acted on.

- The art lint reads a record, not what runs: a wait or a duration can be deleted. Forum Build, Held Door and Thirteenth Summer found it separately.
- Nothing without a hit is priced: masks, curses, escapes, talismans, ward models.
- Mass-battle reserves have no ceiling: 2,000 Qi Refining beat a sect.
- Soul defence is a cliff priced at almost nothing, and the anchors spend none on it.
- Nothing defines what happens after Down.
- Regeneration above upkeep makes a ward permanent, and a per-hit ward may beat the drain ward in any long fight.
- Crit at catalogue size is a trap row by row, and pays only when bought as a whole border.
- Two wards at once expose six gaps in rule 22, including that ward order is undefined.
- `fight_unit` is the one uncapped number in Combat.

## Honest limits

- **Paper model, not the game.** `fight_calc.py` passes the Combat GDD's fixtures, but chance is an expected value, and plug-ins in `rules/` model proposals, not rules.
- **Most Budgets checks are NOT ASSESSED,** because sheets rarely total thần thức and most combat modifiers have no price. Sizes on new content are first guesses.
- **The reference enemies are limited.** `typical` and `top_end` bankrupt themselves, so read `panel.md` and treat wins against `typical` alone as weak evidence. The panel enemies are campaign tools, not Combat fixtures.
- **Some hybrid results lean on a ward.** Several plain wins depend on Stone Ward, Vinegar Cloth or Standing Verdict, which are overnight records. Sheets say how much.
- **Keystone evidence is thin.** Two of seven two-keystone trees were tested in a fight: one real choice, one half real.
- **Critics spot-checked, they did not re-run everything.** About 110 quoted numbers were re-run over three reviews with no mismatch. Results that did not reproduce earlier in the night were removed.
- **Not every sheet got the later rules.** Waves 1 and 2 were repaired, but a sheet may still lean on a reference enemy.

## How the night went

- **Interrupted twice.** A usage limit stopped all agents from about 03:50 to 04:50, and again from about 07:46 until the end, so about 3 hours of work were lost. The last critic review never ran.
- **The last three builds are unchecked.** `indigo-drop`, `welcome-bath` and `empty-river` were written just before the second stop. No critic has read them, and they may be incomplete. They are in `index.md` and `panel.md`.
- **Brief breaches, all small.** Several agents ran a read-only `git status`, two triggered the merge tool by accident, and several deleted their own stale scratch or variant files, against the brief. One left a stray file at the repo root and removed it. No other agent's work and nothing outside this folder was affected.
- **`design/builds/` was silently ignored by git.** A `builds/` rule in `.gitignore` caught it. Fixed in commit `cab4082`, which also holds the skill upgrade. Tonight's output itself is not committed: that is your call.
- **Your uncommitted GDD edits were not touched.**

## Reproducing a number

`python design/builds/overnight-2026-11-07/_tools/fight_x.py design/builds/overnight-2026-11-07/sheets/[slug].fight.json --matrix`

Add `--without [piece]` for an identity test. `_tools/panel.py` rebuilds `panel.md`, and `_tools/merge.py` rebuilds `index.md` and `content-ledger.md`. `scratch/` can be deleted.
