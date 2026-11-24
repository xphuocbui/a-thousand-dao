<!-- PROTOTYPE - NOT FOR PRODUCTION -->
# UI mood round 1 (2026-11-22)

**Question**: which visual direction should the art bible (sections 1-4 and 7) and the Godot theme follow? The 2026-11-11
map style demos (hand-drawn in code) were underwhelming; this round repaints real greybox screenshots with OpenAI's
image model, so the user judges finished-looking screens of this game's own layout.

**User's taste (2026-11-22)**: Crusader Kings III, Europa Universalis V, Victoria 3, and above all the map of Nobunaga's
Ambition: Awakening; all of them have a zoomed-out stylised map layer and a zoomed-in painted terrain layer. Prompts
describe qualities in words, never these games or their art.

**Status**: in progress: round 1 generated, awaiting the user's pick.

## How to run
`python -I img_edit.py <model> <quality> <size> prompts/<direction>.md prompts/<base>.md -- out/<name>.png <input.png>`
(key from `OPENAI_API_KEY`, never written down; `IMG_EDIT=--dry` prints the assembled prompt without sending).
Round 1: `gpt-image-2`, `1536x864` (16:9 accepted), one image per request.

| Output | Input | Prompt |
|---|---|---|
| `out/fight-a-lacquer-m.png` / `-h.png` (high, reference) | `in-fight.png` (greybox shot 29) | fight-base + fight-a-lacquer |
| `out/fight-b-hardwood-m.png` | `in-fight.png` | fight-base + fight-b-hardwood |
| `out/fight-c-ink-m.png` | `in-fight.png` | fight-base + fight-c-ink |
| `out/fight-d-bronze-m.png` | `in-fight.png` | fight-base + fight-d-bronze |
| `out/fight-e-silk-m.png` | `in-fight.png` | fight-base + fight-e-silk |
| `out/fight-f-ember-m.png` | `in-fight.png` | fight-base + fight-f-ember |
| `out/map-far-m.png` | `in-map-far.png` (shot 02, continent) | map-base + map-far |
| `out/map-near-m.png` | `in-map-near.png` (shot 16, region zoom) | map-base + map-near |

Usage per image (from the meta files): medium 1,078 output image tokens, high 4,312; about $0.65 for the round at the
icon pipeline's unverified per-image prices (8 × $0.053 + 1 × $0.211).

## Findings
- Medium quality is enough to judge a direction: layout, text and the painted icons all survive; high adds finer
  texture and background detail only.
- The model added painted portraits to the portrait boxes in a, c, e, f (not asked for).
- `map-far` invented Chinese-pinyin region names and a "Disciple 30" readout; the real regions have Hán-Việt names.
- **User's pick (2026-11-22)**: B, carved hardwood & brass, for the panels; both map layers (paper campaign map
  zoomed out, painted diorama terrain zoomed in).
- Round 2 (`r2-base` + `r2-map-far` / `r2-person` / `r2-tooltip`, inputs `in-map-far.png`, `in-person.png` (shot 25),
  `in-tooltip.png` (shot 22), 3 × medium): B holds across the zoomed-out map, a person window and nested tooltips over
  the painted terrain. Tooltips as parchment cards with brass corners, cinnabar links, a pin for "locked". The far map
  gave Hán-Việt-style region names (invented) and a compass with Chinese characters (to swap).
- The mock-ups are style targets, not game art (too small, terrain not tied to the grid, no map modes, baked labels).

## Round 3 (2026-11-24): windows as illustrated pages, not lists
User: the built windows "look so bad"; "use openai ... include photos, arts boxes at places ... the character list, show
the character and some info ... the sects list show the sects unique place ... Learn from ck3 and eu5".
Method changed: `r3_wireframes.py` draws a NEW layout sketch (portrait box, icon stat tiles, slot cards, hero banner)
with real game text and existing art pasted in, over the real map; `prompts/r3-base.md` + one window prompt, the
approved r2 person mock-up as the style image. `gpt-image-2`, low, 1536x864: 120 output image tokens + 2,592 input
image tokens per image (about $0.01-0.02 each).

| Output | Sketch | Prompt |
|---|---|---|
| `out/r3-character-l.png` | `in-r3-character.png` | r3-base + r3-character |
| `out/r3-sect-l.png` | `in-r3-sect.png` (banner = `design/map/continent-11/art/places/paint_1.png`) | r3-base + r3-sect |

Findings: low quality is enough here; the layout and Vietnamese text survive almost intact. Slips: Thiên phú tile
labels squeezed onto two lines; the sect banner was repainted instead of kept; "died 1000, at 640" became "at 616";
"Your standing" garbled; the lore inset gained two invented lines. Art boxes: place paintings and technique icons exist
today; portraits (large and medallion), trait medallions and the Thiên phú / fact-tile icons are new art.
