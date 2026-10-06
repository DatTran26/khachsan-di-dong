from docx import Document
from docx.enum.section import WD_ORIENT
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_CELL_VERTICAL_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Cm, Pt, RGBColor

OUT = r"D:\Projects\KhachSanDiDong\plans\260923-1658-four-sprint-mvp-backlog\ra-soat-wbs-va-tu-dien-wbs.docx"

BLUE = "1F4E78"
PALE = "EAF2F8"
BORDER = "D9D9D9"

def shade(cell, fill):
    tc_pr = cell._tc.get_or_add_tcPr()
    shd = tc_pr.find(qn("w:shd"))
    if shd is None:
        shd = OxmlElement("w:shd")
        tc_pr.append(shd)
    shd.set(qn("w:fill"), fill)

def border(cell):
    tc_pr = cell._tc.get_or_add_tcPr()
    borders = tc_pr.first_child_found_in("w:tcBorders")
    if borders is None:
        borders = OxmlElement("w:tcBorders")
        tc_pr.append(borders)
    for edge in ("top", "left", "bottom", "right", "insideH", "insideV"):
        tag = qn(f"w:{edge}")
        el = borders.find(tag)
        if el is None:
            el = OxmlElement(f"w:{edge}")
            borders.append(el)
        el.set(qn("w:val"), "single")
        el.set(qn("w:sz"), "6")
        el.set(qn("w:color"), BORDER)

def set_cell_margins(cell, top=100, start=110, bottom=100, end=110):
    tc = cell._tc
    tc_pr = tc.get_or_add_tcPr()
    tc_mar = tc_pr.first_child_found_in("w:tcMar")
    if tc_mar is None:
        tc_mar = OxmlElement("w:tcMar")
        tc_pr.append(tc_mar)
    for m, v in (("top", top), ("start", start), ("bottom", bottom), ("end", end)):
        node = tc_mar.find(qn(f"w:{m}"))
        if node is None:
            node = OxmlElement(f"w:{m}")
            tc_mar.append(node)
        node.set(qn("w:w"), str(v))
        node.set(qn("w:type"), "dxa")

def repeat_header(row):
    tr_pr = row._tr.get_or_add_trPr()
    el = OxmlElement("w:tblHeader")
    el.set(qn("w:val"), "true")
    tr_pr.append(el)

def text(cell, value, bold=False, color=None, align=None, size=9):
    p = cell.paragraphs[0]
    p.paragraph_format.space_after = Pt(0)
    if align is not None:
        p.alignment = align
    run = p.add_run(value)
    run.bold = bold
    run.font.name = "Arial"
    run._element.rPr.rFonts.set(qn("w:ascii"), "Arial")
    run._element.rPr.rFonts.set(qn("w:hAnsi"), "Arial")
    run.font.size = Pt(size)
    if color:
        run.font.color.rgb = RGBColor.from_string(color)

def table(doc, headers, rows, widths, font_size=9):
    t = doc.add_table(rows=1, cols=len(headers))
    t.alignment = WD_TABLE_ALIGNMENT.CENTER
    t.autofit = False
    header = t.rows[0]
    repeat_header(header)
    for i, h in enumerate(headers):
        cell = header.cells[i]
        cell.width = Cm(widths[i])
        shade(cell, BLUE)
        border(cell)
        set_cell_margins(cell)
        cell.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER
        text(cell, h, bold=True, color="FFFFFF", align=WD_ALIGN_PARAGRAPH.CENTER, size=font_size)
    for row_index, row in enumerate(rows):
        cells = t.add_row().cells
        for i, value in enumerate(row):
            cell = cells[i]
            cell.width = Cm(widths[i])
            if row_index % 2 == 1:
                shade(cell, PALE)
            border(cell)
            set_cell_margins(cell)
            cell.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER
            align = WD_ALIGN_PARAGRAPH.CENTER if i in (0, len(row)-1) else WD_ALIGN_PARAGRAPH.LEFT
            text(cell, value, align=align, size=font_size)
    doc.add_paragraph().paragraph_format.space_after = Pt(4)
    return t

def heading(doc, title, level=1):
    p = doc.add_paragraph(style=f"Heading {level}")
    p.paragraph_format.space_before = Pt(10 if level == 1 else 7)
    p.paragraph_format.space_after = Pt(4)
    r = p.add_run(title)
    r.font.name = "Arial"
    r._element.rPr.rFonts.set(qn("w:ascii"), "Arial")
    r._element.rPr.rFonts.set(qn("w:hAnsi"), "Arial")
    r.font.color.rgb = RGBColor(0, 0, 0)
    return p

def body(doc, value, bold_prefix=None):
    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(5)
    p.paragraph_format.line_spacing = 1.08
    if bold_prefix:
        r = p.add_run(bold_prefix)
        r.bold = True
        r.font.name = "Arial"
        r.font.size = Pt(10)
        p.add_run(value)
    else:
        p.add_run(value)
    for r in p.runs:
        r.font.name = "Arial"
        r._element.rPr.rFonts.set(qn("w:ascii"), "Arial")
        r._element.rPr.rFonts.set(qn("w:hAnsi"), "Arial")
        r.font.size = Pt(10)
    return p

doc = Document()
sec = doc.sections[0]
sec.orientation = WD_ORIENT.LANDSCAPE
sec.page_width, sec.page_height = sec.page_height, sec.page_width
sec.top_margin = Cm(1.4)
sec.bottom_margin = Cm(1.3)
sec.left_margin = Cm(1.45)
sec.right_margin = Cm(1.45)

styles = doc.styles
styles["Normal"].font.name = "Arial"
styles["Normal"]._element.rPr.rFonts.set(qn("w:ascii"), "Arial")
styles["Normal"]._element.rPr.rFonts.set(qn("w:hAnsi"), "Arial")
styles["Normal"].font.size = Pt(10)
for s in ("Title", "Heading 1", "Heading 2"):
    styles[s].font.name = "Arial"
    styles[s]._element.rPr.rFonts.set(qn("w:ascii"), "Arial")
    styles[s]._element.rPr.rFonts.set(qn("w:hAnsi"), "Arial")
    styles[s].font.color.rgb = RGBColor(0, 0, 0)

footer = sec.footer.paragraphs[0]
footer.alignment = WD_ALIGN_PARAGRAPH.CENTER
fr = footer.add_run("WBS baseline MVP Khách Sạn Di Động | Project Charter v1.0 | 29/09/2026")
fr.font.name = "Arial"
fr.font.size = Pt(8)

title = doc.add_paragraph(style="Title")
title.alignment = WD_ALIGN_PARAGRAPH.CENTER
tr = title.add_run("Rà soát WBS baseline và từ điển WBS")
tr.font.name = "Arial"
tr._element.rPr.rFonts.set(qn("w:ascii"), "Arial")
tr._element.rPr.rFonts.set(qn("w:hAnsi"), "Arial")
tr.font.color.rgb = RGBColor(0, 0, 0)

subtitle = doc.add_paragraph()
subtitle.alignment = WD_ALIGN_PARAGRAPH.CENTER
sr = subtitle.add_run("MVP Khách Sạn Di Động - theo Project Charter phiên bản 1.0")
sr.italic = True
sr.font.name = "Arial"
sr.font.size = Pt(10)

body(doc, "WBS được chuẩn hóa ở cấp gói công việc để kiểm soát phạm vi và effort. Chín gói bên dưới cộng đúng 530 giờ, bao phủ phạm vi đã thống nhất và tách biệt khỏi các hạng mục ngoài phạm vi.")
heading(doc, "Kết quả rà soát", 1)
body(doc, "Quy tắc 100 phần trăm: ", "Chín gói bao phủ khởi tạo và yêu cầu, thiết kế, nền tảng, realtime, vận hành phòng, dashboard, AI, QA UAT và bàn giao. Các hạng mục ngoài phạm vi gồm iOS, thanh toán, OTA PMS IoT, đa khách sạn và AI hỏi đáp tự do không nằm trong WBS.")
body(doc, "Quy tắc 8 80: ", "Mỗi gói công việc ở tầng WBS này có 40 đến 80 giờ. Các activity 1 đến 7 giờ trong lịch chi tiết là đơn vị giao việc dưới gói cha nên không phải đối tượng áp dụng quy tắc 8 80.")
body(doc, "Đối soát effort: ", "Tổng baseline là 530 giờ, khớp OBJ 7 và C 2 của Project Charter. Capacity tham chiếu cũ là 480 giờ, tạo chênh lệch 50 giờ cần được quản lý như rủi ro nguồn lực.")

heading(doc, "WBS baseline", 1)
wbs_rows = [
    ("1.1", "Khởi động và baseline yêu cầu", "Charter được phê duyệt, PRD BRD URD SRS, decision log, scope baseline và tiêu chí nghiệm thu", "80h"),
    ("1.2", "Thiết kế giải pháp và trải nghiệm", "Kiến trúc, ERD, state flow, API contract, design token, wireframe và ma trận quyền", "64h"),
    ("1.3", "Nền tảng ứng dụng, bảo mật và danh mục phòng", "API và Flutter Web Android chạy được; auth RBAC, dữ liệu 50 phòng, danh mục phòng và quality gate nền tảng", "80h"),
    ("1.4", "Đồng bộ realtime và toàn vẹn trạng thái", "Luồng lưu kiểm quyền audit phát sự kiện, optimistic locking, offline khóa ghi và bằng chứng hai client", "48h"),
    ("1.5", "Vận hành lưu trú, dọn phòng, bảo trì và audit", "Luồng nhận trả phòng, tự phân công, xác nhận sạch, báo sửa hỏng, audit log và kịch bản E2E", "80h"),
    ("1.6", "Dashboard và cảnh báo vận hành", "Dashboard 50 phòng, sáu chỉ số, bộ lọc, cảnh báo quá hạn và đối soát fixture", "40h"),
    ("1.7", "AI tóm tắt vận hành an toàn", "Tóm tắt theo kỳ không PII, kiểm soát timeout chi phí, fallback, lưu bản mới nhất và bộ đánh giá 20 tình huống", "40h"),
    ("1.8", "Kiểm thử tích hợp, tương thích và UAT", "Regression Web Android, kiểm thử tải realtime 30 phiên, accessibility, log lỗi và UAT pass fail", "48h"),
    ("1.9", "Phát hành và bàn giao", "CI xanh, web HTTPS, APK Android, runbook deploy rollback, script nghiệm thu và hồ sơ bàn giao", "50h"),
    ("1.0", "MVP Khách Sạn Di Động", "Bản demo nghiệm thu ngày 27 10 2026", "530h"),
]
table(doc, ["Mã WBS", "Tên", "Sản phẩm bàn giao", "Ước lượng giờ công"], wbs_rows, [2.0, 6.4, 15.7, 3.0], 8.5)

heading(doc, "Từ điển WBS ba gói trọng yếu", 1)
body(doc, "Ba gói được ưu tiên vì quyết định trực tiếp tiêu chí realtime, luồng vận hành cốt lõi và khả năng bàn giao đúng hạn.")

dictionaries = [
    ("1.4 Đồng bộ realtime và toàn vẹn trạng thái", [
        ("Mục tiêu", "Bảo đảm thay đổi trạng thái phòng được lưu và kiểm soát trước khi phát đến client khác; ngăn ghi đè khi có xung đột."),
        ("Phạm vi bao gồm", "Xác thực kết nối realtime; phát sự kiện sau commit; optimistic locking; xử lý conflict; khóa ghi khi offline; tải lại trạng thái khi kết nối lại; đo cập nhật liên thiết bị."),
        ("Sản phẩm bàn giao", "API event contract realtime, client realtime, cơ chế conflict offline và báo cáo kiểm chứng 100 lượt cập nhật với 50 phòng, 30 phiên đồng thời."),
        ("Tiêu chí chấp nhận", "Ít nhất 95 trên 100 cập nhật hiển thị trên thiết bị khác không quá 3 giây; không có ghi đè do xung đột; offline không phát sinh lệnh ghi."),
        ("Không bao gồm", "Hàng đợi ghi offline, đồng bộ nền iOS, tích hợp IoT hoặc mở rộng vượt 30 phiên."),
        ("Phụ thuộc và chủ sở hữu", "Phụ thuộc 1.2 và 1.3. Ngọc Hoàng triển khai backend mobile; Tấn Đạt duyệt contract và bằng chứng; Bảo kiểm thử UI QA."),
        ("Ước lượng", "48 giờ, tuân thủ quy tắc 8 80."),
    ]),
    ("1.5 Vận hành lưu trú dọn phòng bảo trì và audit", [
        ("Mục tiêu", "Số hóa vòng đời phòng để lễ tân, nhân viên hiện trường và quản lý cùng làm việc trên một nguồn trạng thái."),
        ("Phạm vi bao gồm", "Điều kiện nhận phòng; trả phòng tự tạo việc dọn; tự phân công người đang trực ít việc mở nhất; nhận từ chối hoàn tất xác nhận sạch; báo hỏng, ngừng phục vụ, mở lại; audit trước sau; kịch bản E2E."),
        ("Sản phẩm bàn giao", "Migration và API nghiệp vụ, màn hình Web Android cho các vai trò, audit log tra cứu được, bộ kiểm thử transaction RBAC idempotency và 10 kịch bản E2E."),
        ("Tiêu chí chấp nhận", "Một phòng hoàn thành check in, check out, dọn, quản lý xác nhận, rồi check in lại; báo hỏng chặn check in; mọi thao tác ghi có audit và event sau commit."),
        ("Không bao gồm", "Đặt trước, thanh toán, đổi phòng, checklist ảnh dọn, ưu tiên chi phí bảo trì định kỳ và phân công lại thủ công."),
        ("Phụ thuộc và chủ sở hữu", "Phụ thuộc 1.2, 1.3 và 1.4. Ngọc Hoàng triển khai API DB; Bảo triển khai UI QA; Tấn Đạt chốt rule và nghiệm thu."),
        ("Ước lượng", "80 giờ, ở ngưỡng trên của quy tắc 8 80; phát sinh phải tách thành gói riêng."),
    ]),
    ("1.9 Phát hành và bàn giao", [
        ("Mục tiêu", "Tạo bản demo có thể cài, truy cập và nghiệm thu độc lập vào ngày 27 10 2026."),
        ("Phạm vi bao gồm", "Đóng băng phạm vi và triage; security review; CI; deploy HTTPS lên VPS; build cài APK; diễn tập migration, backup rollback và smoke test; script nghiệm thu; hồ sơ kiến trúc ERD API cách chạy giới hạn."),
        ("Sản phẩm bàn giao", "URL web HTTPS, APK Android đã thử cài, CI xanh, runbook deploy rollback, biên bản kiểm thử UAT, script nghiệm thu và handover pack."),
        ("Tiêu chí chấp nhận", "Không còn blocker critical; luồng bắt buộc pass trên Web và Android; web HTTPS và APK chạy với dữ liệu demo reset được; đủ runbook, CI và hồ sơ cho sponsor nghiệm thu."),
        ("Không bao gồm", "Vận hành sau nghiệm thu, phát hành Play Store App Store, SLA sản xuất hoặc mở rộng hạ tầng đa môi trường."),
        ("Phụ thuộc và chủ sở hữu", "Phụ thuộc tối thiểu 1.3 đến 1.8 và VPS domain theo C 8. Tấn Đạt điều phối release DevOps; Ngọc Hoàng phụ trách backend migration APK; Bảo phụ trách regression UAT và evidence."),
        ("Ước lượng", "50 giờ, tuân thủ quy tắc 8 80."),
    ]),
]

for title_text, entries in dictionaries:
    heading(doc, title_text, 2)
    table(doc, ["Thuộc tính", "Nội dung"], entries, [4.1, 23.0], 8.5)

heading(doc, "Vấn đề cần quyết định", 1)
body(doc, "1. Chốt phương án hấp thụ chênh lệch 50 giờ so với capacity tham chiếu 480 giờ: tái phân bổ, tăng capacity có phê duyệt hoặc giảm phạm vi theo quy trình thay đổi.")
body(doc, "2. Cập nhật activity kiểm chứng tải từ 10 lên 30 phiên và tái ước lượng trước khi lập baseline lịch chính thức, để khớp Project Charter.")

doc.save(OUT)
print(OUT)
