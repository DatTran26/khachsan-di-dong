---
title: "Sprint 1 — Nền tảng"
status: review-required
---

# Sprint 1 — Nền tảng (08/09–21/09)

## Mục tiêu

Tạo nền kỹ thuật có thể đăng nhập, quản lý danh mục 50 phòng và đồng bộ một thay đổi giữa hai client. Repository hiện chưa có mã nguồn; mọi ticket code là `Chưa kiểm chứng`.

## Backlog chi tiết

| ID | Owner | Task | Phụ thuộc | Definition of Done | Trạng thái |
|---|---|---|---|---|---|
| S1-DAT-01 | Đạt | Chốt stack, monorepo, module boundary, naming, API versioning | Docs | ADR/README kỹ thuật được team xác nhận | Chưa kiểm chứng |
| S1-DAT-02 | Đạt | Chuyển ERD/SRS thành contract User, Role, RoomType, Room, version | S1-DAT-01 | Có field, enum 3 trục, constraint, ownership | Chưa kiểm chứng |
| S1-DAT-03 | Đạt | Đưa token guideline vào `docs/design-tokens.md` và handoff Hoàng | DONE-DAT-03 | Có palette/type/spacing/state/responsive được theo dõi trong repo | Cần thực hiện |
| S1-DAT-04 | Đạt | Tạo board, quy tắc PR, branch, review checklist, DoD | S1-DAT-01 | Mỗi ticket có owner/dependency/AC | Cần thực hiện |
| S1-DAT-05 | Đạt | Provision dev/staging, DB, web hosting, secret policy | S1-DAT-01 | `.env.example`, health check, không có secret commit | Chưa kiểm chứng |
| S1-BAO-01 | Bảo | Khởi tạo Express TS, lint/test/env, health endpoint | S1-DAT-01 | `GET /health`, lint/test/build pass | Chưa kiểm chứng |
| S1-BAO-02 | Bảo | Prisma schema + migration nền | S1-DAT-02, S1-BAO-01 | User/role/room type/room và unique room number | Chưa kiểm chứng |
| S1-BAO-03 | Bảo | Seed 3 role, demo users, 50 phòng | S1-BAO-02 | Idempotent, đủ tầng/loại/trạng thái | Chưa kiểm chứng |
| S1-BAO-04 | Bảo | Login, password hash, token/session, auth middleware | S1-BAO-02 | Login hợp lệ; lỗi bị chặn; không lộ secret | Chưa kiểm chứng |
| S1-BAO-05 | Bảo | RBAC server-side | S1-BAO-04 | Matrix test chặn quyền sai | Chưa kiểm chứng |
| S1-BAO-06 | Bảo | CRUD RoomType/Room, filter/search, optimistic version | S1-BAO-02,05 | Manager CRUD; role khác read theo contract | Chưa kiểm chứng |
| S1-BAO-07 | Bảo | Socket.IO auth, event convention, room update proof | S1-BAO-04,06 | DB commit rồi event; hai client nhận ≤3 giây | Chưa kiểm chứng |
| S1-HOANG-01 | Hoàng | Khởi tạo Flutter Web/Android, routing, env, network/error shell | S1-DAT-01 | Build Web/APK debug; loading/error/offline state | Chưa kiểm chứng |
| S1-HOANG-02 | Hoàng | Chuyển token guideline thành ThemeData/primitives | S1-DAT-03 | Không hard-code token rải rác trên màn mới | Chưa kiểm chứng |
| S1-HOANG-03 | Hoàng | Login/session guard/logout/role routes | S1-BAO-04, S1-HOANG-01 | Demo users vào đúng home; logout an toàn | Chưa kiểm chứng |
| S1-HOANG-04 | Hoàng | Room catalog UI: list/filter/detail/create/edit | S1-BAO-06, S1-HOANG-02 | Responsive, validation/API error, role action đúng | Chưa kiểm chứng |
| S1-HOANG-05 | Hoàng | Socket.IO + connection/reconnect banner | S1-BAO-07 | A thay đổi, B thấy; offline khoá write UI | Chưa kiểm chứng |
| S1-HOANG-06 | Hoàng | QA auth/RBAC/catalog/realtime proof | S1-HOANG-03..05 | Evidence 3 role, 50 room, 2 client, 95/100 event | Chưa kiểm chứng |

## Gate

- Demo login, danh mục 50 phòng, room update lan tới client thứ hai.
- Đạt review migration, quyền, CI; Bảo và Hoàng chốt API contract.
