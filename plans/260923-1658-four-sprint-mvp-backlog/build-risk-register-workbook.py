"""Sinh file Excel Kế hoạch quản lý rủi ro cho MVP Khách Sạn Di Động.

Nguồn dữ liệu: Project Charter (docs/project-charter.md v1.1), từ điển WBS
(wbs-baseline-review-and-dictionary.md) và danh sách 26 rủi ro nhóm đã duyệt ngày 20/10/2026.
Mẫu bảng theo slide Quản lý dự án CNTT: nhận diện (slide 28), xếp hạng từng tháng (slide 21),
chiến lược đối phó (slide 30).

Chạy: python build-risk-register-workbook.py [đường_dẫn_output.xlsx]
"""
import sys
from datetime import date

from openpyxl import Workbook
from openpyxl.formatting.rule import CellIsRule, FormulaRule
from openpyxl.styles import Alignment, Border, Font, PatternFill, Side
from openpyxl.utils import get_column_letter
from openpyxl.worksheet.datavalidation import DataValidation

sys.stdout.reconfigure(encoding="utf-8")
OUT = sys.argv[1] if len(sys.argv) > 1 else "ke-hoach-quan-ly-rui-ro.xlsx"
PLAN_DATE = date(2026, 10, 20)  # ngày lập sổ rủi ro v1.0

# ---------------------------------------------------------------- styles
FONT = "Arial"
F_BASE = Font(name=FONT, size=10)
F_BOLD = Font(name=FONT, size=10, bold=True)
F_HEAD = Font(name=FONT, size=10, bold=True, color="FFFFFF")
F_TITLE = Font(name=FONT, size=16, bold=True, color="1F4E78")
F_SUB = Font(name=FONT, size=12, bold=True, color="1F4E78")
F_NOTE = Font(name=FONT, size=9, italic=True, color="595959")
F_INPUT = Font(name=FONT, size=10, color="0000FF")
F_XREF = Font(name=FONT, size=10, color="008000")
FILL_HEAD = PatternFill("solid", fgColor="1F4E78")
FILL_INPUT = PatternFill("solid", fgColor="FFF2CC")
FILL_FORMULA = PatternFill("solid", fgColor="EDEDED")
FILL_SECTION = PatternFill("solid", fgColor="DDEBF7")
THIN = Side(style="thin", color="BFBFBF")
BORDER = Border(left=THIN, right=THIN, top=THIN, bottom=THIN)
WRAP = Alignment(wrap_text=True, vertical="top")
CENTER = Alignment(horizontal="center", vertical="center", wrap_text=True)
RED = PatternFill("solid", fgColor="F8CBAD")
ORANGE = PatternFill("solid", fgColor="FFE699")
GREEN = PatternFill("solid", fgColor="C6EFCE")

# ---------------------------------------------------------------- sheet names
S_TD, S1, S2 = "Thang đo", "1. Nhận diện", "2. Đánh giá"
S3, S4, S5, S6 = "3. Xếp hạng tháng", "4. Đối phó", "5. Ma trận", "6. Tổng hợp"

CATEGORIES = {
    "A": "Yêu cầu và phạm vi", "B": "Kỹ thuật", "C": "Bên ngoài", "D": "Nhân sự",
    "E": "Giao tiếp và phối hợp", "F": "Chất lượng", "G": "Bảo mật và dữ liệu", "H": "Tiến độ và chi phí",
}
OWNERS = ["Tấn Đạt", "Ngọc Hoàng", "Bảo"]
STRATEGIES = ["Tránh né", "Chuyển giao", "Giảm nhẹ", "Chấp nhận"]
STATUSES = ["Mở", "Đang xử lý", "Đang xảy ra", "Đã đóng"]

# ---------------------------------------------------------------- dữ liệu rủi ro
# Mỗi rủi ro: mã, nhóm, WBS, nguyên nhân, sự kiện, hậu quả, người chịu trách nhiệm, phạm vi W/B/S,
# ngày ảnh hưởng, P, I, mức nghiêm trọng T9/T10/T11, tiến hành giải quyết,
# chiến lược, biện pháp (nhánh slide 30), hành động, người thực hiện, hạn, dấu hiệu kích hoạt,
# kế hoạch dự phòng, trạng thái.
R = [
    ("R01", "D", "1.4, 1.5", "WBS phân 222h cho Ngọc Hoàng trong khi mức tham chiếu là 160h (dư 62h)",
     "Ngọc Hoàng không kịp hoàn thành backend và mobile đúng cổng sprint",
     "Trễ cổng Sprint 2–3, phát sinh tăng ca", "Tấn Đạt", "W", date(2026, 10, 9), 4, 4, 16, 12, 4,
     "Chuyển bớt task Flutter cho Bảo và Đạt; theo dõi giờ công hằng tuần",
     "Chuyển giao", "Chia sẻ rủi ro",
     "Chuyển task giao diện Flutter sang Bảo, Đạt nhận một phần API; báo GV phần quá tải 62h",
     "Tấn Đạt", date(2026, 9, 25), "Giờ công tuần của Hoàng vượt 30h hoặc task trễ quá 2 ngày",
     "Dùng phụ cấp tăng ca; dời các hạng mục P1 ra sau nghiệm thu", "Đang xử lý"),
    ("R02", "D", "1.1, 1.9", "Tấn Đạt kiêm 5 vai trò PO, BA, PM, Tech Lead, DevOps",
     "Quyết định phạm vi và việc deploy dồn chờ một người",
     "Chậm tiến độ; dự án đứng khi Đạt vắng", "Tấn Đạt", "W", date(2026, 10, 15), 3, 4, 12, 12, 8,
     "Lập ma trận RACI; cử Hoàng dự phòng DevOps, viết runbook trước Sprint 4",
     "Giảm nhẹ", "Giảm thiểu ảnh hưởng – Nhân lực dự phòng",
     "Lập RACI; Hoàng làm người dự phòng DevOps; viết runbook deploy/rollback",
     "Tấn Đạt", date(2026, 10, 15), "Có hơn 3 việc chờ Đạt duyệt quá 1 ngày",
     "Hoàng tạm thay việc deploy theo runbook", "Đang xử lý"),
    ("R03", "B", "1.4, 1.8", "Chưa có công cụ tạo tải 30 phiên; task 165 chưa cập nhật lên 30 phiên",
     "Tỷ lệ cập nhật hiển thị ≤3 giây dưới 95% trong 100 lượt",
     "Không đạt North Star (OBJ-2), trượt tiêu chí nghiệm thu chính", "Ngọc Hoàng", "B",
     date(2026, 10, 25), 3, 5, 10, 15, 15,
     "Cập nhật task 165 lên 30 phiên; chạy thử tải sớm, chưa đạt thì tối ưu ngay",
     "Giảm nhẹ", "Giảm thiểu khả năng – Loại bỏ yếu tố gây rủi ro",
     "Viết script tải bằng socket.io-client 30 phiên; đo 100 lượt; tối ưu phát sự kiện theo phòng",
     "Ngọc Hoàng", date(2026, 10, 23), "Một lần đo cho kết quả dưới 95%",
     "Giảm payload sự kiện; dùng 5 ngày dự phòng 27/10–02/11 để tối ưu", "Mở"),
    ("R04", "C", "1.7", "Phụ thuộc dịch vụ OpenAI bên ngoài",
     "API trả chậm quá 15 giây, đầu ra sai cấu trúc hoặc chi phí vượt trần 300.000đ",
     "Tóm tắt AI không hiển thị được, không đạt OBJ-4", "Ngọc Hoàng", "B", date(2026, 10, 16), 3, 3, 6, 9, 9,
     "Dùng fallback báo cáo mẫu; timeout 15 giây; kiểm payload; chạy bộ 20 tình huống",
     "Chấp nhận", "Kế hoạch khắc phục tác hại",
     "Cài fallback báo cáo mẫu, timeout 15 giây, schema đầu ra có cấu trúc, đếm chi phí theo lượt gọi",
     "Ngọc Hoàng", date(2026, 10, 16), "Lỗi hoặc timeout từ 3/20 lượt thử trở lên",
     "Hiển thị báo cáo mẫu, ghi chú cho GV về giới hạn", "Mở"),
    ("R05", "B", "1.9", "VPS chỉ thuê trong Sprint 4; deploy và build APK làm sát hạn",
     "Triển khai web HTTPS hoặc APK bị lỗi, trễ trước ngày 27/10",
     "Không có bản demo để bàn giao (OBJ-5)", "Tấn Đạt", "B", date(2026, 10, 27), 3, 5, 6, 15, 10,
     "Thuê VPS sớm; diễn tập deploy và rollback trước 25/10; cài thử APK trên máy thật",
     "Giảm nhẹ", "Giảm thiểu ảnh hưởng – Thời gian dự phòng",
     "Diễn tập deploy, rollback và cài APK trên Android thật trước UAT",
     "Tấn Đạt", date(2026, 10, 24), "Lần deploy thử thất bại hoặc APK không cài được",
     "Chạy bản demo trên máy nhóm trong mạng LAN, APK trỏ về máy đó", "Mở"),
    ("R06", "A", "1.9", "Phát sinh yêu cầu nâng cấp UI/UX sau mốc đóng băng 15/10 (plan mở 17/10)",
     "Nhận thêm việc ngoài phạm vi sau khi đóng băng",
     "Không đủ thời gian sửa lỗi và UAT", "Tấn Đạt", "W", date(2026, 10, 20), 3, 3, 4, 9, 4,
     "Giữ đóng băng 15/10; thay đổi mới phải qua PO duyệt, xếp vào P1 hoặc sau nghiệm thu",
     "Tránh né", "Chọn hướng khác",
     "Mọi thay đổi sau 15/10 phải qua PO duyệt; phần không bắt buộc dời sau nghiệm thu",
     "Tấn Đạt", date(2026, 10, 21), "Có PR thêm tính năng mới sau 15/10",
     "Revert các PR ngoài phạm vi trước UAT", "Đang xảy ra"),
    ("R07", "F", "1.8", "Bảo vừa làm frontend vừa làm QA, thiếu người kiểm thử độc lập",
     "Còn lỗi chặn luồng hoặc lỗi nghiêm trọng trước UAT 25–26/10",
     "Không đạt OBJ-6 (0 lỗi nghiêm trọng còn mở)", "Bảo", "B", date(2026, 10, 25), 3, 4, 6, 12, 12,
     "Hoàng kiểm thử chéo FE; triage lỗi hằng ngày; ưu tiên lỗi blocker và critical",
     "Giảm nhẹ", "Giảm thiểu khả năng – Loại bỏ yếu tố gây rủi ro",
     "Hoàng kiểm thử chéo; họp triage lỗi 15 phút mỗi ngày",
     "Bảo", date(2026, 10, 24), "Ngày 24/10 vẫn còn lỗi blocker mở",
     "Ẩn tính năng lỗi không bắt buộc; dùng thời gian dự phòng", "Mở"),
    ("R08", "B", "1.4", "Nhiều người cùng sửa một phòng; mạng chập chờn",
     "Ghi đè do xung đột hoặc mất đồng bộ trạng thái",
     "Trạng thái phòng sai, vi phạm guardrail 0% ghi đè", "Ngọc Hoàng", "S", date(2026, 10, 16), 2, 5, 15, 10, 5,
     "Dùng version (optimistic lock); khóa ghi khi offline; viết test xung đột",
     "Giảm nhẹ", "Giảm thiểu khả năng – Loại bỏ yếu tố gây rủi ro",
     "Kiểm version ở mọi API ghi; khóa nút ghi khi mất kết nối; test xung đột tự động",
     "Ngọc Hoàng", date(2026, 10, 16), "Test xung đột thất bại",
     "Trả 409 và buộc client tải lại trạng thái mới", "Đang xử lý"),
    ("R09", "H", "1.0", "Phần quá tải 62h của Hoàng có thể phải trả theo đơn giá tăng ca",
     "Chi phí tăng ca phát sinh 2.914.000đ (61% quỹ dự phòng)",
     "Vượt ngân sách 30.000.000đ (OBJ-7)", "Tấn Đạt", "W", date(2026, 11, 2), 2, 3, 4, 6, 6,
     "Theo dõi chi so với dự phòng 4.780.000đ; hạn chế tăng ca có trả phí",
     "Chấp nhận", "Chờ và xem",
     "Theo dõi chi tiêu hằng tuần so với quỹ dự phòng",
     "Tấn Đạt", date(2026, 11, 2), "Chi đã dùng vượt 50% quỹ dự phòng",
     "Dùng quỹ dự phòng 4.780.000đ", "Mở"),
    ("R10", "D", "1.0", "Lịch học, thi và sức khỏe của thành viên (giả định A-1)",
     "Một thành viên vắng dài ngày, hụt năng lực",
     "Trễ tiến độ, phải cắt phạm vi", "Tấn Đạt", "W", date(2026, 11, 2), 2, 4, 8, 8, 8,
     "Chia sẻ kiến thức qua docs; dùng 5 ngày dự phòng 27/10–02/11",
     "Chấp nhận", "Kế hoạch khắc phục tác hại",
     "Ghi tài liệu cách chạy và kiến trúc để người khác tiếp nhận được",
     "Tấn Đạt", date(2026, 10, 15), "Thành viên vắng quá 2 ngày làm việc",
     "Phân lại task theo RACI", "Mở"),
    ("R11", "A", "1.1, 1.2", "Spec dài (BRD/PRD/URD/SRS) và nhiều decision D-01 → D-17",
     "Code làm lệch spec BRD/SRS",
     "Phải làm lại; trượt kịch bản nghiệm thu", "Tấn Đạt", "B", date(2026, 10, 9), 3, 4, 12, 9, 6,
     "Đối chiếu spec khi review PR; dùng checklist tiêu chí chấp nhận",
     "Giảm nhẹ", "Giảm thiểu khả năng – Huấn luyện phòng tránh",
     "Thêm mục đối chiếu spec vào mẫu PR; checklist tiêu chí chấp nhận cho từng feature",
     "Tấn Đạt", date(2026, 9, 28), "Review phát hiện code lệch spec",
     "Cập nhật decision log hoặc sửa code theo spec", "Đang xử lý"),
    ("R12", "A", "1.1", "Dữ liệu và kịch bản là giả lập (giả định A-4)",
     "Kịch bản không sát vận hành khách sạn thật",
     "Demo chạy được nhưng nghiệp vụ thiếu thực tế", "Tấn Đạt", "B", date(2026, 11, 2), 2, 3, 6, 6, 6,
     "Tham khảo quy trình khách sạn thật; ghi rõ giới hạn trong hồ sơ",
     "Chấp nhận", "Thu thập/mua thông tin",
     "Tham khảo quy trình của một khách sạn thật hoặc phỏng vấn một lễ tân",
     "Tấn Đạt", date(2026, 10, 24), "GV nhận xét nghiệp vụ chưa thực tế",
     "Ghi giới hạn vào hồ sơ bàn giao", "Mở"),
    ("R13", "A", "1.1", "Charter còn ở trạng thái chờ GV ký duyệt",
     "Sponsor đổi hoặc bổ sung tiêu chí nghiệm thu sát ngày 02/11",
     "Làm thêm việc gấp, có thể trượt nghiệm thu", "Tấn Đạt", "W", date(2026, 11, 2), 2, 4, 4, 6, 8,
     "Xin GV ký charter và tiêu chí; báo cáo tiến độ hằng tuần",
     "Chuyển giao", "Báo cáo lãnh đạo",
     "Gửi GV duyệt charter và tiêu chí nghiệm thu; báo cáo tiến độ mỗi tuần",
     "Tấn Đạt", date(2026, 10, 23), "GV đưa ra yêu cầu mới",
     "Thương lượng đưa yêu cầu mới vào P1", "Mở"),
    ("R14", "B", "1.8", "Flutter Web và Android dùng plugin, socket và layout khác nhau",
     "Tính năng chạy đúng trên một nền tảng nhưng lỗi trên nền tảng kia",
     "Trượt kịch bản bắt buộc trên Web hoặc Android (OBJ-1)", "Bảo", "B", date(2026, 10, 25), 3, 3, 6, 9, 6,
     "Test cả 2 nền tảng ở mỗi PR; lập ma trận tương thích",
     "Giảm nhẹ", "Giảm thiểu khả năng – Loại bỏ yếu tố gây rủi ro",
     "Chạy luồng chính trên Web và Android trước khi merge PR",
     "Bảo", date(2026, 10, 24), "Lỗi chỉ xuất hiện trên một nền tảng",
     "Xử lý riêng theo nền tảng (kIsWeb)", "Mở"),
    ("R15", "B", "1.3, 1.9", "Đổi schema Prisma nhiều lần; migrate lên VPS lần đầu",
     "Migration lỗi trên VPS",
     "Mất hoặc hỏng dữ liệu demo, demo không chạy", "Ngọc Hoàng", "S", date(2026, 10, 27), 2, 5, 4, 10, 5,
     "Backup DB trước khi migrate; diễn tập trên bản sao; có seed reset",
     "Giảm nhẹ", "Giảm thiểu ảnh hưởng – Kế hoạch cứu chữa",
     "Backup DB trước mỗi lần migrate; diễn tập migrate trên bản sao",
     "Ngọc Hoàng", date(2026, 10, 24), "Lệnh migrate báo lỗi",
     "Khôi phục backup và chạy lại seed 50 phòng", "Mở"),
    ("R16", "B", "1.5", "Nhiều việc dọn hoặc sửa được tạo cùng lúc",
     "Tự phân công sai do race condition (giao trùng, lệch tải)",
     "Việc bị bỏ sót hoặc làm trùng; sai quy tắc D-09, D-15", "Ngọc Hoàng", "S", date(2026, 10, 9), 2, 4, 8, 8, 4,
     "Dùng transaction và khóa khi chọn người; test đồng thời",
     "Giảm nhẹ", "Giảm thiểu khả năng – Loại bỏ yếu tố gây rủi ro",
     "Bọc bước chọn người trong transaction có khóa; viết test tạo việc đồng thời",
     "Ngọc Hoàng", date(2026, 10, 9), "Một việc bị gán cho 2 người",
     "Quản lý xử lý việc qua hàng chờ", "Đang xử lý"),
    ("R17", "C", "1.9", "Phụ thuộc nhà cung cấp VPS, domain và SSL",
     "VPS, DNS hoặc chứng chỉ SSL gặp sự cố hoặc cấp chậm",
     "Web không chạy HTTPS đúng hạn", "Tấn Đạt", "B", date(2026, 10, 24), 2, 4, 2, 8, 6,
     "Mua domain và VPS sớm ít nhất 1 tuần; dùng Let's Encrypt",
     "Giảm nhẹ", "Giảm thiểu ảnh hưởng – Kế hoạch cứu chữa",
     "Mua domain và VPS sớm; cấu hình Let's Encrypt; chọn sẵn nhà cung cấp dự phòng",
     "Tấn Đạt", date(2026, 10, 20), "DNS hoặc SSL chưa chạy sau 48 giờ",
     "Chuyển sang nhà cung cấp dự phòng", "Mở"),
    ("R18", "C", "1.9", "Thư viện và Flutter SDK cập nhật liên tục; CI dùng phút miễn phí",
     "Build vỡ do dependency hoặc CI hết phút chạy",
     "CI đỏ, không bàn giao được bản build", "Tấn Đạt", "B", date(2026, 10, 27), 2, 3, 4, 6, 4,
     "Khóa phiên bản SDK và lockfile; không nâng cấp sau đóng băng",
     "Tránh né", "Chọn hướng khác",
     "Khóa phiên bản Flutter, lockfile npm/pub; cấm nâng cấp dependency sau 15/10",
     "Tấn Đạt", date(2026, 10, 15), "CI đỏ do dependency",
     "Rollback phiên bản dependency; build thủ công", "Đang xử lý"),
    ("R19", "E", "1.0", "Ba thành viên làm song song trên 3 nhánh develop-*",
     "Xung đột merge, PR chờ review lâu",
     "Mất thời gian gỡ conflict, chậm tích hợp", "Tấn Đạt", "W", date(2026, 10, 20), 3, 3, 9, 9, 3,
     "Pull develop thường xuyên; PR nhỏ; review trong 24 giờ",
     "Giảm nhẹ", "Giảm thiểu khả năng – Huấn luyện phòng tránh",
     "Quy định pull develop hằng ngày, PR nhỏ, review trong 24 giờ",
     "Tấn Đạt", date(2026, 9, 15), "Xảy ra conflict quá 1 lần mỗi tuần",
     "Họp merge chung để gỡ conflict", "Đang xử lý"),
    ("R20", "E", "1.1", "Quyết định chốt qua chat, không cập nhật decision log",
     "Thành viên làm theo thông tin cũ",
     "Làm lại, lệch giữa các phần", "Tấn Đạt", "W", date(2026, 10, 9), 2, 3, 6, 6, 3,
     "Cập nhật decision log sau mỗi buổi họp; thông báo trên kênh nhóm",
     "Giảm nhẹ", "Giảm thiểu khả năng – Huấn luyện phòng tránh",
     "Ghi decision log ngay sau họp và đăng lên kênh báo cáo",
     "Tấn Đạt", date(2026, 9, 15), "Phát hiện task làm theo quyết định cũ",
     "Rà soát lại các task liên quan", "Đang xử lý"),
    ("R21", "F", "1.8", "Đợt nâng cấp UI/UX sửa nhiều màn hình; test chưa phủ hết",
     "Lỗi hồi quy ở các luồng đã chạy ổn",
     "Lỗi xuất hiện trong UAT, phải sửa gấp", "Bảo", "B", date(2026, 10, 25), 3, 4, 3, 12, 8,
     "Chạy flutter test và checklist regression sau mỗi đợt sửa giao diện",
     "Giảm nhẹ", "Giảm thiểu khả năng – Loại bỏ yếu tố gây rủi ro",
     "Chạy flutter test và checklist regression các luồng chính trước khi merge",
     "Bảo", date(2026, 10, 24), "Phát hiện regression trong UAT",
     "Revert phần giao diện gây lỗi", "Mở"),
    ("R22", "F", "1.2", "Nhân viên hiện trường ít thao tác trên điện thoại (giả định A-5)",
     "Giao diện mobile khó dùng nên nhân viên không tự cập nhật",
     "Mất giá trị cốt lõi của sản phẩm", "Bảo", "B", date(2026, 10, 25), 2, 3, 6, 6, 6,
     "Thử khả năng sử dụng với 3 người; nút lớn, ít bước",
     "Giảm nhẹ", "Giảm thiểu khả năng – Loại bỏ yếu tố gây rủi ro",
     "Thử khả năng sử dụng với 3 người ngoài nhóm; giảm số bước cho thao tác chính",
     "Bảo", date(2026, 10, 23), "Người thử bị vướng ở một bước trở lên",
     "Đơn giản hóa màn hình đó", "Mở"),
    ("R23", "G", "1.3", "Kiểm quyền chỉ ở app (ẩn nút) mà server không chặn",
     "Người dùng gọi API vượt quyền thành công",
     "Vi phạm C-7, trượt tiêu chí 0 hành động vượt quyền", "Ngọc Hoàng", "B", date(2026, 9, 28), 2, 5, 10, 10, 5,
     "Middleware RBAC cho mọi route ghi; test trả 403",
     "Giảm nhẹ", "Giảm thiểu khả năng – Loại bỏ yếu tố gây rủi ro",
     "Gắn middleware RBAC cho mọi route ghi; viết test vượt quyền phải trả 403",
     "Ngọc Hoàng", date(2026, 9, 28), "Test vượt quyền không trả 403",
     "Vá ngay, chặn release cho tới khi sửa xong", "Đang xử lý"),
    ("R24", "G", "1.9", "File .env và API key OpenAI nằm trên máy dev",
     "Bí mật bị commit lên GitHub",
     "Lộ key, bị dùng trộm chi phí API", "Tấn Đạt", "W", date(2026, 10, 27), 2, 5, 10, 10, 5,
     ".gitignore cho .env; quét secret; key chỉ đặt trong env trên VPS",
     "Tránh né", "Chọn hướng khác",
     "Thêm .env vào .gitignore; bật secret scanning; key chỉ cấu hình trên VPS",
     "Tấn Đạt", date(2026, 9, 15), "Phát hiện key trong repo",
     "Thu hồi và tạo key mới ngay", "Đang xử lý"),
    ("R25", "G", "1.5, 1.7", "Audit log và payload AI lấy dữ liệu từ nhiều bảng",
     "PII hoặc mật khẩu lọt vào audit log hay payload gửi AI",
     "Vi phạm quy tắc không ghi mật khẩu và 0 payload PII (OBJ-4)", "Ngọc Hoàng", "S",
     date(2026, 10, 16), 2, 4, 8, 8, 4,
     "Lọc trường nhạy cảm; test payload không có PII",
     "Giảm nhẹ", "Giảm thiểu khả năng – Loại bỏ yếu tố gây rủi ro",
     "Lọc trường mật khẩu và thông tin khách trước khi ghi log hoặc gửi AI; viết test kiểm payload",
     "Ngọc Hoàng", date(2026, 10, 16), "Thấy PII hoặc mật khẩu trong log",
     "Xóa bản ghi vi phạm và vá ngay", "Đang xử lý"),
    ("R26", "H", "1.6, 1.7", "Dashboard và AI dồn vào cuối Sprint 3",
     "Trễ cổng Sprint 3 (16/10)",
     "Lấn sang thời gian UAT và dự phòng", "Tấn Đạt", "W", date(2026, 10, 16), 3, 4, 8, 12, 4,
     "Theo dõi burn-down; ưu tiên các feature Must",
     "Giảm nhẹ", "Giảm thiểu ảnh hưởng – Thời gian dự phòng",
     "Theo dõi burn-down hằng tuần; tập trung feature Must trước",
     "Tấn Đạt", date(2026, 10, 16), "Cổng Sprint 3 chưa pass vào 16/10",
     "Dùng 5 ngày dự phòng; cắt phần không phải Must", "Mở"),
]
N = len(R)
FIRST = 5            # dòng dữ liệu đầu tiên của các sheet bảng
LAST = FIRST + N - 1


# ---------------------------------------------------------------- helpers
def title(ws, text, note):
    ws["A1"] = text
    ws["A1"].font = F_TITLE
    ws["A2"] = note
    ws["A2"].font = F_NOTE


def header(ws, row, cols):
    for i, (name, width) in enumerate(cols, 1):
        c = ws.cell(row=row, column=i, value=name)
        c.font, c.fill, c.alignment, c.border = F_HEAD, FILL_HEAD, CENTER, BORDER
        ws.column_dimensions[get_column_letter(i)].width = width
    ws.row_dimensions[row].height = 32
    ws.freeze_panes = ws.cell(row=row + 1, column=3)


def put(ws, row, col, value, font=F_BASE, fill=None, align=WRAP, fmt=None):
    c = ws.cell(row=row, column=col, value=value)
    c.font, c.alignment, c.border = font, align, BORDER
    if fill:
        c.fill = fill
    if fmt:
        c.number_format = fmt
    return c


def ref(sheet, cell):
    return f"='{sheet}'!{cell}"


def level_rules(ws, rng):
    ws.conditional_formatting.add(rng, CellIsRule(operator="equal", formula=['"Cao"'], fill=RED))
    ws.conditional_formatting.add(rng, CellIsRule(operator="equal", formula=['"Trung bình"'], fill=ORANGE))
    ws.conditional_formatting.add(rng, CellIsRule(operator="equal", formula=['"Thấp"'], fill=GREEN))


def score_rules(ws, rng):
    top = rng.split(":")[0]
    ws.conditional_formatting.add(rng, FormulaRule(formula=[f"{top}>=15"], fill=RED))
    ws.conditional_formatting.add(rng, FormulaRule(formula=[f"AND({top}>=8,{top}<15)"], fill=ORANGE))
    ws.conditional_formatting.add(rng, FormulaRule(formula=[f"AND({top}>0,{top}<8)"], fill=GREEN))


def add_list(ws, values, rng):
    dv = DataValidation(type="list", formula1='"' + ",".join(values) + '"', allow_blank=True)
    ws.add_data_validation(dv)
    dv.add(rng)


wb = Workbook()

# ---------------------------------------------------------------- Thang đo
ws = wb.active
ws.title = S_TD
title(ws, "KẾ HOẠCH QUẢN LÝ RỦI RO — MVP KHÁCH SẠN DI ĐỘNG",
      f"WPCTeam · lập ngày {PLAN_DATE:%d/%m/%Y} · nguồn: Project Charter v1.1, từ điển WBS, danh sách rủi ro nhóm đã duyệt")
ws.column_dimensions["A"].width = 22
ws.column_dimensions["B"].width = 16
ws.column_dimensions["C"].width = 70
rows = [
    ("Xác suất (P)", None, None),
    ("", 1, "Rất thấp — dưới 10%"), ("", 2, "Thấp — 10–30%"), ("", 3, "Trung bình — 30–50%"),
    ("", 4, "Cao — 50–70%"), ("", 5, "Rất cao — trên 70%"),
    ("Ảnh hưởng (I)", None, None),
    ("", 1, "Không đáng kể — trễ dưới 1 ngày, không chạm tiêu chí nghiệm thu"),
    ("", 2, "Nhỏ — trễ 1–2 ngày một task, xử lý trong sprint"),
    ("", 3, "Trung bình — trễ một gói WBS hoặc tốn dưới 25% quỹ dự phòng"),
    ("", 4, "Lớn — trễ cổng sprint hoặc trượt một tiêu chí nghiệm thu phụ"),
    ("", 5, "Nghiêm trọng — trượt North Star, mất bản demo hoặc trượt nghiệm thu 02/11"),
    ("Mức nghiêm trọng", None, "Bằng P × I (thang 1–25)"),
    ("", "Cao", "≥ 15 — xử lý ngay, báo cáo GV"),
    ("", "Trung bình", "8–14 — có biện pháp và người theo dõi"),
    ("", "Thấp", "< 8 — theo dõi định kỳ"),
    ("Phạm vi ảnh hưởng", None, None),
    ("", "W", "Toàn dự án (Whole) — ảnh hưởng nhiều gói WBS"),
    ("", "B", "Một nhánh/gói WBS (Branch)"),
    ("", "S", "Một công việc đơn lẻ (Single task)"),
    ("Xếp hạng", None, "1 = nghiêm trọng nhất; cùng điểm thì xếp theo thứ tự mã rủi ro"),
    ("Chiến lược đối phó", None, None),
    ("", "Tránh né", "Chọn hướng đi khác, thay đổi mục tiêu"),
    ("", "Chuyển giao", "Chia sẻ rủi ro, báo cáo lãnh đạo, mua bảo hiểm"),
    ("", "Giảm nhẹ", "Giảm ảnh hưởng (kế hoạch cứu chữa: nhân lực/thời gian dự phòng, thay người, công cụ mới) "
                     "hoặc giảm khả năng (loại bỏ yếu tố gây rủi ro, huấn luyện phòng tránh)"),
    ("", "Chấp nhận", "Chờ và xem, thu thập thông tin, kế hoạch khắc phục tác hại"),
    ("Cách dùng file", None, None),
    ("", "Ô nền vàng", "Ô nhập liệu (chữ xanh dương): P, I, mức theo tháng, trạng thái... sửa trực tiếp"),
    ("", "Ô nền xám", "Ô công thức (chữ đen) — tự tính, không sửa"),
    ("", "Chữ xanh lá", "Liên kết sang sheet khác"),
]
r = 4
for a, b, c in rows:
    if a:
        put(ws, r, 1, a, F_BOLD, FILL_SECTION)
        put(ws, r, 2, b, F_BOLD, FILL_SECTION, CENTER)
        put(ws, r, 3, c, F_BOLD, FILL_SECTION)
    else:
        put(ws, r, 1, "")
        put(ws, r, 2, b, F_BOLD, None, CENTER)
        put(ws, r, 3, c)
    r += 1
ws.cell(row=r + 1, column=1, value="Ghi chú: định nghĩa W/B/S là cách nhóm hiểu; điểm P, I và mức theo tháng là "
        "đánh giá định tính của nhóm ngày 20/10/2026.").font = F_NOTE

# ---------------------------------------------------------------- 1. Nhận diện (slide 28, bảng 1)
ws = wb.create_sheet(S1)
title(ws, "1. NHẬN DIỆN RỦI RO", "Mẫu slide 28: Mã rủi ro · Số hiệu WBS · Sự kiện rủi ro · Người chịu trách nhiệm · "
      "Phạm vi ảnh hưởng (W/B/S). Bổ sung nguyên nhân và hậu quả để rõ chuỗi rủi ro.")
header(ws, 4, [("Mã rủi ro", 9), ("Nhóm rủi ro", 20), ("Số hiệu trong WBS", 12), ("Nguyên nhân", 38),
               ("Sự kiện rủi ro", 42), ("Hậu quả", 36), ("Người chịu trách nhiệm", 15),
               ("Phạm vi ảnh hưởng (W/B/S)", 12)])
for i, x in enumerate(R):
    row = FIRST + i
    put(ws, row, 1, x[0], F_BOLD, None, CENTER)
    put(ws, row, 2, f"{x[1]}. {CATEGORIES[x[1]]}")
    put(ws, row, 3, x[2], align=CENTER)
    put(ws, row, 4, x[3])
    put(ws, row, 5, x[4], F_BOLD)
    put(ws, row, 6, x[5])
    put(ws, row, 7, x[6], F_INPUT, FILL_INPUT, CENTER)
    put(ws, row, 8, x[7], F_INPUT, FILL_INPUT, CENTER)
add_list(ws, OWNERS, f"G{FIRST}:G{LAST}")
add_list(ws, ["W", "B", "S"], f"H{FIRST}:H{LAST}")
ws.auto_filter.ref = f"A4:H{LAST}"

# ---------------------------------------------------------------- 2. Đánh giá (slide 28, bảng 2)
ws = wb.create_sheet(S2)
title(ws, "2. ĐÁNH GIÁ RỦI RO", "Mẫu slide 28: Ngày ảnh hưởng dự kiến · Xác suất · Ảnh hưởng · Mức độ nghiêm trọng · "
      "Xếp hạng. Mức = P × I; xếp hạng tự tính.")
header(ws, 4, [("Mã rủi ro", 9), ("Sự kiện rủi ro", 46), ("Ngày ảnh hưởng dự kiến", 13),
               ("Xác suất xuất hiện (P 1–5)", 12), ("Ảnh hưởng của rủi ro (I 1–5)", 12),
               ("Mức độ nghiêm trọng (P×I)", 12), ("Phân loại", 12), ("Xếp hạng", 10)])
for i, x in enumerate(R):
    row = FIRST + i
    put(ws, row, 1, ref(S1, f"A{row}"), Font(name=FONT, size=10, bold=True, color="008000"), None, CENTER)
    put(ws, row, 2, ref(S1, f"E{row}"), F_XREF)
    put(ws, row, 3, x[8], F_INPUT, FILL_INPUT, CENTER, "dd/mm/yyyy")
    put(ws, row, 4, x[9], F_INPUT, FILL_INPUT, CENTER)
    put(ws, row, 5, x[10], F_INPUT, FILL_INPUT, CENTER)
    put(ws, row, 6, f"=D{row}*E{row}", F_BOLD, FILL_FORMULA, CENTER)
    put(ws, row, 7, f'=IF(F{row}>=15,"Cao",IF(F{row}>=8,"Trung bình","Thấp"))', F_BASE, FILL_FORMULA, CENTER)
    put(ws, row, 8, f"=RANK(F{row},$F${FIRST}:$F${LAST},0)+COUNTIF($F${FIRST}:F{row},F{row})-1",
        F_BOLD, FILL_FORMULA, CENTER)
pi = DataValidation(type="whole", operator="between", formula1="1", formula2="5")
ws.add_data_validation(pi)
pi.add(f"D{FIRST}:E{LAST}")
level_rules(ws, f"G{FIRST}:G{LAST}")
score_rules(ws, f"F{FIRST}:F{LAST}")
ws.auto_filter.ref = f"A4:H{LAST}"

# ---------------------------------------------------------------- 3. Xếp hạng từng tháng (slide 21)
ws = wb.create_sheet(S3)
title(ws, "3. PHÂN TÍCH TÍNH CHẤT RỦI RO (ĐỊNH TÍNH) — XẾP HẠNG TỪNG THÁNG",
      "Mẫu slide 21. Nhập mức nghiêm trọng ước tính của từng tháng (1–25); hạng tự tính. "
      "T9: 08–30/09 · T10: 01–31/10 · T11: 01–02/11/2026.")
header(ws, 4, [("Mã rủi ro", 9), ("Mục rủi ro", 44), ("Mức T9", 9), ("Mức T10", 9), ("Mức T11", 9),
               ("Hạng T9", 9), ("Hạng T10", 9), ("Hạng T11", 9), ("Tiến hành giải quyết rủi ro", 60)])
for i, x in enumerate(R):
    row = FIRST + i
    put(ws, row, 1, ref(S1, f"A{row}"), Font(name=FONT, size=10, bold=True, color="008000"), None, CENTER)
    put(ws, row, 2, ref(S1, f"E{row}"), F_XREF)
    for k in range(3):
        put(ws, row, 3 + k, x[11 + k], F_INPUT, FILL_INPUT, CENTER)
        s = get_column_letter(3 + k)
        put(ws, row, 6 + k, f"=RANK({s}{row},${s}${FIRST}:${s}${LAST},0)+COUNTIF(${s}${FIRST}:{s}{row},{s}{row})-1",
            F_BOLD, FILL_FORMULA, CENTER)
    put(ws, row, 9, x[14])
mv = DataValidation(type="whole", operator="between", formula1="1", formula2="25")
ws.add_data_validation(mv)
mv.add(f"C{FIRST}:E{LAST}")
score_rules(ws, f"C{FIRST}:E{LAST}")
for col in "FGH":
    rng = f"{col}{FIRST}:{col}{LAST}"
    ws.conditional_formatting.add(rng, FormulaRule(formula=[f"{col}{FIRST}<=5"], fill=RED))
ws.cell(row=LAST + 2, column=1, value="Hạng nền đỏ = top 5 của tháng — đưa vào báo cáo tuần gửi GV.").font = F_NOTE
ws.auto_filter.ref = f"A4:I{LAST}"

# ---------------------------------------------------------------- 4. Đối phó (slide 30)
ws = wb.create_sheet(S4)
title(ws, "4. KẾ HOẠCH ĐỐI PHÓ RỦI RO", "Mẫu slide 30: chiến lược Tránh né / Chuyển giao / Giảm nhẹ / Chấp nhận và "
      "nhánh biện pháp tương ứng.")
header(ws, 4, [("Mã rủi ro", 9), ("Sự kiện rủi ro", 36), ("Mức (P×I)", 9), ("Chiến lược", 13),
               ("Biện pháp (theo sơ đồ)", 26), ("Hành động cụ thể", 46), ("Người thực hiện", 13),
               ("Hạn hoàn thành", 12), ("Dấu hiệu kích hoạt", 32), ("Kế hoạch dự phòng", 36), ("Trạng thái", 12)])
for i, x in enumerate(R):
    row = FIRST + i
    put(ws, row, 1, ref(S1, f"A{row}"), Font(name=FONT, size=10, bold=True, color="008000"), None, CENTER)
    put(ws, row, 2, ref(S1, f"E{row}"), F_XREF)
    put(ws, row, 3, ref(S2, f"F{row}"), F_XREF, None, CENTER)
    put(ws, row, 4, x[15], F_INPUT, FILL_INPUT, CENTER)
    put(ws, row, 5, x[16])
    put(ws, row, 6, x[17])
    put(ws, row, 7, x[18], F_INPUT, FILL_INPUT, CENTER)
    put(ws, row, 8, x[19], F_INPUT, FILL_INPUT, CENTER, "dd/mm/yyyy")
    put(ws, row, 9, x[20])
    put(ws, row, 10, x[21])
    put(ws, row, 11, x[22], F_INPUT, FILL_INPUT, CENTER)
add_list(ws, STRATEGIES, f"D{FIRST}:D{LAST}")
add_list(ws, OWNERS, f"G{FIRST}:G{LAST}")
add_list(ws, STATUSES, f"K{FIRST}:K{LAST}")
score_rules(ws, f"C{FIRST}:C{LAST}")
ws.conditional_formatting.add(f"K{FIRST}:K{LAST}", CellIsRule(operator="equal", formula=['"Đang xảy ra"'], fill=RED))
ws.conditional_formatting.add(f"K{FIRST}:K{LAST}", CellIsRule(operator="equal", formula=['"Đã đóng"'], fill=GREEN))
ws.auto_filter.ref = f"A4:K{LAST}"

# ---------------------------------------------------------------- 5. Ma trận P × I
ws = wb.create_sheet(S5)
title(ws, "5. MA TRẬN XÁC SUẤT × ẢNH HƯỞNG", "Số rủi ro trong từng ô, tự đếm từ sheet 2. Đánh giá.")
ws.column_dimensions["A"].width = 22
for col in range(2, 7):
    ws.column_dimensions[get_column_letter(col)].width = 14
put(ws, 4, 1, "Ảnh hưởng ↓ / Xác suất →", F_HEAD, FILL_HEAD, CENTER)
for p in range(1, 6):
    put(ws, 4, 1 + p, p, F_HEAD, FILL_HEAD, CENTER)
d_rng, e_rng = f"'{S2}'!$D${FIRST}:$D${LAST}", f"'{S2}'!$E${FIRST}:$E${LAST}"
for k, imp in enumerate(range(5, 0, -1)):
    row = 5 + k
    put(ws, row, 1, imp, F_HEAD, FILL_HEAD, CENTER)
    ws.row_dimensions[row].height = 30
    for p in range(1, 6):
        fill = RED if p * imp >= 15 else ORANGE if p * imp >= 8 else GREEN
        put(ws, row, 1 + p, f"=COUNTIFS({d_rng},{p},{e_rng},{imp})", F_BOLD, fill, CENTER)
put(ws, 10, 1, "Tổng", F_BOLD, FILL_SECTION, CENTER)
put(ws, 10, 2, "=SUM(B5:F9)", F_BOLD, FILL_FORMULA, CENTER)
ws["A12"] = "Đỏ: Cao (≥15) · Vàng: Trung bình (8–14) · Xanh: Thấp (<8)"
ws["A12"].font = F_NOTE

# ---------------------------------------------------------------- 6. Tổng hợp
ws = wb.create_sheet(S6)
title(ws, "6. TỔNG HỢP", "Tự đếm từ các sheet 1, 2 và 4.")
ws.column_dimensions["A"].width = 28
for col in "BCDE":
    ws.column_dimensions[col].width = 13
cat_rng, own_rng = f"'{S1}'!$B${FIRST}:$B${LAST}", f"'{S1}'!$G${FIRST}:$G${LAST}"
lvl_rng, st_rng = f"'{S2}'!$G${FIRST}:$G${LAST}", f"'{S4}'!$K${FIRST}:$K${LAST}"
str_rng = f"'{S4}'!$D${FIRST}:$D${LAST}"


def block(start, label, items, crit_rng):
    put(ws, start, 1, label, F_HEAD, FILL_HEAD)
    for j, h in enumerate(["Tổng", "Cao", "Trung bình", "Thấp"]):
        put(ws, start, 2 + j, h, F_HEAD, FILL_HEAD, CENTER)
    for k, (name, crit) in enumerate(items):
        row = start + 1 + k
        put(ws, row, 1, name)
        put(ws, row, 2, f'=COUNTIF({crit_rng},"{crit}")', F_BOLD, FILL_FORMULA, CENTER)
        for j, lv in enumerate(["Cao", "Trung bình", "Thấp"]):
            put(ws, row, 3 + j, f'=COUNTIFS({crit_rng},"{crit}",{lvl_rng},"{lv}")', F_BASE, FILL_FORMULA, CENTER)
    end = start + len(items)
    put(ws, end + 1, 1, "Cộng", F_BOLD, FILL_SECTION)
    for j in range(4):
        col = get_column_letter(2 + j)
        put(ws, end + 1, 2 + j, f"=SUM({col}{start + 1}:{col}{end})", F_BOLD, FILL_SECTION, CENTER)
    return end + 3


nxt = block(4, "Theo nhóm rủi ro", [(f"{k}. {v}", f"{k}. {v}") for k, v in CATEGORIES.items()], cat_rng)
nxt = block(nxt, "Theo người chịu trách nhiệm", [(o, o) for o in OWNERS], own_rng)
nxt = block(nxt, "Theo chiến lược đối phó", [(s, s) for s in STRATEGIES], str_rng)
put(ws, nxt, 1, "Theo trạng thái", F_HEAD, FILL_HEAD)
put(ws, nxt, 2, "Số rủi ro", F_HEAD, FILL_HEAD, CENTER)
for k, s in enumerate(STATUSES):
    put(ws, nxt + 1 + k, 1, s)
    put(ws, nxt + 1 + k, 2, f'=COUNTIF({st_rng},"{s}")', F_BOLD, FILL_FORMULA, CENTER)

for sheet in wb.worksheets:
    sheet.sheet_view.zoomScale = 90
    sheet.page_setup.orientation = "landscape"
    sheet.page_setup.fitToWidth = 1
    sheet.page_setup.fitToHeight = 0
    sheet.sheet_properties.pageSetUpPr.fitToPage = True

wb.save(OUT)
print(f"Đã ghi {OUT}: {N} rủi ro, {len(wb.worksheets)} sheet")
