---
title: "Nâng cấp giao diện Ô phòng (Solid Room Tile) & Tối ưu hóa PMS Dashboard"
description: "Chuyển đổi giao diện ô phòng sang dạng Khối màu nguyên bản (Full Solid Block) chuẩn KiotViet/EzCloud: nhận diện từ xa, số phòng to, thanh trạng thái tương phản, đồng bộ UI, Backend và Docs."
status: in-progress
priority: P1
effort: 8h
branch: develop-dat
tags: [frontend, flutter, ui-ux, pms, dashboard, room-tile]
blockedBy: []
blocks: []
created: 2026-10-27
---

# Kế hoạch: Nâng cấp Ô phòng Solid Block & Dashboard PMS

## 1. Mục tiêu
Thay thế ô phòng hiện tại (nền trắng, chữ 11px nhỏ, màu pastel nhạt) bằng **Phương án 1 (Full Solid Color Block)**:
- Nền màu đặc trưng rực rỡ, độ tương phản tuyệt đối (Xanh lá = Sẵn sàng, Xanh dương = Có khách, Cam = Chưa dọn, Đỏ = Quá giờ, Xám = Bảo trì).
- Số phòng to đùng (20–22px, `FontWeight.w900`, chữ trắng).
- Thanh nhãn trạng thái tương phản cao (`✓ TRỐNG`, `TRẢ 12:00`, `⏱ CÒN 35p`, `⚠️ LỐ +45p`, `🧹 CHƯA DỌN`).
- Tooltip hiển thị đầy đủ thông tin khi rê chuột (Tên khách, loại phòng, thời gian).
- Đồng bộ tính toán Quá hạn khách ở (Overdue stay) từ Backend đến Dashboard.
- Cập nhật tài liệu đặc tả `docs/`.

## 2. Các Phase thực hiện

| # | Phase | Tệp tác động | Trọng tâm |
|---|---|---|---|
| 01 | Chuẩn hóa Theme Token & Colors | `app_theme.dart`, `ui.dart` | Bổ sung bảng màu Solid PMS và helper icon |
| 02 | Xây dựng lại `RoomTile` Solid Block | `room_tile.dart` | Giao diện khối màu, số to, nhãn pill, tooltip hover |
| 03 | Tích hợp Dashboard & Lưới phòng | `dashboard_screen.dart` | Gắn `staysProvider` vào ô phòng, căn chỉnh grid, xử lý xung đột OOS |
| 04 | Thao tác nhanh Check-in & Màn Lưu trú | `room_detail_panel.dart`, `stays_screen.dart` | Nút chọn nhanh Theo giờ / Qua đêm, đồng bộ badge quá giờ |
| 05 | Đồng bộ Backend & Cập nhật Docs | `dashboard.service.ts`, `design-system.md` | Đếm overdue stay trên BE, cập nhật docs |

## 3. Tiêu chí nghiệm thu
1. `flutter analyze lib` không có lỗi, không có warning.
2. Ô phòng hiển thị màu khối rõ nét, nhìn từ xa nhận biết ngay lập tức.
3. Rê chuột trên web hiện tooltip đầy đủ thông tin.
4. Mọi tính năng nhận/trả phòng, dọn phòng, báo hỏng hoạt động trơn tru.
