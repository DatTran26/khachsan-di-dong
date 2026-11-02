---
title: "Tối ưu UI/UX Dashboard và Ô phòng (Room Tile) trực quan cho Lễ tân"
description: "Cải tiến giao diện ô phòng trên lưới Dashboard theo dạng Compact Tile tinh gọn: nhận diện trạng thái bằng màu sắc và icon, hiển thị mốc thời gian/đếm lùi/quá giờ, tooltip chi tiết và bộ lọc loại phòng."
status: planned
priority: P1
effort: 8h
branch: develop-kim
tags: [frontend, flutter, ui-ux, dashboard, room-tile]
blockedBy: []
blocks: []
created: 2026-10-26
---

# Kế hoạch: Tối ưu UI/UX Dashboard và Ô phòng (Room Tile)

## 1. Kết quả mong muốn

1. **Nhận diện trong 0.2 giây (Glanceability):** Lễ tân nhìn vào lưới 50 phòng phân biệt ngay lập tức:
   - Phòng trống sẵn sàng: Nền xanh lá + icon `check_circle`.
   - Phòng có khách: Nền xanh dương + icon `person` + giờ trả.
   - Phòng theo tiếng: Icon `timer` + đếm ngược thời gian còn lại (`35p`).
   - Phòng quá giờ (Overtime): Viền đỏ đậm + nền hồng phấn + badge `+45p`.
   - Phòng trống nhưng bẩn: Nền cam + icon `cleaning_services` + `Chờ dọn`.
   - Phòng hỏng/bảo trì: Nền xám + icon `build`.
2. **Không rác thị giác (Compact & Clean):** Ô phòng tinh gọn (~90x80px), không nhồi nhét nhiều dòng chữ nhỏ, không gạch ngang rườm rà.
3. **Tiết lộ lũy tiến (Progressive Disclosure):** Rê chuột (hover) hiện Tooltip chi tiết (tên khách, loại giường, giờ nhận/trả). Bấm (click) mở trực tiếp form Nhận phòng / Trả phòng.
4. **Bộ lọc thông minh trên Dashboard:** Lọc theo Tầng + lọc theo Loại phòng (Standard, Deluxe, VIP...) + ô tìm kiếm số phòng.

## 2. Danh sách các Phase

| # | Phase | Mục tiêu | Trạng thái |
|---|---|---|---|
| 01 | [phase-01-compact-room-tile.md](phase-01-compact-room-tile.md) | Thiết kế lại `RoomTile` tinh gọn, hệ màu nền, icon và badge thời gian | planned |
| 02 | [phase-02-dashboard-filters-and-search.md](phase-02-dashboard-filters-and-search.md) | Nâng cấp `DashboardScreen` với bộ lọc Loại phòng, tìm kiếm nhanh và lưới responsive | planned |
| 03 | [phase-03-validation-and-qa.md](phase-03-validation-and-qa.md) | Kiểm thử UI trên Web/Mobile, chạy `flutter analyze` & `flutter test` | planned |

## 3. Tiêu chí nghiệm thu (Acceptance Criteria)

- [ ] Lưới phòng hiển thị 50 ô phòng cân đối, trực quan trên các độ phân giải (Web desktop ≥ 1024px, tablet 768px, mobile 360px).
- [ ] Mọi ô phòng phản ánh đúng 1 trong các trạng thái chủ đạo bằng màu nền và icon.
- [ ] Phòng đang ở hiển thị được mốc giờ trả hoặc thời gian đếm lùi; phòng quá hạn viền đỏ nổi bật.
- [ ] Hover vào ô phòng hiển thị Tooltip thông tin chi tiết.
- [ ] `flutter analyze lib` không có lỗi lint hoặc cảnh báo mới.
- [ ] `flutter test` vượt qua các bài kiểm thử.
