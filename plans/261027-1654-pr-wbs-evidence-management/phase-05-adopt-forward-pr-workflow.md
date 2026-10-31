---
title: "Phase 5: Áp dụng quy trình PR mới"
status: in-progress
---

# Phase 5: Áp dụng quy trình PR mới

## Overview

Thiết lập quy ước để các PR sau này luôn truy được task WBS, bằng chứng và
trạng thái quản lý ngay khi được review/merge.

## Requirements

- [x] Một PR mới có title theo conventional commit và workstream.
- [x] Body PR bắt buộc WBS IDs, acceptance criteria, evidence và reviewer.
- [x] Merge vào `develop` không tự coi là Done hay tự-close Issue.

## Implementation Steps

1. Cập nhật `.github/pull_request_template.md` với WBS IDs, Summary WBS,
   acceptance criteria, validation, evidence links và reviewer.
2. Cập nhật `.github/ISSUE_TEMPLATE/task.yml` để tạo Issue task lá với
   WBS IDs, owner, reviewer, target date và definition of done.
3. Áp dụng title: `type(area): [Sx-WORKSTREAM] concise outcome`; ví dụ
   `feat(dashboard): [S3-DASH] live stays-connected room tiles`.
4. Gắn mọi PR mới vào một hoặc nhiều WBS Issue trong Project #14 trước review.
5. Khi PR merge: chuyển card sang `Review`, xác minh CI/evidence, rồi chỉ
   acceptance owner mới chuyển `Done`; UAT/sign-off là bắt buộc cho task vận hành/UI,
   reviewer approval đủ cho artefact tài liệu/BA; carry-over giữ nguyên WBS ID và effort còn lại.

## Todo

- [ ] Tạo một PR thật có WBS ID hợp lệ và verify field/body đầy đủ. Không tạo PR thử rỗng chỉ để đánh dấu checklist.
- [x] Kiểm tra template yêu cầu CI, reviewer và evidence URL trước cập nhật status.

## Success Criteria

PR mới có thể được đọc độc lập bởi reviewer/manager; không cần suy đoán task,
trạng thái hay điều kiện hoàn thành từ title chung chung.

## Risk Assessment

GitHub chỉ tự đóng Issue bằng closing keyword khi merge vào default branch;
repo này merge feature vào `develop`. Giữ trạng thái Issue/Project thủ công
hoặc triển khai automation riêng sau khi review quy tắc này.
