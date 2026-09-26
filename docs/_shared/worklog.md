---
type: worklog
status: active
updated: 2026-09-26
links: []
---

# Nhật ký làm việc & tiến độ

> File ghi tay, cả nhóm cùng cập nhật. Khác `changelog.md` (hook tự ghi từng file tài liệu),
> file này ghi **việc** theo ngày và **tiến độ** theo sprint.
>
> **Cách cập nhật:** làm xong việc nào → thêm 1 dòng vào "Nhật ký theo ngày" (mới nhất ở cuối)
> và đổi trạng thái việc đó ở "Tiến độ theo sprint". Tiến độ % = số việc Xong ÷ tổng số việc của sprint.
> Trạng thái: `Chưa làm` · `Đang làm` · `Xong` · `Hoãn`.

## Tổng quan

| Sprint | Thời gian | Mục tiêu (theo PRD) | Việc xong | Tiến độ |
|---|---|---|---|---|
| Sprint 1 | 08/09 – 21/09 | Tài liệu + khung ứng dụng + phân quyền + danh mục phòng + kiểm chứng realtime | 7/8 | 88% |
| Sprint 2 | 22/09 – 05/10 | Làm bù Sprint 1 + luồng vận hành end-to-end (nhận/trả → dọn → sửa) | 7/9 | 78% |
| Sprint 3 | 06/10 – 19/10 | Dashboard + cảnh báo quá hạn + nhật ký + AI tóm tắt | 0/5 | 0% |
| Sprint 4 | 20/10 – 02/11 | Kiểm thử, sửa lỗi, nghiệm thu, bàn giao | 0/4 | 0% |

**Tình trạng chung (23/09):** tài liệu phân tích 9 tính năng đã xong; khung backend chạy được (chưa có Flutter).
Sprint 1 trễ hạn → nhóm chốt giữ lịch, làm bù phần code Sprint 1 trong Sprint 2.

## Tiến độ theo sprint

### Sprint 1 (08/09 – 21/09)

| Việc | Người | Trạng thái | Ghi chú |
|---|---|---|---|
| Tài liệu phân tích 9 tính năng (PRD, BRD, URD, SRS, use case, user story, wireframe, ERD) | Dat | Xong | 15–17/09, ~220 file trong `docs/features/` |
| Dựng repo GitHub, nhánh thành viên, quy trình gitflow | Dat | Xong | 18/09, PR #1 |
| Khung ứng dụng Flutter (Web + Android) + kiểm chứng thư viện Socket.IO phía Flutter | Dat (Web), Bao (Android) | Chưa làm | Tôn chỉ yêu cầu kiểm chứng Socket.IO trên Flutter ngay Sprint 1 — backend đã sẵn sự kiện `room:updated` |
| Khung backend Node.js + Express + TS + Prisma + PostgreSQL | Kim | Xong | 23/09 — `server/`, 12 bảng, chống ghi đè, 14 test pass |
| Đăng nhập & phân quyền (`auth-roles`) | Kim (backend) | Xong (API) | 23/09 — đăng nhập/phiên 12h/1 TK 1 thiết bị/khóa 5 lần/MK tạm/quản lý TK/socket có xác thực. Màn hình: Dat, Bao |
| Danh mục phòng (`room-catalog`) + seed 50 phòng | Kim (backend) | Xong (API) | 25/09 — thêm/sửa/xóa, tạo theo dải, loại phòng, ngừng phục vụ tay |
| GitHub Actions: typecheck + test + build cho backend | Kim | Xong | 23/09 — `.github/workflows/backend-ci.yml` (chạy thật khi push) |
| Kiểm chứng realtime Socket.IO ≤3s với 30 phiên | Kim (backend) | Xong | 23/09 — 30 TB × 100 lượt: 100% ≤3s, max 43 ms (đo trên máy dev) |

### Sprint 2 (22/09 – 05/10)

| Việc | Người | Trạng thái | Ghi chú |
|---|---|---|---|
| Chốt stack và mục tiêu tải 30 phiên; cập nhật docs | Kim | Xong | 23/09, commit `7718a26` |
| Thiết kế CSDL: gộp 9 ERD thành `schema.prisma` (12 bảng) | Kim (backend) | Đang làm | Bản nháp xong 23/09, chờ nhóm review — `docs/_shared/database-design.md` |
| Làm bù các việc code của Sprint 1 (xem bảng trên) | Cả nhóm | Chưa làm | |
| Đồng bộ realtime + chống ghi đè (`realtime-sync`) | Kim (backend) | Đang làm | Xong phía server: version, lưu rồi mới phát, sự kiện `room:updated`. Còn: xác thực socket, kênh theo vai trò/người |
| Nhận/trả phòng (`check-in-out`) | Kim (API) · Bao (UI) | Xong | 26/09 — UI: dialog nhận/trả phòng trên màn danh mục phòng và màn lưu trú |
| Công việc dọn phòng (`housekeeping`) | Kim (API) · Bao (UI) | Xong | 26/09 — UI: màn `/don-phong`, accept/reject/complete (NV), confirm/return/reassign (QL), realtime qua socket |
| Báo hỏng & bảo trì (`maintenance`) | Kim (API) · Bao (UI) | Xong | 26/09 — UI: màn `/bao-tri`, báo hỏng (mọi role), claim/complete (NV), assign/cancel (QL/LT), realtime qua socket |
| Chạy thử luồng end-to-end: nhận → trả → dọn → xác nhận sạch | Cả nhóm | Đang làm | 26/09 — test tự động backend pass; UI xong, chờ chạy thử trên app |

### Sprint 3 (06/10 – 19/10)

| Việc | Người | Trạng thái | Ghi chú |
|---|---|---|---|
| Dashboard trạng thái phòng (`room-dashboard`) | Dat (UI web) · Kim (API chỉ số) | Đang làm | 26/09 — API xong; UI đã kết nối `/api/dashboard/summary` (occupied, ready, overdue, occupancy rate); chờ hoàn thiện |
| Cảnh báo quá hạn (job quét định kỳ) | Kim (backend) | Xong | 25/09 — 30 giây/lần, cảnh báo 1 lần |
| Nhật ký thay đổi (`audit-log`) — màn xem | Dat (UI) · Kim (API) | Chưa làm | Ghi nhật ký phía backend đã có sẵn (`writeAudit`) |
| AI tóm tắt vận hành (`ai-ops-summary`) | Bao | Chưa làm | Chưa chọn nhà cung cấp LLM |
| Hoàn thiện giao diện Web + Android | Dat (Web), Bao (Android) | Chưa làm | |

### Sprint 4 (20/10 – 02/11)

| Việc | Người | Trạng thái | Ghi chú |
|---|---|---|---|
| Kiểm thử bộ kịch bản nghiệm thu trên Web + Android | Cả nhóm | Chưa làm | |
| Đo realtime: ≥95% trong 100 lượt ≤3s (50 phòng, 30 phiên) | Kim (backend) | Chưa làm | |
| Triển khai: Docker Compose + Nginx HTTPS trên VPS, sao lưu CSDL; build APK | Dat (VPS) · Kim (Docker, sao lưu) · Bao (APK) | Chưa làm | Theo tôn chỉ |
| Sửa lỗi, nghiệm thu, bàn giao | Cả nhóm | Chưa làm | |

## Nhật ký theo ngày

| Ngày | Người | Việc đã làm | Kết quả / Link |
|---|---|---|---|
| 15/09 | Dat | Viết PRD tổng; brainstorm → URD → BRD → PRD → SRS cho `housekeeping` | `docs/_product/prd.md` |
| 17/09 | Dat | Hoàn tất tài liệu 9 tính năng: brainstorm, ERD, sequence, state, use case, user story, user flow, wireframe | ~440 dòng trong `changelog.md` |
| 18/09 | Dat | Dựng repo GitHub, nhánh thành viên, nhập tài liệu dự án | PR #1 vào `develop` |
| 23/09 | Kim | Phân tích yêu cầu từ tài liệu; lập danh sách câu hỏi mở | — |
| 23/09 | Nhóm | Đề xuất đổi sang Supabase → **không đồng ý**, giữ stack đã báo cáo thầy | — |
| 23/09 | Nhóm | Chốt mục tiêu tải **30 phiên đồng thời**; giữ lịch sprint, làm bù Sprint 1 | — |
| 23/09 | Kim | Sửa 21 file docs: ~10 phiên → 30 phiên | commit `7718a26` trên `develop-kim` |
| 23/09 | Kim | Tạo nhật ký làm việc (file này) | commit `ac2ff31` |
| 23/09 | Kim | Bản nháp thiết kế CSDL: 12 bảng, `prisma validate` hợp lệ | `server/prisma/schema.prisma`, `docs/_shared/database-design.md` |
| 23/09 | Kim | Dựng khung backend: Express + Prisma, migration + trigger chống ghi đè, seed 50 phòng/8 TK, API đọc phòng; 14 test pass | `server/` |
| 23/09 | Kim | Cài PostgreSQL 18 trên máy (cổng 5433), tạo DB `khachsan`, chạy migrate + seed | — |
| 23/09 | Kim | Realtime Socket.IO + "lưu xong mới phát"; tách CSDL test riêng; script đo: 30 TB × 100 lượt đạt 100% ≤3s; 18 test pass | `npm run bench:realtime` |
| 23/09 | Kim | Rà soát code với spec + tôn chỉ; sửa schema (migration `align_with_specs`), thông báo lỗi, mốc phát sự kiện, lọc theo loại phòng; 33 test pass | `server/tests/spec-rules.test.ts` |
| 23/09 | Nhóm | Chốt: lễ tân quản lý được TK nhân viên (không đụng TK quản lý) — cập nhật spec/BRD auth-roles | — |
| 23/09 | Kim | GitHub Actions backend CI; đăng nhập & phân quyền (API + socket); 59 test pass; đo realtime 30 TB có đăng nhập: 100% ≤3s | `server/src/modules/auth`, `users` |
| 24/09 | Bao | Khung Flutter: đăng nhập, đổi MK, dashboard, danh mục phòng, quản lý TK, socket (nhánh `develop-bao`, chưa PR) | commit `de1f966` |
| 24/09 | Kim | PR #2 `develop-kim` → `develop` — đã merge, CI xanh, **chưa có review** | PR #2 |
| 25/09 | Nhóm | Chốt: chỉ quản lý thêm/sửa/xóa phòng; khách tối thiểu = tên + số người; chờ Bao PR rồi mới lấy code Flutter | — |
| 25/09 | Kim | CORS; API danh mục phòng đầy đủ; nhận/trả phòng; đăng xuất không trả 401; 94 test pass. Build thử app của Bao: chạy được, phát hiện lỗi vòng lặp logout phía app | chưa commit |
| 25/09 | Kim | API dọn phòng (tự giao việc), báo hỏng & bảo trì, job quá hạn, API dashboard; test luồng đầy đủ; 130 test pass | `server/src/modules/housekeeping`, `maintenance`, `dashboard` |
| 26/09 | Bao | Flutter: models (HousekeepingTask, MaintenanceTask, Stay), socket events mới, màn dọn phòng/bảo trì/lưu trú, check-in/out dialog, dashboard API thật, cập nhật nav | `app/lib/features/`, `app/lib/models/` |
| 26/09 | Bao | Flutter (bổ sung): ConfirmDialog dùng chung, TaskStatusTimeline (dọn phòng + bảo trì), xử lý VERSION_CONFLICT (handleApiError), form thêm/sửa/xóa phòng (quản lý), bulk-create theo dải, màn nhật ký (placeholder) | `app/lib/shared/`, `app/lib/features/rooms/`, `app/lib/features/audit/` |

## Quyết định đã chốt

| Ngày | Quyết định | Lý do |
|---|---|---|
| 23/09 | Stack giữ nguyên: Flutter Web + Android; Node.js + Express + TS; PostgreSQL + Prisma; Socket.IO; VPS | Đã báo cáo và được thầy chốt |
| 23/09 | Mục tiêu tải: 30 phiên đồng thời (thay ~10) | Nhóm chốt |
| 23/09 | Lễ tân quản lý được TK không phải quản lý (thay "chỉ quản lý" trong spec auth-roles) | Nhóm chốt |
| 23/09 | Giữ lịch sprint, hạn cuối 02/11/2026; làm bù Sprint 1 trong Sprint 2 | Nhóm chốt |
| 15/09 | Phân vai: Dat PM/BA/Flutter Web · Kim Backend/CSDL/Triển khai · Bao UI/Flutter Mobile/AI/QA | Tôn chỉ đã ký 15/09 |

## Việc còn treo

- [ ] Xác nhận lại phân công ở trên (gán theo mục "Vai trò" trong tôn chỉ: Dat = PM/BA/Flutter Web, Kim = Backend/CSDL/Triển khai, Bao = UI/Flutter Mobile/AI/QA).
- [ ] Tôn chỉ dự án (`Ton_Chi_Du_An_WPCTeam.docx`) vẫn ghi 10 phiên — cập nhật hay ghi chú lệch.
- [ ] Câu hỏi mở còn lại: housekeeping OQ-1 (nguồn "đang trực" — tạm cờ onDuty), OQ-2 (cảnh báo quá hạn — tạm 1 lần), OQ-3 (nhắc chờ xác nhận — chưa làm); maintenance OQ-1 (ngưỡng quá hạn — tạm cấu hình, mặc định tắt), OQ-2 (tự nhận + chỉ định), OQ-3 (sửa khi có khách — không chặn); room-dashboard OQ-2 ("cần dọn" — API trả đủ từng trạng thái); nhà cung cấp LLM.
