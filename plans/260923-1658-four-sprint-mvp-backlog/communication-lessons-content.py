"""Nội dung 8 bài học chia sẻ của dự án Khách Sạn Di Động (sheet 9 của kế hoạch truyền thông).

Cơ cấu: 4 bài nghiệp vụ khách sạn, 2 bài quản lý dự án, 1 bài làm việc nhóm, 1 bài kỹ thuật.
Mỗi bài dựa trên tài liệu (PRD, BRD) và code trong repo; chỗ cần số liệu thực tế để dạng [ĐIỀN: ...]
và bài đó giữ trạng thái "Đang viết" cho tới khi tác giả điền xong. Tác giả và người duyệt do nhóm chọn.
"""
from datetime import date

COMMON_TAGS = "#KhachSanDiDong #WPCTeam #BaiHocDuAn #QLDACNTT"
CHANNEL = "Slack #bai-hoc-chia-se (bài đầy đủ) + Zalo nhóm lớp (nội dung bài đăng + mục Bài học)"
GROUPS = ["Nghiệp vụ", "Quản lý dự án", "Làm việc nhóm", "Kỹ thuật"]

LESSONS = [
    {
        "id": "BH-01",
        "group": "Quản lý dự án",
        "title": "Phỏng vấn trước, code sau: chốt phạm vi MVP trong tuần đầu",
        "date": date(2026, 10, 15),
        "teaser": "Tuần đầu dự án Khách Sạn Di Động, nhóm chưa viết dòng code nào. Thay vào đó là 4 buổi phỏng vấn theo vai trò, "
                  "một workshop TO-BE và một sổ Open Question. Bài này kể vì sao 4 nhóm người dùng cuối cùng chỉ còn 3 vai trò, "
                  "và vì sao iOS bị gạch khỏi MVP ngay từ đầu.",
        "tags": "#PhongVanNguoiDung #PhamViMVP #BusinessAnalysis",
        "status": "Chờ duyệt",
        "people": "Tác giả: [ĐIỀN] · Duyệt: [ĐIỀN] · Liên quan: Giảng viên, vai trò người dùng giả định · Người đọc: Cả nhóm, Lớp học",
        "docs": "docs/_product/prd.md (mục 2, 3, 5)\ndocs/_shared/project-profile.md\ndocs/features/*/brainstorms/\nWBS mục 1.2.1 (docs/wbs/KhachSanSach.xlsx)",
        "body": """BÀI HỌC 01 – PHỎNG VẤN TRƯỚC, CODE SAU

Bối cảnh
Khách Sạn Di Động là MVP theo dõi trạng thái phòng theo thời gian thực cho một khách sạn giả định 50 phòng. Nhóm WPCTeam có 3 người, 8 tuần và hạn bàn giao 27/10/2026. Ở khách sạn mẫu, trạng thái phòng được cập nhật rời rạc: chỉ lễ tân nhập vào hệ thống tại quầy, còn buồng phòng và bảo trì báo bằng lời hoặc gọi điện.

Vấn đề
Với 8 tuần, sai phạm vi một lần là mất cả sprint. Trước khi chọn kiến trúc, nhóm cần biết chính xác ai dùng hệ thống, họ cần thấy gì và điều gì nằm ngoài MVP.

Cách nhóm làm
Từ 08/09 đến 15/09, nhóm lập danh sách bên liên quan, soạn bộ câu hỏi riêng cho quản lý, lễ tân, nhân viên buồng phòng và nhân viên bảo trì, rồi phỏng vấn từng vai trò. Vì là đồ án, người dùng là vai trò giả định do giảng viên và thành viên nhóm đóng, nhưng mọi câu trả lời vẫn được ghi biên bản như phỏng vấn thật. Sau đó nhóm mô phỏng một ca làm việc AS-IS, gắn từng điểm đau với một tính năng, phân loại MoSCoW và chốt baseline ở workshop TO-BE ngày 15/09.

Ba quyết định quan trọng nhất
1. Gộp buồng phòng và bảo trì thành một vai trò. Hai nhóm thao tác gần giống nhau trên Android (nhận việc, bắt đầu, hoàn tất), tách ra chỉ làm ma trận quyền phình to mà không thêm giá trị.
2. Theo dõi phòng theo 3 trục trạng thái riêng: lưu trú, vệ sinh, bảo trì (bài 02 sẽ kể chi tiết).
3. Ghi rõ non-goal: iOS, đặt phòng trước, thanh toán, giá phòng nằm ngoài MVP. Nghiệm thu trên Flutter Web và Android.

Sổ Open Question
Câu nào chưa trả lời được thì vào sổ Open Question, kèm người chốt, hạn chốt và tác động nếu chưa chốt. Ví dụ "ai xác nhận phòng đã sạch" được chốt ngày 17/09: chỉ quản lý. "Ghi thông tin gì của khách khi nhận phòng" được chốt ngày 25/09: tên khách và số người. Còn hạn xử lý việc bảo trì hiện vẫn là câu hỏi mở.

Bài học
- Câu hỏi phỏng vấn phải viết riêng theo vai trò; bộ câu hỏi chung chỉ thu được câu trả lời chung chung.
- Ghi non-goal quan trọng ngang ghi yêu cầu. Gạch iOS sớm giúp nhóm không phải tranh luận lại ở sprint 3.
- Dù người dùng là giả định, hãy lưu biên bản và sign-off như thật. Khi có tranh cãi về phạm vi, biên bản là bằng chứng.

Câu hỏi thảo luận
Nhóm bạn có dùng sổ Open Question không? Câu hỏi nào treo lâu nhất trong dự án của bạn?""",
    },
    {
        "id": "BH-02",
        "group": "Nghiệp vụ",
        "title": "Một căn phòng, ba trạng thái: vì sao không dùng một ô \"trạng thái\"",
        "date": date(2026, 10, 22),
        "teaser": "Phòng 305 có khách nhưng điều hòa hỏng. Phòng 210 khách vừa trả, chưa dọn. Nếu chỉ có một ô \"trạng thái\", "
                  "hai phòng này sẽ bị ghi sai. Bài này giải thích vì sao nhóm tách trạng thái phòng thành ba trục lưu trú, vệ sinh, "
                  "bảo trì, và định nghĩa thế nào là một phòng \"sẵn sàng\".",
        "tags": "#NghiepVuKhachSan #TrangThaiPhong #HotelOperations",
        "status": "Chờ duyệt",
        "people": "Tác giả: [ĐIỀN] · Duyệt: [ĐIỀN] · Liên quan: Quản lý KS, Lễ tân, NV BP–BT (giả định) · Người đọc: Cả nhóm, Lớp học",
        "docs": "docs/_product/prd.md (mục 2, 4, 7.2, 7.7)\ndocs/features/room-catalog/\ndocs/features/room-dashboard/\ndocs/assets/figma/state-phong-trucluutru.png, state-phong-trucvesinh.png, state-phong-trucbaotri.png",
        "body": """BÀI HỌC 02 – MỘT CĂN PHÒNG, BA TRẠNG THÁI

Bối cảnh
Ở khách sạn mẫu, mỗi bộ phận nắm một mảnh thông tin: lễ tân biết phòng nào có khách, buồng phòng biết phòng nào đã dọn, bảo trì biết phòng nào đang sửa. Câu hỏi đơn giản "phòng này đang thế nào?" lại không ai trả lời chắc chắn.

Vấn đề
Cách quen thuộc là một danh sách trạng thái: trống, có khách, đang dọn, đang sửa. Nhưng các trạng thái này không loại trừ nhau. Phòng có khách vẫn có thể hỏng điều hòa; phòng trống có thể vừa chưa dọn vừa đang sửa vòi sen. Gộp vào một ô thì hoặc mất thông tin, hoặc phải tạo tổ hợp kiểu "có khách – hỏng – chưa dọn" và số trạng thái bùng nổ.

Cách nhóm làm
Tách thành 3 trục độc lập, mỗi trục gắn với bộ phận chịu trách nhiệm:
- Lưu trú: trống / đang ở. Lễ tân đổi khi nhận và trả phòng.
- Vệ sinh: cần dọn / đang dọn / chờ kiểm tra / sạch. Nhân viên buồng phòng cập nhật, quản lý xác nhận.
- Bảo trì: bình thường / ngừng phục vụ. Thay đổi theo việc sửa chữa, hoặc do lễ tân, quản lý đặt khi cần.

"Sẵn sàng" là kết quả, không phải ô nhập tay
Một phòng sẵn sàng đón khách khi đồng thời: trống, sạch và không ngừng phục vụ. Không ai được gõ chữ "sẵn sàng" vào hệ thống; nó được suy ra từ 3 trục. Nhờ vậy, quy tắc nhận phòng chỉ cần kiểm tra đúng 3 điều kiện này.

Mỗi thay đổi ghi rõ trục nào
Nhật ký phải ghi trục bị đổi, từ gì sang gì, chứ không gộp thành "trạng thái chung". Khi khách khiếu nại "phòng chưa dọn", quản lý tra được chính xác ai đổi trục vệ sinh và lúc nào.

Chỉ số trên dashboard
Quản lý xem các chỉ số tại thời điểm: phòng đang ở, sẵn sàng, cần dọn, ngừng phục vụ, việc quá hạn và tỷ lệ lấp đầy. Tỷ lệ lấp đầy = phòng đang ở ÷ phòng có thể phục vụ × 100%. Nếu không có phòng nào phục vụ được, dashboard ghi "không áp dụng" thay vì một con số vô nghĩa.

Bài học
- Trước khi đặt tên trạng thái, hãy hỏi: ai thay đổi nó? Nếu hai bộ phận khác nhau cùng sửa một ô, ô đó nên được tách.
- Trạng thái tổng hợp ("sẵn sàng") nên được tính ra, không nhập tay.
- Mỗi chỉ số phải định nghĩa rõ tử số, mẫu số và cách hiển thị khi mẫu số bằng 0.

Câu hỏi thảo luận
Trong dự án của bạn, có ô "trạng thái" nào đang gánh nhiều ý nghĩa cùng lúc không?""",
    },
    {
        "id": "BH-03",
        "group": "Nghiệp vụ",
        "title": "Nhận và trả phòng: ba điều kiện, một lý do rõ ràng và một việc dọn",
        "date": date(2026, 10, 29),
        "teaser": "Sự cố đáng sợ nhất ở quầy lễ tân là giao chìa khóa phòng chưa dọn hoặc đang sửa. Bài này kể cách nhóm biến thói quen "
                  "\"hỏi miệng buồng phòng\" thành quy tắc: chỉ nhận khách khi đủ ba điều kiện, từ chối phải nói rõ lý do, "
                  "và mỗi lần trả phòng sinh đúng một việc dọn.",
        "tags": "#NghiepVuKhachSan #CheckIn #CheckOut #LeTan",
        "status": "Chờ duyệt",
        "people": "Tác giả: [ĐIỀN] · Duyệt: [ĐIỀN] · Liên quan: Lễ tân, Quản lý KS (giả định) · Người đọc: Cả nhóm, Lớp học",
        "docs": "docs/_product/prd.md (mục 7.3)\ndocs/features/check-in-out/check-in-out-brd.md\ndocs/features/auth-roles/auth-roles-brd.md (BR-02)\ndocs/assets/figma/sequence-check-in-out-nhanphong.png, sequence-check-in-out-traphong.png",
        "body": """BÀI HỌC 03 – NHẬN VÀ TRẢ PHÒNG

Bối cảnh
Trước khi có hệ thống, lễ tân hỏi miệng buồng phòng xem phòng đã dọn chưa. Nhận nhầm phòng thì sửa tay và không còn dấu vết. Khách trả phòng xong, lễ tân lại phải gọi buồng phòng báo dọn.

Vấn đề
Nhận khách vào phòng chưa sẵn sàng là lỗi nghiêm trọng nhất của nghiệp vụ lễ tân: khách vào phòng chưa dọn hoặc đang sửa, uy tín khách sạn bị ảnh hưởng ngay.

Quy tắc nhận phòng
- Chỉ nhận khách khi phòng trống, đã sạch và không ngừng phục vụ. Hệ thống kiểm tra đúng lúc ghi, không dựa vào màn hình lễ tân đang xem, vì màn hình có thể đã cũ vài giây.
- Từ chối phải nêu lý do cụ thể theo trục vi phạm. "Phòng đang chờ quản lý kiểm tra" giúp lễ tân biết phải làm gì tiếp; "Không thể nhận phòng" thì không.
- Mỗi phòng tối đa một lượt lưu trú đang mở.

Thu ít dữ liệu khách nhất có thể
Câu hỏi "ghi thông tin gì của khách" được chốt ngày 25/09: chỉ tên khách và số người. MVP không thu giấy tờ tùy thân. Như vậy vừa đủ cho vận hành phòng, vừa giảm rủi ro giữ dữ liệu cá nhân; dữ liệu demo đều là giả lập.

Quy tắc trả phòng
Khi lễ tân xác nhận trả phòng, lượt lưu trú được đóng, trục lưu trú về "trống", trục vệ sinh sang "cần dọn", và hệ thống tự tạo đúng một việc dọn. Lễ tân không còn phải gọi điện; buồng phòng thấy việc mới ngay trên điện thoại.

Ai được làm
Chỉ lễ tân được nhận và trả phòng. Quản lý giám sát nhưng không tự thao tác. Tách người điều phối và người thực hiện giúp mỗi lượt lưu trú có đúng một người chịu trách nhiệm.

Khi nhận nhầm
Thay vì xóa, tài liệu nghiệp vụ đề xuất hủy lượt nhận nhầm trong một khoảng thời gian ngắn, lượt lưu trú chuyển sang trạng thái "hủy" và vẫn còn trong nhật ký. Độ dài khoảng thời gian này vẫn là câu hỏi mở.

Ngoài phạm vi MVP
Đặt phòng trước, giờ quy định và phụ thu, thanh toán, đổi phòng giữa kỳ lưu trú.

Bài học
- Quy tắc nghiệp vụ quan trọng nhất phải được kiểm tra ở nơi ghi dữ liệu, không chỉ ẩn nút trên giao diện.
- Thông báo từ chối cũng là một phần của nghiệp vụ: nó phải chỉ ra bước tiếp theo.
- Chỉ thu dữ liệu khách mà nghiệp vụ thật sự cần.

Câu hỏi thảo luận
Hệ thống của bạn từ chối người dùng bằng thông báo gì? Người dùng có biết phải làm gì tiếp không?""",
    },
    {
        "id": "BH-04",
        "group": "Nghiệp vụ",
        "title": "Vòng đời một việc dọn phòng: từ \"cần dọn\" tới \"sẵn sàng\"",
        "date": date(2026, 11, 5),
        "teaser": "Phòng trả xong mà không ai nhận dọn là phòng \"treo\", không bán được. Nhóm thiết kế lại chu trình dọn phòng: "
                  "việc tự sinh khi trả phòng, tự chia đều cho người đang trực, quá 60 phút thì cảnh báo, và chỉ quản lý được xác nhận phòng sạch.",
        "tags": "#NghiepVuKhachSan #Housekeeping #BuongPhong #QuyTrinh",
        "status": "Chờ duyệt",
        "people": "Tác giả: [ĐIỀN] · Duyệt: [ĐIỀN] · Liên quan: NV BP–BT, Quản lý KS (giả định) · Người đọc: Cả nhóm, Lớp học",
        "docs": "docs/_product/prd.md (mục 7.4)\ndocs/features/housekeeping/housekeeping-brd.md (BR-housekeeping-01 → 05)\ndocs/assets/figma/state-housekeeping-viecdonphong.png, activity-housekeeping.png",
        "body": """BÀI HỌC 04 – VÒNG ĐỜI MỘT VIỆC DỌN PHÒNG

Bối cảnh
Chu trình dọn phòng ở khách sạn mẫu chạy bằng điện thoại, giấy và bộ đàm. Phòng trả xong không có ai chịu trách nhiệm rõ ràng, phòng đã sạch không được mở bán lại kịp, và khi khách khiếu nại về vệ sinh thì không có bằng chứng để tra lại.

Chu trình mới, mỗi bước một người chịu trách nhiệm
1. Khách trả phòng, việc dọn được tạo tự động (khi cần vẫn có thể tạo việc dọn bằng tay). Việc ở trạng thái "chờ giao".
2. Hệ thống tự phân công theo thứ tự giờ trả phòng, chia đều cho nhân viên buồng phòng đang trực.
3. Nhân viên nhận việc và bắt đầu; trục vệ sinh của phòng chuyển "đang dọn".
4. Nhân viên báo xong; phòng chuyển "chờ kiểm tra", việc chờ quản lý xác nhận.
5. Quản lý xác nhận, phòng chuyển "sạch". Nếu chưa đạt, quản lý trả lại việc và bắt buộc ghi lý do, để nhân viên biết cần sửa gì.

Vì sao chỉ quản lý được xác nhận
Câu hỏi này được chốt ngày 17/09. Cho nhân viên tự xác nhận thì nhanh hơn, nhưng mất đi lớp kiểm tra chất lượng. Nhóm chọn chất lượng, vì phòng chưa sạch mà vẫn bán được là sự cố nặng nhất của bộ phận buồng phòng.

Cảnh báo quá hạn đo đúng người
Việc dọn quá 60 phút kể từ lúc tạo mà nhân viên chưa báo xong thì bị đánh dấu quá hạn và cảnh báo một lần cho quản lý và người phụ trách. Thời gian chờ quản lý xác nhận không tính vào 60 phút, để nhân viên không bị "phạt" vì sự chậm của người khác. Cảnh báo chạy bằng quy tắc, không phụ thuộc AI.

Những đánh đổi nhóm chấp nhận
- Chia đều là cách đơn giản, có thể không hợp khi phòng ở tầng xa hoặc phòng lớn. Nhóm ghi thành rủi ro và sẽ đo lại sau demo.
- Danh sách "nhân viên đang trực" lấy từ đâu (cố định hay quản lý đánh dấu theo ca) vẫn là câu hỏi mở.
- Ngoài phạm vi MVP: checklist dọn theo loại phòng, ảnh bằng chứng, chấm công theo việc.

Bài học
- Mỗi bước trong quy trình phải có đúng một người chịu trách nhiệm và một trạng thái tương ứng.
- Cảnh báo chỉ nên đo phần việc mà người bị cảnh báo kiểm soát được.
- Trả lại công việc phải kèm lý do; nếu không, vòng sửa sẽ lặp lại.

Câu hỏi thảo luận
Trong quy trình của nhóm bạn, ai là người "đóng" một công việc: người làm hay người kiểm tra?""",
    },
    {
        "id": "BH-05",
        "group": "Nghiệp vụ",
        "title": "Báo hỏng và ngừng phục vụ: chặn bán nhầm mà không đuổi khách",
        "date": date(2026, 11, 12),
        "teaser": "Ai phát hiện hỏng hóc cũng có thể báo, nhưng không phải ai cũng được đóng việc sửa. Bài này kể các quy tắc giúp phòng "
                  "đang sửa không bị bán nhầm, khách đang ở không bị ảnh hưởng, và lịch sử sửa chữa không bị viết lại.",
        "tags": "#NghiepVuKhachSan #BaoTri #Maintenance #QuyTac",
        "status": "Chờ duyệt",
        "people": "Tác giả: [ĐIỀN] · Duyệt: [ĐIỀN] · Liên quan: NV BP–BT, Lễ tân, Quản lý KS (giả định) · Người đọc: Cả nhóm, Lớp học",
        "docs": "docs/_product/prd.md (mục 7.5)\ndocs/features/maintenance/maintenance-brd.md (BR-maintenance-01 → 06)\ndocs/assets/figma/state-maintenance-viecbaotri.png, activity-maintenance.png",
        "body": """BÀI HỌC 05 – BÁO HỎNG VÀ NGỪNG PHỤC VỤ

Bối cảnh
Trước đây, hỏng hóc được báo bằng lời. Phòng đang sửa vẫn có thể bị nhận khách vì lễ tân không biết, và không ai theo dõi được việc sửa đã tới đâu.

Vấn đề
Bán nhầm một phòng đang sửa là sự cố vận hành nghiêm trọng. Nhưng phản ứng quá tay, như bắt khách đang ở phải chuyển phòng vì một vòi sen rỉ nước, cũng là trải nghiệm tệ.

Các quy tắc nhóm đã chốt
- Ai phát hiện hỏng cũng báo được, kèm phòng và mô tả.
- Có việc bảo trì đang mở thì phòng tự chuyển "ngừng phục vụ"; hết việc đang mở thì tự về "bình thường". Trạng thái được tính tự động, không phụ thuộc ai nhớ cập nhật.
- Ngừng phục vụ chặn nhận khách mới nhưng không đuổi khách đang ở. Đổi phòng cho khách là quyết định của con người và nằm ngoài MVP.
- Chỉ nhân viên bảo trì được nhận và báo xong việc sửa, và chỉ báo xong trên việc do chính mình đang sửa.
- Lễ tân hoặc quản lý có thể đặt ngừng phục vụ thủ công vì lý do vận hành (ví dụ sơn lại phòng), bắt buộc ghi lý do. Mỗi phòng có tối đa một lần đặt tay đang hiệu lực.
- Việc đã hoàn tất hoặc đã hủy không được mở lại. Sửa chưa đạt thì tạo báo hỏng mới, để lịch sử phản ánh đúng những gì đã xảy ra.

Phân biệt "ai được báo" và "ai được đóng"
Mở rộng quyền báo hỏng cho mọi vai trò giúp phát hiện sớm: lễ tân nghe khách phàn nàn, buồng phòng thấy khi dọn. Nhưng quyền đóng việc chỉ thuộc người thực sự sửa, nên mỗi việc sửa có một người chịu trách nhiệm rõ ràng.

Câu hỏi còn mở
Ngưỡng quá hạn cho việc bảo trì chưa chốt, nên hệ thống chỉ cảnh báo khi đã cấu hình. Việc sửa được giao chỉ định hay để nhân viên tự nhận cũng còn đang bàn.

Ngoài phạm vi MVP
Kho vật tư, chi phí sửa chữa, lịch bảo trì định kỳ và mức độ ưu tiên hỏng.

Bài học
- Tự động hóa những trạng thái mà con người hay quên cập nhật.
- Quy tắc an toàn phải cân bằng: chặn rủi ro mới, nhưng không phá trải nghiệm hiện tại.
- Không viết lại lịch sử: muốn sửa sai thì tạo bản ghi mới.

Câu hỏi thảo luận
Hệ thống của bạn có cho "mở lại" một công việc đã đóng không? Điều đó ảnh hưởng gì tới số liệu báo cáo?""",
    },
    {
        "id": "BH-06",
        "group": "Quản lý dự án",
        "title": "WBS 530 giờ cho 3 người: khi kế hoạch lớn hơn năng lực",
        "date": date(2026, 11, 19),
        "teaser": "Kế hoạch cần 530 giờ, trong khi 3 người × 20 giờ/tuần × 8 tuần chỉ được 480 giờ, và riêng một thành viên gánh 222 giờ. "
                  "Nhóm không giấu chênh lệch mà đưa nó vào charter và sổ rủi ro. Bài này chia sẻ cách dựng WBS theo quy tắc 100% và 8/80 "
                  "rồi đưa vào MS Project.",
        "tags": "#WBS #QuanLyDuAn #MSProject #UocLuong",
        "status": "Chờ duyệt",
        "people": "Tác giả: [ĐIỀN] · Duyệt: [ĐIỀN] · Liên quan: Giảng viên (duyệt dự toán) · Người đọc: Cả nhóm, Giảng viên, Lớp học",
        "docs": "docs/project-charter.md (mục 6 Ngân sách, C-2, A-2)\ndocs/wbs/KhachSanSach.xlsx\nplans/260923-1658-four-sprint-mvp-backlog/ (WBS chi tiết, hướng dẫn import MS Project)",
        "body": """BÀI HỌC 06 – WBS 530 GIỜ CHO 3 NGƯỜI

Bối cảnh
Dự án chạy 4 sprint từ 08/09 đến 27/10/2026. Năng lực tham chiếu là 3 người × 20 giờ/tuần × 8 tuần = 480 giờ, tức khoảng 160 giờ mỗi người.

Vấn đề
Khi cộng dồn từ dưới lên, WBS cần 530 giờ: Đạt 145 giờ, Hoàng 222 giờ, Bảo 163 giờ. Tổng vượt năng lực 50 giờ, và riêng Hoàng vượt khoảng 62 giờ so với mức tham chiếu.

Cách nhóm làm
- Quy tắc 100%: WBS phải bao trọn phạm vi, kể cả việc không phải code như phỏng vấn, kiểm thử, viết runbook, bàn giao. Riêng workstream phân tích nghiệp vụ của Sprint 1 đã chiếm khoảng 51 giờ.
- Quy tắc 8/80 áp dụng ở cấp gói công việc của baseline, không áp cho task hằng ngày.
- Mỗi task có người làm, đầu ra bắt buộc và người kiểm tra. Trạng thái chỉ được ghi "Đã xong" khi có bằng chứng như PR, commit, ảnh chạy hoặc kết quả test.
- Mỗi sprint kết thúc bằng một cổng (milestone 0 ngày) có tiêu chí kiểm chứng được, ví dụ cổng Sprint 1: quản lý đăng nhập, sửa phòng, seed 50 phòng, RBAC chặn ghi, realtime hai client.
- Xuất WBS sang MS Project, gán Đạt, Hoàng, Bảo và các tài nguyên chi phí (phụ cấp tăng ca, VPS, domain) để dự toán tự tính ra 24.920.000 đ. Cộng trần API 300.000 đ và dự phòng 4.780.000 đ, tổng dự toán 30.000.000 đ đã được giảng viên duyệt.

Không giấu chênh lệch
Phần quá tải được ghi thành giả định và rủi ro trong charter: nếu 62 giờ quá tải của Hoàng phải trả theo đơn giá tăng ca thì phát sinh 2.914.000 đ, tương đương khoảng 61% quỹ dự phòng. Nhóm theo dõi rủi ro này hằng tuần trong báo cáo tiến độ, ưu tiên các tính năng Must và đóng băng phạm vi từ 15/10.

Điều MS Project cho thấy
Khi để MS Project tự xếp lịch theo quan hệ phụ thuộc, cổng Sprint 1 rơi vào 28/09 thay vì 21/09. Lịch "trên giấy" và lịch "theo phụ thuộc" lệch nhau một tuần ngay từ sprint đầu, đó là tín hiệu sớm để cân lại việc.

Bài học
- Khi ước lượng vượt năng lực, hãy nói ra từ đầu. Giấu đi thì nó vẫn xuất hiện ở tuần cuối dưới dạng làm đêm.
- Nhìn tổng giờ chưa đủ; phải nhìn giờ theo từng người để thấy ai đang quá tải.
- "Đã xong" cần được định nghĩa bằng bằng chứng, không phải bằng cảm giác.

Câu hỏi thảo luận
Nhóm bạn xử lý thế nào khi một thành viên bị giao nhiều hơn hẳn những người còn lại?""",
    },
    {
        "id": "BH-07",
        "group": "Làm việc nhóm",
        "title": "Truyền thông cho nhóm 3 người: Slack để báo cáo, Zalo để trao đổi",
        "date": date(2026, 11, 26),
        "teaser": "Nhóm chỉ có 3 người nhưng có tới 21 kênh truyền thông tiềm năng khi tính cả giảng viên và các vai trò người dùng. "
                  "Nhóm tách Slack làm nơi đăng báo cáo Excel, Zalo làm nơi trao đổi, và phát hiện PM là điểm nghẽn khi gửi gần một nửa số loại thông tin.",
        "tags": "#TruyenThongDuAn #Slack #Zalo #RACI #LamViecNhom",
        "status": "Đang viết",
        "people": "Tác giả: [ĐIỀN] · Duyệt: [ĐIỀN] · Liên quan: Giảng viên · Người đọc: Cả nhóm, Giảng viên, Lớp học",
        "docs": "plans/260923-1658-four-sprint-mvp-backlog/ke-hoach-quan-ly-truyen-thong.xlsx (sheet 3, 6, 8)",
        "body": """BÀI HỌC 07 – SLACK ĐỂ BÁO CÁO, ZALO ĐỂ TRAO ĐỔI

Bối cảnh
Nhóm có 3 thành viên, một giảng viên đóng vai sponsor và 3 vai trò người dùng giả định. Theo công thức N(N−1)/2, 7 người tạo ra 21 kênh truyền thông tiềm năng; chỉ tính nội bộ nhóm thì có 3.

Vấn đề
Trước khi có kế hoạch, quyết định nằm rải rác trong tin nhắn, báo cáo gửi lúc có lúc không, và không ai biết bản nào là bản mới nhất.

Cách nhóm làm
- Tách vai trò kênh. Slack là nhóm báo cáo: chỉ đăng file Excel theo 4 mẫu (báo cáo tuần, biên bản họp, báo cáo sprint, báo cáo chất lượng). Zalo là nhóm tương tác: hỏi đáp, họp 2 buổi/tuần, việc khẩn. GitHub là kho bản gốc, vì Slack miễn phí chỉ giữ 90 ngày lịch sử.
- Tin nhắn Zalo có tiền tố: [KHẨN] phản hồi trong 30 phút, [HỎI] trong 4 giờ, [CHỐT] là quyết định phải được ghi vào biên bản, [FYI] để tham khảo.
- Mỗi loại thông tin có mã, người gửi, người nhận, thời điểm, kênh và ma trận RACI; file Excel tự kiểm tra mỗi thông tin có đúng 1 người chịu trách nhiệm cuối.

Điều phân tích cho thấy
Bảng tải truyền thông chỉ ra PM là người gửi gần một nửa số loại thông tin và ban đầu chịu trách nhiệm cuối cho 18/20 loại. Nhóm đã ủy quyền biên bản họp, retro và Design Token cho Bảo, API contract cho Hoàng, giảm còn 14/20.
Kế hoạch được lập ngày 14/10, giữa dự án, nên 52 sự kiện trước đó phải xác nhận lại. Đây cũng là bài học lớn nhất của phần này.
[ĐIỀN: KPI truyền thông cuối dự án – tỷ lệ báo cáo đúng hạn, thời gian phản hồi [HỎI], điểm hài lòng truyền thông trung bình]

Bài học
- Lập kế hoạch truyền thông ngay tuần đầu, cùng lúc với WBS.
- Một kênh, một vai trò. Khi kênh vừa để báo cáo vừa để tán gẫu, báo cáo sẽ bị trôi.
- Đo tải truyền thông theo người để thấy điểm nghẽn trước khi nó thành trễ hạn.

Câu hỏi thảo luận
Nhóm bạn quy định kênh nào là "nguồn sự thật" cho các quyết định?""",
    },
    {
        "id": "BH-08",
        "group": "Kỹ thuật",
        "title": "Từ quy tắc nghiệp vụ tới code: lưu trước rồi mới phát, và chỉ một người thắng",
        "date": date(2026, 12, 3),
        "teaser": "Quầy lễ tân, điện thoại buồng phòng và dashboard quản lý phải thấy cùng một trạng thái phòng, và hai người cùng bấm "
                  "một lúc thì không được ghi đè nhau. Bài này kể hai cơ chế kỹ thuật giữ cho các quy tắc nghiệp vụ ở bài 02–05 luôn đúng.",
        "tags": "#Realtime #SocketIO #OptimisticLock #PostgreSQL #Testing",
        "status": "Đang viết",
        "people": "Tác giả: [ĐIỀN] · Duyệt: [ĐIỀN] · Liên quan: Bảo (giao diện mất kết nối) · Người đọc: Cả nhóm, Lớp học",
        "docs": "server/src/lib/transaction.ts\nserver/src/lib/optimistic-lock.ts\nserver/src/realtime/socket.ts\nserver/tests/realtime.test.ts, optimistic-lock.test.ts, spec-rules.test.ts\napp/lib/features/dashboard/widgets/offline_banner.dart",
        "body": """BÀI HỌC 08 – LƯU TRƯỚC RỒI MỚI PHÁT, VÀ CHỈ MỘT NGƯỜI THẮNG

Bối cảnh
Giá trị cốt lõi của sản phẩm là mọi vai trò thấy cùng một trạng thái phòng. Charter đặt mục tiêu North Star: ít nhất 95% trong 100 lượt cập nhật hiển thị trên thiết bị khác trong vòng 3 giây, với 50 phòng và 30 phiên đồng thời, và 0 ca ghi đè do xung đột.

Vấn đề 1: phát sự kiện quá sớm
Nếu cập nhật CSDL rồi phát sự kiện ngay trong lúc xử lý, khi transaction lỗi và rollback, các thiết bị khác đã kịp hiển thị một trạng thái không hề tồn tại.

Cách làm: hàm withTransaction chạy toàn bộ thao tác trong một transaction, gom sự kiện realtime vào hàng chờ và chỉ phát sau khi commit thành công. Nhật ký được ghi trong cùng transaction, nên trạng thái phòng và nhật ký luôn khớp nhau.

Vấn đề 2: hai người cùng bấm một lúc
Hai lễ tân cùng nhận một phòng, hoặc một lần bấm bị gửi lại khi mạng chập chờn. Người ghi sau có thể lặng lẽ đè lên người ghi trước.

Cách làm: các bảng bị nhiều người sửa có cột version. Lệnh cập nhật chỉ thành công khi version còn khớp; nếu không, server trả lỗi xung đột kèm bản mới nhất để giao diện hiển thị lại. Một trigger trong PostgreSQL ép version tăng với mọi lệnh cập nhật, nên kể cả code quên kiểm tra thì client cầm version cũ vẫn bị từ chối.

Phía người dùng
Socket.IO bắt tay bằng token phiên và phát hiện mất kết nối trong khoảng tối đa 10 giây. Khi mất kết nối, ứng dụng Flutter hiện banner "Mất kết nối — đang thử lại" và tạm khóa thao tác ghi để tránh ghi sai.

Kiểm thử
Các quy tắc nghiệp vụ được viết thành test: 10 người sửa cùng lúc với cùng version thì đúng 1 người thành công; xung đột thì không lưu và không phát sự kiện; mỗi lượt trả phòng sinh đúng 1 việc dọn; mỗi phòng tối đa 1 lượt lưu trú đang mở.
[ĐIỀN: kết quả chạy npm test của server (số test pass/tổng) và kết quả đo North Star với 30 phiên đồng thời]

Bài học
- Thứ tự đúng là: kiểm quyền → ghi dữ liệu và nhật ký trong transaction → commit → phát sự kiện.
- Đặt một lớp chặn ở CSDL để lỗi quên gọi hàm không thành lỗ hổng.
- Quy tắc nghiệp vụ nào quan trọng thì phải có test chạy đồng thời thật, không chỉ test tuần tự.

Câu hỏi thảo luận
Ứng dụng của bạn phát sự kiện realtime trước hay sau khi dữ liệu được lưu?""",
    },
]
