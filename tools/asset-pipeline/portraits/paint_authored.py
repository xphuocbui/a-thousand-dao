"""Authored art prompts (design/world/depth/art/README.md; user 2026-11-25: every portrait and place prompt is
authored for that person or place).

Portraits are the existing cast style block (gen_portraits.STYLE), then the sect's dress sheet
(design/world/depth/art/dress.json), then the person's hand-written subject paragraph
(design/world/depth/art/portraits/<batch>.json).

Places use the existing place-art base prompt (tools/asset-pipeline/map/prompts/place-base.md) with the authored
look and art_brief and a kind override (design/world/depth/art/places/<batch>.json), painted into the real map crop.
The crop is the same view as place_art.py plan; it is made here when missing.

Everything is written to separate folders, so no existing portrait, painting, sprite or game asset is touched:
  portraits: tools/asset-pipeline/portraits/out/authored/<batch>/<key>.png (+ -meta.json)
  places:    design/world/depth/art/places/out/<batch>/paint_<id>.png (+ prompt_<id>.md, in_<id>.png)
Nothing is installed into assets/ (installing is a later step, after the user's review).

usage (repo root):
  python -I tools/asset-pipeline/portraits/paint_authored.py prompts <batch>   write the assembled prompts for review
  python -I tools/asset-pipeline/portraits/paint_authored.py paint <batch> [--jobs 4]   paint what is not yet painted
The key comes only from OPENAI_API_KEY.
"""
import concurrent.futures
import glob
import importlib.util
import json
import os
import subprocess
import sys

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
ART = os.path.join(ROOT, "design", "world", "depth", "art")
spec = importlib.util.spec_from_file_location("gen_portraits", os.path.join(HERE, "gen_portraits.py"))
gp = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gp)

# How the portrait is used (art bible sections 1 and 3; the UI specs): added after the unchanged style block so the
# authored portraits keep the existing cast's look.
USAGE = ("How it is used: this is one person's own portrait in the game's character window, shown large in a carved "
         "rosewood and brass frame, and also cropped to a small round medallion about 36 pixels across in rankings, "
         "tooltips and on the map. So the face must read at that small size: the head and shoulders form a clear "
         "silhouette, the face is lit, and the one or two things that make this person recognisable are big and simple, "
         "not fine detail. The clothing's cut and collar shows at a glance what they are (a sect disciple, a loose "
         "cultivator in a travel cloak, a mortal in work clothes). "
         "Cultivators are never ragged: no worn, frayed or patched clothes unless the person's story calls for it. "
         "No numbers, writing or symbols that could read as text.")
# The xianxia style (user 2026-11-26: the old cast portraits' clothing and light felt more xianxia; the authored ones
# read as wuxia). Used instead of gen_portraits.STYLE for people whose entry has "style": "xianxia".
XIANXIA_STYLE = (
    "A single painted character portrait for a historical grand-strategy game set in an original Chinese cultivation "
    "(xianxia) world of immortal cultivators. Chest-up, three-quarter view, eyes alive. Refined semi-realistic oil "
    "painting with soft, visible brushwork, in the manner of a luminous xianxia illustration: soft ethereal light on "
    "the face as if lit by moonlight or spirit-light, a gentle glowing rim light, a dark painterly background with "
    "drifting mist and faint motes of light. East Asian features (Vietnamese and Chinese). Cultivators dress as the "
    "immortals of a xianxia world: flowing, layered hanfu of silk and spirit-woven gauze, two or three crossed collars "
    "showing at the neck, wide sleeves that fall in long folds, borders embroidered with clouds, cranes, waves or "
    "flames, sashes hung with jade pendants and tassels, long hair dressed with jade or silver hairpins, a small crown "
    "or ribbons; clear, rich colours. Even a junior disciple's robe is graceful silk; only a mortal wears plain cotton. "
    "Power may show where it suits the person: a soft aura, wisps of qi or floating motes in the colour of their "
    "element, stronger for the stronger, but not in every portrait. Not wuxia: no rough leather, no work aprons, no "
    "gritty realism unless the person's story asks for it. No armour unless asked. No text, no letters, no frame, no "
    "border, no watermark, no signature; the figure fills the picture, head in the upper third.")
SEX = {"m": "a man", "f": "a woman"}
MEMORIAL = " Painted as a memorial portrait of someone long dead: slightly faded, as on old silk."
PLACE_QUALITY, PLACE_SIZE = "low", "1536x864"   # user 2026-11-25: low on all
PX, VIEW = 12, (40, 22.5)   # as place_art.py


def load(p):
    return json.load(open(p, encoding="utf-8"))


# Rank and realm, read from the cast record and added to every xianxia prompt (user 2026-11-26: a sect's cast wears a
# uniform; higher realms look more powerful, with better clothes, treasures and aura).
RANK = {"tap_dich": "a servant of the sect", "ngoai_mon": "an outer disciple", "noi_mon": "an inner disciple",
        "chan_truyen": "a true disciple", "chap_su": "a steward", "truong_lao": "an elder", "thai_thuong": "a grand elder",
        "tong_chu": "the head of the sect", "founder": "the founder of the sect", "last_head": "a former head",
        "retired_head": "a retired head", "khach_khanh": "a guest elder", "war_marshal": "a war marshal",
        "former_officer": "a former officer"}
REALM_LOOK = {
    "luyen_khi": "Realm: Luyện Khí, a beginner. Their clothes are the plain version of what their rank wears, with "
                 "little ornament, and they show no aura beyond a faint calm.",
    "truc_co": "Realm: Trúc Cơ, a foundation-built cultivator. Finer cloth and one good ornament such as a jade pendant "
               "or a silver hairpin; now and then a faint shimmer of their element's qi.",
    "ket_dan": "Realm: Kết Đan, a golden-core master. Rich robes with heavy embroidery, jewelled hairpins or a small "
               "crown, their spirit weapon or treasure clearly in view; visible wisps of qi in their element's colour "
               "curl around them.",
    "nguyen_anh": "Realm: Nguyên Anh, a great master whose word moves a sect. Splendid layered robes of the finest "
                  "spirit silk, a crown, treasures that glow with their own light; a strong aura in their element's "
                  "colour fills the air around them, and their presence is imposing.",
    "hoa_than": "Realm: Hóa Thần, all but beyond the mortal world. Radiant, ethereal robes that seem woven of light; a "
                "vast aura in their element's colour; the air itself seems to bend around them.",
}
ELEMENT_COLOUR = {"kim": "silver-white", "moc": "jade green", "thuy": "deep blue", "hoa": "red-gold", "tho": "ochre gold",
                  "bang": "ice blue", "loi": "violet", "phong": "pale silver-green", "am": "dark violet",
                  "quang": "golden white", "hon": "shifting many-coloured"}
_CAST = {}


def cast_record(key):
    if not _CAST:
        for f in glob.glob(os.path.join(ROOT, "design", "world", "depth", "**", "*.cast.json"), recursive=True):
            for p in load(f)["people"]:
                _CAST[p["key"]] = p
    return _CAST.get(key, {})


def rank_realm(person):
    rec = cast_record(person["key"])
    out = []
    rank = RANK.get(rec.get("rank") or "")
    if rank and rec.get("sect"):
        out.append("Rank: %s. They wear the sect's uniform in the version for their rank (see the sect's dress), "
                   "with their own touches." % rank)
    realm = rec.get("realm") or rec.get("peak_realm")
    root = rec.get("root") or {}
    pure = dict(root.get("elements") or {}, **(root.get("variants") or {}))
    if realm in REALM_LOOK:
        colour = (" Their element's colour is %s." % ELEMENT_COLOUR.get(max(pure, key=pure.get), "pale")) if pure else ""
        out.append(REALM_LOOK[realm] + colour)
    elif not pure:
        out.append("A mortal or someone with no cultivation to speak of: no aura, plain but clean clothes.")
    return " ".join(out)


def portrait_prompt(person, dress):
    sheet = dress.get(person["dress"]) if person.get("dress") else None
    xianxia = person.get("style") == "xianxia"
    text = (XIANXIA_STYLE if xianxia else gp.STYLE) + "\n\n" + USAGE
    if sheet:
        text += "\n\nThe sect's dress: " + sheet
    if xianxia and person.get("rank_realm"):   # off by default: the user preferred v1 without these lines (2026-11-26)
        rr = rank_realm(person)
        if rr:
            text += "\n\n" + rr
    text += "\n\nThe subject, %s who looks about %d: %s" % (SEX[person["sex"]], person["age"], person["subject"])
    if person.get("memorial"):
        text += MEMORIAL
    return text


PLACE_STYLE = ("A painted illustration of one place in an original Chinese cultivation (xianxia) world, for a historical "
               "grand-strategy game. Seen from high above at a steep aerial angle, as a bird circling overhead would see "
               "it, so that the whole place and its setting fill the frame. The place is painted at its true, grand, "
               "scale, and cultivators build with magic: a great sect is a domain kilometres across that houses thousands of "
               "people (disciples, servants, artisans, mortal families), with hundreds of buildings, palace-sized halls, "
               "whole mountainsides carved into terraces, towers taller than any mortal could raise, and works no mortal "
               "could build; a minor sect is a walled settlement of dozens to a hundred buildings; a city has walls, "
               "districts and tens of thousands of roofs; a village has all its houses, yards and fields. It is never a "
               "miniature, a model or a small compound. Refined semi-realistic painting with soft visible brushwork, rich natural colour, "
               "golden-hour light from the upper left with long soft shadows to the lower right, matching the game's "
               "painted relief map. No text, labels, banners with writing, flags with symbols, frame, border or "
               "watermark; people appear only as tiny figures that show the scale.")
PLACE_USAGE = ("How it is used: this is the place's own picture, shown as the wide banner at the top of its window in a "
               "carved wood frame. It must read at a glance as this one place and no other, with its signature feature "
               "large and clear.")


def place_prompt(place, base=None):
    return "\n\n".join([PLACE_STYLE, PLACE_USAGE, place["subject"]])


def place_crop(pid, dst):
    if os.path.exists(dst):
        return
    src = os.path.join(ROOT, "design/map/continent-11/art/places/in_%d.png" % pid)
    if os.path.exists(src):
        Image.open(src).save(dst)
        return
    cont = load(os.path.join(ROOT, "assets/data/world_continent.json"))
    tx, ty = next(p["tile"] for p in cont["places"] if p["id"] == pid)
    near = Image.open(os.path.join(ROOT, "assets/map/map_near_relief.jpg")).convert("RGB")
    cx, cy = (tx + 0.5) * PX, (ty + 0.5) * PX
    w, h = VIEW[0] * PX, VIEW[1] * PX
    x0, y0 = int(round(cx - w / 2)), int(round(cy - h / 2))
    near.crop((x0, y0, x0 + int(w), y0 + int(h))).resize((1536, 864), Image.BICUBIC).save(dst)


def main():
    cmd, batch = sys.argv[1], sys.argv[2]
    jobs = int(sys.argv[sys.argv.index("--jobs") + 1]) if "--jobs" in sys.argv else 4
    dress = load(os.path.join(ART, "dress.json"))
    for f in sorted(glob.glob(os.path.join(ART, "portraits", "*-dress.json"))):
        dress.update({k: v for k, v in load(f).items() if not k.startswith("_")})

    def gather(kind, field):
        # a batch is either <kind>/<batch>.json or a folder <kind>/<batch>/ of json files (one per sect or chunk)
        one = os.path.join(ART, kind, batch + ".json")
        files = [one] if os.path.exists(one) else sorted(glob.glob(os.path.join(ART, kind, batch, "*.json")))
        return [x for f in files for x in load(f)[field]]
    people = gather("portraits", "people")
    places = gather("places", "places")
    base = open(os.path.join(ROOT, "tools/asset-pipeline/map/prompts/place-base.md"), encoding="utf-8").read()
    pout = os.path.join(gp.OUT, "authored", batch)
    lout = os.path.join(ART, "places", "out", batch)
    if cmd == "prompts":
        lines = ["# Assembled prompts: %s" % batch, "",
                 "Generated by tools/asset-pipeline/portraits/paint_authored.py from design/world/depth/art/. "
                 "The style block is the same for every portrait and is shown once.", "",
                 "## The portrait style block (unchanged from the existing cast)", "", gp.STYLE, "",
                 "## The usage block (new, after the style block)", "", USAGE, "",
                 "## The place style block (every place)", "", PLACE_STYLE, "", PLACE_USAGE, ""]
        head = gp.STYLE + "\n\n" + USAGE
        for p in people:
            full = portrait_prompt(p, dress)
            lines += ["## Portrait: %s" % p["key"], ""]
            if p.get("imagined"):
                lines += ["*Imagined (not sent):* " + p["imagined"], ""]
            h = (XIANXIA_STYLE if p.get("style") == "xianxia" else gp.STYLE) + "\n\n" + USAGE
            lines += [full[len(h):].strip(), ""]
        for p in places:
            lines += ["## Place %d: %s" % (p["id"], p["name"]), "", "*Where (from the record and the map crop):* " + p["where"], "",
                      "*Imagined (not sent):* " + p.get("imagined", ""), "", p["subject"], ""]
        out = os.path.join(ART, batch + "-prompts.md")
        open(out, "w", encoding="utf-8").write("\n".join(lines))
        print("wrote %s: %d portraits, %d places" % (os.path.relpath(out, ROOT), len(people), len(places)))
        return
    if cmd == "paint":
        os.makedirs(pout, exist_ok=True)
        os.makedirs(lout, exist_ok=True)
        todo = [p for p in people if not os.path.exists(os.path.join(gp.OUT, "authored", batch, p["key"] + ".png"))]
        with concurrent.futures.ThreadPoolExecutor(jobs) as ex:
            for key, res in ex.map(lambda p: gp.paint(p["key"], portrait_prompt(p, dress), os.path.join("authored", batch)), todo):
                print("portrait", key, res, flush=True)
        # medium-quality copies for comparison (also_medium), painted after the low pass
        med = [p for p in people if p.get("also_medium")
               and not os.path.exists(os.path.join(gp.OUT, "authored", batch, p["key"] + "__medium.png"))]
        if med:
            gp.QUALITY = "medium"
            with concurrent.futures.ThreadPoolExecutor(jobs) as ex:
                for key, res in ex.map(lambda p: gp.paint(p["key"] + "__medium", portrait_prompt(p, dress),
                                                          os.path.join("authored", batch)), med):
                    print("portrait", key, res, flush=True)
            gp.QUALITY = "low"
        todo_pl = [p for p in places if not os.path.exists(os.path.join(lout, "paint_%d.png" % p["id"]))]
        gp.QUALITY, gp.SIZE = PLACE_QUALITY, PLACE_SIZE
        for p in todo_pl:
            open(os.path.join(lout, "prompt_%d.md" % p["id"]), "w", encoding="utf-8").write(place_prompt(p))
        with concurrent.futures.ThreadPoolExecutor(jobs) as ex:
            for key, res in ex.map(lambda p: gp.paint("paint_%d" % p["id"], place_prompt(p),
                                                      os.path.relpath(lout, gp.OUT)), todo_pl):
                print("place", key, res, flush=True)
        gp.QUALITY, gp.SIZE = "low", "1024x1536"
        return
    sys.exit("unknown command " + cmd)


if __name__ == "__main__":
    main()
