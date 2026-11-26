"""Merge a sect's Effect engine records into assets/data/combat_effects.json (ADR-0009: world-depth Effects live
there, keyed by their plain English name, with source "world-depth:<key>").

    python -I tools/design/combat_sim/put_effects.py                 # round-trip check of the file's layout
    python -I tools/design/combat_sim/put_effects.py <effects.json> [--check]

<effects.json> is {"source": "world-depth:<key>", "effects": {name: {rule, records, ...}}}. Each entry gets that
source. A name already in the library from another source is refused (a new Effect never overwrites an existing key,
ADR-0009 decision 3); one from the same source is replaced, so a rerun is safe. Entries stay sorted by name; every
other entry keeps its text as it is, and a new one is written one line per field with compact values (a records list
of more than one, one record per line). With --check nothing is written; it exits 1 if the merge would change the
file. Emits observations, not a verdict.
"""
import json
import os
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
LIB = os.path.join(ROOT, "assets", "data", "combat_effects.json")
NL = "\n"


def field(name, value):
    """A new entry's field value: compact, except a records list of more than one, one record per line."""
    if name == "records" and isinstance(value, list) and len(value) > 1:
        rows = ("," + NL).join("        " + json.dumps(r, ensure_ascii=False) for r in value)
        return "[" + NL + rows + NL + "      ]"
    return json.dumps(value, ensure_ascii=False)


def entry_text(name, e):
    body = ("," + NL).join("      %s: %s" % (json.dumps(f, ensure_ascii=False), field(f, e[f])) for f in e)
    return "    %s: {%s%s%s    }" % (json.dumps(name, ensure_ascii=False), NL, body, NL)


def blocks(text):
    """The file split into its head lines, its entries' own text (name -> text, kept verbatim) and its tail lines."""
    lines = text.split(NL)
    i = lines.index('  "effects": {')
    head, out, cur, name = lines[:i + 1], {}, None, None
    j = i + 1
    while not lines[j].startswith("  }"):
        ln = lines[j]
        if cur is None and ln.startswith('    "') and ln.endswith("{"):
            name, cur = json.loads(ln.strip()[:-1].rstrip().rstrip(":")), [ln]
        elif cur is not None:
            cur.append(ln)
            if ln in ("    }", "    },"):
                cur[-1] = "    }"
                out[name], cur = NL.join(cur), None
        j += 1
    return head, out, lines[j:]


def render(text, put):
    """The library text with the entries in `put` (name -> entry) added or replaced, every other entry verbatim."""
    head, ents, tail = blocks(text)
    for name, e in put.items():
        ents[name] = entry_text(name, e)
    names = sorted(ents)
    return NL.join(head) + NL + ("," + NL).join(ents[n] for n in names) + NL + NL.join(tail)


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    check = "--check" in sys.argv
    text = open(LIB, encoding="utf-8").read()
    data = json.loads(text)
    if not args:
        print("round-trip\t%s" % ("same" if render(text, {}) == text else "DIFFERS"))
        return 0
    src = json.load(open(args[0], encoding="utf-8"))
    source = src["source"]
    refused, put = [], {}
    for name, e in src["effects"].items():
        old = data["effects"].get(name)
        if old is not None and old.get("source") != source:
            refused.append(name)
            print("REFUSED\t%s\talready in the library from %r" % (name, old.get("source", "items")))
            continue
        entry = {"rule": e["rule"], "source": source}
        entry.update({k: v for k, v in e.items() if k not in ("rule", "source")})
        put[name] = entry
    new = render(text, put)
    json.loads(new)
    if check:
        print("combat_effects.json %s" % ("current" if new == text else "would change"))
        return 0 if new == text else 1
    with open(LIB, "w", encoding="utf-8", newline="\n") as f:
        f.write(new)
    print("put %d Effects from %s (%d refused)" % (len(put), source, len(refused)))
    return 1 if refused else 0


if __name__ == "__main__":
    sys.exit(main())
