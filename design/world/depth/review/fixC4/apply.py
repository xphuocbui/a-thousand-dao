import json,glob,sys
# usage: apply.py sect map.json ; map: {key: {pers:[..], up:str, talent_add:[{id,tier}], talent:[...], app, wants, secret, sub:[[o,n]], add:str}}
sect,mp=sys.argv[1],json.load(open(sys.argv[2],encoding='utf-8'))
fs=sorted(glob.glob(f'sects/{sect}.cast.json')+glob.glob(f'sects/{sect}.[0-9].cast.json'))
done=set()
for f in fs:
    raw=open(f,encoding='utf-8',newline='').read()
    nl='\r\n' if '\r\n' in raw else '\n'
    d=json.loads(raw); ch=False
    for p in d['people']:
        m=mp.get(p['key'])
        if not m: continue
        done.add(p['key']); ch=True
        t=p['traits']
        if 'pers' in m: t['personality']=m['pers']
        if 'up' in m: t['upbringing']=m['up']
        if 'talent' in m: t['talent']=m['talent']
        if 'talent_add' in m: t['talent']=(t.get('talent') or [])+m['talent_add']
        if 'phu' in m: p['thien_phu'].update(m['phu'])
        for o,n in m.get('sub',[]):
            assert o in p['backstory'],(p['key'],o)
            p['backstory']=p['backstory'].replace(o,n)
        if 'add' in m: p['backstory']=p['backstory'].rstrip()+' '+m['add']
        ins={k:m[k] for k in ('app','wants','secret') if k in m}
        new={}
        for k,v in p.items():
            new[k]=v
            if k=='backstory':
                for kk,nm in (('app','appearance'),('wants','wants'),('secret','secret')):
                    if kk in ins and nm not in p: new[nm]=ins[kk]
        for kk,nm in (('app','appearance'),('wants','wants'),('secret','secret')):
            if kk in ins and nm in p: new[nm]=ins[kk]
        p.clear(); p.update(new)
    if ch:
        out=json.dumps(d,indent=1,ensure_ascii=False).replace('\n',nl)+nl
        open(f,'w',encoding='utf-8',newline='').write(out)
miss=set(mp)-done
print('applied',len(done),'missing',miss)
