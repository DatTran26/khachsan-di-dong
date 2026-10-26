import os
from PIL import Image, ImageDraw, ImageFont

# Canvas setup - Compare Style A (Full Solid Block) vs Style B (Split-Tone Card)
width, height = 1600, 1150
bg_color = (245, 246, 250)  # Clean cool grey/white
img = Image.new("RGB", (width, height), bg_color)
draw = ImageDraw.Draw(img)

# Fonts
font_path = "C:/Windows/Fonts/segoeui.ttf"
font_bold_path = "C:/Windows/Fonts/segoeuib.ttf"
font_semi_path = "C:/Windows/Fonts/seguisb.ttf"

title_font = ImageFont.truetype(font_bold_path, 24)
section_font = ImageFont.truetype(font_bold_path, 18)
desc_font = ImageFont.truetype(font_path, 14)

room_huge_font = ImageFont.truetype(font_bold_path, 26)
room_sub_font = ImageFont.truetype(font_bold_path, 12)
room_meta_font = ImageFont.truetype(font_path, 12)

white = (255, 255, 255)
text_dark = (30, 35, 45)
text_muted = (100, 110, 125)

# Palettes for Solid Blocks (Vivid, High-Salience colors used in real hotel PMS)
# 1. Trống sạch: Emerald Green (rõ ràng, không nhờ nhờ)
C_READY = (34, 153, 84)
# 2. Đang ở (Đêm): Deep Royal Blue
C_OCCUPIED = (37, 99, 204)
# 3. Thuê tiếng: Bright Cyan/Teal
C_HOURLY = (14, 140, 180)
# 4. Quá giờ: Alarm Red
C_OVERTIME = (220, 38, 38)
# 5. Cần dọn: Warm Amber/Orange
C_DIRTY = (217, 107, 24)
# 6. Bảo trì: Slate Grey
C_OOS = (100, 116, 139)

# Draw Title
draw.text((40, 30), "SO SÁNH 2 PHONG CÁCH UI Ô PHÒNG CHUẨN PMS THỰC TẾ", fill=text_dark, font=title_font)
draw.text((40, 65), "Khắc phục triệt để lỗi màu nhạt, nhiều chữ rườm rà. Lễ tân nhìn từ xa 3 mét vẫn nhận diện được ngay lập tức.", fill=text_muted, font=desc_font)

# -------------------------------------------------------------
# PHONG CÁCH 1: KHỐI MÀU NGUYÊN BẢN (FULL SOLID COLOR BLOCK)
# Chuẩn KiotViet / Pos365 / EzCloud: Toàn bộ ô là 1 mảng màu đậm, số phòng to đùng
# -------------------------------------------------------------
y_s1 = 120
draw.rounded_rectangle([40, y_s1, 1560, y_s1 + 440], radius=16, fill=white, outline=(225, 230, 240), width=1)
draw.text((65, y_s1 + 24), "PHƯƠNG ÁN 1: KHỐI MÀU NGUYÊN BẢN (FULL SOLID BLOCK - KIỂU KIOTVIET / EZCLOUD)", fill=text_dark, font=section_font)
draw.text((65, y_s1 + 52), "• Không viền mờ, không divider, không icon nhỏ nhặt. Toàn bộ ô phủ màu trạng thái cực kỳ nổi bật.\n• Số phòng to đùng 26px màu trắng ở trung tâm. Bên dưới chỉ có đúng 1 thông số sống còn (Trống / Giờ trả / Phút lố).", fill=text_muted, font=desc_font)

cards_s1 = [
    ("101", "TRỐNG SẠCH", "Đơn • Tầng 1", C_READY, "✓ TRỐNG"),
    ("102", "CÓ KHÁCH", "Đôi • Trả 12:00", C_OCCUPIED, "TRẢ 12:00"),
    ("104", "THUÊ TIẾNG", "VIP • Gói 2h", C_HOURLY, "⏱ CÒN 35p"),
    ("203", "QUÁ GIỜ", "VIP • Lố 45p", C_OVERTIME, "⚠️ LỐ +45p"),
    ("107", "CẦN DỌN", "Đôi • Chưa dọn", C_DIRTY, "🧹 CHƯA DỌN"),
    ("208", "BẢO TRÌ", "Hỏng điều hòa", C_OOS, "🔧 TẠM KHÓA"),
]

x_c = 65
y_c = y_s1 + 120
cw, ch = 220, 140

for r_no, r_title, r_desc, bg_col, status_badge in cards_s1:
    # Outer solid card
    draw.rounded_rectangle([x_c, y_c, x_c + cw, y_c + ch], radius=12, fill=bg_col)
    
    # Tag góc nhỏ
    draw.rounded_rectangle([x_c + cw - 58, y_c + 12, x_c + cw - 12, y_c + 30], radius=9, fill=(0, 0, 0, 40) if False else (255, 255, 255))
    draw.text((x_c + cw - 52, y_c + 14), r_desc.split("•")[0].strip(), fill=bg_col, font=ImageFont.truetype(font_bold_path, 11))

    # Room number huge
    draw.text((x_c + 16, y_c + 20), r_no, fill=white, font=room_huge_font)
    
    # Bottom status pill (high contrast on dark)
    draw.rounded_rectangle([x_c + 14, y_c + ch - 42, x_c + cw - 14, y_c + ch - 12], radius=8, fill=(0, 0, 0, 45) if False else (255, 255, 255, 60))
    # Draw white/contrast sub bar
    draw.rounded_rectangle([x_c + 14, y_c + ch - 42, x_c + cw - 14, y_c + ch - 12], radius=6, fill=white)
    draw.text((x_c + 24, y_c + ch - 36), status_badge, fill=bg_col, font=room_sub_font)
    
    # Secondary info text
    meta_text = r_desc.split("•")[1].strip() if "•" in r_desc else ""
    draw.text((x_c + 130, y_c + ch - 35), meta_text, fill=text_muted, font=room_meta_font)

    x_c += cw + 25

# Mô phỏng cả một dãy phòng trông sẽ như thế nào ở PA1
draw.text((65, y_s1 + 290), "Mô phỏng 1 tầng nhìn từ xa (Lễ tân quét mắt 0.2s là thấy ngay tỷ lệ phòng):", fill=text_dark, font=ImageFont.truetype(font_bold_path, 14))
y_row = y_s1 + 320
x_row = 65
mini_w, mini_h = 135, 75

mini_rooms = [
    ("101", C_READY, "TRỐNG"),
    ("102", C_OCCUPIED, "12:00"),
    ("103", C_READY, "TRỐNG"),
    ("104", C_HOURLY, "35p"),
    ("105", C_OCCUPIED, "12:00"),
    ("106", C_DIRTY, "CẦN DỌN"),
    ("107", C_OVERTIME, "⚠️ LỐ 45p"),
    ("108", C_OCCUPIED, "12:00"),
    ("109", C_READY, "TRỐNG"),
    ("110", C_READY, "TRỐNG"),
]

for no, col, st in mini_rooms:
    draw.rounded_rectangle([x_row, y_row, x_row + mini_w, y_row + mini_h], radius=8, fill=col)
    draw.text((x_row + 12, y_row + 10), no, fill=white, font=ImageFont.truetype(font_bold_path, 20))
    # Sub tag
    draw.rounded_rectangle([x_row + 10, y_row + 42, x_row + mini_w - 10, y_row + 65], radius=4, fill=white)
    draw.text((x_row + 16, y_row + 46), st, fill=col, font=ImageFont.truetype(font_bold_path, 11))
    x_row += mini_w + 14

# -------------------------------------------------------------
# PHONG CÁCH 2: THẺ HAI TẦNG MÀU TƯƠNG PHẢN (SPLIT HEADER TILE)
# Chuẩn Cloudbeds / Mews: Nửa trên khối màu đậm chứa Số phòng, nửa dưới nền trắng
# -------------------------------------------------------------
y_s2 = 600
draw.rounded_rectangle([40, y_s2, 1560, y_s2 + 490], radius=16, fill=white, outline=(225, 230, 240), width=1)
draw.text((65, y_s2 + 24), "PHƯƠNG ÁN 2: THẺ HAI TẦNG TƯƠNG PHẢN (SPLIT-TONE TILE - KIỂU CLOUDBEDS / MEWS)", fill=text_dark, font=section_font)
draw.text((65, y_s2 + 52), "• Nửa trên chiếm 45% là KHỐI MÀU ĐẬM chứa số phòng to (nhìn số phòng cực rõ).\n• Nửa dưới là NỀN TRẮNG SÁCH SẼ chứa đúng 1 dòng trạng thái/thời gian. Trông thanh lịch, hiện đại.", fill=text_muted, font=desc_font)

x_c2 = 65
y_c2 = y_s2 + 120
cw2, ch2 = 220, 135

cards_s2 = [
    ("101", C_READY, "✓ SẴN SÀNG", "Đơn • Nhận khách ngay"),
    ("102", C_OCCUPIED, "👤 ĐANG Ở", "A. Minh • Trả 12:00"),
    ("104", C_HOURLY, "⏱ THEO GIỜ", "Còn 35 phút (15:30)"),
    ("203", C_OVERTIME, "⚠️ QUÁ GIỜ", "Đã lố +45 phút!"),
    ("107", C_DIRTY, "🧹 CHƯA DỌN", "Khách trả lúc 11:30"),
    ("208", C_OOS, "🔧 TẠM KHÓA", "Đang sửa điều hòa"),
]

for r_no, col_top, st_line1, st_line2 in cards_s2:
    # Outer card
    border_c = col_top if col_top == C_OVERTIME else (225, 230, 240)
    border_w = 2 if col_top == C_OVERTIME else 1
    draw.rounded_rectangle([x_c2, y_c2, x_c2 + cw2, y_c2 + ch2], radius=10, fill=white, outline=border_c, width=border_w)
    
    # Top 45% Solid color header
    draw.rounded_rectangle([x_c2, y_c2, x_c2 + cw2, y_c2 + 55], radius=9, fill=col_top)
    draw.rectangle([x_c2, y_c2 + 45, x_c2 + cw2, y_c2 + 55], fill=col_top) # flatten bottom corners of header
    
    # Room number in top header
    draw.text((x_c2 + 16, y_c2 + 12), r_no, fill=white, font=room_huge_font)
    draw.text((x_c2 + cw2 - 85, y_c2 + 20), st_line1.split()[0], fill=white, font=ImageFont.truetype(font_bold_path, 14))

    # Bottom white section
    draw.text((x_c2 + 16, y_c2 + 68), st_line1, fill=col_top, font=ImageFont.truetype(font_bold_path, 13))
    draw.text((x_c2 + 16, y_c2 + 94), st_line2, fill=text_muted, font=room_meta_font)

    x_c2 += cw2 + 25

# Mô phỏng dãy phòng PA2
draw.text((65, y_s2 + 290), "Mô phỏng 1 tầng nhìn từ xa (Kiểu Split-Tone Card):", fill=text_dark, font=ImageFont.truetype(font_bold_path, 14))
y_row2 = y_s2 + 320
x_row2 = 65

for no, col, st in mini_rooms:
    draw.rounded_rectangle([x_row2, y_row2, x_row2 + mini_w, y_row2 + mini_h], radius=8, fill=white, outline=col if col == C_OVERTIME else (220, 225, 235), width=2 if col == C_OVERTIME else 1)
    # Header 40px
    draw.rounded_rectangle([x_row2, y_row2, x_row2 + mini_w, y_row2 + 38], radius=7, fill=col)
    draw.rectangle([x_row2, y_row2 + 28, x_row2 + mini_w, y_row2 + 38], fill=col)
    draw.text((x_row2 + 10, y_row2 + 6), no, fill=white, font=ImageFont.truetype(font_bold_path, 18))
    # Bottom white
    draw.text((x_row2 + 10, y_row2 + 48), st, fill=col, font=ImageFont.truetype(font_bold_path, 11))
    x_row2 += mini_w + 14

# Save image
out_path = r"D:\Projects\KhachSanDiDong\docs\assets\figma\room-tile-style-comparison.png"
img.save(out_path, "PNG")
print(f"SAVED: {out_path}")
