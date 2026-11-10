"""Regenerate design/builds/by-root/index.md. Run: python -I tools/design/build_catalogue/make_index.py design/builds/by-root"""
import re,glob,sys,os
os.chdir(sys.argv[1])
order=['single','dual','triple','quad','five','variant']
files=sorted([f for f in glob.glob('*.md') if f not in('README.md','missing-pieces.md','index.md','notes.md')],
             key=lambda f:(next(i for i,o in enumerate(order) if f.startswith(o)),f))
rows=[];n=0
for f in files:
    t=open(f,encoding='utf-8').read()
    head=t.split('\n')[0].lstrip('# ').strip()
    rows.append(f"\n### {head} (`{f}`)\n\n| # | Build | Concept | Stacks | Linh lực from |\n|---|---|---|---|---|")
    for b in re.split(r"\n## ", t)[1:]:
        title=b.split("\n")[0]
        num,name=title.split('. ',1) if '. ' in title[:4] else ('',title)
        c=re.search(r"\*\*Concept\.\*\* (.*?)(?:\n\n)", b, re.S)
        concept=' '.join(c.group(1).split()) if c else ''
        first=re.split(r'(?<=[.!?])\s', concept)[0]
        st=re.search(r"\*\*Element stacks:\*\* (.*)", b); st=st.group(1).strip() if st else ''
        ks=re.search(r"\*\*Keystone:\*\* (.*)", b); ks=ks.group(1).strip() if ks else ''
        rows.append(f"| {num} | {name} | {first.replace('|','/')} | {st.replace('|','/')} | {ks.replace('|','/')} |")
        n+=1
hdr=["# Build index","",f"All {n} builds in this folder, one line each: the first sentence of the concept, the element stacks it",
     "builds, and where its linh lực comes from (the keystone line). Generated from the files; regenerate after edits.",""]
open('index.md','w',encoding='utf-8').write("\n".join(hdr+rows)+"\n")
print(n,"builds in",len(files),"files")
