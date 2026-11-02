---
title: "Phase 3: Backfill và đổi metadata PR lịch sử"
status: done
---

# Phase 3: Backfill và đổi metadata PR lịch sử

## Overview

Đối chiếu toàn bộ PR #1–#53, gắn evidence vào register và đổi title/body đã được
duyệt mà không viết lại lịch sử Git.

## Requirements

- [x] Mỗi PR được phân loại `Code`, `Code + test/CI`, `Docs/prototype` hoặc `Acceptance`.
- [x] PR lịch sử phạm vi rộng không bị giả vờ tách thành nhiều PR mới; body liên kết
  mọi WBS Issue liên quan.
- [x] Title và body mới nêu workstream/WBS nhưng không sửa SHA, branch hay merge state.

## Implementation Steps

1. Tạo bảng old title → proposed title → WBS IDs → evidence → actual-status proposal.
2. Backfill #34–#46 là chuỗi UI/UX: tách báo cáo thành implementation, automated coverage,
   CI và manual acceptance thay vì ghi là 13 increment đã hoàn thành độc lập.
3. Backfill #47–#51 là project control/docs/prototype; không làm bằng chứng code product.
4. Backfill #52 là dashboard code + tests/CI; #53 là login/reliability code + CI;
   cả hai chờ UAT/sign-off của Đạt khi chưa có acceptance evidence.
5. Sau khi duyệt mapping, dùng `gh pr edit <number> --title ... --body-file ...` theo batch nhỏ.
6. Fetch lại từng PR, đối chiếu title/body/state/checks và ghi URL vào evidence register.

### Mở rộng phạm vi — 2026-10-28

Sau yêu cầu audit toàn bộ lịch sử, #1–#33 được đổi sang `Task name tổng hợp` dựa
trên body, commit và file thay đổi. Các PR phạm vi rộng hoặc có trước WBS không bị
gán bừa WBS Issue; body ghi rõ giới hạn đó. #34–#53 giữ mapping WBS Issue đã kiểm
chứng. Sheet `All PR Audit` trong evidence register là bảng đối chiếu đầy đủ.

## Proposed historical display titles

| PR | Proposed title | Evidence treatment |
|---|---|---|
| #34 | `feat(ui): [S1-UX] loading skeletons and tablet layout foundation` | Code only |
| #35 | `feat(ui): [S1-UX] offline guidance and shared accessibility tokens` | Code only |
| #36 | `feat(shell): [S1-UX] responsive navigation and reconnect feedback` | Code only |
| #37 | `feat(dashboard): [S3-DASH] loading, refresh and room-search persistence` | Code only |
| #38 | `feat(rooms): [S1-ROOM][S2-STAY] room controls and check-in shortcuts` | Code only |
| #39 | `feat(app): [S1-ROOM][S2-STAY][S2-MNT] form validation and offline list UX` | Code only |
| #40 | `feat(operations): [S2-STAY][S2-MNT] checkout and maintenance task UX` | Code only |
| #41 | `feat(housekeeping): [S2-HK] task list readability and mobile interaction` | Code only |
| #42 | `feat(admin): [S1-USER][S2-AUDIT] accounts and audit-screen UX` | Code only |
| #43 | `feat(app): [S1-AUTH][S3-AI] autofill and supporting-screen responsive UX` | Code only |
| #44 | `test(app): [S1-UX][S2-UX] shared-widget and feature-screen coverage` | Test source, no attached CI evidence |
| #45 | `test(ui): [S3-UX][S4-UAT] layout matrix and design-system checks` | Test/docs, manual a11y remains open |
| #46 | `ci(app): [S4-DEVOPS] Flutter analyze, test and web-build workflow` | CI configuration + passing check |
| #47 | `docs(project): [S4-PM] risk register and communication workbooks` | Reviewed artefact only |
| #48 | `docs(ui): [S3-UX] five-phase UI/UX upgrade specification` | Plan only |
| #49 | `docs(qa): [S3-UX] automated QA report and unresolved manual checks` | Historical QA report, gaps remain |
| #50 | `docs(dashboard): [S3-DASH] compact PMS room-tile redesign plan` | Plan only |
| #51 | `docs(dashboard): [S3-DASH] room-tile mockups and interactive prototype` | Prototype only |
| #52 | `feat(dashboard): [S3-DASH] live stays-connected PMS room tiles` | Code + tests/CI; UAT pending |
| #53 | `feat(app): [S1-AUTH][S2-OPS] login slideshow and duplicate-action guard` | Code + CI; UAT pending |

## Todo

- [x] Chụp title/body cũ trước mỗi batch để rollback metadata.
- [x] Không đổi base branch hoặc close/reopen PR.
- [x] Không ghi UAT nếu chỉ có CI/test.

## Success Criteria

Mỗi PR #34–#53 có evidence classification và WBS mapping được duyệt; title hiển thị
đúng phạm vi, không có thay đổi lịch sử mã nguồn.

## Risk Assessment

PR #52 mang cả code, docs và prototype; title chỉ mô tả delivery chính, body nêu
phạm vi phụ. PR #53 chạm auth và task guard; giữ một PR vì dùng chung reliability
control, nhưng liệt kê nhiều WBS ID trong body.
