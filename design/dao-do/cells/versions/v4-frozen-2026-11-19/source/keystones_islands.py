"""Keystones on the three islands, 2026-11-19 (user: "Keystones should connect directly to the travel nodes like in PoE,
and add more"): each hung straight off one road node, clear of everything round it (1.6+), picked by eye among free spots
(tools/design/dao_do_rework/underlay/ks_find.py). Light (931): a pair either side of the road where the sun joins the tree (its
axis has no free spot); Thunder (932): at the top end of its arc; the Moon (933): a pendant below the crescent, on its
axis, off 601."""
THEME = 'island'
CELLS = {
    931: {
        'keystone_gate_R': ({'k': ((2.7, 94.0), 'keystone')}, [(549, 'k', None)]),
        'keystone_gate_L': ({'k': ((-2.7, 94.0), 'keystone')}, [(549, 'k', None)]),
    },
    932: {
        'keystone_tip': ({'k': ((-100.965, -51.683), 'keystone')}, [(578, 'k', None)]),
    },
    933: {
        'keystone_pendant': ({'k': ((0.0, -88.1), 'keystone')}, [(601, 'k', None)]),
    },
}
