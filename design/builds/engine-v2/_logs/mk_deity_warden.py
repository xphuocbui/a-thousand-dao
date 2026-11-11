import json
src = json.load(open('design/builds/overnight-2026-11-10/builds/deity-warden.fight.json'))
src.pop('arts'); src.pop('unmodelled')
src['purity'] = {"metal": 80, "earth": 70}
src['techniques'] = ["mountain-heart-canon", "iron-hide-manual", "mountain-bone-body-art"]
src['arts'] = [{"lib": a} for a in ["mountain-stance", "sinking-weight", "bastion-reprisal", "strata-hammer",
                                    "iron-hide-stance", "mountain-root-stance", "bone-turning-palm"]]
src['unmodelled'] = [
    "ward model change at each phase (per-hit, drain, soul, off): the file holds one drain ward, the phase-I-to-IV average",
    "Phase script and the 12 s phase clock (Needs rule)",
    "Soul ward and Deaf Verdict (soul art): soul is not modelled",
    "Per-hit ward payload of the Iron Gate phase",
    "Purge bell as a timed full strip (no library art cleanses on a 10 s clock)",
    "Open Hand phase (no ward, doubled offence)"]
json.dump(src, open('design/builds/engine-v2/builds/deity-warden.fight.json', 'w'), indent=1)
src['realm'] = 'nguyen_anh'
json.dump(src, open('design/builds/engine-v2/builds/deity-warden.nguyen-anh.fight.json', 'w'), indent=1)
