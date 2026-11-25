import json,glob,sys
s=sys.argv[1]
fs=sorted(glob.glob(f'sects/{s}.cast.json')+glob.glob(f'sects/{s}.[0-9].cast.json'))
for f in fs:
    for p in json.load(open(f,encoding='utf-8'))['people']:
        t=p['traits']
        if not p.get('alive',True): print(f"## {p['key']} DEAD");continue
        print(f"## {p['key']} | {p['name_hv']} | {p['sex']} b{p['born']} | {p.get('realm')} | {p['rank']} | T{p['tier']} | bp={p.get('birthplace')} | {f.split('/')[-1]}")
        print(f" role: {p['role']}")
        print(f" tr: {t['personality']} {t.get('calling')} up={t.get('upbringing')} tal={[x['id']+str(x['tier']) for x in t.get('talent',[])]}")
        print(f" bs: {p['backstory']}")
        print(f" app={p.get('appearance')} wants={p.get('wants')} secret={p.get('secret')}")
        if p['tier']!='C': print(f" phu={p.get('thien_phu')}")
        print(f" ties: {[(x['to'],x['kind']) for x in p.get('ties',[])]}")
