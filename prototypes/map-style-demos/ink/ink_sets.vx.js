const MAPS = [{"name": "A", "title": "Thanh Vân (temperate continent)", "w": 28, "h": 18, "terrain": ["~~~~wwwww~~wwwwww~~~~~~~~~~~", "~~wwwiiiwwwwiiimwwwwww~~~~~~", "~~wiiiiiiiiimmmmmmmmmwww~~~~", "~~wiiiiiiiiimmmmmmmvvmmww~~~", "~~wbgffffgggmmmmmmmmmmmbww~~", "~~wbffffffgggmmmmmmmmmmgbw~~", "~wwbfffffffghhhmmmhhhhhgbww~", "~wbgffffffgggghhhhhhhhgggbww", "wwbgssfffggggwgggggdddddggbw", "wbbssssgggggwwwgggdddddddbww", "wbwssssggggggwggggddddddbww~", "wwbssssjjjjgggggggddddddbww~", "~wwbsjjjjjjjjjgggggddddbwbw~", "~~wwbjjjjjjjjjgggggggbbwbww~", "~~~wwbjjjjjjjjggggggbwwwww~~", "~~~~wwbbbbbgbbggbbbbww~~~~~~", "~~~~~wwwwwwbwwbbwwwww~~~~~~~", "~~~~~~~~~~wwwwwww~~~~~~~~~~~"], "road": [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 2, 10, 10, 10, 10, 10, 12, 0, 0, 0, 0, 0, 7, 10, 10, 10, 8, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 10, 10, 10, 10, 10, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]], "river": [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 10, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]], "road_paths": [[[5, 8], [6, 8], [7, 8], [8, 8], [9, 8], [10, 8], [11, 8], [11, 9], [11, 10], [11, 11], [12, 11], [13, 11], [14, 11], [15, 11], [16, 11], [17, 11], [17, 10], [17, 9], [17, 8], [18, 8], [19, 8], [20, 8], [21, 8]], [[11, 11], [11, 12], [11, 13], [11, 14], [11, 15]], [[17, 8], [17, 7], [17, 6]]], "river_paths": [[[16, 4], [16, 5], [16, 6], [16, 7], [15, 7], [14, 7], [14, 8]], [[13, 10], [13, 11], [13, 12], [13, 13], [13, 14], [14, 14], [14, 15], [14, 16]]], "places": [{"x": 11, "y": 11, "kind": "city", "name": "Thanh Vân Thành"}, {"x": 5, "y": 8, "kind": "town", "name": "Liễu Trấn"}, {"x": 17, "y": 6, "kind": "sect", "name": "Vân Kiếm Tông"}, {"x": 19, "y": 4, "kind": "mine", "name": "Xích Thạch Khoáng"}, {"x": 7, "y": 5, "kind": "abode", "name": "Tùng Động"}, {"x": 22, "y": 11, "kind": "ruin", "name": "Sa Mạc Di Tích"}, {"x": 9, "y": 4, "kind": "blessed", "name": "Thanh Mộc Phúc Địa"}, {"x": 21, "y": 8, "kind": "town", "name": "Sa Khẩu Trấn"}, {"x": 11, "y": 15, "kind": "vein", "name": "Mộc Linh Mạch"}]}, {"name": "B", "title": "Bích Hải (island chain)", "w": 28, "h": 18, "terrain": ["~~~~~~~~~~~~~~~~~~~~~~~~~www", "~~~~wwww~~~~wwwwwww~~~~~wwbw", "~~wwwbbwwwwwwbbbbbww~~~~wbdb", "~~wbfffbbbwwbjjjjjbwwwwwwwbw", "~wwfffffgbwwwbjjjbwwbbbwwwww", "~wbgfffgggbwwbbbbbwbmmmbw~~~", "~wbggggggbbwwwwwwwwbmvmbw~~~", "~wwbbgggbwww~~~~~~wbmmmbw~~~", "~~wwwbbbwwwwwwwww~wwbbbww~~~", "~~~~wwwwwbhbbbbbww~wwwww~~~~", "~~~~~~~wbhhhggggbw~~~~~~~~~~", "~~~~~~~wbghjjjjjbw~~~~www~~~", "~~wwwwwwbbgjjjjbww~~wwwbwww~", "~wwssswwwwbjbbbbw~~~wbbgbbw~", "~wsssssw~wwbwwwww~~~wbgggbw~", "~wwsssww~~www~~~~~~~wbbgbbw~", "~~wwwww~~~~~~~~~~~~~wwwbwww~", "~~~~~~~~~~~~~~~~~~~~~~www~~~"], "road": [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 2, 10, 10, 10, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 10, 10, 10, 10, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]], "river": [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 3, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]], "road_paths": [[[4, 5], [5, 5], [6, 5], [7, 5], [8, 5], [8, 6], [8, 7]], [[9, 11], [10, 11], [11, 11], [12, 11], [13, 11], [14, 11], [14, 12], [14, 13]]], "river_paths": [[[5, 3], [5, 4], [5, 5], [5, 6], [6, 6], [6, 7], [6, 8]]], "places": [{"x": 8, "y": 7, "kind": "town", "name": "Bích Hải Cảng"}, {"x": 4, "y": 5, "kind": "abode", "name": "Tây Đảo Động"}, {"x": 9, "y": 11, "kind": "city", "name": "Trung Châu Thành"}, {"x": 14, "y": 13, "kind": "vein", "name": "Thủy Linh Mạch"}, {"x": 22, "y": 7, "kind": "mine", "name": "Hỏa Đảo Khoáng"}, {"x": 23, "y": 14, "kind": "sect", "name": "Hải Nguyệt Tông"}, {"x": 15, "y": 3, "kind": "ruin", "name": "Cổ Thụ Di Tích"}, {"x": 26, "y": 2, "kind": "blessed", "name": "Kim Sa Phúc Địa"}, {"x": 4, "y": 14, "kind": "abode", "name": "Đầm Ẩn Cư"}]}, {"name": "C", "title": "Băng Nguyên (cold highland)", "w": 28, "h": 18, "terrain": ["~~~~~~~~~wwwwwwwww~~~~~~~~~~", "~~~~~~wwwwiwiiiiiwwww~~~~~~~", "~~~~wwwiiiiiiiiiiiiiww~~~~~~", "~~~wwiiiiiiiiiiiiiiiiwww~~~~", "~~~wiiiiiiiiiiiiiiiiiiiwww~~", "~wwwtttttiiiiiiiiiittttbbww~", "wwttmmmmmtttttttttttmmmmtbww", "wbgmmmmmmmtthhhtttmmmmmmmgbw", "wbmmmmmmmmmhhhhhgmmmmmmmmmbw", "wwbmmmmmmmhhhwhhhgmmmmmmmgbw", "wbggmmmmmgghwwwhgggmmmmgggbw", "wwbgggggffgghwhggggggggggbww", "~wwbggffffffgggggggggggggbw~", "~~wbggfffffffgggsssssssgbww~", "~~wwbbffffffggggsssssssbww~~", "~~~wwwbgfgggggggssssssbww~~~", "~~~~~wwbbbbbggbbbbbwwwww~~~~", "~~~~~~wwwwwwbbwwwwww~~~~~~~~"], "road": [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 10, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 2, 10, 10, 10, 11, 10, 10, 10, 14, 10, 10, 10, 10, 10, 10, 10, 10, 9, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]], "river": [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 10, 10, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]], "road_paths": [[[5, 12], [6, 12], [7, 12], [8, 12], [9, 12], [10, 12], [11, 12], [12, 12], [13, 12], [13, 13], [13, 14], [13, 15]], [[13, 12], [14, 12], [15, 12], [16, 12], [17, 12], [18, 12], [19, 12], [20, 12], [21, 12], [22, 12], [22, 11], [22, 10]], [[9, 12], [9, 11], [9, 10], [9, 9], [9, 8], [9, 7], [9, 6], [10, 6], [11, 6]]], "river_paths": [[[13, 4], [13, 5], [13, 6], [13, 7], [13, 8]], [[14, 11], [14, 12], [14, 13], [15, 13], [16, 13], [17, 13], [17, 14], [17, 15], [17, 16]]], "places": [{"x": 13, "y": 12, "kind": "city", "name": "Bắc Nguyên Thành"}, {"x": 5, "y": 12, "kind": "town", "name": "Tùng Lâm Trấn"}, {"x": 22, "y": 10, "kind": "mine", "name": "Hàn Thiết Khoáng"}, {"x": 11, "y": 6, "kind": "sect", "name": "Băng Tâm Cung"}, {"x": 7, "y": 3, "kind": "ruin", "name": "Băng Phong Di Tích"}, {"x": 18, "y": 3, "kind": "blessed", "name": "Hàn Ngọc Phúc Địa"}, {"x": 13, "y": 15, "kind": "town", "name": "Nam Độ Trấn"}, {"x": 20, "y": 15, "kind": "abode", "name": "Đầm Lầy Động"}, {"x": 16, "y": 8, "kind": "vein", "name": "Hàn Linh Mạch"}]}];
const T = 24;
const MG = 26;
const isLand = (c) => c !== "~" && c !== "w";
// Smooth coastlines: a Gaussian field over cell centres, contoured with marching squares.
function makeField(MP, pred, sigma, step, seed) {
  const W = MP.w * T, H = MP.h * T;
  const nx = Math.ceil(W / step) + 1, ny = Math.ceil(H / step) + 1;
  const cells = [];
  for (let y = 0; y < MP.h; y++) for (let x = 0; x < MP.w; x++) if (pred(MP.terrain[y][x], x, y)) cells.push([x * T + T / 2, y * T + T / 2]);
  const f = new Float32Array(nx * ny);
  const r2 = (3 * sigma) ** 2;
  for (let j = 0; j < ny; j++) for (let i = 0; i < nx; i++) {
    const px = i * step, py = j * step;
    let v = 0;
    for (const [cx, cy] of cells) { const d2 = (px - cx) ** 2 + (py - cy) ** 2; if (d2 < r2) v += Math.exp(-d2 / (2 * sigma * sigma)); }
    f[j * nx + i] = v + noise(px / 40, py / 40, seed) * 0.12;
  }
  return { f, nx, ny, step };
}
function contours(F, thr, ox, oy) {
  const { f, nx, ny, step } = F;
  const v = (i, j) => (i < 0 || j < 0 || i >= nx || j >= ny) ? -1 : f[j * nx + i];
  const segs = new Map();
  const key = (x, y) => Math.round(x * 100) + "," + Math.round(y * 100);
  const edge = (i0, j0, i1, j1) => { const a = v(i0, j0), b = v(i1, j1); const t = (thr - a) / (b - a); return [(i0 + (i1 - i0) * t) * step, (j0 + (j1 - j0) * t) * step]; };
  const add = (p, q) => { const kp = key(...p), kq = key(...q); (segs.get(kp) || segs.set(kp, []).get(kp)).push([q, kq, p]); (segs.get(kq) || segs.set(kq, []).get(kq)).push([p, kp, q]); };
  for (let j = -1; j < ny; j++) for (let i = -1; i < nx; i++) {
    const a = v(i, j) > thr, b = v(i + 1, j) > thr, c = v(i + 1, j + 1) > thr, d = v(i, j + 1) > thr;
    const idx = (a ? 8 : 0) | (b ? 4 : 0) | (c ? 2 : 0) | (d ? 1 : 0);
    if (idx === 0 || idx === 15) continue;
    const T_ = () => edge(i, j, i + 1, j), R_ = () => edge(i + 1, j, i + 1, j + 1), B_ = () => edge(i, j + 1, i + 1, j + 1), L_ = () => edge(i, j, i, j + 1);
    const tab = { 1: [[L_, B_]], 2: [[B_, R_]], 3: [[L_, R_]], 4: [[T_, R_]], 5: [[L_, T_], [B_, R_]], 6: [[T_, B_]], 7: [[L_, T_]],
      8: [[L_, T_]], 9: [[T_, B_]], 10: [[L_, B_], [T_, R_]], 11: [[T_, R_]], 12: [[L_, R_]], 13: [[B_, R_]], 14: [[L_, B_]] };
    for (const [g1, g2] of tab[idx]) add(g1(), g2());
  }
  const used = new Set(); const loops = [];
  for (const [k0, list] of segs) {
    for (const [q0, kq0, p0] of list) {
      const ek = k0 + ">" + kq0; if (used.has(ek)) continue;
      const pts = [p0, q0]; used.add(ek); used.add(kq0 + ">" + k0);
      let prevK = k0, curK = kq0, cur = q0;
      for (let n = 0; n < 5000; n++) {
        const nexts = (segs.get(curK) || []).filter(([q, kq]) => kq !== prevK && !used.has(curK + ">" + kq));
        if (!nexts.length) break;
        const [q, kq] = nexts[0]; used.add(curK + ">" + kq); used.add(kq + ">" + curK);
        if (kq === k0) break;
        pts.push(q); prevK = curK; curK = kq; cur = q;
      }
      if (pts.length > 6) loops.push(pts.filter((_, i) => i % 2 === 0).flatMap(([x, y]) => [x + ox, y + oy]));
    }
  }
  return loops;
}



// Ink-wash (thủy mặc) map style demo: three seeded sets, a symbol sheet and a demo map per set.
// MAPS and the contour helpers (makeField, contours) are injected above by gen.py.

const SETS = [
  { id: "k1", seed: 7, name: "Pure ink",
    paper: "#efe7d6", ink: "#1e1c1a", grey: "#6e6a64", mist: "#f6f1e6", seal: "#b42a1e", sealInk: "#f6f1e6",
    wash: null, font: "Palatino Linotype" },
  { id: "k2", seed: 8, name: "Light colour",
    paper: "#f0e6cf", ink: "#26303a", grey: "#6f7a80", mist: "#f7f0e0", seal: "#b8321f", sealInk: "#f7f0e0",
    wash: { m: "#7f9a8a", h: "#a8b48a", f: "#6f8f6a", j: "#5f8a5a", d: "#d6b47a", s: "#9aa08a", v: "#c07a50", g: "#c8c89a", i: "#e8eef0", t: "#d6d6c6", b: "#e6d6a8" },
    font: "Palatino Linotype" },
  { id: "k3", seed: 9, name: "Moonlit indigo",
    paper: "#dfe2e4", ink: "#1f2a44", grey: "#5a6680", mist: "#eef1f4", seal: "#c8a040", sealInk: "#1f2a44",
    wash: null, font: "Cambria", landOp: 0.3 },
];

function rng(seed) {
  let a = seed >>> 0;
  return () => { a = (a + 0x6D2B79F5) >>> 0; let t = a; t = Math.imul(t ^ (t >>> 15), t | 1); t ^= t + Math.imul(t ^ (t >>> 7), t | 61); return ((t ^ (t >>> 14)) >>> 0) / 4294967296; };
}

for (const S of SETS) {
  const p = S.id + "_";
  pal({ paper: S.paper, ink: S.ink, grey: S.grey, mist: S.mist, seal: S.seal, sealInk: S.sealInk,
        ink0: S.ink + "00", ink40: S.ink + "66", ink20: S.ink + "33", ink10: S.ink + "1a" });
  const BR = (w, extra = {}) => ({ c: "ink", w, wobble: w * 0.5, taper: 0.5, dry: 0.25, ...extra });

  // ---------- brush symbols ----------
  // a misty peak: dark ridge, ink fading down into mist
  for (let i = 0; i < 3; i++) {
    const hgt = [34, 26, 42][i], wid = [26, 30, 22][i];
    sprite(p + "sym_peak_" + i, { w: wid + 8, h: hgt + 6 },
      blob([4, hgt + 4, wid * 0.3 + 4, hgt * 0.4, wid * 0.5 + 4, 3, wid * 0.72 + 4, hgt * 0.45, wid + 4, hgt + 4],
        { fill: lin([["ink40", 0], ["ink10", 0.55], ["ink0", 1]], 90), smooth: 0.55 }),
      curve([4, hgt + 2, wid * 0.3 + 4, hgt * 0.42, wid * 0.5 + 4, 3, wid * 0.72 + 4, hgt * 0.47, wid + 4, hgt + 1],
        { ink: BR(1.8, { taper: 0.35 }), smooth: 0.55 }),
      (f) => Array.from({ length: 4 }, (_, k) => curve([wid * 0.5 + 4 + k * 2, 8 + k * 6, wid * 0.55 + 6 + k * 2, 14 + k * 6, wid * 0.5 + 5 + k * 2, 20 + k * 6],
        { ink: { c: "grey", w: 0.9, taper: 0.6, wobble: 0.4 } })));
  }
  sprite(p + "sym_volcano", { w: 36, h: 40 },
    circle(18, 14, 10, { fill: "seal", opacity: 0.18, blur: 6 }),
    blob([3, 38, 12, 14, 16, 11, 20, 11, 24, 14, 33, 38], { fill: lin([["ink40", 0], ["ink0", 1]], 90), smooth: 0.4 }),
    curve([3, 37, 12, 15, 16, 11], { ink: BR(2) }), curve([20, 11, 24, 15, 33, 37], { ink: BR(2) }),
    curve([18, 9, 15, 5, 19, 2, 16, -2], { ink: { c: "grey", w: 1.6, wobble: 1, taper: 0.6 }, blur: 0.6 }));
  sprite(p + "sym_hill", { w: 30, h: 12 },
    blob([1, 11, 9, 4, 16, 2, 23, 5, 29, 11], { fill: lin([["ink20", 0], ["ink0", 1]], 90), smooth: 0.7 }),
    curve([1, 11, 9, 4, 16, 2, 23, 5, 29, 11], { ink: { c: "grey", w: 1.2, taper: 0.5, wobble: 0.6, dry: 0.3 } }));
  sprite(p + "sym_trees", { w: 26, h: 20 },
    (f) => { const r = rng(S.seed + 3); const out = [];
      for (let k = 0; k < 4; k++) out.push(line([4 + k * 6, 19, 4 + k * 6 + (r() - 0.5) * 2, 9], { stroke: "ink", sw: 0.8 }));
      for (let k = 0; k < 34; k++) out.push(ellipse(2 + r() * 22, 2 + r() * 12, 1.6 + r() * 1.2, 0.9 + r() * 0.6, { fill: r() < 0.5 ? "ink" : "grey", opacity: 0.85 }));
      return out; });
  sprite(p + "sym_pine", { w: 18, h: 22 },
    line([9, 21, 9, 4], { stroke: "ink", sw: 1 }),
    (f) => Array.from({ length: 5 }, (_, k) => curve([9 - 7 + k, 6 + k * 3, 9, 4 + k * 3, 9 + 7 - k, 6 + k * 3], { ink: { c: "ink", w: 1.2, taper: 0.5, wobble: 0.4 } })));
  sprite(p + "sym_jungle", { w: 26, h: 20 },
    (f) => { const r = rng(S.seed + 5); const out = [];
      for (let k = 0; k < 5; k++) { const x = 3 + r() * 20, y = 4 + r() * 12;
        out.push(curve([x, y, x - 4, y - 2, x - 7, y + 1], { ink: { c: "ink", w: 1.6, taper: 0.6 } }), curve([x, y, x + 4, y - 3, x + 7, y], { ink: { c: "ink", w: 1.6, taper: 0.6 } })); }
      for (let k = 0; k < 18; k++) out.push(ellipse(2 + r() * 22, 3 + r() * 14, 2, 1.2, { fill: "ink", opacity: 0.7 }));
      return out; });
  sprite(p + "sym_reeds", { w: 20, h: 12 },
    (f) => Array.from({ length: 6 }, (_, k) => curve([2 + k * 3, 11, 3 + k * 3, 6, 1 + k * 3 + (k % 2 ? 4 : -2), 1], { ink: { c: "ink", w: 0.9, taper: 0.7 } })),
    line([0, 11, 20, 11], { ink: { c: "grey", w: 1, taper: 0.4, dry: 0.5 } }));
  sprite(p + "sym_dune", { w: 26, h: 6 },
    curve([1, 5, 8, 2, 15, 1, 25, 4], { ink: { c: "grey", w: 1.1, taper: 0.5, dry: 0.6 } }));
  sprite(p + "sym_snow", { w: 26, h: 16 },
    blob([1, 15, 9, 5, 13, 2, 18, 6, 25, 15], { fill: "mist", smooth: 0.6 }),
    curve([1, 15, 9, 5, 13, 2, 18, 6, 25, 15], { ink: { c: "grey", w: 1, taper: 0.5, dry: 0.4 } }),
    curve([13, 3, 14, 9, 12, 14], { stroke: "grey", sw: 0.5, opacity: 0.6 }));
  sprite(p + "sym_tundra", { w: 18, h: 6 },
    circle(3, 4, 0.9, "grey"), circle(9, 2, 0.8, "grey"), line([12, 5, 16, 5], { ink: { c: "grey", w: 0.8, taper: 0.5 } }));
  sprite(p + "sym_wave", { w: 30, h: 6 },
    curve([1, 4, 8, 2, 15, 4, 22, 2, 29, 4], { ink: { c: "grey", w: 0.9, taper: 0.6, dry: 0.6 } }));

  // ---------- place drawings ----------
  const IW = { w: 30, h: 30 };
  sprite(p + "ico_city", IW,
    rect(4, 14, 22, 12, { fill: "paper", ink: BR(1.3, { taper: 0 }) }),
    poly([2, 15, 15, 8, 28, 15], { fill: "ink" }), rect(8, 18, 4, 8, { fill: "ink" }), rect(18, 18, 4, 8, { fill: "ink" }),
    curve([2, 15, 6, 14, 15, 8, 24, 14, 28, 15], { ink: BR(1.4) }));
  sprite(p + "ico_town", IW,
    poly([3, 18, 10, 13, 17, 18], { fill: "ink" }), rect(5, 18, 10, 7, { fill: "paper", ink: BR(1, { taper: 0 }) }),
    poly([14, 15, 21, 9, 28, 15], { fill: "ink" }), rect(16, 15, 10, 10, { fill: "paper", ink: BR(1, { taper: 0 }) }));
  sprite(p + "ico_sect", IW,
    poly([3, 21, 15, 16, 27, 21], { fill: "ink" }), rect(8, 21, 14, 6, { fill: "paper", ink: BR(1, { taper: 0 }) }),
    poly([6, 14, 15, 9, 24, 14], { fill: "ink" }), rect(10, 14, 10, 3, { fill: "paper", ink: BR(0.9, { taper: 0 }) }),
    poly([9, 8, 15, 3, 21, 8], { fill: "ink" }), line([15, 3, 15, 0], { stroke: "ink", sw: 1 }));
  sprite(p + "ico_mine", IW,
    blob([3, 27, 8, 12, 15, 7, 22, 12, 27, 27], { fill: lin([["ink20", 0], ["ink0", 1]], 90), smooth: 0.6 }),
    curve([3, 27, 8, 12, 15, 7, 22, 12, 27, 27], { ink: BR(1.4) }),
    blob([10, 27, 11, 19, 15, 16, 19, 19, 20, 27], { fill: "ink", smooth: 0.5 }));
  sprite(p + "ico_abode", IW,
    line([22, 27, 22, 6], { stroke: "ink", sw: 1 }),
    (f) => Array.from({ length: 4 }, (_, k) => curve([22 - 6 + k, 8 + k * 4, 22, 6 + k * 4, 22 + 6 - k, 8 + k * 4], { ink: { c: "ink", w: 1.1, taper: 0.5 } })),
    poly([3, 21, 10, 16, 17, 21], { fill: "ink" }), rect(5, 21, 10, 6, { fill: "paper", ink: BR(0.9, { taper: 0 }) }));
  sprite(p + "ico_ruin", IW,
    line([7, 27, 7, 12], { ink: BR(2.2, { taper: 0.1, dry: 0.5 }) }), line([20, 27, 20, 17], { ink: BR(2.2, { taper: 0.1, dry: 0.5 }) }),
    line([4, 12, 11, 11], { ink: BR(1.6, { dry: 0.5 }) }), line([11, 27, 16, 25], { ink: BR(1.2, { dry: 0.6 }) }));
  sprite(p + "ico_blessed", IW,
    circle(15, 12, 11, { fill: "seal", opacity: 0.14, blur: 5 }),
    curve([15, 28, 14, 20, 16, 14, 13, 8], { ink: BR(2, { taper: 0.4 }) }),
    curve([15, 16, 9, 12, 5, 13], { ink: BR(1.2) }), curve([15, 14, 21, 9, 26, 11], { ink: BR(1.2) }),
    (f) => { const r = rng(S.seed + 9); return Array.from({ length: 26 }, () => ellipse(5 + r() * 21, 3 + r() * 11, 1.8, 1.1, { fill: "ink", opacity: 0.8 })); });
  sprite(p + "ico_vein", IW,
    circle(15, 18, 9, { fill: "seal", opacity: 0.12, blur: 5 }),
    poly([8, 27, 11, 14, 14, 27], { fill: "paper", ink: BR(1.1, { taper: 0 }) }), poly([13, 27, 16, 8, 19, 27], { fill: "paper", ink: BR(1.2, { taper: 0 }) }),
    poly([18, 27, 21, 16, 24, 27], { fill: "paper", ink: BR(1.1, { taper: 0 }) }));
  sprite(p + "seal", { w: 16, h: 16 },
    rect(1, 1, 14, 14, { fill: "seal", r: 1.5, ink: { c: "seal", w: 0.8, wobble: 0.7, dry: 0.3 } }),
    rect(3.5, 3.5, 9, 9, { fill: "none", stroke: "sealInk", sw: 0.9 }));

  sheet(p + "symbols", [p + "sym_*"], { pad: 6, scale: 3 });
  sheet(p + "icons", [p + "ico_*", p + "seal"], { pad: 6, scale: 3 });

  // ---------- demo maps ----------
  for (const MP of MAPS) {
    const R = rng(S.seed * 131 + MP.name.charCodeAt(0));
    const W = MP.w * T + 2 * MG, H = MP.h * T + 2 * MG;
    const at = (x, y) => [MG + x * T + T / 2, MG + y * T + T / 2];
    const cellsOf = (pred) => { const o = []; for (let y = 0; y < MP.h; y++) for (let x = 0; x < MP.w; x++) if (pred(MP.terrain[y][x], x, y)) o.push([x, y]); return o; };
    const sea = new Set(); const stack = [];
    for (let x = 0; x < MP.w; x++) stack.push([x, 0], [x, MP.h - 1]);
    for (let y = 0; y < MP.h; y++) stack.push([0, y], [MP.w - 1, y]);
    while (stack.length) { const [x, y] = stack.pop(); const k = x + "," + y;
      if (x < 0 || y < 0 || x >= MP.w || y >= MP.h || sea.has(k) || isLand(MP.terrain[y][x])) continue;
      sea.add(k); stack.push([x + 1, y], [x - 1, y], [x, y + 1], [x, y - 1]); }
    const isLake = (c, x, y) => !isLand(c) && !sea.has(x + "," + y);
    const land = cellsOf((c) => isLand(c));
    const LF = makeField(MP, (c, x, y) => isLand(c) || isLake(c, x, y), T * 0.62, 6, S.seed);

    const items = [];
    items.push(rect(0, 0, W, H, { fill: "paper" }));
    items.push(rect(0, 0, W, H, { fill: "paper", grain: { freq: 0.6, octaves: 4, seed: S.seed }, blend: "multiply", opacity: 0.18 }));
    // a faint wash on the sea, fading toward the edges
    items.push(rect(0, 0, W, H, { fill: rad([["ink10", 0.2], ["ink0", 0.9]], { cx: 0.5, cy: 0.5, r: 0.8 }) }));
    // coast: a soft land tone and a dry-brush shore line
    for (const lp of contours(LF, 0.5, MG, MG)) {
      items.push(blob(lp, { fill: "mist", opacity: S.landOp ?? 0.7, smooth: 0.8 }));
      items.push(blob(lp, { fill: "none", ink: { c: "grey", w: 1.6, wobble: 1.2, dry: 0.55, taper: 0 }, smooth: 0.8 }));
      items.push(blob(lp, { fill: "none", ink: { c: "ink", w: 0.9, wobble: 1.6, dry: 0.75, taper: 0, seed: 3 }, smooth: 0.8, opacity: 0.6 }));
    }
    for (const lp of contours(LF, 0.2, MG, MG)) items.push(blob(lp, { fill: "none", stroke: "grey", sw: 0.5, opacity: 0.25, smooth: 0.9 }));
    // colour washes (light colour set)
    if (S.wash) for (const [x, y] of land) { const c = MP.terrain[y][x]; const [cx, cy] = at(x, y);
      if (S.wash[c]) items.push(circle(cx, cy, T * 0.85, { fill: S.wash[c], opacity: 0.45, blur: 9 })); }
    // lakes and rivers
    const lakes = cellsOf((c, x, y) => isLake(c, x, y));
    if (lakes.length) { const LK = makeField(MP, (c, x, y) => isLake(c, x, y), T * 0.62, 6, S.seed + 5);
      for (const lp of contours(LK, 0.45, MG, MG)) items.push(blob(lp, { fill: "paper", ink: { c: "grey", w: 1.2, wobble: 0.8, dry: 0.4, taper: 0 }, smooth: 0.8 })); }
    for (const path of MP.river_paths) {
      const pts = []; path.forEach(([x, y], i) => { const [cx, cy] = at(x, y); pts.push(cx + noise(i * 0.7, 3, S.seed) * 6, cy + noise(3, i * 0.7, S.seed) * 6); });
      items.push(curve(pts, { ink: { c: "grey", w: 1.6, taper: 0.2, wobble: 1, dry: 0.3 }, smooth: 0.8 }));
    }
    // symbols back to front; mountains get mist bands between rows
    const order = land.slice().sort((a, b) => a[1] - b[1] || a[0] - b[0]);
    let lastRow = -1;
    for (const [x, y] of order) {
      const c = MP.terrain[y][x]; const [cx, cy] = at(x, y);
      if (y !== lastRow) { lastRow = y;
        const row = MP.terrain[y]; const a = row.indexOf("m"), b = row.lastIndexOf("m");
        if (a >= 0) { const [x0] = at(a, y), [x1] = at(b, y); items.push(ellipse((x0 + x1) / 2, cy + 4, (x1 - x0) / 2 + 14, 5, { fill: "mist", opacity: 0.55, blur: 4 })); } }
      const jx = (R() - 0.5) * 8, jy = (R() - 0.5) * 6;
      const st = (n, dx = 0, dy = 0, sc = 1, op = 1) => items.push(stamp(p + n, cx + jx + dx, cy + jy + dy, { anchor: "bottom", scale: sc, opacity: op }));
      if (c === "m") { st("sym_peak_" + Math.floor(R() * 3), -4, 8, 0.9 + R() * 0.5); if (R() < 0.5) st("sym_peak_" + Math.floor(R() * 3), 7, 12, 0.6 + R() * 0.3, 0.8); }
      else if (c === "v") st("sym_volcano", 0, 10, 1.1);
      else if (c === "h") st("sym_hill", 0, 6, 0.9 + R() * 0.4, 0.9);
      else if (c === "f") {
        for (let k = 0; k < 2; k++) { const tx = cx + (R() - 0.5) * 16; items.push(line([tx, cy + 9, tx + (R() - 0.5) * 2, cy - 2], { stroke: "ink", sw: 0.7, opacity: 0.7 })); }
        for (let k = 0; k < 18; k++) items.push(ellipse(cx + (R() - 0.5) * 22, cy - 2 + (R() - 0.5) * 14, 1.2 + R() * 1.6, 0.7 + R() * 0.6,
          { fill: R() < 0.45 ? "grey" : "ink", opacity: 0.3 + R() * 0.55 }));
        if (R() < 0.2) st("sym_pine", 0, 8, 0.8);
      }
      else if (c === "j") {
        for (let k = 0; k < 14; k++) items.push(ellipse(cx + (R() - 0.5) * 22, cy + (R() - 0.5) * 16, 1.8 + R() * 1.8, 1 + R() * 0.8,
          { fill: "ink", opacity: 0.35 + R() * 0.5 }));
        for (let k = 0; k < 2; k++) { const x0 = cx + (R() - 0.5) * 16, y0 = cy + (R() - 0.5) * 10, d = R() < 0.5 ? -1 : 1;
          items.push(curve([x0, y0, x0 + d * 4, y0 - 3, x0 + d * 8, y0 - 1], { ink: { c: "ink", w: 1.4, taper: 0.6, wobble: 0.4 } })); }
      }
      else if (c === "d") { if (R() < 0.8) st("sym_dune", 0, 3, 0.8 + R() * 0.4); }
      else if (c === "s") st("sym_reeds", 0, 6, 0.9 + R() * 0.3);
      else if (c === "i") { if (R() < 0.4) st("sym_snow", 0, 6, 0.8 + R() * 0.4, 0.9); }
      else if (c === "t") { if (R() < 0.6) st("sym_tundra", 0, 2); }
    }
    for (let i = 0; i < 22; i++) { const x = Math.floor(R() * MP.w), y = Math.floor(R() * MP.h);
      if (MP.terrain[y][x] === "~") { const [cx, cy] = at(x, y); items.push(stamp(p + "sym_wave", cx, cy, { anchor: "center", opacity: 0.7 })); } }
    // roads: a faint dotted brush trail
    for (const path of MP.road_paths) {
      const pts = []; path.forEach(([x, y], i) => { const [cx, cy] = at(x, y); pts.push(cx + noise(i * 0.6, 9, S.seed) * 3, cy + noise(9, i * 0.6, S.seed) * 3); });
      items.push(curve(pts, { stroke: "grey", sw: 1.2, dash: [1.5, 3.5], opacity: 0.9, smooth: 0.7 }));
    }
    // places: a small ink drawing, a seal for the great ones, an italic name
    for (const pl of MP.places) {
      const [cx, cy] = at(pl.x, pl.y);
      items.push(stamp(p + "ico_" + pl.kind, cx, cy + 4, { anchor: "center", scale: pl.kind === "city" ? 1.05 : 0.85 }));
      const great = pl.kind === "city" || pl.kind === "sect" || pl.kind === "blessed";
      if (great) items.push(stamp(p + "seal", cx + 14, cy - 10, { anchor: "center", scale: 0.6 }));
      const lab = { size: great ? 9.5 : 8, font: S.font, anchor: "middle", weight: great ? "bold" : "normal" };
      items.push(text(cx, cy + 24, pl.name, { ...lab, fill: "paper", stroke: "paper", sw: 3, opacity: 0.9 }));
      items.push(text(cx, cy + 24, pl.name, { ...lab, fill: "ink" }));
    }
    // title column and seal, top right
    items.push(text(W - MG - 8, MG + 22, MP.title.split(" (")[0], { size: 18, font: S.font, anchor: "end", fill: "ink", weight: "bold" }));
    items.push(text(W - MG - 8, MG + 36, "(" + MP.title.split(" (")[1], { size: 9, font: S.font, anchor: "end", fill: "grey" }));
    items.push(stamp(p + "seal", W - MG - 10, MG + 52, { anchor: "center", scale: 1.2 }));
    scene(p + "map_" + MP.name, { w: W, h: H }, ...items);
  }
}
