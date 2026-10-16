---
type: prd-product
status: draft
updated: 2026-10-04
links: []
---

# KhachSanDiDong — Product Requirements Document (project-level)

## 1. One-line Pitch

Phần mềm theo dõi trạng thái phòng khách sạn theo thời gian thực tích hợp dashboard dữ liệu (web + mobile), giúp quản lý, lễ tân và nhân viên buồng phòng/bảo trì cùng làm việc trên một nguồn trạng thái phòng duy nhất — thay vì báo miệng rời rạc rồi lễ tân nhập lại sau.

## 2. Problem & Why Now

- **Vấn đề cốt lõi:** trạng thái phòng trên 3 trục (lưu trú / vệ sinh / bảo trì) được cập nhật rời rạc giữa các vai trò → không ai chắc "phòng này đang ở trạng thái gì tại thời điểm này", điều phối chậm và dễ nhầm.
- **Ai đang đau:** quản lý (không có cái nhìn tổng theo thời điểm, không biết việc nào đang trễ), lễ tân (không chắc phòng nào thật sự sẵn sàng để nhận khách, phải nhập hộ mọi cập nhật của bộ phận khác), nhân viên buồng phòng/bảo trì (không biết việc nào đang chờ mình, phải hỏi lại quầy).
- **Giải pháp thay thế hiện tại:** chỉ lễ tân nhập liệu vào hệ thống tại quầy; buồng phòng và bảo trì báo miệng hoặc gọi điện cho lễ tân → lễ tân nhập vào sau → trễ, sót giữa các vai trò.
- **Why now:** đồ án của WPCTeam với deadline cam kết 8 tuần (08/09–02/11/2026); bài toán khách sạn cỡ nhỏ–vừa (~50 phòng) đủ thực tế để chứng minh giá trị nhưng đủ gọn để hoàn thành MVP trong khuôn khổ môn học.

## 3. Target Users

| Nhóm người dùng | Vai trò (primary/secondary) | Job-to-be-done | Bối cảnh sử dụng |
|---|---|---|---|
| Quản lý khách sạn | primary | Biết ngay tình trạng toàn bộ phòng và việc nào đang trễ để điều phối trong ca; cuối ca đọc tóm tắt vận hành | Web dashboard, xem liên tục trong ca |
| Lễ tân | primary | Biết phòng nào thật sự sẵn sàng để nhận khách nhanh; trả phòng chuyển trạng thái ngay tại quầy | Web tại quầy lễ tân, ca làm việc liên tục |
| Nhân viên buồng phòng | primary | Biết việc dọn được giao ở phòng nào, báo hoàn tất ngay tại chỗ không cần gọi quầy | Mobile Android, di chuyển giữa các tầng |
| Nhân viên bảo trì | primary | Nhận báo hỏng kèm phòng/vị trí, cập nhật tiến độ sửa ngay tại hiện trường | Mobile Android, hiện trường |

*Ai KHÔNG phải người dùng: khách lưu trú, kế toán, kênh OTA/đối tác ngoài, các khách sạn khác (phạm vi 1 khách sạn).*

## 4. Value Proposition & Differentiator

- **Giá trị cốt lõi (1 câu):** mọi vai trò nhìn và cập nhật cùng một trạng thái phòng theo thời gian thực — lễ tân không còn làm trung gian nhập hộ.
- **Vì sao chọn mình thay giải pháp cũ:** nhân viên tự cập nhật ngay trên mobile thay vì báo miệng cho lễ tân nhập sau; thay đổi lan tới mọi thiết bị trong ≤3 giây; quản lý có dashboard tổng hợp và cảnh báo quá hạn tự động thay vì phải hỏi từng người.
- **Lợi thế khác biệt:** luồng vận hành khép kín theo 3 trục trạng thái tách biệt (lưu trú / vệ sinh / bảo trì) — tránh nhầm lẫn trạng thái — kèm AI tóm tắt vận hành theo ca hỗ trợ quản lý (AI chỉ tham khảo, không tự sửa dữ liệu).

## 5. Goals & Non-Goals

**Mục tiêu (in-scope):**
- MVP hoàn thành trong 8 tuần, nghiệm thu trên Flutter Web + Android tại khách sạn giả định 50 phòng.
- Quản lý tài khoản và phân quyền; danh mục phòng; nhận/trả phòng cơ bản; công việc dọn phòng, báo hỏng và lịch sử thay đổi.
- Đồng bộ thay đổi giữa các thiết bị; dashboard thể hiện phòng đang ở, sẵn sàng, cần dọn, ngừng phục vụ, công việc quá hạn và tỷ lệ lấp đầy tại thời điểm xem.
- AI tạo bản tóm tắt vận hành theo ca/ngày từ số liệu hệ thống và gợi ý việc cần chú ý (hỗ trợ quản lý, không quyết định thay).

**Ngoài phạm vi (non-goals / out-of-scope):**
- Phát hành lên kho ứng dụng (App Store/Play); iOS chỉ là mục tiêu mở rộng khi có môi trường build/kiểm thử.
- Thanh toán, kế toán, tích hợp OTA/PMS, IoT, dự báo doanh thu, huấn luyện AI riêng.
- Đa khách sạn, đa ngôn ngữ (v1 chỉ tiếng Việt), dữ liệu khách sạn thật (chỉ dữ liệu giả lập).

## 6. Capability Themes

| Theme | Mô tả | Features thuộc theme |
|---|---|---|
| Nền tảng chung | Tài khoản, phân quyền và cơ chế đồng bộ thời gian thực làm nền cho mọi thao tác | `auth-roles`, `realtime-sync` |
| Vận hành phòng | Luồng nghiệp vụ hằng ngày trên trạng thái phòng: danh mục, nhận/trả, dọn, sửa | `room-catalog`, `check-in-out`, `housekeeping`, `maintenance` |
| Giám sát & truy vết | Nhìn tổng quan, truy vết lịch sử và tóm tắt vận hành phục vụ quản lý | `room-dashboard`, `audit-log`, `ai-ops-summary` |

## 7. Feature Map

### Luồng người dùng tổng quan

1) Quản lý/lễ tân tạo tài khoản và gán vai trò → `auth-roles`
2) Nhập danh mục 50 phòng của khách sạn → `room-catalog`
3) Lễ tân nhận phòng cho khách — chỉ khi phòng trống, đã sạch và trục bảo trì ở trạng thái bình thường → `check-in-out`
4) Khách trả phòng → phòng chuyển "cần dọn", hệ thống tự tạo việc dọn → `check-in-out` → `housekeeping`
5) Nhân viên buồng nhận và hoàn tất việc dọn → phòng được xác nhận "sẵn sàng" → `housekeeping`
6) Phòng hỏng → báo hỏng, phòng "ngừng phục vụ", sửa xong mở lại → `maintenance`
7) Mọi thay đổi lan realtime tới mọi thiết bị và tự động ghi nhật ký → `realtime-sync` + `audit-log`
8) Quản lý theo dõi dashboard (đang ở / sẵn sàng / cần dọn / ngừng / quá hạn / tỷ lệ lấp đầy) và đọc tóm tắt AI cuối ca → `room-dashboard` + `ai-ops-summary`

### Bảng Feature Map

| # | Tính năng | Slug | Theme | Persona | Ưu tiên (MoSCoW) | Phụ thuộc | Chi tiết hóa |
|---|---|---|---|---|---|---|---|
| 1 | Đăng nhập & phân quyền | `auth-roles` | Nền tảng chung | tất cả | Must | — | ✅ đã chi tiết (1 brainstorm) |
| 2 | Danh mục phòng | `room-catalog` | Vận hành phòng | quản lý | Must | `auth-roles` | ✅ đã chi tiết (1 brainstorm) |
| 3 | Nhận/trả phòng | `check-in-out` | Vận hành phòng | lễ tân | Must | `room-catalog` | ✅ đã chi tiết (1 brainstorm) |
| 4 | Công việc dọn phòng | `housekeeping` | Vận hành phòng | nv buồng | Must | `room-catalog`, `check-in-out` | ✅ đã chi tiết (1 brainstorm) |
| 5 | Báo hỏng & bảo trì | `maintenance` | Vận hành phòng | nv bảo trì | Must | `room-catalog` | ✅ đã chi tiết (1 brainstorm) |
| 6 | Đồng bộ thời gian thực | `realtime-sync` | Nền tảng chung | tất cả | Must | `auth-roles` | ✅ đã chi tiết (1 brainstorm) |
| 7 | Dashboard trạng thái phòng | `room-dashboard` | Giám sát & truy vết | quản lý | Must | `housekeeping`, `maintenance`, `realtime-sync` | ✅ đã chi tiết (1 brainstorm) |
| 8 | Nhật ký thay đổi | `audit-log` | Giám sát & truy vết | quản lý | Must | `auth-roles` | ✅ đã chi tiết (1 brainstorm) |
| 9 | AI tóm tắt vận hành | `ai-ops-summary` | Giám sát & truy vết | quản lý | Must | `room-dashboard`, `audit-log` | ✅ đã chi tiết (1 brainstorm) |

### 7.1 Đăng nhập & phân quyền — `auth-roles`

Tài khoản và vai trò là cửa ngõ của toàn hệ thống: mọi thao tác ghi đều kiểm tra quyền ở máy chủ. Quản lý và lễ tân tạo/khóa tài khoản và gán vai trò cho nhân viên. Kết quả là mỗi người chỉ thấy và làm đúng phần việc của vai trò mình.

**Phục vụ job:** feature nền — hỗ trợ cả 4 nhóm người dùng (không ai dùng được hệ thống nếu chưa có tài khoản và quyền).

**Phạm vi v1:** đăng nhập/đăng xuất; 3 vai trò (quản lý, lễ tân, nhân viên buồng phòng–bảo trì — 1 vai trò gộp); quản lý + lễ tân tạo/khóa tài khoản và gán vai trò; kiểm tra quyền phía máy chủ cho mọi thao tác ghi; mật khẩu lưu an toàn.
**Chưa làm:** quên mật khẩu/email reset, SSO, tự đổi mật khẩu, phân quyền chi tiết theo chức năng, tách vai trò buồng phòng–bảo trì.

**Luồng chính:**
1) Quản lý/lễ tân tạo tài khoản, gán 1 trong 3 vai trò.
2) Nhân viên đăng nhập trên web (quầy) hoặc Android (di động).
3) Hệ thống hiển thị phần việc theo vai trò.
4) Mọi thao tác ghi được máy chủ kiểm quyền và ghi nhật ký (`audit-log`).

**Rủi ro chính:** phân quyền sai → nhân viên thao tác vượt quyền (vd tự đổi trạng thái phòng). · **Đo thành công:** 100% thao tác ghi được kiểm quyền server-side; 0 hành động vượt quyền trong các kịch bản nghiệm thu.
**OQ riêng:** —

### 7.2 Danh mục phòng — `room-catalog`

Danh mục phòng là dữ liệu gốc mà mọi trạng thái và thao tác bám vào: 50 phòng giả lập với số phòng, tầng, loại phòng. Quản lý nhập và chỉnh danh mục; các vai trò khác tra cứu tình trạng phòng từ danh mục này.

**Phục vụ job:** nền cho job của lễ tân ("biết phòng nào sẵn sàng") và quản lý ("cái nhìn tổng") — không có danh mục thì không có trạng thái để theo dõi.

**Phạm vi v1:** danh mục 50 phòng giả lập (số phòng, tầng, loại phòng); CRUD phòng bởi quản lý; mỗi phòng mang 3 trục trạng thái riêng (lưu trú / vệ sinh / bảo trì).
**Chưa làm:** giá phòng, hình ảnh, tiện nghi chi tiết, sơ đồ mặt bằng.

**Luồng chính:**
1) Quản lý nhập danh mục 50 phòng.
2) Lễ tân/nhân viên tra cứu phòng theo tầng, trạng thái.
3) Thông tin phòng là đầu vào cho nhận/trả phòng, dọn, báo hỏng.

**Rủi ro chính:** danh mục sai → mọi trạng thái và dashboard lệch theo. · **Đo thành công:** danh mục 50 phòng khớp dữ liệu giả lập; thay đổi danh mục phản ánh ngay trên các màn hình khác.
**OQ riêng:** —

### 7.3 Nhận/trả phòng — `check-in-out`

Nghiệp vụ lõi của lễ tân: nhận phòng chỉ khi phòng trống, đã sạch và không ngừng phục vụ; trả phòng chuyển trạng thái lưu trú sang trống và vệ sinh sang "cần dọn", đồng thời tự tạo việc dọn cho buồng phòng. Đây là điểm khởi đầu của vòng đời vận hành phòng mỗi ngày.

**Phục vụ job:** lễ tân — "nhận khách nhanh vào phòng thật sự sẵn sàng, trả phòng cập nhật ngay không qua trung gian".

**Phạm vi v1:** nhận phòng với kiểm tra điều kiện (trống + sạch + bảo trì bình thường) và chặn khi không đạt; trả phòng → tự tạo việc dọn; thông tin khách ghi tối thiểu (dữ liệu giả lập).
**Chưa làm:** đặt phòng trước (booking), giờ quy định/phụ thu, thanh toán, đổi phòng giữa kỳ lưu trú.

**Luồng chính:**
1) Lễ tân chọn phòng trống-sẵn sàng để nhận khách.
2) Hệ thống kiểm tra điều kiện và xác nhận nhận phòng → trạng thái lưu trú "đang ở".
3) Khi khách trả: lễ tân xác nhận trả → phòng chuyển "cần dọn", việc dọn được tạo tự động.
4) Trạng thái mới lan realtime tới mọi thiết bị (`realtime-sync`).

**Rủi ro chính:** nhận phòng vào phòng chưa sẵn sàng → sai nghiệp vụ cốt lõi, khách vào phòng chưa dọn. · **Đo thành công:** 100% ca nhận phòng bị chặn khi phòng chưa đủ điều kiện; 100% ca trả phòng tự tạo việc dọn.
**OQ riêng:** OQ-4 ✅ resolved 2026-09-25 — tên khách + số người.

### 7.4 Công việc dọn phòng — `housekeeping`

Quản lý chu trình dọn phòng sau khi khách trả hoặc khi cần: việc dọn được tạo, giao cho nhân viên buồng, nhân viên nhận và báo hoàn tất ngay trên mobile. Phòng chỉ quay lại "sẵn sàng" khi việc dọn được xác nhận — khép kín vòng từ "cần dọn" về "sạch".

**Phục vụ job:** nhân viên buồng — "biết việc nào đang chờ mình, báo xong ngay tại chỗ"; quản lý — "biết việc dọn nào đang trễ".

**Phạm vi v1:** danh sách việc dọn theo phòng; tạo tự động khi trả phòng và tạo tay khi cần; giao việc; nhân viên nhận/hoàn tất; trạng thái vệ sinh riêng (cần dọn / đang dọn / sạch); gắn cờ việc quá hạn.
**Chưa làm:** checklist dọn theo loại phòng, ảnh bằng chứng, chấm công theo việc.

**Luồng chính:**
1) Việc dọn được tạo (tự động khi trả phòng hoặc thủ công).
2) Hệ thống giao việc cho nhân viên buồng phòng đang trực có ít việc mở nhất.
3) Nhân viên cập nhật "đang dọn" → "hoàn tất".
4) Phòng được xác nhận sạch → trạng thái vệ sinh "sạch", phòng sẵn sàng phục vụ.

**Rủi ro chính:** việc dọn bị bỏ sót hoặc quá hạn mà không ai biết → phòng "treo" không bán được. · **Đo thành công:** 100% phòng trả xong có việc dọn được tạo; mọi việc quá hạn được gắn cờ hiển thị trên dashboard.
**OQ riêng:** OQ-1 (ngưỡng thời gian tính "quá hạn"); OQ-2 ✅ resolved 2026-09-17 — chỉ quản lý xác nhận (BR-housekeeping-001, FR-housekeeping-005/006); OQ-3 (giao việc — xem Mục 11, annotate từng phía).

### 7.5 Báo hỏng & bảo trì — `maintenance`

Bất kỳ vai trò nào phát hiện hỏng hóc đều báo kèm phòng và mô tả; phòng chuyển "ngừng phục vụ" để không bị nhận khách nhầm. Nhân viên bảo trì nhận việc, cập nhật tiến độ tại hiện trường, sửa xong thì phòng mở lại phục vụ.

**Phục vụ job:** nhân viên bảo trì — "nhận báo hỏng rõ phòng/vị trí, cập nhật tiến độ ngay"; quản lý/lễ tân — "phòng đang sửa không bị bán nhầm".

**Phạm vi v1:** báo hỏng kèm phòng + mô tả từ mọi vai trò; trạng thái bảo trì riêng (bình thường / ngừng phục vụ); nhân viên bảo trì nhận và hoàn tất việc sửa; mở lại phục vụ sau khi xong.
**Chưa làm:** kho vật tư, chi phí sửa chữa, lịch bảo trì định kỳ, mức độ ưu tiên hỏng.

**Luồng chính:**
1) Ai đó báo hỏng kèm phòng và mô tả.
2) Phòng chuyển "ngừng phục vụ" — `check-in-out` không thể nhận phòng này.
3) Nhân viên bảo trì nhận việc, sửa, báo xong.
4) Phòng mở lại phục vụ, trạng thái lan realtime.

**Rủi ro chính:** phòng đang sửa vẫn bị nhận khách → sự cố vận hành nghiêm trọng. · **Đo thành công:** 100% phòng "ngừng phục vụ" bị chặn nhận khách; báo hỏng nào cũng có trạng thái xử lý rõ ràng cho tới khi đóng.
**OQ riêng:** OQ-1 (ngưỡng "quá hạn" cho việc bảo trì), OQ-3 (giao việc chỉ định hay tự nhận).

### 7.6 Đồng bộ thời gian thực — `realtime-sync`

Cơ chế nền khiến "một nguồn sự thật" thành hiện thực: thay đổi trạng thái được lưu ở máy chủ rồi phát tới mọi thiết bị trong ≤3 giây; khi hai người sửa cùng lúc thì kiểm tra phiên bản để không ghi đè; khi mất mạng thiết bị báo trạng thái và khóa thao tác ghi, có mạng lại thì tải trạng thái mới từ máy chủ.

**Phục vụ job:** feature nền — là điều kiện để job "cập nhật ngay tại chỗ" của nhân viên và "cái nhìn tổng realtime" của quản lý thành hiện thực.

**Phạm vi v1:** lưu trước rồi phát sự kiện; cập nhật lan tới thiết bị khác ≤3s; kiểm tra phiên bản chống ghi đè; mất mạng → báo trạng thái + khóa ghi; kết nối lại → tải trạng thái mới.
**Chưa làm:** hàng đợi offline cho thao tác ghi, đồng bộ nội dung soạn dở, retry thông minh.

**Luồng chính:**
1) Một thiết bị thay đổi trạng thái → máy chủ lưu thành công.
2) Máy chủ phát cập nhật → các thiết bị khác hiển thị trong ≤3s.
3) Hai thiết bị sửa cùng lúc → kiểm tra phiên bản, từ chối ghi đè.
4) Thiết bị mất mạng → báo offline, khóa ghi; có mạng lại → đồng bộ lại.

**Rủi ro chính:** xung đột/mất kết nối gây ghi đè trạng thái → dữ liệu sai trên toàn hệ thống. · **Đo thành công:** ≥95% trong 100 lượt cập nhật hiển thị trên thiết bị khác ≤3s (50 phòng, 30 phiên đồng thời); 0 ca ghi đè do xung đột.
**OQ riêng:** —

### 7.7 Dashboard trạng thái phòng — `room-dashboard`

Màn hình tổng cho quản lý (và tham khảo cho lễ tân): lưới 50 phòng cập nhật realtime kèm các chỉ số tại thời điểm xem — phòng đang ở, sẵn sàng, cần dọn, ngừng phục vụ, công việc quá hạn và tỷ lệ lấp đầy. Cảnh báo quá hạn chạy bằng quy tắc, không phụ thuộc AI.

**Phục vụ job:** quản lý — "biết ngay tình trạng toàn khách sạn và việc nào đang trễ để điều phối trong ca".

**Phạm vi v1:** lưới 50 phòng realtime; chỉ số thời điểm: đang ở / sẵn sàng / cần dọn / ngừng phục vụ / việc quá hạn / tỷ lệ lấp đầy (phòng đang ở ÷ phòng có thể phục vụ × 100%, mẫu = 0 hiển thị "không áp dụng"); lọc theo tầng/trạng thái; cảnh báo quá hạn theo quy tắc.
**Chưa làm:** dự báo, báo cáo doanh thu, xem lịch sử từ dashboard.

**Luồng chính:**
1) Quản lý mở dashboard trên web.
2) Lưới phòng + chỉ số hiển thị trạng thái tại thời điểm xem.
3) Mọi thay đổi từ các vai trò lan lên dashboard realtime (`realtime-sync`).
4) Việc quá hạn được tô cờ/đánh dấu để quản lý can thiệp.

**Rủi ro chính:** chỉ số dashboard lệch dữ liệu thật → quản lý điều phối sai. · **Đo thành công:** 100% chỉ số dashboard khớp dữ liệu đối soát trong nghiệm thu.
**OQ riêng:** OQ-1 (ngưỡng "quá hạn" để hiển thị cảnh báo).

### 7.8 Nhật ký thay đổi — `audit-log`

Mọi thay đổi trạng thái và thao tác ghi đều tự động ghi nhật ký ở máy chủ (ai / khi nào / từ trạng thái nào sang trạng thái nào). Quản lý xem lại theo phòng để truy vết khi có tranh chấp "ai đã đổi gì".

**Phục vụ job:** quản lý — "truy vết được mọi thay đổi khi có sai lệch hoặc tranh chấp"; cũng là nguồn dữ liệu sự kiện cho `ai-ops-summary`.

**Phạm vi v1:** tự động ghi mọi thay đổi trạng thái và thao tác ghi; xem nhật ký theo phòng; lọc theo thời gian và vai trò/người thao tác.
**Chưa làm:** export nhật ký, chính sách lưu trữ dài hạn, cảnh báo từ nhật ký.

**Luồng chính:**
1) Người dùng thực hiện thao tác ghi → máy chủ kiểm quyền, lưu dữ liệu, ghi nhật ký.
2) Quản lý mở nhật ký của một phòng hoặc theo khoảng thời gian.
3) Nhật ký hiển thị ai / khi / hành động / trạng thái trước→sau.

**Rủi ro chính:** mất vết khi có tranh chấp → không truy được trách nhiệm. · **Đo thành công:** 100% thay đổi trạng thái có bản ghi đủ ai/khi/từ→sang.
**OQ riêng:** —

### 7.9 AI tóm tắt vận hành — `ai-ops-summary`

Cuối ca hoặc cuối ngày, quản lý bấm tạo bản tóm tắt: hệ thống tính số liệu tổng hợp (không chứa thông tin định danh khách) gửi tới dịch vụ LLM bên ngoài, nhận về bản tóm tắt có cấu trúc kèm gợi ý việc cần chú ý. Bản tóm tắt luôn kèm thời điểm dữ liệu và nhãn "tham khảo"; AI không tự sửa dữ liệu hay quyết định nghiệp vụ. Khi API lỗi hoặc hết hạn mức, hệ thống hiển thị báo cáo mẫu dựng từ dữ liệu gốc.

**Phục vụ job:** quản lý — "cuối ca đọc một bản tóm tắt đáng tin thay vì tự tổng hợp từ nhiều màn hình".

**Phạm vi v1:** tạo tóm tắt theo ca/ngày theo yêu cầu; dữ liệu gửi AI chỉ là số liệu tổng hợp không định danh; hiển thị kèm thời điểm dữ liệu + nhãn tham khảo; kiểm tra đầu ra và giới hạn chi phí; fallback báo cáo mẫu khi AI lỗi.
**Chưa làm:** tự động theo lịch, hỏi-đáp tự do với AI, huấn luyện AI riêng, đa ngôn ngữ.

**Luồng chính:**
1) Quản lý chọn ca/ngày và bấm tạo tóm tắt.
2) Hệ thống tính số liệu tổng hợp từ dashboard + nhật ký.
3) Gọi dịch vụ LLM → nhận bản tóm tắt có cấu trúc.
4) Hiển thị kèm thời điểm dữ liệu và nhãn tham khảo; nếu lỗi → báo cáo mẫu từ dữ liệu gốc.

**Rủi ro chính:** AI bịa sự kiện không có trong dữ liệu → quản lý mất tin vào hệ thống. · **Đo thành công:** ≥18/20 tình huống thử nghiệm đúng số liệu, không thêm sự kiện, nêu đúng việc cần chú ý; 100% ca API lỗi/hết hạn mức rơi về báo cáo mẫu.
**OQ riêng:** —

## 8. Success Metrics

| Vai trò | Chỉ số | Baseline | Target | Mốc thời gian |
|---|---|---|---|---|
| North Star | % thay đổi trạng thái phòng hiển thị đúng trên thiết bị khác trong ≤3 giây | 0% — hiện cập nhật thủ công qua lễ tân, trễ hàng chục phút | ≥95% trong 100 lượt (50 phòng, 30 phiên đồng thời) | 02/11/2026 |
| Input | % kịch bản nghiệp vụ bắt buộc pass trên Flutter Web + Android | — | 100% | 02/11/2026 |
| Input | Chỉ số dashboard khớp dữ liệu đối soát | — | 100% | 02/11/2026 |
| Input | AI tóm tắt đúng (số liệu đúng, không bịa sự kiện, nêu đúng việc cần chú ý) | — | ≥18/20 tình huống | 02/11/2026 |
| Input | Web truy cập qua HTTPS trên VPS + APK cài và chạy trên Android thử | — | Đạt | 02/11/2026 |
| Guardrail | Số lỗi chặn luồng hoặc lỗi nghiêm trọng còn mở | — | 0 | liên tục |
| Guardrail | Tỷ lệ cập nhật sai do xung đột ghi đè | — | 0% | liên tục |

**Mốc tiến độ** (dự án 8 tuần nên dùng mốc sprint thay 3/6/12 tháng): Sprint 1 (21/09) khung ứng dụng + phân quyền + danh mục phòng + kiểm chứng đồng bộ realtime → Sprint 2 (05/10) luồng vận hành chạy end-to-end (nhận/trả → dọn → sửa) → Sprint 3 (19/10) dashboard + cảnh báo quá hạn + đánh giá AI → Sprint 4 (02/11) kiểm thử, sửa lỗi, nghiệm thu và bàn giao.

## 9. Constraints

- **Ngân sách / timeline / team:** 8 tuần (08/09–02/11/2026), 4 sprint × 2 tuần; bàn giao 27/10, nghiệm thu 02/11 (D-17); team WPCTeam 3 người, 530h theo WBS baseline; dự toán 30.000.000 VNĐ đã được GV duyệt (D-04), gồm nhân công quy đổi, VPS/tên miền, API OpenAI ≤300.000 VNĐ và dự phòng; sprint 4 dành chủ yếu cho sửa lỗi và bàn giao.
- **Ràng buộc tích hợp (chỉ tên hệ thống):** dịch vụ LLM bên ngoài (vd OpenAI/Google AI) cho `ai-ops-summary` — chỉ gửi số liệu tổng hợp không định danh khách; VPS Linux + tên miền demo phục vụ bản web.
- **Ràng buộc pháp lý / vùng / compliance:** 1 khách sạn giả định 50 phòng, dữ liệu giả lập, tiếng Việt; nghiệm thu trên Flutter Web + Android (iOS mở rộng); không dùng dữ liệu khách thật.

## 10. Risks & Assumptions

| Rủi ro / Giả định | Loại | Tầm quan trọng | Evidence | Khả năng | Hậu quả | Cách phòng |
|---|---|---|---|---|---|---|
| Phát sinh tính năng hoặc thiếu thời gian trong 8 tuần | viability | Cao | Tín hiệu gián tiếp (kế hoạch chặt, team 3 người) | Thường | Trễ nghiệm thu, feature bỏ dở | Đóng phạm vi cuối sprint 1, ưu tiên luồng chính, sprint 4 chỉ sửa lỗi và bàn giao |
| Hai người sửa cùng lúc hoặc mất mạng → ghi đè trạng thái | feasibility | Cao | Giả định | Thỉnh thoảng | Trạng thái phòng sai → nhận nhầm phòng, dashboard sai | Kiểm tra phiên bản trước khi ghi; mất mạng khóa thao tác ghi; kết nối lại tải trạng thái mới |
| AI tóm tắt sai hoặc vượt chi phí | feasibility | Vừa | Giả định | Thỉnh thoảng | Quản lý mất tin vào tóm tắt; vượt ngân sách API 300.000 VNĐ | Xác thực đầu ra, đặt hạn mức API, fallback báo cáo mẫu; AI chỉ tham khảo, không tự sửa dữ liệu |
| Nghiệp vụ giả lập lệch so với khách sạn thật | value | Vừa | Giả định | Thường | Demo đẹp nhưng luồng nghiệp vụ không sát thực tế | Ghi rõ giới hạn xác thực thực tế; dùng bộ kịch bản giả lập thống nhất xuyên suốt |
| Nhân viên không chịu cập nhật → dữ liệu lại rời rạc | value | Cao | Giả định | Thỉnh thoảng | Dashboard sai, mất giá trị cốt lõi của sản phẩm | Thao tác cập nhật tối giản trên mobile; các kịch bản nghiệm thu bắt buộc phủ đủ vai trò |

## 11. Open Questions

- [ ] OQ-1: Ngưỡng thời gian để một việc dọn/bảo trì bị tính là "quá hạn" (theo loại việc? theo ca?) — quyết khi `/brainstorm housekeeping`, `maintenance`, `room-dashboard`.
- [x] OQ-2: Ai xác nhận phòng "sẵn sàng" sau khi nhân viên báo dọn xong — nhân viên tự xác nhận hay lễ tân/quản lý duyệt — quyết khi `/brainstorm housekeeping`. ✅ Resolved 2026-09-17: chỉ quản lý xác nhận (BR-housekeeping-001, FR-housekeeping-005/006).
- [ ] OQ-3: Việc dọn/bảo trì được giao bằng cách chỉ định (quản lý/lễ tân chọn người) hay nhân viên tự nhận — quyết khi `/brainstorm housekeeping`, `maintenance`.
  - **Trạng thái từng phía (giữ OQ mở ở product):**
    - `housekeeping`: đã chốt hướng MVP — hệ thống tự phân công tới cá nhân; quản lý xác nhận sẵn sàng (BR-housekeeping-001). Phân công lại thủ công = P1.
    - `maintenance`: vẫn phụ thuộc maintenance OQ-2 — "tự nhận" đang là assumption chưa chốt (urd + brainstorm); chưa cascade đóng product OQ-3.
- [x] OQ-4: Thông tin khách tối thiểu cần ghi khi nhận phòng — ✅ Resolved 2026-09-25 (chốt nhóm): tên khách + số người.
