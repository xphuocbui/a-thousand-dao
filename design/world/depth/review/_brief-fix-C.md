# Brief: fix pass C, depth and tone (world-depth review fixes)

The content review (`review/RANKED.md` group C) found the world too kind, tier B thin, tier C faceless, and the cast too
uniform. The story pass (B) has rewritten the sects' arcs. You add depth to the **people** in your batch's cast files,
consistent with those arcs. The user chose three parts: a harsher layer; wants and secrets for tier B; and appearance,
talent flaws and upbringing for tier C (the flaw and upbringing parts apply to every tier).

## Read first
- `schema.md` (fields; `appearance` is now for all tiers, and `wants` and `secret` are now for A and B), and
  `traits-v2.md` (kinds, opposites, the band per tier: A 6-12 traits, B 5-8, C 4-6).
- For each sect in your batch: its page's §1, §4 and §9 **as they are now** (pass B just rewrote them), then its cast
  files. A change must fit the sect's arc and each person's backstory.
- `review/_bc-notes.md` lines for your sects.

## 1. A harsher world
Counts across all 1,889 people today: Cruel 10, Faithless 13, Arbitrary 13, Callous 48, Lazy 57, Greedy 119, Deceitful 86,
against Diligent 444, Brave 418, Honest 356, Loyal 327. Aim, **in your batch, for about**:
- Cruel and Faithless: 4 % of people each;
- Callous, Arbitrary and Lazy: 5 % each;
- Greedy and Deceitful: 9-10 % each.

**Swap** a virtuous trait for the dark one, so that people stay inside their band. Respect the opposites: each pair is one
`set` in `assets/data/traits.json`, for example Honest/Deceitful, Loyal/Faithless,
Generous/Greedy and Compassionate/Callous/Cruel. A person holds at most one trait of each set. The checker now flags
two traits from one set, and three people already break the rule (bien_lam_chau, doan_ngoc_hanh, te_tieu_van): fix
them if they are yours.

**A dark trait needs a deed.**
- For tier A and B, write the deed into `backstory`, `wants` or `secret`. It is what they do, to whom (a key), and what it
  costs that person.
- For tier C, the one-line backstory carries it.

**Kinds of harshness to mix:**
- frightening (cruelty that someone pays for);
- petty (a grudge over a cup, a stolen bench);
- funny (a coward who brags, a miser who counts his rice);
- cold-blooded (a betrayal for a promotion).

Do not make every villain sad underneath.

**The demonic group** (`people/demonic*`) must frighten. Today none of its 25 living people is Cruel. Make at least six
Cruel, with deeds: soul-taking, blood rites, hostages kept for years. Keep Hám Tàn Chung and Tòng Bích Linh as they are
(a best item).

## 2. Tier B wants and secrets
Every living tier B person gets a `wants` (a line: what they are after) and a `secret` (a line).
- **The secret is an act in progress:** something they are doing now that will be found out or finished. It is not
  "X hides Y from Z".
- Vary them. Some are dark, some petty, some kind, some funny. A secret may tie into the sect's arc, but at most a third
  of a sect's tier B should; the rest are their own.
- If a secret names someone else, that person must have a way to be involved.

## 3. Tier C appearance, and flaws and upbringing for everyone
- **Appearance for every living tier C person:** one short clause, concrete and particular ("a burn scar he hides under
  a sleeve that is always too long", not "sharp eyes"). Vary the sense and the body part, and do not repeat a phrase
  within a sect. Tier A and B people with no appearance get one sentence.
- **Talent flaws.** No one today carries `slow_witted`, `homely` or `thin_soul`, and flaws are rare. Give about 10 % of
  your people one flaw talent: slow_witted, frail_frame, thin_soul, homely, unlucky or restless_heart.
  - Let it show in one word of the backstory or appearance.
  - For tier A and B, the matching `thien_phu` score must agree: slow_witted means a low ngo_tinh, frail_frame a low
    can_cot, thin_soul a low than_hon, homely a low mi_luc, unlucky a low khi_van, and restless_heart a low dao_tam.
  - A flaw replaces a gift talent if the band would overflow.
- **Upbringing.** `village_born` is 63 % of the world. Bring your batch to about 35-40 %. Use the other upbringings where
  they fit the person's home, role and family ties: servant_born, street_orphan, war_orphan, merchant_child,
  mortal_noble, scholar_family, temple_raised, wild_raised, hermit_taught, clan_heir and sect_raised.
  - A person whose backstory says "born in a village" either keeps the trait, or gets the backstory clause changed to
    match.
  - Siblings share an upbringing.

## Do not
- Change pass B's arcs, cited facts, chronicle ids (C, A, V), ties, roots, realms, ranks or builds.
- Touch the best items listed in `_brief-fix-B.md`.
- Write to the counters. A trait without a deed is not the fix.
- Use names or plots from existing novels, dramas or games.

## How to edit
The JSON is hand-formatted. You may write the values yourself into a scratch map keyed by person key, then insert them
with a small script that adds the field on its own line after the person's `role` or `backstory` line and keeps the
formatting. **Every value is still hand-written by you, not generated.** Validate that each file parses after each sect.
Prefix scratch files with your batch name.

After each sect, append one line to `review/_c-progress.md` with your batch name, the sect key, `done`, and counts: dark
traits swapped, tier B wants and secrets added, tier C looks added, flaws added, upbringings changed. If you are cut off,
the next writer resumes from there.

## Finish
Run `python -I tools/design/world/depth_check.py` until it shows no findings in your files: it checks the trait bands
and the opposites. Touch only your batch's files plus `_c-progress.md`. Do not commit. Report in under 120 words with
your counts per part.
