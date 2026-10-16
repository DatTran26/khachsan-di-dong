---
title: "Sprint 2 — Luồng vận hành"
status: todo
---

# Sprint 2 — Luồng vận hành (22/09–05/10)

## Mục tiêu

Hoàn thành luồng end-to-end: lễ tân nhận/trả phòng, hệ thống tạo và phân công việc dọn, nhân viên xử lý dọn/bảo trì, và mọi thay đổi có audit + realtime.

## Backlog chi tiết

| ID | Owner | Task | Phụ thuộc | Definition of Done |
|---|---|---|---|---|
| S2-DAT-01 | Đạt | Chốt OQ chặn code: thông tin khách, overdue, danh sách trực, reconnect/conflict | S1 gate | Ghi vào canonical SRS; team xác nhận |
| S2-DAT-02 | Đạt | Review state machine và transaction checkout → housekeeping | S2-DAT-01 | Không transition mâu thuẫn; thứ tự save→audit→emit rõ |
| S2-DAT-03 | Đạt | Chốt API/event/error-code contract Sprint 2 | S2-DAT-02 | Request/response/role/error cho từng command |
| S2-DAT-04 | Đạt | Thiết kế test data & E2E scenario room clean/dirty/OOS/conflict | S2-DAT-03 | Có expected state, audit event, UI outcome |
| S2-BAO-01 | Bảo | Prisma: Stay, HousekeepingTask, MaintenanceTask, AuditLog/enums | S2-DAT-02 | Migration rollback-tested, FK/index/version đầy đủ |
| S2-BAO-02 | Bảo | API check-in: room trống+sạch+bình thường, tạo stay/audit | S2-BAO-01 | Chặn có lý do; concurrent request không tạo 2 stay |
| S2-BAO-03 | Bảo | API checkout transaction: close stay, room state, task dọn, audit, emit | S2-BAO-02 | Atomic, rollback khi lỗi, tạo đúng 1 task |
| S2-BAO-04 | Bảo | Housekeeping API: auto-assign, nhận/từ chối/hoàn tất/manager xác nhận | S2-BAO-01, S2-DAT-01 | State/RBAC/audit/event/overdue hợp lệ |
| S2-BAO-05 | Bảo | Maintenance API: báo hỏng, OOS, nhận/hoàn tất/mở lại | S2-BAO-01 | OOS chặn check-in; event/audit đầy đủ |
| S2-BAO-06 | Bảo | Audit service chung + query room/time/actor/action | S2-BAO-01 | Không ghi log rời rạc; pagination/filter có test |
| S2-BAO-07 | Bảo | Socket event sau commit + version conflict handling | S2-BAO-02..06 | Không emit khi rollback; client nhận lý do conflict |
| S2-BAO-08 | Bảo | Backend integration/RBAC/concurrency tests | S2-BAO-02..07 | Pass scenario S2-DAT-04 |
| S2-HOANG-01 | Hoàng | Web check-in/check-out, eligibility indicator/error state | S2-BAO-02..03 | Receptionist thao tác hoàn chỉnh, không action sai quyền |
| S2-HOANG-02 | Hoàng | Mobile list/nhận/từ chối/hoàn tất dọn | S2-BAO-04 | Luồng chính ≤3 chạm sau mở task |
| S2-HOANG-03 | Hoàng | Mobile báo hỏng/xử lý bảo trì | S2-BAO-05 | Hiển thị tiến độ/lỗi/offline state |
| S2-HOANG-04 | Hoàng | Manager xác nhận phòng sạch + audit log filter | S2-BAO-04,06 | Realtime update và lọc log đúng |
| S2-HOANG-05 | Hoàng | Stale-state/conflict dialog + reconnect refresh | S2-BAO-07 | Client không giữ state sai sau conflict/reconnect |
| S2-HOANG-06 | Hoàng | QA E2E Web+Android + regression S1 | S2-HOANG-01..05 | Evidence từng role, responsive, accessibility cơ bản |

## Gate

- Demo: check-in → checkout → dọn → manager confirm → check-in lại.
- Demo báo hỏng chặn check-in, sửa xong mở lại; audit/UI hai client khớp.
