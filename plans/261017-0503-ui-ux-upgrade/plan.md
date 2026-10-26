---
title: "Nâng cấp UI/UX toàn bộ app Flutter"
description: "Đồng bộ design system, cải thiện trải nghiệm thao tác, trợ năng và responsive cho cả 9 màn của app Khách Sạn Di Động, chia song song cho 3 thành viên."
status: in-progress
priority: P2
effort: 44h
branch: develop-dat
tags: [frontend, flutter, ui-ux, a11y, design-system]
blockedBy: []
blocks: []
created: 2026-10-17
---

# Nâng cấp UI/UX — app Flutter

## Kết quả mong muốn

Mọi màn dùng chung một bộ token (màu, chữ, khoảng cách, bo góc) thay cho giá trị viết cứng; lần tải đầu
hiện skeleton thay vòng xoay; mọi danh sách kéo để làm mới; app dùng tốt ở điện thoại 360px, tablet
600–899px và web ≥900px; đọc được với cỡ chữ hệ thống 200% và trình đọc màn hình. Giữ bảng màu
Champagne Gold, chỉ tinh chỉnh.

## Ràng buộc và ngoài phạm vi

- Không đổi API, provider, model hay route — chỉ tầng giao diện (`app/lib/**/screens`, `widgets`, `core/theme`).
- Không thêm dark mode, animation trang trí hay đổi nhận diện thương hiệu (người dùng đã loại "Thẩm mỹ & chuyển động").
- Không thêm package mới trừ khi phase ghi rõ lý do (skeleton tự viết bằng widget có sẵn).
- Gitflow: mỗi người làm trên nhánh cá nhân, PR vào `develop`.

## Hiện trạng (đo ngày 2026-10-17)

| Chỉ số | Hiện tại | Mục tiêu |
|---|---|---|
| `Color(0x` ngoài `app_theme.dart` | 35 chỗ / 15 file | 0 |
| `fontSize:` trong `features/` | 57 chỗ | 0 (dùng `AppText`/`textTheme`) |
| Spinner toàn màn khi tải lần đầu | 8 màn | 0 (skeleton) |
| Màn danh sách có kéo-làm-mới | 3/7 | 7/7 |
| Semantics/tooltip | 11 chỗ | mọi nút chỉ có icon + ô phòng + chip trạng thái |
| Bố cục tablet riêng | không có | NavigationRail ở 600–899px |
| Widget test | 1 file | test cho component dùng chung + smoke test mỗi màn |

## Các phase

| # | Phase | Người | Phụ thuộc | Ước lượng | Trạng thái |
|---|---|---|---|---|---|
| 01 | [Nền tảng design system](phase-01-design-system-foundation.md) | Dat | — | 10h | completed |
| 02 | [Shell, Tổng quan, Danh sách phòng](phase-02-shell-dashboard-rooms.md) | Dat | 01 | 9h | completed |
| 03 | [Lưu trú, Chi tiết phòng, Bảo trì](phase-03-stays-room-detail-maintenance.md) | Bao | 01 | 10h | completed |
| 04 | [Dọn phòng, Tài khoản, Nhật ký, Đăng nhập](phase-04-housekeeping-users-audit-auth.md) | Kim | 01 | 10h | completed |
| 05 | [Kiểm tra tích hợp và tài liệu](phase-05-integration-qa-docs.md) | Cả nhóm (Dat chủ trì) | 02, 03, 04 | 5h | completed |

```
01 (Dat) ──merge vào develop──┬── 02 (Dat) ──┐
                              ├── 03 (Bao) ──┼── 05 (cả nhóm)
                              └── 04 (Kim) ──┘
```

Phase 01 phải merge vào `develop` trước; Bao và Kim kéo `develop` về nhánh cá nhân rồi mới bắt đầu.
Phase 02–04 không chạm chung file nào (xem bảng sở hữu trong từng phase).

## Tiêu chí nghiệm thu chung

1. `cd app && flutter analyze` không lỗi, không cảnh báo mới; `flutter test` xanh.
2. Các lệnh đếm ở mục Hiện trạng đạt cột Mục tiêu (lệnh cụ thể ở phase 05).
3. Mỗi màn chạy đúng ở 360×800, 768×1024, 1280×800 và với `textScaler` 2.0 không tràn chữ.
4. Không thay đổi hành vi nghiệp vụ: các luồng đăng nhập, nhận/trả phòng, dọn phòng, báo hỏng, quản lý tài khoản vẫn chạy như trước.

## Rủi ro chính

- **Phase 01 trễ chặn cả nhóm** → giữ phase 01 nhỏ, merge sớm; API component mới chốt ngay ngày đầu để Bao/Kim đọc trước.
- **Xung đột merge ở `ui.dart`/`app_theme.dart`** → chỉ Dat sửa hai file này; ai cần thêm component dùng chung thì báo Dat hoặc để widget riêng trong thư mục feature của mình.
- **Màn Kim vừa thiết kế lại ở PR #8 bị làm lại** → phase 04 chỉ chuyển sang token và bổ sung trợ năng, không đổi bố cục.

## Câu hỏi còn mở

- Có muốn thêm job `flutter analyze` + `flutter test` vào CI (`.github/workflows`) không? Hiện chỉ có `backend-ci.yml`.

## Kết quả thực hiện (2026-10-17)

Cả 5 phase đã làm trên `develop-dat`, chưa commit. Kết quả, chỉ số và các điểm lệch so với plan:
[`plans/reports/qa-261017-0503-ui-ux-upgrade.md`](../reports/qa-261017-0503-ui-ux-upgrade.md).
Plan để `in-progress` cho tới khi kiểm thủ công trên thiết bị (TalkBack, bàn phím web) xong.
