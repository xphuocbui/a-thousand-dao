---
trigger: glob
globs: "**/src/ui/**, **/Assets/**/UI/**/*.cs, **/Assets/**/Ui/**/*.cs, **/Assets/**/ui/**/*.cs, **/Source/**/UI/**/*.h, **/Source/**/UI/**/*.cpp, **/Source/**/Ui/**/*.h, **/Source/**/Ui/**/*.cpp, **/Source/**/ui/**/*.h, **/Source/**/ui/**/*.cpp"
---

# UI Code Rules

- UI must NEVER own or directly modify game state — display only, use commands/events to request changes
- All UI text must go through the localization system — no hardcoded user-facing strings
- Support both keyboard/mouse AND gamepad input for all interactive elements
- All animations must be skippable and respect user motion/accessibility preferences
- UI sounds trigger through the audio event system, not directly
- UI must never block the game thread
- Scalable text and colorblind modes are mandatory, not optional
- Test all screens at minimum and maximum supported resolutions
- **Missing art shows an obvious placeholder** (user, 2026-11-24): when a painting, portrait or picture that should
  exist is missing (a cast member's portrait, a place painting, a province's picture, item or icon art), show
  `PlaceholderArt` (`src/ui/placeholder_art.gd`: magenta-and-ink stripes with the word PLACEHOLDER), never a silent
  stand-in that looks finished (a generic face for a named character, a map crop, another place's art, only a name in
  a frame). Generic art that is the design (type portraits for ordinary NPCs) is not missing.
