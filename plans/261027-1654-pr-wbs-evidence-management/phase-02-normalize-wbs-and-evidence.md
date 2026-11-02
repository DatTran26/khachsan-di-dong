---
title: "Phase 2: Chuẩn hóa WBS và evidence register"
status: todo
---

# Phase 2: Chuẩn hóa WBS và evidence register

## Overview

Tạo một register chi tiết có 178 task lá và xác nhận nó khớp XML, không dùng
CSV lỗi cột Status làm nguồn tiến độ.

## Requirements

- [x] Giữ nguyên XML/MS Project làm baseline lịch và WBS hierarchy.
- [x] Tách `Owner`, `Reviewer`, `Status` thành cột riêng trong dữ liệu chuẩn hóa.
- [x] Lưu evidence theo WBS ID, không theo text Task Name dễ đổi.

## Implementation Steps

1. So khớp 202 XML rows: 1 project root, 5 sprint, 18 workstream và 178 task lá.
2. Khôi phục schema CSV chuẩn; rà 31 status không hợp lệ là tên reviewer.
3. Tạo evidence register gồm: WBS ID, outline path, sprint, workstream, task name,
owner, reviewer, estimate, status, PR/commit/test/acceptance URLs, blocker và last verified.
4. Đặt status ban đầu theo evidence: các record chưa chứng minh là `Needs Evidence`,
   không suy diễn từ `PercentComplete` XML hay PR merged.
5. Tạo view review trong workbook: task name đã chốt, evidence, actual status và notes.

## Todo

- [x] Kiểm tra count 178 và uniqueness của WBS ID.
- [x] Kiểm tra mỗi `Done` có acceptance evidence phù hợp: UAT/sign-off cho
  luồng vận hành, reviewer approval cho tài liệu/BA, test/CI + reviewer cho task kỹ thuật nội bộ.

## Success Criteria

Register không có status reviewer, không có WBS ID trùng và truy được từng
status về PR, commit, test hoặc acceptance evidence phù hợp.

## Files and validation

- Read: `plans/260923-1658-four-sprint-mvp-backlog/Ke-hoach-KhachSanDiDong-MSProject-2021.xml`
- Read/repair mapping only: `plans/260923-1658-four-sprint-mvp-backlog/microsoft-project-import.csv`
- Read: `plans/260923-1658-four-sprint-mvp-backlog/detailed-task-breakdown.md`
- Validate count, schema and source-to-register reconciliation before export.
