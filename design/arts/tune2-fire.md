# Tune 2 - fire (scorch-fist)

Before:
suite_check	fire	art scorch-fist	truc_co	mean 28.8 s, typical mirror 25.6 s, x1.12 (near typical)	W-L 6-14
suite_check	fire	art scorch-fist	ket_dan	mean 20.9 s, typical mirror 20.0 s, x1.04 (near typical)	W-L 5-15

After:
suite_check	fire	art scorch-fist	truc_co	mean 29.2 s, typical mirror 25.6 s, x1.14 (near typical)	W-L 8-12
suite_check	fire	art scorch-fist	ket_dan	mean 21.1 s, typical mirror 20.0 s, x1.05 (near typical)	W-L 5-14

Changes:
- scorch-fist c_art 1.8 -> 1.88 (the most the lint allows at 2 Burn stacks / 5 s).
- scorch-fist convert share 0.5 -> 0.75 (more of the hit meets Fire defence).
- scorch-fist empower gate 20 -> 8 Burn stacks (fully Fire much sooner).
- Tried c_art 2.3 with 3 stacks: 15-4 but lint over (cap 1.72 with 3 stacks); 3 stacks and longer Burn both lower the lint cap, so reverted.
- Result is a modest gain only (6-14 -> 8-12, Kết Đan 5-14); still below even. The lint cap limits further raw power; not chased further.
- Lint: 0 findings. family-fire.md table row updated.
