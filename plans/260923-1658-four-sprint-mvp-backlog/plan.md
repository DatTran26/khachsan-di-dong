---
title: "Backlog thực thi MVP theo 4 sprint"
description: "Phân rã công việc cho ba thành viên từ đặc tả MVP khách sạn realtime và các hạng mục Đạt đã hoàn thành."
status: pending
priority: P1
effort: "530h"
tags: [feature, frontend, backend, database, api, auth, infra]
blockedBy: []
blocks: []
created: 2026-09-24
---

# Backlog thực thi MVP theo 4 sprint

## Overview

Backlog này chuyển bộ tài liệu nghiệp vụ thành công việc có chủ sở hữu cho MVP Flutter Web + Android, backend Node.js/Express/TypeScript, PostgreSQL/Prisma và Socket.IO. Trạng thái `Đã xong` chỉ dùng cho phần có tài liệu hoặc người dùng xác nhận.

Bao gồm workstream Business Analysis: phỏng vấn stakeholder/khách hàng, quan sát AS-IS, xác nhận TO-BE, chốt scope và quản lý Open Questions trước khi đội kỹ thuật thực hiện các feature phụ thuộc.

## Phân công cố định

| Thành viên | Vai trò chính | Quy ước backlog |
|---|---|---|
| Tấn Đạt | PO, BA, PM, System Architect/Tech Lead, DevOps | Quyết định phạm vi, kiến trúc/contract, review, môi trường, CI/CD, release và nghiệm thu |
| Ngọc Hoàng | Backend, Mobile | API/nghiệp vụ, DB/Prisma, auth/RBAC, Socket.IO, Flutter Android và test backend |
| Bảo | UI/UX, Frontend, QA | Design system/token, Flutter Web, UI mobile, tích hợp API, test UI/UX và regression |

## Mốc và nguyên tắc

- Sprint 1: 08/09–21/09 — nền tảng, phân quyền, danh mục phòng, realtime proof.
- Sprint 2: 22/09–05/10 — nhận/trả, dọn phòng, bảo trì và audit log.
- Sprint 3: 06/10–19/10 — dashboard, hoàn thiện UI, AI summary.
- Sprint 4: 20/10–27/10 — kiểm thử, sửa lỗi, triển khai và bàn giao. **27/10/2026 là hạn bàn giao chính thức**; các mốc 02/11 trong tài liệu cũ cần được cập nhật khi chạm tới tài liệu đó.
- Mọi thay đổi ghi dữ liệu phải đi qua API server, kiểm quyền, ghi audit log, rồi mới phát Socket.IO.

## Công việc Đạt đã hoàn thành

| ID | Công việc | Bằng chứng | Trạng thái |
|---|---|---|---|
| DONE-DAT-01 | Tái cấu trúc PRD/BRD/URD/SRS, use case, user story và wireframe cho 9 feature | `docs/_product/prd.md`, `docs/features/` | Đã xong |
| DONE-DAT-02 | Chốt phạm vi MVP, 3 vai trò, 3 trục trạng thái phòng và lộ trình 4 sprint | `docs/_shared/project-profile.md`, product PRD | Đã xong |
| DONE-DAT-03 | Thiết kế guideline Design Token | Người dùng xác nhận; artefact chuẩn cần đặt tại `docs/design-tokens.md` | Đã xong — cần đưa vào repo |
| DONE-DAT-04 | Thiết lập repository Gitflow, quy ước branch và tài liệu an toàn | `AGENTS.md`, `.github/`, `SECURITY.md` | Đã xong |

## Phases

| # | Phase | Dates | Status |
|---|---|---|---|
| 1 | [Sprint 1 — Nền tảng](./phase-01-sprint-1-foundation.md) | 08/09–21/09 | Cần đối chiếu code |
| 2 | [Sprint 2 — Luồng vận hành](./phase-02-sprint-2-operations.md) | 22/09–05/10 | Pending |
| 3 | [Sprint 3 — Giám sát và AI](./phase-03-sprint-3-observability-ai.md) | 06/10–19/10 | Pending |
| 4 | [Sprint 4 — Chất lượng và bàn giao](./phase-04-sprint-4-release.md) | 20/10–27/10 | Pending |

## Work Breakdown Structure

WBS baseline cấp gói công việc, gồm mã WBS, sản phẩm bàn giao và ước lượng 530 giờ theo Project Charter, nằm tại [Rà soát WBS và từ điển WBS](./wbs-baseline-review-and-dictionary.md). Bảng này là nguồn kiểm soát phạm vi theo quy tắc 100% và 8/80.

[WBS 4 sprint chi tiết](./detailed-task-breakdown.md) vẫn là bảng phân công hằng ngày gồm các hoạt động triển khai nhỏ hơn; nó phân rã các gói trong baseline, không phải tầng áp dụng quy tắc 8/80.

## Global Definition of Done

- [ ] Quyền được kiểm tra tại API; client không thể tự vượt quyền.
- [ ] Migration/seed, API contract và UI được đồng bộ; dữ liệu demo có 50 phòng.
- [ ] Unit/integration test phù hợp pass; UI đã QA trên Web và Android.
- [ ] Không commit secret; cấu hình dùng biến môi trường và có `.env.example` an toàn.
- [ ] Pull request được review, pipeline xanh và release note/tài liệu liên quan được cập nhật.

## Dependencies

- Sprint 2 chỉ tích hợp sau khi auth, catalog và realtime proof của Sprint 1 được xác minh.
- Sprint 3 cần sự kiện audit và dữ liệu vận hành thật từ Sprint 2.
- Sprint 4 dùng môi trường staging/VPS và bộ kịch bản nghiệm thu đã chốt.

## Validation Log

### Quyết định xác nhận 24/09/2026

- Hạn bàn giao chính thức: **27/10/2026**.
- Nguồn Design Token guideline: **`docs/design-tokens.md`**.
- Sprint 1: chưa gán trạng thái hoàn thành cho bất kỳ task code nào; team sẽ rà soát bảng task chi tiết trước, rồi bổ sung evidence để đánh dấu từng ticket.
