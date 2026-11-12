"""Generate painted icon candidates with an image model (art bible §7.1, §7.4, §7.4b, §8.6 item 9).

Builds one prompt per icon (arts, techniques, wards, statuses, counters, stances, element glyphs) from the art bible's
grammar and the game data, calls Recraft and/or OpenAI, saves every candidate with its prompt, model and seed, and
writes a pick sheet (one row per icon, one column per candidate) for the user to choose from.

Keys come only from the environment: RECRAFT_API_TOKEN, OPENAI_API_KEY. A missing key skips that provider and says so.
Costs are estimates from the providers' published per-image prices (OpenAI's is unverified).

Run (from the repo root):
  python -I tools/asset-pipeline/icons/gen_ai.py --set test --provider both --n 2 --dry-run   (prompts and cost only)
  python -I tools/asset-pipeline/icons/gen_ai.py --set test --provider both --n 2
Default provider: openai (gpt-image-2, user choice 2026-11-12). Sets: test (17 icons), arts, techniques, wards, statuses, counters, stances, glyphs, all.
"""
import argparse
import base64
import glob
import io
import json
import os
import sys
import time
import urllib.error
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
OUTDIR = os.path.join(HERE, "ai")
PRICE = {"recraft": 0.035, "openai": 0.211}           # USD per image: recraftv4_1 raster; gpt-image-2 high 1024 (unverified)
MODEL = {"recraft": "recraftv4_1", "openai": "gpt-image-2"}
QUALITY = ["high"]
OPENAI_PRICE = {"low": 0.006, "medium": 0.053, "high": 0.211}   # gpt-image-2 1024x1024, unverified

HUE = {"fire": ("vermilion", "#E8442A"), "water": ("deep blue", "#3F6FE0"), "wood": ("jade green", "#2FBF8A"),
       "metal": ("gold", "#E3B341"), "earth": ("ochre", "#B9772E"), "ice": ("pale cyan", "#7AD7F0"),
       "thunder": ("violet", "#A15CFF"), "wind": ("pale mint", "#A6EBD8"), "phys": ("bone white", "#C9C2B2"),
       "force": ("rose", "#E58FB5"), "chaos": ("magenta", "#E0409A"), "soul": ("lavender white", "#CFC4FF")}

# Style validated by the user on GPT Image 2 (2026-11-12): the whole tile is one hue field, painted concept art, an
# action caught mid-moment, a dark subject against blazing light (art bible 7.2, revised).
STYLE = ("Square game ability icon, semi-realistic painted concept art, cinematic spell-effect still, Chinese xianxia "
         "cultivation theme. The whole square is filled with a rich {hue_name} colour field ({hex}), darker toward the "
         "corners; nearly monochrome, one hue family from deep shadow to blazing white. The subject is caught mid-moment; "
         "solid forms are dark or mid-tone silhouettes cut against intense glowing energy, which is the brightest thing "
         "in the image. Strong bloom, sparks and motion streaks, a dynamic often diagonal composition cropped tight so "
         "the effect fills the frame and runs off its edges. Vivid and luminous, high contrast, readable at 48 pixels. "
         "No text, no letters, no numbers, no border, no frame, no UI, no watermark.")
GLYPH_STYLE = ("Simple bold game status icon of {what}, in its own colours ({hue_name}, {hex}), painterly but very "
               "simple, one shape, centred, strong silhouette readable at 20 pixels, on a plain near-black background "
               "(#0B0D10). No text, no border, no frame, no halo.")

SUBJ = {  # recipe subject -> what to paint (an element phrase is filled in)
    "palm": "an open palm thrusting forward, releasing a burst of {el} energy from its centre",
    "fist": "a clenched fist striking forward with a shockwave of {el} force at the knuckles",
    "sword": "a straight jian sword thrusting diagonally, its blade blazing with {el} light",
    "saber": "a curved dao saber mid-swing leaving a bright crescent trail of {el} light",
    "spear": "a long spear with a leaf-shaped head driving forward, a spiral of {el} energy coiling round the shaft",
    "bow": "a drawn recurve bow with a glowing {el} arrow nocked",
    "needles": "a volley of thin glowing {el} needles flying diagonally in parallel",
    "seal": "a round cultivation seal sigil of interlocking glyph strokes, glowing {el}",
    "talisman": "a yellow paper talisman with brushed red glyphs, its lower edge burning with {el} flame",
    "bell": "a bronze temple bell ringing, rings of {el} sound rippling outward",
    "song": "flowing ribbons of {el} sound with drifting musical notes",
    "hammer": "a heavy war hammer smashing down, shards of {el} stone bursting",
    "mountain": "jagged mountain peaks rising, cracked with {el} light",
    "flame": "a tall living flame of {el} fire",
    "wave": "a cresting ocean wave curling over, foam glowing {el}",
    "cup": "an overflowing jade cup spilling glowing {el} water",
    "sprout": "a seed splitting open with a bright sprout of {el} life",
    "bloom": "a flower bursting into bloom, petals glowing {el}",
    "vine": "a thorny vine lashing like a whip, glowing {el}",
    "root": "gnarled roots gripping the ground, pulsing with {el} light",
    "bolt": "a forked lightning bolt striking down, crackling {el}",
    "cloud": "a dark storm cloud with a {el} lightning bolt falling from it",
    "crystal": "a cluster of sharp ice crystals, glowing {el}",
    "feather": "a single feather sweeping on a gust, edges glowing {el}",
    "swirl": "a spiralling whirlwind of {el} air",
    "stance": "a robed cultivator standing in a martial stance, a {el} aura around the body",
    "dash": "a robed cultivator dashing forward, leaving afterimages and {el} streaks",
    "eye": "a single sinister eye wreathed in {el} curse smoke",
    "lotus": "a glowing lotus flower opening, healing {el} light rising from it",
    "spirit": "a small ghostly spirit companion formed of {el} energy",
    "lance": "a beam-like lance of pure {el} light piercing diagonally",
    "hourglass": "an hourglass with frozen {el} sand suspended mid-fall",
    "chain": "glowing {el} chains snapping taut",
    "shield": "a round warding shield with a glowing {el} sigil",
    "drop": "a single glowing drop of {el} essence",
    "brazier": "a bronze tripod brazier burning with {el} fire",
    "phoenix": "a phoenix rising with spread wings of {el} fire and ash",
    "core": "a glowing golden core orb inside the chest, orbits of {el} energy around it",
    "thread": "a needle trailing a fraying glowing {el} thread",
    "orb": "a glowing orb of {el} energy hurtling forward with a comet tail",
    "tablet": "an ancient stone tablet carved with glowing {el} glyphs",
    "husk": "a hollow empty mask, eye slits glowing {el}",
    "cleave": "a great blade cleaving downward in a wide {el} arc",
    "wedge": "a glowing wedge splitting a stone block with {el} cracks",
    "mantle": "an armoured mantle of {el} plates over the shoulders",
    "scroll": "an unrolled scroll with a glowing {el} pact seal",
    "cairn": "a stack of balanced stones awakening as a guardian, eyes glowing {el}",
    "millstone": "a spinning carved millstone, grinding sparks of {el}",
    "breath": "a cross-legged meditating cultivator drawing a column of {el} breath up from the belly",
    "haze": "rippling heat haze distorting the air around a glowing {el} eye",
    "blood": "a falling drop of blood ringed by {el} energy",
}
EL_WORD = {"fire": "fiery", "water": "watery", "wood": "verdant", "metal": "golden metal", "earth": "earthen",
           "ice": "icy", "thunder": "violet lightning", "wind": "wind", "phys": "pale steel", "force": "rose-coloured force",
           "chaos": "magenta chaos", "soul": "ghostly soul"}
MOD_TXT = {"echo": "with a translucent afterimage echoing it", "quick": "with fast speed streaks",
           "heavy": "with a heavy impact shockwave at its base", "held": "charged and held back, energy gathering",
           "summon": "standing over a faint summoning circle"}
# hand-written subjects where the template is not enough
OVERRIDE = {
    "twin-flame-echo": "two fireballs streaking diagonally from the bottom left to the top right, one close behind the other along the same path; the leading fireball blazing white-yellow, the one behind it a fainter echo, each with its own long fiery trail; no hands, no people",
    "tolling-bell-requiem": "a bronze funeral bell tolling, pale soul wisps spiralling out of its mouth",
    "stilled-instant": "an hourglass encased in ice, its falling sand frozen mid-air",
    "three-step-chase": "a robed cultivator dashing in three fast steps, three fading afterimages behind, wind streaks",
    "hollowing-strike": "a fist punching through a hollow ring of rose-coloured force, the air caving inward",
}
STATUS_TXT = {"bleed": "three drops of blood dripping from a slash wound", "corpse_rot": "rotting green-black miasma rising from a skull",
              "exposed": "a cracked shield with a glowing target mark behind it", "heavy_breath": "laboured breath clouds and a heavy chained chest",
              "leaking_ward": "a cracked ward bubble leaking blue qi", "qi_disruption": "a tangled knot of broken qi lines",
              "sealed_meridian": "glowing meridian lines on a body bound shut by a seal glyph",
              "silence": "a mouth sealed by a paper talisman", "slackened_soul": "a dim soul flame drifting loose from a body",
              "slowed_time": "a clock face with its hands dragged by slow ripples", "stagnation": "still murky water with a stopped whirl",
              "sundered": "a breastplate split in two", "withering": "a withering hand, its flesh drying to grey"}
GLYPHS = {"fire": "a flame", "water": "a water drop", "wood": "a leaf with a curling vine", "metal": "a gold ingot",
          "earth": "a three-layered mountain", "ice": "a six-pointed ice crystal", "thunder": "a lightning bolt",
          "wind": "three curling wind lines"}
TIER_BIND = {0: "plain yellow cloth binding", 1: "dark lacquered binding", 2: "carved jade covers", 3: "gilded gold covers"}


def recipes():
    sys.path.insert(0, HERE)
    import make_icons
    return {r["id"]: r for r in make_icons.load()}


def items(which):
    R = recipes()
    names = {}
    for f in glob.glob(os.path.join(ROOT, "design", "arts", "family-*.json")) + glob.glob(os.path.join(ROOT, "design", "arts", "part-*.json")):
        for a in json.load(open(f, encoding="utf-8")):
            names[a["id"]] = a.get("name", a["id"]).split(" (")[0]
    out = []
    if which in ("arts", "all", "test"):
        for aid, r in R.items():
            el = r["hue"]
            subj = OVERRIDE.get(aid) or SUBJ[r["subject"]].format(el=EL_WORD[el])
            mods = "" if aid in OVERRIDE else ", ".join(MOD_TXT[m] for m in r["mods"] if m in MOD_TXT)
            what = "%s: %s%s" % (names.get(aid, aid), subj, (", " + mods) if mods else "")
            out.append(("art", aid, el, what, STYLE))
    if which in ("techniques", "all", "test"):
        for f in sorted(glob.glob(os.path.join(ROOT, "design", "techniques", "catalogue-*.json"))):
            for t in json.load(open(f, encoding="utf-8")):
                pay = t["abilities"][-1]["ability_id"]
                r = R.get(pay, {"hue": "phys", "subject": "seal"})
                if t["tech_kind"] == "body":
                    what = "%s: a muscular cultivator in a body-refining stance, skin glowing like bronze" % t["name"].split(" (")[0]
                else:
                    what = ("%s: a closed cultivation scripture book with %s, seen at a slight angle, its cover emblem showing %s"
                            % (t["name"].split(" (")[0], TIER_BIND[t["tier"]], SUBJ[r["subject"]].format(el=EL_WORD[r["hue"]])))
                out.append(("tech", t["id"], r["hue"], what, STYLE))
    if which in ("wards", "all", "test"):
        wards = [("common-ward", "phys", "a faint shell of body qi around a meditating silhouette"),
                 ("golden-bell", "metal", "a huge translucent golden bell dome covering a cultivator"),
                 ("black-tortoise-shell", "water", "a black tortoise shell barrier with glowing hexagonal plates"),
                 ("mountain-screen", "earth", "a folding screen of stone mountains standing as a wall"),
                 ("thousand-layer-cloud", "wind", "many layered clouds wrapped around as armour"),
                 ("fire-shunning-veil", "fire", "a shimmering veil parting incoming flames"),
                 ("clear-heart-ward", "soul", "a calm glowing heart inside a protective lotus sigil"),
                 ("soul-guarding-lamp", "soul", "a small lantern whose flame shields a soul wisp"),
                 ("iron-shirt", "phys", "a torso hardened like iron, rivets of light on the skin"),
                 ("surging-tide", "water", "a wall of surging water circling as a barrier"),
                 ("golden-light-shield", "metal", "a radiant round shield of golden light"),
                 ("qi-scattering-robe", "wind", "a flowing robe scattering incoming qi into sparks"),
                 ("flame-quelling-aura", "ice", "a cold aura snuffing out flames around a figure"),
                 ("still-lake-aura", "water", "a perfectly still lake surface as a shield")]
        for wid, el, what in wards:
            out.append(("ward", wid, el, "A protective ward, symmetric and calm, no motion: " + what, STYLE))
    if which in ("statuses", "all", "test"):
        for sid, what in STATUS_TXT.items():
            out.append(("status", sid, "chaos" if sid in ("corpse_rot", "withering") else "phys", what, STYLE))
    if which in ("counters", "all"):
        cs = set()
        for f in glob.glob(os.path.join(ROOT, "design", "arts", "family-*.json")):
            for a in json.load(open(f, encoding="utf-8")):
                for c in a.get("counters", []):
                    cs.add((c["id"], R[a["id"]]["hue"]))
        for cid, el in sorted(cs):
            out.append(("counter", cid, el, "a single small emblem standing for '%s', gathered %s energy" % (cid, EL_WORD[el]), STYLE))
    if which in ("stances", "all"):
        ss = set()
        for f in glob.glob(os.path.join(ROOT, "design", "arts", "family-*.json")):
            for a in json.load(open(f, encoding="utf-8")):
                for s in a.get("states", []):
                    ss.add((s["id"], R[a["id"]]["hue"]))
        for sid, el in sorted(ss):
            out.append(("stance", sid, el, "a robed cultivator holding the '%s' stance, %s aura" % (sid.replace("-", " "), EL_WORD[el]), STYLE))
    if which in ("glyphs", "all", "test"):
        for el, what in GLYPHS.items():
            out.append(("glyph", el, el, what, GLYPH_STYLE))
    if which == "test":
        keep = {("art", x) for x in ("twin-flame-echo", "swelling-tide-palm", "sheathed-edge", "strata-hammer", "harvest-bloom",
                                      "stilled-instant", "chain-arc", "three-step-chase", "tolling-bell-requiem", "hollowing-strike")}
        keep |= {("tech", "red-sun-scripture"), ("tech", "unbroken-flesh-canon"), ("ward", "golden-bell"),
                 ("ward", "black-tortoise-shell"), ("status", "bleed"), ("status", "withering"), ("glyph", "fire")}
        out = [o for o in out if (o[0], o[1]) in keep]
    return out


def prompt_of(kind, iid, el, what, style):
    hn, hx = HUE[el]
    return what + ". " + style.format(hue_name=hn, hex=hx, what=what)


def post(url, body, key, timeout=180):
    req = urllib.request.Request(url, data=json.dumps(body).encode("utf-8"), method="POST",
                                 headers={"Authorization": "Bearer " + key, "Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return json.loads(r.read().decode("utf-8"))


def gen(provider, prompt, n, seed):
    if provider == "recraft":
        body = {"prompt": prompt, "model": MODEL["recraft"], "size": "1:1", "n": n, "style": "any",
                "response_format": "b64_json", "image_format": "png", "random_seed": seed}
        res = post("https://external.api.recraft.ai/v1/images/generations", body, os.environ["RECRAFT_API_TOKEN"])
        out = []
        for d in res.get("data", []):
            if d.get("b64_json"):
                out.append(base64.b64decode(d["b64_json"]))
            elif d.get("url"):
                out.append(urllib.request.urlopen(d["url"], timeout=120).read())
        return out
    body = {"model": MODEL["openai"], "prompt": prompt, "size": "1024x1024", "quality": QUALITY[0], "n": n,
            "output_format": "png", "background": "opaque"}
    res = post("https://api.openai.com/v1/images/generations", body, os.environ["OPENAI_API_KEY"])
    return [base64.b64decode(d["b64_json"]) for d in res.get("data", [])]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--set", default="test")
    ap.add_argument("--provider", default="openai", choices=["recraft", "openai", "both"])
    ap.add_argument("--quality", default="medium", choices=["low", "medium", "high"])
    ap.add_argument("--ids", help="only these icon ids (comma-separated), e.g. the rejects to redo at high")
    ap.add_argument("--tag", default="", help="file suffix for a rerun, e.g. h (saves <id>_h0.png)")
    ap.add_argument("--n", type=int, default=2)
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()
    QUALITY[0] = a.quality
    PRICE["openai"] = OPENAI_PRICE[a.quality]
    its = items(a.set)
    if a.ids:
        want = set(a.ids.split(","))
        its = [i for i in its if i[1] in want]
    provs = ["recraft", "openai"] if a.provider == "both" else [a.provider]
    est = sum(PRICE[p] for p in provs) * a.n * len(its)
    print("plan\t%d icons x %d candidates x %s = %d images, about $%.2f" % (len(its), a.n, "+".join(provs), len(its) * a.n * len(provs), est))
    if a.dry_run:
        for k, iid, el, what, style in its:
            print("prompt\t%s/%s\t%s" % (k, iid, prompt_of(k, iid, el, what, style)))
        return 0
    keys = {"recraft": "RECRAFT_API_TOKEN", "openai": "OPENAI_API_KEY"}
    ready = [p for p in provs if os.environ.get(keys[p])]
    for p in provs:
        if p not in ready:
            print("NOT_ASSESSED\t%s skipped: environment variable %s is not set" % (p, keys[p]))
    if not ready:
        return 2
    log = open(os.path.join(OUTDIR, "log.jsonl"), "a", encoding="utf-8") if os.makedirs(OUTDIR, exist_ok=True) is None else None
    spent, fails = 0.0, 0
    for k, iid, el, what, style in its:
        prompt = prompt_of(k, iid, el, what, style)
        for p in ready:
            d = os.path.join(OUTDIR, p, k)
            os.makedirs(d, exist_ok=True)
            if all(os.path.exists(os.path.join(d, "%s_%s%d.png" % (iid, a.tag, j))) for j in range(a.n)):
                continue
            seed = abs(hash((iid, p))) % 100000
            try:
                imgs = gen(p, prompt, a.n, seed)
            except urllib.error.HTTPError as e:
                body = e.read()[:300].decode("utf-8", "replace")
                print("FAIL\t%s\t%s/%s\tHTTP %d %s" % (p, k, iid, e.code, body))
                fails += 1
                if e.code in (401, 403) or "insufficient_quota" in body or "credit_balance" in body:
                    print("STOPPED\t%s: account or billing problem; nothing more will succeed until it is fixed" % p)
                    return 2
                continue
            except Exception as e:  # network, timeout
                print("FAIL\t%s\t%s/%s\t%s" % (p, k, iid, e))
                fails += 1
                continue
            for j, b in enumerate(imgs):
                open(os.path.join(d, "%s_%s%d.png" % (iid, a.tag, j)), "wb").write(b)
            spent += PRICE[p] * len(imgs)
            log.write(json.dumps({"t": time.time(), "provider": p, "model": MODEL[p], "kind": k, "id": iid, "seed": seed,
                                  "n": len(imgs), "quality": QUALITY[0], "tag": a.tag, "prompt": prompt}) + "\n")
            log.flush()
            print("ok\t%s\t%s/%s\t%d images" % (p, k, iid, len(imgs)))
    print("spent\tabout $%.2f; %d failures" % (spent, fails))
    print("next	python -I tools/asset-pipeline/icons/review.py   (builds the review page)")
    return 1 if fails else 0


def sheet(its, provs, n):
    try:
        from PIL import Image, ImageDraw
    except ImportError:
        print("NOT_ASSESSED\tPillow missing: no pick sheet")
        return
    cell, lab = 160, 230
    W = lab + cell * n * len(provs)
    img = Image.new("RGB", (W, 30 + cell * len(its)), (236, 235, 227))
    dr = ImageDraw.Draw(img)
    for pi, p in enumerate(provs):
        dr.text((lab + pi * cell * n + 6, 8), "%s (%s)" % (p, MODEL[p]), fill=(30, 30, 30))
    for i, (k, iid, el, what, style) in enumerate(its):
        y = 30 + i * cell
        dr.text((6, y + 6), "%s\n%s" % (k, iid), fill=(30, 30, 30))
        for pi, p in enumerate(provs):
            for j in range(n):
                f = os.path.join(OUTDIR, p, k, "%s_%d.png" % (iid, j))
                if os.path.exists(f):
                    im = Image.open(f).convert("RGB").resize((cell - 8, cell - 8), Image.LANCZOS)
                    img.paste(im, (lab + (pi * n + j) * cell + 4, y + 4))
    p = os.path.join(OUTDIR, "pick_sheet.png")
    img.save(p)
    print("sheet\t%s" % p)


if __name__ == "__main__":
    sys.exit(main())
