// Lays out the exported Kinh Mạch Đồ with no crossing edges and fills the page template.
// Roads sit on an exact wheel. Each cluster starts as a small blob inside its own region and
// grows; a move that would make any edge cross, or touch another edge, is rejected.
const fs=require('fs'),path=require('path');
const dir=__dirname;
const d=JSON.parse(fs.readFileSync(path.join(dir,'meridian.json'),'utf8'));
// One step of the map: road acupoints sit one S apart, and connected acupoints aim for S.
const S=46,CLEAR=15,MINSEP=30;
const rOf=dep=>dep===0?0:110+dep*S;
const byId=new Map(d.nodes.map(n=>[n.id,n]));
let seed=+(process.env.MAP_SEED||33);const rnd=()=>(seed=(seed*1664525+1013904223)>>>0)/4294967296;
const pol=(deg,r)=>[r*Math.sin(deg*Math.PI/180),-r*Math.cos(deg*Math.PI/180)];
const isRoad=n=>['road','junction','gate'].includes(n.kind);
const cycle=d.elements.map(e=>e.id);
const letterOff={L:-24,C:0,R:24};

// --- Skeleton -------------------------------------------------------------------------
for(const n of d.nodes){n.x=null;n.y=null;n.th=null;n.fixed=false;}
const root=byId.get(0);root.x=0;root.y=0;root.fixed=true;
for(const n of d.nodes){
 if(n.kind==='gate'){n.th=cycle.indexOf(n.sector)*72;}
 const m=n.name.match(/ ([LCR])(\d+)$/);
 if(m&&isRoad(n))n.th=cycle.indexOf(n.sector)*72+letterOff[m[1]];
}
// Ring acupoints, connectors and braids: spread evenly along their chain between radial anchors.
const chainNodes=d.nodes.filter(n=>isRoad(n)&&n.th===null);
const seen=new Set();
const unwrap=(a,ref)=>{while(a-ref>180)a-=360;while(a-ref<-180)a+=360;return a;};
for(const n of chainNodes){
 if(seen.has(n.id))continue;
 const chain=[n];seen.add(n.id);
 const grow=(fromEnd)=>{
  for(;;){
   const cur=fromEnd?chain[chain.length-1]:chain[0];
   const nx=cur.links.map(l=>byId.get(l)).find(m=>isRoad(m)&&m.th===null&&!seen.has(m.id));
   if(!nx)break;seen.add(nx.id);fromEnd?chain.push(nx):chain.unshift(nx);
  }
 };
 grow(true);grow(false);
 const anchor=(end,skip)=>end.links.map(l=>byId.get(l)).find(m=>isRoad(m)&&m.th!==null&&m!==skip);
 const a=anchor(chain[0]);
 const b=anchor(chain[chain.length-1],chain.length===1?a:undefined);
 const tb=unwrap(b.th,a.th);
 chain.forEach((c,i)=>{c.pendingTh=a.th+(tb-a.th)*(i+1)/(chain.length+1);});
}
for(const n of chainNodes)n.th=n.pendingTh;
for(const n of d.nodes){
 if(!isRoad(n))continue;
 [n.x,n.y]=pol(n.th,rOf(n.depth));n.fixed=true;
}
// Keystones: the centre one sits in the border gap; the sector ones hang outward from their host.
for(const n of d.nodes){
 if(n.kind!=='keystone')continue;
 if(n.sector===''){[n.x,n.y]=pol(36,rOf(1));n.th=36;}
 else{const h=byId.get(n.links[0]);n.th=h.th;[n.x,n.y]=pol(h.th,rOf(23.4));}
 n.fixed=true;
}

// --- Geometry helpers -----------------------------------------------------------------
const edges=[];
const isPortal=(a,b)=>(!!a.variant)!==(!!b.variant);
const allEdges=()=>{const out=[];for(const n of d.nodes)for(const l of n.links){if(l<n.id)continue;const m=byId.get(l);if(isPortal(n,m))continue;out.push([n,m]);}return out;};
const orient=(ax,ay,bx,by,cx,cy)=>(bx-ax)*(cy-ay)-(by-ay)*(cx-ax);
function segCross(ax,ay,bx,by,cx,cy,dx,dy){
 const o1=orient(ax,ay,bx,by,cx,cy),o2=orient(ax,ay,bx,by,dx,dy),o3=orient(cx,cy,dx,dy,ax,ay),o4=orient(cx,cy,dx,dy,bx,by);
 return ((o1>0)!==(o2>0))&&((o3>0)!==(o4>0));
}
const distSeg=(px,py,a,b)=>{const vx=b.x-a.x,vy=b.y-a.y,q=vx*vx+vy*vy||1;let t=((px-a.x)*vx+(py-a.y)*vy)/q;t=Math.max(0,Math.min(1,t));return Math.hypot(px-a.x-t*vx,py-a.y-t*vy);};
const placed=n=>n.x!==null;
function crossesWorld(a,b,world){
 for(const [c,e] of world){
  if(c===a||c===b||e===a||e===b)continue;
  if(segCross(a.x,a.y,b.x,b.y,c.x,c.y,e.x,e.y))return true;
 }
 return false;
}

// --- Variant sectors go outside the rim -------------------------------------------------
const variantSlot=new Map(d.variants.map((v,i)=>[v.id,i]));
const SAT_R=rOf(22)+1250;
const satCenter=new Map();
for(const v of d.variants){
 const i=variantSlot.get(v.id),deg=i*45+22.5;
 const [cx,cy]=pol(deg,SAT_R);satCenter.set(v.id,{cx,cy,deg});
 const roads=d.nodes.filter(n=>n.variant===v.id&&n.kind==='variant_road').sort((a,b)=>a.id-b.id);
 const tx=Math.cos(deg*Math.PI/180),ty=Math.sin(deg*Math.PI/180);
 roads.forEach((n,k)=>{const o=(k-(roads.length-1)/2)*S;n.x=cx+tx*o;n.y=cy+ty*o;n.fixed=true;n.th=deg;});
}
// The groups for variant clusters: connected sets of non-road nodes in each sector.
const vGroups=[];
for(const v of d.variants){
 const rest=d.nodes.filter(n=>n.variant===v.id&&n.kind!=='variant_road');
 const left=new Set(rest.map(n=>n.id));
 while(left.size){
  const start=left.values().next().value,comp=[start],q=[start];left.delete(start);
  while(q.length){for(const l of byId.get(q.pop()).links){if(left.has(l)){left.delete(l);comp.push(l);q.push(l);}}}
  const links=[...new Set(comp.flatMap(i=>byId.get(i).links).filter(l=>byId.get(l).kind==='variant_road'))];
  vGroups.push({nodes:comp,links,variant:v.id});
 }
}

// --- Seed each cluster as a small planar blob -------------------------------------------
const regionCentroid=r=>{const p=r.boundary.map(i=>byId.get(i));return [p.reduce((s,n)=>s+n.x,0)/p.length,p.reduce((s,n)=>s+n.y,0)/p.length];};
// A planar start: the cluster's nodes in depth-first order around a small circle, its first entry
// facing the hosts, either way round.
function dfsOrder(g){
 const set=new Set(g.nodes),host=new Set(g.links);
 const start=g.nodes.find(i=>byId.get(i).links.some(l=>host.has(l)))??g.nodes[0];
 const out=[],seenN=new Set();
 const go=i=>{seenN.add(i);out.push(i);for(const l of byId.get(i).links)if(set.has(l)&&!seenN.has(l))go(l);};
 go(start);return out;
}
function circle(g,P,rad,rot,mirror){
 const order=dfsOrder(g);
 order.forEach((id,k)=>{const n=byId.get(id),t=rot+(mirror?-1:1)*k*6.283/order.length;n.x=P[0]+Math.cos(t)*rad;n.y=P[1]+Math.sin(t)*rad;});
}
// Barycentric start for clusters with a path inside a ring: the longest cycle goes on a circle and
// the rest settle between their neighbours, which is planar when the cycle bounds the cluster.
function longestCycle(g){
 const set=new Set(g.nodes),host=new Set(g.links);let best=[];
 const entries=g.nodes.filter(i=>byId.get(i).links.some(l=>host.has(l)));
 for(const s0 of g.nodes){
  const path=[s0],on=new Set(path);
  const go=i=>{for(const l of byId.get(i).links){if(!set.has(l))continue;if(l===s0&&path.length>2&&path.length>best.length&&entries.every(q=>on.has(q)))best=path.slice();if(on.has(l))continue;if(path.length>16)continue;path.push(l);on.add(l);go(l);path.pop();on.delete(l);}};
  go(s0);
 }
 return best;
}
function barycentric(g,P,rad,rot,mirror){
 const cyc=g.cyc??(g.cyc=longestCycle(g));
 if(cyc.length<3)return false;
 cyc.forEach((id,k)=>{const n=byId.get(id),t=rot+(mirror?-1:1)*k*6.283/cyc.length;n.x=P[0]+Math.cos(t)*rad;n.y=P[1]+Math.sin(t)*rad;});
 const on=new Set(cyc),set=new Set(g.nodes),rest=g.nodes.filter(i=>!on.has(i));
 for(const i of rest){const n=byId.get(i);n.x=P[0]+(rnd()-.5);n.y=P[1]+(rnd()-.5);}
 for(let it=0;it<80;it++)for(const i of rest){const n=byId.get(i),ns=n.links.filter(l=>set.has(l)).map(l=>byId.get(l));n.x=ns.reduce((q,m)=>q+m.x,0)/ns.length;n.y=ns.reduce((q,m)=>q+m.y,0)/ns.length;}
 return true;
}
function groupEdges(g){
 const set=new Set(g.nodes),out=[];
 for(const i of g.nodes){const n=byId.get(i);for(const l of n.links){const m=byId.get(l);if(isPortal(n,m))continue;if(set.has(l)&&l<i)continue;out.push([n,m]);}}
 return out;
}
function groupCrossings(g,world){
 const es=groupEdges(g);let c=0;
 for(let i=0;i<es.length;i++){
  const [a,b]=es[i];
  if(crossesWorld(a,b,world))c++;
  for(let j=i+1;j<es.length;j++){const [p,q]=es[j];if(p===a||p===b||q===a||q===b)continue;if(segCross(a.x,a.y,b.x,b.y,p.x,p.y,q.x,q.y))c++;}
 }
 return c;
}
const world=[];
for(const n of d.nodes)for(const l of n.links){if(l<n.id)continue;const m=byId.get(l);if(n.fixed&&m.fixed&&!isPortal(n,m))world.push([n,m]);}
let stuck=0;
function seedGroup(g,base){
 const hosts=g.links.map(i=>byId.get(i));
 const mid=[hosts.reduce((q,n)=>q+n.x,0)/hosts.length,hosts.reduce((q,n)=>q+n.y,0)/hosts.length];
 const near=world.filter(([u,v])=>Math.hypot((u.x+v.x)/2-mid[0],(u.y+v.y)/2-mid[1])<420);
 let best=null;
 const n=g.nodes.length;
 // Candidate centres, nearest the region's middle first: toward it, then a ring of points.
 const cands=[];
 for(const t of [.06,.12,.2,.3,.42,.56,.75])cands.push([mid[0]+(base[0]-mid[0])*t,mid[1]+(base[1]-mid[1])*t]);
 for(const r of [6,12,20,30,44,60,80,110])for(let a=0;a<16;a++)cands.push([mid[0]+Math.cos(a*.3927)*r,mid[1]+Math.sin(a*.3927)*r]);
 search:for(const P of cands){
  for(const L of [3.2,2,1.2]){
   const rad=Math.max(L*1.2,n*L/6.283);
   const a0=Math.atan2(hosts[0].y-P[1],hosts[0].x-P[0]);
   for(const init of [0,1])for(let k=0;k<16;k++)for(const mirror of [false,true]){
    const rot=a0+k*6.283/16;
    if(init===0)circle(g,P,rad,rot,mirror);else if(!barycentric(g,P,rad,rot,mirror))continue;
    const c2=groupCrossings(g,near);
    if(!best||c2<best.c)best={c:c2,pos:g.nodes.map(i=>[byId.get(i).x,byId.get(i).y])};
    if(c2===0)break search;
   }
  }
 }
 g.nodes.forEach((i,k)=>{const q=byId.get(i);q.x=best.pos[k][0];q.y=best.pos[k][1];});
 if(best.c>0){stuck++;console.log('stuck',g.nodes.length,'nodes',g.links.length,'links',d.regions[g.region]?.band??g.variant,'crossings',best.c);}
 world.push(...groupEdges(g));
}
// Clusters on chords first, then the rest, each aimed at the middle of its region or outward.
const gs=d.groups.slice().sort((a,b)=>b.links.length-a.links.length);
for(const g of gs){
 const r=d.regions[g.region];
 let base=regionCentroid(r);
 if(/rim/.test(r.band)){const h=byId.get(g.links[0]);const k=(rOf(22)+640)/(Math.hypot(h.x,h.y)+1);base=[h.x*k,h.y*k];}
 seedGroup(g,base);
}
for(const g of vGroups){
 const {cx,cy,deg}=satCenter.get(g.variant);
 const hosts=g.links.map(i=>byId.get(i)),mx=hosts.reduce((s,n)=>s+n.x,0)/hosts.length,my=hosts.reduce((s,n)=>s+n.y,0)/hosts.length;
 const n0=g.nodes.length;const side=(n0>6&&g.links.length===2)||(n0<=6)?1:-1;
 const nx=-Math.sin(deg*Math.PI/180)*0+Math.sin(deg*Math.PI/180),ny=-Math.cos(deg*Math.PI/180);
 const sgn=n0<=6?-1:(hosts[0].id%100>=4?1:-1);
 seedGroup(g,[mx+nx*240*sgn,my+ny*240*sgn]);
}

// --- Grow, rejecting any move that crosses --------------------------------------------
const free=d.nodes.filter(n=>!n.fixed);
const neighbours=new Map(free.map(n=>[n,n.links.map(l=>byId.get(l)).filter(m=>!isPortal(n,m))]));
const CELL=96;
function binEdges(all){
 const grid=new Map();
 for(const e of all){
  const [a,b]=e;
  const x0=Math.floor((Math.min(a.x,b.x)-24)/CELL),x1=Math.floor((Math.max(a.x,b.x)+24)/CELL),y0=Math.floor((Math.min(a.y,b.y)-24)/CELL),y1=Math.floor((Math.max(a.y,b.y)+24)/CELL);
  for(let x=x0;x<=x1;x++)for(let y=y0;y<=y1;y++){const k=x*100000+y;(grid.get(k)||grid.set(k,[]).get(k)).push(e);}
 }
 return grid;
}
let nodeGrid=new Map();
function moveOk(n,x,y,grid,clear){
 const ox=n.x,oy=n.y;n.x=x;n.y=y;let ok=true;
 const cgx=Math.floor(x/CELL),cgy=Math.floor(y/CELL);
 for(const m of neighbours.get(n)){
  for(let a=-1;a<=1&&ok;a++)for(let c=-1;c<=1&&ok;c++)for(const w of nodeGrid.get((cgx+a)*100000+cgy+c)||[]){
   if(w===n||w===m)continue;
   const now=distSeg(w.x,w.y,n,m);
   if(now>=clear)continue;
   n.x=ox;n.y=oy;const was=distSeg(w.x,w.y,n,m);n.x=x;n.y=y;
   if(now<was){ok=false;break;}
  }
 }
 if(!ok){n.x=ox;n.y=oy;return false;}
 const near=new Set();
 const gx=Math.floor(x/CELL),gy=Math.floor(y/CELL);
 for(let a=-1;a<=1;a++)for(let b=-1;b<=1;b++)for(const e of grid.get((gx+a)*100000+gy+b)||[])near.add(e);
 outer:for(const e of near){
  const [c,f]=e;
  if(c!==n&&f!==n){const dn=distSeg(x,y,c,f);if(dn<clear&&dn<distSeg(ox,oy,c,f)){ok=false;break;}}
  for(const m of neighbours.get(n)){
   if(c===n||f===n||c===m||f===m)continue;
   if(segCross(x,y,m.x,m.y,c.x,c.y,f.x,f.y)){ok=false;break outer;}
  }
 }
 if(!ok){n.x=ox;n.y=oy;}
 return ok;
}
const live=allEdges();
const closest=(px,py,a,e)=>{const vx=e.x-a.x,vy=e.y-a.y,q=vx*vx+vy*vy||1;let t=((px-a.x)*vx+(py-a.y)*vy)/q;t=Math.max(0,Math.min(1,t));return [a.x+t*vx,a.y+t*vy];};
const ITER=1600;
for(let it=0;it<ITER;it++){
 const L=6+Math.min(1,it/(ITER*.6))*(S-6);
 const clear=CLEAR*Math.min(1,.25+it/(ITER*.6));
 const sep=MINSEP*Math.min(1,.25+it/(ITER*.6));
 const grid=binEdges(live);
 const ngrid=new Map();
 for(const n of d.nodes){if(n.x===null)continue;const k=Math.floor(n.x/CELL)*100000+Math.floor(n.y/CELL);(ngrid.get(k)||ngrid.set(k,[]).get(k)).push(n);}
 nodeGrid=ngrid;
 for(const n of free){
  let fx=0,fy=0;
  const gx=Math.floor(n.x/CELL),gy=Math.floor(n.y/CELL);
  for(let a=-1;a<=1;a++)for(let b2=-1;b2<=1;b2++)for(const m of ngrid.get((gx+a)*100000+gy+b2)||[]){
   if(m===n)continue;const dx=n.x-m.x,dy=n.y-m.y,q=Math.hypot(dx,dy);
   if(q<.5){fx+=(rnd()-.5)*4;fy+=(rnd()-.5)*4;}
   else if(q<sep*1.7){const f=(sep*1.7-q)/q*.35;fx+=dx*f;fy+=dy*f;}
  }
  // Springs hold connected acupoints at the standard length.
  for(const m of neighbours.get(n)){const dx=m.x-n.x,dy=m.y-n.y,q=Math.hypot(dx,dy)+.01,f=(q-L)*.34;fx+=dx/q*f;fy+=dy/q*f;}
  // Every edge this acupoint is not on pushes it away.
  // And an edge of this acupoint is pushed off any acupoint it runs past.
  for(const m of neighbours.get(n)){
   for(let a=-1;a<=1;a++)for(let b2=-1;b2<=1;b2++)for(const w of ngrid.get((gx+a)*100000+gy+b2)||[]){
    if(w===n||w===m)continue;
    const [qx,qy]=closest(w.x,w.y,n,m),dx=qx-w.x,dy=qy-w.y,q=Math.hypot(dx,dy)+.01;
    if(q<clear*1.5){const f=(clear*1.5-q)*.6;fx+=dx/q*f;fy+=dy/q*f;}
   }
  }
  const seenE=new Set();
  for(let a=-1;a<=1;a++)for(let b2=-1;b2<=1;b2++)for(const e of grid.get((gx+a)*100000+gy+b2)||[]){
   if(seenE.has(e))continue;seenE.add(e);
   const [c,f2]=e;if(c===n||f2===n)continue;
   const [qx,qy]=closest(n.x,n.y,c,f2),dx=n.x-qx,dy=n.y-qy,q=Math.hypot(dx,dy)+.01;
   if(q<clear*1.5){const f=(clear*1.5-q)*.5;fx+=dx/q*f;fy+=dy/q*f;}
  }
  const sp=Math.hypot(fx,fy),cap=5;if(sp>cap){fx*=cap/sp;fy*=cap/sp;}
  if(!moveOk(n,n.x+fx,n.y+fy,grid,clear)){moveOk(n,n.x+fx*.35,n.y+fy*.35,grid,clear);}
 }
}

// Separate anything still stacked: random hops, keeping every edge clear.
for(let round=0;round<120;round++){
 const grid=binEdges(live);
 const ngrid=new Map();
 for(const n of d.nodes){const k=Math.floor(n.x/CELL)*100000+Math.floor(n.y/CELL);(ngrid.get(k)||ngrid.set(k,[]).get(k)).push(n);}
 let close=0;
 for(const n of free){
  const gx=Math.floor(n.x/CELL),gy=Math.floor(n.y/CELL);let near=null;
  for(let a=-1;a<=1;a++)for(let b=-1;b<=1;b++)for(const m of ngrid.get((gx+a)*100000+gy+b)||[]){if(m!==n&&Math.hypot(m.x-n.x,m.y-n.y)<MINSEP)near=m;}
  if(!near)continue;
  close++;
  for(let t=0;t<14;t++){
   const a=rnd()*6.283,r=8+rnd()*30,x=n.x+Math.cos(a)*r,y=n.y+Math.sin(a)*r;
   let clearOf=true;
   for(let p2=-1;p2<=1&&clearOf;p2++)for(let q=-1;q<=1&&clearOf;q++)for(const m of ngrid.get((Math.floor(x/CELL)+p2)*100000+Math.floor(y/CELL)+q)||[]){if(m!==n&&Math.hypot(m.x-x,m.y-y)<MINSEP){clearOf=false;break;}}
   if(clearOf&&moveOk(n,x,y,grid,CLEAR)){break;}
  }
 }
 if(!close)break;
}

for(let round=0;round<320;round++){
 const grid=binEdges(live);
 const ngrid=new Map();
 for(const n of d.nodes){const k=Math.floor(n.x/CELL)*100000+Math.floor(n.y/CELL);(ngrid.get(k)||ngrid.set(k,[]).get(k)).push(n);}
 nodeGrid=ngrid;
 let fixes=0;
 const score=(n)=>{ // the worst clearance around this acupoint and its edges
  let w=1e9;const gx=Math.floor(n.x/CELL),gy=Math.floor(n.y/CELL);
  for(let a=-1;a<=1;a++)for(let c=-1;c<=1;c++){
   for(const e of grid.get((gx+a)*100000+gy+c)||[]){const [u,v]=e;if(u===n||v===n)continue;w=Math.min(w,distSeg(n.x,n.y,u,v));}
   for(const q of ngrid.get((gx+a)*100000+gy+c)||[]){if(q===n)continue;for(const m of neighbours.get(n)){if(q===m)continue;w=Math.min(w,distSeg(q.x,q.y,n,m));}}
  }
  return w;
 };
 for(const n of free){
  const before=score(n);
  if(before>=CLEAR+1.5)continue;
  const ox=n.x,oy=n.y;let bx=ox,by=oy,bs=before;
  for(let t=0;t<48;t++){
   const a=rnd()*6.283,r=6+rnd()*60,x=ox+Math.cos(a)*r,y=oy+Math.sin(a)*r;
   n.x=ox;n.y=oy;
   if(!moveOk(n,x,y,grid,0))continue;
   const sc=score(n);
   const len=neighbours.get(n).every(m=>Math.hypot(m.x-n.x,m.y-n.y)<Math.max(S*1.9,Math.hypot(m.x-ox,m.y-oy)));
   if(sc>bs&&len){bs=sc;bx=x;by=y;}
  }
  n.x=bx;n.y=by;if(bs>before)fixes++;
 }
 if(!fixes)break;
}

// --- Count what is left ------------------------------------------------------------------
const all=allEdges();
let crossings=0;const bad=[];
const grid=binEdges(all);
const seenPair=new Set();
for(const v of grid.values()){
 for(let i=0;i<v.length;i++)for(let j=i+1;j<v.length;j++){
  const [a,b]=v[i],[c,e]=v[j];
  if(a===c||a===e||b===c||b===e)continue;
  const key=[a.id,b.id,c.id,e.id].sort((p,q)=>p-q).join('-');
  if(seenPair.has(key))continue;seenPair.add(key);
  if(segCross(a.x,a.y,b.x,b.y,c.x,c.y,e.x,e.y)){crossings++;if(bad.length<8)bad.push(`${a.name}#${a.id} x ${c.name}#${c.id}`);}
 }
}
let minLen=1e9,sum=0;for(const [a,b] of all){const q=Math.hypot(a.x-b.x,a.y-b.y);minLen=Math.min(minLen,q);sum+=q;}
const quad=(a,c,e,t)=>{const u=1-t;return [u*u*a.x+2*u*t*c[0]+t*t*e.x,u*u*a.y+2*u*t*c[1]+t*t*e.y];};
const SAMPLES=8;
const pathOf=e=>{const [a,f]=e;if(!e.c)return [[a.x,a.y],[f.x,f.y]];const pts=[];for(let i=0;i<=SAMPLES;i++)pts.push(quad(a,e.c,f,i/SAMPLES));return pts;};
function pathsCross(p,q){
 for(let i=0;i<p.length-1;i++)for(let j=0;j<q.length-1;j++){
  if(segCross(p[i][0],p[i][1],p[i+1][0],p[i+1][1],q[j][0],q[j][1],q[j+1][0],q[j+1][1]))return true;
 }
 return false;
}
const ptSeg=(px,py,a,e)=>distSeg(px,py,{x:a[0],y:a[1]},{x:e[0],y:e[1]});
function pathClear(p,e){
 const [a,f]=e;
 for(const n of d.nodes){
  if(n===a||n===f)continue;
  for(let i=0;i<p.length-1;i++){if(Math.abs(n.x-p[i][0])>120||Math.abs(n.y-p[i][1])>120)continue;if(ptSeg(n.x,n.y,p[i],p[i+1])<CLEAR)return false;}
 }
 return true;
}
function curveOk(e){
 const p=pathOf(e);
 if(!pathClear(p,e))return false;
 const [a,f]=e;
 for(const o of all){
  if(o===e)continue;const [c,g]=o;
  if(c===a||c===f||g===a||g===f){
   // Edges that share an acupoint may meet only there.
   const q=pathOf(o);
   if(pathsCross(p.slice(1,-1).length?p.slice(1):p,q.slice(1,-1).length?q.slice(1):q)&&pathsCross(p.slice(0,-1),q.slice(0,-1)))return false;
   continue;
  }
  if(Math.max(a.x,f.x,e.c?e.c[0]:a.x)+40<Math.min(c.x,g.x)||Math.min(a.x,f.x,e.c?e.c[0]:a.x)-40>Math.max(c.x,g.x))continue;
  if(Math.max(a.y,f.y,e.c?e.c[1]:a.y)+40<Math.min(c.y,g.y)||Math.min(a.y,f.y,e.c?e.c[1]:a.y)-40>Math.max(c.y,g.y))continue;
  if(pathsCross(p,pathOf(o)))return false;
 }
 return true;
}
const onRing=n=>isRoad(n)&&!/ [LCR]\d+$/.test(n.name)&&n.kind!=='gate';
const ringEdge=(a,f)=>(onRing(a)||onRing(f))&&isRoad(a)&&isRoad(f);
const adjOf=new Map(d.nodes.map(n=>[n,[]]));
for(const e of all){adjOf.get(e[0]).push(e[1]);adjOf.get(e[1]).push(e[0]);}
let curved=0;
for(const e of all){
 const [a,f]=e;
 if(ringEdge(a,f)){
  // The arc of the wheel: the control point sits out along the mean angle.
  const ra=Math.hypot(a.x,a.y),rf=Math.hypot(f.x,f.y),ta=Math.atan2(a.x,-a.y),tf=ta+Math.atan2(Math.sin(Math.atan2(f.x,-f.y)-ta),Math.cos(Math.atan2(f.x,-f.y)-ta));
  const half=(tf-ta)/2,rm=(ra+rf)/2/Math.max(Math.cos(half),.5),tm=(ta+tf)/2;
  e.c=[rm*Math.sin(tm),-rm*Math.cos(tm)];
 }else if(!a.fixed||!f.fixed){
  // Flow through a chain: bend toward the side the neighbours turn to.
  const na=adjOf.get(a).filter(m=>m!==f),nf=adjOf.get(f).filter(m=>m!==a);
  const dx=f.x-a.x,dy=f.y-a.y,len=Math.hypot(dx,dy)||1,px=-dy/len,py=dx/len;
  let side=0;
  for(const m of na)side+=((m.x-a.x)*px+(m.y-a.y)*py)>0?-1:1;
  for(const m of nf)side+=((m.x-f.x)*px+(m.y-f.y)*py)>0?-1:1;
  if(side===0)continue;
  const k=Math.sign(side)*len*.2;
  e.c=[(a.x+f.x)/2+px*k,(a.y+f.y)/2+py*k];
 }else continue;
 if(curveOk(e))curved++;else delete e.c;
}
// Crossings and clearance again, on the curves as drawn.
let finalCross=0,finalClose=0;
for(let i=0;i<all.length;i++){
 const e=all[i],p2=pathOf(e),[a,f]=e;
 if(!pathClear(p2,e))finalClose++;
 for(let j=i+1;j<all.length;j++){
  const o=all[j],[c,g]=o;
  if(c===a||c===f||g===a||g===f)continue;
  if(pathsCross(p2,pathOf(o)))finalCross++;
 }
}
console.log('curved',curved,'of',all.length,'| drawn crossings',finalCross,'| edges too close to a node',finalClose);
const out={
 edges:all.map(e=>e.c?[e[0].id,e[1].id,Math.round(e.c[0]*10)/10,Math.round(e.c[1]*10)/10]:[e[0].id,e[1].id]),
 nodes:d.nodes.map(n=>({i:n.id,n:n.name,k:n.kind,s:n.sector,d:n.depth,x:Math.round(n.x*10)/10,y:Math.round(n.y*10)/10,l:n.links,m:n.mods,c:n.cluster,v:n.variant,p:n.capability,e:n.desc})),
 clusters:d.clusters,variants:d.variants,elements:d.elements};
const tpl=fs.readFileSync(path.join(dir,'map_template.html'),'utf8');
fs.writeFileSync(path.join(dir,'meridian-map.html'),tpl.replace('__DATA__',JSON.stringify(out)));
let tooClose=0,worst=1e9;const offenders=new Map();
for(const n of d.nodes){for(const [c,e] of all){if(c===n||e===n)continue;if(Math.abs(c.x-n.x)>60&&Math.abs(e.x-n.x)>60&&Math.sign(c.x-n.x)===Math.sign(e.x-n.x))continue;const q=distSeg(n.x,n.y,c,e);worst=Math.min(worst,q);if(q<CLEAR){tooClose++;offenders.set(n.name+'#'+n.id,q.toFixed(1));}}}
const lens=all.map(([a,e])=>Math.hypot(a.x-e.x,a.y-e.y)).sort((p,q)=>p-q);const pct=q=>lens[Math.floor(lens.length*q)].toFixed(0);
console.log('clearance: min',worst.toFixed(1),'violations',tooClose,'of limit',CLEAR);
console.log('edge length p5/p25/p50/p75/p95:',pct(.05),pct(.25),pct(.5),pct(.75),pct(.95),'max',lens[lens.length-1].toFixed(0));
if(offenders.size)console.log([...offenders].slice(0,10).join('  '));
console.log('edges drawn',all.length,'crossings',crossings,'stuck blobs',stuck,'min edge',minLen.toFixed(1),'mean edge',(sum/all.length).toFixed(1),'extent',Math.round(Math.max(...d.nodes.map(n=>Math.hypot(n.x,n.y)))));
if(bad.length)console.log(bad.join('\n'));
