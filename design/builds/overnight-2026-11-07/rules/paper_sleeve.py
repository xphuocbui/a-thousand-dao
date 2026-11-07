"""The paper sleeve: capability #13 (Endless Talismans) and the rows that read it.

Asked for with "unburnt": {"keep": 0.3, "ride": true}. An art with "talisman": true counts.
  keep  the chance a used talisman is not consumed. The calculator has no dice, so this runs
        as an expected value, as crit does: each firing burns 1 - keep of a paper, and a kind
        with under half a paper left is out.
  ride  Let It Ride: a paper that came back fires once more in the same instant. Run as an
        extra firing at keep of its size. It re-lands the hit, the status chance and any
        refund, not the curse. It cannot come back itself: one trigger, once in a chain.
Also adds the "per" scale "papers_fired", for Warm Hand, and prints the paper lines. List it
before per_cap. A spec with no "unburnt" key still counts paper, with keep 0.
"""


def install(f):
    resolve_art, scale_value = f.resolve_art, f.scale_value
    report_result = f.report_result

    def counts(s):
        if not hasattr(s, "paper_fired"):
            s.paper_fired = 0.0
        return s

    def ride_copy(art, keep):
        extra = dict(art)
        extra.pop("curse", None)
        extra["c_art"] = art.get("c_art", 0) * keep
        extra["applies"] = [dict(st, chance=st.get("chance", 1.0) * keep) for st in art.get("applies", [])]
        if art.get("refund_qi_share"):
            extra["refund_qi_share"] = art["refund_qi_share"] * keep
        return extra

    def resolve(att, dfn, art, t, gap):
        if not art.get("talisman"):
            return resolve_art(att, dfn, art, t, gap)
        counts(att).paper_fired += 1
        resolve_art(att, dfn, art, t, gap)
        spec = att.spec.get("unburnt")
        if not spec:
            return None
        keep = spec.get("keep", 0)
        if art.get("stock_left") is not None:
            art["stock_left"] += keep
            if art["stock_left"] < 0.5:
                art["stock_left"] = 0
        if spec.get("ride") and keep:
            att.paper_fired += keep
            resolve_art(att, dfn, ride_copy(art, keep), t, gap)
        return None

    def scale(c, att, dfn, t):
        if c.get("per") == "papers_fired":
            return c.get("points_per", 0) * counts(att).paper_fired
        return scale_value(c, att, dfn, t)

    def report(res, build):
        report_result(res, build)
        a = res["a"]
        papers = [x for x in a.arts if x.get("talisman")]
        if papers:
            burnt = [(x["id"], len(x["fired"]) * (1 - (a.spec.get("unburnt") or {}).get("keep", 0)))
                     for x in papers]
            print("paper\tstock %d\tburnt %.1f\tfirings %.1f" % (
                sum(x.get("stock", 0) for x in papers), sum(v for _, v in burnt),
                counts(a).paper_fired))
            print("paper_burnt\t" + "\t".join("%s %.1f" % kv for kv in burnt))

    f.resolve_art, f.scale_value, f.report_result = resolve, scale, report
