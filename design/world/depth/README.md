# World depth pass (overnight 2026-11-24/25)

> **Status**: Done (overnight 2026-11-24/25), awaiting the user's review. Proposals only: no GDD, `assets/data`,
> `design/items` or code edits, no commits. The user reviews in the morning.
> **Ask** (user, 2026-11-24/25): the world feels unconnected and shallow. Sects whose members don't match their
> element, seats on the wrong land, a thin cast, shallow traits, no signature items. "Don't stop at 100 cast, go 1000
> 2000."

## Files

| File | What |
|---|---|
| `rules-proposals.md` | R1-R8: roots follow the land, admission by công pháp, no-lean sects, seats on fitting land, sect lineages, traits v2, item sets, cast scale |
| `traits-v2.md`, `traits-v2.json` | the new trait kinds and catalogue (upbringing, talent tiers, path, lifestyle, health, coping) |
| `schema.md` | the file formats every content file follows |
| `seat-audit.md` | every seat's land fit and candidates (generated: `tools/design/world/depth_seat_audit.py`) |
| `quotas.json` | realm quotas per sect for the authored living cast |
| `sects/<key>.md` | a sect's page: land, history, doctrine, lineage, admission, halls, relations, inside, treasures, roster, hooks |
| `sects/<key>[.<n>].cast.json` | its people |
| `sects/<key>.techniques.json` | its lineage and proposed techniques |
| `sects/<key>.items.json` | its signature items and sets |
| `people/<group>.*` | people outside sects (loose cultivators, clans, merchant houses, hermits, demonic circles) |
| `_inputs/` | per-sect slices of the history and land (generated: `tools/design/world/depth_inputs.py`) |
| `cross-sect.md` | the cross-sect pass: ties, marriages, rivalries across files (last) |
| `SUMMARY-2026-11-25.md` | **the morning summary: counts, where to read, decisions for the user** |

Check everything with `python -I tools/design/world/depth_check.py`.

## Stages and progress

| Stage | What | State |
|---|---|---|
| 0 | Frame: rules, traits v2, schema, audit, inputs, checker, quotas | done |
| 1 | Pilot: Băng Tâm Các (by hand) | done: 73 people (A10 B10 C53) |
| 2 | Smoke test: one writer agent on one great sect | done: Thúy Vi Tông, 76 people (70 living), clean |
| 3 | The other six great sects | done: all seven great sects written, clean |
| 4 | The 43 minor sects (each with its lord's context) | done: all 43, clean; 11 no-lean |
| 5 | People outside sects | done: hermits-sages, demonic, market-folk, clans (6), loose-north, loose-south |
| 6 | Wave 2: tier C fill of the great sects' gates (`<key>.4.cast.json`) | done: +315 (all 7 at TC 45 / LK 55) |
| 6b | Wave 3: tier C fill of the minor sects (`<key>.5.cast.json`, +2 TC +5 LK each) | done: +301; world 1,889 people |
| 7 | Cross-sect pass, checker clean, morning summary | done: ~2,100 far-side ties added, checker clean, `SUMMARY-2026-11-25.md` |

## Outside-sect groups (stage 5 plan)

| Group | Existing members | New quota (NA / KD / TC / LK) |
|---|---|---|
| `hermits-sages` | mac_quy_khu (HT), tu_khong_hac_nien, doan_thuong_hai; dead abode owners hoac_han_quang, cao_dan_ha, cung_hoa_van, luong_lac_mai | 1 / 3 / 6 / 4 |
| `demonic` | trieu_huyet_y; dead mac_huyet_sinh | 0 / 4 / 10 / 10 |
| `market-folk` | lac_dan_thanh, gia_hoi_xuan, kim_van_ly, ve_van_co | 0 / 4 / 12 / 15 |
| `clans` (cultivating families in cities: the Tiêu of Hòe Âm and others) | | 0 / 5 / 15 / 30 |
| `loose-north` (regions 1-9) | lam_da_hac if his home is there | 0 / 2 / 8 / 20 |
| `loose-south` (regions 10-20) | | 0 / 2 / 8 / 21 |

## New sects and keys this pass introduces

- `lanh_huong`: Lãnh Hương Các, a fallen plum-blossom sword sect (ruin place 1412), destroyed at Cô Thành in 724
  (Băng Tâm page). To add to `fallen_sects` when approved.

## No-lean sects (R3)

- `trac_anh` Trạc Anh Đài: body sect of sea hunters, recruits by bone and kin (no Ice in its whole region).
- `tam_kiem` Tầm Kiếm Đường: sword school, recruits by comprehension (ngộ tính).
- `van_khoi` Vân Khởi Quán: soul/heart school on a Metal seat, recruits by Dao heart (đạo tâm).
- `nhan_tran` Nhạn Trận Môn: drills mortal levies of every root (body art + element-free formation arts).
- `xuyen_lam` Xuyên Lâm Môn: staff-and-footwork school, by bone and kin.
- `thu_phan` Thu Phần Các: soul-and-song school of the graves (the head keeps Darkness as her own root).
- `vong_trieu` Vọng Triều Đường: admits by oath and kin (seal, soul and body methods).
- `van_hac` Vạn Hác Viện: zither song arts, recruits by ear.
- `tuan_tung` Tuần Tùng Đường: body school, staff and bow.
- `chan_kim` Chân Kim Các: assay house, recruits by the eye and by kin.
- `muc_van` Mục Vân Trang: body sect of herders (no wind qi in its ground; Wind stays the head's gift).

## Decisions for the user (collected)

1. **Seat moves** (R4): Băng Tâm → Hồ Thiên Phái (214), with the head's sanctum on Băng Bích Nhai (1393). The
   founder's Jade Vessel Array keeps the density near the old seat's (proposal `seat_array_density`). Thúy Vi →
   Cổ Dịch Trấn (1110), moved 1001-1006; the old ridge seat becomes the Cliff Hall (a faction). Thính Vũ Lâu →
   Thần Cổ Phong (874, Metal 45 %, Thunder 40) in 1166 **and re-leans Metal/Water/Thunder → Metal/Thunder** (no
   place in its ground holds all three); the volcano tower stays as the Rain Tower.
   Băng Tâm vassals: Lê Hoa Am → glacier Lăng Tuyệt Phong (184), re-leans Ice/Metal; Trấn Sa re-orders Earth/Metal;
   Dạ Quang stays (Fire/Metal); Lãnh Giang stays (Water only: its licence reserves Ice to the Pavilion).
2. **Traits v2 open points** (`traits-v2.md`).
- **Thiên Xu proposals needing your eye**: hidden event N-thien_xu-04 keeps A087 ("the vein guard has never been
  withdrawn") literally true (the guard went to Chiết Kích in 803 and never came back; the 1188 refusal rests on it);
  "the Confirmation" (since 760 the seven great sects confirm the Pivot's head); the Thiết Mã tally becomes split (a
  legendary item change). Tùng Đào and Thiên Xu seats stay.
- **Lạc Hà** → Vân Kiều Trấn (558, region 13) in 1185 with a Cloud Bridge Array (density ~1.66 vs 1.72); the old
  seat (4) becomes the outer gate; A190 rewording proposed.
- **Phượng Minh** → Hỏa Ti Trấn (449, Fire 47 %) in 1162; ridge seat (6) becomes the Wutong Court; Nest Array +0.65
  density proposed; **449 lies in vassal Phần Vũ's province** (Provinces #48 decision).
- **R1 × R2 tension (Fire)**: no inhabited land is strongly Fire (villages ≤ 24 %), so Fire sects draw from even land;
  consider a smaller k_land for Fire or a 'hearth' rule (forges, volcano towns).
3. **Cast scale** (R8): about 1,500 authored people in tiers A/B/C, against the GDD's 60-100.
