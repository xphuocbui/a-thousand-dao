"""Export the reference fighters to game data (ADR-0001 decision 2: "an enemy without a Character ... is a profile built
from data") and keep the t6_typical_mirror_r0..r4 parity fixtures in lockstep.

fight.py defines the pre-Dao-Do reference enemies (enemy_file: typical, top_end, top_end_the_tu) from GDD-checked
constants (still used by combat_library.json as the character-compiler stand-in base and by fight.py --selftest).
For Power Rankings ladders and standalone reference opponents, this exporter layers post-Dao-Do typical stats
(POST_DAO_DO_TYPICAL) on top of fight.enemy_file("typical", r), compiles every kind at every realm with to_build(),
writes assets/data/combat_reference_fighters.json, and writes tests/parity/fixtures/t6_typical_mirror_r0..r4.json from
the same compiled typical builds so fighter_compiler_test.gd and combat_parity_test.gd stay in lockstep.

Run:
  python -I tools/design/combat_sim/export_reference_fighters.py           write reference fighters + t6 fixtures
  python -I tools/design/combat_sim/export_reference_fighters.py --check   compare with files on disk; exit 1 on drift
"""
import copy
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import fight as F  # noqa: E402
import parity_export as P  # noqa: E402

ROOT = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
OUT = os.path.join(ROOT, "assets", "data", "combat_reference_fighters.json")
FIXTURES_DIR = os.path.join(ROOT, "tests", "parity", "fixtures")
KINDS = ("typical", "top_end", "top_end_the_tu")

# Post-Dao-Do typical reference profiles by realm (0..4):
# (L1_add, L2, L3, L4, L5, pool_mult, ws_add, ward_layers, crit_chance, crit_mult, art_speed_pct, regen_bonus_pp)
# Reflecting post-Dao-Do live cast realm medians (~20 / 94 / 175 / 304 / 512 Dao Do points).
POST_DAO_DO_TYPICAL = (
    ( 28.0,  50,  50, 20, 10,  1.32,  8.0, [42, 45, 20, 10], 0.18, 1.75,  4.0, 0.15),  # R0 Luyen Khi
    ( 80.0,  82,  76, 32, 14,  2.55, 18.0, [46, 52, 22, 10], 0.21, 1.82, 10.0, 0.35),  # R1 Truc Co
    (175.0, 130, 115, 50, 22,  5.30, 30.0, [50, 60, 25, 10], 0.25, 1.90, 16.0, 0.60),  # R2 Ket Dan
    (315.0, 205, 175, 80, 38, 11.20, 42.0, [55, 68, 28, 15], 0.29, 2.00, 22.0, 0.90),  # R3 Nguyen Anh
    (370.0, 235, 205, 95, 45, 13.00, 54.0, [60, 76, 32, 15], 0.33, 2.12, 28.0, 1.25),  # R4 Hoa Than
)


def post_dao_do_typical_file(r):
    """Build file for the post-Dao-Do typical reference fighter at realm r (0..4)."""
    L1a, L2, L3, L4, L5, pm, wsa, wl, cch, cm, aspd, reg = POST_DAO_DO_TYPICAL[r]
    d = dict(F.enemy_file("typical", r))
    d["layers"] = [d["layers"][0] + L1a, L2, L3, L4, L5]
    d["n_body"] = d["n_body"] * pm
    d["n_qi"] = d["n_qi"] * pm
    ws = d["ward"].get("ws_base", F.C["typical_ws"][r]) + wsa
    d["ward"] = {"ws_base": ws, "we": ws, "layers": list(wl), "block": F.C["typical_block"][r] * pm}
    d["crit"] = {"chance": cch, "mult": cm}
    d["art_speed_pct"] = aspd
    d["regen_bonus_pp"] = reg
    return d


def build_all():
    out = {"schema_version": 1,
           "_doc": "Reference fighters by kind and realm (0-4), as fully resolved engine Builds. Written by "
                   "tools/design/combat_sim/export_reference_fighters.py (post-Dao-Do typical via "
                   "post_dao_do_typical_file(); top_end and top_end_the_tu via fight.py's enemy_file()) and "
                   "compiled with fight.to_build(); do not edit by hand. Read by FighterCompiler.from_data() "
                   "(ADR-0001 decision 2).",
           "fighters": {}}
    for kind in KINDS:
        rows = []
        for r in range(5):
            notes = []
            src = post_dao_do_typical_file(r) if kind == "typical" else dict(F.enemy_file(kind, r))
            b = F.to_build(src, r, notes, kind)
            rec = P.as_doc(b)
            rec["name"] = "%s-r%d" % (kind, r)
            rows.append(rec)
        out["fighters"][kind] = rows
    return out


def t6_fixture_doc(r, typical_rec):
    """Canonical t6_typical_mirror_r<r> parity fixture synced to combat_reference_fighters.json."""
    a = copy.deepcopy(typical_rec)
    a["name"] = "typical"
    b = copy.deepcopy(typical_rec)
    b["name"] = "typical-b"
    return {
        "name": "t6_typical_mirror_r%d" % r,
        "slice": 6,
        "chance_free": False,
        "seeds": 1000,
        "doc": "Engine sign-off (ADR-0001 Validation Criteria): the post-Dao-Do typical reference enemy at realm %d, "
               "built by export_reference_fighters.py (post_dao_do_typical_file + fight.to_build), in a mirror. "
               "Both engines must agree, and the mirror must last 30-60 s." % r,
        "a": a,
        "b": b,
    }


def dumps(doc, indent=1):
    return json.dumps(doc, indent=indent, ensure_ascii=False) + "\n"


def _write_or_check(path, text, check):
    if check:
        old = open(path, encoding="utf-8").read() if os.path.exists(path) else None
        same = old == text
        print(("same  " if same else "DRIFT ") + path)
        return same
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)
    print("wrote " + path)
    return True


def main(argv):
    check = "--check" in argv
    doc = build_all()
    ok = _write_or_check(OUT, dumps(doc, indent=1), check)
    for r, typical_rec in enumerate(doc["fighters"]["typical"]):
        fpath = os.path.join(FIXTURES_DIR, "t6_typical_mirror_r%d.json" % r)
        ok = _write_or_check(fpath, dumps(t6_fixture_doc(r, typical_rec), indent=2), check) and ok
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
