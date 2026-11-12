# Build Content Ledger

> **Status**: Proposals. Nothing here is in game data or a GDD unless its State says `promoted`.
> **Purpose**: What the build sessions have made, so a new build reuses pieces instead of inventing
> near copies. Modifier definitions live in `design/quick-specs/tree-modifier-catalogue.md`; this file
> records who uses them.
> **Rule**: rows are added, and `Used by` grows. A row is never rewritten by a later build.

## Builds

| Build | Channel | Enabler | Identity piece | Sheet |
|---|---|---|---|---|
| The Burial Shroud (pilot) | Tick, then hits | Grave-Silk Shroud | Spillover | [burial-shroud.md](burial-shroud.md) |
| The Ninth Bell (pilot) | Art hit | None | On the Beat | [ninth-bell.md](ninth-bell.md) |

## Modifiers

| Modifier | Form | Channel | Layer | Fit | Used by | Second home | State |
|---|---|---|---|---|---|---|---|
| Spillover (Dật Độc) | Overflow | tick | none | Needs rule | Burial Shroud | any poison build | proposal |
| Bare Vessel (Lộ Đỉnh) | Conditional | art, basic | L5 | Needs key | Burial Shroud, Ninth Bell | any ward-breaker | proposal |
| Rot Deepens (Thi Độc Thâm) | More | tick | L2 | Needs key | Burial Shroud | any poison build | proposal |
| Corpse-Wax Coating (Thi Lạp) | More | tick | L4 | Needs key | Burial Shroud | any poison build | proposal |
| Damage over time | Increased | tick | L1 | Needs key | Burial Shroud | any poison build | catalogue row |
| On the Beat (Hợp Tiết) | Conditional | art | L5 | Needs rule | Ninth Bell | any fast-art build | proposal |
| Sustained Note (Dư Âm) | Per | art | L2 | Needs key | Ninth Bell | Late Bloom builds | proposal |
| Tolled Seal (Chung Ấn) | More | art | L2 | Needs key | Ninth Bell | any seal build | proposal |
| Ringing Ground (Hưởng Địa) | More | art | L4 | Needs key | Ninth Bell | any seal build | proposal |

## Enablers

| Enabler | Kind | Lives on | Opens | Closes | Used by | State |
|---|---|---|---|---|---|---|
| Grave-Silk Shroud (Liệm Thi Y) | New channel | Named artifact, `giap` base | A permanent tick with no slot | 25 % of linh lực reserved | Burial Shroud | proposal |

## Other pieces

| Piece | Type | Fit | Used by | State |
|---|---|---|---|---|
| Withered Mound Sutra (Khô Trủng Kinh) | Technique | Needs key | Burial Shroud | proposal |
| Nine-Toll Timetable (Cửu Hưởng Thời Khắc Biểu) | Technique | Needs key | Ninth Bell | proposal |
| Grave Wind, Bier Hush, Closing the Lid | Arts | Needs key | Burial Shroud | proposal |
| First Toll, Second Toll, Great Toll | Arts | Needs key | Ninth Bell | proposal |
| Sick Meridians (Bệnh Mạch) | Cluster idea | Needs key | Burial Shroud | proposal |
| Measured Breath (Điều Tức) | Cluster idea | Needs rule | Ninth Bell | proposal |
| Death Đạo, Burial branch | Đạo proposal | Needs rule | Burial Shroud | proposal |
| Time Đạo, Rhythm branch | Đạo proposal | Needs key | Ninth Bell | proposal |

## New concepts

| Concept | Rule needed | Serves | State |
|---|---|---|---|
| Reservation | Combat rule 11 | Burial Shroud, held formations, kept wards | Question for the user |
| Permanent status (aura) | Combat rule 7 | Burial Shroud, any standing curse | Question for the user |
