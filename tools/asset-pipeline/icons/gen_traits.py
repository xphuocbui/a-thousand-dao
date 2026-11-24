"""Painted trait medallions (user 2026-11-24: "do traits first, use openai"; the round-3 character mock-up's trait row,
prototypes/ui-mood/out/r3-character-l.png). One round medallion per trait in assets/data/traits.json (personality,
callings, fate, gained), painted by OpenAI's image model at low quality (memory: image-quality-low), each with a
hand-written symbol below; the group sets the medallion's metal so a row reads at a glance (bronze personality, jade
callings, gold fate, iron gained).

Masters: tools/asset-pipeline/icons/ai/openai/traits/<group>_<id>.png (+ -meta.json; git-ignored with ai/).
Game copies: assets/icons/traits/<id>.png at 128 px with transparent corners, and assets/icons/traits/index.json.
Usage (repo root): python -I tools/asset-pipeline/icons/gen_traits.py [test|all] [--dry] [--jobs 6]
The key comes only from OPENAI_API_KEY; painted keys are skipped on a re-run.
"""
import base64, concurrent.futures, json, os, sys, time, urllib.error, urllib.request
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
OUT = os.path.join(HERE, "ai", "openai", "traits")
GAME = os.path.join(ROOT, "assets", "icons", "traits")
MODEL, QUALITY, SIZE = "gpt-image-2", "low", "1024x1024"

METAL = {"personality": "an aged bronze rim with fine engraving",
         "callings": "a carved green jade rim",
         "fate": "a gilded gold rim with tiny cloud scrolls",
         "gained": "a dark forged iron rim with rivets"}
STYLE = ("A single round medallion icon for a historical grand-strategy game set in an original Chinese cultivation (xianxia) "
         "world, seen flat and straight-on, filling the square, on a plain pure black background. The medallion has %s and a "
         "smooth enamel field in %s; in its centre one bold, simple, instantly readable symbol: %s. Painted in a refined "
         "semi-realistic style with crisp edges and strong contrast so it reads at 32 pixels: one clear silhouette, few small "
         "details, gentle light from the upper left. No text, no letters, no characters, no numbers, no border outside the "
         "medallion, no watermark.")
# The field colour: warm for virtues and boons, cool or dark for vices and banes, so the row hints at the trait's lean.
GOOD, BAD, NEUTRAL = "a warm deep teal", "a deep oxblood red", "a muted slate blue"
SUBJECT = {
    # personality (37)
    "brave": (GOOD, "a raised sword crossed over a lion's head"), "cautious": (NEUTRAL, "a closed eye behind a raised round shield"),
    "calm": (GOOD, "a still lotus on unrippled water"), "wrathful": (BAD, "a roaring flame shaped like a snarling face"),
    "content": (GOOD, "a steaming teacup beside a small hearth"), "ambitious": (NEUTRAL, "a mountain peak with a crown above it"),
    "diligent": (GOOD, "a brush and an inkstone with a stack of scrolls"), "lazy": (BAD, "a sleeping cat curled on a pillow"),
    "forgiving": (GOOD, "two open hands releasing a white dove"), "vengeful": (BAD, "a coiled serpent biting a dagger"),
    "generous": (GOOD, "an open hand pouring coins"), "greedy": (BAD, "a clawed hand clutching a heap of gold ingots"),
    "gregarious": (GOOD, "three wine cups raised together"), "reclusive": (NEUTRAL, "a lone hut on a misty mountain"),
    "honest": (GOOD, "a clear mirror shining"), "deceitful": (BAD, "a smiling mask hiding a second face"),
    "humble": (GOOD, "a bowed bamboo stalk"), "arrogant": (BAD, "a peacock with its tail spread"),
    "just": (GOOD, "balanced scales"), "arbitrary": (BAD, "a broken scale with one pan crushed"),
    "patient": (GOOD, "a tortoise under a pine"), "impatient": (BAD, "an hourglass cracking with sand spilling"),
    "temperate": (GOOD, "a single bowl of rice and chopsticks"), "indulgent": (BAD, "an overflowing wine jar and grapes"),
    "trusting": (NEUTRAL, "two clasped hands"), "paranoid": (BAD, "many watching eyes in darkness"),
    "devout": (GOOD, "an incense burner with rising smoke"), "pragmatic": (NEUTRAL, "an abacus"),
    "stubborn": (NEUTRAL, "a boulder splitting a river"), "fickle": (BAD, "a weathervane spinning in the wind"),
    "compassionate": (GOOD, "a hand cradling a small sprouting seedling"), "callous": (BAD, "a cold stone heart cracked with frost"),
    "cruel": (BAD, "a barbed whip"), "warlike": (BAD, "a battle axe and a war banner"),
    "peaceable": (GOOD, "an olive-like branch of peach blossom over a sheathed sword"), "loyal": (GOOD, "a faithful hound sitting upright"),
    "faithless": (BAD, "a snapped red cord"),
    # callings (14)
    "strategist": (NEUTRAL, "a war map with flag markers"), "steward": (NEUTRAL, "a key ring and a ledger"),
    "diplomat": (NEUTRAL, "a sealed scroll tied with ribbon"), "merchant": (NEUTRAL, "a balance with a coin string"),
    "teacher": (NEUTRAL, "an open book with a glowing light"), "schemer": (NEUTRAL, "a hand moving a go stone on a board"),
    "alchemist": (NEUTRAL, "a three-legged pill furnace with a glowing pill"), "refiner": (NEUTRAL, "a hammer over an anvil with sparks"),
    "formation_master": (NEUTRAL, "a glowing octagonal formation diagram"), "talisman_maker": (NEUTRAL, "a yellow paper talisman with red glyph strokes"),
    "beast_tamer": (NEUTRAL, "a tiger head with a leash ring"), "herbalist": (NEUTRAL, "a ginseng root with leaves"),
    "duelist": (NEUTRAL, "two crossed sabres"), "wanderer": (NEUTRAL, "a straw hat and a walking staff"),
    # fate (10)
    "heaven_favoured": (GOOD, "a beam of light from parting clouds"), "ill_starred": (BAD, "a falling black comet"),
    "wise_born": (GOOD, "a glowing third eye on a brow"), "dull_witted": (BAD, "a fogged clouded orb"),
    "iron_boned": (GOOD, "an iron skeleton arm flexed"), "frail": (BAD, "a cracked porcelain vase"),
    "spirit_eyed": (GOOD, "an eye with a glowing spirit iris"), "hollow_souled": (BAD, "a hollow wisp-shaped flame with a hole"),
    "pure_hearted": (GOOD, "a radiant red heart wrapped in white light"), "demon_seeded": (BAD, "a black seed sprouting purple demonic flame"),
    # gained (16)
    "scarred": (NEUTRAL, "a scarred cheek with three slashes"), "battle_hardened": (GOOD, "a dented helmet on crossed spears"),
    "shaken": (BAD, "a trembling candle flame"), "renowned": (GOOD, "a laurel of golden leaves around a bell"),
    "disgraced": (BAD, "a broken jade token"), "humbled": (NEUTRAL, "a kneeling figure bowing"),
    "embittered": (BAD, "a withered bitter melon"), "grudge": (BAD, "a red knot pierced by a needle"),
    "lovestruck": (NEUTRAL, "a pair of mandarin ducks"), "grieving": (BAD, "a white funeral lantern"),
    "sworn_sibling": (GOOD, "three cups under a peach tree"), "life_debt": (NEUTRAL, "a hand pulling another from water"),
    "hunted": (BAD, "an arrow-pierced paper wanted notice"), "enlightened": (GOOD, "a glowing lotus above a meditating silhouette"),
    "oath_bound": (NEUTRAL, "a blood drop over a sealed oath scroll"), "demon_tainted": (BAD, "a black vein spreading over a hand"),
}


def traits():
    d = json.load(open(os.path.join(ROOT, "assets", "data", "traits.json"), encoding="utf-8"))
    return [(g, t) for g in ("personality", "callings", "fate", "gained") for t in d[g]]


def prompt(group, t):
    colour, symbol = SUBJECT[str(t["id"])]
    return STYLE % (METAL[group], colour, symbol)


def paint(key, text):
    full = os.path.join(OUT, key + ".png")
    if os.path.exists(full):
        return key, "skip"
    body = json.dumps({"model": MODEL, "prompt": text, "n": 1, "size": SIZE, "quality": QUALITY}).encode()
    req = urllib.request.Request("https://api.openai.com/v1/images/generations", data=body, headers={
        "Authorization": "Bearer " + os.environ["OPENAI_API_KEY"], "Content-Type": "application/json"})
    for attempt in range(3):
        try:
            r = json.load(urllib.request.urlopen(req, timeout=600))
            break
        except urllib.error.HTTPError as e:
            msg = e.read().decode()[:300]
            if e.code in (429, 500, 502, 503) and attempt < 2:
                time.sleep(20 * (attempt + 1))
                continue
            return key, "HTTP %d %s" % (e.code, msg)
        except Exception as e:
            if attempt < 2:
                continue
            return key, "error %s" % e
    os.makedirs(OUT, exist_ok=True)
    open(full, "wb").write(base64.b64decode(r["data"][0]["b64_json"]))
    json.dump({"prompt": text, "usage": r.get("usage"), "model": MODEL, "quality": QUALITY, "size": SIZE},
              open(full[:-4] + "-meta.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    return key, "ok"


def install(pairs):
    os.makedirs(GAME, exist_ok=True)
    index = {}
    for group, t in pairs:
        src = os.path.join(OUT, "%s_%s.png" % (group, t["id"]))
        if not os.path.exists(src):
            continue
        im = Image.open(src).convert("RGBA").resize((128, 128), Image.LANCZOS)
        mask = Image.new("L", (128 * 4, 128 * 4), 0)   # the black background around the medallion becomes transparent
        ImageDraw.Draw(mask).ellipse((10, 10, 128 * 4 - 10, 128 * 4 - 10), fill=255)
        im.putalpha(mask.resize((128, 128), Image.LANCZOS))
        im.save(os.path.join(GAME, "%s.png" % t["id"]))
        index[str(t["id"])] = {"group": group, "file": "traits/%s.png" % t["id"]}
    json.dump({"_doc": "Trait medallions (tools/asset-pipeline/icons/gen_traits.py): trait id -> group and the icon under assets/icons/.",
               "icons": index}, open(os.path.join(GAME, "index.json"), "w", encoding="utf-8"), indent=1, ensure_ascii=False)
    return len(index)


def main():
    pairs = traits()
    missing = [str(t["id"]) for _g, t in pairs if str(t["id"]) not in SUBJECT]
    assert not missing, "no symbol written for: %s" % missing
    if "test" in sys.argv:
        pairs = [p for p in pairs if p[1]["id"] in ("brave", "greedy", "alchemist", "heaven_favoured", "scarred")]
    jobs = int(sys.argv[sys.argv.index("--jobs") + 1]) if "--jobs" in sys.argv else 6
    work = [("%s_%s" % (g, t["id"]), prompt(g, t)) for g, t in pairs]
    todo = [w for w in work if not os.path.exists(os.path.join(OUT, w[0] + ".png"))]
    print("%d traits, %d to paint" % (len(work), len(todo)))
    if "--dry" in sys.argv:
        print(work[0][1])
        return
    with concurrent.futures.ThreadPoolExecutor(jobs) as ex:
        for key, res in ex.map(lambda w: paint(*w), todo):
            if res != "ok":
                print(key, res, flush=True)
    print("installed", install(traits()))


if __name__ == "__main__":
    main()
