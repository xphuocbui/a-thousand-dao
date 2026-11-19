# Underlay ideas: Sun, Moon, Thunder, Chaos (2026-11-19)

The user asked for underlay images like the earlier Fire phoenix, "just so we have some ideas", in the style of the
moon from the whole-map first try, sketch 3 (`sketch3-whole.png`; crop `style-moon-sketch3.png`). Ideas only, never
map data (`no-illustrated-lands` still holds for the map itself).

- Model `gpt-image-2.6-sunburst`, `/v1/images/edits`, 1024x1024, quality high (`img.py`).
- Each request: image 1 = the island's empty roads (`layout-*.png`, from `render_box.py` on the base map), image 2 =
  the sketch 3 moon crop; prompt = region brief + shared style and drawing rules (`prompt-*.md`).
- Results: `moon-1..4.png` (4 = the first probe), `sun-1..3`, `thunder-1..3`, `chaos-1..3`; `contact.png`.
- Frames (map units; the image covers centre +- half): moon (0, -103) 21, sun (0, 112) 19, thunder (-103.7, -33.7) 19,
  chaos (0, 0) 15.5. The viewer artifact's "Underlay ideas" toggle places them there.
- Spend: 13 images, about 30k input and 23k output tokens.
