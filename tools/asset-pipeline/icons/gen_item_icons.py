"""Painted item icons for the inventory (user 2026-11-24, the illustrated windows: "Inventory: needs item icons").
One square icon per item template the game makes (item_factory.gd kinds): the 22 artifact bases, 11 herbs, 13
materials, 12 pills, 4 talismans, 2 treasures and the công pháp manual by element (6); and (user 2026-11-24, "go do
all 3") one per named legendary item in items_named.json (171, key named_<id>): its base's object made legendary,
coloured by its element and themed by its name and family. Painted by OpenAI's image model at low quality; the rarity frame is
drawn by the UI, so every icon is the object alone on the same dark ground.

Masters: tools/asset-pipeline/icons/ai/openai/items/<key>.png (git-ignored with ai/). Game copies:
assets/icons/items/<key>.png at 128 px, key = <kind>_<template id>. Usage: python -I tools/asset-pipeline/icons/gen_item_icons.py [test]
"""
import base64, concurrent.futures, json, os, sys, time, urllib.error, urllib.request
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
OUT = os.path.join(HERE, "ai", "openai", "items")
GAME = os.path.join(ROOT, "assets", "icons", "items")
STYLE = ("A single inventory item icon for a historical grand-strategy RPG set in an original Chinese cultivation (xianxia) "
         "world: %s. The object alone, centred and filling about 80 %% of the square, three-quarter view, on a plain very dark "
         "warm-brown background with a soft vignette. Refined semi-realistic painting, crisp edges and strong contrast so it "
         "reads at 48 pixels, gentle light from the upper left, a faint glow of spiritual energy where it suits. No text, no "
         "letters, no characters, no frame, no border, no watermark.")
EL = {"kim": "pale gold metal", "moc": "jade green wood", "thuy": "deep blue water", "hoa": "vermilion fire", "tho": "ochre earth", "": ""}
SUBJECT = {
    # artifact bases (items_artifacts.json bases)
    "artifact_phi_kiem": "a slender flying sword (phi kiếm) hovering point-down with a faint trail of light",
    "artifact_an": "a square jade seal with a carved beast knob",
    "artifact_chuong": "a small bronze temple bell with engraved runes",
    "artifact_ho_lo": "a lacquered calabash gourd bottle tied with red cord",
    "artifact_thuan": "a round bronze shield with a tortoise-shell pattern",
    "artifact_giap": "a lamellar armour vest of dark scales",
    "artifact_phien": "a folding fan of white silk with ink mountains",
    "artifact_cham": "three silver needles fanned out",
    "artifact_ky": "a small formation banner on a black pole",
    "artifact_phu": "a broad battle axe with a cloud-shaped blade",
    "artifact_tien_tieu": "a set of throwing coin darts on a string",
    "artifact_cam": "a seven-string zither (cầm) of dark wood",
    "artifact_mao": "a long serpent spear",
    "artifact_co": "a war drum with a red hide face",
    "artifact_kinh": "a round bronze mirror with a glowing face",
    "artifact_huong_lo": "a three-legged bronze incense burner with smoke",
    "artifact_dang": "a paper lantern lamp with a spirit flame",
    "artifact_lac_thiet": "a heavy iron chain flail",
    "artifact_loi_truong": "a thunder staff crackling with violet lightning",
    "artifact_nhan": "a storage ring of silver set with a dark gem",
    "artifact_ngoc_boi": "a carved jade pendant on a silk tassel",
    "artifact_dao_bao": "a folded Daoist robe embroidered with a taiji",
    # herbs (items_herbs.json)
    "herb_ngung_khi_thao": "a tuft of pale green qi-gathering grass with dew",
    "herb_thiet_tuyen_thao": "wiry iron-grey grass blades like thread",
    "herb_thanh_tam_lien": "a pale blue lotus flower",
    "herb_hoa_linh_chi": "a fire-red lingzhi mushroom",
    "herb_hoang_tinh_sam": "an ochre earth ginseng root with leaves",
    "herb_xich_huyet_dang": "a coil of blood-red vine",
    "herb_bang_tam_thao": "frosted ice-blue grass",
    "herb_kim_tuy_qua": "a golden glowing fruit",
    "herb_van_nien_moc_linh": "an ancient knotted wood spirit root with a tiny face of light",
    "herb_anh_tam_lien": "a pink lotus with a tiny glowing infant shape in its heart",
    "herb_hoa_than_qua": "a radiant fruit wreathed in white spirit flame",
    # materials (items_materials.json)
    "material_linh_thach_khoang": "a lump of raw spirit-stone ore with blue crystal veins",
    "material_tinh_thiet": "a refined iron ingot",
    "material_yeu_dan": "a glowing demon beast core, a red pearl",
    "material_han_ngoc": "a block of cold white jade with frost",
    "material_xich_dong": "a red copper ingot glowing warm",
    "material_linh_moc_tam": "a piece of spirit-tree heartwood with green grain",
    "material_huyen_hoang_thach": "a dark-yellow formation stone carved with lines",
    "material_loi_kich_moc": "a lightning-struck branch scorched with violet cracks",
    "material_tu_kim_sa": "a small heap of purple-gold sand",
    "material_yeu_cot": "a large demon-beast bone",
    "material_yeu_thu_bi": "a rolled demon-beast hide",
    "material_linh_tuyen_thuy": "a glass vial of shining spirit-spring water",
    "material_dia_hoa_tinh": "a molten earth-fire crystal",
    # pills (items_recipes.json recipes): a small porcelain bottle or pills in a dish, coloured by effect
    "pill_tu_khi_dan": "three pale green pills in a small porcelain dish",
    "pill_thanh_doc_dan": "blue cleansing pills beside a white porcelain bottle",
    "pill_hoi_xuan_dan": "red healing pills glowing warmly",
    "pill_hoang_long_dan": "a golden pill with a dragon pattern",
    "pill_tinh_tam_dan": "a calm white pill on a lotus leaf",
    "pill_truc_co_dan": "a large earth-brown foundation pill with rings",
    "pill_huyet_khi_dan": "a deep crimson pill with a pulse of light",
    "pill_ngung_nguyen_dan": "a golden core pill in a jade box",
    "pill_tay_tuy_dan": "a translucent marrow-washing pill",
    "pill_dien_tho_dan": "a peach-shaped longevity pill",
    "pill_hoa_anh_dan": "a violet pill with a tiny infant glow",
    "pill_hoa_than_dan": "a white pill wreathed in spirit flame",
    # talismans (crafting_talismans.json)
    "talisman_hoa_cau": "a yellow paper talisman with red glyph strokes and a small fireball",
    "talisman_kim_cuong": "a yellow paper talisman with gold strokes and a diamond glint",
    "talisman_than_hanh": "a yellow paper talisman with green strokes and wind lines",
    "talisman_pha_canh": "a yellow paper talisman with violet strokes breaking a barrier",
    # treasures (items_treasures.json)
    "treasure_linh_can_qua": "a millennium fruit glowing with five colours",
    "treasure_dao_an": "a Dao seal of black jade with a glowing rune",
    # công pháp manuals by element
    "cong_phap_": "a bound cultivation manual with a silk cover",
    "diagram_manual": "a half-unrolled silk scroll showing a glowing golden formation diagram of linked circles (a combat formation manual)",
    "cong_phap_kim": "a bound cultivation manual with a pale gold metal cover",
    "cong_phap_moc": "a bound cultivation manual with a jade green cover",
    "cong_phap_thuy": "a bound cultivation manual with a deep blue cover",
    "cong_phap_hoa": "a bound cultivation manual with a vermilion cover",
    "cong_phap_tho": "a bound cultivation manual with an ochre cover",
}


FAMILY = {"metal": "sharp gleaming metal", "body": "sinew, bone and blood-red qi", "force-chaos": "swirling magenta chaos force",
          "soul-song-seal": "ethereal lavender soul light and faint musical notes", "water": "flowing deep blue water",
          "wood": "living jade-green wood and leaves", "fire": "vermilion flame", "thunder": "crackling violet lightning",
          "earth": "heavy ochre stone", "general": "a warm golden aura", "wind": "pale mint wind streaks",
          "blade": "keen cold sword light", "ice": "pale cyan frost"}


def named_subjects():
    d = json.load(open(os.path.join(ROOT, "assets", "data", "items_named.json"), encoding="utf-8"))["named"]
    out = {}
    for t in d:
        base = SUBJECT.get("artifact_" + str(t["base"]), "a cultivation artifact")
        title = str(t["name"]).split(" (")[0]
        out["named_" + str(t["id"])] = ("a legendary unique treasure named '%s': %s, richly ornamented and finer than any "
                                        "common one, wreathed in %s") % (title, base, FAMILY.get(str(t.get("family", "")), "a golden aura"))
    return out


SUBJECT.update(named_subjects())


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
    keys = list(SUBJECT)
    if "test" in sys.argv:
        keys = ["artifact_phi_kiem", "herb_hoa_linh_chi", "material_yeu_dan", "pill_truc_co_dan", "talisman_hoa_cau"]
    if "named-test" in sys.argv:
        keys = [k for k in keys if k.startswith("named_")][:4]
    print(len(keys), "item icons")
    with concurrent.futures.ThreadPoolExecutor(6) as ex:
        for key, res in ex.map(paint, keys):
            if res not in ("ok", "skip"):
                print(key, res, flush=True)
    os.makedirs(GAME, exist_ok=True)
    n = 0
    for key in SUBJECT:
        src = os.path.join(OUT, key + ".png")
        if os.path.exists(src):
            Image.open(src).convert("RGB").resize((128, 128), Image.LANCZOS).save(os.path.join(GAME, key + ".png"))
            n += 1
    print("installed", n)


if __name__ == "__main__":
    main()
