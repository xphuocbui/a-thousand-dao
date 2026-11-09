# Thoughts: technique and item trees in their own tab

Status: **thoughts only** (user, 2026-11-09: "Let's just put that into thoughts for now"). The user's statements and
answers below are decisions; the rest is proposal. No GDD or drawing has been changed for it.

## What the user said (2026-11-09)

1. **Scrap the hidden clusters idea.** The sealed and open clusters on the Meridian Map (Kinh Mạch Đồ), unsealed by an
   event, an item or a cultivation technique (công pháp), are dropped.
2. **Công pháp and items have their own skill trees**, each an island that does not connect to the Meridian Map. There
   may be hundreds of them in the future, so they can't all sit on the map. The idea is a PoE ascendancy-like feature:
   another tab or window.

The element islands on the map (Light, Darkness, Thunder) are not affected: they are part of the main tree.

### Answers to the first questions (same day)

| Question | User's answer |
|---|---|
| Which công pháp and items get a tree? | **Every công pháp; some items.** |
| Which points feed the trees, and is there a cap? | **The same skill points as the Meridian Map. Nodes in a tree can take several upgrades (ranks). No cap on how many trees a character works.** |
| Do the capabilities move into these trees? | "If they are skills, yes." They are not (see below). Follow-up: **a công pháp tree or an item tree can hold capabilities.** |
| What happens to the LLM-written story-moment content? | **It becomes its own tree island too**, in the same tab. |

**Capabilities are not skills.** The 25 capabilities (thần thông, kinh-mach-do.md rules 16–17) are passive rule
changes, such as +1 magic treasure slot, brewing two recipes in a season, or rerolling a failed event check. None is an
action the character uses, so by the user's rule they stay out of the side trees. The earlier decision already gives
them a home on the main map: slot raises become keystones with a real closing cost, and closeless ones become major
Effects. Several fit a technique or item tree by theme (Twin Technique Cultivation, Divided Furnace Flame, the beast
pair). **User, follow-up: a công pháp or item tree can hold capabilities.** So a capability lives on the main map or
in a side tree, whichever fits its theme; which one each of the 25 goes to is still to sort.

## Reference: PoE ascendancy (from memory, not checked)

- A small separate tree (about 30 nodes, of which a character can take 8) for the subclass chosen within the class.
- Its points come from separate trials, not from levelling.
- It opens from the main passive tree window, through the class's start in the centre.
- One per character. Ours differs: many trees per character, all on the shared skill points.

## The shape so far

- **One tab, many trees.** The tab lists the trees the character has: every công pháp they cultivate, items with a
  tree, and each story-moment island. Hundreds exist in the world; a switcher picks which tree fills the window.
- **Shared points, ranked nodes.** Every point spent in a side tree is a point not spent on the Meridian Map, so the
  tab is a real choice, not free power. A node can take several points, each rank stronger.
- **Small and templated** (proposal). Ascendancy-sized, about 10–30 nodes. A few hand-drawn skeletons, each reused by
  many công pháp with their own content, keep hundreds affordable to author.
- **A door on the main map** (proposal). The start (or the hub) shows the main công pháp's emblem and opens the tab,
  as PoE's centre does.
- **Story-moment islands.** The LLM writes a small tree at the story moment, inside the budget the open clusters had
  (rules 10–11), and it joins the tab.

## The main map is a placeholder (user, 2026-11-09)

"The main map should just be a placeholder for now, there will be a point where we fill in the
modifiers/capabilities/keystones/notable nodes." The drawn Meridian Map is layout only: every notable name, keystone
(including the 40 drawn, all marked [proposal]), modifier and capability on it is a stand-in. Content is filled in one
later pass, after the modifier library exists. So sorting the capabilities between the main map and the side trees
waits for that pass.

## Consequences to work through

- **Budget.** With no cap on trees and shared points, the main map's coverage (5.7 % of the lean tree by the end of
  Nascent Soul) falls as players spend in the tab. The point totals per realm, or the main map's size, need a second
  look once the side trees have a size.
- **Ranks.** The modifier pricing (W) has no notion of ranks yet; a ranked node's price per rank needs a formula.
- **NPC builds** allocate across the main map and their side trees.

## What the hidden clusters carried, and where it goes

| Hidden clusters did this | Becomes |
|---|---|
| Capabilities (thần thông), rules 16–17, 25 entries | Main-map keystones and major Effects, or nodes in a công pháp or item tree, by theme |
| Sealed clusters opened by a công pháp (`seal_clusters` in cong-phap.md, rule 15's interim sector rule) | The công pháp's own tree |
| The Meridian Seal (Mạch Ấn) item opening the nearest sealed cluster | Dropped, or repurposed |
| Open clusters written by the LLM at a story moment (rules 10–11) | A story-moment tree island in the tab |
| NPCs unsealing clusters at generation (rule 14) | NPCs get the trees of the công pháp and items they hold |
| About 525 acupoints in the GDD budget (about 690 in the drawing) | Removed from the main map |
| "Cluster unsealed" events in the World Database | Tree events (a story island written, a tree completed), or dropped |

## Not done yet

- **Drawing.** The rim band of hidden clusters is still in `tools/design/meridian_rework/` (`landkit.halo`, the
  inner hidden clusters, `HALO_EXTRA`) and the published tree. Removing it frees the rim for visible clusters.
- **GDDs.** Rewriting kinh-mach-do.md (rules 6–17, Formulas H, the state table, budgets), cong-phap.md
  (`seal_clusters`, rule 15), item-database.md (Mạch Ấn) and NPC Builds is the user's call, section by section. The side
  trees likely need their own GDD.
- **Code.** The debug terminal builds hidden clusters (`src/gameplay/meridian/`).

## Open questions

1. (For the content pass.) Which of the 25 capabilities go to the main map and which to side trees? Can one capability appear in several
   side trees (for example, Divided Furnace Flame in every alchemy công pháp)?
2. Do the main công pháp's tree and a secondary one's differ (size, speed, or which nodes open)?
3. Which items get a tree: by grade, by kind (magic treasures only), or hand-picked?
4. Does a side tree's progress stay when the công pháp is dropped or the item is lost?
