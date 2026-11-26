# Brief: Vietnamese text for the world-depth events (2026-11-26)

You translate one batch of the world-depth pass's new dated events into Vietnamese and confirm who and where each one
names. The user ruled (2026-11-26) that all 277 events are translated now, in batches; the user reviews at the end.

## Your files

Only the `design/world/depth/events/<owner>.events.json` files of the owners your prompt lists. Never edit another
file: not the sect pages, not other owners' events files, not any tool. Do not run
`depth_events.py` without `--check` (the write mode regenerates every file and would clash with the other batches).
No commits, no subagents.

## The checker (run it first, and again at the end)

    python -I tools/design/world/depth_events.py --check --owner=<your owners, comma-separated>

At the start every event says "no text_vi". At the end it must print `observations: 0` for your owners.

## Every rule, in one list

1. **Fields you write**, in each event of your files:
   - `text_vi`: the Vietnamese text of `text_en`.
   - `text_vi_of`: `text_en` copied exactly, character for character (it tells the checker which English you translated).
   - `people`: the keys of the people the text names, or refers to unmistakably ("the founder" when the page says who),
     in the order they appear. Remove a wrong match; add a missing one.
   - `sects`: the keys of the sects the text names or is plainly about. Remove wrong matches, add missing ones.
   - `place`: the one place id where the event happens, or `null` if the text names no place.
2. **Fields you never change:** `id`, `year`, `span`, `kind`, `story_kind`, `tier`, `secret`, `text_en`, `page`. If one
   looks wrong, write it in your report; do not fix it.
3. **Meaning:** translate what `text_en` says, no more and no less. Do not add facts from the page, and do not drop a
   clause.
4. **Style:** plain, chronicle-like Vietnamese in the present tense, as in the existing annals. Examples from
   `assets/data/world_history.json`:
   - "Fishers on the long lake say that five years ago they saw a man walk over the water into the moon; they build a
     shrine on the shore." → "Ngư dân bên hồ dài kể rằng năm năm trước họ thấy một người bước trên mặt nước đi vào vầng
     trăng; họ dựng một miếu thờ bên bờ."
   - "The last abbot of Tê Nhạn Quán joins Trạc Anh Đài with his disciples, and the halls are left to the marsh geese."
     → "Vị quán chủ cuối cùng của Tê Nhạn Quán cùng các đệ tử gia nhập Trạc Anh Đài, để lại các tòa điện cho bầy ngỗng
     đầm lầy."
   - "Ung Hạc Minh tames a crane king that will let no one else ride it." → "Ung Hạc Minh thuần phục một hạc vương
     không cho ai khác cưỡi."
5. **Names:** every person, sect, place, item and technique name already written in Vietnamese (with tones) in
   `text_en` is kept exactly as written, and keeps its capitals when repeated ("Hỏa Đình", never "hỏa đình"). A name
   given only in English (a blade called "Three Years' Tax", an art, an array, a hall, a ford) takes its Hán-Việt name
   if the page, the techniques or items file, or `design/glossary.md` gives one; otherwise coin a **Hán-Việt** name in
   the same style ("Counting House" → "Toán Phòng"), never plain Vietnamese words ("Kho Chiến
   Lợi"), and list it in your report. A name the existing annals already render (Cold Ford is "Hàn Tân") keeps that
   rendering.
5b. **Epithets name the sect:** "the Pavilion", "the Tower", "the Pivot", "the Gate", "the Court" and the like become
   the sect's short name ("Băng Tâm Các", "Thính Vũ Lâu", "Thiên Xu"), never a bare "Các", "Lâu" or "Môn".
5c. **Titles by house:** the head of a sect is tông chủ (or chưởng môn for an academy or school); the abbot of a
   Buddhist "Tự" is trụ trì, of a Daoist "Quán" quán chủ.
6. **Cultivation words:** use the standard Hán-Việt terms (Luyện Khí, Trúc Cơ, Kết Đan, Nguyên Anh, Hóa Thần; tông
   môn, trưởng lão, tông chủ, đệ tử, động phủ, linh thạch, công pháp, pháp bảo, trận pháp). `design/glossary.md` is
   the reference.
7. **Looking things up:** the event's `page` holds its context. People: `design/world/depth/sects/*.cast.json` and
   `people/*.cast.json` (`key`, `name_hv`), plus `assets/data/world_history.json` `people` (`key`, `name`). Sects and
   places: `assets/data/world_continent.json` (`great_sects`, `minor_sects` with `key` and `name`; `places` with `id` and
   `name`). A moved seat's place is in `design/world/depth/seats.json`.
8. **Editing:** keep each file valid JSON, UTF-8, the same layout (`json.dump(..., ensure_ascii=False, indent=1)` plus
   a final newline). A short Python script that loads, edits and writes the file is fine.
9. **Rewrite, never expand:** if a draft runs long, shorten it to the English's length.

## Your report (your final message)

- the owners and event count done, and the checker's last line;
- every event where you changed `people`, `sects` or `place` from the proposal, one line each (id: what and why);
- every name you translated without a Hán-Việt source;
- anything that looked wrong in a field you may not change.
