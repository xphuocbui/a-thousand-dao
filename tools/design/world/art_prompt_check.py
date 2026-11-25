"""Observations on the authored art prompts (design/world/depth/art/): which prompts look padded, bolted-on or off-rule.
Emits observations, not verdicts: the polish writer reads each flagged prompt and decides (CLAUDE.md, helpers in
scripts emit observations).

Flags per prompt:
  short      subject under 200 words (portraits) / 250 (places)
  label      a bolted-on "X detail:" label, or a part label used twice
  repeat     two sentences that share most of their content words, or the same noun phrase re-stated
  stubby     three or more very short sentences (under 6 words), the mark of padding
  clothes    a word for worn or poor clothing (frayed, patched, ragged...) - allowed only where the story calls for it
  traits     the Expression part only lists two or more personality trait names
  text       a word that invites writing in the picture (inscription, calligraphy, characters, ledger page...)

Writes design/world/depth/art/_check.json (key -> flags) and prints counts.
Run: python -I tools/design/world/art_prompt_check.py
"""
import glob
import json
import os
import re

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
ART = os.path.join(ROOT, "design", "world", "depth", "art")
STOP = set("a an the of and or in on at to with his her their its is are was were be by from as that this one two "
           "for over under into onto he she they it them him not no but so up out off down".split())
POOR = re.compile(r"\b(frayed|patched|patches|ragged|rags|threadbare|tattered|darned|moth-eaten|shabby|worn-out|"
                  r"worn thin|holes in|torn)\b", re.I)
TEXT = re.compile(r"\b(inscription|inscribed|calligraphy|characters written|written on|lettering|ledger page|"
                  r"signboard|plaque with)\b", re.I)
LABELS = ["The moment", "Face", "Hair", "Body", "Clothing", "Hands and objects", "Background", "Light", "Expression"]


def words(s):
    return [w for w in re.findall(r"[a-zà-ỹ'-]+", s.lower()) if w not in STOP and len(w) > 2]


def check(subject, floor, traits):
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
    m = POOR.search(subject)
    if m:
        flags.append("clothes: " + m.group(0))
    m = TEXT.search(subject)
    if m:
        flags.append("text: " + m.group(0))
    ex = re.search(r"Expression:([^\n]*)$", subject)
    if ex:
        hits = [t for t in traits if t.lower() in ex.group(1).lower()]
        if len(hits) >= 2 and len(ex.group(1).split()) <= 12:
            flags.append("traits listed: " + ", ".join(hits))
    return flags


def main():
    t = json.load(open(os.path.join(ROOT, "assets/data/traits.json"), encoding="utf-8"))
    traits = [x["name"] for x in t["personality"]]
    out, counts, total = {}, {}, 0
    for kind, field, floor in (("portraits", "people", 200), ("places", "places", 250)):
        for f in sorted(glob.glob(os.path.join(ART, kind, "*", "*.json"))):
            if "out" in f.replace("\\", "/").split("/"):
                continue
            batch = os.path.basename(os.path.dirname(f))
            for e in json.load(open(f, encoding="utf-8"))[field]:
                total += 1
                fl = check(e.get("subject", ""), floor, traits)
                if fl:
                    key = str(e.get("key") or e.get("id"))
                    out[key] = {"file": os.path.relpath(f, ROOT).replace(os.sep, "/"), "flags": fl}
                    for x in fl:
                        k = x.split(":")[0].split(" ")[0]
                        counts[(batch, k)] = counts.get((batch, k), 0) + 1
    json.dump(out, open(os.path.join(ART, "_check.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print("prompts checked %d, flagged %d" % (total, len(out)))
    for b in sorted({b for b, _ in counts}):
        print(b, {k: v for (bb, k), v in counts.items() if bb == b})


if __name__ == "__main__":
    main()
