"""Regenerate design/builds/by-root/missing-pieces.md from each file's New pieces. Run: python -I tools/design/build_catalogue/compile_missing.py design/builds/by-root"""
import re,glob,sys,os
os.chdir(sys.argv[1])
items=[]
for f in sorted(glob.glob('*.md')):
    if f in ('README.md','missing-pieces.md','index.md','notes.md'): continue
    t=open(f,encoding='utf-8').read()
    for m in re.finditer(r"\*\*[^*]*linh lực keystone \(New[^)]*\):\*\* \*\*([^*]+)\*\*:? ?(.*?)(?:\n\n)", t, re.S):
        items.append((f,None,m.group(1).strip(),' '.join(m.group(2).split()),'root'))
    for m in re.finditer(r"\*\*[^*]*linh lực\.\*\*(.*?)(?:\n\n)", t, re.S):
        mm=re.search(r"\*\*([^*]+)\*\*:? ?(.*)", ' '.join(m.group(1).split()))
        if mm: items.append((f,None,mm.group(1).strip(),mm.group(2),'root'))
    for b in re.split(r"\n## ", t)[1:]:
        title=b.split("\n")[0]
        np=re.search(r"\*\*New pieces\.\*\*(.*?)(?:\n## |\Z)", b, re.S)
        if not np: continue
        for m in re.finditer(r"^- \*\*([^*]+)\*\*,? ?(.*?)(?=^- |\Z)", np.group(1), re.S|re.M):
            items.append((f,title,m.group(1).strip(),' '.join(m.group(2).split()),None))
def cat(n,d,k):
    dl=d.lower().lstrip(': ')
    if k=='root': return '1. Linh lực keystones, one per element or variant (user decision 2026-11-09)'
    if 'content' in n.lower() or dl.startswith('keystone'): return '2. Keystone content for the Meridian Map'
    if any(w in dl for w in ['artifact kind','a ward:','a formation','consumable','pill kind','formation field','an item','an artifact refined']): return '6. Items, wards and formations'
    if dl.startswith('a công pháp') or dl.startswith('a light công pháp'): return '4. Công pháp'
    if dl.startswith('an effect'): return '3. Effects'
    if dl.startswith('an art guard') or dl.startswith('an art-record'): return '9. Rules, readables and record fields'
    if dl.startswith('an art') or dl.startswith('a heal art') or dl.startswith('a soul art') or dl.startswith('an escape art'): return '5. Arts'
    if 'đạo' in n.lower(): return '7. Đạo'
    if 'stack_' in dl and 'scope' in dl: return '8. Modifiers'
    return '9. Rules, readables and record fields'
groups={}
for f,b,n,d,k in items:
    groups.setdefault(cat(n,d,k),{}).setdefault(n,[d,[]])[1].append(f"`{f}`" + ("" if b is None else f" ({b.split(' (')[0]})"))
out=["# Missing pieces","",
"Every piece the builds in this folder use that does not exist yet, with how to create it. Compiled from the",
"**New pieces** sections and the linh lực keystone notes of each file (overnight 2026-11-09/10) by",
"`tools/design/build_catalogue/compile_missing.py` (rerun after editing a build). Nothing here is designed into a GDD; each is a proposal",
"for the library: modifiers, Effects, items, công pháp, Đạo, keystones.","",
"Where a piece names a system rule, that system's owner would have to accept it. Effects are unpriced (Effects",
"rule 4); arts and items pass their own lints; keystones belong to the Meridian Map content pass, which waits on",
"the modifier library (user, 2026-11-09).",""]
for g in sorted(groups):
    out.append(f"## {g[3:]}"); out.append("")
    out.append("| Piece | What it does and how to create it | Used by |"); out.append("|---|---|---|")
    for n,(d,us) in sorted(groups[g].items()):
        d=d.lstrip(': ').replace('|','/')
        out.append(f"| **{n}** | {d} | {', '.join(sorted(set(us)))} |")
    out.append("")
out.append(f"Total: {sum(len(v) for v in groups.values())} pieces.")
open('missing-pieces.md','w',encoding='utf-8').write("\n".join(out)+"\n")
for g in sorted(groups): print(g, len(groups[g]), sorted(groups[g])[:3])
