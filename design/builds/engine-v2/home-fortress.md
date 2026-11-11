# Home Fortress (Trạch Sơn): NOT REBUILT, NO FIGHT FILE WAS RUN

**Status: blocked.** The task says to keep the build's layers, crit, ward, body, keystones, curses and purity from the old fight files `design/builds/overnight-2026-11-10/builds/home-fortress*.fight.json`. Those files do not exist. Two Globs (that exact pattern, and `**/home-fortress*.json` over the whole repo) returned nothing. The only old files for this build are `home-fortress.md` (the guide), `home-fortress.sheet.md`, and two `_driver` try logs. The task limits reading to the guide, the old fight files, the Fight input section and `design/arts/INDEX.md`, so I did not open the sheet or the logs.

I wrote no `.fight.json` and ran no `fight.py` command (no `--matrix`, no `--without`). There are no results. The guide gives preparation and ward-strength figures but no layer vector, crit, body or purity values. Filling those in myself would be tuning numbers, which rule 5 forbids, so I stopped.

## Choices recorded for a rerun (from the guide and INDEX.md; untested)

Concept: never meet a guest on the road. Over-prepare past the L4 cap, turn the surplus into ward strength, and fight on your own ground.

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Mountain-Press Seal (slot 1, big hit) | `strata-hammer` (heavy Earth hit, lays Strata on you) | mountain-heart-canon (6) |
| Landslide (Earth stacks that dampen Physical) | `landslide` (common art) | no catalogue technique carries it; use a generated common technique |
| Stake-Driving Seal (cheap, slow Earth seal) | `sinking-weight` (Earth seal) | mountain-heart-canon (2) |
| Warm Stone (heal) | no equivalent among the Earth arts; the closest is `second-wind` (common) | common technique |
| Homeward Step (escape) | none: the engine does not model escape | lost |
| Golden Bell / ward in the art slot | `bastion-reprisal` (body shield) | mountain-heart-canon (4) |

The main technique would be `mountain-heart-canon` (Profound main, tho). It carries four arts, up to layer 6, which is within the truc_co limit. For an auxiliary technique, `mountain-bone-body-art` is a body technique that any root can use, and it adds `resist_pct` +40 [physical] and `block_rating`. `deep-vein-scripture` (tho, Heaven secret) is the alternative.

Lost in the move, whatever the rerun finds:
- Threshold Binding, Overbuilt Walls, Five Preparations, Host's Advantage and Pressing Mountain are Effects from Đạo, items or the tree, so they stay. They need the staged home-ground and preparation payload plumbing, which the fight format may not express. If the engine refuses them they go in `unmodelled`.
- The escape art and the Warm Stone heal have no library equivalent.

## Results tables

None. No fight was run.

## Next step

Supply the old fight JSON, or say which values to use for layers, crit, ward, body and purity. Then I rebuild the build and run the matrix and the two `--without` tests.

LIB-DONE design/builds/engine-v2/home-fortress.md
