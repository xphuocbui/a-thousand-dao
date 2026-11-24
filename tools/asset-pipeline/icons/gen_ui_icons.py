"""Small painted UI icons for the illustrated windows' tiles (user 2026-11-24: the round-3 mock-ups' Thiên phú and sect
fact-tile icons). Same medallion grammar as the trait icons (gen_traits.py) with a brass rim and a dark ink field, so
tiles read as one family; painted by OpenAI's image model at low quality.

Masters: tools/asset-pipeline/icons/ai/openai/ui/<key>.png (git-ignored with ai/). Game copies: assets/icons/ui/<key>.png
at 128 px with transparent corners. Usage (repo root): python -I tools/asset-pipeline/icons/gen_ui_icons.py [--dry]
"""
import base64, concurrent.futures, json, os, sys, time, urllib.error, urllib.request
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
OUT = os.path.join(HERE, "ai", "openai", "ui")
GAME = os.path.join(ROOT, "assets", "icons", "ui")
STYLE = ("A single round medallion icon for a historical grand-strategy game set in an original Chinese cultivation (xianxia) "
         "world, seen flat and straight-on, filling the square, on a plain pure black background. The medallion has a polished "
         "brass rim with a fine key-fret engraving and a smooth deep ink-blue enamel field; in its centre one bold, simple, "
         "instantly readable symbol: %s. Refined semi-realistic painting, crisp edges, strong contrast so it reads at 32 pixels, "
         "one clear silhouette, gentle light from the upper left. No text, no letters, no characters, no numbers, no watermark.")
SUBJECT = {
    # Thiên phú (character_attributes.json thien_phu)
    "tp_ngo_tinh": "a glowing lightbulb-like lotus bud opening above an open scroll (insight)",
    "tp_can_cot": "a strong white bone crossed with a jade bracer (physique)",
    "tp_than_hon": "a pale blue spirit flame shaped like a calm face (soul strength)",
    "tp_khi_van": "a golden carp leaping through a ring of auspicious clouds (fortune)",
    "tp_dao_tam": "a still white heart inside a yin-yang ring (Dao heart)",
    "tp_mi_luc": "a red peony blossom with a faint glow (presence and charm)",
    # sect fact tiles
    "sect_founded": "an engraved stone stele on a tortoise base (founding)",
    "sect_members": "three robed disciple silhouettes standing in a row (members)",
    # tie kinds (ui_windows.json tie_kinds; the Relationships cards' badges, weak-point review 2026-11-24: no emoji)
    "tie_kin": "a family tree of three linked roots (kin)",
    "tie_master": "a master's hand guiding a brush over a scroll (master)",
    "tie_disciple": "a kneeling student holding up a tea cup (disciple)",
    "tie_ket_nghia": "three wine cups raised together under a peach blossom (sworn siblings)",
    "tie_dao_lu": "two cranes dancing face to face (Dao companions)",
    "tie_companion": "two travellers' straw hats side by side (companion)",
    "tie_friend": "two clasped hands (friend)",
    "tie_rival": "two crossed swords point to point (rival)",
    "tie_debt": "a red cord tied around a jade token (debt of gratitude)",
    "tie_enmity": "a dark storm cloud with a crack of red (enmity)",
    "tie_feud": "a blood-red dagger over a broken jade ring (blood feud)",
    # Z2 window buttons (weak-point review 2026-11-24 #7: icon + letter tiles)
    "win_character": "a cultivator's head and shoulders in a topknot, in profile (character)",
    "win_inventory": "a cloth storage pouch tied with a cord, a faint glow at its mouth (inventory)",
    "win_relationships": "two figures joined by a red thread (relationships)",
    "win_sect": "a mountain gate with a curved tiled roof (sect)",
    "win_provinces": "a folded map with a boundary line and a seal (province)",
    "win_rankings": "a vertical jade ranking tablet with three steps (rankings)",
    "win_places": "a pagoda beside a winding road marker (places)",
    "win_dao_do": "a star chart of linked glowing nodes in a circle (the Dao chart)",
    "win_abode": "a cave mouth in a cliff with a small door and a lantern (cave abode)",
}


def paint(key):
    full = os.path.join(OUT, key + ".png")
    if os.path.exists(full):
        return key, "skip"
    text = STYLE % SUBJECT[key]
    body = json.dumps({"model": "gpt-image-2", "prompt": text, "n": 1, "size": "1024x1024", "quality": "low"}).encode()
    req = urllib.request.Request("https://api.openai.com/v1/images/generations", data=body, headers={
        "Authorization": "Bearer " + os.environ["OPENAI_API_KEY"], "Content-Type": "application/json"})
    for attempt in range(3):
        try:
            r = json.load(urllib.request.urlopen(req, timeout=600))
            break
        except urllib.error.HTTPError as e:
            if e.code in (429, 500, 502, 503) and attempt < 2:
                time.sleep(20 * (attempt + 1))
                continue
            return key, "HTTP %d %s" % (e.code, e.read().decode()[:300])
        except Exception as e:
            if attempt < 2:
                continue
            return key, "error %s" % e
    os.makedirs(OUT, exist_ok=True)
    open(full, "wb").write(base64.b64decode(r["data"][0]["b64_json"]))
    json.dump({"prompt": text, "usage": r.get("usage")}, open(full[:-4] + "-meta.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    return key, "ok"


def main():
    if "--dry" in sys.argv:
        print(STYLE % SUBJECT["tp_ngo_tinh"])
        return
    with concurrent.futures.ThreadPoolExecutor(8) as ex:
        for key, res in ex.map(paint, list(SUBJECT)):
            if res != "ok":
                print(key, res, flush=True)
    os.makedirs(GAME, exist_ok=True)
    for key in SUBJECT:
        src = os.path.join(OUT, key + ".png")
        if os.path.exists(src):
            im = Image.open(src).convert("RGBA").resize((128, 128), Image.LANCZOS)
            mask = Image.new("L", (512, 512), 0)
            ImageDraw.Draw(mask).ellipse((10, 10, 502, 502), fill=255)
            im.putalpha(mask.resize((128, 128), Image.LANCZOS))
            im.save(os.path.join(GAME, key + ".png"))
    print("installed", len(os.listdir(GAME)))


if __name__ == "__main__":
    main()
