# Build wishlist: sets-bt (personal item sets for Băng Tâm, Thúy Vi, their vassals and the clans)

Proposals for the user's review (format: `README.md` here). They come out of the personal sets written in
`sects/<key>.items.json` and `people/clans.items.json` (brief `_brief-cast-sets.md`). Each set uses the closest
existing lines for now. Nothing is added to `effects.md`, the Modifier System or the tree.

## sets-bt-01 Stillness (Tĩnh)
- **Kind**: Other (a shared combat state that set Effects can test).
- **Rule or line**: You are Still while you have cast no art for 2 s, or while you hold a sitting or standing stance.
  Being Still ends when you cast an attack art or are pushed. Set Effects then say "while Still" or "after 5 s Still".
- **Where it would live**: the combat rules (one definition), used by set bonuses, the Ice and Water lineages' sitting
  stances, and Đạo Đồ notables.
- **Fun**: the sitter's moment: the ward thickens, the counter is loaded, and the foe has to decide whether to hit it.
- **Who needs it**: `co_lang_suong`, `tiet_han_mai`, `lieu_ngu_ca` (bang_tam); `lu_doc_dieu`, `bo_toa_tuyet`
  (lanh_giang); `tong_toa_van` (van_khoi); `tieu_thua_am` (clans).
- **Why**: seven sets written here are about waiting, and each says it its own way ("cast no art for 2 s", "while you
  sit", "inside your own formation", "not attacked for 10 s"). Without one shared rule the engine needs seven timers.

## sets-bt-02 Banked charges (Tích)
- **Kind**: Effect (a shared rule for stored charges).
- **Rule or line**: Some Effects bank a charge on a timer or a trigger (a Cloud, a seed, a toll), up to a cap, and
  spend all of them at once for a payoff that scales with the number spent.
- **Where it would live**: the combat rules; first users are set bonuses (Sit as Thôi Sat, Outlast the Drought,
  Pillar in the Flood).
- **Fun**: a visible counter that fills while you hold out and empties in one burst.
- **Who needs it**: `tong_toa_van` (van_khoi, Clouds), `luc_thuong_lam` and `on_trong_luong` (clans).
- **Why**: Tống's Sitting Cloud Canon already banks Clouds, but only for his own technique. The sets need the same
  thing for other counters; stack lines (`stack_grant`) cover debuffs and buffs, not stored payoffs.

## sets-bt-03 Fishing rod (Cần Câu), an item base with a line
- **Kind**: Item (a new base in `design/items/bases.json`).
- **Rule or line**: A line weapon: its art hooks a foe, and a hooked foe cannot leave reach and can be dragged in
  (pulled to you, interrupting its art). Modifiers like a needle's, plus status duration.
- **Where it would live**: item bases; the Ice Hook (`lg-ice-hook`, now on `cham`) and the lost relic of the frost
  coast, Liễu Thoa Lạp's lone fisher's rod, which Liễu Ngư Ca is looking for.
- **Fun**: the fisher's fight: hook, wait, pull.
- **Who needs it**: `lu_doc_dieu` (lanh_giang), `lieu_ngu_ca` (bang_tam); `doan_thanh_lang` (trac_anh) uses the
  same line idea on a harpoon (`mao`, with the The Line Holds Effect).
- **Why**: no base carries a line, so the hook sits on a needle and the harpoon's pin is written into Effects.

## sets-bt-04 Displacement (push, pull, root) and Unmoved (Bất Động)
- **Kind**: Other (combat rule) and an Effect line.
- **Rule or line**: Arts may push a foe back or pull it in; a rooted foe cannot be moved; Unmoved makes you immune to
  push and pull. Set Effects test it ("you cannot be pushed back", "you cannot be moved").
- **Where it would live**: the combat rules, then set bonuses and the Wood and Earth lands' guard notables.
- **Fun**: the doorway that cannot be passed and the pillar in the flood feel solid only if something tries to move
  them.
- **Who needs it**: `manh_tinh_chi` (le_hoa), `on_trong_luong` (clans), `luc_thanh_sam` (ho_lam), `cu_thuy_bach`
  (thuy_vi).
- **Why**: rooting exists for Wood builds, but nothing pushes, so "cannot be moved" in four set Effects has nothing to
  stop yet. If the engine stays without displacement, these clauses should become block or damage-taken lines.

## sets-bt-05 Black Ice (Hắc Băng Quyết), a hidden Ice-Darkness method
- **Kind**: Technique (a secret method, not the Pavilion's).
- **Rule or line**: An Earth-tier method running on Ice and Darkness together: Ice stacks you lay also count as
  curses, and a foe frozen while cursed takes Darkness damage when the freeze ends.
- **Where it would live**: a found or stolen manual (a hook for her story), not Băng Tâm's lineage.
- **Fun**: the Ice caster whose frost turns black when nobody is watching.
- **Who needs it**: `cung_mac_suong` (bang_tam), whose want is "to stop starving half of her root".
- **Why**: her set (Black and White Stones) lets curses count as Ice debuffs, which is the most an item can do. The
  Darkness half of her root still has no method that feeds it beside the Winter Toll Canon.
