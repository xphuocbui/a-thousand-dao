"""Observations on the authored art prompts (design/world/depth/art/). Observations, not verdicts: a fixer reads each
flagged prompt and decides (CLAUDE.md: helpers in scripts emit observations).

Text flags (every prompt):
  short      subject under 200 words (portraits) / 250 (places)
  label      a bolted-on "X detail:" label, or a part label used twice
  repeat     two sentences that share most of their content words
  stubby     three or more very short sentences (under 6 words)
  clothes    a word for worn or poor clothing (allowed only where the story calls for it)
  traits     the Expression part only lists personality trait names
  text       a word that invites writing in the picture
  power      realm or power drawn as glow, aura or grandeur (the art bible: power is never drawn)
  risk       a word likely to trip the image model's content filter (blood, gore, nudity), or a minor described
             in a way that is not appropriate
  ip         a name from a well-known existing novel, drama or game
Record flags (portraits, checked against the cast record; user 2026-11-25):
  age        apparent age against real age, realm and lifespan
  qi         an element named in the qi hint that the person's root does not have
  weapon     a sword cultivator with no blade in the picture; a beast tamer whose beasts are not in it
  dress      a living sect member whose dress sheet is missing or another sect's
Place flags (checked against _inputs/places.json):
  size       the size line against the place's kind
  land       land words that contradict the biome, with no map-crop note saying so
  crop       no note that the map crop was read
  sect       a sect seat whose picture names fewer than two sect features (gate, hall, practice ground...)
Corpus observations (printed, not per prompt): openings shared within a group, stock phrases used across many prompts.

Writes design/world/depth/art/_check.json (key -> flags) and prints counts.
Run: python -I tools/design/world/art_prompt_check.py
"""
import collections
import glob
import json
import os
import re

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
ART = os.path.join(ROOT, "design", "world", "depth", "art")
DEPTH = os.path.join(ROOT, "design", "world", "depth")
YEAR = 1200
LIFE = {"luyen_khi": 120, "truc_co": 200, "ket_dan": 500, "nguyen_anh": 1000, "hoa_than": 2000}
STOP = set("a an the of and or in on at to with his her their its is are was were be by from as that this one two "
           "for over under into onto he she they it them him not no but so up out off down".split())
POOR = re.compile(r"\b(frayed|patched|patches|ragged|rags|threadbare|tattered|darned|moth-eaten|shabby|worn-out|"
                  r"worn thin|holes in|torn)\b", re.I)
TEXT = re.compile(r"\b(inscription|inscribed|calligraphy|characters written|written on|lettering|ledger page|"
                  r"signboard|plaque with)\b", re.I)
POWER = re.compile(r"\b(aura|radiant|radiating|radiates|divine|godlike|majestic power|overwhelming power|blazing power|"
                   r"towering presence|glowing body|halo of power|imposing power)\b", re.I)
RISK = re.compile(r"\b(blood|bloody|bleeding|gore|gory|corpse|severed|entrails|naked|nude|topless|disembowel\w*)\b", re.I)
MINOR_RISK = re.compile(r"\b(sensual|seductive|alluring|curves|cleavage|sexy|voluptuous)\b", re.I)
IP_NAMES = ["Lệnh Hồ Xung", "Dương Quá", "Tiểu Long Nữ", "Quách Tĩnh", "Hoàng Dung", "Trương Vô Kỵ", "Đoàn Dự",
            "Kiều Phong", "Hư Trúc", "Vi Tiểu Bảo", "Thạch Phá Thiên", "Đông Phương Bất Bại", "Nhạc Bất Quần",
            "Hàn Lập", "Tiêu Viêm", "Lâm Động", "Đường Tam", "Diệp Phàm", "Thạch Hạo", "Mạnh Hạo", "Vương Lâm",
            "Bạch Tiểu Thuần", "Phương Nguyên", "Wei Wuxian", "Lan Wangji", "Hiệp Khách Hành"]
ELEMENT_WORDS = {"kim": ["metal"], "moc": ["wood"], "thuy": ["water"], "hoa": ["fire"], "tho": ["earth"],
                 "bang": ["ice", "frost"], "loi": ["thunder", "lightning"], "phong": ["wind"],
                 "am": ["darkness", "shadow"], "quang": ["light"], "hon": ["chaos"]}
LABELS = ["The moment", "Face", "Hair", "Body", "Clothing", "Hands and objects", "Background", "Light", "Expression"]
SECT_FEATURES = ["gate", "hall", "practice", "training", "terrace", "pavilion", "scripture", "courtyard", "pagoda",
                 "shrine", "dormitor", "quarters", "sword court", "forge", "alchemy", "herb"]
LAND_CLASH = {"tundra": ["jungle", "palm", "desert dunes"], "glacier": ["jungle", "palm", "desert"],
              "desert": ["jungle", "glacier", "snowfield"], "tropical rainforest": ["glacier", "tundra", "snowfield"],
              "jungle": ["glacier", "tundra", "snowfield"], "steppe": ["jungle", "glacier"]}


def words(s):
    return [w for w in re.findall(r"[a-zà-ỹ'-]+", s.lower()) if w not in STOP and len(w) > 2]


def text_checks(subject, floor, traits):
    flags = []
    n = len(subject.split())
    if n < floor:
        flags.append("short %d" % n)
    if re.search(r"\b[A-Z][a-z]+ detail:", subject):
        flags.append("label bolted-on")
    for lab in LABELS:
        if len(re.findall(r"(?:^|[.;]\s)%s(?: \([^)]*\))?:" % re.escape(lab), subject)) > 1:
            flags.append("label twice: " + lab)
    sents = [s.strip() for s in re.split(r"(?<=[.!?])\s+", subject) if s.strip()]
    sets = [set(words(s)) for s in sents]
    for i in range(len(sets)):
        for j in range(i + 1, len(sets)):
            a, b = sets[i], sets[j]
            if len(a) >= 4 and len(b) >= 4 and len(a & b) / min(len(a), len(b)) >= 0.6:
                flags.append("repeat: %s | %s" % (sents[i][:60], sents[j][:60]))
                break
    stub = [s for s in sents if len(s.split()) < 6 and not re.match(r"^(The moment|Face|Hair|Body|Clothing|Light|Expression|Background)", s)]
    if len(stub) >= 3:
        flags.append("stubby %d" % len(stub))
    for name, rx in (("clothes", POOR), ("text", TEXT), ("risk", RISK)):   # power may be drawn (user 2026-11-25)
        m = rx.search(subject)
        if m:
            flags.append("%s: %s" % (name, m.group(0)))
    for nm in IP_NAMES:
        if nm.lower() in subject.lower():
            flags.append("ip: " + nm)
    ex = re.search(r"Expression:([^\n]*)$", subject)
    if ex and traits:
        hits = [t for t in traits if t.lower() in ex.group(1).lower()]
        if len(hits) >= 2 and len(ex.group(1).split()) <= 12:
            flags.append("traits listed: " + ", ".join(hits))
    return flags


def record_checks(e, rec, dress_keys):
    flags = []
    s = e.get("subject", "")
    low = s.lower()
    alive = rec.get("alive", True)
    born = rec.get("born")
    realm = rec.get("realm") or rec.get("peak_realm")
    life = LIFE.get(realm, 500)
    if isinstance(born, int):
        real = (YEAR if alive else int(rec.get("died") or YEAR)) - born
        age = e.get("age")
        if isinstance(age, int):
            if age > real + 5:
                flags.append("age: looks %d but is %d" % (age, real))
            if real < 25 and abs(age - real) > 6:
                flags.append("age: looks %d, young person aged %d" % (age, real))
            if alive and real >= 0.8 * life and age < 50 and "young" not in str(rec.get("appearance", "")).lower():
                flags.append("age: looks %d in the last fifth of a %d-year lifespan (%d)" % (age, life, real))
            if real >= 18 and age < 16:
                flags.append("age: looks %d but is an adult of %d" % (age, real))
            if age < 18 and MINOR_RISK.search(s):
                flags.append("risk: minor described as " + MINOR_RISK.search(s).group(0))
    root = rec.get("root") or {}
    have = set((root.get("elements") or {}).keys()) | set((root.get("variants") or {}).keys())
    if have:
        for sent in re.split(r"(?<=[.!?])\s+", s):
            if re.search(r"\bqi\b|\bhint\b|sheen of", sent, re.I):
                # element names are capitalised in the qi hint ("a faint red Fire hint"); lower-case light, frost or
                # water are usually lighting or weather, not qi
                bare = re.sub(r"\b(Light|Face|Hair|Body|Clothing|Background|Expression):", "", sent)
                named = {el for el, ws in ELEMENT_WORDS.items() for w in ws if re.search(r"\b%s\b" % w.capitalize(), bare)}
                if named and not (named & have):
                    flags.append("qi: names %s, root has %s" % ("/".join(sorted(named)), "/".join(sorted(have))))
    b = rec.get("build") or {}
    if alive and b.get("archetype") == "kiem_tu" and not re.search(r"\b(sword|sabre|saber|blade|jian|dao|scabbard)\b", low):
        flags.append("weapon: sword cultivator with no blade")
    if alive and rec.get("beasts") and not re.search(r"\b(bird|beast|wolf|horse|crane|hawk|elk|fox|tiger|snake|serpent|sparrow|drongo|dog|hound|sable|cat|deer|ox|fish|rat|monkey|bear)\b", low):
        flags.append("weapon: beasts %s not in the picture" % ",".join(rec["beasts"]))
    sect = rec.get("sect")
    if alive and sect and rec.get("rank") in ("ngoai_mon", "noi_mon", "chan_truyen", "truong_lao", "tong_chu"):
        if sect in dress_keys and e.get("dress") not in (sect, "x:" + sect):
            flags.append("dress: %s wears %s" % (sect, e.get("dress")))
    return flags


def place_checks(e, fact):
    flags = []
    s, size, where = e.get("subject", ""), str(e.get("size", "")), str(e.get("where", ""))
    kind = e.get("kind") or (fact or {}).get("kind")
    if kind in ("village",) and re.search(r"thousands? of (houses|buildings|roofs)", size + " " + s, re.I):
        flags.append("size: a village with thousands of buildings")
    if kind == "great_seat" and not re.search(r"hundred|thousand", size, re.I):
        flags.append("size: a great seat sized without hundreds")
    if kind == "minor_seat" and re.search(r"thousands of buildings", size, re.I):
        flags.append("size: a minor seat with thousands of buildings")
    if not re.search(r"\bcrop\b|\bthe map\b|map shows|on the map", where, re.I):
        flags.append("crop: no note that the map crop was read")
    biome = (fact or {}).get("biome") or ""
    for bad in LAND_CLASH.get(biome, []):
        if re.search(r"\b%s\b" % bad, s, re.I) and not re.search(r"crop|map", where, re.I):
            flags.append("land: %s on a %s place" % (bad, biome))
    if kind in ("great_seat", "minor_seat"):
        n = sum(1 for f in SECT_FEATURES if f in s.lower())
        if n < 2:
            flags.append("sect: only %d sect features named" % n)
    return flags


def main():
    t = json.load(open(os.path.join(ROOT, "assets/data/traits.json"), encoding="utf-8"))
    traits = [x["name"] for x in t["personality"]]
    cast = {}
    for f in glob.glob(os.path.join(DEPTH, "**", "*.cast.json"), recursive=True):
        for p in json.load(open(f, encoding="utf-8"))["people"]:
            cast[p["key"]] = p
    dress = json.load(open(os.path.join(ART, "dress.json"), encoding="utf-8"))
    for f in glob.glob(os.path.join(ART, "portraits", "*-dress.json")):
        dress.update(json.load(open(f, encoding="utf-8")))
    facts = {p["id"]: p for p in json.load(open(os.path.join(ART, "_inputs", "places.json"), encoding="utf-8"))["places"]}
    out, counts, total = {}, collections.Counter(), 0
    openings = collections.defaultdict(list)
    grams = collections.Counter()
    for kind, field, floor in (("portraits", "people", 200), ("places", "places", 250)):
        files = sorted(glob.glob(os.path.join(ART, kind, "*", "*.json")))
        for f in files:
            if "out" in f.replace("\\", "/").split("/"):
                continue
            batch = os.path.basename(os.path.dirname(f))
            group = os.path.basename(f)[:-5]
            for e in json.load(open(f, encoding="utf-8"))[field]:
                total += 1
                s = e.get("subject", "")
                fl = text_checks(s, floor, traits if kind == "portraits" else [])
                if kind == "portraits" and e.get("key") in cast:
                    fl += record_checks(e, cast[e["key"]], dress)
                if kind == "places":
                    fl += place_checks(e, facts.get(e.get("id")))
                first = " ".join(re.sub(r"^The moment:\s*", "", s).split()[:6]).lower()
                openings[(batch, group, first)].append(str(e.get("key") or e.get("id")))
                w = re.findall(r"[a-z]+", s.lower())
                grams.update({" ".join(w[i:i + 5]) for i in range(len(w) - 4)})
                if fl:
                    key = "%s/%s" % (batch, e.get("key") or e.get("id"))   # batch/key: a person may be in several batches
                    out[key] = {"file": os.path.relpath(f, ROOT).replace(os.sep, "/"), "flags": fl}
                    for x in fl:
                        counts[(batch, x.split(":")[0].split(" ")[0])] += 1
    json.dump(out, open(os.path.join(ART, "_check.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print("prompts checked %d, flagged %d" % (total, len(out)))
    for b in sorted({b for b, _ in counts}):
        print(b, {k: v for (bb, k), v in sorted(counts.items()) if bb == b})
    shared = [(k, v) for k, v in openings.items() if len(v) >= 3]
    print("openings shared by 3+ prompts in one group: %d, e.g. %s" % (
        len(shared), "; ".join("%s/%s '%s' x%d" % (k[0], k[1], k[2], len(v)) for k, v in shared[:6])))
    stock = [(g, n) for g, n in grams.most_common(400) if n >= 60 and not re.match(r"^(the moment|face most important|from the upper left)", g)]
    print("stock 5-word phrases in 60+ prompts: %s" % "; ".join("'%s' %d" % x for x in stock[:15]))


if __name__ == "__main__":
    main()
