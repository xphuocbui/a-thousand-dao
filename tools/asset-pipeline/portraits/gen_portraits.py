"""Painted character portraits (user decision 2026-11-24: "Set + special characters").

Two sets, both painted by OpenAI's image model at low quality (memory: image-quality-low) from prompts built here:
  type  - one portrait per (sex, look age, attire, tier) combination, plus extra variants for the commonest one
          (loose cultivators of the low realms); every ordinary NPC is given one by PortraitPicker in the game.
  cast  - one portrait per person of the fixed cast (assets/data/world_history.json people), briefed from their record.
Each painting is saved full size under tools/asset-pipeline/portraits/out/<set>/ with its prompt, and a 400x600 webp
copy is written to assets/portraits/<set>/<key>.webp with assets/portraits/portraits.json (keys and prompts).

Usage (repo root):  python -I tools/asset-pipeline/portraits/gen_portraits.py <set: test|type|cast|all> [--dry] [--jobs 6]
The key comes only from OPENAI_API_KEY. Already-painted keys are skipped (re-run to fill gaps).
"""
import base64, concurrent.futures, io, json, os, sys, time, urllib.error, urllib.request
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
OUT = os.path.join(HERE, "out")
GAME = os.path.join(ROOT, "assets", "portraits")
MODEL, QUALITY, SIZE = "gpt-image-2", "low", "1024x1536"
PRICE_LOW = 0.01   # USD per low 1024x1536 image, an estimate (round 3 measured 120 output image tokens per 1536x864)

STYLE = ("A single painted character portrait for a historical grand-strategy game set in an original Chinese "
         "cultivation (xianxia) world. Chest-up, three-quarter view, facing slightly left, eyes alive. Refined "
         "semi-realistic oil painting with visible soft brushwork, warm key light from the upper left and a gentle rim "
         "light, a dark softly blurred painterly background in muted tones that suit the costume. East Asian features "
         "(Vietnamese and Chinese). Period-accurate hanfu-style cultivator clothing, no armour unless asked. No text, no "
         "letters, no frame, no border, no watermark, no signature; the figure fills the picture, head in the upper third.")

SEX = {"m": "a man", "f": "a woman"}
LOOK = {"youth": "who looks about 18 to 24", "prime": "who looks about 30 to 40", "elder": "who looks about 60 to 70, grey-haired"}
TIER = {"low": "a plain, practical outfit of a junior cultivator; a faint calm about them",
        "high": "rich layered robes with fine embroidery and a jade or silver ornament; a quiet, heavy presence and a faint glow of qi around the shoulders"}
# great sects: colours and motifs from their names and elements (world_continent.json great_sects)
ATTIRE = {
    "loose": "a wandering loose cultivator: weathered hemp or cotton travelling clothes in grey, brown or faded indigo, a cloth sash",
    "thien_xu": "a disciple of the Sect of the Heavenly Pivot: white and pale gold robes with ochre trim and a star-pivot emblem",
    "tung_dao": "a disciple of the Palace of the Pine Waves: deep pine-green robes with wave-blue trim and a pine-needle pattern",
    "lac_ha": "a disciple of the Sect of the Drifting Sunset Clouds: soft rose and amber robes like evening clouds, earthy brown sash",
    "thinh_vu": "a disciple of the Tower Where One Listens to the Rain: rain-grey and slate-blue robes, silver thread like falling rain",
    "bang_tam": "a disciple of the Pavilion of the Ice Heart: white and pale ice-blue robes, frost-white fur at the collar",
    "thuy_vi": "a disciple of the Sect of the Emerald Haze: blue-green jade robes, misty white under-robe, herb-leaf embroidery",
    "phuong_minh": "a disciple of the Palace of the Phoenix's Call: vermilion and gold robes with phoenix-feather embroidery",
    "minor_chinh": "a disciple of a small righteous sect: neat robes in muted blue or green with a simple sect badge",
    "minor_trung": "a member of a small neutral sect or trading house: practical robes in brown, teal or grey with a guild token",
    "minor_ma": "a member of a small demonic (ma đạo) sect: dark crimson and black robes, a cold sly look",
}
VARIANTS = {("loose", "low"): 3}   # the commonest group gets extra faces


def type_keys():
    out = []
    for sex in SEX:
        for look in LOOK:
            for att in ATTIRE:
                for tier in TIER:
                    for v in range(VARIANTS.get((att, tier), 1)):
                        out.append("%s_%s_%s_%s_%d" % (sex, look, att, tier, v))
    return out


def type_prompt(key):
    sex, look, att, tier, v = _split(key)
    extra = ["", " A different face and build from the usual: thinner, sharper features.", " A different face and build: broad, sturdy, a scar or a weathered look."][int(v)]
    return "%s\n\nThe subject: %s %s, %s; %s.%s" % (STYLE, SEX[sex], LOOK[look], ATTIRE[att], TIER[tier], extra)


def _split(key):
    sex, look, rest = key.split("_", 2)
    rest, v = rest.rsplit("_", 1)
    att, tier = rest.rsplit("_", 1)
    return sex, look, att, tier, v


REALM = {"luyen_khi": ("Luyện Khí (qi refining)", 120), "truc_co": ("Trúc Cơ (foundation)", 200), "ket_dan": ("Kết Đan (golden core)", 500),
         "nguyen_anh": ("Nguyên Anh (nascent soul)", 1000), "hoa_than": ("Hóa Thần (spirit transformation)", 2000)}


def cast_people():
    h = json.load(open(os.path.join(ROOT, "assets/data/world_history.json"), encoding="utf-8"))
    cont = json.load(open(os.path.join(ROOT, "assets/data/world_continent.json"), encoding="utf-8"))
    sects = {s["key"]: s for s in cont["great_sects"] + cont["minor_sects"]}
    return h["start_year"], h["people"], sects


def cast_prompt(p, year, sects):
    realm = p.get("realm") or p.get("peak_realm") or "ket_dan"
    rname, life = REALM.get(realm, REALM["ket_dan"])
    age = (int(p["died"]) if not p.get("alive", True) and p.get("died") is not None else year) - int(p.get("born", year - 30))
    looks = int(18 + 50 * min(1.0, max(0.0, age / life)))
    s = sects.get(p.get("sect", ""), None)
    if s is None:
        dress = ATTIRE["loose"] if realm in ("luyen_khi", "truc_co") else "a solitary master's robes, plain but of fine cloth"
    elif s["key"] in ATTIRE:
        dress = ATTIRE[s["key"]]
    else:
        al = {"chính đạo": "minor_chinh", "trung lập": "minor_trung", "ma đạo": "minor_ma"}.get(s.get("alignment", ""), "minor_trung")
        dress = ATTIRE[al] + "; the sect's craft: " + str(s.get("craft", ""))
    tier = TIER["high"] if realm in ("ket_dan", "nguyen_anh", "hoa_than") else TIER["low"]
    tr = p.get("traits", {})
    pers = ", ".join(str(t).lower() for t in tr.get("personality", []))
    who = "%s (%s), %s%s" % (p.get("name", p.get("name_hv", "")), p.get("gloss", ""), p.get("role", ""),
                             ("; temperament: " + pers + (", a " + str(tr["calling"]).lower() if tr.get("calling") else "")) if pers else "")
    return ("%s\n\nThe subject: %s who looks about %d (a cultivator of the %s realm, %d years old; cultivators age slowly). "
            "Costume: %s; %s. The person: %s. Let the name's meaning colour the mood and palette.%s") % (
        STYLE, SEX["f" if p.get("sex") == "F" else "m"], looks, rname, age, dress, tier, who,
        " Painted as a memorial portrait of someone long dead: slightly faded, as on old silk." if not p.get("alive", True) else "")


def paint(key, prompt, folder):
    full = os.path.join(OUT, folder, key + ".png")
    if os.path.exists(full):
        return key, "skip"
    body = json.dumps({"model": MODEL, "prompt": prompt, "n": 1, "size": SIZE, "quality": QUALITY}).encode()
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
        except Exception as e:   # timeouts
            if attempt < 2:
                continue
            return key, "error %s" % e
    raw = base64.b64decode(r["data"][0]["b64_json"])
    os.makedirs(os.path.dirname(full), exist_ok=True)
    open(full, "wb").write(raw)
    json.dump({"prompt": prompt, "usage": r.get("usage"), "model": MODEL, "quality": QUALITY, "size": SIZE},
              open(full[:-4] + "-meta.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    return key, "ok"


def install(folder, keys):
    os.makedirs(os.path.join(GAME, folder), exist_ok=True)
    n = 0
    for k in keys:
        src = os.path.join(OUT, folder, k + ".png")
        dst = os.path.join(GAME, folder, k + ".webp")
        if os.path.exists(src) and not os.path.exists(dst):
            Image.open(src).convert("RGB").resize((400, 600), Image.LANCZOS).save(dst, "WEBP", quality=86, method=6)
            n += 1
    return n


def main():
    which = sys.argv[1]
    dry = "--dry" in sys.argv
    jobs = int(sys.argv[sys.argv.index("--jobs") + 1]) if "--jobs" in sys.argv else 6
    year, people, sects = cast_people()
    work = []
    if which in ("type", "all"):
        work += [("type", k, type_prompt(k)) for k in type_keys()]
    if which in ("cast", "all"):
        work += [("cast", p["key"], cast_prompt(p, year, sects)) for p in people]
    if which == "test":
        work = [("type", "m_youth_loose_low_0", type_prompt("m_youth_loose_low_0")),
                ("type", "f_prime_thuy_vi_high_0", type_prompt("f_prime_thuy_vi_high_0")),
                ("type", "m_elder_minor_ma_high_0", type_prompt("m_elder_minor_ma_high_0"))]
        work += [("cast", p["key"], cast_prompt(p, year, sects)) for p in people if p["key"] in ("ngu_lam_son", "phung_yen_ha")]
    todo = [w for w in work if not os.path.exists(os.path.join(OUT, w[0], w[1] + ".png"))]
    print("%d portraits, %d to paint, about $%.2f" % (len(work), len(todo), len(todo) * PRICE_LOW))
    if dry:
        for w in work[:3]:
            print("---", w[0], w[1], "\n" + w[2])
        return
    with concurrent.futures.ThreadPoolExecutor(jobs) as ex:
        for key, res in ex.map(lambda w: paint(w[1], w[2], w[0]), todo):
            if res != "ok":
                print(key, res, flush=True)
    for folder in ("type", "cast"):
        install(folder, [w[1] for w in work if w[0] == folder])
    # the index the game reads: every installed key with its group fields
    idx = {"_doc": "Painted portraits (tools/asset-pipeline/portraits/gen_portraits.py). type: key = sex_look_attire_tier_variant; "
                   "cast: key = world_history.json people key. Files: assets/portraits/<set>/<key>.webp (400x600).",
           "type": sorted(f[:-5] for f in os.listdir(os.path.join(GAME, "type")) if f.endswith(".webp")) if os.path.isdir(os.path.join(GAME, "type")) else [],
           "cast": sorted(f[:-5] for f in os.listdir(os.path.join(GAME, "cast")) if f.endswith(".webp")) if os.path.isdir(os.path.join(GAME, "cast")) else []}
    json.dump(idx, open(os.path.join(GAME, "portraits.json"), "w", encoding="utf-8"), indent=1, ensure_ascii=False)
    print("installed: type %d, cast %d" % (len(idx["type"]), len(idx["cast"])))


if __name__ == "__main__":
    main()
