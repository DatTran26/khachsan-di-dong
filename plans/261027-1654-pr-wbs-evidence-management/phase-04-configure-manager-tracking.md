---
title: "Phase 4: Cấu hình theo dõi cho quản lý"
status: done
---

# Phase 4: Cấu hình theo dõi cho quản lý

## Overview

Biến GitHub Project #14 đang trống thành board có đủ 178 card task lá, liên kết
với evidence register để quản lý xem được tiến độ thực tế ở mức chi tiết.

## Requirements

- [x] Không tạo GitHub Project mới; dùng Project #14 `khachsan-di-dong Delivery` và 178 Issue lá.
- [x] Giữ Kanban sẵn có: Triage, Ready, In Progress, Blocked, Review, Done.
- [x] Bổ sung WBS ID, Sprint, Workstream và Evidence level để phân biệt delivery với acceptance.

## Implementation Steps

1. Tạo custom fields: `WBS ID` (text), `Sprint` (single-select S1–S4), `Workstream` (single-select),
   `Evidence level` (No evidence/Code/Code + test/CI/Acceptance),
   `Acceptance type` (UAT/Stakeholder sign-off/Reviewer approval/Not applicable),
   `Last verified` (date).
2. Tạo 178 Issue lá, title bắt đầu bằng WBS ID, và chứa outcome, acceptance criteria,
   owner, reviewer, evidence links cùng issue relationship khi có dependency.
3. Thêm 178 Issue vào Project #14; set Kanban/priority/estimate/start date/target date.
4. Thiết kế saved views quản lý: Sprint, Workstream, Owner, `Needs evidence`, `Blocked`
   và `Done awaiting acceptance`.
5. Trong workbook, tạo sheet detail đủ 178 task lá và sheet summary theo Sprint,
   công bố tỷ lệ done dựa theo estimate có acceptance evidence phù hợp.

## Todo

- [x] Kiểm tra 0 item hiện hữu của Project #14 trước khi import.
- [x] Kiểm tra link từ Issue/PR về WBS ID và ngược lại.

## Success Criteria

Quản lý thấy mỗi card task lá có outcome/evidence rõ; có thể lọc từ Sprint xuống
task và PR, không có card `Done` thiếu acceptance evidence phù hợp.

## Security Considerations

Không chép secrets, `.env`, URL credentials hoặc dữ liệu khách hàng vào Issue,
PR body, Project field hay workbook evidence.
