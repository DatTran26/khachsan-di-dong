---
type: prd
feature: realtime-sync
status: draft
updated: 2026-09-17
links:
  - "[[docs/features/realtime-sync/realtime-sync-brd.md|Realtime-sync BRD]]"
  - "[[docs/features/realtime-sync/realtime-sync-urd.md|Realtime-sync URD]]"
---

# realtime-sync — Product Requirements Document (Feature)

## 1. Overview

Cơ chế nền dùng chung biến "một nguồn sự thật" thành hiện thực: lưu thay đổi tại máy chủ trước rồi phát tới mọi thiết bị trong ≤3 giây; kiểm tra phiên bản chống ghi đè; mất kết nối thì báo rõ + khóa ghi; kết nối lại thì tự tải trạng thái mới. Feature không chứa nghiệp vụ — nó là đường truyền mà `check-in-out`, `housekeeping`, `maintenance`, `room-dashboard` cùng dùng.

### Product Gap

- AS-IS: mỗi vai trò/thiết bị giữ bản trạng thái riêng; hai người sửa cùng lúc ghi đè lặng lẽ; mất mạng thì thao tác mất không ai biết.
- TO-BE: một cơ chế đồng bộ thống nhất — mọi thiết bị thấy cùng trạng thái mới nhất, xung đột bị chặn, offline được báo rõ.

## 2. Goals & Non-Goals

### Goals

- G1: ≥95% trong 100 lượt cập nhật hiển thị trên thiết bị khác ≤3 giây (50 phòng, 10 phiên đồng thời).
- G2: 0 ca ghi đè trạng thái do xung đột phiên bản.
- G3: 100% thời điểm mất kết nối có cảnh báo + khóa ghi; 100% lần kết nối lại tự tải trạng thái mới.
- G4: Một cơ chế dùng chung — mọi feature trạng thái đi qua cùng đường truyền, không nhân bản logic.

### Non-Goals

- Không hàng đợi offline cho ghi, không đồng bộ soạn dở, không retry thông minh (PRD "chưa làm").
- Không chứa nghiệp vụ trạng thái (báo hỏng, dọn phòng, nhận/trả) — thuộc feature vận hành tương ứng.
- Không quản lý phiên đăng nhập (`auth-roles`); không ghi nhật ký nghiệp vụ (`audit-log`).
- Không đồng bộ đa máy chủ/đa khách sạn; không tối ưu cho tải lớn hơn ~10 phiên.

## 3. Personas & Use Cases

| Persona | Bối cảnh | Use cases trong feature |
|---------|----------|--------------------------|
| Mọi vai trò (lễ tân, nv buồng phòng–bảo trì, quản lý) | Web + Android trong ca | Nhận cập nhật realtime; được báo khi bị xung đột phiên bản; thấy banner offline; tự đồng bộ khi có mạng lại |
| Người vận hành (WPCTeam) | Kiểm thử/vận hành | Đo độ trễ đồng bộ phục vụ nghiệm thu; dùng chung cơ chế cho mọi feature |

Ref: `[[docs/features/realtime-sync/realtime-sync-urd.md]]` mục User Types + Journeys.

## 4. Capabilities (Epics)

| ID | Epic | P | Rationale | Sizing | Trace |
|----|------|---|-----------|--------|-------|
| CAP-realtime-sync-01 | Lưu tại máy chủ trước rồi phát sự kiện tới thiết bị | P0 | Nền của "một nguồn sự thật" | ~4 story | UN-001, UN-002 → BO-01 |
| CAP-realtime-sync-02 | Hiển thị cập nhật trên thiết bị khác ≤3 giây | P0 | Tiêu chí nghiệm thu lõi | ~3 | UN-001 → BO-01 |
| CAP-realtime-sync-03 | Kiểm tra phiên bản chống ghi đè + báo người bị từ chối | P0 | Chặn rủi ro dữ liệu sai nặng nhất | ~4 | UN-003 → BO-02 |
| CAP-realtime-sync-04 | Phát hiện mất kết nối → cảnh báo + khóa ghi | P0 | Ngăn thao tác mất lặng lẽ | ~3 | UN-004 → BO-03 |
| CAP-realtime-sync-05 | Tự kết nối lại + tải trạng thái mới + mở khóa ghi | P0 | Khép kín chu trình offline | ~3 | UN-005 → BO-03 |
| CAP-realtime-sync-06 | Chỉ báo kết nối thống nhất trên mọi màn hình | P1 | Chuẩn hóa trải nghiệm offline | ~2 | UN-004 → BO-03 |
| CAP-realtime-sync-07 | Đo độ trễ phát sự kiện phục vụ nghiệm thu | P1 | Cần số liệu đối chiếu 95% ≤3s | ~2 | UN-006 → BO-01 |
| CAP-realtime-sync-08 | Hàng đợi offline / đồng bộ soạn dở / retry thông minh | P2 | Ngoài phạm vi MVP theo PRD | ~6 | — |

### Done when (product level)

- CAP-01: Mọi thay đổi trạng thái chỉ được phát sau khi máy chủ xác nhận lưu; không có sự kiện "ảo".
- CAP-02: Đo 100 lượt cập nhật giữa các thiết bị — ≥95% hiển thị ≤3 giây.
- CAP-03: Kịch bản 2 thiết bị ghi cùng đối tượng — ghi sau bị từ chối 100%, người ghi được báo và thấy bản mới; 0 ca ghi đè.
- CAP-04: Tắt mạng — thiết bị hiển thị cảnh báo rõ và mọi thao tác ghi đều bị khóa/báo "chưa được lưu".
- CAP-05: Bật mạng lại — thiết bị tự kết nối, tự tải trạng thái mới, mở khóa ghi; không yêu cầu đăng nhập lại khi phiên còn hạn.
- CAP-06: Cùng một chỉ báo kết nối xuất hiện trên mọi màn hình của cả Web và Android.
- CAP-07: Có số liệu độ trễ từng lượt để đối chiếu tiêu chí nghiệm thu.
- CAP-08: (sau MVP) thao tác ghi khi offline được xếp hàng và đẩy khi có mạng.

## 5. Success Metrics

| Metric | Baseline | Target | Measurement | Timeframe |
|--------|----------|--------|-------------|-----------|
| Độ trễ lan truyền cập nhật | Chưa có | ≥95% trong 100 lượt ≤3 giây | Đo trực tiếp giữa 2+ thiết bị | Nghiệm thu |
| Ca ghi đè do xung đột | Chưa có | 0 | Kịch bản kiểm thử xung đột | Nghiệm thu |
| Thời điểm offline có cảnh báo + khóa ghi | Chưa có | 100% | Kiểm thử tắt/bật mạng | Sprint 1–4 |
| Lần reconnect tự tải trạng thái mới | Chưa có | 100% | Kiểm thử tắt/bật mạng | Sprint 1–4 |

## 6. Dependencies

| Dependency | Owner | Status | Needed By |
|------------|-------|--------|-----------|
| Phiên đăng nhập + kiểm quyền trước khi ghi | `auth-roles` (team, sprint 1) | Đã chi tiết | CAP-01, CAP-05 |
| Kênh realtime (Socket.IO theo tôn chỉ) | Team backend | Quyết định công nghệ đã chốt | CAP-01, CAP-02 |
| Các feature nghiệp vụ phát/tiêu thụ sự kiện | `check-in-out`, `housekeeping`, `maintenance`, `room-dashboard` (sprint 2–3) | Đang pipeline | CAP-01, CAP-02 |

## 7. Assumptions

- Một máy chủ duy nhất là nguồn sự thật; ~10 phiên đồng thời là tải đỉnh.
- Mất kết nối vẫn cho xem dữ liệu cuối — chỉ khóa ghi.
- Sự kiện mang trạng thái mới của đối tượng; thiết bị lỡ sự kiện được bù bằng tải lại khi kết nối lại (không cần hàng đợi sự kiện lưu trữ).
- Kiểm tra phiên bản áp theo đối tượng trạng thái, không khóa toàn bộ phòng.

## 8. Risks (product)

| Risk | P | Impact | Mitigation | Owner |
|------|---|--------|------------|-------|
| Xung đột ghi đè lặng lẽ | Medium | Dữ liệu sai toàn hệ thống | Kiểm tra phiên bản bắt buộc (CAP-03) + kịch bản kiểm thử xung đột | Team lead |
| Mạng demo chập chờn → lượt >3s | Medium | Trượt mục tiêu 95% | Chuẩn bị mạng demo ổn định; đo rõ từng lượt (CAP-07) | Team lead |
| Reconnect không tải lại → hiển thị cũ | Medium | Thao tác trên dữ liệu sai | Bắt buộc tải trạng thái mới trong luồng reconnect (CAP-05) | Team lead |
| Người dùng bỏ qua cảnh báo offline | Low | Thao tác tưởng đã lưu | Khóa ghi cứng + báo khi chạm ghi (CAP-04) | PM |

## 9. Release Plan

### Now (Sprint 1 — khung tới 21/09)

- CAP-realtime-sync-01 → 05 — cơ chế lõi, mốc "kiểm chứng đồng bộ realtime" của sprint 1.

### Next (Sprint 2–3)

- CAP-realtime-sync-06, 07 — chỉ báo kết nối thống nhất + đo độ trễ, hoàn thiện cùng các luồng vận hành và dashboard.

### Later (sau MVP)

- CAP-realtime-sync-08 — hàng đợi offline, đồng bộ soạn dở, retry thông minh.

## 10. Launch Readiness

- Guardrail: ≥95% lượt ≤3s; 0 ghi đè; 100% offline có cảnh báo + khóa ghi.
- Demo script: hai thiết bị mở cùng sơ đồ phòng — một máy báo xong việc bảo trì, máy kia thấy đổi trong ≤3s; tắt wifi một máy → banner + khóa ghi; bật lại → tự đồng bộ.
- Rollback: cơ chế nền — nếu lỗi, các feature vận hành quay về thao tác thủ công trên máy chủ; không mất dữ liệu đã lưu.

## 11. Open Questions

- [ ] OQ-1: Thiết bị báo "mất kết nối" sau tối đa bao lâu kể từ khi mất liên lạc máy chủ?
- [ ] OQ-2: Người bị từ chối ghi đè có cần giữ nội dung vừa nhập để nhập lại không?
- [ ] OQ-3: "Tải trạng thái mới" khi kết nối lại là toàn bộ hay chỉ phần đã đổi?
