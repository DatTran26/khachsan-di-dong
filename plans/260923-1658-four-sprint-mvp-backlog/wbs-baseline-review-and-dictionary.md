---
title: "Rà soát WBS baseline và từ điển WBS"
status: pending-approval
source: "Project Charter v1.0, 2026-09-29"
effort: "530h"
---

# Rà soát WBS baseline và từ điển WBS

## Kết quả rà soát

WBS baseline ở đây dùng **gói công việc** làm đơn vị kiểm soát. Mỗi gói có một sản phẩm bàn giao có thể nghiệm thu; các hoạt động 1–7 giờ trong [WBS 4 sprint chi tiết](./detailed-task-breakdown.md) là work activity để lập lịch và giao việc, không phải work package để kiểm tra quy tắc 8/80.

- **Quy tắc 100%:** chín gói dưới đây bao phủ toàn bộ phạm vi trong Charter: khởi tạo/yêu cầu, thiết kế, nền tảng, đồng bộ realtime, vận hành phòng, dashboard, AI, QA/UAT và bàn giao. Không gói nào bao gồm các hạng mục ngoài phạm vi như iOS, thanh toán, OTA/PMS/IoT, đa khách sạn hoặc AI hỏi-đáp tự do.
- **Quy tắc 8/80:** mọi gói công việc ở tầng này nằm trong khoảng 40–80 giờ. Nếu một gói vượt 80 giờ khi tái ước lượng, PM phải tách nó thành các gói có sản phẩm bàn giao riêng; nếu dưới 8 giờ thì quản lý như activity dưới gói cha.
- **Đối soát effort:** tổng WBS là **530 giờ**, khớp OBJ-7 và ràng buộc C-2 của Project Charter. Nó cao hơn capacity tham chiếu 480 giờ của backlog cũ 50 giờ; đây là rủi ro nguồn lực cần xử lý, không được che bằng cách giảm tổng effort.

## WBS baseline

| Mã WBS | Tên | Sản phẩm bàn giao | Ước lượng giờ công |
|---|---|---|---:|
| 1.1 | Khởi động và baseline yêu cầu | Charter được phê duyệt, PRD/BRD/URD/SRS, decision log, scope baseline và tiêu chí nghiệm thu | 80h |
| 1.2 | Thiết kế giải pháp và trải nghiệm | Kiến trúc, ERD, state/flow, API contract, design token, wireframe và ma trận quyền | 64h |
| 1.3 | Nền tảng ứng dụng, bảo mật và danh mục phòng | API và Flutter Web/Android chạy được; auth/RBAC, dữ liệu 50 phòng, danh mục phòng và quality gate nền tảng | 80h |
| 1.4 | Đồng bộ realtime và toàn vẹn trạng thái | Luồng lưu-kiểm quyền-audit-phát sự kiện, optimistic locking, offline khóa ghi và bằng chứng hai client | 48h |
| 1.5 | Vận hành lưu trú, dọn phòng, bảo trì và audit | Luồng nhận/trả phòng, tự phân công, xác nhận sạch, báo/sửa hỏng, audit log và kịch bản E2E | 80h |
| 1.6 | Dashboard và cảnh báo vận hành | Dashboard 50 phòng, sáu chỉ số, bộ lọc, cảnh báo quá hạn và đối soát fixture | 40h |
| 1.7 | AI tóm tắt vận hành an toàn | Tóm tắt theo kỳ không PII, kiểm soát timeout/chi phí, fallback, lưu bản mới nhất và bộ đánh giá 20 tình huống | 40h |
| 1.8 | Kiểm thử tích hợp, tương thích và UAT | Kết quả regression Web/Android, kiểm thử tải realtime 30 phiên, accessibility, log lỗi và UAT pass/fail | 48h |
| 1.9 | Phát hành và bàn giao | CI xanh, web HTTPS, APK Android, runbook deploy/rollback, script nghiệm thu và hồ sơ bàn giao | 50h |
| **1.0** | **MVP Khách Sạn Di Động** | **Bản demo nghiệm thu ngày 27/10/2026** | **530h** |

## Từ điển WBS — ba gói trọng yếu

Ba gói dưới đây được chọn vì quyết định trực tiếp North Star realtime, luồng nghiệp vụ cốt lõi và khả năng bàn giao đúng hạn.

### 1.4 — Đồng bộ realtime và toàn vẹn trạng thái

| Thuộc tính | Nội dung |
|---|---|
| Mục tiêu | Bảo đảm mọi thay đổi trạng thái phòng được lưu và kiểm soát trước khi phát đến client khác; ngăn ghi đè khi có xung đột. |
| Phạm vi bao gồm | Xác thực kết nối realtime; phát sự kiện sau commit; phiên bản/optimistic locking; xử lý conflict; khóa thao tác ghi khi offline; tải lại trạng thái khi kết nối lại; đo cập nhật liên thiết bị. |
| Sản phẩm bàn giao | API/event contract realtime, client realtime, cơ chế conflict/offline và báo cáo kiểm chứng 100 lượt cập nhật với 50 phòng, 30 phiên đồng thời. |
| Tiêu chí chấp nhận | Ít nhất 95/100 cập nhật hiển thị trên thiết bị khác không quá 3 giây; không có ghi đè do xung đột; offline không phát sinh lệnh ghi. |
| Không bao gồm | Hàng đợi ghi offline, đồng bộ nền iOS, tích hợp IoT hoặc mở rộng vượt 30 phiên. |
| Phụ thuộc | 1.2 cung cấp contract và state model; 1.3 cung cấp auth, database, room catalog và hai client chạy được. |
| Chủ sở hữu đề xuất | Ngọc Hoàng triển khai backend/mobile; Tấn Đạt duyệt contract và bằng chứng; Bảo kiểm thử UI/QA. |
| Ước lượng | 48h; nằm trong quy tắc 8/80. |

### 1.5 — Vận hành lưu trú, dọn phòng, bảo trì và audit

| Thuộc tính | Nội dung |
|---|---|
| Mục tiêu | Số hóa đầy đủ vòng đời phòng để lễ tân, nhân viên hiện trường và quản lý cùng làm việc trên một nguồn trạng thái. |
| Phạm vi bao gồm | Điều kiện nhận phòng; trả phòng tự tạo việc dọn; tự phân công người đang trực ít việc mở nhất; nhận/từ chối/hoàn tất/xác nhận sạch; báo hỏng, ngừng phục vụ, mở lại; audit ai/khi nào/trước-sau; kịch bản E2E. |
| Sản phẩm bàn giao | Migration và API nghiệp vụ, màn hình Web/Android cho các vai trò, audit log tra cứu được, bộ kiểm thử transaction/RBAC/idempotency và 10 kịch bản E2E. |
| Tiêu chí chấp nhận | Một phòng hoàn thành check-in → check-out → dọn → quản lý xác nhận → check-in lại; báo hỏng chặn check-in; mọi thao tác ghi có audit và event sau commit. |
| Không bao gồm | Đặt trước, thanh toán, đổi phòng, checklist/ảnh dọn, ưu tiên/chi phí/bảo trì định kỳ và phân công lại thủ công. |
| Phụ thuộc | 1.2 chốt state/rule; 1.3 bảo đảm auth, catalog và RBAC; 1.4 cung cấp phát sự kiện và bảo vệ xung đột. |
| Chủ sở hữu đề xuất | Ngọc Hoàng triển khai API/DB; Bảo triển khai UI/QA; Tấn Đạt chốt rule và nghiệm thu. |
| Ước lượng | 80h; ở ngưỡng trên của quy tắc 8/80. Mọi phát sinh phải được tách thành một gói riêng thay vì cộng dồn. |

### 1.9 — Phát hành và bàn giao

| Thuộc tính | Nội dung |
|---|---|
| Mục tiêu | Tạo bản demo có thể cài, truy cập và nghiệm thu độc lập vào ngày 27/10/2026. |
| Phạm vi bao gồm | Đóng băng phạm vi và triage; security review; CI; deploy HTTPS lên VPS; build/cài APK; diễn tập migration, backup/rollback và smoke test; script nghiệm thu; hồ sơ kiến trúc/ERD/API/cách chạy/giới hạn. |
| Sản phẩm bàn giao | URL web HTTPS, APK Android đã thử cài, CI xanh, runbook deploy/rollback, biên bản kiểm thử/UAT, script nghiệm thu và handover pack. |
| Tiêu chí chấp nhận | Không còn blocker/critical; luồng bắt buộc pass trên Web và Android; web HTTPS và APK chạy với dữ liệu demo reset được; đủ runbook, CI và hồ sơ để sponsor nghiệm thu. |
| Không bao gồm | Vận hành sau nghiệm thu, phát hành Play Store/App Store, SLA sản xuất hoặc mở rộng hạ tầng đa môi trường. |
| Phụ thuộc | Hoàn thành tối thiểu 1.3–1.8 và có VPS/domain theo C-8 của Charter. |
| Chủ sở hữu đề xuất | Tấn Đạt điều phối release/DevOps; Ngọc Hoàng phụ trách backend, migration và APK; Bảo phụ trách regression/UAT và evidence. |
| Ước lượng | 50h; nằm trong quy tắc 8/80. |

## Câu hỏi còn mở

1. Nhóm cần chốt phương án hấp thụ chênh lệch 50h so với capacity tham chiếu 480h: tái phân bổ, tăng capacity có phê duyệt hoặc giảm phạm vi theo quy trình thay đổi.
2. WBS chi tiết hiện có vẫn ghi kiểm chứng tải với 10 phiên ở một số activity; cần cập nhật thành 30 phiên để khớp Charter trước khi lập baseline lịch chính thức.
