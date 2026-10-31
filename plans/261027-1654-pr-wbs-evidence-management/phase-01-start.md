---
title: "Phase 1: Xác nhận nguyên tắc và phạm vi"
status: todo
---

# Phase 1: Xác nhận nguyên tắc và phạm vi

## Overview

Khóa cách diễn giải bằng chứng và thiết kế mapping trước khi tạo Issue hay
đổi title của PR đã merge.

## Requirements

- [x] Duyệt quy ước `WBS ID` là khóa bất biến và mỗi task lá có một Issue.
- [x] Duyệt status thực tế và điều kiện để dùng `Done`.
- [ ] Duyệt tiêu chuẩn title PR và phần body bắt buộc.

## Implementation Steps

1. Trình danh sách evidence level: `No evidence`, `Code`, `Code + test/CI`, `Acceptance`.
2. Chốt rằng summary WBS tự roll-up từ task lá, không nhận status trực tiếp từ PR.
3. Chốt quy tắc một Issue cho một task WBS lá; PR có thể liên kết nhiều Issue khi
   thay đổi kỹ thuật dùng chung chạm nhiều task.
4. Duyệt danh sách title PR lịch sử trước bất cứ thao tác GitHub nào.

## Todo

- [x] Đạt xác nhận UAT/sign-off và có quyền chuyển task UI/vận hành sang `Done`.
- [x] Xác nhận dùng GitHub Project #14 thay vì tạo board mới.

## Success Criteria

Mọi phase sau có tiêu chuẩn trạng thái và evidence rõ ràng; mỗi task lá có
đường đi sang một Issue; không có thao tác metadata GitHub nào trước khi
mapping/title được người dùng chốt.

## Risk Assessment

Nếu chưa có UAT owner, giữ các task đã merge ở `Review` và đặt Evidence level là
`No evidence` hoặc `Code + test/CI` theo bằng chứng hiện có.
Không dùng `Done` thay cho tình trạng “đã merge”.
