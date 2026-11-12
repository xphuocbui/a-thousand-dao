"""Build the fight-screen icons (design/art/art-bible.md §7-8) from the art library and the subject library.

Steps: read every signature art (design/arts/family-*.json) and common art (design/arts/part-*.json, tier common),
give each a recipe (subject, hue, family motif, role, modifiers), append the recipes plus the ward and chip calls to
lib.vx.js, render with vex, copy the PNGs to assets/icons/ under id-based names, then validate (§8.5) and write
contact sheets. Emits observations; exits 1 if a check fails, 2 if it could not run.

Run (from the repo root): python -I tools/asset-pipeline/icons/make_icons.py [--only id,id] [--vex PATH]
"""
import argparse
import glob
import json
import os
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
BUILD = os.path.join(HERE, "build")
OUT = os.path.join(ROOT, "assets", "icons")
VEX = os.path.expanduser("~/.claude/skills/vex-vector-art/bin/vex.js")

# Explicit subjects for signature arts: within a family no two share a silhouette (art bible §8.6 item 7).
SUBJECT = {
    # blade
    "debt-blade": "cleave", "flurry-stance": "stance", "pinning-arrow": "needles", "coiling-thrust": "spear",
    "nocked-arrow": "bow", "phantom-sword": "sword", "flying-sword": "lance", "triple-draw": "saber",
    # body
    "marrow-tithe-strike": "blood", "last-breath-fist": "breath", "bulwark-knuckle": "shield", "answering-palm": "palm",
    "rolling-barrage-fist": "fist", "twin-shadow-fist": "spirit", "mountain-root-stance": "stance", "bone-turning-palm": "core",
    # earth
    "strata-hammer": "hammer", "sinking-weight": "seal", "bastion-reprisal": "shield", "quarry-offering": "wedge",
    "stone-warden-call": "cairn", "mountain-stance": "stance", "aftershock-slam": "mountain", "millstone-palm": "millstone",
    # fire
    "scorch-fist": "fist", "blood-fed-pyre": "brazier", "brazier-form": "stance", "furnace-heart": "core",
    "flint-volley": "orb", "twin-flame-echo": "flame", "ash-rebirth": "phoenix", "heat-haze": "haze",
    # force-chaos
    "marrow-siphon-palm": "palm", "hollowing-strike": "fist", "hollow-husk-stance": "husk", "fraying-thread": "thread",
    "gathered-ruin-verdict": "tablet", "ripening-curse": "eye", "bloodletting-rite": "blood", "shearing-palm": "cleave",
    # ice
    "rime-lock-seal": "seal", "shatter-palm": "palm", "deep-winter-form": "stance", "black-ice-glaze": "crystal",
    "stilled-instant": "hourglass", "shattering-mantle": "mantle", "sleet-volley": "needles", "frozen-marrow-pact": "scroll",
    # metal
    "whetstone-pass": "palm", "shatter-edge-cleave": "cleave", "sheathed-edge": "sword", "blood-quench-blade": "saber",
    "needle-rain": "needles", "flying-blade-retinue": "lance", "sundering-wedge": "wedge", "iron-hide-stance": "stance",
    # soul-song-seal
    "tolling-bell-requiem": "bell", "lamp-oil-lance": "lance", "ambush-talisman": "talisman", "frozen-hour-seal": "hourglass",
    "branding-seal": "seal", "marching-dirge": "song", "thorn-lullaby": "lotus", "blood-ink-writ": "scroll",
    # thunder
    "capacitor-palm": "palm", "chain-arc": "chain", "answering-peal": "bolt", "overload-form": "stance",
    "tribulation-seal": "seal", "thunderclap-bind": "eye", "stormcloud-familiar": "cloud", "storm-bank": "orb",
    # water
    "swelling-tide-palm": "wave", "gathering-wave": "swirl", "deep-lake-stance": "stance", "brimming-cup": "cup",
    "drag-of-the-deep": "eye", "seep-through-palm": "palm", "marrow-to-dew": "drop", "backwash-seal": "seal",
    # wind
    "hundred-feather-flurry": "feather", "swallow-stance": "stance", "three-step-chase": "dash", "held-breath": "breath",
    "echo-of-the-dodge": "swirl", "reckless-gale": "blood", "trailing-gale": "haze", "gale-sprite": "spirit",
    # wood
    "seed-of-spring": "sprout", "harvest-bloom": "bloom", "second-spring": "lotus", "rooted-form": "stance",
    "thornling-grove": "spirit", "blight-canker": "eye", "thorn-rain": "needles", "bloodroot-pact": "root",
}
# common arts: keyword first, then the element's default
KEYWORD = [("ledger", "tablet"), ("bolt", "orb"), ("lance", "spear"), ("needle", "needles"), ("whip", "vine"), ("vine", "vine"), ("seal", "seal"),
           ("brand", "seal"), ("ledger", "tablet"), ("palm", "palm"), ("fist", "fist"), ("sword", "sword"), ("cut", "feather"),
           ("saber", "saber"), ("slash", "saber"), ("spear", "spear"), ("hammer", "hammer"), ("heal", "lotus"),
           ("mending", "lotus"), ("sap", "drop"), ("breath", "breath"), ("seed", "sprout"), ("rot", "sprout"), ("spring", "drop"),
           ("thought", "eye"), ("thorn", "eye"), ("wave", "orb"), ("hearth", "brazier"), ("stance", "stance"), ("rain", "needles"),
           ("landslide", "mountain"), ("tremor", "mountain"), ("peal", "bolt"), ("light", "bolt"), ("charge", "core"),
           ("tithe", "blood"), ("leaf", "feather"), ("gust", "swirl"), ("pulse", "wave"), ("restore", "core"), ("wind", "swirl")]
EL_DEFAULT = {"fire": "flame", "earth": "mountain", "water": "wave", "wood": "sprout", "thunder": "bolt", "ice": "crystal",
              "wind": "swirl", "metal": "sword", "": "orb"}
FAMILY_MOTIF = {"blade": "blade", "body": "body", "force-chaos": None, "soul-song-seal": "soul"}


def hue_of(a):
    el = a.get("element") or ""
    if el:
        return el
    tags = set(a.get("tags", []))
    for t, h in (("chaos", "chaos"), ("force", "force"), ("soul", "soul"), ("song", "soul"), ("seal", "soul"),
                 ("talisman", "soul")):
        if t in tags:
            return h
    return "phys"


def recipe(a, fam, common):
    tags = set(a.get("tags", []))
    if common:
        key = (a["id"] + " " + " ".join(tags)).lower()
        subj = next((s for k, s in KEYWORD if k in key), EL_DEFAULT.get(a.get("element") or "", "orb"))
    else:
        subj = SUBJECT[a["id"]]
    hue = hue_of(a)
    motif = FAMILY_MOTIF.get(fam, fam) if not common else (a.get("element") or None)
    if motif is None:
        motif = "chaos" if "chaos" in tags else "force"
    if common and not motif:
        motif = {"force": "force", "chaos": "chaos", "soul": "soul"}.get(hue, "body")
    mods = []
    if tags & {"echo", "afterimage", "twin"} or a["id"].startswith(("twin", "triple", "answering", "echo")):
        mods.append("echo")
    if tags & {"quick", "barrage"} and "echo" not in mods:
        mods.append("quick")
    if "heavy" in tags:
        mods.append("heavy")
    if "held" in tags:
        mods.append("held")
    if a.get("role") == "summon":
        mods.append("summon")
    return {"id": a["id"], "subject": subj, "hue": hue, "motif": motif, "role": a.get("role", "damage"), "mods": mods,
            "tier": "common" if common else "signature"}


def load():
    rec = []
    for f in sorted(glob.glob(os.path.join(ROOT, "design", "arts", "family-*.json"))):
        fam = os.path.basename(f)[7:-5]
        rec += [recipe(a, fam, False) for a in json.load(open(f, encoding="utf-8"))]
    for f in sorted(glob.glob(os.path.join(ROOT, "design", "arts", "part-*.json"))):
        rec += [recipe(a, "common", True) for a in json.load(open(f, encoding="utf-8")) if a.get("tier") == "common"]
    return rec


WARDS = [("resist", "water", "shield"), ("shield", "ice", "core"), ("default", "phys", "seal")]
ELEMENTS = ["fire", "water", "wood", "metal", "earth", "ice", "thunder", "wind"]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--only")
    ap.add_argument("--vex", default=VEX)
    a = ap.parse_args()
    if not os.path.exists(a.vex):
        print("NOT_ASSESSED\tvex not found at %s (the vex-vector-art skill)" % a.vex)
        return 2
    rec = load()
    if a.only:
        keep = set(a.only.split(","))
        rec = [r for r in rec if r["id"] in keep]
    os.makedirs(BUILD, exist_ok=True)
    lib = open(os.path.join(HERE, "lib.vx.js"), encoding="utf-8").read()
    calls = ["artIcon(%s)" % json.dumps(r) for r in rec]
    if not a.only:
        calls += ["wardIcon(%s, %s, %s)" % tuple(json.dumps(x) for x in w) for w in WARDS]
        calls += ["chip(%s, %s)" % (json.dumps(k), json.dumps(e)) for k in ("buff", "debuff") for e in ELEMENTS]
    src = os.path.join(BUILD, "icons.vx.js")
    open(src, "w", encoding="utf-8", newline="\n").write(lib + "\n// ---- generated by make_icons.py\n" + "\n".join(calls) + "\n")
    json.dump(rec, open(os.path.join(BUILD, "recipes.json"), "w", encoding="utf-8"), indent=1)
    r = subprocess.run(["node", a.vex, "build", src, "--out", os.path.join(BUILD, "out"), "--scales", "1,2", "--no-preview"],
                       capture_output=True, text=True)
    errs = [l for l in (r.stdout + r.stderr).splitlines() if "rror" in l]
    for l in errs[:20]:
        print("VEX\t" + l)
    if r.returncode != 0:
        print("NOT_ASSESSED\tvex exited %d" % r.returncode)
        return 2
    sp = os.path.join(BUILD, "out", "sprites")
    for d in ("arts", "wards", "status"):
        os.makedirs(os.path.join(OUT, d), exist_ok=True)
    n = 0
    for f in os.listdir(sp):
        if not f.endswith(".png"):
            continue
        base = f[:-4]
        two = base.endswith("@2x")
        stem = base[:-3] if two else base
        if stem.startswith("art_"):
            dst = os.path.join(OUT, "arts", stem + ("@256" if two else "") + ".png")
        elif stem.startswith("ward_"):
            if two:
                continue
            dst = os.path.join(OUT, "wards", stem + ".png")
        elif stem.startswith(("buff_", "debuff_")):
            if two:
                continue
            dst = os.path.join(OUT, "status", stem + ".png")
        else:
            continue
        shutil.copyfile(os.path.join(sp, f), dst)
        n += 1
    print("copied\t%d files to %s" % (n, OUT))
    return validate(rec, full=not a.only)


def validate(rec, full):
    try:
        from PIL import Image
    except ImportError:
        print("NOT_ASSESSED\tPillow missing: sizes, border alpha and contact sheets not checked")
        return 2
    bad = 0
    want = [("arts", "art_%s.png" % r["id"].replace("-", "_"), 128) for r in rec]
    want += [("arts", "art_%s@256.png" % r["id"].replace("-", "_"), 256) for r in rec]
    if full:
        want += [("wards", "ward_%s.png" % w[0], 96) for w in WARDS]
        want += [("status", "%s_%s.png" % (k, e), 48) for k in ("buff", "debuff") for e in ELEMENTS]
    for d, name, size in want:
        p = os.path.join(OUT, d, name)
        if not os.path.exists(p):
            print("MISSING\t%s/%s" % (d, name))
            bad += 1
            continue
        im = Image.open(p).convert("RGBA")
        if im.size[0] != size or abs(im.size[1] - size) > 4:
            print("SIZE\t%s/%s is %dx%d, want %d" % (d, name, im.size[0], im.size[1], size))
            bad += 1
    # contact sheets: 50 px colour and greyscale, by family order
    arts = [os.path.join(OUT, "arts", "art_%s.png" % r["id"].replace("-", "_")) for r in rec]
    arts = [p for p in arts if os.path.exists(p)]
    cols = 16
    for mode in ("color", "grey"):
        rows = (len(arts) + cols - 1) // cols
        sheet = Image.new("RGBA", (cols * 54 + 4, rows * 54 + 4), (236, 235, 227, 255))
        for i, p in enumerate(arts):
            im = Image.open(p).convert("RGBA").resize((50, 50), Image.LANCZOS)
            if mode == "grey":
                im = im.convert("LA").convert("RGBA")
            sheet.alpha_composite(im, (4 + (i % cols) * 54, 4 + (i // cols) * 54))
        sheet.save(os.path.join(BUILD, "contact_%s.png" % mode))
    print("contact\t%s" % os.path.join(BUILD, "contact_color.png"))
    print("checked %d files, %d findings" % (len(want), bad))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
