---
type: worklog
status: active
updated: 2026-09-23
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
| Sprint 1 | 08/09 – 21/09 | Tài liệu + khung ứng dụng + phân quyền + danh mục phòng + kiểm chứng realtime | 2/7 | 29% |
| Sprint 2 | 22/09 – 05/10 | Làm bù Sprint 1 + luồng vận hành end-to-end (nhận/trả → dọn → sửa) | 1/7 | 14% |
| Sprint 3 | 06/10 – 19/10 | Dashboard + cảnh báo quá hạn + nhật ký + AI tóm tắt | 0/5 | 0% |
| Sprint 4 | 20/10 – 02/11 | Kiểm thử, sửa lỗi, nghiệm thu, bàn giao | 0/4 | 0% |

**Tình trạng chung (23/09):** tài liệu phân tích 9 tính năng đã xong; **chưa có dòng code nào**.
Sprint 1 trễ hạn → nhóm chốt giữ lịch, làm bù phần code Sprint 1 trong Sprint 2.

## Tiến độ theo sprint

### Sprint 1 (08/09 – 21/09)

| Việc | Người | Trạng thái | Ghi chú |
|---|---|---|---|
| Tài liệu phân tích 9 tính năng (PRD, BRD, URD, SRS, use case, user story, wireframe, ERD) | Dat | Xong | 15–17/09, ~220 file trong `docs/features/` |
| Dựng repo GitHub, nhánh thành viên, quy trình gitflow | Dat | Xong | 18/09, PR #1 |
| Khung ứng dụng Flutter (Web + Android) | — | Chưa làm | Làm bù ở Sprint 2 |
| Khung backend Node.js + Express + TS + Prisma + PostgreSQL | Kim | Chưa làm | Làm bù ở Sprint 2 |
| Đăng nhập & phân quyền (`auth-roles`) | Kim (backend) | Chưa làm | Làm bù ở Sprint 2 |
| Danh mục phòng (`room-catalog`) + seed 50 phòng | Kim (backend) | Chưa làm | Làm bù ở Sprint 2 |
| Kiểm chứng realtime Socket.IO ≤3s với 30 phiên | Kim (backend) | Chưa làm | Rủi ro lớn nhất — làm sớm nhất |

### Sprint 2 (22/09 – 05/10)

| Việc | Người | Trạng thái | Ghi chú |
|---|---|---|---|
| Chốt stack và mục tiêu tải 30 phiên; cập nhật docs | Kim | Xong | 23/09, commit `7718a26` |
| Làm bù các việc code của Sprint 1 (xem bảng trên) | Cả nhóm | Chưa làm | |
| Đồng bộ realtime + chống ghi đè (`realtime-sync`) | Kim (backend) | Chưa làm | Cột `version`, lưu rồi mới phát |
| Nhận/trả phòng (`check-in-out`) | — | Chưa làm | |
| Công việc dọn phòng (`housekeeping`) | — | Chưa làm | |
| Báo hỏng & bảo trì (`maintenance`) | — | Chưa làm | |
| Chạy thử luồng end-to-end: nhận → trả → dọn → xác nhận sạch | Cả nhóm | Chưa làm | |

### Sprint 3 (06/10 – 19/10)

| Việc | Người | Trạng thái | Ghi chú |
|---|---|---|---|
| Dashboard trạng thái phòng (`room-dashboard`) | — | Chưa làm | |
| Cảnh báo quá hạn (job quét định kỳ) | Kim (backend) | Chưa làm | |
| Nhật ký thay đổi (`audit-log`) — màn xem | — | Chưa làm | Ghi nhật ký phía backend làm từ Sprint 2 |
| AI tóm tắt vận hành (`ai-ops-summary`) | — | Chưa làm | Chưa chọn nhà cung cấp LLM |
| Hoàn thiện giao diện Web + Android | — | Chưa làm | |

### Sprint 4 (20/10 – 02/11)

| Việc | Người | Trạng thái | Ghi chú |
|---|---|---|---|
| Kiểm thử bộ kịch bản nghiệm thu trên Web + Android | Cả nhóm | Chưa làm | |
| Đo realtime: ≥95% trong 100 lượt ≤3s (50 phòng, 30 phiên) | Kim (backend) | Chưa làm | |
| Triển khai: web HTTPS trên VPS + build APK | — | Chưa làm | |
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

## Quyết định đã chốt

| Ngày | Quyết định | Lý do |
|---|---|---|
| 23/09 | Stack giữ nguyên: Flutter Web + Android; Node.js + Express + TS; PostgreSQL + Prisma; Socket.IO; VPS | Đã báo cáo và được thầy chốt |
| 23/09 | Mục tiêu tải: 30 phiên đồng thời (thay ~10) | Nhóm chốt |
| 23/09 | Giữ lịch sprint, hạn cuối 02/11/2026; làm bù Sprint 1 trong Sprint 2 | Nhóm chốt |
| 23/09 | Kim phụ trách backend | Phân vai trong nhóm |

## Việc còn treo

- [ ] Phân công người cho các việc đang để `—` (Flutter, các tính năng nghiệp vụ).
- [ ] Tôn chỉ dự án (`Ton_Chi_Du_An_WPCTeam.docx`) vẫn ghi 10 phiên — cập nhật hay ghi chú lệch.
- [ ] Các câu hỏi mở (OQ) trong spec: ngưỡng quá hạn bảo trì, giao việc bảo trì, thông tin khách khi nhận phòng, quyền lễ tân với danh mục, nhà cung cấp LLM.
