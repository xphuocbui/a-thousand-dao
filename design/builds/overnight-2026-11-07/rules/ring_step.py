"""Ring Step (Hoàn Bộ): Combat rule 6, a share of a hit moved one step along the generating cycle.

Used when the whole hit converts, so the converted part is the whole art and keeps its old tags.
The rows it unlocks are the next element's, and they read only through this step, so they are
written under "ring_mods" and join conditional_mods when this plug-in runs. `--without ring_step`
then removes the crossing and nothing else. Act only for a side whose spec lists ring_mods.
"""


def install(f):
    Base = f.Side

    class Side(Base):
        def __init__(self, spec, name):
            super().__init__(spec, name)
            mods = spec.get("ring_mods")
            if mods:
                self.conditionals = list(self.conditionals) + list(mods)

    f.Side = Side
