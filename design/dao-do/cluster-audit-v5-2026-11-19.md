# Đạo Đồ: cluster audit of the frozen v5 graph (2026-11-19)

**Why:** before the approved big-cluster ideas (`big-clusters-draft-2026-11-18.md`, 80 ideas, all 25 capabilities)
are bound onto the drawn graph, count what v5 actually has, land by land (user, 2026-11-19: "first record the
auditing"). The 11-18 pictures were never drawn; an idea only has to fit its land, a matching picture is a bonus
(user, 2026-11-19).

**Source:** `cells/versions/v5-frozen-2026-11-19/dao-do-map.json` (8,038 nodes, 867 pieces). Script:
`tools/design/dao_do_rework/cells/audit_clusters.py <map> [--list]` (observations only).

**How it counts**
- Tiers as in `rules-2026-11-18.md` 3.3: small 1-5 nodes, medium 6-8, big 9+ (small and notable nodes of a piece;
  roads, starts and keystones are not in clusters).
- **Distinct** counts a mirrored pair once: the same picture at the same size, reflected across the land's axis
  through its start node, or the two halves of one cell's figure (Fire's c3 wings). The hub swirl's arms and the
  start motifs are never paired.
- **Band** by the piece's centroid radius: inner < 50, middle 50-69, rim >= 69 (the 11-18 draft's bands).
- Unnamed pieces are the base map's start and emblem figures; they are left out of the big-picture lists.
- Lands: islands by cell (931 Light, 932 Thunder, 933 Darkness with the Shadow Shrine); the purple Chaos motifs in
  cells 1-5 are listed as each land's **start motif**; cell 79 is the hub swirl.

## Summary

| Area | Clusters (S/M/B) | Distinct (S/M/B) | Big by band (inner/middle/rim) | Notables (all / in big) | Big pictures | Ideas approved | Gap |
|---|---|---|---|---|---|---|---|
| Fire | 153 (82/43/28) | 67/34/20 | 10/5/5 | 267 / 96 | **19** | 12 | 7 |
| Earth | 138 (72/34/32) | 61/28/24 | 8/7/9 | 230 / 91 | **23** | 12 | 11 |
| Metal | 145 (69/47/29) | 59/35/20 | 6/8/6 | 277 / 105 | **19** | 12 | 7 |
| Water | 129 (63/42/24) | 57/34/23 | 8/7/8 | 247 / 96 | **21** | 13 | 8 |
| Wood | 155 (80/43/32) | 63/36/24 | 8/12/4 | 297 / 116 | **23** | 12 | 11 |
| Light island (Sun, Fusang tree) | 30 (4/3/23) | 2/2/12 | – | 91 / 84 | **11** | 4 | 7 |
| Thunder island | 40 (9/11/20) | 7/9/20 | – | 95 / 62 | **19** | 4 | 15 |
| Darkness island + Shadow Shrine | 20 (2/10/8) | 1/5/6 | – | 91 / 79 | **5** | 5 + 2 | −2 |
| Hub swirl (cell 79) | 10 arms | – | – | 25 / 25 | **10 arms, 1 picture** | 4 (H1-H4) | 6 |
| Start motifs (cells 1-5) | 19 | – | – | 102 / 100 | **18** | 0 | 18 |
| **All** | | | | | **168** | **80** | **≈88** |

Counts in the "Big by band" column include the unnamed start figures (one or two per land); "Big pictures" does not.
Keystones: 4 per land (cells 901-905), 2 on Light, 1 on Thunder, 1 on Darkness: 24.

## Findings

1. **About twice as many big pictures as approved ideas: 168 against 80.** The draft sized itself on PoE 2's share
   (about 80 of about 570 clusters); the drawn tree has more and bigger figures, plus the start motifs and the hub
   swirl, which were drawn after the draft.
2. **The gap is uneven.** Thunder (19 pictures, 4 ideas), Earth and Wood (23 for 12 each) and the start motifs
   (18, none planned) are short. Darkness with the Shrine has more ideas than pictures, but its two pieces are huge.
3. **Fire is crowded at the centre:** 10 of its 20 big pieces are inner, while the draft puts most Fire ideas in the
   middle or rim. Wood is crowded in the middle (12 of 24).
4. **Some single pieces are very large** and could hold more than one idea: the Shrine's eclipse (141 nodes, 35
   notables) and the Moon's lotus (121, 25); Thunder's upper cloud (56); the start motifs (Wood vines 71 and 61,
   Water waves 68, Fire flames 62, Metal blades 53); the Fusang tree branches (36-46 a side); Water's rim snowflakes
   (32-41).
5. **Capabilities without a home:** the hub's #6 Twin Technique Cultivation, #14 Portable Cave Abode and
   #24 Mutation Awakening were planned on hub pictures (Twin Rings, Cave Gate, Sixth Point); the hub is now the
   swirl. The other 22 capabilities' lands still exist.
6. **Notables:** 1,759 in all, about 1,020 of them in big pictures. The GDD's value scale (Formulas A2) assumes
   1,084 notables in all; at v5's counts its mean is 2.60 W against the 2.07 W target (decision pending, separate
   from this audit).
7. **Medium clusters** number 28-36 distinct per land; as decided (rules 6.5) they get plain modifiers later.

## Options to close the gap

**Decided 2026-11-19 (user): A, more ideas.** Every big picture gets its own idea: the 80 approved ideas are bound
onto v5's pictures and about 88 new ideas are written for the rest, land by land. The user
approves the process (`content-method.md`) and reviews the content once the whole tree is filled (user, 2026-11-19).

| Option | What it means | Pros | Cons |
|---|---|---|---|
| **A. More ideas** | About 88 new ideas, one per big picture | Every big picture is a build concept: the most variety (`builds-are-the-game`). One simple rule: one picture, one idea | 88 concepts to design and approve, more than the whole approved list. Risk of thin or repeated ideas ("more X damage"). Each idea gets one cluster, so builds are shallow and spread out. Harder to hold the value and power targets |
| **B. Keep 80, rest plain** | The 80 ideas go on 80 pictures; the other ~88 carry the land's ordinary modifiers | Fastest. The approved list is kept as it is. Plain big clusters are normal in PoE | About half the big pictures promise something and give plain stats, including the eye-catchers (Thunder's clouds, the start motifs every player sees first). Thunder and Light feel empty (4 ideas each over 19 and 11 pictures) |
| **C. Districts + a few new ideas** | An idea may cover 2-3 neighbouring big clusters (e.g. Fire's Furnace and Strange Pill over cells 28 and 29); huge pieces take 2 ideas; 3-6 new ideas per short area; the rest plain | Deeper ideas: a build has enough notables in one place to commit to. Far fewer new concepts (about 20-30). The approved list is kept | The player must see which clusters belong to one idea (shared name, colour). An idea concentrated in one area concentrates power there, so bands need care. Some plain clusters remain |

The start motifs and the hub swirl need an answer under any option: the motifs could carry each start's own idea
(what choosing that start means), and the hub's three capabilities could go on the swirl or on the motifs.

## Big pictures per area (v5)

One row per distinct big picture (a mirrored pair is one row, marked "yes"). Radius is the centroid's distance from
the centre in map units.

### Fire (19)

| Cell | Picture | Nodes | Notables | Radius | Band | Pair |
|---|---|---|---|---|---|---|
| c3 | A_wing | 15 | 3 | 23.1 | inner | yes |
| c63 | corona | 13 | 4 | 36.5 | inner | yes |
| c63 | halo | 9 | 3 | 37.6 | inner | yes |
| c120 | comet | 10 | 2 | 39.1 | inner |  |
| c119 | flicker | 9 | 3 | 39.2 | inner |  |
| c18 | sun | 14 | 3 | 44.9 | inner | yes |
| c28 | spiral | 10 | 2 | 47.5 | inner | yes |
| c29 | wisp | 9 | 2 | 48.1 | inner |  |
| c28 | wisp | 10 | 2 | 48.2 | inner |  |
| c28 | sunrise | 11 | 3 | 51.2 | middle | yes |
| c92 | feather | 14 | 5 | 58.5 | middle |  |
| c49 | torch | 9 | 2 | 59.1 | middle |  |
| c47 | wing | 12 | 4 | 59.6 | middle |  |
| c49 | firework | 11 | 3 | 60.4 | middle |  |
| c105 | trident | 12 | 3 | 69.2 | rim |  |
| c101 | star | 10 | 3 | 69.3 | rim |  |
| c53 | fleur | 11 | 3 | 71.1 | rim |  |
| c901 | ding_R | 14 | 4 | 81.1 | rim | yes |
| c901 | trefoil_R | 28 | 8 | 81.6 | rim | yes |

### Earth (23)

| Cell | Picture | Nodes | Notables | Radius | Band | Pair |
|---|---|---|---|---|---|---|
| c66 | stairway | 10 | 2 | 37.2 | inner |  |
| c65 | hill | 13 | 3 | 37.4 | inner |  |
| c36 | terrace1 | 12 | 4 | 44.7 | inner |  |
| c23 | road | 15 | 3 | 46.2 | inner |  |
| c24 | road | 16 | 3 | 46.3 | inner |  |
| c36 | terrace2 | 10 | 1 | 46.9 | inner |  |
| c19 | ridge | 13 | 3 | 48.8 | inner |  |
| c36 | terrace3 | 12 | 4 | 50.6 | middle |  |
| c24 | peak_outer | 9 | 1 | 51.6 | middle | yes |
| c87 | stone | 10 | 2 | 58.5 | middle |  |
| c40 | keep | 9 | 3 | 59.4 | middle |  |
| c48 | keep | 11 | 3 | 59.6 | middle |  |
| c87 | tower | 11 | 2 | 60.0 | middle | yes |
| c78 | pyramid | 10 | 3 | 61.3 | middle | yes |
| c55 | quarry | 16 | 3 | 69.3 | rim |  |
| c51 | cave | 10 | 3 | 69.8 | rim |  |
| c8 | wall | 24 | 2 | 70.0 | rim |  |
| c902 | bell | 12 | 4 | 77.6 | rim |  |
| c902 | earth_seal_terrace_east | 11 | 2 | 78.0 | rim | yes |
| c902 | cong_R | 16 | 4 | 78.5 | rim | yes |
| c902 | ruyi_R | 11 | 3 | 79.1 | rim | yes |
| c902 | star_R | 20 | 5 | 79.8 | rim | yes |
| c902 | bronze_bell_storey_east | 12 | 2 | 81.8 | rim | yes |

### Metal (19)

| Cell | Picture | Nodes | Notables | Radius | Band | Pair |
|---|---|---|---|---|---|---|
| c27 | coin | 12 | 3 | 44.2 | inner |  |
| c30 | bell | 11 | 3 | 44.6 | inner | yes |
| c20 | coins | 9 | 2 | 45.4 | inner |  |
| c20 | bow | 9 | 3 | 45.6 | inner | yes |
| c30 | compass | 9 | 4 | 47.7 | inner |  |
| c34 | trident | 9 | 3 | 50.1 | middle |  |
| c20 | gong | 10 | 3 | 50.6 | middle |  |
| c41 | arcs | 10 | 4 | 56.3 | middle | yes |
| c77 | wheel | 11 | 3 | 56.7 | middle | yes |
| c41 | crown | 11 | 3 | 60.2 | middle |  |
| c77 | ding | 10 | 4 | 61.9 | middle | yes |
| c9 | rack | 10 | 4 | 67.3 | middle | yes |
| c10 | shield | 12 | 3 | 68.8 | middle |  |
| c58 | sawblade | 9 | 3 | 69.3 | rim | yes |
| c10 | hammer | 10 | 2 | 70.7 | rim |  |
| c9 | sword | 9 | 3 | 70.8 | rim | yes |
| c903 | pentagons R | 15 | 4 | 79.5 | rim | yes |
| c903 | linked rings | 29 | 7 | 79.6 | rim |  |
| c903 | weiqi board | 25 | 7 | 79.8 | rim |  |

### Water (21)

| Cell | Picture | Nodes | Notables | Radius | Band | Pair |
|---|---|---|---|---|---|---|
| c26 | raindrop | 15 | 3 | 45.0 | inner |  |
| c26 | waterwheel | 11 | 3 | 45.4 | inner |  |
| c32 | moon_halo | 10 | 3 | 46.0 | inner |  |
| c22 | wave_train | 15 | 4 | 46.8 | inner |  |
| c38 | lily_pad | 10 | 3 | 48.4 | inner |  |
| c32 | lotus | 9 | 3 | 49.3 | inner |  |
| c42 | seaweed | 9 | 2 | 59.1 | middle |  |
| c76 | braid | 10 | 3 | 60.1 | middle |  |
| c69 | pearl | 10 | 4 | 61.2 | middle |  |
| c54 | meeting_ripples | 12 | 4 | 67.2 | middle |  |
| c11 | pond | 12 | 3 | 67.5 | middle |  |
| c59 | endless | 10 | 3 | 67.9 | middle |  |
| c17 | turning_wave | 12 | 3 | 68.6 | middle |  |
| c11 | whirlpool | 13 | 2 | 69.4 | rim |  |
| c17 | meander | 10 | 3 | 70.5 | rim |  |
| c904 | armillary_L | 21 | 6 | 79.2 | rim | yes |
| c904 | oai_stellar_frost | 32 | 6 | 80.5 | rim |  |
| c904 | ice_flake | 35 | 6 | 82.3 | rim |  |
| c904 | bagua | 15 | 4 | 93.1 | rim |  |
| c904 | plate_flake | 41 | 6 | 93.6 | rim |  |
| c904 | lotus | 19 | 6 | 101.3 | rim |  |

### Wood (23)

| Cell | Picture | Nodes | Notables | Radius | Band | Pair |
|---|---|---|---|---|---|---|
| c67 | tendrils | 10 | 2 | 39.2 | inner | yes |
| c31 | fir | 9 | 4 | 44.1 | inner |  |
| c31 | pinecone | 9 | 3 | 45.3 | inner |  |
| c25 | morningglory | 14 | 3 | 48.8 | inner |  |
| c35 | wreath | 11 | 3 | 49.2 | inner |  |
| c31 | bamboo1 | 9 | 3 | 49.8 | inner |  |
| c21 | seed | 11 | 3 | 50.0 | inner |  |
| c31 | bamboo2 | 10 | 3 | 50.1 | middle |  |
| c31 | bamboo3 | 9 | 3 | 50.2 | middle |  |
| c44 | cloud | 9 | 2 | 55.6 | middle |  |
| c39 | youngfir | 10 | 1 | 56.6 | middle |  |
| c72 | vine | 11 | 4 | 58.1 | middle | yes |
| c44 | pinwheel | 11 | 3 | 60.4 | middle |  |
| c94 | tulip | 10 | 4 | 61.9 | middle | yes |
| c39 | bough | 10 | 2 | 62.1 | middle |  |
| c43 | streaks | 10 | 3 | 62.3 | middle |  |
| c13 | maple | 10 | 3 | 67.0 | middle | yes |
| c60 | rings | 12 | 3 | 67.3 | middle |  |
| c109 | frond | 11 | 4 | 69.0 | middle | yes |
| c13 | tree | 11 | 3 | 69.5 | rim | yes |
| c905 | lantern_e | 20 | 5 | 79.2 | rim | yes |
| c905 | star_e | 22 | 6 | 81.4 | rim | yes |
| c905 | holo | 28 | 7 | 101.3 | rim |  |

### Hub (10)

| Cell | Picture | Nodes | Notables | Radius | Band | Pair |
|---|---|---|---|---|---|---|
| c79 | swirl_arm_03 | 11 | 2 | 9.6 | - |  |
| c79 | swirl_arm_08 | 11 | 2 | 9.6 | - |  |
| c79 | swirl_arm_02 | 11 | 2 | 9.6 | - |  |
| c79 | swirl_arm_07 | 11 | 2 | 9.6 | - |  |
| c79 | swirl_arm_05 | 11 | 2 | 9.6 | - |  |
| c79 | swirl_arm_10 | 11 | 2 | 9.6 | - |  |
| c79 | swirl_arm_01 | 11 | 2 | 9.6 | - |  |
| c79 | swirl_arm_06 | 11 | 2 | 9.6 | - |  |
| c79 | swirl_arm_04 | 11 | 2 | 9.6 | - |  |
| c79 | swirl_arm_09 | 11 | 2 | 9.6 | - |  |

### Light (11)

| Cell | Picture | Nodes | Notables | Radius | Band | Pair |
|---|---|---|---|---|---|---|
| c931 | flames_144_r | 17 | 3 | 99.3 | - | yes |
| c931 | tree_A_r | 36 | 6 | 102.6 | - | yes |
| c931 | flames_126_r | 9 | 2 | 104.9 | - | yes |
| c931 | tree_B_r | 46 | 7 | 108.0 | - | yes |
| c931 | flames_108_r | 11 | 2 | 109.4 | - | yes |
| c931 | flames_090_r | 11 | 2 | 114.2 | - | yes |
| c931 | tree_CD_r | 37 | 5 | 116.3 | - | yes |
| c931 | tree_E_r | 28 | 5 | 121.4 | - | yes |
| c931 | flames_054_r | 11 | 2 | 122.3 | - | yes |
| c931 | flames_036_r | 9 | 2 | 125.8 | - | yes |
| c931 | flames_018_r | 9 | 2 | 127.3 | - | yes |

### Thunder (19)

| Cell | Picture | Nodes | Notables | Radius | Band | Pair |
|---|---|---|---|---|---|---|
| c932 | bolt_down_tree | 14 | 3 | 88.7 | - |  |
| c932 | bolt_out_tree | 14 | 3 | 92.4 | - |  |
| c932 | storm_569 | 20 | 5 | 94.5 | - |  |
| c932 | bolt_out_double | 9 | 2 | 100.1 | - |  |
| c932 | oai_three_tribulations | 9 | 3 | 100.2 | - |  |
| c932 | open_cloud_567 | 11 | 2 | 104.2 | - |  |
| c932 | oai_rim_coursing_thunder | 17 | 3 | 108.1 | - |  |
| c932 | oai_high_thunder_fan | 10 | 2 | 108.4 | - |  |
| c932 | storm_566 | 21 | 5 | 110.2 | - |  |
| c932 | bolt_out_chain | 10 | 2 | 110.9 | - |  |
| c932 | storm_586 | 20 | 5 | 117.6 | - |  |
| c932 | cloud_585 | 15 | 2 | 119.5 | - |  |
| c932 | cloud_upper | 56 | 7 | 120.8 | - |  |
| c932 | cloud_584 | 21 | 3 | 121.1 | - |  |
| c932 | cloud_579 | 12 | 3 | 122.1 | - |  |
| c932 | cloud_583 | 13 | 1 | 123.3 | - |  |
| c932 | arc_cloud_584 | 10 | 2 | 125.7 | - |  |
| c932 | cloud_581 | 12 | 3 | 128.5 | - |  |
| c932 | arc_cloud_582 | 10 | 2 | 128.8 | - |  |

### Darkness (5)

| Cell | Picture | Nodes | Notables | Radius | Band | Pair |
|---|---|---|---|---|---|---|
| c933 | long_spiral_r | 25 | 2 | 96.7 | - | yes |
| c933 | full_moon | 20 | 3 | 105.0 | - |  |
| c933 | horn_and_s_r | 32 | 4 | 106.0 | - | yes |
| c933 | shrine_eclipse | 141 | 35 | 110.7 | - |  |
| c933 | moon_lotus | 121 | 25 | 115.0 | - |  |

### Start motif, fire (3)

| Cell | Picture | Nodes | Notables | Radius | Band | Pair |
|---|---|---|---|---|---|---|
| c3 | flames_1 | 62 | 10 | 22.9 | - |  |
| c3 | flames_3 | 37 | 5 | 25.1 | - |  |
| c3 | flames_2 | 37 | 7 | 25.3 | - |  |

### Start motif, earth (6)

| Cell | Picture | Nodes | Notables | Radius | Band | Pair |
|---|---|---|---|---|---|---|
| c2 | ridges_4 | 14 | 1 | 23.2 | - |  |
| c2 | ridges_3 | 18 | 3 | 23.3 | - |  |
| c2 | ridges_2 | 21 | 2 | 23.4 | - |  |
| c2 | ridges_1 | 23 | 3 | 23.6 | - |  |
| c2 | ridges_6 | 11 | 1 | 25.3 | - |  |
| c2 | ridges_5 | 11 | 1 | 28.1 | - |  |

### Start motif, metal (4)

| Cell | Picture | Nodes | Notables | Radius | Band | Pair |
|---|---|---|---|---|---|---|
| c4 | blades_1 | 53 | 8 | 21.9 | - |  |
| c4 | blades_2 | 46 | 7 | 23.4 | - |  |
| c4 | blades_3 | 15 | 4 | 27.3 | - |  |
| c4 | blades_5 | 9 | 1 | 27.6 | - |  |

### Start motif, water (3)

| Cell | Picture | Nodes | Notables | Radius | Band | Pair |
|---|---|---|---|---|---|---|
| c5 | waves_3 | 10 | 1 | 20.0 | - |  |
| c5 | waves_1 | 68 | 10 | 24.6 | - |  |
| c5 | waves_2 | 43 | 8 | 25.5 | - |  |

### Start motif, wood (2)

| Cell | Picture | Nodes | Notables | Radius | Band | Pair |
|---|---|---|---|---|---|---|
| c1 | vines_1 | 71 | 15 | 23.0 | - |  |
| c1 | vines_2 | 61 | 13 | 25.0 | - |  |

