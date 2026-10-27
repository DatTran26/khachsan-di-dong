---
phase: 5
title: "Kiểm tra tích hợp và tài liệu"
owner: Dat (chủ trì), Bao, Kim
status: completed
effort: 5h
dependsOn: [2, 3, 4]
---

# Phase 05 — Kiểm tra tích hợp và tài liệu

## File sở hữu

- Tạo: `docs/_shared/design-system.md`, `plans/reports/qa-<ngày>-ui-ux-upgrade.md`
- Sửa: chỉ file cần để sửa lỗi phát hiện ở bước kiểm tra. Lỗi thuộc phase nào thì trả về người sở hữu file đó.

## Các bước

1. Cả ba PR đã merge vào `develop`; kéo `develop` mới nhất.
2. Chạy các lệnh đo (từ thư mục `app/`):
   ```bash
   grep -rn "Color(0x" lib --include=*.dart | grep -v core/theme/app_theme.dart | wc -l   # mục tiêu 0
   grep -rn "fontSize:" lib/features --include=*.dart | wc -l                              # mục tiêu 0
   grep -rn "Center(child: CircularProgressIndicator" lib/features | wc -l                 # mục tiêu 0
   grep -rln "RefreshIndicator" lib/features --include=*_screen.dart | wc -l               # ≥ 7
   flutter analyze && flutter test
   ```
3. Ma trận kiểm thủ công: 3 vai trò × 3 kích thước (360, 768, 1280) × cỡ chữ (1.0, 2.0); thêm một lượt TalkBack trên Android cho luồng nhân viên và một lượt chỉ dùng bàn phím trên web cho luồng lễ tân.
4. Ghi kết quả, ảnh chụp và số thao tác trước/sau (từ report của phase 03) vào report QA.
5. Viết `docs/_shared/design-system.md` (ngắn, dưới 150 dòng): token, breakpoints, component dùng chung và khi nào dùng, quy tắc "không viết cứng màu/cỡ chữ", checklist trợ năng cho màn mới. Link tới `app_theme.dart` và `ui.dart`, không chép code.
6. Cập nhật `docs/_shared/changelog.md` một dòng.

## Tiêu chí hoàn thành

- Mọi lệnh ở bước 2 đạt mục tiêu, `flutter analyze` + `flutter test` xanh.
- Ma trận kiểm thủ công không còn lỗi mức chặn; lỗi nhỏ còn lại được ghi trong report kèm người sở hữu.
- Tài liệu design system đã merge vào `develop`.
