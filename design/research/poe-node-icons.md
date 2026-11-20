# How PoE's node icons work, and what the Đạo Đồ takes from it

Research for art bible §7.9, 2026-11-20. The user's notes on the first full icon set: "everything doesn't look colourful
enough, it's basically just a gold shade everywhere"; "we should do what PoE does, the art + colour sort of tell you
what the node is and they are distinguishable"; "we need another art for Mộc damage, Fire damage and all that"; "we
probably need more notable arts, they're repeating far too much".

Source: GGG's public PoE 1 tree export (`data.json` and its icon sprite sheets, github.com/grindinggear/skilltree-export,
downloaded 2026-11-20 to the scratchpad, not kept in the repo). Ascendancy, mastery, jewel-socket and proxy nodes left
out. PoE's art is studied only, never copied (the subjects and paintings stay ours).

## 1. Counts

| | PoE 1 nodes | PoE 1 icons | nodes per icon | Đạo Đồ nodes | Đạo Đồ icons (first set) |
|---|---|---|---|---|---|
| Small | 1,538 | 286 | 5.4 | 5,493 small + 958 plain notables on stat icons | 66 |
| Notable | 784 | 489 | 1.6 | 1,759 (1,451 distinct names) | 168 idea icons + the stat icons |
| Keystone | 57 | 57 | 1 | 43 | 43 |

The first set shared far more than PoE: 98 nodes per stat icon against PoE's 5.4, and notables repeating.

## 2. What PoE does

1. **Colour names the family before the picture is read.** Every icon is a full, saturated colour field, never a
   neutral metal. Fire damage is orange flame, cold icy blue, lightning blue-white, chaos magenta. Life is red, mana
   blue, energy shield silver-blue, evasion green, armour dark red. Strength, Dexterity and Intelligence nodes are one
   cross in red, green or blue.
2. **The picture names the stat:** the element itself for element damage, a figure in an aura for a defence, the
   weapon for a weapon-scoped line.
3. **The scope has its own icon.** Fire, cold and lightning damage, bow crit, axe attack speed and two-handed damage are
   separate icons. Fire damage has three near-identical versions (plain, Strength side, Intelligence side).
4. **Hybrids are split.** The life-and-mana icon is half red and half blue; armour-and-energy-shield likewise.
5. **Notables mostly get their own, more detailed art**, in the colour of their theme (489 icons for 784 notables).
   Keystones are all unique, usually a figure.

## 3. What the Đạo Đồ takes

- **Stat icons by stat and scope:** 147 combinations on small nodes and plain notables (65 unscoped, 63 scoped by
  element, 19 by another scope: sword, talisman, companion, formation, over time, quick, slow, poison, curse). The
  regeneration pairs keep sharing one icon each.
- **Colour = family, picture = stat.** Every icon is a full colour field (as the fight icons already are, §7.2), so the
  tree is colourful and a node's family reads from across the screen.
- **Scope changes the picture:** a Wood-damage node is a Wood-themed strike, a sword-scoped node shows the sword, a
  conversion (`convert_pct[physical>fire]`) is split between its two colours.
- **Notables get their own icons:** one per distinct name (1,414 plain notables; a mirrored pair shares one), painted
  in the colour of the notable's main line. The 37 capability and Effect notables keep theirs. The 168 idea icons stay
  as each big picture's fallback.

## 4b. Palette v2 (decided by Claude at the user's request, 2026-11-20: "make this choice for me, but study first")

The user asked for more variety between groups ("red for both fire and health is confusing"; "shift fire to orange,
like PoE's fire"; "they don't all have to be the same shade"). The draft below (§4) was rebuilt from three studies:

1. **Perception.** About 8 to 12 categorical colours can be told apart quickly. Red against green fails for about 6 to
   8 % of men, while blue against orange holds for every common colour-blindness. Colour-blind-safe palettes vary
   lightness, not only hue. Colour should not be the only cue, so the picture always carries the stat too.
   (Healey 1996; game-accessibility guides; the dataviz skill's validator.)
2. **Expectations.** PoE: life red, mana blue, fire orange, cold icy blue, chaos magenta, physical bone. Five Elements:
   Wood 青 qīng (blue-green), Fire red, Earth yellow-brown, Metal white, Water black-blue. The user's own picks: Metal
   white, Earth brown, Light bright yellow, Darkness purple apart from Thunder, Fire orange, health not like Fire.
3. **Our tree.** Pairs weighted by how often their nodes touch (edges), share a cluster (×3, because a cluster
   alternates two stat lines) and share a land (×0.15). Heaviest: fortune and mind (364), body and fortune (229),
   defence and offence (164), body and mind (144), body and offence (138), body and crafts (134). A land is mostly
   *not* its element (Earth land is 9 % Earth nodes, Wood 14 %): body, fortune and crafts fill most of each land.

Method: a search over candidate colours scored every pair by its weight times its OKLab distance in normal vision and
under simulated deuteranopia, protanopia and tritanopia (Machado 2009), with rules for meaning (offence far from
Chaos and from health, fortune apart from Light and from Fire, crafts apart from Earth and Fire, linh lực apart
from defence and Water) and a 3:1 contrast floor on the tree's dark ground. Sword joins Metal (one group fewer).

| Group | Colour | Why |
|---|---|---|
| Body and health | crimson #C62839 | PoE life red; deep, so it is not Fire |
| Fire | flame orange #FF7A1A | PoE fire; the user's pick |
| Fortune and cultivation | rich gold #FFD24A | gold reads as fortune |
| Mind and soul | lavender #B49CFF | soul themes are pale violet |
| Offence (no element) | keen sky-cyan #7FE0FF | the only colour clear of health, fortune, defence and Chaos at once |
| Defence | slate blue #3F6F9F | calm and armoured; far from offence |
| Linh lực | azure #3D8BFF | PoE mana blue |
| Crafts and companions | brass #A0A040 | apart from crimson even for colour-blind players |
| Wood | qīng green #22B07A | the Five Elements colour; separates from Fire by lightness |
| Metal and sword | white #FFFFFF | the user's pick |
| Water | sapphire #2A50E0 | deep blue, bright enough for the dark ground |
| Ice and cold | frost #C8F8FF | PoE cold |
| Thunder | electric violet #B060FF | as before |
| Darkness and curses | dark violet #8A3AB8 | dark purple, apart from Thunder, readable on the ground |
| Chaos | magenta #C02CA8 | PoE chaos |
| Earth | ochre brown #B47A40 | the user's brown, light enough to stay apart from crimson |
| Light | pale radiance #FFFBE0 | lighter than fortune's gold |
| Physical and force | bone #BFB39A | PoE physical |
| Wind | pale mint #B5F5E0 | |
| Poison | venom lime #D0F040 | |

Result: every pair of weight 40 or more is at least 15 apart in normal vision (OKLab ×100) and 8 under the worst
colour-blindness; every colour is at least 3:1 on the ground. Eight lighter pairs (weight 25 or less) stay under 15
or 5, mostly crafts against Earth, Wood, Fire and bone; the picture carries them. Each icon is painted in shades of its
group (deeper and brighter) with a touch of a neighbouring shade, so two icons of one group are not identical.

## 4. Palette (first draft, superseded by 4b)

Element scopes use the §7.5 table, so one colour means one thing across the fight screen and the tree. Unscoped stats
use the natural colour of the thing, as PoE does with life and mana.

| Family | Colour | Stats | Nodes |
|---|---|---|---|
| Fire arts `hoa`, fire damage `fire` | vermilion #E8442A | attack, crit, art speed and cost, stacks, resist and pen for fire | ~560 |
| Water arts `thuy` | deep blue #3F6FE0 | attack, art speed and cost, linh lực on hit, buff stacks | ~140 |
| Ice `bang`, cold damage `cold` | ice cyan #7AD7F0 | attack, crit, resist and pen for cold, Ice stacks | ~200 |
| Wood arts `moc` | jade green #2FBF8A | attack, crit, art speed and cost, over time, stacks | ~190 |
| Poison `poison` | venom green-yellow #A3C93A | poison damage, poison resistance | ~30 |
| Metal arts `kim` | silver-white #DCE3EC | attack, crit, art speed | ~190 |
| Sword `sword` | steel blue-grey #9FB3C8 | sword attack, crit, art speed | ~100 |
| Earth arts `tho` | earthen brown #8F5A2E | attack, crit damage | ~110 |
| Thunder arts `loi`, lightning `lightning` | violet #A15CFF | attack, crit, resist and pen, stacks, quick and slow strikes | ~140 |
| Wind `phong` | pale mint #A6EBD8 | attack, quick strikes | ~40 |
| Light `light` | bright yellow #FFE45C | attack, crit, resist and pen | ~80 |
| Chaos `chaos` | magenta #E0409A | attack, pen | ~140 |
| Physical `physical`, force `force` | bone #C9C2B2, rose #E58FB5 | attack, crit, resist and pen | ~140 |
| Body and health | crimson #B3243A | khí huyết, health regeneration, healing, healing taken, căn cốt, body shield, block | ~1,100 |
| Linh lực | azure #4FA3FF | linh lực pool, regeneration, on hit, on crit, leech, reservation, art cost | ~450 |
| Mind and soul | lavender #B79CFF | thần hồn, thần thức, soul resistance, soul attack, heart-demon resistance, đạo tâm, ngộ tính, qi deviation | ~950 |
| Offence, any element | amber #F0A030 | attack, crit chance and damage, accuracy, pierce, penetration, art and basic speed, stacks, status duration, curse, element affinity | ~700 |
| Defence | slate steel #7F9CB8 | defence, evade, resistance, ward, status and timer resistance, escape, stealth | ~550 |
| Fortune and cultivation | gold #E6B84A | khí vận, cơ duyên, mị lực, mission income, travel, cultivation speed, breakthrough, lifespan | ~800 |
| Crafts and companions | copper #D08850 | alchemy, pills and toxicity, refining, herbs, formations, treasures, companions, talismans | ~450 |

Known overlaps, resolved by the picture (as in PoE, where life red and fire orange sit close): crimson body against
vermilion Fire; azure linh lực against deep-blue Water; gold fortune against bright-yellow Light; copper crafts against
brown Earth; amber offence against vermilion Fire.

## 5. Cost

147 stat icons and 1,414 notable icons at one candidate each, about **$83** at medium quality ($0.053 per image,
unverified price); a 16-icon look test first, about $0.85.

## 6. Why the zoomed-out tree felt flat (2026-11-20)

The user: "the colouring of the tree when zoomed out seems a bit monotonic, it doesn't have depth like PoE 1 and 2".
PoE 1 was drawn from its own export and sprites (background tile, group backplates, lines, inactive icons, frames);
PoE 2 from a published patch 0.3 screenshot (icy-veins / poe-vault before-and-after image). Measured on node pixels:

| | PoE 1 | PoE 2 | Ours, Fire | Ours, Metal |
|---|---|---|---|---|
| Strongly saturated (HSV saturation > 0.5) | 15 % | 2 % | 49 % | 32 % |
| Dark / mid / bright / very bright (luminance bands) | 58 / 36 / 5 / 0 | 62 / 18 / 4 / 16 | 20 / 40 / 30 / 10 | 15 / 34 / 27 / 23 |
| Hue entropy in one region (12 bins) | 2.1 bits | 2.1 bits | 1.6 bits | 1.5 bits |
| Background | textured navy (8, 11, 15) | navy (7, 10, 16), soft colour glows | flat (7, 8, 12) | flat |

Findings: PoE keeps most of the tree dark and dim. Unallocated icons use separate desaturated "inactive" art, every
cluster sits on a dark ornamental backplate (group background), and the background is a textured navy. The bright
things are few (allocated paths, gold notable frames, keystones, PoE 2's soft glows), which reads as depth. Ours shows
every icon as if allocated, at full saturation on flat black, and a land is dominated by one or two hues, so the eye
gets no layers and reads it as monotonic. A mock with no new art (dimmed unallocated icons, navy textured ground,
soft land glows, placeholder backplates) moved it towards PoE's look.

Proposed: (1) an unallocated state that dims and desaturates icons (in-engine, art bible 7.7; the viewer can filter);
(2) a painted textured navy ground with soft land-colour glows; (3) painted ornamental cluster backplates in three sizes,
smaller than the cluster; (4) allocated paths and nodes at full colour with lit connectors.

## 7. The icons, not only the dimming (2026-11-20)

The user asked whether the flatness came from the icons rather than from PoE's dimming. Measured inside each icon
(PoE 1 full-colour sprites against ours): saturation about the same (0.72 against 0.67), but PoE is darker (mean value
0.54 against 0.73), has deep shadow in 19-24 % of the picture (ours 3-5 %) and mixes 2.1 main hues per icon (ours 1.3).
A render of PoE 1 with every node allocated still has its depth (18 % strongly saturated against our 51 %). Causes, in
order: (1) the icon style: ours were bright single-hue glowing discs, by the prompt; (2) colour spread: our lands are
dominated by one or two groups, PoE mixes hues node to node; (3) dimming, an extra layer.
Fix applied to the minor nodes first (user): stat style 2 (`gen_ai.STAT_STYLE2`, tag `_l2`): dark and moody, about a
quarter near-black, the group colour dominant with a counter-tone and a neighbouring touch. Fire land after: strongly
saturated 51 % -> 39 %, very bright 11 % -> 6 %; the small nodes recede and notables and keystones lead.
