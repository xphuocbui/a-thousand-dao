# How PoE-style passive trees are designed (web research, 2026-11-18)

**Why this note exists:** the user said the Đạo Đồ work feels "so far from the truth... sloppy and soulless". So far we have measured PoE's finished tree: orbit radii, angles, cluster sizes, how often small shapes repeat. Those numbers describe what GGG produced, not how they produced it. This note collects what is public about how such trees are designed.

**Bottom line:** GGG has never published a step-by-step method. Every source that touches on it points the same way: **the meaning comes first and the drawing comes last.** Each area means something, each cluster is one named idea, and the notables can be read as a map of builds. The layout is then arranged by hand to fit.

## 1. What the sources say

### Chris Wilson, PoE's lead designer (Marooners' Rock interview, 2012)

- The tree is "kind of a fingerprint of the DNA of the character" (part 3).
- It was built around the three attributes. "A lot of the systems are designed around these three" (part 1). The classes start in each attribute's area.
- They first studied other games' trees, and their first decision was to "pull out all of the active skills into a separate system" (part 3).
- Parameters they tried "so many different variations" of: whether a node takes one point or several, whether the tree is a maze or "more linear", and whether related nodes are grouped together or scattered (part 3).
- Goal: players explore it "without them needing to sit down with a pencil and paper to work out their entire build" (part 3).
- Notables were added later, about 100 of them, each with its own name and art. Their purpose was "a high level overview of the tree so they can see which notables they're interested in" (part 1).
- Keystones are "the ones [that] dramatically change how you play your character" (part 1).
- The layout was done by hand. Adding the attribute highways "did cause us to have to redo most of the tree": "about 15-20 man days of just laying out and arranging the icons". It was followed by "a ton of tweaks to make sure that it's relatively fair for all the different classes" (part 3).

### GGG, 3.11.0 patch notes (2020), as quoted on the PoE wiki

- The rework aimed to give **each cluster its own identity and function**. It also moved some build-defining keystones out of Timeless Jewels and onto the tree.
- Not verified at the source: the official forum thread and both wiki copies blocked automated access.

### Last Epoch developers ("Passive Skill Systems" dev blog, 2018)

- "Interesting decisions come from restrictions."
- They avoided plain "+10% damage" nodes. With about 16-17 points at end game, each node must be "impactful and build shaping".
- Putting attributes into nodes made "each node either boring or too busy".
- Each area between two neighbouring axes is themed around the playstyle that blends them. This is the same idea as PoE's areas between classes.
- The grid in that post was later dropped, so treat it as a statement of principles, not a finished system.

### Player guides (secondary, opinion)

- The tree is a routing problem. Notables are what make the trip worth it, travel nodes are what it costs, and a long road can pay off if its travel nodes give attributes or reach a jewel socket.
- The route a player takes becomes part of the build's identity.

## 2. The method these sources imply

1. **Each area means something because of its neighbours.** A region's theme comes from what is on either side of it: classes and attributes in PoE, axes in Last Epoch.
2. **Each cluster is one named idea.** It has its own identity and function, and its notable carries the name and the art.
3. **The notables read as a map.** A player can plan a build from the notable names alone, without pencil and paper.
4. **Distance is a cost.** A notable further away must be worth the walk. Travel nodes are the price of the trip.
5. **Restriction makes the decision.** Each point is limited, so each node must shape the build.
6. **The layout is arranged by hand,** icon by icon, after the content. A structural change, such as the highways, means hand-redoing most of the tree.

## 3. Compared with what we did

| PoE / Last Epoch | Đạo Đồ so far |
|---|---|
| Meaning first, shape last | Shape library first, meaning "later" (`design/dao-do/rules-2026-11-18.md` §2) |
| Each cluster has its own identity and function | "Shapes were drawn empty. Nothing tied a shape to what it grants" (rules §2.4) |
| Notables are an overview of builds | Notables are placed as geometry, with no names checked |
| Judged by whether you can plan a build from it | Judged by density, interlock and variety against PoE statistics |
| Placed by hand | Placed by hand, matching rule 3.1 |

The geometry rules that PoE 2 follows (rules §3.2) can stay as checks. They were never what makes PoE feel alive.

## 4. A test for any land (proposed)

**The notable-names test:** hide everything except the notable names, with the Dao Seals (keystones) included. If a reader cannot tell which builds the land supports from those names alone, the land has no soul yet, however good its geometry is.

**Proposed next step (not yet approved):** take one small patch of one land, about one 18-unit window, and design it from the inside out:

1. Write what the patch is about: what it grants, which build wants it, and what choice the player makes (take it, or skip it to save points).
2. Only then draw the shape that expresses that, by hand.
3. Judge it with one question: can you tell what this patch is for just by looking at it?

## 5. Gaps

- No source explains how GGG chose any particular cluster's shape. That part seems to be designer craft that was never written down.
- Blocked to automated fetch (worth opening in a browser):
  - the official 3.11.0 patch notes: pathofexile.com forum thread 2866606, and the wiki copies
  - the Jonathan Rogers interview on PoE 2 tree balance (Sportskeeda)
  - the Chris Wilson interviews on PC Invasion / Prima Games
- Not found: any GDC talk on passive-tree or skill-web design, or any Grim Dawn developer post on how its constellations were designed.

## Sources

- [Marooners' Rock: Chris Wilson interview, part 1 of 3](https://maroonersrock.com/2012/02/interview-chris-wilson-path-of-exile-part-1-of-3/)
- [Marooners' Rock: Chris Wilson interview, part 3 of 3](https://maroonersrock.com/2012/02/interview-chris-wilson-path-of-exile-part-3-of-3/)
- [Last Epoch dev blog: Passive Skill Systems](https://forum.lastepoch.com/t/passive-skill-systems/1270)
- [PoE Wiki (Fandom): Passive skill, which quotes the 3.11 patch note](https://pathofexile.fandom.com/wiki/Passive_skill)
- [expcarry: PoE passive tree guide (routing view)](https://expcarry.com/path-of-exile-passive-skill-tree-guide)
- [miguelballesteros.com: the route as build identity](https://miguelballesteros.com/how-path-of-exiles-passive-skill-tree-helps-you-create-the-most-unique-builds-in-the-arpg-genre/)
