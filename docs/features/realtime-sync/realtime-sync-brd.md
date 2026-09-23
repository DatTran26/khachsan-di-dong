---
type: brd
feature: realtime-sync
status: draft
updated: 2026-09-23
links:
  - "[[docs/features/realtime-sync/realtime-sync-urd.md|Realtime-sync URD]]"
  - "[[docs/features/realtime-sync/brainstorms/co-che-dong-bo-realtime.md|Brainstorm: Cơ chế đồng bộ thời gian thực]]"
  - "[[Ton_Chi_Du_An_WPCTeam.txt|Tôn chỉ dự án]]"
---

# realtime-sync — Business Requirements Document

## 1. Executive Summary

Giá trị cốt lõi của sản phẩm — một nguồn trạng thái phòng chung cho mọi vai trò và thiết bị — chỉ thành hiện thực nếu mọi thay đổi lan tới đúng và nhanh. Feature realtime-sync là cơ chế nền bảo đảm điều đó: lưu tại máy chủ trước rồi phát tới mọi thiết bị trong ≤3 giây, kiểm tra phiên bản để không ai ghi đè lẫn nhau, và khi mất mạng thì báo rõ + khóa ghi thay vì để thao tác mất lặng lẽ. Đây là điều kiện tiên quyết của mọi feature vận hành (nhận/trả phòng, dọn phòng, bảo trì, dashboard) và là nội dung được kiểm chứng ngay trong Sprint 1.

## 2. Business Problem & Context

### 2.1 Problem Statement

| ID | Business Condition | Baseline | Business Impact | Evidence |
|----|--------------------|----------|-----------------|----------|
| BP-realtime-sync-01 | Trạng thái phòng cập nhật rời rạc giữa các vai trò/thiết bị — lễ tân làm trung gian thủ công | Chưa có hệ thống | Sai lệch trạng thái → nhận nhầm phòng, sót việc, mất thời gian đối chiếu | Confirmed (tôn chỉ: vấn đề lõi của dự án) |
| BP-realtime-sync-02 | Hai người sửa cùng đối tượng có thể ghi đè lặng lẽ | Chưa có | Dữ liệu sai lan trên toàn hệ thống; không truy vết được đâu là đúng | Confirmed (PRD: rủi ro chính) |
| BP-realtime-sync-03 | Mất mạng tại hiện trường khiến thao tác mất lặng lẽ | Chưa có | Việc thật không được ghi; quầy thấy trạng thái cũ | Confirmed (PRD: mất mạng phải báo + khóa ghi) |

### 2.2 Opportunity & Why Now

`realtime-sync` thuộc nhóm "Nền tảng chung" và có mốc kiểm chứng ngay Sprint 1 (tới 21/09): "khung ứng dụng + phân quyền + danh mục phòng + kiểm chứng đồng bộ realtime". Nếu cơ chế này không đạt, toàn bộ Sprint 2 (luồng vận hành end-to-end) và Sprint 3 (dashboard realtime) không có nền — đây là dependency cứng, không phải cải tiến.

### 2.3 Strategic Alignment

Trực tiếp hiện thực hóa tôn chỉ: "dữ liệu thay đổi được đồng bộ thời gian thực giữa các thiết bị", "cập nhật trạng thái phải có kiểm tra phiên bản để tránh ghi đè", và giá trị cốt lõi "một nguồn sự thật — lễ tân không còn là trung gian thủ công".

## 3. Current State, Future State & Gap

### 3.1 Current State (AS-IS)

Mỗi vai trò cập nhật trên kênh riêng (giấy, điện thoại, bảng quầy); trạng thái hội tụ chậm qua lễ tân; khi hai người cập nhật cùng lúc không ai biết bản nào đúng; mất liên lạc thì việc đã làm không được ghi nhận.

### 3.2 Future State (TO-BE)

Mọi thay đổi ghi tại máy chủ rồi lan tới mọi thiết bị trong ≤3 giây; xung đột được chặn bằng kiểm tra phiên bản (ghi cũ bị từ chối, người ghi được báo và tải bản mới); mất kết nối được báo rõ và khóa ghi; kết nối lại tự động tải trạng thái mới.

### 3.3 Gap

| Gap | Mô tả | Ưu tiên |
|-----|-------|---------|
| G1 | Chưa có cơ chế "lưu trước — phát sau" thống nhất cho mọi thay đổi trạng thái | Cao |
| G2 | Chưa có kiểm tra phiên bản chống ghi đè | Cao |
| G3 | Chưa có phát hiện mất kết nối + khóa ghi + tự đồng bộ lại | Cao |
| G4 | Chưa có phương tiện đo độ trễ để nghiệm thu ≥95% ≤3s | Trung bình |

## 4. Stakeholders

| Stakeholder Role | Interest | Influence | Stakeholder Requirement / Expectation |
|------------------|----------|-----------|----------------------------------------|
| Mọi vai trò (lễ tân, nv buồng phòng–bảo trì, quản lý) | Màn hình luôn mới, thao tác không mất | Cao (người dùng cuối) | Cập nhật ≤3s; báo rõ khi offline; không ghi đè lẫn nhau |
| WPCTeam (dev) | Một cơ chế đồng bộ dùng chung, kiểm chứng được | Cao | Cơ chế đơn giản đủ cho 30 phiên; có số liệu đo nghiệm thu |
| Quản lý | Dashboard realtime đáng tin | Trung bình | Dữ liệu dashboard không trễ quá 3s so với thay đổi thật |
| Giảng viên hướng dẫn | Đánh giá theo tiêu chí môn học | Cao | Tiêu chí nghiệm thu đo được: ≥95% ≤3s, 0 ghi đè |

## 5. Business Objectives & Success Measures

| ID | Objective | Baseline | Target | Timeframe | Success Measure |
|----|-----------|----------|--------|-----------|-----------------|
| BO-realtime-sync-01 | Một nguồn sự thật realtime giữa các thiết bị | Chưa có | ≥95% trong 100 lượt cập nhật hiển thị trên thiết bị khác ≤3s (50 phòng, 30 phiên) | Nghiệm thu | Đo trực tiếp theo tiêu chí PRD |
| BO-realtime-sync-02 | Không mất dữ liệu do ghi đè | Chưa có | 0 ca ghi đè do xung đột phiên bản | Nghiệm thu | Kịch bản kiểm thử xung đột |
| BO-realtime-sync-03 | Không mất thao tác lặng lẽ khi mất mạng | Chưa có | 100% thời điểm offline có cảnh báo + khóa ghi; 100% reconnect tự tải trạng thái mới | Sprint 1–4 | Kiểm thử tắt/bật mạng |

## 6. Business Scope

### 6.1 In Scope

- Cơ chế nền dùng chung cho mọi thay đổi trạng thái: lưu tại máy chủ trước, phát sự kiện sau, lan tới thiết bị khác ≤3 giây.
- Kiểm tra phiên bản chống ghi đè + báo cho người bị từ chối.
- Phát hiện mất kết nối → báo trạng thái + khóa ghi; tự kết nối lại → tải trạng thái mới.
- Chỉ báo trạng thái kết nối thống nhất trên mọi màn hình; đo độ trễ phục vụ nghiệm thu.

### 6.2 Out of Scope

- Hàng đợi offline cho ghi, đồng bộ soạn dở, retry thông minh (PRD "chưa làm").
- Nghiệp vụ sinh sự kiện (`check-in-out`, `housekeeping`, `maintenance`, `room-dashboard`, `audit-log` — chỉ là đầu mối tiêu thụ).
- Quản lý phiên/xác thực (`auth-roles`); đồng bộ đa máy chủ/đa khách sạn.

### 6.3 Assumptions

- Một máy chủ duy nhất là nguồn sự thật; 30 phiên đồng thời là tải đỉnh.
- Kênh realtime của stack đã chọn (Socket.IO theo tôn chỉ) đáp ứng được mục tiêu.
- Mất kết nối vẫn cho xem dữ liệu cuối; chỉ khóa ghi.

### 6.4 Constraints

- MVP 8 tuần, nhóm 3 người; cơ chế phải kiểm chứng trong Sprint 1.
- Tiếng Việt; dữ liệu giả lập; không thiết kế quá mức cho tải lớn hơn quy mô đã chốt.

### 6.5 Dependencies

- Feature `auth-roles` cung cấp phiên đăng nhập + kiểm quyền trước khi ghi/phát (sprint 1).
- Stack realtime theo tôn chỉ (Socket.IO, Node.js) — quyết định công nghệ đã chốt.
- Các feature nghiệp vụ (`check-in-out`, `housekeeping`, `maintenance`, `room-dashboard`, `audit-log`) là đầu mối phát/tiêu thụ sự kiện (sprint 2–3).

## 7. High-level Business Requirements

| ID | Business Requirement | Business Objective | Priority |
|----|----------------------|--------------------|----------|
| BREQ-realtime-sync-01 | Mọi thay đổi trạng thái phải được lưu tại máy chủ trước rồi mới phát tới thiết bị khác | BO-realtime-sync-01 | Must |
| BREQ-realtime-sync-02 | Cập nhật phải hiển thị trên thiết bị khác trong ≤3 giây | BO-realtime-sync-01 | Must |
| BREQ-realtime-sync-03 | Mọi ghi phải kiểm tra phiên bản; ghi dựa trên phiên bản cũ phải bị từ chối, không ghi đè | BO-realtime-sync-02 | Must |
| BREQ-realtime-sync-04 | Mất kết nối phải được báo rõ cho người dùng và khóa mọi thao tác ghi | BO-realtime-sync-03 | Must |
| BREQ-realtime-sync-05 | Khi kết nối lại, thiết bị phải tự tải trạng thái mới từ máy chủ trước khi cho ghi | BO-realtime-sync-03 | Must |

## 8. Business Rules

| ID | Business Rule | Rationale |
|----|---------------|-----------|
| BR-realtime-sync-01 | Lưu trước — phát sau: không có sự kiện nào được phát khi máy chủ chưa lưu thành công | Tránh thiết bị hiển thị trạng thái "ảo" không tồn tại ở nguồn sự thật |
| BR-realtime-sync-02 | Mọi ghi kèm phiên bản; phiên bản không khớp → từ chối | Chống ghi đè — rủi ro chính của PRD |
| BR-realtime-sync-03 | Mất kết nối → chỉ đọc, cấm ghi | Ngăn thao tác mất lặng lẽ |
| BR-realtime-sync-04 | Kết nối lại → tải trạng thái mới trước khi mở khóa ghi | Bù toàn bộ sự kiện đã lỡ, đảm bảo thao tác trên dữ liệu mới |
| BR-realtime-sync-05 | Chỉ máy chủ phát sự kiện; thiết bị không tự coi thay đổi cục bộ là đã đồng bộ | Một nguồn sự thật duy nhất |

## 9. Cost-Benefit (định tính)

### 9.1 Cost Drivers

- Effort phát triển Sprint 1 (đã nằm trong kế hoạch 480 giờ): kênh sự kiện máy chủ↔thiết bị, kiểm tra phiên bản, phát hiện/xử lý mất kết nối, chỉ báo kết nối trên UI.
- Chi phí hạ tầng realtime: đã nằm trong hạng mục VPS của ngân sách chung.

### 9.2 Expected Benefits

- Hiện thực hóa giá trị cốt lõi toàn sản phẩm: mọi vai trò thao tác trên cùng trạng thái mới nhất, lễ tân thoát khỏi vai trò trung gian.
- Loại bỏ lỗi ghi đè lặng lẽ — nguồn gốc dữ liệu sai khó truy vết nhất.
- Một cơ chế dùng chung cho mọi feature → không nhân bản logic đồng bộ ở từng luồng.

### 9.3 Priority / Rough ROI

Ưu tiên cao nhất — dependency cứng của mọi feature vận hành; không có nó, Feature Map không feature nào đạt tiêu chí "realtime" của sản phẩm. Chi phí đã nằm trong kế hoạch; ROI đo trực tiếp qua tiêu chí nghiệm thu.

## 10. Risks

| ID | Risk | Likelihood | Impact | Mitigation | Owner Role |
|----|------|------------|--------|------------|------------|
| RISK-realtime-sync-01 | Ghi đè do xung đột khi 2 thiết bị sửa cùng lúc | Trung bình | Dữ liệu sai toàn hệ thống | Kiểm tra phiên bản bắt buộc (BREQ-03) + kịch bản kiểm thử xung đột | Team lead |
| RISK-realtime-sync-02 | Mạng demo chập chờn làm lượt cập nhật >3s | Trung bình | Trượt mục tiêu nghiệm thu 95% | Chuẩn bị mạng demo ổn định; đo và ghi nhận rõ từng lượt | Team lead |
| RISK-realtime-sync-03 | Reconnect nhưng UI không tải lại → hiển thị cũ | Trung bình | Người dùng thao tác trên dữ liệu sai | Bắt buộc bước "tải trạng thái mới" trong luồng reconnect (BR-04) | Team lead |
| RISK-realtime-sync-04 | Người dùng bỏ qua cảnh báo offline | Thấp | Thao tác tưởng đã lưu nhưng không | Khóa ghi cứng + thông báo khi chạm ghi (BR-03) | PM |

## 11. Open Questions

- [ ] OQ-1: Thiết bị báo "mất kết nối" sau tối đa bao lâu kể từ khi mất liên lạc máy chủ?
- [ ] OQ-2: Người bị từ chối ghi đè có cần giữ nội dung vừa nhập để nhập lại không?
- [ ] OQ-3: "Tải trạng thái mới" khi kết nối lại là toàn bộ hay chỉ phần đã đổi?
