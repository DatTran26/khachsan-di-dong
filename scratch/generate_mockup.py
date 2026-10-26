import os
from PIL import Image, ImageDraw, ImageFont

# Canvas setup
width, height = 1600, 1100
bg_color = (248, 246, 241)  # #F8F6F1 AppColors.bg
img = Image.new("RGB", (width, height), bg_color)
draw = ImageDraw.Draw(img)

# Fonts
font_path = "C:/Windows/Fonts/segoeui.ttf"
font_bold_path = "C:/Windows/Fonts/segoeuib.ttf"
font_semi_path = "C:/Windows/Fonts/seguisb.ttf"

title_font = ImageFont.truetype(font_bold_path, 26)
subtitle_font = ImageFont.truetype(font_path, 15)
card_title_font = ImageFont.truetype(font_bold_path, 18)
stat_val_font = ImageFont.truetype(font_bold_path, 24)
stat_lbl_font = ImageFont.truetype(font_path, 13)
room_num_font = ImageFont.truetype(font_bold_path, 16)
room_tag_font = ImageFont.truetype(font_bold_path, 10)
room_status_font = ImageFont.truetype(font_semi_path, 12)
sec_font = ImageFont.truetype(font_bold_path, 15)
meta_font = ImageFont.truetype(font_path, 12)

# Colors
espresso = (31, 27, 22)
gold = (201, 162, 77)
gold_dark = (176, 138, 54)
white = (255, 255, 255)
border_color = (231, 225, 213)
text_muted = (107, 99, 86)
text_dark = (31, 27, 22)

# Sidebar
sidebar_w = 240
draw.rectangle([0, 0, sidebar_w, height], fill=espresso)

# Logo
draw.text((28, 30), "KHÁCH SẠN DI ĐỘNG", fill=gold, font=ImageFont.truetype(font_bold_path, 16))
draw.text((28, 52), "Lễ tân ca sáng • 26/10", fill=(191, 179, 156), font=meta_font)

# Nav items
nav_items = [
    ("📊  Tổng quan", True),
    ("🚪  Phòng", False),
    ("🔑  Lưu trú", False),
    ("🧹  Buồng phòng", False),
    ("🔧  Bảo trì", False),
    ("👥  Nhân viên", False),
    ("📋  Nhật ký", False),
    ("✨  Tóm tắt AI", False),
]

y_nav = 110
for item, active in nav_items:
    if active:
        draw.rounded_rectangle([16, y_nav, sidebar_w - 16, y_nav + 40], radius=8, fill=(41, 201, 162, 45) if False else (45, 38, 30))
        draw.line([16, y_nav + 8, 16, y_nav + 32], fill=gold, width=3)
        draw.text((36, y_nav + 10), item, fill=gold, font=ImageFont.truetype(font_semi_path, 14))
    else:
        draw.text((36, y_nav + 10), item, fill=(191, 179, 156), font=ImageFont.truetype(font_path, 14))
    y_nav += 46

# Top Header in Main Content
main_x = sidebar_w + 36
draw.text((main_x, 28), "Tổng quan trạng thái phòng", fill=text_dark, font=title_font)
draw.text((main_x, 62), "50 phòng • Cập nhật tự động thời gian thực • Nhận diện trực quan theo màu sắc & mã rút gọn", fill=text_muted, font=subtitle_font)

# Stats Cards
stats = [
    ("SẴN SÀNG", "14", "nhận khách ngay", (45, 123, 49), (231, 243, 232)),
    ("ĐANG Ở", "26", "phòng có khách", (30, 95, 174), (229, 238, 249)),
    ("THEO TIẾNG", "5", "đang đếm giờ", (14, 116, 144), (224, 242, 254)),
    ("QUÁ GIỜ", "2", "cần giục khách", (192, 38, 45), (253, 235, 236)),
    ("CẦN DỌN", "6", "chờ buồng phòng", (180, 71, 28), (252, 235, 226)),
    ("LẤP ĐẦY", "62%", "31/50 phòng", gold_dark, (246, 239, 221)),
]

card_w = 196
card_h = 76
x_st = main_x
for lbl, val, sub, fg, bg in stats:
    draw.rounded_rectangle([x_st, 98, x_st + card_w, 98 + card_h], radius=10, fill=white, outline=border_color, width=1)
    draw.rectangle([x_st + 1, 99, x_st + 6, 98 + card_h - 1], fill=fg)
    draw.text((x_st + 18, 108), lbl, fill=fg, font=stat_lbl_font)
    draw.text((x_st + 18, 126), val, fill=text_dark, font=stat_val_font)
    draw.text((x_st + 75, 134), sub, fill=text_muted, font=meta_font)
    x_st += card_w + 14

# Filter bar
y_filter = 196
draw.text((main_x, y_filter + 6), "Lọc tầng:", fill=text_muted, font=meta_font)
floors = ["Tất cả (50)", "Tầng 1 (10)", "Tầng 2 (10)", "Tầng 3 (10)", "Tầng 4 (10)", "Tầng 5 (10)"]
xf = main_x + 60
for i, f in enumerate(floors):
    is_act = (i == 0)
    bg_p = espresso if is_act else white
    fg_p = gold if is_act else text_muted
    w_p = 80 if i > 0 else 90
    draw.rounded_rectangle([xf, y_filter, xf + w_p, y_filter + 30], radius=15, fill=bg_p, outline=border_color if not is_act else espresso)
    draw.text((xf + 12, y_filter + 6), f, fill=fg_p, font=meta_font)
    xf += w_p + 8

# Search Box on the right
draw.rounded_rectangle([1320, y_filter, 1550, y_filter + 30], radius=15, fill=white, outline=border_color)
draw.text((1335, y_filter + 6), "🔍  Tìm số phòng, tên khách...", fill=(160, 155, 145), font=meta_font)

# Helper for drawing a compact room tile
def draw_compact_tile(x, y, room_no, room_type, status_type, info_text, is_hover=False):
    tw, th = 114, 82
    
    # Palette per status
    # status_type: 'ready', 'occupied', 'hourly', 'overtime', 'dirty', 'oos'
    if status_type == 'ready':
        bg = (235, 247, 236)
        border = (168, 219, 172)
        accent = (45, 123, 49)
        icon_str = "✓"
    elif status_type == 'occupied':
        bg = (232, 242, 253)
        border = (175, 206, 245)
        accent = (30, 95, 174)
        icon_str = "👤"
    elif status_type == 'hourly':
        bg = (226, 245, 252)
        border = (160, 218, 238)
        accent = (14, 116, 144)
        icon_str = "⏱"
    elif status_type == 'overtime':
        bg = (254, 238, 240)
        border = (224, 75, 83)
        accent = (192, 38, 45)
        icon_str = "⚠️"
    elif status_type == 'dirty':
        bg = (254, 242, 234)
        border = (247, 195, 168)
        accent = (180, 71, 28)
        icon_str = "🧹"
    else:  # oos
        bg = (240, 238, 234)
        border = (205, 200, 192)
        accent = (100, 95, 88)
        icon_str = "🔧"

    # Base card
    outline_w = 2 if (status_type == 'overtime' or is_hover) else 1
    if is_hover:
        border = gold_dark
    draw.rounded_rectangle([x, y, x + tw, y + th], radius=8, fill=bg, outline=border, width=outline_w)

    # Top Row: Room number (bold) & Tag
    draw.text((x + 10, y + 8), room_no, fill=text_dark, font=room_num_font)
    
    # Tag badge
    draw.rounded_rectangle([x + tw - 38, y + 9, x + tw - 8, y + 23], radius=4, fill=white, outline=border, width=1)
    draw.text((x + tw - 34, y + 10), room_type, fill=text_muted, font=room_tag_font)

    # Divider line
    draw.line([x + 8, y + 33, x + tw - 8, y + 33], fill=border, width=1)

    # Bottom Row: Icon + Short status
    draw.text((x + 10, y + 43), icon_str, fill=accent, font=ImageFont.truetype(font_bold_path, 14))
    draw.text((x + 32, y + 43), info_text, fill=accent, font=room_status_font)

    # If hover, draw popup tooltip
    if is_hover:
        px, py = x + 20, y + th + 8
        pw, ph = 260, 112
        draw.rounded_rectangle([px, py, px + pw, py + ph], radius=8, fill=espresso, outline=gold, width=2)
        draw.text((px + 14, py + 12), f"Phòng {room_no} • {room_type} Deluxe Double", fill=gold, font=ImageFont.truetype(font_bold_path, 13))
        draw.text((px + 14, py + 34), "Khách: Nguyễn Văn Tuấn (2 người)", fill=white, font=meta_font)
        draw.text((px + 14, py + 52), "Gói: Thuê qua đêm • Nhận: 14:00 hôm qua", fill=(191, 179, 156), font=meta_font)
        draw.text((px + 14, py + 70), "Hạn trả: 12:00 trưa nay (Đúng hạn)", fill=(134, 239, 172), font=meta_font)
        draw.text((px + 14, py + 88), "👉 Click để xem hồ sơ / Trả phòng", fill=gold, font=ImageFont.truetype(font_semi_path, 11))

# Room simulation matrix (Floor 1, 2, 3)
floors_data = [
    ("TẦNG 1  •  10 phòng (4 sẵn sàng, 4 đang ở, 2 cần dọn)", [
        ("101", "STD", "ready", "Trống"),
        ("102", "STD", "occupied", "12:00"),
        ("103", "DLX", "ready", "Trống"),
        ("104", "DLX", "hourly", "⏱ 45p"),
        ("105", "VIP", "occupied", "12:00"),
        ("106", "VIP", "ready", "Trống"),
        ("107", "STD", "dirty", "Chờ dọn"),
        ("108", "STD", "occupied", "12:00"),
        ("109", "DLX", "dirty", "Chờ dọn"),
        ("110", "VIP", "ready", "Trống"),
    ]),
    ("TẦNG 2  •  10 phòng (2 sẵn sàng, 5 đang ở, 1 quá giờ, 1 bảo trì)", [
        ("201", "STD", "occupied", "12:00", True),  # hovered
        ("202", "STD", "hourly", "⏱ 20p"),
        ("203", "DLX", "overtime", "⚠️ +45p"),
        ("204", "DLX", "occupied", "12:00"),
        ("205", "VIP", "ready", "Trống"),
        ("206", "VIP", "occupied", "12:00"),
        ("207", "STD", "dirty", "Chờ dọn"),
        ("208", "STD", "oos", "Bảo trì"),
        ("209", "DLX", "ready", "Trống"),
        ("210", "VIP", "hourly", "⏱ 1h10"),
    ]),
    ("TẦNG 3  •  10 phòng (3 sẵn sàng, 5 đang ở, 1 quá giờ, 1 cần dọn)", [
        ("301", "STD", "ready", "Trống"),
        ("302", "STD", "occupied", "12:00"),
        ("303", "DLX", "overtime", "⚠️ +15p"),
        ("304", "DLX", "occupied", "12:00"),
        ("305", "VIP", "occupied", "12:00"),
        ("306", "VIP", "ready", "Trống"),
        ("307", "STD", "dirty", "Chờ dọn"),
        ("308", "STD", "occupied", "12:00"),
        ("309", "DLX", "hourly", "⏱ 55p"),
        ("310", "VIP", "ready", "Trống"),
    ]),
]

y_floor = 250
for floor_title, rooms in floors_data:
    draw.text((main_x, y_floor), floor_title, fill=text_dark, font=sec_font)
    y_floor += 26
    
    gx = main_x
    for r_item in rooms:
        r_no = r_item[0]
        r_type = r_item[1]
        r_stat = r_item[2]
        r_txt = r_item[3]
        is_hov = len(r_item) > 4 and r_item[4]
        draw_compact_tile(gx, y_floor, r_no, r_type, r_stat, r_txt, is_hover=is_hov)
        gx += 114 + 10
    
    y_floor += 82 + 30

# Bottom legend bar
draw.rounded_rectangle([main_x, 820, 1550, 870], radius=8, fill=white, outline=border_color)
draw.text((main_x + 18, 836), "Chú giải nhận diện:", fill=text_dark, font=ImageFont.truetype(font_bold_path, 13))

legends = [
    ((45, 123, 49), "✓ Sẵn sàng (Bán ngay)"),
    ((30, 95, 174), "👤 Đang ở (Thuê đêm)"),
    ((14, 116, 144), "⏱ Đang ở (Thuê giờ)"),
    ((192, 38, 45), "⚠️ Quá giờ (Báo động)"),
    ((180, 71, 28), "🧹 Cần dọn (Chưa bán)"),
    ((100, 95, 88), "🔧 Bảo trì (Ngừng phục vụ)"),
]

lx = main_x + 170
for col, text in legends:
    draw.rounded_rectangle([lx, 837, lx + 14, 851], radius=3, fill=col)
    draw.text((lx + 20, 836), text, fill=text_muted, font=meta_font)
    lx += 180

# Save image
out_dir = r"D:\Projects\KhachSanDiDong\docs\assets\figma"
os.makedirs(out_dir, exist_ok=True)
out_path = os.path.join(out_dir, "dashboard-compact-mockup.png")
img.save(out_path, "PNG")
print(f"SAVED_TO: {out_path}")
