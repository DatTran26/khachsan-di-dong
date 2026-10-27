import os
from PIL import Image, ImageDraw, ImageFont

# Canvas setup
width, height = 1200, 680
bg_color = (248, 246, 241)  # #F8F6F1
img = Image.new("RGB", (width, height), bg_color)
draw = ImageDraw.Draw(img)

# Fonts
font_bold = ImageFont.truetype("C:/Windows/Fonts/segoeuib.ttf", 22)
title_font = ImageFont.truetype("C:/Windows/Fonts/segoeuib.ttf", 20)
desc_font = ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf", 13)

room_num_font = ImageFont.truetype("C:/Windows/Fonts/segoeuib.ttf", 18)
tag_font = ImageFont.truetype("C:/Windows/Fonts/segoeuib.ttf", 10)
status_font = ImageFont.truetype("C:/Windows/Fonts/segoeuib.ttf", 12)
sub_font = ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf", 10)
icon_font = ImageFont.truetype("C:/Windows/Fonts/segmdl2.ttf", 14)  # Windows Segoe MDL2 icon font

# Title
draw.text((40, 25), "THIẾT KẾ TRỰC QUAN CHO 5 TRƯỜNG HỢP THỰC TẾ (CHUẨN PMS)", fill=(31, 27, 22), font=title_font)
draw.text((40, 55), "Đã hiện thực hóa 100% vào code Flutter: Màu khối nhận diện xa 3m + Thông tin chi tiết ngữ cảnh", fill=(107, 99, 86), font=desc_font)

# 5 cases
cases = [
    {
        "case_num": "1. PHÒNG TRỐNG SẴN SÀNG",
        "room": "101",
        "tag": "DLX",
        "icon": "[✓]",
        "title": "SẴN SÀNG",
        "sub": "Deluxe • Sẵn sàng đón khách",
        "bg": (34, 153, 84),  # #229954 solidReady
        "sub_color": (220, 252, 231),
        "note": "Nền Xanh Lá\nMời đón khách",
        "border": None
    },
    {
        "case_num": "2. PHÒNG TRỐNG CẦN DỌN",
        "room": "102",
        "tag": "STD",
        "icon": "[🧹]",
        "title": "CẦN DỌN",
        "sub": "Khách vừa trả • Chờ dọn",
        "bg": (217, 119, 6),  # #D97706 solidDirty
        "sub_color": (254, 243, 199),
        "note": "Nền Cam Đất\nCảnh báo phòng bẩn",
        "border": None
    },
    {
        "case_num": "3. THUÊ QUA ĐÊM (Bình thường)",
        "room": "201",
        "tag": "VIP",
        "icon": "[👤]",
        "title": "ĐANG Ở",
        "sub": "A. Tuấn • Trả 12:00 trưa",
        "bg": (37, 99, 235),  # #2563EB solidOccupied
        "sub_color": (219, 234, 254),
        "note": "Nền Xanh Dương\nCó khách đang lưu trú",
        "border": None
    },
    {
        "case_num": "4. THUÊ THEO TIẾNG (Đếm ngược)",
        "room": "202",
        "tag": "STD",
        "icon": "[⏰]",
        "title": "THEO TIẾNG",
        "sub": "Còn 35 phút (Hạn 16:15)",
        "bg": (14, 116, 144),  # #0E7490 solidHourly
        "sub_color": (224, 242, 254),
        "note": "Nền Xanh Ngọc (Cyan)\nĐếm ngược giờ trả",
        "border": None
    },
    {
        "case_num": "5. KHÁCH Ở QUÁ GIỜ (OVERTIME)",
        "room": "203",
        "tag": "VIP",
        "icon": "[⚠️]",
        "title": "QUÁ GIỜ TRẢ PHÒNG",
        "sub": "Đã lố: +45 phút (từ 12:00)",
        "bg": (220, 38, 38),  # #DC2626 solidOverdue
        "sub_color": (255, 210, 210),
        "note": "Nền Đỏ Báo Động\nViền sáng + Cảnh báo lố giờ",
        "border": (255, 255, 255)
    },
]

# Layout tiles in 2 rows or 1 row
# Card width: 200, height: 110
card_w = 205
card_h = 100
spacing_x = 24
start_x = 40
start_y = 105

# Row 1: 3 cards
for i, c in enumerate(cases[:3]):
    x = start_x + i * (card_w + spacing_x)
    y = start_y
    
    # Case header text
    draw.text((x, y), c["case_num"], fill=(31, 27, 22), font=ImageFont.truetype("C:/Windows/Fonts/segoeuib.ttf", 12))
    
    # Card
    cy = y + 24
    if c["border"]:
        # Red glow shadow
        draw.rounded_rectangle([x-2, cy-2, x + card_w + 2, cy + card_h + 2], radius=10, fill=(255, 180, 180))
    
    draw.rounded_rectangle([x, cy, x + card_w, cy + card_h], radius=8, fill=c["bg"])
    if c["border"]:
        draw.rounded_rectangle([x, cy, x + card_w, cy + card_h], radius=8, outline=(255, 255, 255), width=2)
    else:
        draw.rounded_rectangle([x, cy, x + card_w, cy + card_h], radius=8, outline=(255, 255, 255, 40), width=1)
        
    # Line 1: Room + Tag + Icon
    draw.text((x + 12, cy + 8), c["room"], fill=(255, 255, 255), font=room_num_font)
    
    # Tag
    draw.rounded_rectangle([x + 55, cy + 10, x + 85, cy + 24], radius=3, fill=(255, 255, 255, 60))
    draw.text((x + 59, cy + 11), c["tag"], fill=(255, 255, 255), font=tag_font)
    
    # Icon text
    draw.text((x + card_w - 30, cy + 8), c["icon"], fill=(255, 255, 255), font=ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf", 12))
    
    # Divider
    draw.line([x + 10, cy + 34, x + card_w - 10, cy + 34], fill=(255, 255, 255, 60), width=1)
    
    # Line 2: Title
    draw.text((x + 12, cy + 42), c["title"], fill=(255, 255, 255), font=status_font)
    
    # Line 3: Subtitle
    draw.text((x + 12, cy + 62), c["sub"], fill=c["sub_color"], font=sub_font)
    
    # Note below
    draw.text((x, cy + card_h + 10), c["note"], fill=(107, 99, 86), font=ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf", 11))

# Row 2: 2 cards (Hourly & Overtime)
start_y2 = 300
for i, c in enumerate(cases[3:]):
    x = start_x + i * (card_w + spacing_x)
    y = start_y2
    
    # Case header text
    draw.text((x, y), c["case_num"], fill=(31, 27, 22), font=ImageFont.truetype("C:/Windows/Fonts/segoeuib.ttf", 12))
    
    # Card
    cy = y + 24
    if c["border"]:
        # Red glow shadow
        draw.rounded_rectangle([x-3, cy-3, x + card_w + 3, cy + card_h + 3], radius=10, fill=(254, 202, 202))
    
    draw.rounded_rectangle([x, cy, x + card_w, cy + card_h], radius=8, fill=c["bg"])
    if c["border"]:
        draw.rounded_rectangle([x, cy, x + card_w, cy + card_h], radius=8, outline=(255, 255, 255), width=2)
    else:
        draw.rounded_rectangle([x, cy, x + card_w, cy + card_h], radius=8, outline=(255, 255, 255, 40), width=1)
        
    # Line 1: Room + Tag + Icon
    draw.text((x + 12, cy + 8), c["room"], fill=(255, 255, 255), font=room_num_font)
    
    # Tag
    draw.rounded_rectangle([x + 55, cy + 10, x + 85, cy + 24], radius=3, fill=(255, 255, 255, 60))
    draw.text((x + 59, cy + 11), c["tag"], fill=(255, 255, 255), font=tag_font)
    
    # Icon text
    draw.text((x + card_w - 30, cy + 8), c["icon"], fill=(255, 255, 255), font=ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf", 12))
    
    # Divider
    draw.line([x + 10, cy + 34, x + card_w - 10, cy + 34], fill=(255, 255, 255, 60), width=1)
    
    # Line 2: Title
    draw.text((x + 12, cy + 42), c["title"], fill=(255, 255, 255), font=status_font)
    
    # Line 3: Subtitle
    draw.text((x + 12, cy + 62), c["sub"], fill=c["sub_color"], font=sub_font)
    
    # Note below
    draw.text((x, cy + card_h + 10), c["note"], fill=(107, 99, 86), font=ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf", 11))

# Legend panel on the right
lx = start_x + 3 * (card_w + spacing_x)
ly = start_y
draw.rounded_rectangle([lx, ly, lx + 440, ly + 400], radius=12, fill=(255, 255, 255), outline=(231, 225, 213), width=1)
draw.text((lx + 20, ly + 20), "BẢNG QUY ƯỚC HIỂN THỊ LỄ TÂN (PMS)", fill=(31, 27, 22), font=ImageFont.truetype("C:/Windows/Fonts/segoeuib.ttf", 15))

rules = [
    ("🟢 XANH LÁ", "Phòng trống, đã dọn sạch sẽ, sẵn sàng bán ngay."),
    ("🟠 CAM ĐẤT", "Phòng khách vừa trả, buồng phòng chưa dọn."),
    ("🔵 XANH DƯƠNG", "Khách thuê qua đêm (hẹn trả 12:00 trưa hôm sau)."),
    ("🔷 XANH NGỌC", "Khách thuê theo tiếng (hiển thị đếm ngược phút còn lại)."),
    ("🔴 ĐỎ CẢNH BÁO", "Khách quá giờ trả phòng (hiển thị số phút lố)."),
    ("🟣 TÍM / HỒNG", "Buồng phòng đang dọn hoặc đang chờ duyệt."),
    ("🔘 XÁM BẢO TRÌ", "Phòng khóa tạm do hỏng hóc hoặc sự cố kỹ thuật."),
]

ry = ly + 55
for color_badge, rule_desc in rules:
    draw.text((lx + 20, ry), color_badge, fill=(31, 27, 22), font=ImageFont.truetype("C:/Windows/Fonts/segoeuib.ttf", 12))
    draw.text((lx + 130, ry), rule_desc, fill=(107, 99, 86), font=ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf", 12))
    ry += 32

# Save
out_path = "D:/Projects/KhachSanDiDong/docs/assets/figma/5-visual-cases-pms.png"
img.save(out_path)
print(f"SAVED: {out_path}")
