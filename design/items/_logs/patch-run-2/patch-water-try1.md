# Job transcript: patch-water (try 1)

I appended four items to `design/items/catalogue-water.json`. The lint reports 0 findings on 14 items. The first 10 records are untouched.

The `Bash` call to run a Python script was denied, so I added the records with direct edits instead. The new records are formatted more compactly than the first 10 (short modifier lines on one line).

| Id | Grade | Answers |
|---|---|---|
| `water-undertow-mail` (Giáp) | 2 | pacifist: Water armour with a standing ward; unique-nine-fathom-seal: Water body armour; starter-tide: Water armour with a pool ward |
| `water-owed-water-pendant` (Ngọc Bội) | 2 | dry-well: Owed Water, and a non-reserve sustain necklace; starter-tide: a non-reserve Water necklace Effect |
| `water-slack-tide-ring` (Nhẫn) | 1 | unique-nine-fathom-seal: a cheap grade-1 slow item; pacifist: a cost-reducing item |
| `water-spring-censer` (Hương Lô) | 2 | starter-tide: a full pool turned into a Cup refill; unkillable: Underground Spring |

- **Undertow Mail:** it carries a standing drain ward, "all 205.5 points, drain 0.1968". That is the Common Ward at 0.6 times, with the factor noted in the record. It is typed "all" rather than Water, because that is how the Common Ward is written.
- **Slack Tide Ring:** I raised its linh lực regeneration modifier from 3 to 6 after the first lint run, because the first version spent only 72 % of the grade-1 budget. It now spends 11.6 W of 12.8.
- **Other spends:** the other three items spend 20.6–23.0 W of the 25.6 W grade-2 budget. The censer's reserve art, Underground Spring, spends 8.4 W of the 10 W allowed.
- **New Effects:** I wrote two, both minor and neither an enabler: Owed Water (on the pendant) and Brimming Cup (on the censer). Both are marked as proposed in the water patch and are not in `effects.md`. I made them up for this patch, so the rules and numbers are mine, not the user's.

PATCH-DONE water
