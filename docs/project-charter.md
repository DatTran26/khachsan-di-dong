---
type: project-charter
status: draft — chờ GV. Nguyễn Hữu Trung ký duyệt
version: 1.0
updated: 2026-09-29
links:
  - "[[docs/_product/prd.md|Product PRD (updated 2026-09-29)]]"
  - "[[project-profile.md|Project Profile (updated 2026-09-29)]]"
  - "[[docs/features/ai-ops-summary/ai-ops-summary-urd.md|URD ai-ops-summary (updated 2026-09-29)]]"
  - "KhachSanSach.xlsx — WBS baseline MS Project"
---

# Project Charter — WPCTeam_KhachSanDiDong

**Tài liệu đầu vào:** `prd.md` (2026-09-29, gồm Decision Log D-01 → D-16), `project-profile.md` (2026-09-29), `ai-ops-summary-urd.md` (2026-09-29), WBS baseline `KhachSanSach.xlsx`, Resource Sheet MS Project, các quyết định WPCTeam xác nhận trong chat ngày 29/09/2026.

**Quy ước nhãn:** **(XN)** đã xác nhận · **(SL)** suy luận · **(GĐ)** giả định · **(KN)** khuyến nghị.

---

## 1. Mục đích dự án

**Vấn đề (XN):** trạng thái phòng trên 3 trục — lưu trú, vệ sinh, bảo trì — đang được cập nhật rời rạc. Chỉ lễ tân nhập liệu tại quầy; buồng phòng và bảo trì báo miệng hoặc gọi điện để lễ tân nhập lại sau, nên cập nhật bị trễ, bị sót và không ai chắc trạng thái phòng tại một thời điểm.

**Mục đích (XN):** xây dựng MVP phần mềm theo dõi trạng thái 50 phòng của 1 khách sạn giả định theo thời gian thực, chạy trên Flutter Web và Android. Mọi vai trò cùng nhìn và cập nhật một nguồn trạng thái duy nhất; lễ tân không còn nhập hộ; quản lý có dashboard, cảnh báo quá hạn theo quy tắc và bản tóm tắt vận hành do AI tạo (chỉ để tham khảo).

**Bối cảnh (XN):** đồ án môn học của WPCTeam, thực hiện 08/09–27/10/2026 (~7 tuần). Không có mục tiêu kinh doanh.

---

## 2. Mục tiêu SMART

Hạn chung cho mọi mục tiêu: **27/10/2026** (D-01).

| Mã | Mục tiêu (S) | Đo lường (M) | Khả thi / Liên quan (A/R) | Nguồn |
|---|---|---|---|---|
| OBJ-1 | Hoàn thành 9 feature mức Must | 100% kịch bản nghiệp vụ bắt buộc pass trên Flutter Web và Android | Cả 9 feature đã có task trong WBS | PRD mục 7, 8 |
| OBJ-2 | Đồng bộ realtime (North Star) | ≥95% trong 100 lượt cập nhật hiển thị trên thiết bị khác ≤3 giây, với 50 phòng và **30 phiên đồng thời**; 0 ca ghi đè do xung đột | Giá trị cốt lõi của sản phẩm; cần công cụ tạo tải cho 30 phiên | PRD mục 7.6, 8; D-13 |
| OBJ-3 | Dashboard đúng dữ liệu | 100% chỉ số khớp dữ liệu đối soát (fixture 50 phòng) | Ngưỡng quá hạn đã chốt (D-14) | PRD mục 7.7, 8 |
| OBJ-4 | AI tóm tắt đáng tin và an toàn | ≥18/20 tình huống đúng; 100% ca lỗi, quá 15 giây hoặc chạm trần chi phí rơi về báo cáo mẫu; 0 payload chứa thông tin định danh khách | OpenAI, timeout 15 giây, trần 300.000 VNĐ | PRD mục 7.9; URD mục 9; D-05, D-06 |
| OBJ-5 | Triển khai được bản demo | Web chạy HTTPS trên VPS; APK cài và chạy trên máy Android thử | VPS và domain đã có trong ngân sách Sprint 4 | PRD mục 8; D-08 |
| OBJ-6 | Chất lượng bàn giao | 0 lỗi chặn luồng hoặc lỗi nghiêm trọng còn mở khi nghiệm thu | Sprint 4 dành chủ yếu cho sửa lỗi | PRD mục 8 |
| OBJ-7 | Kiểm soát nguồn lực | Tổng chi ≤30.000.000 VNĐ (baseline 24.920.000 + API ≤300.000 + dự phòng 4.780.000); nỗ lực theo WBS 530h | Dự toán đã được GV duyệt | D-04 |

---

## 3. Phạm vi

### 3.1 Trong phạm vi (XN)

| Feature | Phạm vi v1 |
|---|---|
| `auth-roles` | Đăng nhập/đăng xuất; 3 vai trò: quản lý, lễ tân, nv buồng phòng–bảo trì (gộp); tạo/khóa tài khoản và gán vai trò; kiểm quyền server-side cho mọi thao tác ghi; mật khẩu lưu an toàn |
| `room-catalog` | 50 phòng giả lập (số phòng, tầng, loại); **chỉ quản lý CRUD**, các vai trò khác chỉ xem (D-10); mỗi phòng có 3 trục trạng thái riêng |
| `check-in-out` | Nhận phòng chỉ khi phòng trống, sạch và đang phục vụ; trả phòng tự tạo việc dọn; thông tin khách: tên và số người |
| `housekeeping` | Tạo việc tự động hoặc thủ công; **hệ thống tự phân công** cho người đang trực có ít việc mở nhất; nhân viên nhận/từ chối/hoàn tất; từ chối thì gán người kế tiếp, hết người thì vào hàng chờ quản lý (D-09, D-15); **chỉ quản lý xác nhận sạch** (D-11); quá hạn sau 60 phút (D-14) |
| `maintenance` | Mọi vai trò báo hỏng; báo hỏng tự chuyển phòng sang ngừng phục vụ; hệ thống tự phân công; nhân viên bảo trì nhận, hoàn tất và **mở lại phục vụ**; quản lý đặt ngừng phục vụ thủ công (D-12); quá hạn sau 4 giờ (D-14); sửa xong không tự chuyển "cần dọn" (D-16) |
| `realtime-sync` | Lưu rồi mới phát sự kiện, ≤3 giây; kiểm tra phiên bản chống ghi đè; offline thì khóa ghi, có mạng lại thì tải trạng thái mới |
| `room-dashboard` | Lưới 50 phòng realtime; 6 chỉ số tại thời điểm xem; lọc theo tầng/trạng thái; cảnh báo quá hạn theo quy tắc, quét mỗi 1 phút |
| `audit-log` | Tự ghi ai / khi nào / trạng thái trước → sau cho mọi thao tác ghi; xem theo phòng; lọc thời gian và người thao tác |
| `ai-ops-summary` | Quản lý tạo tóm tắt theo ca/ngày; chỉ gửi số liệu tổng hợp không định danh tới OpenAI; nhãn "tham khảo" và thời điểm dữ liệu; timeout 15 giây; trần 300.000 VNĐ; lưu bản mới nhất theo kỳ; fallback báo cáo mẫu; chỉ trên web |

**Sản phẩm bàn giao (XN, theo WBS task 162, 178):** web HTTPS, APK Android, CI xanh, runbook deploy/rollback, hồ sơ bàn giao (kiến trúc, ERD, API, cách chạy), script nghiệm thu.

### 3.2 Ngoài phạm vi (XN)

- **Nền tảng:** phát hành App Store/Play; iOS chỉ là mục tiêu mở rộng.
- **Nghiệp vụ:** đặt phòng trước, thanh toán, kế toán, giá phòng, phụ thu, đổi phòng giữa kỳ, kho vật tư, chi phí sửa chữa, bảo trì định kỳ, mức ưu tiên hỏng, checklist dọn, ảnh bằng chứng.
- **Tích hợp:** OTA, PMS, IoT.
- **AI và phân tích:** dự báo doanh thu, tóm tắt tự động theo lịch, hỏi-đáp tự do, huấn luyện AI riêng, xuất/chia sẻ bản tóm tắt.
- **Quy mô:** đa khách sạn, đa ngôn ngữ, dữ liệu khách thật.
- **Tài khoản:** quên mật khẩu, SSO, tự đổi mật khẩu, tách vai trò buồng phòng và bảo trì.
- **Khác:** hàng đợi ghi offline, export nhật ký, lưu trữ dài hạn, phân công lại thủ công (P1).

---

## 4. Bên liên quan và vai trò

| Bên liên quan | Vai trò | Ảnh hưởng / Quan tâm | Nguồn |
|---|---|---|---|
| GV. Nguyễn Hữu Trung | Nhà tài trợ (sponsor): phê duyệt charter, phạm vi, ngân sách. Khách hàng nghiệm thu ngày 27/10/2026 | Cao / Cao | D-03 |
| Tấn Đạt | PO, BA, PM, Tech Lead, DevOps (vận hành VPS) | Cao / Cao | XN |
| Ngọc Hoàng | Backend, Mobile | Cao / Cao | XN |
| Bảo | UI/UX, Frontend, QA | Cao / Cao | XN |
| Quản lý (persona) | Dashboard, nhật ký, AI, tài khoản; duy nhất được CRUD phòng, xác nhận sạch, đặt ngừng phục vụ thủ công | Người dùng giả lập | D-10, D-11, D-12 |
| Lễ tân (persona) | Nhận/trả phòng; quản lý tài khoản nhân viên thường; xem danh mục phòng; báo hỏng | Người dùng giả lập | D-10 → D-12 |
| Nv buồng phòng–bảo trì (persona) | Nhận/từ chối việc được phân công; báo hỏng; báo hoàn tất; mở lại phục vụ sau khi sửa | Người dùng giả lập | D-09, D-12 |
| Khách lưu trú | Không dùng hệ thống; chỉ là dữ liệu giả lập | — | XN |

**Nhận xét (SL):** Tấn Đạt kiêm 5 vai trò, là điểm nghẽn đơn lẻ cho quyết định phạm vi và vận hành VPS. Bảo vừa làm frontend vừa làm QA.
**(KN):** Lập ma trận RACI; Ngọc Hoàng kiểm thử chéo frontend; chỉ định người dự phòng cho DevOps trước Sprint 4.

---

## 5. Mốc chính

Nguồn: WBS baseline `KhachSanSach.xlsx`. Các sprint **được phép chồng lấn** (D-02).

| Mốc | Khoảng thời gian | Cổng / kết quả bàn giao | Trạng thái |
|---|---|---|---|
| Khởi động | 08/09/2026 | Sponsor, stakeholder, chốt MVP (task 31) | (XN) |
| Sprint 1 — Nền tảng | 08/09 → 28/09/2026 | Cổng 28/09: quản lý đăng nhập, sửa phòng, seed 50 phòng, RBAC chặn ghi, realtime hai client | Chờ nhóm xác thực |
| Sprint 2 — Vận hành | 17/09 → 09/10/2026 | Cổng 09/10: nhận/trả, dọn, xác nhận, báo hỏng chặn nhận phòng, audit sau commit | Chờ nhóm xác thực |
| Sprint 3 — Dashboard và AI | 21/09 → 16/10/2026 | Cổng 16/10: dashboard khớp fixture, AI không gửi PII, fallback 15 giây, trần 300.000 VNĐ | Chưa đến |
| Sprint 4 — Bàn giao | 15/10 → 27/10/2026 | Đóng băng phạm vi 15/10; UAT 25–26/10 | Chưa đến |
| **Bàn giao chính thức** | **27/10/2026** | Web HTTPS, APK, CI xanh, runbook rollback, hồ sơ bàn giao | Chưa đến |

**Nhận xét (SL):** Hạn mới 27/10 sớm hơn mốc 02/11 cũ 6 ngày, nên không còn khoảng đệm sau bàn giao. Mọi trễ ở cổng Sprint 3 (16/10) sẽ lấn trực tiếp vào thời gian UAT.

---

## 6. Ngân sách tổng

Nguồn: Resource Sheet và WBS baseline MS Project; dự toán đã được GV duyệt (D-04).

| Hạng mục | Công thức | Thành tiền (VNĐ) |
|---|---|---|
| Nhân công — Tấn Đạt | 145h × 50.000 | 7.250.000 |
| Nhân công — Ngọc Hoàng | 222h × 45.000 | 9.990.000 |
| Nhân công — Bảo | 163h × 40.000 | 6.520.000 |
| Phụ cấp tăng ca | 2 × 400.000 | 800.000 |
| VPS (Sprint 4, nhóm tự vận hành) | 1 × 200.000 | 200.000 |
| Domain (Sprint 4) | 1 × 160.000 | 160.000 |
| **Baseline MS Project** | | **24.920.000** |
| OpenAI API (trần) | | 300.000 |
| Dự phòng (15,9%) | 30.000.000 − 25.220.000 | 4.780.000 |
| **Tổng dự toán đã duyệt** | | **30.000.000** |

**Giả định tính:**
- Chi phí nhân công = Scheduled_Work × Std. Rate. Ovt. Rate chưa dùng vì WBS không có giờ tăng ca.
- Task 177 chia 14h cho Đạt và 6h cho Bảo, khớp với cách MS Project tính.
- VPS và Domain chỉ tính 1 lần cho Sprint 4.

**Rủi ro chi phí (SL):** Nếu phần quá tải 62h của Hoàng phải trả theo Ovt. Rate thì phát sinh 62 × 47.000 = 2.914.000 VNĐ, tương đương khoảng 61% quỹ dự phòng.

---

## 7. Giả định và ràng buộc

### 7.1 Ràng buộc (XN)

| Mã | Ràng buộc |
|---|---|
| C-1 | Hạn bàn giao cứng 27/10/2026; 4 sprint được phép chồng lấn |
| C-2 | 3 người; nỗ lực theo WBS 530h (Đạt 145h, Hoàng 222h, Bảo 163h) |
| C-3 | Tổng chi ≤30.000.000 VNĐ; API OpenAI ≤300.000 VNĐ |
| C-4 | Nghiệm thu trên Flutter Web và Android; iOS không bắt buộc |
| C-5 | 1 khách sạn, 50 phòng, dữ liệu giả lập, tiếng Việt |
| C-6 | OpenAI (Responses API) chỉ nhận số liệu tổng hợp không định danh; timeout 15 giây; AI không được ghi hay sửa dữ liệu nghiệp vụ |
| C-7 | Mọi thao tác ghi đều kiểm quyền server-side và ghi nhật ký |
| C-8 | VPS Linux do nhóm tự cài đặt và vận hành, có domain và HTTPS, thuê trong Sprint 4 |

### 7.2 Giả định

| Mã | Giả định | Hậu quả nếu sai | Trạng thái |
|---|---|---|---|
| A-1 | Cả 3 thành viên duy trì được năng lực đều đặn tới 27/10 | Hụt năng lực, phải cắt phạm vi | (GĐ) |
| A-2 | 530h theo WBS là đủ và phân bổ lại được phần quá tải của Hoàng (222h so với tham chiếu 160h) | Trễ cổng Sprint 2–3; phát sinh tăng ca | (GĐ) Rủi ro cao |
| A-3 | OpenAI trả được đầu ra có cấu trúc ổn định | Khó kiểm tra và hiển thị thống nhất | (GĐ) |
| A-4 | Kịch bản giả lập đủ sát khách sạn thật | Demo đẹp nhưng nghiệp vụ không thực tế | (GĐ) |
| A-5 | Nhân viên chịu tự cập nhật trên mobile | Mất giá trị cốt lõi | (GĐ) Khó kiểm chứng trong demo |
| A-6 | Tạo được tải 30 phiên đồng thời để đo North Star | Không chứng minh được OBJ-2 | (GĐ) WBS task 165 chưa cập nhật lên 30 phiên |
| A-7 | Ngưỡng 60 phút / 4 giờ phù hợp vận hành | Cảnh báo quá nhiều hoặc quá ít | (GĐ) Chưa kiểm chứng với khách sạn thật; ngưỡng cấu hình được |

---

## 8. Tiêu chí thành công

Tất cả được đo tại buổi nghiệm thu ngày 27/10/2026, do GV. Nguyễn Hữu Trung nghiệm thu.

| Loại | Tiêu chí | Ngưỡng |
|---|---|---|
| North Star | Thay đổi trạng thái hiển thị trên thiết bị khác ≤3 giây | ≥95% trong 100 lượt; 50 phòng; 30 phiên đồng thời |
| Chức năng | Kịch bản nghiệp vụ bắt buộc pass trên Web và Android | 100% |
| Chức năng | Chặn nhận phòng khi phòng chưa đủ điều kiện (kể cả đang ngừng phục vụ) | 100% |
| Chức năng | Trả phòng tự tạo và tự phân công việc dọn | 100% |
| Chức năng | Kiểm quyền server-side; không có hành động vượt quyền | 100%; 0 |
| Chức năng | Mọi thay đổi trạng thái có bản ghi ai / khi nào / trước → sau | 100% |
| Dữ liệu | Chỉ số dashboard khớp đối soát, kể cả số việc quá hạn | 100% |
| AI | Tóm tắt đúng số liệu, không bịa, nêu đúng việc cần chú ý | ≥18/20 |
| AI | Rơi về báo cáo mẫu khi lỗi, quá 15 giây hoặc chạm trần | 100% |
| AI | Payload chứa thông tin định danh khách | 0 |
| Triển khai | Web HTTPS trên VPS; APK chạy trên Android thử | Đạt |
| Guardrail | Lỗi chặn luồng hoặc nghiêm trọng còn mở | 0 |
| Guardrail | Cập nhật sai do xung đột ghi đè | 0% |
| Nguồn lực | Tổng chi | ≤30.000.000 VNĐ |

---

## 9. Decision Log

Chi tiết từng quyết định xem `prd.md` mục 12.

| ID | Quyết định |
|---|---|
| D-01 | Hạn bàn giao 27/10/2026 (thay 02/11/2026) |
| D-02 | Sprint được phép chồng lấn |
| D-03 | Sponsor và người nghiệm thu: GV. Nguyễn Hữu Trung |
| D-04 | Dự toán 30.000.000 VNĐ đã duyệt; dự phòng 4.780.000 VNĐ là đủ |
| D-05 | Nhà cung cấp LLM: OpenAI |
| D-06 | AI: timeout 15 giây, trần 300.000 VNĐ |
| D-07 | Lưu bản tóm tắt mới nhất theo kỳ |
| D-08 | VPS nhóm tự vận hành 200.000 VNĐ; có HTTPS |
| D-09 | Dọn và bảo trì do hệ thống tự phân công; nhân viên nhận/từ chối |
| D-10 | Chỉ quản lý CRUD danh mục phòng |
| D-11 | Chỉ quản lý xác nhận phòng sạch |
| D-12 | Báo hỏng tự chuyển ngừng phục vụ; nhân viên bảo trì mở lại; quản lý đặt thủ công |
| D-13 | North Star nghiệm thu với 30 phiên |
| D-14 | Quá hạn: dọn 60 phút, bảo trì 4 giờ, tính từ lúc tạo; quét mỗi 1 phút |
| D-15 | Từ chối → gán người kế tiếp; hết người → hàng chờ quản lý |
| D-16 | Sửa xong không tự chuyển "cần dọn" |

---

## 10. Nhóm phản biện

**Đã kiểm tra:**
- Mọi câu hỏi mở cấp product trong PRD đã đóng (OQ-1 → OQ-12).
- Ngân sách tái tạo được từ Resource Sheet, khớp 24.920.000 VNĐ.
- Mốc 27/10 thống nhất giữa PRD, URD, WBS và charter.
- Phân quyền thống nhất giữa PRD và project-profile.

**Còn mở:**

| # | Việc còn mở | Người đề xuất phụ trách (KN) |
|---|---|---|
| 1 | URD ai-ops-summary OQ-1: khung giờ "ca" chưa định nghĩa. Màn chọn kỳ (WBS task 148) bắt đầu 09/10 | Tấn Đạt |
| 2 | Xác thực trạng thái thực tế của cổng Sprint 1 (28/09) và tiến độ Sprint 2 | Tấn Đạt |
| 3 | Sửa WBS task 165 từ 10 lên 30 phiên và ước lượng lại giờ công | Ngọc Hoàng |
| 4 | Cascade D-09 sang URD maintenance (đóng maintenance OQ-2) | Tấn Đạt |
| 5 | Phân bổ lại phần quá tải 62h của Hoàng | Tấn Đạt |
| 6 | Bổ sung file "Tôn chỉ dự án" vào Knowledge, vì URD tham chiếu file này | Tấn Đạt |

**Câu hỏi quyết định:**
1. Khung giờ ca cho tóm tắt AI là bao nhiêu ca, bắt đầu và kết thúc lúc mấy giờ?
2. Nhóm chuyển phần việc nào của Hoàng sang Đạt hoặc Bảo?

---

## 11. Phê duyệt

| Vai trò | Họ tên | Ngày | Chữ ký |
|---|---|---|---|
| Nhà tài trợ / Khách hàng nghiệm thu | GV. Nguyễn Hữu Trung | | |
| PO / PM | Tấn Đạt | | |
