# Job transcript: content-tech-force-chaos (try 1)

I added two techniques to the force-chaos family. The lint reports 0 findings on the file, with the expected note that the whole-catalogue checks were skipped.

- **Formless Ruin Canon (Vô Hình Phế Kinh)** is the Chaos main method: Profound, kind main, 9 layers, names `hon_don`. It carries Shearing Palm at layer 1 and Bloodletting Rite at layer 3. Passives use 14.1 W of 16, and the single bonus is tam_ma_resist_pct +8.
- **Hundred Arts Sage Canon (Bách Pháp Hiền Kinh)** is the multi-element hub: Earth, kind main, 12 layers, names `hon_don`, `hoa` and `thuy`. It carries Scorch Fist (layer 1), Backwash Seal (layer 2) and Bloodletting Rite (layer 4). Passives use 22.0 W of 24: stack effect +12 % and stack duration +15 % (unscoped, so stacks of every element), chaos damage +6 %, art speed +10 %. Its two bonuses are linh_luc_pct +12 and than_thuc_pct +10.

Both records use `origin` "authored", `effects` [], `suite` "" and `family` "force-chaos".

I added a section for each to `catalogue-force-chaos.md`.

One thing to know: no unclaimed Chaos arts exist in the library. Both techniques therefore reuse loose, suite-less arts that Tearing Force Rites or other families already carry (Shearing Palm, Bloodletting Rite, Scorch Fist, Backwash Seal). The lint accepts this, but the same art now has more than one carrier.

I could only edit the Chaos-scoped passive on the hub lightly. It has a single chaos damage line, and the stack passives are what make the hub reward holding many elements.

CONTENT-DONE force-chaos
