# Brief: sect writer (world-depth pass)

You are writing one sect of a fixed cultivation (tu tiên) world, for a game whose world must feel connected: the land
shapes its people, a sect's people fit its teaching, and every person is tied to others and to the history. The user
said the current world is "not connected, not deep, not well defined" and asked for nicely written content at scale.

## Read first (in this order)

1. `design/world/depth/rules-proposals.md` (R1-R8: the rules you write against). Read it whole.
2. `design/world/depth/schema.md` (file formats). Read it whole.
3. `design/world/depth/traits-v2.md` and `design/world/depth/traits-v2.json` (trait ids), and the v1 trait names:
   personality (Brave, Cautious, Calm, Wrathful, Content, Ambitious, Diligent, Lazy, Forgiving, Vengeful, Generous,
   Greedy, Gregarious, Reclusive, Honest, Deceitful, Humble, Arrogant, Just, Arbitrary, Patient, Impatient, Temperate,
   Indulgent, Trusting, Paranoid, Devout, Pragmatic, Stubborn, Fickle, Compassionate, Callous, Cruel, Warlike,
   Peaceable, Loyal, Faithless); callings (Strategist, Steward, Diplomat, Merchant, Teacher, Schemer, Alchemist,
   Refiner, Formation master, Talisman maker, Beast tamer, Herbalist, Duelist, Wanderer); fate (Heaven-favoured,
   Ill-starred, Wise-born, Dull-witted, Iron-boned, Frail, Spirit-eyed, Hollow-souled, Pure-hearted, Demon-seeded);
   gained (Scarred, Battle-hardened, Shaken, Renowned, Disgraced, Humbled, Embittered, Grudge, Lovestruck, Grieving,
   Sworn sibling, Life-debt, Hunted, Enlightened, Oath-bound, Demon-tainted).
4. **The pilot, as your quality bar**: `design/world/depth/sects/bang_tam.md`, `bang_tam.cast.json`,
   `bang_tam.techniques.json`, `bang_tam.items.json`. Match its depth and its voice: concrete, specific, restrained,
   every person wanting something and tied to someone, history cited by event id.
5. Your inputs: `design/world/depth/_inputs/<key>.json` (your sect's record, land, seat audit, events, territory
   history, existing cast with builds, legendary items) and `design/world/depth/_inputs/world.json` (eras, every
   sect, wars, grudges, the loose cast). These are compact JSON with one item per line; read them in parts with
   offset/limit if large.
6. Techniques that exist: `design/techniques/catalogue-*.json` (ids, tier 0-3, kind, element names, abilities).
   Items that exist: `design/items/catalogue-*.json` (look at your element's family for modifier sizes) and
   `design/items/bases.json` (base ids). Arts: `design/arts/family-*.json`.

## Write (only these paths; nothing else in the repo)

- `design/world/depth/sects/<key>.md`: the sect page, the 12 sections of `schema.md`, in the pilot's style.
- `design/world/depth/sects/<key>.techniques.json`: its lineage (R5) and proposed techniques. Reuse catalogue
  techniques where they fit, and propose new ones where they don't. A great sect's main method is Earth or Heaven tier.
- `design/world/depth/sects/<key>.cast.json`, and if large `<key>.2.cast.json`, `<key>.3.cast.json`: its people.
  Write in batches of about 12-15 people per write so no single write is huge.
- `design/world/depth/sects/<key>.items.json`: signature items for tier A people (heads 2-4, elders 1-3) and 1-2 sets.

Do **not** edit any other file: not the pilot, not `README.md`, not the rules, not game data, not GDDs. If you think
a rule is wrong, say so in your final report. Do not commit. Do not run Godot.

## What to decide and write

1. **Seat (R4).** Read your seat audit. If the seat fails, choose: move (great sects: to a candidate in your own
   ground), or for a minor sect move or re-lean. Write the story of why the sect is where it is, what the move costs,
   what the old seat becomes. If no candidate fits, re-lean or make the case for a move next door. Use place ids.
2. **Doctrine and customs.** Make the sect a culture, not a stat block: what it believes, how it dresses, eats,
   buries its dead, what it forbids, how it treats outsiders. Derive it from its element, its land and its history.
3. **Lineage (R5)** whose elements match its leans. Admission (R2): its outer gate takes the lineage's base elements
   (purity ≥ 30); inner disciples (nội môn) and above hold the main method's element (≥ 45), or the variant for a
   variant lineage. Exceptions only with an `exception` reason (guest elders `khach_khanh`, servants `tap_dich`,
   hostages, a root changed after joining).
4. **Cast.** Keep every existing cast member's key, name, birth year, realm, sect and rank, and deepen them. Add
   new people to your quota (`design/world/depth/quotas.json`; it counts living people by realm and includes the
   existing cast). Great sect target: about 65-75 living people, 3-4 Nguyên Anh, up to 12 Kết Đan, about 30 Trúc
   Cơ, about 25 Luyện Khí. Also 4-10 dead lineage figures (founders, fallen heroes, the dead of its wars) to give
   the living roots. Tiers (R8): about 10 tier A, 20 tier B, the rest tier C. Use the right word counts.
5. **Roots follow the land (R1).** Give each person a `birthplace` (place id). Most members are born on the sect's own
   ground, so their roots look like it. Desert-born, coast-born and city-born people differ, and the backstory should show it.
6. **Ties.** Every person has at least one tie. Masters must be older and of a higher realm, in the same sect.
   Build master-disciple lines, families (parents, siblings, Dao partners), rivalries, factions and debts **inside**
   the sect. Ties to people outside your file may point **only to keys that already exist** in
   `assets/data/world_history.json` (the inputs list them) or in `bang_tam.cast.json`. Note other cross-sect wishes
   in your report.
7. **Builds.** Per `schema.md`: archetype; main technique from the lineage by rank (outer method, inner method, elder
   method); aux secret arts by rank; gear `1 + realm index` pieces (max 3), each `{base, grade 1-4, element}` or
   `{named: id}`; tree `{start, intent}` (never invent Đạo Đồ node ids); craft skills (`dan_dao`, `tran_phap`,
   `linh_thuc`, `phu_luc`, `luyen_khi`) 1-9.
8. **Items.** Follow `design/items` schema, with modifier keys and sizes like the catalogue's (grade 3-4 for
   elders and heads). Effects are short hand-written rules. Item ids are prefixed with your sect key's initials and
   a hyphen, e.g. `tv-` for thuy_vi.
9. **Story hooks**: 6-12, each naming people and places.

## Names and style

- Names are Hán-Việt with correct Hán characters (`name_han`) and a gloss. They must be original: never a character
  from an existing novel, drama or game. Vary surnames, and avoid names already in the world (the checker flags
  duplicates).
- Write in English. Annotate cultivation terms with the Hán-Việt in parentheses the first time, e.g. sect (tông môn),
  then use either. Keep sect and Way names in Hán-Việt.
- Plain, concrete prose. A person is what they want, what they fear, what they did, and who they are tied to.
  Avoid filler words ("ancient", "mysterious", "legendary") unless they carry a fact. Avoid stock phrasing, and
  make each person different. Tier C is a sentence or two, and still specific.
- Ground everything in the inputs: cite event ids (`C012`, `A143`, `V061`), places by id, people by key. You may
  invent new history events as `N-<key>-01`... in the page, with year, kind and text, but they must not contradict
  the existing chronicle.

## Check, then report

Run `python -I tools/design/world/depth_check.py` and fix every finding in your files (findings in other sects' files
are not yours). Run it again until your files are clean. Then reply with a short report (under 300 words):
counts by tier and realm, the seat decision, the lineage, any no-lean decision, cross-sect ties you'd like the
cross-sect pass to add (with keys), rule problems you hit, and anything you could not finish.
