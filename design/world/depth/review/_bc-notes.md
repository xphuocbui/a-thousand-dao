# Notes for the B+C writers, collected from pass A
- tp batch: Phần Vũ's page still treats its province as an open question; the ruling (DECISIONS group 2 / Provinces
  rule 2a): Phượng Minh takes the province as its seat province, Phần Vũ keeps its seat as a vassal. Write it in.
- tp batch: Phí Thoa Y (A, Xuyên Lâm) has no staff (gear holds split sets): give a set piece the staff role or rework.
- all batches: new beast records exist (`design/world/depth/**/*.beasts.json`): add a `beasts: [ids]` field to each
  tamer's record in your batch (ta_thanh_loan: tieu_loan, que_tuoc, mac_vu; ta_thanh_thuoc: quy_thuoc; khau_muc_van:
  dap_van; tan_thien_ly: hong_tong; cu_van_ly: han_vu; mai_lo_tuyet: bat_phi; vu_ngo_dong: xich_quan, tieu_vi;
  an_thuy_vu: ngu_cau; lam_tuyet_dieu: ngoc_dieu, han_tich; lo_da_huong: ngan_ti; uong_muc_dich: lao_hoang; doan_to_ba:
  lang_nhi, tiem_nhi; diem_lac_nhan: thuong_muc; quan_tuyet_tung: tiem_anh; an_thu_son: bat_phe).
- all batches: the authored source records now bound d21 (Momentum decay), d23 (compounding discount), d43 (Heat past
  5) and e8 (pay_per_stack): copy those bounds into the wired copies in your batch's items/techniques files
  (grep `"authored": "d21"` etc.).
- tx batch: Phùng Xích Kim's knowledge (a leaked secret) left for pass B; eight early deaths got placeholder causes in
  pass A: give them real ones in the sect's story.
- bt batch: N-vu_an-02 still says "two boys" (conflicts with the cast).
- chronicle (existing, assets/data/world_history.json): C023 has Lôi Vô Danh die of old age at 390 (below his realm's
  lifespan): propose a rewording in the World Generation export list (depth pages own nothing there).
- open: `tx-iron-horse-tally` has no base (tally base missing: Item DB OQ 27); catalogue `debt-ledger-blade` (design/
  techniques, not depth) keeps "5 Debts" for the catalogue pass.
- bt batch: **the Frost Test lake Phiến Băng Hồ (191) is ~3,000 km from the new seat (214)**: move the Frost Test to ice
  near the seat (a lake or glacier place near 214 in region 7; pick by place id from `_inputs/bang_tam.json`), and
  update every mention (bang_tam.md §4/§6/§7, cast homes at 191, the Frost Test people). Phiến Băng Hồ can stay a
  pilgrimage or a vassal's water.
- bt batch: review pass A's own inventions: the death causes of cong_thu_nhat, luc_da_coc, nhan_du_ti; hoa_tuyet_nghi
  born 1177 -> 1182; Tiết Hàn Mai's Array date 760 -> 820 (and three items).
- cross: caps remain in builds/duel-readings.md (lines ~189, 197) and builds/authored/ (orchestrator sweeps).
- "two boys" line is in people/loose-north.md (tx batch), not vu_an.
