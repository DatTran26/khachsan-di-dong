---
title: "Quản lý WBS, PR và bằng chứng hoàn thành"
description: "Chuẩn hóa WBS, đổi tên metadata PR lịch sử và vận hành bảng theo dõi tiến độ thực tế bằng GitHub Project."
status: pending
priority: P1
effort: "14h"
branch: develop-dat
tags: [docs, infra, github]
blockedBy: []
blocks: []
created: 2026-10-27
---

# Quản lý WBS, PR và bằng chứng hoàn thành

## Overview

Tạo một luồng quản lý có thể đối chiếu giữa 178 task WBS, PR/commit/test
evidence và trạng thái thực tế. Kế hoạch dùng GitHub Project
[`khachsan-di-dong Delivery`](https://github.com/users/DatTran26/projects/14),
đang trống, làm bảng quản lý; MS Project chỉ giữ lịch, dependency và baseline.

Phạm vi gồm chuẩn hóa nguồn WBS, backfill metadata cho PR #34–#53, cấu hình
board quản lý và quy ước PR mới. Không sửa `.mpp`, không thay đổi mã sản phẩm,
không tách lại commit hay rewrite lịch sử Git.

## Goals

| # | Goal | Priority |
|---|------|----------|
| 1 | Mỗi task WBS có ID, owner, evidence và trạng thái thực tế kiểm chứng được. | P1 |
| 2 | PR có tên nhất quán, nêu rõ workstream và liên kết được tới WBS. | P1 |
| 3 | Quản lý nhìn được phần đã có code, đã có CI/test, đang chờ UAT và bị chặn. | P1 |

## Phases

| # | Phase | Status |
|---|-------|--------|
| 1 | [Xác nhận nguyên tắc và phạm vi](./phase-01-start.md) | Pending |
| 2 | [Chuẩn hóa WBS và evidence register](./phase-02-normalize-wbs-and-evidence.md) | Pending |
| 3 | [Backfill PR lịch sử](./phase-03-backfill-historical-prs.md) | Pending |
| 4 | [Cấu hình theo dõi cho quản lý](./phase-04-configure-manager-tracking.md) | Pending |
| 5 | [Áp dụng quy trình PR mới](./phase-05-adopt-forward-pr-workflow.md) | Pending |

## Success Criteria

- [ ] 178 task lá được đối chiếu với XML, có cột owner, reviewer, trạng thái và evidence tách bạch.
- [ ] PR #34–#53 có đề xuất đổi tên đã được duyệt; title/body mới không làm thay đổi branch, commit hoặc CI history.
- [ ] Project #14 hiển thị đủ 178 task lá và phân biệt được `Code`, `Code + test/CI`, `Acceptance` và `No evidence`.
- [ ] Một summary WBS chỉ được `Done` khi các task lá bắt buộc và sprint exit criteria đều có evidence.

## Thiết kế đã chọn

`WBS ID` là khóa bất biến. Mỗi trong 178 task lá có một GitHub Issue riêng;
một task WBS có thể liên kết nhiều PR và một PR có thể liên kết nhiều Issue.
PR lịch sử nhiều phạm vi sẽ **không bị tách lại**: chỉ được đổi metadata và
thêm mapping evidence. PR mới phải nhỏ, có đầy đủ WBS IDs và một vòng review
kiểm chứng được.

GitHub Project #14 dùng các trạng thái Kanban sẵn có. Thêm `WBS ID`, `Sprint`,
`Workstream`, `Evidence level` và `Acceptance type`; `Done` chỉ dùng khi evidence
đáp ứng acceptance criteria của đúng loại task. Project chứa đủ 178 Issue lá;
evidence register là bản đối chứng cho quan hệ nhiều-nhiều WBS ↔ PR.

PR title mới dùng `type(area): [Sx-WORKSTREAM] outcome ngắn`; body chứa đầy đủ
`WBS-IDs`, evidence, acceptance criteria và reviewer. Ví dụ:
`feat(dashboard): [S3-DASH] live stays-connected room tiles`.

## Bằng chứng và rủi ro đã kiểm tra

- Không có PR mở. #34–#53 đã merge vào `develop`; title có thể cập nhật bằng
  `gh pr edit --title`, nhưng thực hiện sau khi duyệt danh sách mapping.
- #52 và #53 có code và App CI thành công; #47–#51 chủ yếu là tài liệu,
  kế hoạch hoặc prototype. Không PR nào thay thế UAT/sign-off.
- XML có 202 dòng (178 task lá) nhưng status date là 24/09/2026 và
  `PercentComplete` là 0. CSV hiện lẫn 31 reviewer trong cột Status; không dùng
  CSV hiện tại làm báo cáo thực tế.
- PR merge vào `develop`, không phải default branch `main`; từ khóa `Closes #N`
  không tự đóng Issue. Board phải được cập nhật theo evidence hoặc bằng automation
  dành riêng cho merge vào `develop`.

## Dependencies

- Đã duyệt đổi title PR #34–#53 theo mapping, thực hiện theo batch nhỏ.
- Đã duyệt tạo một Issue cho mỗi trong 178 task lá; dùng view/lọc để giảm độ dày board.
- Đạt là acceptance owner cho task UI/vận hành trước khi chuyển task sang `Done`.

## Red Team Review

- **Independent reviewer limit:** Ba lượt red-team song song đã dừng do usage limit,
  nên chưa có phản biện độc lập hoàn chỉnh. Các rủi ro dưới đây là kiểm tra trực tiếp
  bằng WBS, template, GitHub PR/Project và sẽ cần một lượt red-team lại trước triển khai.
- **History integrity:** Không đổi commit SHA, branch hoặc trạng thái merged; chụp mapping
  cũ/mới trước từng `gh pr edit` và đổi title theo batch có thể rollback bằng title cũ.
- **False completion:** Code merge/CI xanh chỉ đến `Code + test/CI`; không được suy diễn
  runtime, security, deploy hoặc UAT. Task tài liệu/BA có thể `Done` khi reviewer
  duyệt artefact theo acceptance criteria; task vận hành/UI cần UAT/sign-off.
- **Overhead:** Người dùng chọn 178 Issue riêng. Giảm quá tải bằng view theo Sprint,
  Workstream, Owner và exception, thay vì bỏ chi tiết WBS.
- **Gitflow:** Không chuyển base branch sang `main` chỉ để auto-close Issue; duy trì merge
  vào `develop` và cập nhật trạng thái quản lý rõ ràng.

## Validation Log

### Verification Results

- **Tier:** Full (5 phases)
- **Claims checked:** 16
- **Verified:** 15 | **Failed then corrected:** 1 | **Unverified:** 0
- **Evidence:** WBS XML có 202 dòng và status date 24/09/2026; 196 task có
  `PercentComplete=0`, các summary/milestone không được dùng làm actual progress.
  `detailed-task-breakdown.md` yêu cầu PR/commit/test evidence trước Done.
  README quy định feature PR vào `develop`; Project #14 tồn tại, đang trống và
  token hiện có scope `project`.

### Session 1 — 2026-10-28

**Trigger:** Người dùng yêu cầu tiếp tục sau khi kiểm tra PR/WBS.
**Questions asked:** 3

#### Questions & Answers

1. **[Scope]** Bạn muốn xử lý title của 20 PR đã merge (#34–#53) theo cách nào?
   - Options: Đổi theo mapping | Chỉ PR từ nay | Chỉ tạo mapping
   - **Answer:** Đổi theo mapping
   - **Rationale:** Cần nhìn được lịch sử delivery theo Task Name ngay trên GitHub.
2. **[Architecture]** Trên GitHub Project, mức chia task nào phù hợp cho quản lý?
   - Options: Theo work package | 178 Issue riêng | Theo Sprint
   - **Answer:** 178 Issue riêng
   - **Rationale:** Người dùng cần đánh dấu hoàn thành ở từng task WBS.
3. **[Assumptions]** Ai sẽ xác nhận task vận hành/UI trước khi chuyển sang Done?
   - Options: Đạt xác nhận | Nhóm tự xác nhận | Khách hàng xác nhận
   - **Answer:** Đạt xác nhận
   - **Rationale:** Tạo một điểm quyết định rõ ràng cho UAT/sign-off.

#### Confirmed Decisions

- Đổi title PR #34–#53 theo mapping: bảo toàn commit, branch và merge state.
- Tạo 178 Issue lá trong Project #14: dùng views để quản lý mật độ card.
- Đạt là acceptance owner cho UI/vận hành: `Done` sau UAT/sign-off của Đạt.

### Whole-Plan Consistency Sweep

- Files reread: `plan.md`, `phase-01-start.md`, `phase-02-normalize-wbs-and-evidence.md`,
  `phase-03-backfill-historical-prs.md`, `phase-04-configure-manager-tracking.md`,
  `phase-05-adopt-forward-pr-workflow.md`.
- Decision deltas checked: 3 (rename historical PRs, 178 Issue riêng, Đạt acceptance owner).
- Reconciled stale references: 11.
- Unresolved contradictions: 0.

<!-- slug: pr-wbs-evidence-management -->
