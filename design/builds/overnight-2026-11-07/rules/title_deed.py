"""Title Deed (Địa Khế): a Borrow. While a formation you hold title to stands, your arts with an
authored cooldown of "min_cooldown" seconds or more count as carrying the formation source tag.

Asked for with "title_deed": {"min_cooldown": 6}. Load it after laid_ground. It only marks the art
"laid", so Old Bund, Deep Bund and Standing Water (laid_ground.py) read it as their own. Unlike a laid
art, a deeded art is a real art: in a blind fight, or an ambush with no standing formation, it loses
the tag and keeps firing as authored. `--without title_deed` takes the tag away everywhere.
"""


def install(f):
    Base = f.Side

    class Side(Base):
        def __init__(self, spec, name):
            deed = spec.get("title_deed")
            s = spec.get("situation", "foreseen")
            if deed and (s == "foreseen" or (s == "ambush" and spec.get("standing"))):
                least = deed.get("min_cooldown", 0)
                spec = dict(spec, arts=[dict(a, laid=True) if a.get("c_art", 0) > 0 and a["cooldown"] >= least else a
                                        for a in spec.get("arts", [])])
            super().__init__(spec, name)

    f.Side = Side
