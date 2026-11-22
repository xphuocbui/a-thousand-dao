# UI theme kit pipeline (art bible 8.7)

Regenerates the UI furniture in `assets/ui/` from image-model masters and procedural noise.

| Step | Command | Output |
|---|---|---|
| Masters (paid, only when a piece is redesigned) | `python -I img_edit.py gpt-image-2 medium 1536x1024 prompts/kit-<piece>.md prompts/kit-base.md -- masters/kit-<piece>-m1.png masters/style-ref-hardwood.png` (key from `OPENAI_API_KEY`) | `masters/kit-*.png` + `-meta.json` (usage, prompt) |
| Cut | `python -I tools/asset-pipeline/ui/cut_kit.py . [border_1x=8]` | frames, plaques, bar trough at 2x and `_1x`; parchment re-tinted into Section 4's range; `assets/ui/kit.json` (nine-slice margins) |
| Textures | `python -I tools/asset-pipeline/ui/tex_gen.py .` | seamless `tex_parchment.png`, `tex_rosewood.png` (seeded) |
| Font check | `godot --headless --path . -s res://tools/asset-pipeline/ui/font_check.gd` | Vietnamese coverage and tabular digits, printed |
| Theme sheet | `godot --path . --windowed --resolution 1280x720 -s res://tools/asset-pipeline/ui/theme_sheet.gd -- --out <png> [--scale 1.5]` | one screenshot of the kit through real controls (opens a window briefly; no cursor moves) |

Style reference: `masters/style-ref-hardwood.png`, the user's pick from `prototypes/ui-mood/` (round 1, B).
`masters/` has a `.gdignore`: masters are pipeline inputs, never imported as game textures. The lone brass corner
fitting in `masters/kit-tooltip-m1.png` is not used. Fonts in `assets/fonts/` are OFL (licence beside each family).
