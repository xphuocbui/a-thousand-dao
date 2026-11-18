# Đạo Đồ: image-model sketch, then trace

The split (2026-11-17): an image model sketches how the tree looks, the user picks a sketch and makes the look calls
in the editor, and Claude traces the sketch into real pieces and links and checks the rules. The sketch is a guide
under the map, not the map. It never goes into a version.

## Files here

| File | What it is |
|---|---|
| `current-layout.png` | The live tree (`hand-2026-11-17-woven-tilt`) in the editor's orientation (Fire at the bottom), coloured and labelled by land. Give it to the image model as the layout to keep. Made by `tools/design/dao_do_rework/authoring/layout_png.py <version.json> <out.png> [nolabels]`. |
| `poe-grammar.png` | A PoE 1 crop (left half of `reference/img_18.png`): the drawing grammar to copy. |
| `prompt.md` | This file. |

Save the sketches you like here (`sketch-01.png`, ...).

## How to run it

1. Use any image model that takes reference images (ChatGPT/GPT image, Gemini, Midjourney with `--sref`, ...).
   Attach **`current-layout.png` first** and **`poe-grammar.png` second**, then paste prompt A.
2. Make 4 to 8 and keep the best 1 or 2. Bad results are cheap, so don't fix a weak image with more prompting.
   Generate again.
3. Try prompt B as well. It gives the model a free hand with the composition, and it may find something better
   than the current arrangement.
4. In the editor (`python -I tools/design/dao_do_rework/editor/serve.py`), press **U** or click **Underlay**,
   then load the image or drop it on the map. Click **Fit to map**, then **Move image** to line it up: drag moves it,
   the wheel scales it, Shift+wheel rotates it. Opacity is about 0.4. **On top** draws it over the nodes.
   **Shift+U** hides or shows it. The image and its placement are remembered in your browser, not in the version.
   - `current-layout.png` lines up exactly at width **271.93**, centre **(-3.244, 3.382)**.
5. Tell Claude which sketch you chose and what to take from it (all of it, or "Earth's road pattern", ...).
   Claude traces it, and you judge the result with the sketch underneath.

## Prompt A: same layout, better drawing (whole tree)

```
Redraw the passive skill tree in image 1 as a clean, flat, top-down node graph in the drawing style of image 2.

KEEP from image 1: where every region sits and roughly how big it is. Chaos is the round hub in the centre. Five
large element lands surround it: Fire at the bottom, Earth to the right, Metal top-right, Water top-left, Wood to the
left. A small blend wedge sits between each pair of neighbouring lands (Fire|Earth, Earth|Metal, Metal|Water,
Water|Wood, Wood|Fire). A large circular rim road goes round all of them. Four outer regions hang outside the rim:
Light as a round disc below Fire, Darkness as a long crescent arc over the top, Thunder as a disc far left, Shrine as
a small ring far right.

COPY from image 2: the grammar, not the content.
- Roads are long, straight and orderly: exactly vertical, exactly horizontal or exactly 45 degrees, parallel and
  evenly spaced, with rounded corners. Curved roads follow true circles centred on the tree's centre.
- Small clusters of 3 to 7 nodes hang off road nodes on short spokes that leave at 90 or 45 degrees: small rings,
  little wheels, short curls, pairs mirrored across a road. Some big set pieces too: an 8-spoke star, a ring of
  rings.
- Mixed sizes, a steady rhythm, clear air between clusters. Nothing tangled, no crossing lines.
- About one node in four is a larger ringed "notable". Two big hollow "keystone" circles per element land, near its
  outer edge.

Give each element land its own road pattern; it may also picture its element:
Fire = radiating spokes and pentagon hubs; Earth = a rectilinear terrace grid; Metal = sharp diagonal 45-degree
blades; Water = long flowing parallel curves and one wide ring basin; Wood = branching forks that split and split
again. Chaos = a symmetric wheel. Light = concentric rings with rays. Darkness = a crescent with arms.
Thunder = zigzag forks. Shrine = one small ring with petals.

Style: square image, near-black background, thin warm-gold lines, small grey dots for minor nodes, gold-ringed
notables, plain flat 2D vector look. No text, no labels, no icons inside nodes, no glow, no texture, no
perspective, no border or frame. The whole tree must fit inside the image with a small margin.
```

## Prompt B: free composition (whole tree)

Prompt A without the "KEEP" paragraph. Instead:

```
Composition: a round tree, about 7,500 nodes in all. Chaos hub in the centre, five element lands in a ring around
it (Fire at the bottom, then counter-clockwise: Earth right, Metal top-right, Water top-left, Wood left), small blend wedges between
neighbours, one big rim road, and four smaller outer regions outside the rim (Light, Darkness, Thunder, Shrine).
Arrange the outer four however reads best. Attach only image 2.
```

## Prompt C: zoom on one region (later, only if the whole-tree sketch is too coarse)

Crop the chosen whole-tree sketch to the region, attach the crop first and `poe-grammar.png` second:

```
Image 1 is a rough sketch of one region of a passive skill tree. Redraw only this region at full detail in the
drawing style of image 2. Keep its outline, its main roads and where its big set pieces sit. Fill it with small
clusters of 3 to 7 nodes hanging off the roads on short spokes at 90 or 45 degrees, mixed sizes, steady rhythm,
clear air between clusters, no crossing lines. About one node in four is a larger ringed notable. Same style rules:
square, near-black background, thin warm-gold lines, flat 2D, no text, no glow, no perspective, no frame.
```

## Expectations

- The image model will not get the counts, the angles or the connectivity right. That's fine. Pick for the overall
  look (shape, rhythm, which land feels like itself), not for correctness.
- Claude's trace follows the rules even where the sketch breaks them. Exact 45/90 degree angles, keystone air,
  combos first, no crossings and reachability all come from the trace, not the sketch.
- The A2 skeleton roads and the rim ring stay unless the user says otherwise (`keep-user-designed-roads`). Where a
  sketch moves them, Claude points it out and asks rather than changing them.
