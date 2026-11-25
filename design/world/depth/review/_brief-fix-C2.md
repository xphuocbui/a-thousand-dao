# Brief: fix pass C2 (the pass C readers' findings)

Pass C added dark traits, tier B wants and secrets, tier C looks, flaws and upbringings (`_brief-fix-C.md`). Two fresh
readers checked a sample (`review/read-pass-C-1.md`, `review/read-pass-C-2.md`). The user chose to fix everything. You
work in your batch's cast files only, with the same ownership as pass C.

## Read first
- Both reader files in full. Their named defects and patterns are your list.
- `_brief-fix-C.md` (the rules still hold) and `schema.md`.
- For each sect: §9 of its page as it is now, then its cast files.

## Do, in your files
1. **Named defects.** Fix every defect either reader names in your files: contradicting secrets, a secret repeated in the
   backstory, a flattened person, a twin with a different upbringing. Use the reader's fix, or a better one that keeps
   the sect's arc.
2. **Names.** Every name in new text must match the cast record's `name` exactly. The readers list 23 that drift; also
   grep your own files. For each key named in a text, compare the Hán-Việt spelling.
3. **Tier C dark deeds name a victim.** A tier C person with Cruel, Faithless, Callous, Greedy, Deceitful or Arbitrary
   gets a one-line deed that names who it was done to: a key, or a role in the sect ("the kitchen girl"), and what it
   cost them.
   - Break the templates the reader found: Greedy and Faithless "sell something", Deceitful "lies", Arbitrary "acts by
     mood".
   - Vary the act: hoarding, bullying, informing, stealing credit, a rigged lot, a debt called in at a funeral.
4. **Flaws show.** Every person with a flaw talent (slow_witted, frail_frame, thin_soul, homely, unlucky,
   restless_heart) has it visible in their appearance or backstory, in a few words that show it in action.
5. **Spread dark traits across upbringings.** Today dark traits sit on 82 % of street_orphan people and 57 % of
   merchant_child people, which reads as a stereotype. In your batch, keep no upbringing above 35 % dark. Do it by
   moving a dark trait to a person with another upbringing (sect_raised, clan_heir, mortal_noble, scholar_family and
   temple_raised all have cruel and faithless people), giving the deed with it, and restoring a virtuous trait where
   one was taken. Keep each person inside the trait band and the one-per-set rule.
6. **Tier C looks out of the shared frame.** The looks share one frame, "A X and Y" (an adjective, a feature, "and",
   a second feature).
   - Rewrite them so that no frame covers more than a fifth of a sect's people.
   - Mix the shapes: a habit ("cracks his knuckles before every answer"), a thing worn or carried, a sound, a smell, how
     others see them, one striking detail.
   - Keep each one short and concrete, and keep any flaw that shows in it.

## Do not
- Change pass B's arcs, cited facts, chronicle ids, ties (other than fixing a named defect), roots, realms, ranks or
  builds.
- Touch the best items, which are listed in `_brief-fix-B.md` and in the readers' "best" sections.
- Use names or plots from existing novels, dramas or games.

## How to edit
Edit with careful exact-substring replacement. You may also put your hand-written values in a scratch map keyed by
person and apply them with a small script that keeps the file's layout, line endings and indentation. **Do not
re-indent a file.** Validate after each sect, and prefix scratch files with your batch name. After each sect, append one
line to `review/_c2-progress.md`: the batch, the sect, `done`, and counts for each of the six items.

## Finish
Run `python -I tools/design/world/depth_check.py` until your files show no findings. Touch only your files plus
`_c2-progress.md`. Do not commit. Report in under 120 words, with counts per item.
