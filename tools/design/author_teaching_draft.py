"""Writes the formation-teaching draft (design/formations/teaching-draft-2026-11-24.json + .md) for the user's review.
User 2026-11-24: sects' teaching hand-assigned per sect ("Hand-assign per sect"), learning costs contribution, formation
manuals as loot, the five one-off sources later with events. Each of the 50 fixed sects (world_history.json) gets a
short list by its name, path and speciality; the rank needed follows the formation's grade (grade 0 outer disciple,
1 inner, 2 inner at a great sect / elder at a minor one, 3 elder, 4 sect head). Hand-authored lists; only the coverage
check is computed. Usage: python -I tools/design/author_teaching_draft.py"""
import collections, json, os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
cat = {d["id"]: d for d in json.load(open(os.path.join(ROOT, "assets/data/crafting_diagrams.json"), encoding="utf-8"))["diagrams"]}
sects = {s["key"]: s for s in json.load(open(os.path.join(ROOT, "assets/data/world_history.json"), encoding="utf-8"))["sects"]}

TEACH = {
    # great sects
    "thien_xu": ["tam_tai", "tu_mon", "tu_tuong", "ngu_hanh", "cuu_cung", "luc_hop", "ky_mon", "bat_quai"],   # the formation sect
    "tung_dao": ["luong_nghi", "thuy_liem", "nhat_nguyet", "tinh_ha", "song_long"],          # pine waves: water, sky
    "lac_ha": ["ba_hoa", "hoa_long_quyen", "nhat_nguyet", "phong_loi"],                     # sunset clouds: fire, wind
    "thinh_vu": ["song_nhan_dummy", "nguyet_anh", "hac_sat", "khon_tien_vong", "van_kiem", "thien_la", "thap_phuong", "tu_thien_kiem"],  # demonic swords
    "bang_tam": ["thanh_phong_kiem", "bang_phong", "that_tinh", "van_kiem", "tu_thien_kiem"],   # ice heart swords
    "thuy_vi": ["quy_giap", "hoi_xuan", "lien_hoa", "lo_luyen"],                             # alchemists
    "phuong_minh": ["hoa_long_quyen", "nhat_nguyet", "song_long", "van_thu"],                # phoenix: fire, beasts
    # minor sects
    "thoi_tinh": ["thanh_phong_kiem", "tam_tai", "that_tinh"],
    "phat_y": ["thanh_phong_kiem", "quy_giap", "nguyet_anh"],
    "cung_tinh": ["tam_tai", "tu_mon", "tinh_ha", "ngu_hanh"],
    "cuu_cao": ["luong_nghi", "thuy_liem"],
    "ham_nguyet": ["luong_nghi", "nguyet_anh", "nhat_nguyet"],
    "van_hac": ["tho_bich", "tu_mon", "phong_loi"],
    "thai_chi": ["hoi_xuan", "ba_hoa"],
    "lang_dao": ["luong_nghi", "thuy_liem", "boi_thuy"],
    "binh_thuy": ["thuy_liem", "boi_thuy"],
    "muc_van": ["quy_giap", "tho_bich", "kim_chung", "kim_cuong"],
    "thien_bao": ["tam_tai", "tu_mon", "cuu_cung"],
    "nam_pho": ["tam_tai", "tu_tuong", "thuy_liem"],
    "xuyen_lam": ["tho_bich", "pha_quan"],
    "hong_dau": ["hac_sat", "doc_long", "huyet_hai"],
    "le_hoa": ["thanh_phong_kiem", "ba_hoa", "lien_hoa"],
    "trac_anh": ["kim_chung", "boi_thuy"],
    "da_quang": ["nguyet_anh", "hac_sat", "me_hon"],
    "hong_lo": ["hoi_xuan", "hoa_long_quyen"],
    "van_khoi": ["luong_nghi", "ba_hoa", "phong_loi"],
    "truc_thuc": ["hoi_xuan", "tho_bich"],
    "le_tuyen": ["hoi_xuan", "thuy_liem"],
    "phan_vu": ["hoa_long_quyen", "pha_quan"],
    "thu_phan": ["me_hon", "khon_tien_vong", "bach_quy"],
    "ngao_tuyet": ["thanh_phong_kiem", "bang_phong"],
    "bach_vu": ["hoi_xuan", "lien_hoa"],
    "vong_trieu": ["thuy_liem", "tu_tuong", "tinh_ha"],
    "tran_sa": ["thanh_phong_kiem", "tho_bich", "pha_quan"],
    "lanh_giang": ["thuy_liem", "bang_phong"],
    "nhan_van": ["luong_nghi", "tam_tai"],
    "nhan_tran": ["tu_mon", "tu_tuong", "pha_quan"],   # the Goose Formation gate: the wedge
    "vu_linh": ["tu_mon", "kim_chung", "loi_dinh"],
    "tuan_tung": ["quy_giap", "tho_bich", "kim_chung", "kim_cuong"],
    "tam_kiem": ["thanh_phong_kiem", "nguyet_anh", "that_tinh"],
    "chan_kim": ["thanh_phong_kiem", "pha_quan"],
    "coc_vu": ["hoi_xuan", "loi_dinh"],
    "minh_loan": ["cam_am", "kim_chung"],
    "yen_quang": ["hoi_xuan", "ba_hoa"],
    "hoa_cai": ["ba_hoa", "tinh_ha"],
    "suong_tung": ["luong_nghi", "bang_phong"],
    "chuc_ha": ["cam_am", "ba_hoa"],
    "vu_an": ["tam_tai", "tu_mon", "nguyet_anh"],
    "ho_lam": ["quy_giap", "hoi_xuan", "tho_bich"],
    "hoa_tinh": ["tinh_ha", "that_tinh"],
}
TEACH["thinh_vu"].remove("song_nhan_dummy")
# manuals as loot: the drop formations, and (rarer) a copy of any sect formation; the five one-off sources wait
MANUAL_ONLY = ["phong_hoa_luan", "van_tuong"]          # no sect teaches them
SPECIAL = ["con_bang", "thai_cuc_vo_cuc", "hon_don", "luan_hoi", "chu_thien"]   # later, with events
RANK = ["ngoai_mon", "noi_mon", "truong_lao", "tong_chu"]
COST = [60, 200, 600, 1500, 4000]   # contribution by grade


def rank_for(grade, great):
    if grade == 0:
        return "ngoai_mon"
    if grade == 1:
        return "noi_mon"
    if grade == 2:
        return "noi_mon" if great else "truong_lao"
    if grade == 3:
        return "truong_lao"
    return "tong_chu"


out = {"_doc": "DRAFT for the user's approval: which formations each fixed sect teaches (sect key -> [{id, rank}]), the contribution cost by grade, the manual-only and special formations.",
       "cost_contribution": COST, "manual_only": MANUAL_ONLY, "special": SPECIAL, "sects": {}}
taught_by = collections.defaultdict(list)
problems = []
for key, ids in TEACH.items():
    s = sects.get(key)
    if s is None:
        problems.append("unknown sect " + key)
        continue
    rows = []
    for fid in ids:
        if fid not in cat:
            problems.append("%s: unknown formation %s" % (key, fid))
            continue
        rows.append({"id": fid, "rank": rank_for(int(cat[fid]["grade"]), s["kind"] == "great")})
        taught_by[fid].append(key)
    out["sects"][key] = rows
for fid, d in cat.items():
    if fid in ("truong_xa",) or fid in MANUAL_ONLY or fid in SPECIAL:
        continue
    if not taught_by.get(fid):
        problems.append("no sect teaches " + fid)
missing = [k for k in sects if k not in TEACH]
problems += ["sect with no list: " + k for k in missing]
json.dump(out, open(os.path.join(ROOT, "design/formations/teaching-draft-2026-11-24.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
# the readable sheet
names = {"ngoai_mon": "outer", "noi_mon": "inner", "truong_lao": "elder", "tong_chu": "head"}
lines = ["# Formation teaching draft (2026-11-24)", "", "For the user's approval. Contribution to learn, by grade 0-4: " + ", ".join(map(str, COST)) +
         ". Rank by grade: 0 outer disciple, 1 inner, 2 inner at a great sect / elder at a minor one, 3 elder, 4 sect head. The formation's own realm and Trận Pháp gate also apply (rule 8).", "",
         "| Sect | Kind · path · speciality | Teaches (rank) |", "|---|---|---|"]
for key, rows in out["sects"].items():
    s = sects[key]
    lines.append("| %s (%s) | %s · %s · %s | %s |" % (s["name"], s.get("gloss", ""), s["kind"], s["alignment"], s["specialty"],
        ", ".join("%s (%s)" % (cat[r["id"]]["name"], names[r["rank"]]) for r in rows)))
lines += ["", "**How widely each formation is taught**", "", "| Formation | Grade | Sects |", "|---|---|---|"]
for fid, d in sorted(cat.items(), key=lambda kv: (kv[1]["grade"], kv[1]["name"])):
    src = "everyone (the starter)" if fid == "truong_xa" else ("manual only (loot)" if fid in MANUAL_ONLY else ("special: later, with events" if fid in SPECIAL else str(len(taught_by[fid]))))
    lines.append("| %s (%s) | %d | %s |" % (d["name"], d["name_vi"], d["grade"], src))
lines += ["", "Manuals (loot): every formation except the special five can drop as a manual (rarer by grade); the two manual-only ones drop only that way."]
open(os.path.join(ROOT, "design/formations/teaching-draft-2026-11-24.md"), "w", encoding="utf-8").write("\n".join(lines) + "\n")
print("problems:", problems)
cnt = collections.Counter(len(v) for v in taught_by.values())
print("formations by number of teaching sects:", dict(sorted(cnt.items())))
