"""Sinh file Excel Kế hoạch quản lý truyền thông cho MVP Khách Sạn Di Động.

Nguồn dữ liệu: WBS MS Project (KhachSanSach.xlsx / plan.md), project-profile.md và các
quyết định của nhóm: Slack là nhóm báo cáo (đăng file Excel), Zalo là nhóm tương tác,
họp 2 buổi/tuần, bên liên quan người dùng là giả định trên giấy.

Chạy: python build-communication-plan-workbook.py [đường_dẫn_output.xlsx]
"""
import sys
from datetime import date, timedelta

import importlib.util
from pathlib import Path

from openpyxl import Workbook
from openpyxl.chart import BarChart, Reference
from openpyxl.comments import Comment
from openpyxl.formatting.rule import FormulaRule
from openpyxl.styles import Alignment, Border, Font, PatternFill, Side
from openpyxl.utils import get_column_letter
from openpyxl.workbook.defined_name import DefinedName
from openpyxl.worksheet.datavalidation import DataValidation

sys.stdout.reconfigure(encoding="utf-8")
_spec = importlib.util.spec_from_file_location("lessons", Path(__file__).with_name("communication-lessons-content.py"))
_mod = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_mod)
LESSONS, COMMON_TAGS, LESSON_CHANNEL = _mod.LESSONS, _mod.COMMON_TAGS, _mod.CHANNEL
OUT = sys.argv[1] if len(sys.argv) > 1 else "ke-hoach-quan-ly-truyen-thong.xlsx"
PLAN_DATE = date(2026, 10, 14)  # ngày lập kế hoạch v1.0

# ---------------------------------------------------------------- styles
FONT = "Arial"
F_BASE = Font(name=FONT, size=10)
F_BOLD = Font(name=FONT, size=10, bold=True)
F_HEAD = Font(name=FONT, size=10, bold=True, color="FFFFFF")
F_TITLE = Font(name=FONT, size=16, bold=True, color="1F4E78")
F_SUB = Font(name=FONT, size=12, bold=True, color="1F4E78")
F_NOTE = Font(name=FONT, size=9, italic=True, color="595959")
F_LINK = Font(name=FONT, size=10, color="0563C1", underline="single")
FILL_HEAD = PatternFill("solid", fgColor="1F4E78")
FILL_INPUT = PatternFill("solid", fgColor="FFF2CC")
FILL_FORMULA = PatternFill("solid", fgColor="EDEDED")
FILL_SECTION = PatternFill("solid", fgColor="DDEBF7")
FILL_EXAMPLE = PatternFill("solid", fgColor="E2EFDA")
THIN = Side(style="thin", color="BFBFBF")
BORDER = Border(left=THIN, right=THIN, top=THIN, bottom=THIN)
WRAP = Alignment(wrap_text=True, vertical="top")
CENTER = Alignment(horizontal="center", vertical="center", wrap_text=True)
RED = PatternFill("solid", fgColor="F8CBAD")
ORANGE = PatternFill("solid", fgColor="FFE699")
GREEN = PatternFill("solid", fgColor="C6EFCE")
BLUE = PatternFill("solid", fgColor="BDD7EE")
GREY = PatternFill("solid", fgColor="D9D9D9")

# ---------------------------------------------------------------- sheet names
S_TQ, S_DM = "Tổng quan", "Danh mục"
S1, S2, S3, S4 = "1. Bên liên quan", "2. Thu thập TT", "3. Phân phối", "4. Định dạng"
S5, S6, S7, S8 = "5. Lịch biểu", "6. Truy cập", "7. Cập nhật KH", "8. Phân tích"
S9 = "9. Bài học chia sẻ"
M1, M2, M3, M4 = "M1. Báo cáo tuần", "M2. Biên bản họp", "M3. Báo cáo sprint", "M4. Báo cáo chất lượng"
MAXR = 300  # các vùng công thức đọc tới dòng này để nhóm thêm dòng mới vẫn được tính


def q(sheet):
    return "'" + sheet + "'"


def rng(sheet, col, r1=5, r2=MAXR):
    return f"{q(sheet)}!${col}${r1}:${col}${r2}"


wb = Workbook()
wb.remove(wb.active)
for name in (S_TQ, S_DM, S1, S2, S3, S4, S5, S6, S7, S8, S9, M1, M2, M3, M4):
    wb.create_sheet(name)
wb.calculation.fullCalcOnLoad = True


def define(name, ref):
    wb.defined_names[name] = DefinedName(name, attr_text=ref)


def style_cell(c, kind="body"):
    c.font = F_BASE
    c.border = BORDER
    c.alignment = WRAP
    if kind == "input":
        c.fill = FILL_INPUT
    elif kind == "formula":
        c.fill = FILL_FORMULA
    elif kind == "example":
        c.fill = FILL_EXAMPLE


def title(ws, text, sub=None):
    ws["A1"] = text
    ws["A1"].font = F_TITLE
    if sub:
        ws["A2"] = sub
        ws["A2"].font = F_NOTE
    ws.sheet_view.showGridLines = False


def section(ws, row, text, ncols):
    c = ws.cell(row=row, column=1, value=text)
    c.font = F_SUB
    for col in range(1, ncols + 1):
        ws.cell(row=row, column=col).fill = FILL_SECTION
    return row + 1


def header(ws, row, headers):
    for i, h in enumerate(headers, 1):
        c = ws.cell(row=row, column=i, value=h)
        c.font = F_HEAD
        c.fill = FILL_HEAD
        c.alignment = CENTER
        c.border = BORDER
    ws.row_dimensions[row].height = 32


def table(ws, row, headers, rows, formula_cols=(), input_cols=None, blank_rows=0):
    """Ghi bảng; ô bắt đầu bằng '=' có thể chứa {r} (số dòng hiện tại).

    input_cols=None nghĩa là mọi cột không phải công thức đều là ô nhập.
    Trả về (dòng dữ liệu đầu, dòng dữ liệu cuối kể cả dòng trống)."""
    header(ws, row, headers)
    first = row + 1
    r = first
    for data in rows + [[None] * len(headers)] * blank_rows:
        for i, v in enumerate(data, 1):
            col = get_column_letter(i)
            is_f = col in formula_cols
            if is_f and v is None and rows:
                v = rows[0][i - 1]  # lặp công thức cho dòng trống
            if isinstance(v, str) and v.startswith("="):
                v = v.replace("{r}", str(r))
            c = ws.cell(row=r, column=i, value=v)
            kind = "formula" if is_f else ("input" if input_cols is None or col in input_cols else "body")
            style_cell(c, kind)
            if isinstance(v, date):
                c.number_format = "dd/mm/yyyy"
                c.alignment = Alignment(horizontal="center", vertical="top")
        r += 1
    return first, r - 1


def widths(ws, ws_widths):
    for col, w in ws_widths.items():
        ws.column_dimensions[col].width = w


def dv(ws, ref, formula, prompt=None):
    v = DataValidation(type="list", formula1=formula, allow_blank=True, showDropDown=False)
    v.error = "Chọn giá trị trong danh sách (sửa danh sách ở sheet Danh mục)."
    v.errorTitle = "Giá trị không hợp lệ"
    if prompt:
        v.prompt = prompt
        v.showInputMessage = True
    ws.add_data_validation(v)
    v.add(ref)


def cf(ws, ref, formula, fill):
    ws.conditional_formatting.add(ref, FormulaRule(formula=[formula], fill=fill))


# =================================================================== DANH MỤC
dm = wb[S_DM]
title(dm, "DANH MỤC DÙNG CHUNG", "Nguồn của mọi dropdown và tra cứu. Thêm giá trị vào cuối cột là dropdown tự cập nhật. Ô vàng là ô được sửa.")
LISTS = [
    ("DS_NguoiGui", "Người gửi / phụ trách", ["Đạt", "Hoàng", "Bảo", "Cả nhóm", "GitHub (tự động)"]),
    ("DS_LoaiBLQ", "Loại bên liên quan", ["Nội bộ", "Bên ngoài", "Giả định"]),
    ("DS_Muc", "Mức (quyền lực, quan tâm, rủi ro)", ["Cao", "Trung bình", "Thấp"]),
    ("DS_ThamGia", "Mức tham gia (thấp → cao)", ["Không biết", "Phản đối", "Trung lập", "Ủng hộ", "Dẫn dắt"]),
    ("DS_CoKhong", "Có / Không", ["Có", "Không"]),
    ("DS_NhomTT", "Nhóm thông tin", ["Tiến độ", "Phạm vi & yêu cầu", "Kỹ thuật", "Chất lượng", "Rủi ro & vấn đề", "Chi phí", "Phản hồi người dùng", "Quản trị dự án"]),
    ("DS_PPThuThap", "Phương pháp thu thập", ["Tổng hợp từ công cụ", "Tự báo cáo", "Họp", "Phỏng vấn", "Khảo sát", "Quan sát", "Workshop", "Kiểm thử", "Review tài liệu/PR", "Tự động từ công cụ"]),
    ("DS_TanSuat", "Tần suất", ["Theo thời gian thực", "Khi phát sinh", "Mỗi buổi họp", "Hằng ngày (triage)", "Hằng tuần", "Đầu mỗi sprint", "Cuối mỗi sprint", "Theo đợt", "Một lần"]),
    ("DS_BaoMat", "Mức bảo mật", ["Nội bộ nhóm", "Nội bộ + Giảng viên", "Hạn chế (không đăng nhóm)"]),
    ("DS_DinhDang", "Định dạng", ["Excel (.xlsx)", "Tin nhắn Zalo", "Cuộc gọi Zalo", "Thông báo tự động", "Markdown/OpenAPI", "Bài viết (text)"]),
    ("DS_RACI", "RACI", ["R", "A", "R/A", "C", "I"]),
    ("DS_TrangThai", "Trạng thái sự kiện", ["Kế hoạch", "Cần xác nhận", "Đã hoàn thành", "Hoãn", "Hủy"]),
    ("DS_LoaiSK", "Loại sự kiện", ["Họp định kỳ", "Báo cáo định kỳ", "Mốc dự án", "Hoạt động nghiệp vụ", "Kiểm thử & chất lượng", "Rà soát kế hoạch"]),
    ("DS_Quyen", "Quyền truy cập", ["Quản trị", "Đăng/Sửa", "Xem/Bình luận", "Không"]),
    ("DS_RAG", "Tình trạng RAG", ["Xanh", "Vàng", "Đỏ"]),
    ("DS_KetQua", "Kết quả", ["Đạt", "Không đạt", "Chưa đánh giá"]),
    ("DS_Pass", "Kết quả test", ["Pass", "Fail", "Blocked"]),
    ("DS_MucLoi", "Mức lỗi", ["Blocker", "Critical", "Major", "Minor"]),
    ("DS_TTLoi", "Trạng thái lỗi", ["Mở", "Đang sửa", "Chờ retest", "Đóng"]),
    ("DS_QuyetDinh", "Quyết định", ["Chờ duyệt", "Duyệt", "Từ chối"]),
    ("DS_TTRaSoat", "Trạng thái rà soát", ["Chưa đến hạn", "Đã rà soát", "Không áp dụng"]),
    ("DS_TTBaiHoc", "Trạng thái bài học", ["Ý tưởng", "Đang viết", "Chờ duyệt", "Đã duyệt", "Đã đăng", "Hoãn"]),
    ("DS_NhomBaiHoc", "Nhóm chủ đề bài học", ["Nghiệp vụ", "Quản lý dự án", "Làm việc nhóm", "Kỹ thuật"]),
]
for idx, (name, label, values) in enumerate(LISTS, 1):
    col = get_column_letter(idx)
    c = dm.cell(row=3, column=idx, value=label)
    c.font, c.fill, c.alignment, c.border = F_HEAD, FILL_HEAD, CENTER, BORDER
    for j, v in enumerate(values, 4):
        style_cell(dm.cell(row=j, column=idx, value=v), "input")
    for j in range(4 + len(values), 4 + len(values) + 3):
        style_cell(dm.cell(row=j, column=idx), "input")
    dm.column_dimensions[col].width = 20
    define(name, f"OFFSET({q(S_DM)}!${col}$4,0,0,COUNTA({q(S_DM)}!${col}$4:${col}$40),1)")
dm.row_dimensions[3].height = 40

# Bảng sprint và ngày đánh giá
sc = len(LISTS) + 2
SC = [get_column_letter(sc + i) for i in range(4)]
r0 = 3
for i, h in enumerate(["Sprint", "Bắt đầu", "Kết thúc", "Nội dung"]):
    c = dm.cell(row=r0, column=sc + i, value=h)
    c.font, c.fill, c.alignment, c.border = F_HEAD, FILL_HEAD, CENTER, BORDER
SPRINTS = [
    ("Sprint 1", date(2026, 9, 8), date(2026, 9, 21), "Nền tảng: auth, RBAC, danh mục phòng, realtime"),
    ("Sprint 2", date(2026, 9, 22), date(2026, 10, 5), "Vận hành: nhận/trả, dọn phòng, bảo trì, audit"),
    ("Sprint 3", date(2026, 10, 6), date(2026, 10, 19), "Dashboard, accessibility, AI summary"),
    ("Sprint 4", date(2026, 10, 20), date(2026, 10, 27), "Kiểm thử, triển khai, UAT, bàn giao 27/10"),
]
for j, s in enumerate(SPRINTS, r0 + 1):
    for i, v in enumerate(s):
        c = dm.cell(row=j, column=sc + i, value=v)
        style_cell(c, "input")
        if isinstance(v, date):
            c.number_format = "dd/mm/yyyy"
for col, w in zip(SC, (12, 12, 12, 42)):
    dm.column_dimensions[col].width = w
define("SPRINT_TEN", f"{q(S_DM)}!${SC[0]}$4:${SC[0]}$7")
define("SPRINT_BD", f"{q(S_DM)}!${SC[1]}$4:${SC[1]}$7")
define("SPRINT_KT", f"{q(S_DM)}!${SC[2]}$4:${SC[2]}$7")
dm.cell(row=9, column=sc, value="Ngày bắt đầu dự án").font = F_BOLD
c = dm.cell(row=9, column=sc + 1, value=f"=MIN({q(S_DM)}!${SC[1]}$4:${SC[1]}$7)")
style_cell(c, "formula"); c.number_format = "dd/mm/yyyy"
dm.cell(row=10, column=sc, value="Ngày kết thúc dự án").font = F_BOLD
c = dm.cell(row=10, column=sc + 1, value=f"=MAX({q(S_DM)}!${SC[2]}$4:${SC[2]}$7)")
style_cell(c, "formula"); c.number_format = "dd/mm/yyyy"
dm.cell(row=11, column=sc, value="Ngày đánh giá").font = F_BOLD
c = dm.cell(row=11, column=sc + 1, value="=TODAY()")
style_cell(c, "input"); c.number_format = "dd/mm/yyyy"
c.comment = Comment("Mặc định = TODAY(). Gõ một ngày cụ thể để xem cảnh báo và KPI tại thời điểm đó.", "PM")
define("NGAY_BD", f"{q(S_DM)}!${SC[1]}$9")
define("NGAY_KT", f"{q(S_DM)}!${SC[1]}$10")
define("NGAY_DG", f"{q(S_DM)}!${SC[1]}$11")
dm.cell(row=12, column=sc, value="Tốc độ đọc (tiếng/phút)").font = F_BOLD
c = dm.cell(row=12, column=sc + 1, value=200)
style_cell(c, "input")
c.comment = Comment("Giả định để tính Thời lượng đọc ở sheet 9; chỉnh nếu nhóm đo được tốc độ khác.", "PM")
define("TOC_DO_DOC", f"{q(S_DM)}!${SC[1]}$12")

# Chiến lược theo nhóm quyền lực – quan tâm
dm.cell(row=13, column=sc, value="Nhóm (lưới quyền lực – quan tâm)").font = F_BOLD
dm.cell(row=13, column=sc + 1, value="Chiến lược truyền thông").font = F_BOLD
GRID = [
    ("Quản lý chặt", "Mời tham gia quyết định; báo cáo tuần + báo cáo sprint; xin duyệt mọi thay đổi phạm vi hoặc mốc"),
    ("Giữ hài lòng", "Gửi tóm tắt ngắn ở mốc quan trọng; hỏi ý kiến khi chốt KPI, quyền và báo cáo"),
    ("Thông báo đầy đủ", "Cập nhật đều đặn những gì ảnh hưởng tới công việc của họ; mời tham gia phỏng vấn, usability, UAT"),
    ("Theo dõi", "Thông báo khi cần (sự cố, hạ tầng, chi phí); không gửi báo cáo định kỳ"),
]
for j, (k, v) in enumerate(GRID, 14):
    style_cell(dm.cell(row=j, column=sc, value=k), "input")
    style_cell(dm.cell(row=j, column=sc + 1, value=v), "input")
define("CL_NHOM", f"{q(S_DM)}!${SC[0]}$14:${SC[0]}$17")
define("CL_NOIDUNG", f"{q(S_DM)}!${SC[1]}$14:${SC[1]}$17")
dm.freeze_panes = "A4"

# =================================================================== 1. BÊN LIÊN QUAN
ws = wb[S1]
title(ws, "1. BÊN LIÊN QUAN VÀ NHU CẦU THÔNG TIN",
      "Đầu vào cho mọi phần của kế hoạch. Nhóm chiến lược, chiến lược và khoảng cách tham gia được tính tự động. "
      "Người dùng khách sạn là vai trò giả định trên giấy.")
H1 = ["Mã", "Bên liên quan", "Vai trò trong dự án", "Loại", "Nhu cầu thông tin chính", "Mã TT nhận",
      "Quyền lực", "Mức quan tâm", "Nhóm chiến lược", "Chiến lược truyền thông", "Tham gia hiện tại",
      "Tham gia mong muốn", "Khoảng cách", "Kênh ưu tiên", "Tính vào số kênh", "Đầu mối liên lạc", "Ghi chú",
      "_QLC", "_GHL", "_TBĐĐ", "_TD"]
F_GRP = '=IF(OR(G{r}="",H{r}=""),"",IF(AND(G{r}="Cao",H{r}="Cao"),"Quản lý chặt",IF(G{r}="Cao","Giữ hài lòng",IF(H{r}="Cao","Thông báo đầy đủ","Theo dõi"))))'
F_STR = '=IFERROR(INDEX(CL_NOIDUNG,MATCH(I{r},CL_NHOM,0)),"")'
TG = f"{q(S_DM)}!$D$4:$D$40"  # cột Mức tham gia trong Danh mục (vùng tĩnh để MATCH ổn định)
F_GAP = ('=IF(OR(K{r}="",L{r}=""),"",IF(MATCH(L{r},' + TG + ',0)-MATCH(K{r},' + TG + ',0)<=0,"Đạt mong muốn",'
         '"Cần nâng "&(MATCH(L{r},' + TG + ',0)-MATCH(K{r},' + TG + ',0))&" mức"))')
HELP = ['=IF(I{r}="Quản lý chặt",B{r},"")', '=IF(I{r}="Giữ hài lòng",B{r},"")',
        '=IF(I{r}="Thông báo đầy đủ",B{r},"")', '=IF(I{r}="Theo dõi",B{r},"")']
SH = [
    ("SH-01", "Đạt", "PO, BA, PM, Tech Lead, DevOps", "Nội bộ", "Toàn bộ tiến độ, rủi ro, chi phí, quyết định kỹ thuật và phạm vi", "TT-01 → TT-20", "Cao", "Cao", "Dẫn dắt", "Dẫn dắt", "Zalo nhóm WPC (nội bộ)", "Có", "Đạt", "Chủ sở hữu kế hoạch truyền thông; kiêm 5 vai trò nên là điểm nghẽn thông tin"),
    ("SH-02", "Hoàng", "Backend, Mobile", "Nội bộ", "API contract, lỗi backend, quyết định kỹ thuật, việc được giao", "TT-02, TT-03, TT-06, TT-10, TT-11, TT-13", "Trung bình", "Cao", "Ủng hộ", "Ủng hộ", "Zalo nhóm WPC (nội bộ)", "Có", "Đạt", ""),
    ("SH-03", "Bảo", "UI/UX, Frontend, QA", "Nội bộ", "Design Token, API contract, lỗi UI, kịch bản kiểm thử, phản hồi người dùng", "TT-02, TT-03, TT-06, TT-11, TT-12, TT-14, TT-16", "Trung bình", "Cao", "Ủng hộ", "Ủng hộ", "Zalo nhóm WPC (nội bộ)", "Có", "Đạt", "Thư ký họp và người lập báo cáo chất lượng"),
    ("SH-04", "Giảng viên", "Sponsor, khách hàng, người nghiệm thu (GV. Nguyễn Hữu Trung)", "Bên ngoài", "Tiến độ tuần, kết quả cổng sprint, thay đổi phạm vi/mốc, rủi ro cao, chi phí, bàn giao", "TT-01, TT-04, TT-07, TT-09, TT-15, TT-18, TT-19", "Cao", "Cao", "Trung lập", "Ủng hộ", "Slack #bao-cao-tuan", "Có", "Đạt", "Giả định: giảng viên được mời vào Slack (xem báo cáo) và nhóm Zalo riêng với nhóm"),
    ("SH-05", "Quản lý KS", "Người dùng: dashboard, nhật ký, AI, quản lý tài khoản", "Giả định", "KPI dashboard, quyền, báo cáo ca, kết quả demo", "TT-15, TT-16", "Cao", "Trung bình", "Trung lập", "Ủng hộ", "Zalo nhóm WPC + Giảng viên", "Có", "Đạt", "Vai trò giả định; giảng viên hoặc thành viên đóng vai khi phỏng vấn/UAT"),
    ("SH-06", "Lễ tân", "Người dùng: nhận/trả phòng tại quầy (Web)", "Giả định", "Quy trình check-in/out, thông báo lỗi, thay đổi màn hình", "TT-15, TT-16", "Thấp", "Cao", "Trung lập", "Ủng hộ", "Zalo nhóm WPC + Giảng viên", "Có", "Đạt", "Vai trò giả định"),
    ("SH-07", "NV BP–BT", "Người dùng: nhận việc dọn/sửa trên Android", "Giả định", "Việc được giao, thao tác mobile, quá hạn", "TT-15, TT-16", "Thấp", "Cao", "Trung lập", "Ủng hộ", "Zalo nhóm WPC + Giảng viên", "Có", "Bảo", "Vai trò gộp buồng phòng–bảo trì (chốt 15/09)"),
    ("SH-08", "Người vận hành", "Phục hồi tài khoản quản trị ngoài app (WPCTeam)", "Nội bộ", "Sự cố hạ tầng, runbook, rollback", "TT-17, TT-19", "Thấp", "Thấp", "Ủng hộ", "Ủng hộ", "Zalo nhóm WPC (nội bộ)", "Không", "Đạt", "Do chính thành viên nhóm đảm nhiệm nên không tính thêm kênh"),
    ("SH-09", "Nhà cung cấp hạ tầng", "VPS, Domain, OpenAI API", "Bên ngoài", "Hóa đơn, hạn mức sử dụng, cảnh báo dịch vụ (chiều vào)", "TT-18", "Thấp", "Thấp", "Trung lập", "Trung lập", "GitHub repo", "Không", "Đạt", "Chỉ nhận thông tin từ họ (email dịch vụ); không gửi báo cáo"),
    ("SH-10", "Lớp học", "Các nhóm cùng lớp đọc bài học chia sẻ", "Bên ngoài", "Bài học rút ra từ dự án: nghiệp vụ, kỹ thuật, quản lý dự án", "TT-21", "Thấp", "Cao", "Trung lập", "Ủng hộ", "Zalo nhóm lớp", "Không", "Đạt", "Khán giả theo nhóm, không tính kênh cá nhân"),
]
rows = []
for s in SH:
    rows.append(list(s[:8]) + [F_GRP, F_STR] + list(s[8:10]) + [F_GAP] + list(s[10:]) + HELP)
f1, l1 = table(ws, 4, H1, rows, formula_cols=("I", "J", "M", "R", "S", "T", "U"), blank_rows=6)
widths(ws, {"A": 8, "B": 18, "C": 26, "D": 11, "E": 36, "F": 22, "G": 11, "H": 11, "I": 16, "J": 38,
            "K": 13, "L": 13, "M": 16, "N": 24, "O": 11, "P": 12, "Q": 34})
for col in "RSTU":
    ws.column_dimensions[col].hidden = True
dv(ws, f"D{f1}:D{l1}", "=DS_LoaiBLQ")
dv(ws, f"G{f1}:H{l1}", "=DS_Muc")
dv(ws, f"K{f1}:L{l1}", "=DS_ThamGia")
dv(ws, f"N{f1}:N{l1}", "=DS_Kenh")
dv(ws, f"O{f1}:O{l1}", "=DS_CoKhong")
dv(ws, f"P{f1}:P{l1}", "=DS_NguoiGui")
cf(ws, f"I{f1}:I{l1}", f'$I{f1}="Quản lý chặt"', RED)
cf(ws, f"I{f1}:I{l1}", f'$I{f1}="Giữ hài lòng"', ORANGE)
cf(ws, f"I{f1}:I{l1}", f'$I{f1}="Thông báo đầy đủ"', BLUE)
cf(ws, f"I{f1}:I{l1}", f'$I{f1}="Theo dõi"', GREY)
cf(ws, f"M{f1}:M{l1}", f'LEFT($M{f1},8)="Cần nâng"', ORANGE)
ws.freeze_panes = "C5"
ws.auto_filter.ref = f"A4:Q{l1}"
define("DS_BLQ", f"OFFSET({q(S1)}!$B$5,0,0,COUNTA({q(S1)}!$B$5:$B$100),1)")

# =================================================================== 2. THU THẬP
TT = [
    # mã, tên, nhóm, mô tả, nguồn, phương pháp, người thu thập, tần suất, thời điểm chốt, nơi lưu, bảo mật, WBS
    ("TT-01", "Báo cáo tiến độ tuần", "Tiến độ", "% hoàn thành theo WBS, việc xong và việc tuần tới, giờ công từng người, rủi ro, chi phí, thay đổi chờ duyệt", "WBS KhachSanSach.xlsx, GitHub Issues/PR, biên bản họp", "Tổng hợp từ công cụ", "Đạt", "Hằng tuần", "Sau họp Thứ 6", "GitHub repo: plans/reports/", "Nội bộ + Giảng viên", "Toàn dự án (WBS 0)"),
    ("TT-02", "Biên bản họp nhóm", "Quản trị dự án", "Thành phần, nội dung, quyết định, việc cần làm (người, hạn), Open Question mới", "Buổi họp qua Zalo gọi nhóm", "Họp", "Bảo", "Mỗi buổi họp", "Cuối buổi họp", "GitHub repo: plans/reports/", "Nội bộ nhóm", "Áp dụng mọi sprint"),
    ("TT-03", "Kế hoạch sprint", "Phạm vi & yêu cầu", "Mục tiêu sprint, danh sách task, người làm, giờ ước lượng, tiêu chí cổng sprint", "WBS, detailed-task-breakdown.md", "Họp", "Đạt", "Đầu mỗi sprint", "Họp Thứ 3 đầu sprint", "WBS + GitHub repo", "Nội bộ + Giảng viên", "1.2, 1.3, 1.4, 1.5"),
    ("TT-04", "Báo cáo sprint review & demo", "Tiến độ", "Kết quả cổng sprint, nội dung demo, giờ thực tế so với kế hoạch, việc dời sang sprint sau", "Cổng sprint trong WBS, bản build demo", "Họp", "Đạt", "Cuối mỗi sprint", "Ngày cổng sprint", "GitHub repo: plans/reports/", "Nội bộ + Giảng viên", "1.2.6, 1.3.4, 1.4.4, 1.5.4"),
    ("TT-05", "Kết quả retro & khảo sát truyền thông", "Quản trị dự án", "Giữ / Bỏ / Thử, điểm hài lòng truyền thông thang 1–5", "Buổi retro, phiếu khảo sát trong M3", "Khảo sát", "Bảo", "Cuối mỗi sprint", "Cuối buổi retro", "GitHub repo: plans/reports/", "Nội bộ nhóm", "Áp dụng mọi sprint"),
    ("TT-06", "Trao đổi công việc & hỏi đáp", "Kỹ thuật", "Câu hỏi, vướng mắc, nhờ review, nhắc việc. Điều đã chốt phải đưa vào biên bản", "Thành viên nhóm", "Tự báo cáo", "Cả nhóm", "Khi phát sinh", "Không áp dụng", "Zalo (không phải bản lưu chính thức)", "Nội bộ nhóm", "Áp dụng mọi sprint"),
    ("TT-07", "Yêu cầu thay đổi & quyết định phạm vi", "Phạm vi & yêu cầu", "Nội dung thay đổi, lý do, ảnh hưởng giờ/mốc, người đề xuất, quyết định và người duyệt", "Thành viên, giảng viên, đại diện người dùng", "Họp", "Đạt", "Khi phát sinh", "Họp gần nhất", "Mục 6 của báo cáo tuần (M1)", "Nội bộ + Giảng viên", "1.2.1.17, 1.5.1.1"),
    ("TT-08", "Sổ Open Question & quyết định", "Phạm vi & yêu cầu", "Câu hỏi mở, giả định, người chốt, hạn chốt, tác động nếu chưa chốt", "Họp, phỏng vấn, review", "Họp", "Đạt", "Mỗi buổi họp", "Cuối buổi họp", "Mục OQ của biên bản họp (M2)", "Nội bộ nhóm", "1.2.1.18, 1.3.1"),
    ("TT-09", "Sổ rủi ro & vấn đề", "Rủi ro & vấn đề", "Rủi ro, mức độ, người xử lý, hành động, hạn. Ví dụ: thiếu 50 giờ nguồn lực (530h so với 480h)", "Họp Thứ 6, báo cáo tuần", "Họp", "Đạt", "Hằng tuần", "Họp Thứ 6", "Mục 5 của báo cáo tuần (M1)", "Nội bộ + Giảng viên", "Toàn dự án"),
    ("TT-10", "Thông báo PR, review, CI", "Kỹ thuật", "PR mở/merge, yêu cầu review, kết quả GitHub Actions (lint, test, build)", "GitHub", "Tự động từ công cụ", "Đạt", "Theo thời gian thực", "Không áp dụng", "GitHub", "Nội bộ nhóm", "1.5.1.4"),
    ("TT-11", "Báo cáo lỗi", "Chất lượng", "Mã issue, mô tả, bước tái hiện, mức lỗi, người sửa, trạng thái retest", "Kiểm thử QA, UAT, GitHub Issues", "Kiểm thử", "Bảo", "Hằng ngày (triage)", "18:00 hằng ngày trong giai đoạn triage", "GitHub Issues + file M4", "Nội bộ nhóm", "1.3.3.14, 1.5.1.1, 1.5.2.1"),
    ("TT-12", "Báo cáo kiểm thử sprint", "Chất lượng", "Kết quả kịch bản E2E, regression, tỷ lệ pass/fail, lỗi còn mở", "Lượt chạy kiểm thử", "Kiểm thử", "Bảo", "Cuối mỗi sprint", "Trước cổng sprint 1 ngày", "GitHub repo: plans/reports/", "Nội bộ + Giảng viên", "1.2.5.14, 1.3.3.13, 1.4.3.12, 1.5.3.1"),
    ("TT-13", "API contract, OpenAPI & ADR", "Kỹ thuật", "Endpoint, mã lỗi, event Socket.IO, quyết định kiến trúc", "Code backend, docs/api", "Review tài liệu/PR", "Hoàng", "Khi phát sinh", "Trước khi merge PR đổi contract", "GitHub repo: docs/api/", "Nội bộ nhóm", "1.2.3, 1.2.4.17, 1.3.2.19"),
    ("TT-14", "Design Token & đặc tả UI", "Kỹ thuật", "Màu semantic 3 trục trạng thái, typography, spacing, component dùng chung", "docs/design-tokens.md", "Review tài liệu/PR", "Bảo", "Khi phát sinh", "Khi đổi token", "GitHub repo: docs/", "Nội bộ nhóm", "1.2.5.3, 1.5.3.4"),
    ("TT-15", "Kết quả khảo sát nghiệp vụ & sign-off", "Phạm vi & yêu cầu", "Biên bản phỏng vấn, AS-IS/TO-BE, requirement baseline và xác nhận duyệt", "Phỏng vấn đại diện người dùng (giả định), workshop", "Phỏng vấn", "Đạt", "Theo đợt", "Sau mỗi buổi phỏng vấn", "GitHub repo: docs/", "Nội bộ + Giảng viên", "1.2.1"),
    ("TT-16", "Phản hồi người dùng (usability, UAT)", "Phản hồi người dùng", "Vấn đề, mức độ, quyết định sửa hoặc giữ", "Usability review 18/09, UAT 25–26/10", "Quan sát", "Bảo", "Theo đợt", "Cuối buổi review/UAT", "File M4", "Nội bộ + Giảng viên", "1.2.1.23, 1.5.3.6"),
    ("TT-17", "Cảnh báo sự cố khẩn", "Rủi ro & vấn đề", "Blocker, build/deploy hỏng, staging ngừng, chi phí AI chạm trần", "Bất kỳ thành viên, cảnh báo hệ thống", "Tự báo cáo", "Cả nhóm", "Khi phát sinh", "Ngay khi phát hiện", "Sau xử lý ghi vào sổ rủi ro (M1)", "Nội bộ nhóm", "1.5.1, 1.5.2"),
    ("TT-18", "Báo cáo chi phí & ngân sách", "Chi phí", "Dự toán đã duyệt 30.000.000 đ: nhân công, phụ cấp tăng ca, VPS, Domain, trần AI 300.000 đ, dự phòng 4.780.000 đ", "docs/project-charter.md mục 6, Resource Sheet MS Project, hóa đơn, usage OpenAI", "Tổng hợp từ công cụ", "Đạt", "Hằng tuần", "Họp Thứ 6", "Mục 4 của báo cáo tuần (M1)", "Nội bộ + Giảng viên", "1 (Phụ cấp tăng ca), 1.4.2.8, 1.5.1"),
    ("TT-19", "Release note & gói bàn giao", "Tiến độ", "Link Web HTTPS, APK Android, runbook, tài khoản demo, release note", "Build, docs/runbooks", "Review tài liệu/PR", "Đạt", "Theo đợt", "Trước ngày bàn giao", "GitHub repo", "Nội bộ + Giảng viên", "1.5.1.5, 1.5.1.8, 1.5.4"),
    ("TT-20", "Kế hoạch quản lý truyền thông", "Quản trị dự án", "File này: quy ước, lịch, kênh, KPI truyền thông", "Retro, các điều kiện cập nhật (sheet 7)", "Review tài liệu/PR", "Đạt", "Cuối mỗi sprint", "Sau retro", "GitHub repo: plans/", "Nội bộ + Giảng viên", "Quản lý dự án"),
    ("TT-21", "Bài học chia sẻ của dự án", "Quản trị dự án", "Bài viết dài về bài học nghiệp vụ, kỹ thuật, quản lý dự án; teaser, hashtag, tài liệu kèm theo", "Code và tài liệu trong repo, biên bản retro, kết quả kiểm thử", "Review tài liệu/PR", "Đạt", "Hằng tuần", "Thứ 4 trước ngày đăng (duyệt bài)", "Sheet 9 của file này + GitHub repo", "Nội bộ + Giảng viên", "Toàn dự án"),
]
ws = wb[S2]
title(ws, "2. THU THẬP CÁC LOẠI THÔNG TIN",
      "Mỗi mã TT là một loại thông tin; mã này được dùng ở sheet 3, 4, 5 và 6. Thêm loại mới ở cuối bảng.")
H2 = ["Mã TT", "Loại thông tin", "Nhóm", "Nội dung cần thu thập", "Nguồn dữ liệu", "Phương pháp thu thập",
      "Người thu thập", "Tần suất", "Thời điểm chốt số liệu", "Nơi lưu bản gốc", "Mức bảo mật", "Tham chiếu WBS"]
f2, l2 = table(ws, 4, H2, [list(t) for t in TT], blank_rows=10)
widths(ws, {"A": 8, "B": 28, "C": 18, "D": 46, "E": 32, "F": 20, "G": 13, "H": 18, "I": 22, "J": 28, "K": 20, "L": 22})
dv(ws, f"C{f2}:C{l2}", "=DS_NhomTT")
dv(ws, f"F{f2}:F{l2}", "=DS_PPThuThap")
dv(ws, f"G{f2}:G{l2}", "=DS_NguoiGui")
dv(ws, f"H{f2}:H{l2}", "=DS_TanSuat")
dv(ws, f"K{f2}:K{l2}", "=DS_BaoMat")
ws.freeze_panes = "C5"
ws.auto_filter.ref = f"A4:L{l2}"
define("DS_MaTT", f"OFFSET({q(S2)}!$A$5,0,0,COUNTA({q(S2)}!$A$5:$A$100),1)")

# =================================================================== 6. TRUY CẬP (trước sheet 3 vì DS_Kenh)
CH = [
    ("Slack #bao-cao-tuan", "Slack", "Báo cáo", "Đẩy", "Đăng file Excel báo cáo tuần (gồm rủi ro, chi phí, thay đổi chờ duyệt)", "TT-01, TT-07, TT-09, TT-18", "Cả nhóm, Giảng viên", "Cần điền link kênh", "Đạt", "Đọc và thả ✅ trong 48 giờ", "Đăng trước 10:00 Thứ 7", "Bản gốc lưu GitHub; Slack chỉ để phân phối", "Không đăng dữ liệu khách thật, mật khẩu, API key"),
    ("Slack #bao-cao-sprint", "Slack", "Báo cáo", "Đẩy", "Đăng file Excel kế hoạch sprint, báo cáo review/demo, retro, sign-off, bàn giao, bản cập nhật kế hoạch truyền thông", "TT-03, TT-04, TT-05, TT-15, TT-19, TT-20", "Cả nhóm, Giảng viên", "Cần điền link kênh", "Đạt", "Đọc trong 72 giờ", "Theo lịch sprint", "Bản gốc lưu GitHub", "Như trên"),
    ("Slack #bien-ban-hop", "Slack", "Báo cáo", "Đẩy", "Đăng file Excel biên bản sau mỗi buổi họp (kèm Open Question)", "TT-02, TT-08", "Cả nhóm", "Cần điền link kênh", "Bảo", "Đọc trong 24 giờ; người được giao việc trả lời ✅", "Trong 24 giờ sau họp", "Bản gốc lưu GitHub", "Như trên"),
    ("Slack #chat-luong-loi", "Slack", "Báo cáo", "Đẩy", "Đăng file Excel báo cáo lỗi, kiểm thử sprint, phản hồi usability/UAT", "TT-11, TT-12, TT-16", "Cả nhóm, Giảng viên (xem)", "Cần điền link kênh", "Bảo", "Blocker 4 giờ, Critical 24 giờ", "18:00 hằng ngày khi triage (16/10–27/10)", "Bản gốc lưu GitHub; issue ở GitHub Issues", "Như trên"),
    ("Slack #github-tu-dong", "Slack", "Báo cáo", "Đẩy", "Thông báo tự động từ GitHub (PR, review, CI). Ngoại lệ duy nhất không phải file Excel", "TT-10", "Cả nhóm", "Cần điền link kênh", "Đạt", "Review PR trong 24 giờ", "Theo thời gian thực", "Lịch sử nằm trên GitHub", "Chỉ cài GitHub app ở mức quyền tối thiểu"),
    ("Zalo nhóm WPC (nội bộ)", "Zalo", "Tương tác", "Tương tác", "Hỏi đáp, gỡ vướng, nhắc việc, cảnh báo khẩn; chốt gì thì ghi vào biên bản Excel", "TT-06, TT-17", "Đạt, Hoàng, Bảo", "Cần điền link nhóm", "Đạt", "[HỎI] 4 giờ; [KHẨN] 30 phút", "08:00–22:00", "Ghim tin quan trọng; không coi là bản lưu chính thức", "Không gửi mật khẩu, token qua Zalo"),
    ("Zalo nhóm WPC + Giảng viên", "Zalo", "Tương tác", "Tương tác", "Trao đổi với giảng viên: hỏi đáp, đặt lịch demo, xin ý kiến thay đổi phạm vi, nhắc đã đăng báo cáo", "TT-07, TT-15, TT-19", "Cả nhóm, Giảng viên", "Cần điền link nhóm", "Đạt", "24 giờ", "Giờ hành chính", "Kết luận được ghi vào báo cáo tuần/biên bản", "Lịch sự, ngắn gọn, mỗi tin một chủ đề"),
    ("Zalo gọi nhóm (họp)", "Zalo", "Tương tác", "Tương tác", "2 buổi họp/tuần, demo cổng sprint, họp khẩn khi có Blocker", "TT-02, TT-03, TT-04", "Cả nhóm (Giảng viên khi demo)", "Gọi trong nhóm Zalo tương ứng", "Đạt", "Có mặt đúng giờ; vắng báo trước 2 giờ", "Thứ 3 và Thứ 6, 20:00–21:00", "Biên bản Excel đăng #bien-ban-hop", "Không ghi âm khi chưa được đồng ý"),
    ("GitHub repo", "GitHub", "Lưu trữ", "Kéo", "Bản gốc mọi file Excel, tài liệu, plans; nơi tra cứu chính thức", "TT-01 → TT-20 (bản gốc)", "Cả nhóm (sửa), Giảng viên (xem nếu được mời)", "https://github.com/DatTran26/khachsan-di-dong", "Đạt", "Tự tra cứu khi cần", "24/7", "Lưu vĩnh viễn, có lịch sử phiên bản", "Repo private; không commit .env, secret"),
    ("GitHub Issues/PR", "GitHub", "Lưu trữ", "Kéo", "Issue lỗi, PR, review, API contract", "TT-10, TT-11, TT-13, TT-14", "Cả nhóm", "https://github.com/DatTran26/khachsan-di-dong/issues", "Đạt", "Theo mức lỗi", "24/7", "Lưu vĩnh viễn", "Như trên"),
    ("Slack #bai-hoc-chia-se", "Slack", "Báo cáo", "Đẩy", "Đăng bài học đầy đủ hằng tuần (ngoại lệ: bài viết dạng text, không phải file Excel)", "TT-21", "Cả nhóm, Giảng viên", "Cần điền link kênh", "Đạt", "Thả cảm xúc hoặc bình luận trong 72 giờ", "Thứ 5, 09:00 hằng tuần", "Bản gốc ở sheet 9 + GitHub", "Không đưa dữ liệu khách thật, secret, link staging nội bộ"),
    ("Zalo nhóm lớp", "Zalo", "Tương tác", "Tương tác", "Đăng Nội dung bài đăng kèm mục Bài học của bài (không đăng bài đầy đủ vì nhóm lớp chưa dùng Ghi chú); các nhóm cùng lớp đọc và thảo luận", "TT-21", "Cả nhóm, Giảng viên, Lớp học", "Cần điền link nhóm", "Đạt", "Trả lời bình luận trong 24 giờ", "Thứ 5, 09:00 hằng tuần", "Kết luận thảo luận ghi lại ở sheet 9", "Không chia sẻ link repo private cho người ngoài nhóm"),
]
ws = wb[S6]
title(ws, "6. PHƯƠNG PHÁP TRUY CẬP ĐỂ NHẬN THÔNG TIN",
      "Nguyên tắc: Slack = nhóm BÁO CÁO (đăng file Excel, đẩy) · Zalo = nhóm TƯƠNG TÁC (hỏi đáp, họp, khẩn) · GitHub = KHO bản gốc (kéo).")
H6 = ["Kênh", "Nền tảng", "Vai trò kênh", "Kiểu truyền thông", "Mục đích / nội dung đăng", "Mã TT", "Ai được truy cập",
      "Cách truy cập (link)", "Quản trị kênh", "Thời gian phản hồi kỳ vọng", "Khung giờ", "Lưu trữ & tìm lại", "Quy tắc bảo mật"]
f6, l6 = table(ws, 4, H6, [list(c) for c in CH], blank_rows=5)
widths(ws, {"A": 26, "B": 10, "C": 12, "D": 13, "E": 42, "F": 24, "G": 24, "H": 34, "I": 11, "J": 24, "K": 22, "L": 30, "M": 30})
for r in range(f6, f6 + len(CH)):
    v = ws.cell(row=r, column=8).value
    if isinstance(v, str) and v.startswith("http"):
        ws.cell(row=r, column=8).hyperlink = v
        ws.cell(row=r, column=8).font = F_LINK
cf(ws, f"H{f6}:H{l6}", f'LEFT($H{f6},8)="Cần điền"', ORANGE)
dv(ws, f"D{f6}:D{l6}", '"Đẩy,Kéo,Tương tác"')
dv(ws, f"I{f6}:I{l6}", "=DS_NguoiGui")
define("DS_Kenh", f"OFFSET({q(S6)}!$A$5,0,0,COUNTA({q(S6)}!$A$5:$A$40),1)")
ws.freeze_panes = "B5"

# Ma trận quyền truy cập
r = l6 + 3
r = section(ws, r, "Ma trận quyền truy cập: bên liên quan × kênh", 13)
ACC_CH = [c[0] for c in CH]
header(ws, r, ["Bên liên quan"] + ACC_CH)
acc_head = r
ACC = {
    "Đạt": ["Quản trị"] * 12,
    "Hoàng": ["Đăng/Sửa"] * 12,
    "Bảo": ["Đăng/Sửa", "Đăng/Sửa", "Quản trị", "Quản trị"] + ["Đăng/Sửa"] * 8,
    "Giảng viên": ["Xem/Bình luận", "Xem/Bình luận", "Không", "Xem/Bình luận", "Không", "Không", "Đăng/Sửa", "Đăng/Sửa", "Xem/Bình luận", "Không", "Xem/Bình luận", "Đăng/Sửa"],
    "Quản lý KS": ["Không"] * 6 + ["Xem/Bình luận"] + ["Không"] * 5,
    "Lễ tân": ["Không"] * 6 + ["Xem/Bình luận"] + ["Không"] * 5,
    "NV BP–BT": ["Không"] * 6 + ["Xem/Bình luận"] + ["Không"] * 5,
    "Lớp học": ["Không"] * 11 + ["Xem/Bình luận"],
}
r += 1
acc_first = r
for name, vals in ACC.items():
    style_cell(ws.cell(row=r, column=1, value=name), "body")
    for i, v in enumerate(vals, 2):
        style_cell(ws.cell(row=r, column=i, value=v), "input")
    r += 1
acc_last = r - 1
style_cell(ws.cell(row=r, column=1, value="Số người truy cập được"), "body")
ws.cell(row=r, column=1).font = F_BOLD
for i in range(2, len(ACC_CH) + 2):
    col = get_column_letter(i)
    style_cell(ws.cell(row=r, column=i, value=f'=COUNTA({col}{acc_first}:{col}{acc_last})-COUNTIF({col}{acc_first}:{col}{acc_last},"Không")'), "formula")
dv(ws, f"B{acc_first}:{get_column_letter(len(ACC_CH) + 1)}{acc_last}", "=DS_Quyen")
cf(ws, f"B{acc_first}:{get_column_letter(len(ACC_CH) + 1)}{acc_last}", f'B{acc_first}="Không"', GREY)
cf(ws, f"B{acc_first}:{get_column_letter(len(ACC_CH) + 1)}{acc_last}", f'B{acc_first}="Quản trị"', BLUE)
ws.cell(row=r + 2, column=1, value="Lưu ý: Slack bản miễn phí chỉ hiển thị lịch sử 90 ngày gần nhất, vì vậy bản gốc mọi file Excel phải nằm ở GitHub repo.").font = F_NOTE

# =================================================================== 3. PHÂN PHỐI
RACI_COLS = ["Đạt", "Hoàng", "Bảo", "Giảng viên", "Quản lý KS", "Lễ tân", "NV BP–BT"]
DIST = [
    # mã, người gửi, người nhận, mục đích, thời điểm, kênh chính, kênh phụ, định dạng, mẫu, phản hồi, hạn phản hồi, RACI(7)
    ("TT-01", "Đạt", "Giảng viên, Hoàng, Bảo", "Nắm tiến độ, phát hiện lệch kế hoạch sớm", "Thứ 7, 10:00 hằng tuần", "Slack #bao-cao-tuan", "Zalo nhóm WPC + Giảng viên", "Excel (.xlsx)", "MF-01", "Có", "48 giờ", ["R/A", "C", "C", "I", "", "", ""]),
    ("TT-02", "Bảo", "Cả nhóm", "Thống nhất quyết định và việc cần làm", "Trong 24 giờ sau mỗi buổi họp", "Slack #bien-ban-hop", "Zalo nhóm WPC (nội bộ)", "Excel (.xlsx)", "MF-02", "Có", "24 giờ", ["C", "C", "R/A", "", "", "", ""]),
    ("TT-03", "Đạt", "Cả nhóm, Giảng viên", "Thống nhất cam kết của sprint", "Ngày đầu sprint, sau họp Thứ 3", "Slack #bao-cao-sprint", "Zalo nhóm WPC + Giảng viên", "Excel (.xlsx)", "MF-03", "Có", "24 giờ", ["R/A", "C", "C", "I", "", "", ""]),
    ("TT-04", "Đạt", "Giảng viên, Cả nhóm", "Nghiệm thu từng sprint, nhận phản hồi", "Ngày cổng sprint", "Slack #bao-cao-sprint", "Zalo gọi nhóm (họp)", "Excel (.xlsx)", "MF-03", "Có", "72 giờ", ["R/A", "R", "R", "C", "", "", ""]),
    ("TT-05", "Bảo", "Cả nhóm", "Cải tiến cách làm và cách truyền thông", "Trong 24 giờ sau retro", "Slack #bao-cao-sprint", "Zalo nhóm WPC (nội bộ)", "Excel (.xlsx)", "MF-03", "Không", "", ["C", "C", "R/A", "", "", "", ""]),
    ("TT-06", "Cả nhóm", "Cả nhóm", "Gỡ vướng nhanh", "Khi phát sinh", "Zalo nhóm WPC (nội bộ)", "Zalo gọi nhóm (họp)", "Tin nhắn Zalo", "MF-05", "Có", "4 giờ", ["R/A", "R", "R", "", "", "", ""]),
    ("TT-07", "Đạt", "Giảng viên, Cả nhóm", "Kiểm soát phạm vi, giữ hạn 27/10", "Trong 24 giờ sau khi phát sinh; chốt ở họp gần nhất", "Slack #bao-cao-tuan", "Zalo nhóm WPC + Giảng viên", "Excel (.xlsx)", "MF-01", "Có", "48 giờ", ["R", "C", "C", "A", "C", "", ""]),
    ("TT-08", "Đạt", "Cả nhóm", "Không để Open Question treo quá hạn", "Sau mỗi buổi họp (trong biên bản)", "Slack #bien-ban-hop", "Zalo nhóm WPC (nội bộ)", "Excel (.xlsx)", "MF-02", "Có", "Theo hạn của từng OQ", ["R/A", "C", "C", "C", "C", "", ""]),
    ("TT-09", "Đạt", "Cả nhóm, Giảng viên", "Ứng phó rủi ro sớm", "Hằng tuần trong báo cáo tuần; rủi ro Cao báo ngay", "Slack #bao-cao-tuan", "Zalo nhóm WPC + Giảng viên", "Excel (.xlsx)", "MF-01", "Có", "24 giờ với rủi ro Cao", ["R/A", "C", "C", "I", "", "", ""]),
    ("TT-10", "GitHub (tự động)", "Cả nhóm", "Review kịp thời, phát hiện build hỏng", "Theo thời gian thực", "Slack #github-tu-dong", "GitHub Issues/PR", "Thông báo tự động", "MF-06", "Có", "24 giờ", ["A", "R", "R", "", "", "", ""]),
    ("TT-11", "Bảo", "Hoàng, Đạt", "Sửa lỗi đúng hạn", "Issue ngay khi phát hiện; file tổng hợp 18:00 hằng ngày khi triage", "Slack #chat-luong-loi", "Zalo nhóm WPC (nội bộ)", "Excel (.xlsx)", "MF-04", "Có", "Blocker 4 giờ, Critical 24 giờ", ["A", "R", "R", "", "", "", ""]),
    ("TT-12", "Bảo", "Cả nhóm, Giảng viên", "Bằng chứng chất lượng cho cổng sprint", "Trước cổng sprint 1 ngày", "Slack #chat-luong-loi", "Slack #bao-cao-sprint", "Excel (.xlsx)", "MF-04", "Có", "24 giờ", ["A", "C", "R", "I", "", "", ""]),
    ("TT-13", "Hoàng", "Bảo, Đạt", "Frontend tích hợp đúng contract", "Trước khi merge PR thay đổi contract", "GitHub repo", "Zalo nhóm WPC (nội bộ)", "Markdown/OpenAPI", "MF-06", "Có", "24 giờ", ["C", "R/A", "C", "", "", "", ""]),
    ("TT-14", "Bảo", "Hoàng, Đạt", "Đồng nhất giao diện Web và Android", "Khi thay đổi token", "GitHub repo", "Zalo nhóm WPC (nội bộ)", "Markdown/OpenAPI", "MF-06", "Không", "", ["C", "I", "R/A", "", "", "", ""]),
    ("TT-15", "Đạt", "Cả nhóm, Giảng viên, Quản lý KS", "Chốt phạm vi trước khi code", "Sau mỗi buổi phỏng vấn; sign-off 15/09", "Slack #bao-cao-sprint", "Zalo nhóm WPC + Giảng viên", "Excel (.xlsx)", "MF-02", "Có", "48 giờ", ["R", "I", "I", "A", "C", "C", "C"]),
    ("TT-16", "Bảo", "Đạt, Hoàng", "Sửa trải nghiệm trước bàn giao", "Trong 24 giờ sau buổi usability/UAT", "Slack #chat-luong-loi", "Zalo nhóm WPC (nội bộ)", "Excel (.xlsx)", "MF-04", "Có", "48 giờ", ["A", "C", "R", "", "C", "C", "C"]),
    ("TT-17", "Cả nhóm", "Cả nhóm", "Xử lý sự cố ngay", "Ngay lập tức", "Zalo nhóm WPC (nội bộ)", "Zalo gọi nhóm (họp)", "Tin nhắn Zalo", "MF-05", "Có", "30 phút", ["A", "R", "R", "", "", "", ""]),
    ("TT-18", "Đạt", "Giảng viên, Cả nhóm", "Giữ chi tiêu trong hạn mức 1.500.000 đ", "Kèm báo cáo tuần; báo ngay khi dùng 80% một hạng mục", "Slack #bao-cao-tuan", "Zalo nhóm WPC + Giảng viên", "Excel (.xlsx)", "MF-01", "Không", "", ["R/A", "I", "I", "I", "", "", ""]),
    ("TT-19", "Đạt", "Giảng viên, Cả nhóm", "Nghiệm thu và bàn giao", "27/10/2026", "Slack #bao-cao-sprint", "Zalo nhóm WPC + Giảng viên", "Excel (.xlsx)", "MF-03", "Có", "72 giờ", ["R/A", "R", "R", "C", "", "", ""]),
    ("TT-20", "Đạt", "Cả nhóm, Giảng viên", "Mọi người theo cùng một quy ước", "Trong 24 giờ sau khi bản mới được duyệt", "Slack #bao-cao-sprint", "Zalo nhóm WPC (nội bộ)", "Excel (.xlsx)", "Không áp dụng", "Không", "", ["R/A", "C", "C", "I", "", "", ""]),
    ("TT-21", "Cả nhóm", "Cả nhóm, Giảng viên, Lớp học", "Lan tỏa bài học, nhận góp ý từ lớp", "Thứ 5, 09:00 hằng tuần (lịch ở sheet 9)", "Slack #bai-hoc-chia-se", "Zalo nhóm lớp", "Bài viết (text)", "MF-07", "Có", "24 giờ (trả lời bình luận)", ["A", "R", "R", "I", "", "", ""]),
]
ws = wb[S3]
title(ws, "3. CẤU TRÚC PHÂN PHỐI: THÔNG TIN GÌ, TỚI AI, KHI NÀO, BẰNG CÁCH NÀO",
      "Tên thông tin và kiểu truyền thông tự lấy theo mã TT và kênh. RACI: R làm, A chịu trách nhiệm cuối (đúng 1 người), C được hỏi ý kiến, I được thông báo.")
H3 = ["Mã TT", "Tên thông tin", "Người gửi", "Người nhận", "Mục đích", "Khi nào gửi", "Kênh chính", "Kênh phụ",
      "Kiểu truyền thông", "Định dạng", "Mẫu", "Cần phản hồi", "Hạn phản hồi"] + RACI_COLS + ["Kiểm tra RACI"]
F_NAME = f'=IF(A{{r}}="","",IFERROR(INDEX({rng(S2, "B", 5, 100)},MATCH(A{{r}},{rng(S2, "A", 5, 100)},0)),"Mã chưa có ở sheet 2"))'
F_KIEU = f'=IF(G{{r}}="","",IFERROR(INDEX({rng(S6, "D", 5, 40)},MATCH(G{{r}},{rng(S6, "A", 5, 40)},0)),"Kênh chưa có ở sheet 6"))'
F_RACI = '=IF(COUNTA(N{r}:T{r})=0,"",IF(COUNTIF(N{r}:T{r},"*A*")=1,"OK","Cần đúng 1 người A"))'
rows = []
for d in DIST:
    rows.append([d[0], F_NAME, d[1], d[2], d[3], d[4], d[5], d[6], F_KIEU, d[7], d[8], d[9], d[10]] + d[11] + [F_RACI])
f3, l3 = table(ws, 4, H3, rows, formula_cols=("B", "I", "U"), blank_rows=10)
widths(ws, {"A": 8, "B": 28, "C": 15, "D": 24, "E": 30, "F": 30, "G": 24, "H": 24, "I": 12, "J": 15, "K": 9, "L": 9, "M": 16, "U": 16})
for i in range(14, 21):
    ws.column_dimensions[get_column_letter(i)].width = 8
dv(ws, f"A{f3}:A{l3}", "=DS_MaTT")
dv(ws, f"C{f3}:C{l3}", "=DS_NguoiGui")
dv(ws, f"G{f3}:H{l3}", "=DS_Kenh")
dv(ws, f"J{f3}:J{l3}", "=DS_DinhDang")
dv(ws, f"L{f3}:L{l3}", "=DS_CoKhong")
dv(ws, f"N{f3}:T{l3}", "=DS_RACI")
for col in range(14, 21):
    for rr in range(f3, l3 + 1):
        ws.cell(row=rr, column=col).alignment = CENTER
cf(ws, f"U{f3}:U{l3}", f'$U{f3}="OK"', GREEN)
cf(ws, f"U{f3}:U{l3}", f'LEFT($U{f3},3)="Cần"', RED)
cf(ws, f"N{f3}:T{l3}", f'ISNUMBER(SEARCH("A",N{f3}))', ORANGE)
cf(ws, f"I{f3}:I{l3}", f'$I{f3}="Đẩy"', BLUE)
cf(ws, f"I{f3}:I{l3}", f'$I{f3}="Tương tác"', GREEN)
ws.freeze_panes = "C5"
ws.auto_filter.ref = f"A4:U{l3}"

# =================================================================== 4. ĐỊNH DẠNG
ws = wb[S4]
title(ws, "4. ĐỊNH DẠNG THÔNG TIN ĐỂ TRUYỀN THÔNG",
      "Quy ước: mọi nội dung đăng nhóm Slack là FILE EXCEL theo mẫu M1–M4 trong file này (sao chép sheet mẫu ra file mới). Zalo dùng tin nhắn có tiền tố.")
H4 = ["Mã mẫu", "Tên mẫu", "Dùng cho mã TT", "Định dạng", "Sheet mẫu", "Cấu trúc bắt buộc", "Quy ước tên file",
      "Kênh đăng", "Người lập", "Người duyệt", "Nơi lưu bản gốc"]
FMT = [
    ("MF-01", "Báo cáo tiến độ tuần", "TT-01, TT-07, TT-09, TT-18", "Excel (.xlsx)", M1, "1 Thông tin chung + tình trạng RAG; 2 Việc đã xong (có bằng chứng PR/issue); 3 Kế hoạch tuần tới; 4 Giờ công; 5 Chi phí; 6 Rủi ro; 7 Thay đổi chờ duyệt", "WPC_BaoCaoTuan_T{tuần}_{yyyy-mm-dd}.xlsx", "Slack #bao-cao-tuan", "Đạt", "Đạt", "plans/reports/"),
    ("MF-02", "Biên bản họp", "TT-02, TT-08, TT-15", "Excel (.xlsx)", M2, "1 Thông tin buổi họp; 2 Thành phần và tỷ lệ có mặt; 3 Nội dung; 4 Quyết định; 5 Việc cần làm (người, hạn); 6 Open Question mới", "WPC_BienBan_{yyyy-mm-dd}_{T3|T6}.xlsx", "Slack #bien-ban-hop", "Bảo", "Đạt", "plans/reports/"),
    ("MF-03", "Báo cáo sprint (kế hoạch, review, retro, bàn giao)", "TT-03, TT-04, TT-05, TT-19", "Excel (.xlsx)", M3, "1 Sprint và mục tiêu; 2 Cổng sprint; 3 Giờ công; 4 Kết quả demo; 5 Retro Giữ/Bỏ/Thử; 6 Khảo sát truyền thông 1–5", "WPC_BaoCaoSprint_S{n}_{yyyy-mm-dd}.xlsx", "Slack #bao-cao-sprint", "Đạt", "Giảng viên", "plans/reports/"),
    ("MF-04", "Báo cáo chất lượng (lỗi, kiểm thử, UAT)", "TT-11, TT-12, TT-16", "Excel (.xlsx)", M4, "1 Thông tin bản build; 2 Tổng hợp lỗi theo mức × trạng thái (tự tính); 3 Danh sách lỗi có link issue; 4 Kết quả kịch bản kiểm thử, tỷ lệ pass (tự tính)", "WPC_ChatLuong_{yyyy-mm-dd}.xlsx", "Slack #chat-luong-loi", "Bảo", "Đạt", "plans/reports/"),
    ("MF-05", "Tin nhắn tương tác Zalo", "TT-06, TT-17", "Tin nhắn Zalo", "Không áp dụng", "[Tiền tố] + nội dung 1 chủ đề + người cần trả lời (@tag) + hạn (nếu có). Xem bảng tiền tố bên dưới", "Không áp dụng", "Zalo nhóm WPC (nội bộ)", "Cả nhóm", "Không áp dụng", "Không lưu; chốt thì ghi vào M2"),
    ("MF-06", "Issue, PR và tài liệu kỹ thuật", "TT-10, TT-13, TT-14", "Markdown/OpenAPI", "Không áp dụng", "Mẫu trong .github/ (issue, PR checklist); OpenAPI trong docs/api/", "Theo quy ước commit/branch trong AGENTS.md", "GitHub Issues/PR", "Hoàng, Bảo", "Đạt", "GitHub"),
    ("MF-07", "Bài học chia sẻ", "TT-21", "Bài viết (text)", S9, "Nội dung bài đăng ≤ 80 chữ (đăng Zalo lớp cùng mục Bài học); bài đầy đủ 300–700 tiếng đăng Slack: Bối cảnh → Vấn đề → Cách làm → Kiểm thử/kết quả → Bài học → Câu hỏi thảo luận; 4 hashtag chung + 3–5 hashtag chủ đề; liệt kê tài liệu nguồn", "BH-{số}_{slug}", "Slack #bai-hoc-chia-se", "Tác giả (bạn chọn)", "Người duyệt (bạn chọn)", "Sheet 9 + GitHub"),
]
f4, l4 = table(ws, 4, H4, [list(x) for x in FMT], blank_rows=3)
for rr in range(f4, f4 + len(FMT)):
    c = ws.cell(row=rr, column=5)
    if c.value in (M1, M2, M3, M4, S9):
        c.hyperlink = f"#{q(c.value)}!A1"
        c.font = F_LINK
widths(ws, {"A": 8, "B": 30, "C": 22, "D": 15, "E": 22, "F": 60, "G": 34, "H": 22, "I": 11, "J": 12, "K": 22})
dv(ws, f"D{f4}:D{l4}", "=DS_DinhDang")
dv(ws, f"H{f4}:H{l4}", "=DS_Kenh")
ws.freeze_panes = "B5"

r = l4 + 3
r = section(ws, r, "Quy ước chung cho file Excel đăng nhóm Slack", 11)
RULES = [
    ("Font và bố cục", "Arial 10; dòng 1 là tiêu đề; mục 1 luôn là thông tin chung; không gộp ô trong vùng bảng dữ liệu"),
    ("Phiên bản", "Sửa file đã đăng thì thêm hậu tố _v2, _v3 và đăng lại vào cùng thread Slack; không xóa bản cũ"),
    ("Tình trạng RAG", "Xanh: đúng kế hoạch · Vàng: lệch nhưng còn bù được trong sprint · Đỏ: ảnh hưởng mốc, cần giảng viên hoặc PM quyết định"),
    ("Tin đăng kèm file", "Dòng 1: [BÁO CÁO] + tên + kỳ; dòng 2: tình trạng RAG; dòng 3: tối đa 3 ý chính; dòng 4: việc cần người đọc làm (nếu có)"),
    ("Bảo mật", "Không đưa dữ liệu khách thật, mật khẩu, token, API key; dữ liệu demo là dữ liệu giả lập"),
    ("Ngôn ngữ", "Tiếng Việt có dấu; thuật ngữ theo glossary dự án (lưu trú, vệ sinh, bảo trì)"),
    ("Lưu bản gốc", "Commit file vào plans/reports/ trước hoặc cùng lúc đăng Slack (Slack miễn phí chỉ giữ 90 ngày lịch sử)"),
]
header(ws, r, ["Quy ước", "Nội dung"])
for i, (k, v) in enumerate(RULES, r + 1):
    style_cell(ws.cell(row=i, column=1, value=k), "body")
    ws.cell(row=i, column=1).font = F_BOLD
    ws.merge_cells(start_row=i, start_column=2, end_row=i, end_column=6)
    style_cell(ws.cell(row=i, column=2, value=v), "input")
r = r + len(RULES) + 3
r = section(ws, r, "Tiền tố tin nhắn và mức ưu tiên", 11)
PREFIX = [
    ("[BÁO CÁO]", "Slack", "Đăng file Excel định kỳ", "Theo hạn đọc của kênh", "[BÁO CÁO] Báo cáo tuần T06 (06/10–12/10) – Vàng"),
    ("[KHẨN]", "Zalo nhóm WPC (nội bộ)", "Blocker, build/deploy hỏng, staging ngừng", "30 phút; quá hạn thì gọi Zalo", "[KHẨN] Staging trả 502 sau deploy 21:10 – @Hoàng xem log giúp"),
    ("[HỎI]", "Zalo", "Cần câu trả lời để làm tiếp", "4 giờ (nội bộ) / 24 giờ (giảng viên)", "[HỎI] Hạn xử lý việc bảo trì (MAINTENANCE_DUE_MINUTES) chốt bao nhiêu phút? – @Đạt trước 17:00"),
    ("[CHỐT]", "Zalo → ghi vào M2", "Thông báo quyết định đã thống nhất", "Không cần trả lời; ghi vào biên bản gần nhất", "[CHỐT] Đóng băng phạm vi từ 15/10, CR mới chuyển sang sau bàn giao"),
    ("[FYI]", "Zalo", "Thông tin tham khảo, không cần hành động", "Không cần trả lời", "[FYI] Đã cập nhật OpenAPI check-out trong docs/api"),
]
header(ws, r, ["Tiền tố", "Kênh", "Khi dùng", "Thời gian phản hồi", "Ví dụ"])
for i, row in enumerate(PREFIX, r + 1):
    for j, v in enumerate(row, 1):
        style_cell(ws.cell(row=i, column=j, value=v), "input")
    ws.cell(row=i, column=1).font = F_BOLD

# =================================================================== 5. LỊCH BIỂU
EV = []  # (ngày, giờ, hoạt động, loại, mã TT, chủ trì, thành phần, kênh, đầu ra, ghi chú)


def add(d, t, act, kind, tt, owner, who, ch, out, note=""):
    EV.append((d, t, act, kind, tt, owner, who, ch, out, note))


D = date
sprint_start = {D(2026, 9, 8): 1, D(2026, 9, 22): 2, D(2026, 10, 6): 3, D(2026, 10, 20): 4}
d = D(2026, 9, 8)
while d <= D(2026, 10, 27):
    wd = d.weekday()  # 0 = Thứ 2
    if wd == 1:  # Thứ 3
        if d in sprint_start:
            n = sprint_start[d]
            act = f"Họp Thứ 3 đầu Sprint {n}: lập kế hoạch sprint" if n == 1 else f"Họp Thứ 3 đầu Sprint {n}: review + retro Sprint {n - 1}, lập kế hoạch Sprint {n}"
            add(d, "20:00", act, "Họp định kỳ", "TT-02, TT-03" if n == 1 else "TT-02, TT-03, TT-05", "Đạt", "Cả nhóm", "Zalo gọi nhóm (họp)", "Biên bản M2 + kế hoạch sprint M3")
            add(d, "21:30", f"Đăng kế hoạch Sprint {n}", "Báo cáo định kỳ", "TT-03", "Đạt", "Cả nhóm, Giảng viên", "Slack #bao-cao-sprint", "File M3 (phần kế hoạch)")
            if n > 1:
                add(d, "21:15", f"Rà soát kế hoạch truyền thông cuối Sprint {n - 1}", "Rà soát kế hoạch", "TT-20", "Đạt", "Cả nhóm", "Zalo gọi nhóm (họp)", "Cập nhật sheet 7, nhật ký phiên bản")
        elif d == D(2026, 10, 27):
            add(d, "20:00", "Họp Thứ 3 cuối dự án: retro Sprint 4 và tổng kết", "Họp định kỳ", "TT-02, TT-05", "Đạt", "Cả nhóm", "Zalo gọi nhóm (họp)", "Biên bản M2 + retro M3")
            add(d, "21:15", "Rà soát kế hoạch truyền thông cuối dự án (bài học kinh nghiệm)", "Rà soát kế hoạch", "TT-20", "Đạt", "Cả nhóm", "Zalo gọi nhóm (họp)", "Nhật ký phiên bản + KPI sheet 8")
        else:
            add(d, "20:00", "Họp Thứ 3: rà tiến độ, phân việc", "Họp định kỳ", "TT-02", "Đạt", "Cả nhóm", "Zalo gọi nhóm (họp)", "Biên bản M2")
        post = (d + timedelta(days=1), "20:00") if d < D(2026, 10, 27) else (d, "21:45")
        add(post[0], post[1], f"Đăng biên bản họp Thứ 3 ({d:%d/%m})", "Báo cáo định kỳ", "TT-02, TT-08", "Bảo", "Cả nhóm", "Slack #bien-ban-hop", "File M2")
    if wd == 4:  # Thứ 6
        add(d, "20:00", "Họp Thứ 6: tiến độ tuần, rủi ro, Open Question, chi phí", "Họp định kỳ", "TT-02, TT-08, TT-09", "Đạt", "Cả nhóm", "Zalo gọi nhóm (họp)", "Biên bản M2; số liệu cho M1")
        add(d + timedelta(days=1), "09:00", f"Đăng biên bản họp Thứ 6 ({d:%d/%m})", "Báo cáo định kỳ", "TT-02, TT-08", "Bảo", "Cả nhóm", "Slack #bien-ban-hop", "File M2")
        week = (d - D(2026, 9, 8)).days // 7 + 1
        add(d + timedelta(days=1), "10:00", f"Đăng báo cáo tiến độ tuần T{week:02d}", "Báo cáo định kỳ", "TT-01, TT-09, TT-18", "Đạt", "Giảng viên, Cả nhóm", "Slack #bao-cao-tuan", "File M1", "Nhắn Zalo nhóm với giảng viên khi đã đăng")
    d += timedelta(days=1)

# Mốc và hoạt động nghiệp vụ lấy từ WBS (KhachSanSach.xlsx)
add(D(2026, 9, 8), "08:00", "Xác định sponsor, người quyết định, bên liên quan", "Hoạt động nghiệp vụ", "TT-15", "Đạt", "Cả nhóm", "Zalo nhóm WPC (nội bộ)", "Danh sách bên liên quan (sheet 1)", "WBS 1.2.2.6")
add(D(2026, 9, 9), "08:00", "Gửi lịch kickoff và lịch phỏng vấn theo vai trò", "Hoạt động nghiệp vụ", "TT-15", "Đạt", "Giảng viên", "Zalo nhóm WPC + Giảng viên", "Lịch phỏng vấn", "WBS 1.2.1.2")
add(D(2026, 9, 10), "09:00", "Kickoff dự án: mục tiêu MVP, hạn bàn giao", "Mốc dự án", "TT-15", "Đạt", "Cả nhóm, Giảng viên", "Zalo gọi nhóm (họp)", "Biên bản kickoff M2", "WBS 1.2.1.7")
add(D(2026, 9, 10), "11:00", "Phỏng vấn quản lý khách sạn (giả định) về dashboard 50 phòng", "Hoạt động nghiệp vụ", "TT-15", "Đạt", "Quản lý KS", "Zalo gọi nhóm (họp)", "Biên bản phỏng vấn M2", "WBS 1.2.1.7")
add(D(2026, 9, 11), "09:00", "Phỏng vấn lễ tân (giả định) về check-in, check-out, tra cứu", "Hoạt động nghiệp vụ", "TT-15", "Đạt", "Lễ tân", "Zalo gọi nhóm (họp)", "Biên bản phỏng vấn M2", "WBS 1.2.1.7")
add(D(2026, 9, 11), "11:00", "Phỏng vấn nhân viên buồng phòng (giả định)", "Hoạt động nghiệp vụ", "TT-15", "Đạt", "NV BP–BT", "Zalo gọi nhóm (họp)", "Biên bản phỏng vấn M2", "WBS 1.2.1.10")
add(D(2026, 9, 11), "14:00", "Phỏng vấn nhân viên bảo trì (giả định)", "Hoạt động nghiệp vụ", "TT-15", "Đạt", "NV BP–BT", "Zalo gọi nhóm (họp)", "Biên bản phỏng vấn M2", "WBS 1.2.1.11")
add(D(2026, 9, 13), "14:00", "Đăng tổng hợp phỏng vấn, AS-IS và problem statement", "Hoạt động nghiệp vụ", "TT-15", "Đạt", "Cả nhóm, Giảng viên", "Slack #bao-cao-sprint", "File Excel tổng hợp", "WBS 1.2.1.12–13")
add(D(2026, 9, 14), "14:00", "Mở sổ Open Question, giả định và quyết định", "Hoạt động nghiệp vụ", "TT-08", "Đạt", "Cả nhóm", "Slack #bien-ban-hop", "Sổ OQ (trong M2)", "WBS 1.2.1.18")
add(D(2026, 9, 15), "08:00", "Workshop xác nhận quy trình TO-BE và exception flow", "Hoạt động nghiệp vụ", "TT-15", "Đạt", "Cả nhóm, Giảng viên", "Zalo gọi nhóm (họp)", "Biên bản workshop M2", "WBS 1.2.1.19")
add(D(2026, 9, 15), "10:00", "Sign-off requirement baseline", "Mốc dự án", "TT-15", "Đạt", "Giảng viên", "Zalo nhóm WPC + Giảng viên", "Xác nhận duyệt (ngày, người duyệt)", "WBS 1.2.1.20")
add(D(2026, 9, 18), "08:00", "Usability review wireframe với người dùng đại diện", "Kiểm thử & chất lượng", "TT-16", "Bảo", "Quản lý KS, Lễ tân, NV BP–BT", "Zalo gọi nhóm (họp)", "Sổ phản hồi M4", "WBS 1.2.1.23")
add(D(2026, 9, 18), "17:00", "Đăng sổ phản hồi usability", "Kiểm thử & chất lượng", "TT-16", "Bảo", "Đạt, Hoàng", "Slack #chat-luong-loi", "File M4", "WBS 1.2.1.23")
add(D(2026, 9, 21), "08:00", "Chốt KPI dashboard, provider AI, trần chi phí 300.000 đ", "Hoạt động nghiệp vụ", "TT-07, TT-08", "Đạt", "Cả nhóm, Giảng viên", "Zalo nhóm WPC + Giảng viên", "Quyết định ghi vào M1 mục 7", "WBS 1.4.1.1–3")
add(D(2026, 9, 24), "09:00", "Thông báo quyết định đổi hạn bàn giao 02/11 → 27/10", "Mốc dự án", "TT-07, TT-20", "Đạt", "Cả nhóm, Giảng viên", "Slack #bao-cao-tuan", "Quyết định trong M1", "Validation log trong plan.md, 24/09")
GATES = [
    (D(2026, 9, 25), D(2026, 9, 28), 1, "quản lý đăng nhập, sửa phòng, seed 50 phòng, RBAC, realtime hai client", "WBS 1.2.6"),
    (D(2026, 10, 8), D(2026, 10, 9), 2, "check-in/out, dọn, bảo trì, audit sau commit", "WBS 1.3.4"),
    (D(2026, 10, 15), D(2026, 10, 16), 3, "dashboard khớp fixture, AI không gửi PII, fallback 15 giây", "WBS 1.4.4"),
]
for qa, gate, n, scope, ref in GATES:
    add(qa, "17:00", f"Đăng báo cáo kiểm thử Sprint {n}", "Kiểm thử & chất lượng", "TT-12", "Bảo", "Cả nhóm, Giảng viên", "Slack #chat-luong-loi", "File M4", ref)
    add(gate, "19:00", f"Cổng Sprint {n}: demo ({scope})", "Mốc dự án", "TT-04", "Đạt", "Cả nhóm, Giảng viên", "Zalo gọi nhóm (họp)", "Kết quả demo", ref)
    add(gate, "21:00", f"Đăng báo cáo sprint review Sprint {n}", "Báo cáo định kỳ", "TT-04", "Đạt", "Giảng viên, Cả nhóm", "Slack #bao-cao-sprint", "File M3", ref)
add(D(2026, 10, 14), "21:00", "Phát hành kế hoạch quản lý truyền thông v1.0", "Rà soát kế hoạch", "TT-20", "Đạt", "Cả nhóm, Giảng viên", "Slack #bao-cao-sprint", "File kế hoạch truyền thông này", "Sheet 7, nhật ký phiên bản")
add(D(2026, 10, 15), "16:00", "Đóng băng phạm vi, mở bảng triage lỗi", "Mốc dự án", "TT-07, TT-11", "Đạt", "Cả nhóm, Giảng viên", "Slack #bao-cao-sprint", "Thông báo [CHỐT] + bảng triage M4", "WBS 1.5.1.1")
d = D(2026, 10, 16)
while d <= D(2026, 10, 27):
    add(d, "18:00", "Đăng file triage lỗi hằng ngày", "Kiểm thử & chất lượng", "TT-11", "Bảo", "Hoàng, Đạt", "Slack #chat-luong-loi", "File M4", "WBS 1.5.1.1 (ghi chú hằng ngày)")
    d += timedelta(days=1)
add(D(2026, 10, 20), "16:00", "Bật thông báo GitHub Actions vào Slack", "Mốc dự án", "TT-10", "Đạt", "Cả nhóm", "Slack #github-tu-dong", "CI chạy trên mọi PR", "WBS 1.5.1.4")
add(D(2026, 10, 21), "15:00", "Đăng runbook deploy/rollback và script nghiệm thu", "Mốc dự án", "TT-19", "Đạt", "Cả nhóm, Giảng viên", "Slack #bao-cao-sprint", "Link tài liệu + file M3", "WBS 1.5.1.5, 1.5.1.7")
add(D(2026, 10, 22), "15:00", "Thống nhất release checklist và tiêu chí go/no-go", "Mốc dự án", "TT-19", "Đạt", "Cả nhóm", "Zalo nhóm WPC (nội bộ)", "Checklist go/no-go", "WBS 1.5.3.1")
add(D(2026, 10, 25), "08:00", "Diễn tập UAT ngày 1 theo script nghiệm thu", "Kiểm thử & chất lượng", "TT-16", "Bảo", "Cả nhóm, vai trò người dùng giả định", "Zalo gọi nhóm (họp)", "Sổ phản hồi UAT M4", "WBS 1.5.3.6")
add(D(2026, 10, 26), "08:00", "Diễn tập UAT ngày 2, xác nhận bản sửa", "Kiểm thử & chất lượng", "TT-16", "Bảo", "Cả nhóm, vai trò người dùng giả định", "Zalo gọi nhóm (họp)", "Sổ phản hồi UAT M4", "WBS 1.5.3.6")
add(D(2026, 10, 26), "17:00", "Đăng kết quả UAT và báo cáo kiểm thử Sprint 4", "Kiểm thử & chất lượng", "TT-12, TT-16", "Bảo", "Cả nhóm, Giảng viên", "Slack #chat-luong-loi", "File M4", "WBS 1.5.3.6")
add(D(2026, 10, 27), "11:00", "Bàn giao: Web HTTPS, APK, CI xanh, runbook, handover pack", "Mốc dự án", "TT-19", "Đạt", "Giảng viên, Cả nhóm", "Zalo gọi nhóm (họp)", "Biên bản bàn giao", "WBS 1.5.4")
add(D(2026, 10, 27), "14:00", "Đăng gói bàn giao và release note", "Báo cáo định kỳ", "TT-19", "Đạt", "Giảng viên, Cả nhóm", "Slack #bao-cao-sprint", "File M3 (bàn giao) + link", "WBS 1.5.1.8")
for ls in LESSONS:
    add(ls["date"], "09:00", f"Đăng bài học {ls['id']}: {ls['title']}", "Báo cáo định kỳ", "TT-21", "Cả nhóm", "Cả nhóm, Giảng viên, Lớp học", "Slack #bai-hoc-chia-se", "Bài đầy đủ trên Slack; Nội dung bài đăng + mục Bài học trên Zalo lớp", "Sheet 9")
EV.sort(key=lambda e: (e[0], e[1]))

ws = wb[S5]
title(ws, "5. LỊCH BIỂU TẠO VÀ PHÂN PHỐI THÔNG TIN (08/09 – 27/10/2026)",
      "Thứ, tuần, sprint và cảnh báo tự tính. Sự kiện trước ngày lập kế hoạch (14/10) để 'Cần xác nhận': nhóm đổi sang Đã hoàn thành / Hoãn / Hủy theo thực tế.")
H5 = ["Mã SK", "Ngày", "Thứ", "Tuần", "Sprint", "Giờ", "Hoạt động / sự kiện", "Loại", "Mã TT", "Chủ trì / người lập",
      "Thành phần / người nhận", "Kênh", "Đầu ra", "Trạng thái", "Cảnh báo", "Ghi chú / tham chiếu"]
F_THU = '=IF(B{r}="","",CHOOSE(WEEKDAY(B{r}),"CN","T2","T3","T4","T5","T6","T7"))'
F_TUAN = '=IF(B{r}="","",INT((B{r}-NGAY_BD)/7)+1)'
F_SPR = '=IF(B{r}="","",IF(OR(B{r}<NGAY_BD,B{r}>NGAY_KT),"Ngoài dự án",INDEX(SPRINT_TEN,MATCH(B{r},SPRINT_BD,1))))'
F_WARN = ('=IF(OR(B{r}="",N{r}="Đã hoàn thành",N{r}="Hủy"),"",IF(N{r}="Cần xác nhận","Cần xác nhận kết quả",'
          'IF(B{r}<NGAY_DG,"Quá hạn – cần cập nhật",IF(B{r}-NGAY_DG<=3,"Sắp diễn ra",""))))')
rows = []
for i, e in enumerate(EV, 1):
    status = "Cần xác nhận" if e[0] < PLAN_DATE else "Kế hoạch"
    rows.append([f"SK-{i:03d}", e[0], F_THU, F_TUAN, F_SPR, e[1], e[2], e[3], e[4], e[5], e[6], e[7], e[8], status, F_WARN, e[9]])
f5, l5 = table(ws, 4, H5, rows, formula_cols=("C", "D", "E", "O"), blank_rows=20)
for rr in range(f5, l5 + 1):
    ws.cell(row=rr, column=2).number_format = "dd/mm/yyyy"
    ws.cell(row=rr, column=4).number_format = "0"
    for col in (3, 4, 5, 6):
        ws.cell(row=rr, column=col).alignment = CENTER
widths(ws, {"A": 9, "B": 11, "C": 6, "D": 6, "E": 10, "F": 7, "G": 50, "H": 18, "I": 16, "J": 12, "K": 24, "L": 24, "M": 28, "N": 14, "O": 20, "P": 28})
dv(ws, f"H{f5}:H{l5}", "=DS_LoaiSK")
dv(ws, f"J{f5}:J{l5}", "=DS_NguoiGui")
dv(ws, f"L{f5}:L{l5}", "=DS_Kenh")
dv(ws, f"N{f5}:N{l5}", "=DS_TrangThai")
cf(ws, f"O{f5}:O{l5}", f'LEFT($O{f5},7)="Quá hạn"', RED)
cf(ws, f"O{f5}:O{l5}", f'LEFT($O{f5},12)="Cần xác nhận"', ORANGE)
cf(ws, f"O{f5}:O{l5}", f'$O{f5}="Sắp diễn ra"', BLUE)
cf(ws, f"N{f5}:N{l5}", f'$N{f5}="Đã hoàn thành"', GREEN)
cf(ws, f"A{f5}:M{l5}", f'AND($B{f5}<>"",$B{f5}=NGAY_DG)', BLUE)
ws.freeze_panes = "H5"
ws.auto_filter.ref = f"A4:P{l5}"
EV_LAST = l5

# =================================================================== 7. CẬP NHẬT KẾ HOẠCH
ws = wb[S7]
title(ws, "7. PHƯƠNG PHÁP CẬP NHẬT KẾ HOẠCH THEO TIẾN ĐỘ DỰ ÁN",
      "Kế hoạch được rà soát bắt buộc ở retro cuối mỗi sprint và ngay khi xảy ra một điều kiện kích hoạt bên dưới.")
r = section(ws, 4, "A. Trọng tâm truyền thông theo từng giai đoạn", 8)
HA = ["Giai đoạn", "Bắt đầu", "Kết thúc", "Trạng thái", "Trọng tâm truyền thông", "Thông tin ưu tiên", "Điều chỉnh tần suất / kênh", "Bên liên quan trọng tâm"]
PH = [
    ("Sprint 1", "Thu thập yêu cầu, chốt phạm vi, dựng nền tảng", "TT-15, TT-08, TT-03", "Tương tác với giảng viên và người dùng giả định nhiều nhất (phỏng vấn, workshop, sign-off) qua Zalo", "Giảng viên, Quản lý KS, Lễ tân, NV BP–BT"),
    ("Sprint 2", "Đồng bộ API contract giữa backend và frontend; chốt rule vận hành", "TT-13, TT-14, TT-11, TT-08", "Thêm báo cáo lỗi; review PR qua #github-tu-dong; Open Question phải chốt trong 2 buổi họp", "Hoàng, Bảo"),
    ("Sprint 3", "Chốt KPI và an toàn AI; kiểm soát chi phí AI; review PR dashboard", "TT-07, TT-18, TT-12", "Báo cáo chi phí AI hằng tuần; cảnh báo [KHẨN] khi dùng 80% trần 300.000 đ", "Giảng viên, Quản lý KS"),
    ("Sprint 4", "Đóng băng phạm vi, triage, go/no-go, UAT, bàn giao", "TT-11, TT-16, TT-17, TT-19", "Tăng tần suất: file triage 18:00 hằng ngày; họp khẩn qua Zalo khi có Blocker; mọi CR mới phải được giảng viên duyệt", "Cả nhóm, Giảng viên"),
]
F_PH_BD = '=INDEX(SPRINT_BD,MATCH(A{r},SPRINT_TEN,0))'
F_PH_KT = '=INDEX(SPRINT_KT,MATCH(A{r},SPRINT_TEN,0))'
F_PH_TT = '=IF(NGAY_DG>C{r},"Đã qua",IF(NGAY_DG>=B{r},"Đang diễn ra","Sắp tới"))'
fa, la = table(ws, r, HA, [[p[0], F_PH_BD, F_PH_KT, F_PH_TT] + list(p[1:]) for p in PH], formula_cols=("B", "C", "D"))
for rr in range(fa, la + 1):
    for col in (2, 3):
        ws.cell(row=rr, column=col).number_format = "dd/mm/yyyy"
cf(ws, f"D{fa}:D{la}", f'$D{fa}="Đang diễn ra"', GREEN)
cf(ws, f"D{fa}:D{la}", f'$D{fa}="Đã qua"', GREY)

r = section(ws, la + 3, "B. Điều kiện kích hoạt cập nhật kế hoạch", 8)
HB = ["Mã", "Điều kiện kích hoạt", "Ví dụ trong dự án", "Người phát hiện", "Hành động", "Sheet bị ảnh hưởng", "Thời hạn cập nhật"]
TRG = [
    ("TR-01", "Kết thúc sprint (retro)", "Retro Sprint 3 ngày 20/10", "Đạt", "Rà KPI sheet 8, kết quả khảo sát M3; sửa tần suất/kênh chưa hiệu quả", "3, 5, 6, 8", "24 giờ sau retro"),
    ("TR-02", "Yêu cầu thay đổi được duyệt làm đổi phạm vi hoặc mốc", "Hạn bàn giao đổi 02/11 → 27/10 (quyết định 24/09)", "Đạt", "Cập nhật lịch biểu, thông báo [CHỐT] trên Zalo, ghi vào M1", "5, 3", "24 giờ"),
    ("TR-03", "Thêm, bớt bên liên quan hoặc đổi vai trò", "Mời người dùng thật tham gia UAT thay vai trò giả định", "Bất kỳ ai", "Thêm vào sheet 1, cấp quyền ở sheet 6, bổ sung RACI ở sheet 3", "1, 3, 6, 8", "Trước khi người đó tham gia"),
    ("TR-04", "Kênh không hiệu quả (KPI không đạt 2 lần liên tiếp)", "Báo cáo tuần không ai xác nhận đọc trong 48 giờ", "Đạt", "Đổi kênh/khung giờ hoặc rút gọn mẫu", "3, 4, 6", "Họp gần nhất"),
    ("TR-05", "Rủi ro mức Cao mới hoặc sự cố", "Chi phí AI chạm 80% trần; staging ngừng", "Bất kỳ ai", "Thêm thông tin hoặc luồng báo khẩn, rút ngắn thời gian phản hồi", "2, 3", "Ngay lập tức"),
    ("TR-06", "Thay đổi công cụ hoặc giới hạn công cụ", "Slack miễn phí chỉ giữ 90 ngày lịch sử", "Đạt", "Cập nhật nơi lưu bản gốc và quy tắc truy cập", "4, 6", "1 tuần"),
    ("TR-07", "Chuyển giai đoạn dự án", "Từ Sprint 3 sang đóng băng phạm vi 15/10", "Đạt", "Áp dụng tần suất của giai đoạn mới ở bảng A", "5, 7", "Ngày chuyển giai đoạn"),
]
fb, lb = table(ws, r, HB, [list(t) for t in TRG], blank_rows=3)

r = section(ws, lb + 3, "C. Quy trình cập nhật", 8)
HC = ["Bước", "Việc cần làm", "Người làm", "Kênh", "Đầu ra"]
STEP = [
    ("1", "Phát hiện điều kiện kích hoạt và báo trong nhóm", "Bất kỳ ai", "Zalo nhóm WPC (nội bộ) với tiền tố [HỎI]", "Đề xuất thay đổi"),
    ("2", "Đánh giá ảnh hưởng: thông tin nào, ai, kênh nào, lịch nào", "Đạt", "Không áp dụng", "Ghi chú ảnh hưởng (trong 24 giờ)"),
    ("3", "Thảo luận và thống nhất ở buổi họp gần nhất", "Cả nhóm", "Zalo gọi nhóm (họp)", "Quyết định trong biên bản M2"),
    ("4", "Sửa file, tăng phiên bản (thay đổi lớn +1.0, nhỏ +0.1), ghi nhật ký bảng D", "Đạt", "GitHub repo", "Phiên bản mới của file"),
    ("5", "Phát hành: đăng file Excel mới, ghim tin, nhắn [FYI] trên Zalo", "Đạt", "Slack #bao-cao-sprint", "Mọi người dùng cùng một bản"),
    ("6", "Theo dõi hiệu quả ở retro tiếp theo bằng KPI sheet 8", "Bảo", "Zalo gọi nhóm (họp)", "Khảo sát truyền thông trong M3"),
]
fc, lc = table(ws, r, HC, [list(s) for s in STEP])

r = section(ws, lc + 3, "D. Nhật ký phiên bản", 8)
HD = ["Phiên bản", "Ngày", "Người sửa", "Nội dung thay đổi", "Lý do / điều kiện kích hoạt", "Sheet bị ảnh hưởng", "Người duyệt"]
fd, ld = table(ws, r, HD, [["1.0", PLAN_DATE, "Đạt", "Lập kế hoạch quản lý truyền thông cho toàn dự án; sự kiện trước 14/10 ghi ở trạng thái 'Cần xác nhận'", "Yêu cầu lập kế hoạch truyền thông cho các bên liên quan", "Tất cả", "Chờ duyệt"],
                            ["1.1", PLAN_DATE, "Đạt", "Thêm sheet 9 (8 bài học chia sẻ: 4 nghiệp vụ, 2 quản lý dự án, 1 làm việc nhóm, 1 kỹ thuật), TT-21, kênh Slack #bai-hoc-chia-se và Zalo nhóm lớp, bên liên quan Lớp học; mẫu M1 dùng dự toán 30.000.000 đ theo charter", "Yêu cầu truyền thông nội dung chia sẻ của dự án (TR-03: thêm bên liên quan)", "1, 2, 3, 4, 5, 6, 8, 9, M1", "Chờ duyệt"]], blank_rows=9)
for rr in range(fd, ld + 1):
    ws.cell(row=rr, column=2).number_format = "dd/mm/yyyy"
dv(ws, f"C{fd}:C{ld}", "=DS_NguoiGui")
LOG_V = f"{q(S7)}!$A${fd}:$A${ld}"
LOG_D = f"{q(S7)}!$B${fd}:$B${ld}"

r = section(ws, ld + 3, "E. Lịch rà soát định kỳ", 8)
HE = ["Lần rà soát", "Ngày", "Dịp", "Trạng thái", "Kết quả / thay đổi"]
REV = [
    ("Cuối Sprint 1", D(2026, 9, 22), "Retro Sprint 1", "Không áp dụng", "Kế hoạch lập ngày 14/10, chưa có bản để rà"),
    ("Cuối Sprint 2", D(2026, 10, 6), "Retro Sprint 2", "Không áp dụng", "Kế hoạch lập ngày 14/10, chưa có bản để rà"),
    ("Cuối Sprint 3", D(2026, 10, 20), "Retro Sprint 3", "Chưa đến hạn", ""),
    ("Cuối dự án", D(2026, 10, 27), "Retro Sprint 4, bài học kinh nghiệm", "Chưa đến hạn", ""),
]
fe, le = table(ws, r, HE, [list(x) for x in REV], blank_rows=2)
dv(ws, f"D{fe}:D{le}", "=DS_TTRaSoat")
widths(ws, {"A": 12, "B": 34, "C": 34, "D": 16, "E": 46, "F": 30, "G": 40, "H": 30})

# =================================================================== 8. PHÂN TÍCH
ws = wb[S8]
title(ws, "8. PHÂN TÍCH TRUYỀN THÔNG",
      "Toàn bộ số liệu tự tính từ các sheet 1–7. Ô vàng ở bảng KPI là chỉ số nhóm nhập tay sau mỗi retro.")
B1 = (rng(S1, "D", 5, 100), rng(S1, "O", 5, 100), rng(S1, "B", 5, 100), rng(S1, "I", 5, 100), rng(S1, "M", 5, 100))
r = section(ws, 4, "A. Số kênh truyền thông tiềm năng: N × (N − 1) / 2", 8)
header(ws, r, ["Kịch bản", "Số người (N)", "Số kênh", "Diễn giải"])
CHAN = [
    ("Chỉ nội bộ nhóm", f'=COUNTIFS({B1[0]},"Nội bộ",{B1[1]},"Có")', "Ba thành viên trao đổi trực tiếp, nên một nhóm Zalo là đủ"),
    ("Nội bộ + bên ngoài (giảng viên)", f'=COUNTIFS({B1[0]},"Nội bộ",{B1[1]},"Có")+COUNTIFS({B1[0]},"Bên ngoài",{B1[1]},"Có")', "Thêm giảng viên làm số kênh tăng gấp đôi, cần kênh báo cáo riêng"),
    ("Toàn bộ bên liên quan được tính", f'=COUNTIF({B1[1]},"Có")', "Gồm 3 vai trò người dùng giả định; mọi kênh đều đi qua đầu mối Đạt hoặc Bảo"),
]
first_ch = r + 1
for i, (k, n, note) in enumerate(CHAN, r + 1):
    style_cell(ws.cell(row=i, column=1, value=k), "body")
    style_cell(ws.cell(row=i, column=2, value=n), "formula")
    style_cell(ws.cell(row=i, column=3, value=f"=B{i}*(B{i}-1)/2"), "formula")
    style_cell(ws.cell(row=i, column=4, value=note), "body")
TOTAL_CH_ROW = r + 3
r = r + 5
r = section(ws, r, "B. Lưới quyền lực – mức quan tâm", 8)
header(ws, r, ["Nhóm", "Số bên liên quan", "Thành viên", "Chiến lược"])
for i, (g, col) in enumerate([("Quản lý chặt", "R"), ("Giữ hài lòng", "S"), ("Thông báo đầy đủ", "T"), ("Theo dõi", "U")], r + 1):
    style_cell(ws.cell(row=i, column=1, value=g), "body")
    style_cell(ws.cell(row=i, column=2, value=f'=COUNTIF({B1[3]},A{i})'), "formula")
    style_cell(ws.cell(row=i, column=3, value=f'=_xlfn.TEXTJOIN(", ",TRUE,{rng(S1, col, 5, 100)})'), "formula")
    style_cell(ws.cell(row=i, column=4, value=f'=IFERROR(INDEX(CL_NOIDUNG,MATCH(A{i},CL_NHOM,0)),"")'), "formula")
cf(ws, f"A{r + 1}:A{r + 1}", "TRUE", RED)
cf(ws, f"A{r + 2}:A{r + 2}", "TRUE", ORANGE)
cf(ws, f"A{r + 3}:A{r + 3}", "TRUE", BLUE)
cf(ws, f"A{r + 4}:A{r + 4}", "TRUE", GREY)
r += 6
style_cell(ws.cell(row=r, column=1, value="Bên liên quan cần nâng mức tham gia"), "body")
ws.cell(row=r, column=1).font = F_BOLD
style_cell(ws.cell(row=r, column=2, value=f'=COUNTIF({B1[4]},"Cần nâng*")'), "formula")
style_cell(ws.cell(row=r, column=3, value=f'=COUNTIF({B1[4]},"Cần nâng*")/MAX(1,COUNTA({B1[2]}))'), "formula")
ws.cell(row=r, column=3).number_format = "0%"
style_cell(ws.cell(row=r, column=4, value="Đưa giảng viên và người dùng giả định từ Trung lập lên Ủng hộ bằng demo cổng sprint và UAT có phản hồi được ghi nhận"), "body")
ENG_ROW = r

r = section(ws, r + 3, "C. Tải truyền thông theo người (từ sheet 3)", 8)
header(ws, r, ["Bên liên quan", "Số TT là người gửi", "Tỷ lệ gửi", "Số TT giữ vai trò R", "Số TT giữ vai trò A", "Nhận xét"])
S3C = {name: get_column_letter(14 + i) for i, name in enumerate(RACI_COLS)}
load_first = r + 1
for i, name in enumerate(RACI_COLS, r + 1):
    col = S3C[name]
    style_cell(ws.cell(row=i, column=1, value=name), "body")
    style_cell(ws.cell(row=i, column=2, value=f'=COUNTIF({rng(S3, "C")},A{i})'), "formula")
    style_cell(ws.cell(row=i, column=3, value=f'=IFERROR(B{i}/COUNTA({rng(S3, "A")}),0)'), "formula")
    ws.cell(row=i, column=3).number_format = "0%"
    style_cell(ws.cell(row=i, column=4, value=f'=COUNTIF({rng(S3, col)},"R*")'), "formula")
    style_cell(ws.cell(row=i, column=5, value=f'=COUNTIF({rng(S3, col)},"*A*")'), "formula")
    style_cell(ws.cell(row=i, column=6, value=f'=IF(C{i}>=0.4,"Điểm nghẽn (≥40% số loại thông tin): nên ủy quyền bớt",IF(AND(D{i}>0,E{i}=0),"Có thể nhận vai trò A cho thông tin mình trực tiếp làm",""))'), "formula")
load_last = r + len(RACI_COLS)
cf(ws, f"F{load_first}:F{load_last}", f'LEFT($F{load_first},9)="Điểm nghẽ"', RED)

r = section(ws, load_last + 3, "D. Phân bổ theo kênh (từ sheet 3, 5, 6)", 8)
header(ws, r, ["Kênh", "Kiểu", "Số TT dùng làm kênh chính", "Số TT dùng làm kênh phụ", "Số sự kiện trong lịch", "Tổng lượt sử dụng"])
ch_first = r + 1
for i in range(len(CH)):
    rr = ch_first + i
    src = f6 + i
    style_cell(ws.cell(row=rr, column=1, value=f'={q(S6)}!A{src}'), "formula")
    style_cell(ws.cell(row=rr, column=2, value=f'={q(S6)}!D{src}'), "formula")
    style_cell(ws.cell(row=rr, column=3, value=f'=COUNTIF({rng(S3, "G")},A{rr})'), "formula")
    style_cell(ws.cell(row=rr, column=4, value=f'=COUNTIF({rng(S3, "H")},A{rr})'), "formula")
    style_cell(ws.cell(row=rr, column=5, value=f'=COUNTIF({rng(S5, "L")},A{rr})'), "formula")
    style_cell(ws.cell(row=rr, column=6, value=f"=SUM(C{rr}:E{rr})"), "formula")
ch_last = ch_first + len(CH) - 1
rr = ch_last + 1
style_cell(ws.cell(row=rr, column=1, value="Tổng"), "body")
ws.cell(row=rr, column=1).font = F_BOLD
for col in "CDEF":
    style_cell(ws.cell(row=rr, column=" ABCDEF".index(col), value=f"=SUM({col}{ch_first}:{col}{ch_last})"), "formula")
rr += 2
header(ws, rr, ["Kiểu truyền thông", "Số TT (kênh chính)", "Tỷ lệ"])
kind_first = rr + 1
for i, k in enumerate(["Đẩy", "Kéo", "Tương tác"], rr + 1):
    style_cell(ws.cell(row=i, column=1, value=k), "body")
    style_cell(ws.cell(row=i, column=2, value=f'=COUNTIF({rng(S3, "I")},A{i})'), "formula")
    style_cell(ws.cell(row=i, column=3, value=f"=IFERROR(B{i}/SUM($B${kind_first}:$B${kind_first + 2}),0)"), "formula")
    ws.cell(row=i, column=3).number_format = "0%"
kind_last = kind_first + 2

r = section(ws, kind_last + 3, "E. Lịch truyền thông theo sprint (từ sheet 5)", 8)
header(ws, r, ["Sprint", "Số sự kiện", "Đã hoàn thành", "Cần xác nhận / quá hạn", "Tỷ lệ hoàn thành"])
sp_first = r + 1
for i, s in enumerate(SPRINTS + [("Ngoài dự án",)], r + 1):
    style_cell(ws.cell(row=i, column=1, value=s[0]), "body")
    style_cell(ws.cell(row=i, column=2, value=f'=COUNTIF({rng(S5, "E")},A{i})'), "formula")
    style_cell(ws.cell(row=i, column=3, value=f'=COUNTIFS({rng(S5, "E")},A{i},{rng(S5, "N")},"Đã hoàn thành")'), "formula")
    style_cell(ws.cell(row=i, column=4, value=f'=COUNTIFS({rng(S5, "E")},A{i},{rng(S5, "O")},"Cần xác nhận*")+COUNTIFS({rng(S5, "E")},A{i},{rng(S5, "O")},"Quá hạn*")'), "formula")
    style_cell(ws.cell(row=i, column=5, value=f"=IFERROR(C{i}/B{i},0)"), "formula")
    ws.cell(row=i, column=5).number_format = "0%"
sp_last = sp_first + len(SPRINTS)

r = section(ws, sp_last + 3, "F. Chỉ số hiệu quả truyền thông (KPI)", 8)
header(ws, r, ["Chỉ số", "Cách đo", "Mục tiêu", "Thực tế", "So sánh", "Đánh giá", "Nguồn"])
ev_b, ev_n, ev_o, ev_h, ev_l = (rng(S5, c) for c in "BNOHL")
KPI = [
    ("Sự kiện đã đến hạn được xác nhận hoàn thành", "Đã hoàn thành ÷ số sự kiện có ngày ≤ ngày đánh giá", 0.9, f'=IFERROR(COUNTIFS({ev_n},"Đã hoàn thành",{ev_b},"<="&NGAY_DG)/COUNTIFS({ev_b},"<="&NGAY_DG),0)', ">=", "Sheet 5", True),
    ("Sự kiện quá hạn hoặc chưa xác nhận", "Số dòng cảnh báo Quá hạn / Cần xác nhận", 0, f'=COUNTIF({ev_o},"Quá hạn*")+COUNTIF({ev_o},"Cần xác nhận*")', "<=", "Sheet 5", False),
    ("Báo cáo định kỳ gửi đúng hạn", "Báo cáo định kỳ đã hoàn thành ÷ báo cáo định kỳ đã đến hạn", 1, f'=IFERROR(COUNTIFS({ev_h},"Báo cáo định kỳ",{ev_n},"Đã hoàn thành",{ev_b},"<="&NGAY_DG)/COUNTIFS({ev_h},"Báo cáo định kỳ",{ev_b},"<="&NGAY_DG),0)', ">=", "Sheet 5", True),
    ("Dòng phân phối có RACI hợp lệ", "Số dòng 'OK' ÷ số mã TT ở sheet 3", 1, f'=IFERROR(COUNTIF({rng(S3, "U")},"OK")/COUNTA({rng(S3, "A")}),0)', ">=", "Sheet 3", True),
    ("Bên liên quan đạt mức tham gia mong muốn", "Số dòng 'Đạt mong muốn' ÷ số bên liên quan", 0.8, f'=IFERROR(COUNTIF({B1[4]},"Đạt mong muốn")/COUNTA({B1[2]}),0)', ">=", "Sheet 1", True),
    ("Thời gian phản hồi trung bình tin [HỎI] trên Zalo (giờ)", "Nhóm ước lượng từ lịch sử Zalo khi retro", 4, None, "<=", "Nhập tay sau retro", False),
    ("Open Question quá hạn chốt", "Đếm trong sổ OQ (M2) tại ngày đánh giá", 0, None, "<=", "Nhập tay sau retro", False),
    ("Điểm hài lòng truyền thông (1–5)", "Điểm trung bình khảo sát trong M3", 4, None, ">=", "Nhập tay sau retro", False),
    ("Số lần làm lại do hiểu sai thông tin (mỗi sprint)", "Đếm task phải làm lại vì nhận sai/thiếu thông tin", 1, None, "<=", "Nhập tay sau retro", False),
    ("Báo cáo Slack được xác nhận đọc đúng hạn", "Số file có đủ ✅ trong hạn ÷ số file đã đăng", 0.9, None, ">=", "Nhập tay sau retro", True),
    ("Bài học đăng đúng lịch", "Bài 'Đã đăng' ÷ bài có ngày đăng ≤ ngày đánh giá", 1, f'=IFERROR(COUNTIFS({rng(S9, "H", 5, 100)},"Đã đăng",{rng(S9, "J", 5, 100)},"<="&NGAY_DG)/COUNTIFS({rng(S9, "J", 5, 100)},"<="&NGAY_DG),"")', ">=", "Sheet 9", True),
]
kpi_first = r + 1
for i, (name, how, target, formula, op, src, pct) in enumerate(KPI, r + 1):
    style_cell(ws.cell(row=i, column=1, value=name), "body")
    style_cell(ws.cell(row=i, column=2, value=how), "body")
    style_cell(ws.cell(row=i, column=3, value=target), "input")
    style_cell(ws.cell(row=i, column=4, value=formula), "formula" if formula else "input")
    style_cell(ws.cell(row=i, column=5, value=op), "body")
    style_cell(ws.cell(row=i, column=6, value=f'=IF(D{i}="","Chưa đo",IF(E{i}=">=",IF(D{i}>=C{i},"Đạt","Chưa đạt"),IF(D{i}<=C{i},"Đạt","Chưa đạt")))'), "formula")
    style_cell(ws.cell(row=i, column=7, value=src), "body")
    if pct:
        ws.cell(row=i, column=3).number_format = "0%"
        ws.cell(row=i, column=4).number_format = "0%"
    for col in (3, 4, 5, 6):
        ws.cell(row=i, column=col).alignment = CENTER
kpi_last = kpi_first + len(KPI) - 1
cf(ws, f"F{kpi_first}:F{kpi_last}", f'$F{kpi_first}="Đạt"', GREEN)
cf(ws, f"F{kpi_first}:F{kpi_last}", f'$F{kpi_first}="Chưa đạt"', RED)
cf(ws, f"F{kpi_first}:F{kpi_last}", f'$F{kpi_first}="Chưa đo"', GREY)

r = section(ws, kpi_last + 3, "G. Rào cản truyền thông và cách giảm thiểu", 8)
BAR = [
    ("Một người kiêm nhiều vai trò", "Đạt là PO, BA, PM, Tech Lead, DevOps và là người gửi phần lớn thông tin (bảng C)", "Thông tin chờ một người, chậm quyết định", "Bảo làm thư ký và chủ kênh chất lượng; Hoàng chủ API contract; Đạt chỉ duyệt", "Đạt", "Cao"),
    ("Thông tin phân tán giữa Zalo và Slack", "Quyết định nằm trong tin nhắn Zalo, không ai ghi lại", "Hiểu sai, làm lại", "Quy tắc [CHỐT]: mọi quyết định phải vào biên bản Excel đăng #bien-ban-hop", "Bảo", "Cao"),
    ("Làm việc bán thời gian", "Khoảng 20 giờ/tuần mỗi người, giờ làm lệch nhau", "Trả lời chậm, lỡ hạn", "Khung giờ Zalo 08:00–22:00; thời gian phản hồi theo tiền tố; 2 buổi họp cố định", "Đạt", "Trung bình"),
    ("Thiếu nguồn lực (530h so với 480h)", "Áp lực tiến độ ở Sprint 3–4; Hoàng 222h so với tham chiếu 160h", "Bỏ qua báo cáo, biên bản", "Mẫu Excel ngắn, có công thức sẵn; báo cáo chỉ 3 ý chính", "Đạt", "Cao"),
    ("Người dùng chỉ là giả định trên giấy", "Không có phản hồi thật từ quản lý, lễ tân, nhân viên", "Yêu cầu sai với thực tế", "Giảng viên hoặc thành viên đóng vai trong phỏng vấn/UAT; ghi rõ là giả định", "Đạt", "Trung bình"),
    ("Giới hạn lịch sử Slack miễn phí", "Chỉ xem được 90 ngày gần nhất", "Mất bằng chứng khi nghiệm thu", "Bản gốc mọi file Excel commit vào GitHub", "Đạt", "Thấp"),
]
fg, lg = table(ws, r, ["Rào cản", "Biểu hiện", "Tác động", "Giải pháp", "Người phụ trách", "Mức"], [list(b) for b in BAR], blank_rows=2)
dv(ws, f"F{fg}:F{lg}", "=DS_Muc")
dv(ws, f"E{fg}:E{lg}", "=DS_NguoiGui")
widths(ws, {"A": 34, "B": 40, "C": 24, "D": 52, "E": 16, "F": 14, "G": 18, "H": 4})

# Biểu đồ
ch1 = BarChart()
ch1.type = "col"
ch1.title = "Sự kiện truyền thông theo sprint"
ch1.y_axis.title = "Số sự kiện"
ch1.add_data(Reference(ws, min_col=2, max_col=3, min_row=sp_first - 1, max_row=sp_last), titles_from_data=True)
ch1.set_categories(Reference(ws, min_col=1, min_row=sp_first, max_row=sp_last))
ch1.height, ch1.width = 7.5, 15
ws.add_chart(ch1, "I5")
ch2 = BarChart()
ch2.type = "bar"
ch2.title = "Tổng lượt sử dụng theo kênh"
ch2.add_data(Reference(ws, min_col=6, min_row=ch_first - 1, max_row=ch_last), titles_from_data=True)
ch2.set_categories(Reference(ws, min_col=1, min_row=ch_first, max_row=ch_last))
ch2.legend = None
ch2.height, ch2.width = 9, 15
ws.add_chart(ch2, "I22")
ch3 = BarChart()
ch3.type = "col"
ch3.title = "Tải truyền thông theo người"
ch3.add_data(Reference(ws, min_col=2, max_col=2, min_row=load_first - 1, max_row=load_last), titles_from_data=True)
ch3.add_data(Reference(ws, min_col=4, max_col=5, min_row=load_first - 1, max_row=load_last), titles_from_data=True)
ch3.set_categories(Reference(ws, min_col=1, min_row=load_first, max_row=load_last))
ch3.height, ch3.width = 7.5, 15
ws.add_chart(ch3, "I42")

# =================================================================== MẪU M1–M4


def info_block(ws, row, items):
    """items: (nhãn, giá trị, kiểu, dv, number_format)."""
    for i, (label, val, kind, valid, fmt) in enumerate(items, row):
        c = ws.cell(row=i, column=1, value=label)
        c.font, c.border = F_BOLD, BORDER
        ws.merge_cells(start_row=i, start_column=2, end_row=i, end_column=4)
        c = ws.cell(row=i, column=2, value=val)
        style_cell(c, kind)
        if fmt:
            c.number_format = fmt
        if valid:
            dv(ws, f"B{i}", valid)
    return row + len(items)


def template_note(ws, tag):
    ws["A2"] = (f"Mẫu {tag}: sao chép sheet này ra file mới (chuột phải → Move or Copy → New book), đặt tên theo quy ước ở sheet 4, "
                "điền ô vàng, đăng lên kênh Slack tương ứng và commit bản gốc vào GitHub. Dòng nền xanh lá là dòng ví dụ, xóa trước khi gửi.")
    ws["A2"].font = F_NOTE
    ws.merge_cells("A2:H2")
    ws["A2"].alignment = WRAP
    ws.row_dimensions[2].height = 30


# ---- M1 Báo cáo tuần
ws = wb[M1]
title(ws, "BÁO CÁO TIẾN ĐỘ TUẦN – KHÁCH SẠN DI ĐỘNG")
template_note(ws, "MF-01")
r = section(ws, 4, "1. Thông tin chung", 8)
r = info_block(ws, r, [
    ("Tuần số", 6, "input", None, None),
    ("Từ ngày", "=NGAY_BD+(B5-1)*7", "formula", None, "dd/mm/yyyy"),
    ("Đến ngày", "=B6+6", "formula", None, "dd/mm/yyyy"),
    ("Sprint", '=IF(OR(B6<NGAY_BD,B6>NGAY_KT),"Ngoài dự án",INDEX(SPRINT_TEN,MATCH(B6,SPRINT_BD,1)))', "formula", None, None),
    ("Người lập", "Đạt", "input", "=DS_NguoiGui", None),
    ("Ngày gửi", None, "input", None, "dd/mm/yyyy"),
    ("Tình trạng chung (RAG)", "Vàng", "input", "=DS_RAG", None),
    ("Tóm tắt (tối đa 3 ý)", None, "input", None, None),
])
cf(ws, "B11", 'B11="Xanh"', GREEN)
cf(ws, "B11", 'B11="Vàng"', ORANGE)
cf(ws, "B11", 'B11="Đỏ"', RED)
r = section(ws, r + 1, "2. Việc đã hoàn thành trong tuần", 8)
_, r = table(ws, r, ["Mã WBS", "Công việc", "Người phụ trách", "Bằng chứng (PR / issue / link)", "Ghi chú"],
             [["1.4.2.1", "Query tổng hợp dashboard: đếm trạng thái, công suất, quá hạn", "Hoàng", "Link PR", "Dòng ví dụ"]], blank_rows=6)
for col in range(1, 6):
    ws.cell(row=r - 6, column=col).fill = FILL_EXAMPLE
dv(ws, f"C{r - 6}:C{r}", "=DS_NguoiGui")
r = section(ws, r + 2, "3. Kế hoạch tuần tới", 8)
_, r = table(ws, r, ["Mã WBS", "Công việc", "Người phụ trách", "Hạn", "Rủi ro trễ"], [], blank_rows=6)
dv(ws, f"C{r - 5}:C{r}", "=DS_NguoiGui")
r = section(ws, r + 2, "4. Giờ công", 8)
g1, g2 = table(ws, r, ["Thành viên", "Giờ kế hoạch", "Giờ thực tế", "% thực hiện"],
               [["Đạt", None, None, '=IFERROR(C{r}/B{r},"")'], ["Hoàng", None, None, '=IFERROR(C{r}/B{r},"")'], ["Bảo", None, None, '=IFERROR(C{r}/B{r},"")']],
               formula_cols=("D",), input_cols=("B", "C"))
style_cell(ws.cell(row=g2 + 1, column=1, value="Tổng"), "body")
for col in "BC":
    style_cell(ws.cell(row=g2 + 1, column=" ABC".index(col), value=f"=SUM({col}{g1}:{col}{g2})"), "formula")
style_cell(ws.cell(row=g2 + 1, column=4, value=f'=IFERROR(C{g2 + 1}/B{g2 + 1},"")'), "formula")
for rr in range(g1, g2 + 2):
    ws.cell(row=rr, column=4).number_format = "0%"
r = section(ws, g2 + 3, "5. Chi phí lũy kế (VNĐ)", 8)
F_CON, F_PCT = "=IF(B{r}=\"\",\"\",B{r}-C{r})", '=IFERROR(C{r}/B{r},"")'
BUDGET = [  # nguồn: docs/project-charter.md mục 6 – dự toán đã được giảng viên duyệt (D-04)
    ("Nhân công — Đạt", 7250000, "145h × 50.000 đ"),
    ("Nhân công — Hoàng", 9990000, "222h × 45.000 đ"),
    ("Nhân công — Bảo", 6520000, "163h × 40.000 đ"),
    ("Phụ cấp tăng ca", 800000, "2 × 400.000 đ"),
    ("VPS (Sprint 4)", 200000, "1 × 200.000 đ, D-08"),
    ("Domain (Sprint 4)", 160000, "1 × 160.000 đ"),
    ("OpenAI API (trần)", 300000, "Trần chi phí AI, D-06"),
    ("Dự phòng", 4780000, "30.000.000 − 25.220.000"),
]
c1, c2 = table(ws, r, ["Hạng mục", "Dự toán", "Đã chi lũy kế", "Còn lại", "% đã dùng", "Nguồn (project-charter.md mục 6)"],
               [[k, v, None, F_CON, F_PCT, src] for k, v, src in BUDGET],
               formula_cols=("D", "E"), input_cols=("B", "C", "F"))
rt = c2 + 1
style_cell(ws.cell(row=rt, column=1, value="Tổng theo hạng mục"), "body")
for col in "BC":
    style_cell(ws.cell(row=rt, column=" ABC".index(col), value=f"=SUM({col}{c1}:{col}{c2})"), "formula")
style_cell(ws.cell(row=rt + 1, column=1, value="Tổng dự toán đã duyệt"), "body")
style_cell(ws.cell(row=rt + 1, column=2, value=30000000), "input")
style_cell(ws.cell(row=rt + 1, column=6, value="project-charter.md, OBJ-7 và D-04"), "body")
style_cell(ws.cell(row=rt + 2, column=1, value="Chênh lệch (phải bằng 0)"), "body")
style_cell(ws.cell(row=rt + 2, column=2, value=f"=B{rt + 1}-B{rt}"), "formula")
style_cell(ws.cell(row=rt + 3, column=1, value="% ngân sách đã chi"), "body")
style_cell(ws.cell(row=rt + 3, column=2, value=f"=IFERROR(C{rt}/B{rt + 1},0)"), "formula")
for rr in range(c1, rt + 3):
    for col in (2, 3, 4):
        ws.cell(row=rr, column=col).number_format = "#,##0"
    ws.cell(row=rr, column=5).number_format = "0%"
ws.cell(row=rt + 3, column=2).number_format = "0%"
cf(ws, f"E{c1}:E{c2}", f'AND(ISNUMBER($E{c1}),$E{c1}>=0.8)', RED)
r = section(ws, rt + 5, "6. Rủi ro và vấn đề", 8)
_, r = table(ws, r, ["Mô tả", "Mức", "Người xử lý", "Hành động", "Hạn"],
             [["Thiếu 50 giờ nguồn lực (530h so với 480h)", "Cao", "Đạt", "Ưu tiên Must-have, dời việc Could-have sau bàn giao", None]], blank_rows=4)
for col in range(1, 6):
    ws.cell(row=r - 4, column=col).fill = FILL_EXAMPLE
dv(ws, f"B{r - 4}:B{r}", "=DS_Muc")
dv(ws, f"C{r - 4}:C{r}", "=DS_NguoiGui")
r = section(ws, r + 2, "7. Thay đổi và quyết định cần duyệt", 8)
_, r = table(ws, r, ["Mã CR", "Nội dung", "Lý do", "Ảnh hưởng (giờ / mốc)", "Người đề xuất", "Quyết định", "Người duyệt"], [], blank_rows=4)
dv(ws, f"F{r - 3}:F{r}", "=DS_QuyetDinh")
dv(ws, f"E{r - 3}:E{r}", "=DS_NguoiGui")
widths(ws, {"A": 24, "B": 40, "C": 16, "D": 28, "E": 18, "F": 26, "G": 14, "H": 4})

# ---- M2 Biên bản họp
ws = wb[M2]
title(ws, "BIÊN BẢN HỌP NHÓM – KHÁCH SẠN DI ĐỘNG")
template_note(ws, "MF-02")
r = section(ws, 4, "1. Thông tin buổi họp", 8)
r = info_block(ws, r, [
    ("Ngày", None, "input", None, "dd/mm/yyyy"),
    ("Giờ", "20:00–21:00", "input", None, None),
    ("Hình thức", "Zalo gọi nhóm (họp)", "input", "=DS_Kenh", None),
    ("Loại họp", "Họp định kỳ", "input", "=DS_LoaiSK", None),
    ("Chủ trì", "Đạt", "input", "=DS_NguoiGui", None),
    ("Thư ký", "Bảo", "input", "=DS_NguoiGui", None),
])
r = section(ws, r + 1, "2. Thành phần", 8)
t1, t2 = table(ws, r, ["Thành viên", "Có mặt", "Ghi chú"], [["Đạt", "Có", None], ["Hoàng", "Có", None], ["Bảo", "Có", None], ["Giảng viên", "Không", "Chỉ mời khi demo"]], input_cols=("B", "C"))
dv(ws, f"B{t1}:B{t2}", "=DS_CoKhong")
style_cell(ws.cell(row=t2 + 1, column=1, value="Tỷ lệ có mặt (thành viên nhóm)"), "body")
style_cell(ws.cell(row=t2 + 1, column=2, value=f'=IFERROR(COUNTIF(B{t1}:B{t1 + 2},"Có")/3,0)'), "formula")
ws.cell(row=t2 + 1, column=2).number_format = "0%"
r = section(ws, t2 + 3, "3. Nội dung thảo luận", 8)
_, r = table(ws, r, ["STT", "Chủ đề", "Tóm tắt thảo luận"], [], blank_rows=5)
r = section(ws, r + 2, "4. Quyết định", 8)
_, r = table(ws, r, ["STT", "Quyết định", "Người chốt", "Mã TT liên quan"], [], blank_rows=4)
dv(ws, f"C{r - 3}:C{r}", "=DS_NguoiGui")
dv(ws, f"D{r - 3}:D{r}", "=DS_MaTT")
r = section(ws, r + 2, "5. Việc cần làm", 8)
_, r = table(ws, r, ["Việc", "Người làm", "Hạn", "Trạng thái"], [], blank_rows=6)
dv(ws, f"B{r - 5}:B{r}", "=DS_NguoiGui")
dv(ws, f"D{r - 5}:D{r}", "=DS_TrangThai")
r = section(ws, r + 2, "6. Open Question mới", 8)
_, r = table(ws, r, ["Câu hỏi", "Người chốt", "Hạn chốt", "Tác động nếu chưa chốt"],
             [["Hạn xử lý việc bảo trì là bao nhiêu phút (maintenance OQ-1)?", "Đạt", None, "Job quá hạn chưa đánh cờ việc sửa khi chưa cấu hình"]], blank_rows=4)
for col in range(1, 5):
    ws.cell(row=r - 4, column=col).fill = FILL_EXAMPLE
dv(ws, f"B{r - 4}:B{r}", "=DS_NguoiGui")
widths(ws, {"A": 28, "B": 44, "C": 30, "D": 26, "E": 4})

# ---- M3 Báo cáo sprint
ws = wb[M3]
title(ws, "BÁO CÁO SPRINT – KHÁCH SẠN DI ĐỘNG")
template_note(ws, "MF-03")
r = section(ws, 4, "1. Thông tin sprint", 8)
r = info_block(ws, r, [
    ("Sprint", "Sprint 3", "input", "=SPRINT_TEN", None),
    ("Từ ngày", "=IFERROR(INDEX(SPRINT_BD,MATCH(B5,SPRINT_TEN,0)),\"\")", "formula", None, "dd/mm/yyyy"),
    ("Đến ngày", "=IFERROR(INDEX(SPRINT_KT,MATCH(B5,SPRINT_TEN,0)),\"\")", "formula", None, "dd/mm/yyyy"),
    ("Nội dung sprint", "=IFERROR(INDEX(" + f"{q(S_DM)}!${SC[3]}$4:${SC[3]}$7" + ",MATCH(B5,SPRINT_TEN,0)),\"\")", "formula", None, None),
    ("Loại báo cáo", "Review", "input", '"Kế hoạch,Review,Retro,Bàn giao"', None),
    ("Mục tiêu sprint", None, "input", None, None),
    ("Tiêu chí cổng sprint", None, "input", None, None),
    ("Kết quả cổng sprint", "Chưa đánh giá", "input", "=DS_KetQua", None),
])
cf(ws, "B12", 'B12="Đạt"', GREEN)
cf(ws, "B12", 'B12="Không đạt"', RED)
r = section(ws, r + 1, "2. Giờ công sprint", 8)
g1, g2 = table(ws, r, ["Thành viên", "Giờ kế hoạch", "Giờ thực tế", "% thực hiện"],
               [["Đạt", None, None, '=IFERROR(C{r}/B{r},"")'], ["Hoàng", None, None, '=IFERROR(C{r}/B{r},"")'], ["Bảo", None, None, '=IFERROR(C{r}/B{r},"")']],
               formula_cols=("D",), input_cols=("B", "C"))
style_cell(ws.cell(row=g2 + 1, column=1, value="Tổng"), "body")
for col in "BC":
    style_cell(ws.cell(row=g2 + 1, column=" ABC".index(col), value=f"=SUM({col}{g1}:{col}{g2})"), "formula")
style_cell(ws.cell(row=g2 + 1, column=4, value=f'=IFERROR(C{g2 + 1}/B{g2 + 1},"")'), "formula")
for rr in range(g1, g2 + 2):
    ws.cell(row=rr, column=4).number_format = "0%"
r = section(ws, g2 + 3, "3. Kết quả demo", 8)
d1, d2 = table(ws, r, ["Tính năng / kịch bản", "Kết quả", "Phản hồi của giảng viên", "Việc tiếp theo"],
               [["Dashboard 50 phòng khớp fixture", "Đạt", None, "Dòng ví dụ"]], blank_rows=5)
for col in range(1, 5):
    ws.cell(row=d1, column=col).fill = FILL_EXAMPLE
dv(ws, f"B{d1}:B{d2}", "=DS_KetQua")
style_cell(ws.cell(row=d2 + 1, column=1, value="Tỷ lệ đạt"), "body")
style_cell(ws.cell(row=d2 + 1, column=2, value=f'=IFERROR(COUNTIF(B{d1}:B{d2},"Đạt")/COUNTA(A{d1}:A{d2}),0)'), "formula")
ws.cell(row=d2 + 1, column=2).number_format = "0%"
r = section(ws, d2 + 3, "4. Retro", 8)
_, r = table(ws, r, ["Giữ (làm tốt)", "Bỏ (không hiệu quả)", "Thử (cải tiến)"], [], blank_rows=5)
r = section(ws, r + 2, "5. Khảo sát truyền thông (thang 1–5)", 8)
QS = ["Tôi nhận đủ thông tin cần để làm việc", "Thông tin đến đúng lúc", "Slack và Zalo được dùng đúng mục đích",
      "Biên bản và quyết định rõ ràng, dễ tìm", "Tôi biết hỏi ai khi vướng"]
k1, k2 = table(ws, r, ["Câu hỏi", "Đạt", "Hoàng", "Bảo", "Điểm trung bình"],
               [[qq, None, None, None, '=IFERROR(AVERAGE(B{r}:D{r}),"")'] for qq in QS], formula_cols=("E",), input_cols=("B", "C", "D"))
style_cell(ws.cell(row=k2 + 1, column=1, value="Điểm hài lòng truyền thông (đưa vào KPI sheet 8)"), "body")
ws.cell(row=k2 + 1, column=1).font = F_BOLD
style_cell(ws.cell(row=k2 + 1, column=5, value=f'=IFERROR(AVERAGE(B{k1}:D{k2}),"")'), "formula")
for rr in range(k1, k2 + 2):
    ws.cell(row=rr, column=5).number_format = "0.0"
v = DataValidation(type="whole", operator="between", formula1="1", formula2="5", allow_blank=True)
v.error = "Nhập số nguyên từ 1 đến 5"
ws.add_data_validation(v)
v.add(f"B{k1}:D{k2}")
widths(ws, {"A": 40, "B": 30, "C": 30, "D": 26, "E": 16})

# ---- M4 Báo cáo chất lượng
ws = wb[M4]
title(ws, "BÁO CÁO CHẤT LƯỢNG (LỖI, KIỂM THỬ, UAT) – KHÁCH SẠN DI ĐỘNG")
template_note(ws, "MF-04")
r = section(ws, 4, "1. Thông tin chung", 8)
r = info_block(ws, r, [
    ("Ngày", None, "input", None, "dd/mm/yyyy"),
    ("Sprint", '=IF(B5="","",IF(OR(B5<NGAY_BD,B5>NGAY_KT),"Ngoài dự án",INDEX(SPRINT_TEN,MATCH(B5,SPRINT_BD,1))))', "formula", None, None),
    ("Loại báo cáo", "Triage hằng ngày", "input", '"Triage hằng ngày,Kiểm thử sprint,Usability,UAT"', None),
    ("Bản build / phiên bản", None, "input", None, None),
    ("Người lập", "Bảo", "input", "=DS_NguoiGui", None),
])
sum_row = r + 1
r = section(ws, sum_row, "2. Tổng hợp lỗi theo mức (tự tính từ mục 3)", 8)
header(ws, r, ["Mức lỗi", "Mở", "Đang sửa", "Chờ retest", "Đóng", "Tổng"])
sum_first = r + 1
list_head = sum_first + 4 + 3  # dòng header của danh sách lỗi
LIST_FIRST, LIST_LAST = list_head + 1, list_head + 20
for i, lv in enumerate(["Blocker", "Critical", "Major", "Minor"], sum_first):
    style_cell(ws.cell(row=i, column=1, value=lv), "body")
    for j, stt in enumerate(["Mở", "Đang sửa", "Chờ retest", "Đóng"], 2):
        style_cell(ws.cell(row=i, column=j, value=f'=COUNTIFS($C${LIST_FIRST}:$C${LIST_LAST},$A{i},$F${LIST_FIRST}:$F${LIST_LAST},"{stt}")'), "formula")
    style_cell(ws.cell(row=i, column=6, value=f"=SUM(B{i}:E{i})"), "formula")
cf(ws, f"B{sum_first}:C{sum_first + 1}", f"B{sum_first}>0", RED)
section(ws, list_head - 1, "3. Danh sách lỗi (chi tiết ở GitHub Issues)", 8)
l1_, l2_ = table(ws, list_head, ["Mã issue", "Tiêu đề", "Mức", "Màn hình / API", "Người sửa", "Trạng thái", "Link", "Ngày phát hiện"],
                 [["#12 (ví dụ)", "Check-out gửi lại tạo 2 việc dọn", "Critical", "POST /stays/:id/check-out", "Hoàng", "Đang sửa", "Link issue", None]], blank_rows=19)
for col in range(1, 9):
    ws.cell(row=l1_, column=col).fill = FILL_EXAMPLE
dv(ws, f"C{l1_}:C{l2_}", "=DS_MucLoi")
dv(ws, f"E{l1_}:E{l2_}", "=DS_NguoiGui")
dv(ws, f"F{l1_}:F{l2_}", "=DS_TTLoi")
r = section(ws, l2_ + 2, "4. Kết quả kịch bản kiểm thử", 8)
e1, e2 = table(ws, r + 0, ["Kịch bản", "Nền tảng", "Kết quả", "Ghi chú"],
               [["E2E-01 Nhận phòng sẵn sàng", "Web", "Pass", "Dòng ví dụ"]], blank_rows=11)
for col in range(1, 5):
    ws.cell(row=e1, column=col).fill = FILL_EXAMPLE
dv(ws, f"B{e1}:B{e2}", '"Web,Android,Web + Android"')
dv(ws, f"C{e1}:C{e2}", "=DS_Pass")
cf(ws, f"C{e1}:C{e2}", f'$C{e1}="Pass"', GREEN)
cf(ws, f"C{e1}:C{e2}", f'$C{e1}="Fail"', RED)
style_cell(ws.cell(row=e2 + 1, column=1, value="Tỷ lệ pass"), "body")
style_cell(ws.cell(row=e2 + 1, column=3, value=f'=IFERROR(COUNTIF(C{e1}:C{e2},"Pass")/COUNTA(C{e1}:C{e2}),0)'), "formula")
ws.cell(row=e2 + 1, column=3).number_format = "0%"
widths(ws, {"A": 28, "B": 36, "C": 12, "D": 28, "E": 12, "F": 12, "G": 16, "H": 14})

# =================================================================== 9. BÀI HỌC CHIA SẺ
ws = wb[S9]
title(ws, "9. BÀI HỌC CHIA SẺ CỦA DỰ ÁN",
      "Mỗi tuần 1 bài, đăng Slack #bai-hoc-chia-se và Zalo nhóm lớp. Thời lượng = thời gian đọc, tự tính theo số tiếng và tốc độ đọc ở Danh mục. "
      "Chỗ [ĐIỀN] (tô cam): tác giả và người duyệt do bạn chọn ở cột Các bên liên quan; số liệu thực tế phải điền ở bài đầy đủ trước khi chuyển sang Chờ duyệt.")
H9 = ["ID", "Tên bài học", "Thời lượng", "Nội dung bài đăng", "HashTag", "Bài đăng đầy đủ (Kịch bản)", "Tài liệu",
      "Trạng thái", "Các bên liên quan", "Ngày đăng dự kiến", "Kênh đăng", "Nhóm chủ đề"]
F_DOC = ('=IF(F{r}="","",MAX(1,ROUND((LEN(TRIM(SUBSTITUTE(F{r},CHAR(10)," ")))'
         '-LEN(SUBSTITUTE(TRIM(SUBSTITUTE(F{r},CHAR(10)," "))," ",""))+1)/TOC_DO_DOC,0))&" phút đọc")')
rows = [[ls["id"], ls["title"], F_DOC, ls["teaser"], COMMON_TAGS + " " + ls["tags"], ls["body"], ls["docs"],
         ls["status"], ls["people"], ls["date"], LESSON_CHANNEL, ls["group"]] for ls in LESSONS]
f9, l9 = table(ws, 4, H9, rows, formula_cols=("C",), blank_rows=8)
for rr in range(f9, f9 + len(LESSONS)):
    ws.row_dimensions[rr].height = 409
    ws.cell(row=rr, column=3).alignment = CENTER
    ws.cell(row=rr, column=1).font = F_BOLD
widths(ws, {"A": 8, "B": 26, "C": 11, "D": 42, "E": 24, "F": 95, "G": 34, "H": 12, "I": 28, "J": 12, "K": 22, "L": 16})
dv(ws, f"H{f9}:H{l9}", "=DS_TTBaiHoc")
dv(ws, f"L{f9}:L{l9}", "=DS_NhomBaiHoc")
dv(ws, f"K{f9}:K{l9}", "=DS_Kenh")
cf(ws, f"F{f9}:F{l9}", f'ISNUMBER(SEARCH("[ĐIỀN",$F{f9}))', ORANGE)
cf(ws, f"I{f9}:I{l9}", f'ISNUMBER(SEARCH("[ĐIỀN",$I{f9}))', ORANGE)
cf(ws, f"H{f9}:H{l9}", f'$H{f9}="Đã đăng"', GREEN)
cf(ws, f"H{f9}:H{l9}", f'OR($H{f9}="Chờ duyệt",$H{f9}="Đã duyệt")', BLUE)
cf(ws, f"J{f9}:J{l9}", f'AND($J{f9}<>"",$J{f9}<NGAY_DG,$H{f9}<>"Đã đăng",$H{f9}<>"Hoãn")', RED)
ws.freeze_panes = "C5"
ws.auto_filter.ref = f"A4:L{l9}"
r = section(ws, l9 + 2, "Tiến độ bộ bài học (tự tính)", 11)
header(ws, r, ["Trạng thái", "Số bài"])
for i, stt in enumerate(["Ý tưởng", "Đang viết", "Chờ duyệt", "Đã duyệt", "Đã đăng", "Hoãn"], r + 1):
    style_cell(ws.cell(row=i, column=1, value=stt), "body")
    style_cell(ws.cell(row=i, column=2, value=f'=COUNTIF($H${f9}:$H${l9},A{i})'), "formula")
i = r + 7
style_cell(ws.cell(row=i, column=1, value="Bài còn chỗ [ĐIỀN]"), "body")
style_cell(ws.cell(row=i, column=2, value=f'=SUMPRODUCT(ISNUMBER(SEARCH("[ĐIỀN",$F${f9}:$F${l9}))*1)'), "formula")
header(ws, r, ["Trạng thái", "Số bài", "", "Nhóm chủ đề", "Số bài", "Tỷ lệ"])
for i, grp in enumerate(["Nghiệp vụ", "Quản lý dự án", "Làm việc nhóm", "Kỹ thuật"], r + 1):
    style_cell(ws.cell(row=i, column=4, value=grp), "body")
    style_cell(ws.cell(row=i, column=5, value=f'=COUNTIF($L${f9}:$L${l9},D{i})'), "formula")
    style_cell(ws.cell(row=i, column=6, value=f'=IFERROR(E{i}/COUNTA($A${f9}:$A${l9}),0)'), "formula")
    ws.cell(row=i, column=6).number_format = "0%"
i = r + 7
ws.cell(row=i + 2, column=1, value="Quy trình mỗi bài: tác giả viết → điền đủ [ĐIỀN] → Chờ duyệt → người duyệt góp ý (Thứ 4) → Đã duyệt → đăng Thứ 5 09:00 → Đã đăng.").font = F_NOTE

# =================================================================== TỔNG QUAN
ws = wb[S_TQ]
title(ws, "KẾ HOẠCH QUẢN LÝ TRUYỀN THÔNG DỰ ÁN")
ws["A2"] = "MVP Khách Sạn Di Động – theo dõi trạng thái phòng khách sạn realtime (Flutter Web + Android) · WPCTeam"
ws["A2"].font = F_SUB
r = section(ws, 4, "Thông tin kế hoạch", 6)
INFO = [
    ("Dự án", "Khách Sạn Di Động – MVP quản lý phòng realtime (50 phòng, dữ liệu giả lập)", "body", None),
    ("Thời gian dự án", '=TEXT(NGAY_BD,"dd/mm/yyyy")&" – "&TEXT(NGAY_KT,"dd/mm/yyyy")&" (4 sprint)"', "formula", None),
    ("Nhóm", "Đạt (PO, BA, PM, Tech Lead, DevOps) · Hoàng (Backend, Mobile) · Bảo (UI/UX, Frontend, QA)", "body", None),
    ("Chủ sở hữu kế hoạch", "Đạt – PM", "body", None),
    ("Phiên bản hiện tại", f'=IFERROR(INDEX({LOG_V},COUNTA({LOG_V})),"")', "formula", None),
    ("Ngày cập nhật gần nhất", f'=IFERROR(INDEX({LOG_D},COUNTA({LOG_V})),"")', "formula", "dd/mm/yyyy"),
    ("Ngày đánh giá", "=NGAY_DG", "formula", "dd/mm/yyyy"),
    ("Nguyên tắc kênh", "Slack = nhóm BÁO CÁO (chỉ đăng file Excel theo mẫu M1–M4) · Zalo = nhóm TƯƠNG TÁC (hỏi đáp, họp 2 buổi/tuần, khẩn) · GitHub = KHO bản gốc", "body", None),
    ("Nhịp họp", "Thứ 3 và Thứ 6, 20:00–21:00 qua Zalo gọi nhóm; báo cáo tuần đăng Slack trước 10:00 Thứ 7", "body", None),
]
for i, (k, v, kind, fmt) in enumerate(INFO, r):
    c = ws.cell(row=i, column=1, value=k)
    c.font, c.border = F_BOLD, BORDER
    ws.merge_cells(start_row=i, start_column=2, end_row=i, end_column=6)
    c = ws.cell(row=i, column=2, value=v)
    style_cell(c, kind)
    if fmt:
        c.number_format = fmt
        c.alignment = Alignment(horizontal="left", vertical="top")
    ws.row_dimensions[i].height = 28 if len(str(v)) > 90 else 16
r = r + len(INFO) + 1
r = section(ws, r, "Số liệu nhanh (tự tính)", 6)
QUICK = [
    ("Số bên liên quan", f"=COUNTA({B1[2]})", None),
    ("Số kênh truyền thông tiềm năng N(N−1)/2", f"={q(S8)}!C{TOTAL_CH_ROW}", None),
    ("Số loại thông tin (mã TT)", f'=COUNTA({rng(S2, "A", 5, 100)})', None),
    ("Số sự kiện trong lịch", f'=COUNTA({rng(S5, "A")})', None),
    ("Sự kiện đã đến hạn được xác nhận hoàn thành", f"={q(S8)}!D{kpi_first}", "0%"),
    ("Sự kiện cần xác nhận / quá hạn", f"={q(S8)}!D{kpi_first + 1}", None),
    ("Sự kiện sắp tới", f'=IFERROR(_xlfn.MINIFS({rng(S5, "B")},{rng(S5, "B")},">="&NGAY_DG),"")', "dd/mm/yyyy"),
    ("Nội dung sự kiện sắp tới", f'=IFERROR(INDEX({rng(S5, "G")},MATCH(B{{next}},{rng(S5, "B")},0)),"")', None),
    ("Bài học đã đăng", f'=COUNTIF({rng(S9, "H", 5, 100)},"Đã đăng")&" / "&COUNTA({rng(S9, "A", 5, 100)})', None),
    ("KPI đang đạt", f'=COUNTIF({q(S8)}!$F${kpi_first}:$F${kpi_last},"Đạt")&" / "&COUNTA({q(S8)}!$A${kpi_first}:$A${kpi_last})', None),
]
next_row = r + 6
for i, (k, v, fmt) in enumerate(QUICK, r):
    c = ws.cell(row=i, column=1, value=k)
    c.font, c.border = F_BOLD, BORDER
    ws.merge_cells(start_row=i, start_column=2, end_row=i, end_column=6)
    c = ws.cell(row=i, column=2, value=v.replace("{next}", str(next_row)))
    style_cell(c, "formula")
    c.alignment = Alignment(horizontal="left", vertical="top")
    if fmt:
        c.number_format = fmt
r = r + len(QUICK) + 1
r = section(ws, r, "Mục lục", 6)
header(ws, r, ["Sheet", "Nội dung", "Trả lời câu hỏi"])
TOC = [
    (S1, "Bên liên quan, nhu cầu thông tin, lưới quyền lực – quan tâm, mức tham gia", "Truyền thông cho ai, theo chiến lược nào?"),
    (S2, "Mô tả việc thu thập 20 loại thông tin", "Thông tin gì, lấy từ đâu, ai lấy, bao lâu một lần?"),
    (S3, "Cấu trúc phân phối và ma trận RACI", "Gửi tới ai, khi nào, bằng cách nào?"),
    (S4, "Định dạng, mẫu file Excel, quy ước tiền tố Zalo", "Thông tin trình bày theo định dạng nào?"),
    (S5, "Lịch biểu tạo và phân phối thông tin 08/09–27/10", "Khi nào tạo, khi nào gửi?"),
    (S6, "Kênh Slack/Zalo/GitHub, quyền và ma trận truy cập", "Nhận thông tin bằng cách nào?"),
    (S7, "Trọng tâm theo sprint, điều kiện kích hoạt, quy trình, nhật ký phiên bản", "Cập nhật kế hoạch theo tiến độ ra sao?"),
    (S8, "Số kênh, tải truyền thông, phân bổ kênh, KPI, rào cản, biểu đồ", "Truyền thông có hiệu quả không?"),
    (S9, "8 bài học chia sẻ (4 nghiệp vụ, 2 quản lý dự án, 1 làm việc nhóm, 1 kỹ thuật)", "Truyền thông nội dung chia sẻ của dự án"),
    (M1, "Mẫu báo cáo tiến độ tuần (MF-01)", "Đăng Slack #bao-cao-tuan"),
    (M2, "Mẫu biên bản họp (MF-02)", "Đăng Slack #bien-ban-hop"),
    (M3, "Mẫu báo cáo sprint (MF-03)", "Đăng Slack #bao-cao-sprint"),
    (M4, "Mẫu báo cáo chất lượng (MF-04)", "Đăng Slack #chat-luong-loi"),
    (S_DM, "Danh mục dropdown, bảng sprint, ngày đánh giá", "Sửa danh sách dùng chung ở đâu?"),
]
for i, (s, desc, qq) in enumerate(TOC, r + 1):
    c = ws.cell(row=i, column=1, value=s)
    c.hyperlink = f"#{q(s)}!A1"
    style_cell(c, "body")
    c.font = F_LINK
    style_cell(ws.cell(row=i, column=2, value=desc), "body")
    ws.merge_cells(start_row=i, start_column=3, end_row=i, end_column=6)
    style_cell(ws.cell(row=i, column=3, value=qq), "body")
r = r + len(TOC) + 2
r = section(ws, r, "Chú giải", 6)
LEG = [(FILL_INPUT, "Ô nhập / dropdown – nhóm được sửa"), (FILL_FORMULA, "Ô công thức – không sửa tay"),
       (FILL_EXAMPLE, "Dòng ví dụ trong mẫu – xóa trước khi gửi"), (FILL_HEAD, "Tiêu đề bảng")]
for i, (fill, text) in enumerate(LEG, r):
    c = ws.cell(row=i, column=1)
    c.fill, c.border = fill, BORDER
    ws.cell(row=i, column=2, value=text).font = F_BASE
widths(ws, {"A": 40, "B": 60, "C": 20, "D": 20, "E": 20, "F": 20})

# ---------------------------------------------------------------- chung cho mọi sheet
for sh in wb.worksheets:
    sh.page_setup.orientation = "landscape"
    sh.page_setup.fitToWidth = 1
    sh.page_setup.fitToHeight = 0
    sh.sheet_properties.pageSetUpPr.fitToPage = True
    for row in sh.iter_rows():
        for c in row:
            if c.font is None or c.font.name != FONT:
                c.font = Font(name=FONT, size=c.font.size if c.font else 10, bold=c.font.bold if c.font else False,
                              italic=c.font.italic if c.font else False, color=c.font.color if c.font else None)
TAB = {S_TQ: "1F4E78", S_DM: "7F7F7F", S9: "C55A11", M1: "70AD47", M2: "70AD47", M3: "70AD47", M4: "70AD47"}
for sh in wb.worksheets:
    sh.sheet_properties.tabColor = TAB.get(sh.title, "2E75B6")
wb.active = 0
wb.save(OUT)
print(f"Đã ghi {OUT}: {len(EV)} sự kiện, {len(TT)} mã TT, {len(CH)} kênh")
