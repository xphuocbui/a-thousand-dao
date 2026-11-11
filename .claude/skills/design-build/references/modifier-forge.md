# The Modifier Forge

This is the heart of the skill. The game works like Path of Exile: **a build is a concept with modifiers
stacked on it**, and sometimes one enabling piece that makes the concept possible at all. Death's Oath
gives a character a death aura, and then the build stacks chaos damage and everything else that aura
wants. The armour opens the door; the modifiers are the build.

So this skill designs modifiers first and everything else second. Techniques, items, tree clusters and
Đạo are where modifiers live. Read `combat-model.md` first: a modifier that ignores how its channel
works is decoration.

## The shape of a build

```
ENABLER   opens a channel, a rule or a resource that was not there
   │      and takes something away in exchange
   ▼
STACK     the modifiers that make it strong, one rung at a time
   │
   ▼
ANSWERS   what keeps it alive and covers its gaps
```

Most builds need one enabler at most. Plenty need none, because the concept is simply an unusual stack
of what already exists. Never add an enabler to feel creative: the best stacks are often built from
ordinary pieces that nobody had thought to combine.

## Anatomy of a modifier

```
[size] [form] [what it changes] [scope: tags] [condition]
 +12    more   damage            with Poison   while the enemy has no linh lực
```

A modifier always states: its **form**, its **channel** (or that it is channel-neutral), its **layer**
(if it adds to damage), its **scope** as tags, and its **condition**.

Scope it by **tags, never by build**. "+12 % Poison damage" serves every poison build ever made.
"+12 % damage for Grave-Silk Rot" serves one, and the game gets a little worse.

## The forms

Use a range of these. A stack that is all one form is a list of bonuses with a theme word on it.

| # | Form | Pattern | Example | Layer | Weight |
|---|---|---|---|---|---|
| 1 | **Increased** | +X % to a tag | +12 % Sword damage | L1 | Small |
| 2 | **More** | X % more, tag-keyed | Arts with a 5 s cooldown or more deal 25 % more | L2 | Notable |
| 3 | **Flat base** | Adds to the coefficient | +0.3 to the basic attack's coefficient | none | Notable |
| 4 | **Conditional** | While or after a state | +30 % more while your ward is down | L5 | Notable |
| 5 | **Per** | X for each Y | +2 % more per curse on the enemy | any | Notable |
| 6 | **Conversion** | A share becomes another tag | 40 % of Fire hits become Lava | rule 6 | Notable |
| 7 | **Redirect** | A bonus to A also applies to B | Art speed also applies to your basic attack | none | Keystone |
| 8 | **Borrow** | A counts as B | Unused thần thức counts as ward strength | none | Keystone |
| 9 | **Trigger** | When X, do Y | On a crit, refund 5 % of the art's cost | rule 9 | Notable |
| 10 | **Cap shift** | Moves a fixed limit | +1 to `curse_slots` | none | Keystone |
| 11 | **Overflow** | What a cap clips becomes something else | Tick damage over the cap burns linh lực | none | Keystone |
| 12 | **Trade** | A gain with a real loss | Arts cost health, and +40 % more | any | Keystone |
| 13 | **Rule swap** | Replaces a rule | Art costs are a share of current linh lực, not maximum | none | Keystone |
| 14 | **Timing** | Moves when things happen | Your first art fires at half its cooldown | none | Notable |

**Overflow and Per are the most Path of Exile forms this game has.** Overflow gives a build a reason to
keep stacking past a cap. Per turns a stat nobody cares about into a build's entire purpose.

## Enablers

An enabler is what the player finds, earns or sacrifices for. It should be a moment in a life: the robe
found on a dead elder, the Đạo glimpsed at a graveside. It must do two things:

1. **Open something:** a channel, a rule or a resource the build cannot have otherwise.
2. **Close something:** a real loss that shapes the rest of the build. An enabler with no price is just
   a strong item.

| Kind | What it does | Example shape |
|---|---|---|
| **New channel** | Damage arrives a new way | A permanent tick with no slot or cooldown |
| **Free channel** | Removes the cost of one | Basic attacks carry your art tags |
| **Resource swap** | Pays with something else | Arts cost health, lifespan or heart demon |
| **Scaling bridge** | A defensive or life stat starts feeding damage | Ward strength adds to L2 |
| **Rule removal** | Takes a limit away, with a price | No soul lockout, but soul arts cost health |
| **Slot bender** | Changes what the loadout means | Empty art slots strengthen the rest |
| **Victory change** | Changes what winning is | A stalemate with more health left counts as a win |
| **Loop opener** | A closed resource loop | Linh lực drained from the enemy refills your ward |

Where an enabler can live: a named artifact, a technique's divine ability, a Đạo keystone, a sealed
cluster's keystone, a variant root, a pill that permanently changes the body, or a rare event. Choose
the place that fits the story and its rarity.

**The rule for rarity:** the enabler can be rare, the stack cannot. If the stack needs three unique items,
it is not a build, it is a prize.

## The stack ladder

Go up this ladder for the build's channel. Each rung asks what could go there. An empty rung is either a
real gap or a deliberate sacrifice, and the sheet says which.

| Rung | Question | Typical modifiers |
|---|---|---|
| **1. Base** | What is the size before multipliers? | Coefficient, `c_tick`, stacks, thần thức for soul |
| **2. Rate** | How often does it happen? | Art speed, first firing, pulses, extra firings |
| **3. Multiplier** | Which layers can this channel use, and which are empty? | One source for each of L1 to L5 it can use |
| **4. Crit or certainty** | Does it crit? If not, what replaces that? | Crit, or a rule that makes it certain |
| **5. Reach** | What stops it getting through? | Pierce, shred, ward pass raise, accuracy |
| **6. Past the cap** | What happens when it hits its limit? | Cap shift or overflow |
| **7. Fuel** | Can it afford this for the whole fight? | Cost, regeneration, refund, swapped resource |
| **8. Survival** | Does it live long enough? | Ward, guard, evade, soul and status answers |
| **9. Identity** | What is the one strange piece that makes it this build? | A Per, Borrow or Overflow nobody else uses |

Rung 9 is where the build earns its name. If you could delete it and the build plays the same, it is
not finished.

## Creative moves

Most weak modifiers come from starting with a theme word. Start from a rule instead. Pick a rule below
and ask what happens if a modifier bends it. These are prompts, so use them to find new ideas rather
than copying them.

**The timeline**
- Art cooldowns that divide the pulse land on the beat. What if an art firing in the same millisecond
  as a pulse deals more? Art speed stops being "more is better" and becomes tuning a rhythm.
- Two arts in one instant: should the second gain from the first?
- Follow-up instants fire after damage lands. What if an art in a follow-up instant counts as a riposte?
- All of an instant's damage lands before the defeat check, so a dying side still acts. What if your last
  instant hits harder? What if you win double knockouts by rule, for a build that means to die with you?
- A stalemate is a failure today. What if it is a win for one strange build?

**Linh lực and wards**
- Nothing reserves linh lực. What does a reservation buy, given that it weakens the ward?
- Costs are a share of maximum. What if they were a share of what is left, so the pool never empties but
  never stays full?
- Regeneration above a full pool is wasted. What could it become?
- The ward drains in proportion to what it blocks. Can you make the enemy's ward work against them?
- A negative ward strength is allowed. Which curse gets there, and what stacks on it?

**Limits**
- What should happen to tick damage a cap clips? To a trigger over budget? To a stack past the cap? To a
  curse pushed out of a full set of slots?
- Thần thức limits artifacts. What if the part you leave unused is the build's power?
- A build with an empty art slot: is that a loss, or a resource?

**The life around the fight**
- Heart demon, pill toxicity, a failed breakthrough, a wasted decade. Which of these can be a weapon?
- Pill toxicity is a problem to manage. What if a poisoner keeps it on purpose?
- Lifespan runs out. What if a build gets stronger as it does, and knows the date?
- What does a build gain from having fewer of something: fewer Daos, fewer artifacts, a single root?

**Other people's rules**
- Which enemy rule can be turned around? Their arts' costs, their guards, their timers, their slot order.
- Can you win by making them act, rather than by acting?

## Tests for one modifier

Keep a modifier only if it passes all of these.

1. **Real hook.** It names a real rule, key or tag, or it says exactly which new one it needs.
2. **Right channel.** It affects something its channel actually uses.
3. **A decision.** It makes a player want or avoid something, rather than simply taking it.
4. **Second home.** Name a different build that would also want it. If there is none, it is a signature
   piece and must be labelled so, and a build gets very few of those.
5. **Readable.** One line in a Breakdown can explain it (rule 16).
6. **NPC-safe.** The NPC generator can use it, and it does not depend on player input. Every modifier
   also applies to NPCs (rule 2).
7. **Bounded.** It stays inside a stated limit (Pillar 2). A Per has a cap or a naturally bounded source.

## Sizing

Nothing past L1 has a W price yet (Combat Open Question 5). Until it does, every size on a new modifier
is a first guess, and the sheet says so. Size against these instead of inventing a scale:

- **Everyday nodes:** `tree-modifier-catalogue.md` gives small and notable sizes. A narrower scope gets a
  bigger number.
- **Layer points:** L2 sources are authored at 5 to 50 points. Compare any layer's total to the Formulas B
  anchors for typical and top-end.
- **Passive and art weight in a Đạo:** `credit(T)` in dao.md Formulas D1.
- **Keystones are not sized by number.** They are sized by what they take away.

Being a bit strong is fine. Macro averages matter, individual outliers do not, so note a strong build and
move on rather than shaving it.

## Worked example: an aura build

The seed: "a Death's Oath style aura, then stack around it."

**Translate.** No area and no movement exist here. An aura is a tick that needs no slot. Reading the
channel table: ticks skip the ward, use L1 to L4, never crit, and clip at shares of the target's health.

**What that means.** Damage soon stops mattering, because the tick reaches the cap. A plain copy would be
weak and dull, so stacking damage needs a purpose past the cap. That is the insight, and it could not
come from the theme.

**Enabler.** A permanent tick from t = 0 (new channel), paid for by reserving linh lực, which weakens the
ward.

**Stack.** Rung 3 fills L1 to L4 and ignores L5. Rung 6 is the build: an **Overflow** turns clipped tick
damage into linh lực burn, so past the cap the same stack now starves the ward. Rung 7 is regeneration,
because of the reservation. Rung 8 is body guard, because the ward is smaller.

**Second homes.** Overflow on ticks also serves any poison build. Reservation serves any sustained effect.

## What to avoid

- A modifier that is only a bigger number on something that already exists, when a catalogue row covers it.
- Modifiers named after the build instead of the tag.
- A stack with no answer to the channel's cap.
- An enabler that is strictly better than not having it.
- Three stats that all mean "more damage" in the same layer.
- A condition that is always true, or never true, in a real fight. Check it with `fight.py --timeline`.
