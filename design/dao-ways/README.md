# Đạo Ways: content drafts (overnight 2026-11-10/11)

> **Status**: Overnight draft, proposals only. Not in `dao.md`, not in data, not reviewed. Numbers are first
> guesses. The user decides what moves into the GDD and the Meridian kit regions.
> **Source**: the 94-Way roster in `design/gdd/dao.md` § Catalogue (provisional): names, titles, facets and
> capstone ideas are taken as given. This folder fills in what each Way actually does.
> **Template**: Kiếm Đạo, the approved pilot (`tools/design/meridian_rework/regions/dao_sword.py`).

## What each file holds

One file per Way, `NN-slug.md`, NN the roster number. Each has:

- **Header:** needs, theme stats (`theme_stats`, the keys its stat lines may use), the road modifier.
- **Build directions:** the three or more builds the Way is meant to host (the library rule: a Way hosts many
  builds, never one). Written as a player would see them: what to stack, what it converts, what it breaks.
- **Five facets**, each with:
  - small-node lines (the 2.4 W pair a small node of that facet carries);
  - stat notables (16 W each, theme stats only), four or five per facet, written `Name (Hán-Việt): lines`;
  - three Effect notables: **1 major, 2 minor** (dao.md rule 10). The major usually sits at the facet's far end.
- **Capstones** (2–6): one `keystone` or `enabler` Effect each, with what it **closes** (Effects rule 14) and
  its rival if any. Capstones and majors belong to this Way only.
- **Art:** only when the Way's theme owns one (rare; dao.md rule 10).
- **New pieces:** stat keys, statuses, readables or rules the Way needs that do not exist, labelled
  `Needs key` or `Needs rule`. Collected in [`_new-pieces.md`](_new-pieces.md).
- **Kept apart from:** how it avoids its overlaps (dao.md Open (roster)).

## Conventions

- **Modifier vs Effect.** A stat line is a plain number on a catalogue key (`attack_pct` with a tag scope, a
  conversion via `convert_pct`). Anything with a condition, trigger or rule is an Effect, unpriced.
- **L5 +N** = N points of Combat's L5 (cap 100), granted only by an Effect. **L2 +N** and **L4 +N** are `more`
  points. Plain `+X %` on a key is L1 (increased) unless the key says otherwise.
- **Element stacks** are Effects rule 9a (buff on self, debuff on foe, batches, no cap). Statuses and curses are the
  Effects Status Catalogue (Burn, Poison, Bleed, Qi Disruption, Corpse Rot, Sundered, Exposed, Sealed Meridian,
  Silence, Stagnation, Heavy Breath, Leaking Ward, Withering, Slackened Soul).
- **Fights** run 30–60 s, fatigue from 60 s, sustain is king. Arts start on their full cooldown. The basic attack
  always runs. Wards pay reserved, per hit, drain or cast.
- **Build-first, not romantic.** The names and titles are the roster's. The mechanics are written for players
  who min-max: a hook to scale, a resource to convert, a rule to bend, a drawback worth taking.
- **(starter)** marks an Effect simple enough for a first Way, as in the Sword pilot.
- **Shared minor** marks a `minor` Effect from the shared pool (dao.md rule 3; at most 4 per Way).

## Index

See [`index.md`](index.md) for the table of Ways, their status in this pass and their build directions.
