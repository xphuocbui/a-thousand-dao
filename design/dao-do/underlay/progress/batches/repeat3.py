"""Report-only: which sizes repeat, how far apart repeats sit, how often clusters nest. PoE 2 structural clusters,
ours per figure. Same drawing = node kinds + sorted pairwise distances in 0.5 buckets (any turn or mirror)."""
import sys, json, math, collections, os
sys.path.insert(0, r'C:\Users\xphuo\IdeaProjects\my-game\tools\design\dao_do_rework\tree_view'); sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import trees
from shapestats import comps
def hull(P):
    P=sorted(set(P))
    if len(P)<3: return P
    cr=lambda o,a,b:(a[0]-o[0])*(b[1]-o[1])-(a[1]-o[1])*(b[0]-o[0])
    lo=[];up=[]
    for p in P:
        while len(lo)>=2 and cr(lo[-2],lo[-1],p)<=0: lo.pop()
        lo.append(p)
    for p in reversed(P):
        while len(up)>=2 and cr(up[-2],up[-1],p)<=0: up.pop()
        up.append(p)
    return lo[:-1]+up[:-1]
def inside(p,H):
    if len(H)<3: return False
    s=None
    for a,b in zip(H,H[1:]+H[:1]):
        c=(b[0]-a[0])*(p[1]-a[1])-(b[1]-a[1])*(p[0]-a[0])
        if s is None: s=c>0
        elif (c>0)!=s: return False
    return True
def run(name,cl,xy,kind):
    sig={}; cen={}
    for n,c in enumerate(cl):
        pts=[xy(i) for i in c]; k=len(c)
        sig[n]=(tuple(sorted(kind(i) for i in c)),tuple(sorted(round(math.dist(pts[i],pts[j])/0.5) for i in range(k) for j in range(i+1,k))))
        cen[n]=(sum(p[0] for p in pts)/k,sum(p[1] for p in pts)/k)
    cnt=collections.Counter(sig.values())
    print('==',name,len(cl))
    for lo,hi in ((1,3),(4,5),(6,8),(9,12),(13,99)):
        grp=[n for n in sig if lo<=len(cl[n])<=hi]
        if not grp: continue
        rep=sum(1 for n in grp if cnt[sig[n]]>1)
        print('  size %2d-%-2d: %4d clusters, %3.0f%% share a drawing with another cluster'%(lo,hi,len(grp),100*rep/len(grp)))
    by=collections.defaultdict(list)
    for n,s in sig.items(): by[s].append(n)
    dd=[]; allnn=[]
    for n in sig:
        same=[math.dist(cen[n],cen[m]) for m in by[sig[n]] if m!=n]
        if same: dd.append(min(same))
        allnn.append(min(math.dist(cen[n],cen[m]) for m in sig if m!=n))
    dd.sort(); allnn.sort()
    print('  nearest copy of the same drawing: p10 %.1f, median %.1f units (nearest cluster of any kind: median %.1f)'%(dd[len(dd)//10],dd[len(dd)//2],allnn[len(allnn)//2]))
    H={n:hull([xy(i) for i in cl[n]]) for n in sig}
    nest=0; hosts=set()
    for n in sig:
        for m in sig:
            if m!=n and len(cl[m])>len(cl[n]) and all(inside(xy(i),H[m]) for i in cl[n]):
                nest+=1; hosts.add(m); break
    print('  nested (a cluster wholly inside another cluster\'s outline): %d (%.1f%%), inside %d hosts'%(nest,100*nest/len(cl),len(hosts)))
if __name__=='__main__':
    t,a=trees.load_poe2(r'C:\Users\xphuo\IdeaProjects\my-game\design\dao-do\reference\poe2\data.json')
    pk={'small':'s','notable':'N','jewel':'N'}; kind=lambda i: pk.get(t['nodes'][i][2],'r')
    cs,adj=comps(range(len(t['nodes'])),[tuple(e[:2]) for e in t['edges']],lambda i: kind(i) in ('s','N'))
    run('PoE 2',cs,lambda i:tuple(t['nodes'][i][:2]),kind)
    M=json.load(open(sys.argv[1] if len(sys.argv)>1 else 'cur.json',encoding='utf-8'))
    by=collections.defaultdict(list)
    for n in M['nodes']:
        if n.get('cluster') is not None and n['kind'] in ('small','notable'): by[n['cluster']].append(n['id'])
    N={n['id']:n for n in M['nodes']}; ok={'small':'s','notable':'N'}
    run('Ours',list(by.values()),lambda i:(N[i]['x'],N[i]['y']),lambda i: ok.get(N[i]['kind'],'r'))
    