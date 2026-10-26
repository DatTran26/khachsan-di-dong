---
type: qa-report
plan: plans/261017-0503-ui-ux-upgrade/plan.md
date: 2026-10-17
branch: develop-dat
status: done-with-gaps
---

# QA — Nâng cấp UI/UX app Flutter

## Kết quả

Cả 5 phase đã làm trên `develop-dat` (chưa commit). `flutter analyze`: không có vấn đề. `flutter test`:
78/78 pass. `flutter build web`: thành công.

## Chỉ số (đo bằng lệnh ở phase 05, từ `app/`)

| Chỉ số | Trước | Sau | Mục tiêu |
|---|---|---|---|
| `Color(0x` ngoài `app_theme.dart` | 35 | 0 | 0 ✅ |
| `fontSize:` trong `lib/features` | 57 | 0 | 0 ✅ |
| Spinner toàn màn khi tải lần đầu | 8 | 0 | 0 ✅ |
| Màn danh sách có kéo-làm-mới | 3/7 | 7/7 | 7/7 ✅ |
| Semantics / tooltip / semanticsLabel | 11 | 38 | — |
| Widget test | 1 (placeholder) | 78 | — |

## Ma trận bố cục (tự động)

`test/features/layout_matrix_test.dart`: 8 màn × {360×800, 768×1024, 1280×800} × chữ {100%, 200%} = 48 ca.
Lần chạy đầu phát hiện **14 lỗi tràn thật ở chữ 200%**, đã sửa hết:

- Thanh đầu trang web cao cố định 68 → cao tối thiểu, chữ cắt "…".
- Thanh bên web không cuộn → cuộn được khi 7 mục không vừa.
- `StatusChip` cao cố định 24 → cao tối thiểu, chữ co lại.
- `SegmentedPills` (lọc tầng) tràn ngang ở 360px → xuống dòng.
- `EmptyState` không cuộn → cuộn được.
- Đầu trang Bảo trì: mô tả bị nút ép thành cột hẹp → `Wrap`.
- Thẻ việc dọn ở cột hẹp: chip đè số phòng → xuống dòng.
- Bảng Phòng (web) bị ép khi cửa sổ thấp → bảng tối thiểu 360px, cả cột cuộn.
- Tên app trên màn đăng nhập (mobile + web) không co → `Flexible`.

Font trong test rộng hơn font thật, nên ma trận khắt khe hơn thực tế — pass ở đây là biên an toàn.

## Số thao tác (đếm theo code, trước → sau)

| Luồng | Trước | Sau |
|---|---|---|
| Nhận phòng, không chọn ngày trả | 3 chạm | 3 chạm |
| Nhận phòng, có ngày trả (1–3 đêm) | 7 chạm (ô → ngày → OK → OK giờ) | 4 chạm (nút "N đêm") |
| Trả phòng từ màn Phòng / Lưu trú | 3 / 2 | 3 / 2 (giữ bước xác nhận) |
| Báo hỏng từ chi tiết phòng | 4 chạm | 3 chạm (ô mô tả tự focus) |
| Báo hỏng từ màn Bảo trì | 5 chạm | 5 chạm |
| Lọc lưới Tổng quan theo nhóm | 1 chạm (pill dưới thẻ số liệu) | 1 chạm, thêm cách bấm thẳng thẻ số liệu |

## Lỗi thật phát hiện ngoài kế hoạch

- Ô tìm kiếm màn Phòng hiện trống khi quay lại màn dù bộ lọc trong provider vẫn còn → khởi tạo từ provider.
- `OverdueBadge` bị trình đọc màn hình đọc lặp "Quá hạn" hai lần → bỏ đọc phần chữ bên trong.
- Màu chữ "Sẵn sàng" trên nền xanh nhạt 4.49:1 (dưới chuẩn 4.5) → `#2D7A31`, 4.67:1.

## Lệch so với plan (có lý do)

- **Form tài khoản không thêm `autofillHints`**: form dùng để tạo tài khoản cho *người khác*, tự điền sẽ chèn
  tên/số điện thoại của chính quản lý. Autofill giữ ở màn Đăng nhập và Đổi mật khẩu.
- **Nhật ký giữ dropdown lọc**, không đổi sang pill: phase 04 có ràng buộc giữ bố cục PR #8.
- **Chi tiết phòng không làm thanh hành động cố định đáy sheet**: sheet đã kéo được và hành động chính
  nằm trong tầm nhìn ban đầu (75% màn); thanh cố định sẽ bị bàn phím che khi nhập form nhận phòng.
- **Không ghi `docs/_shared/changelog.md`**: file ghi rõ chỉ hook `ba-kit-run.mjs` được ghi. Tài liệu mới
  là `docs/_shared/design-system.md`, đã link từ `README.md`.
- **Mật khẩu tạm**: giữ nút "Sao chép" có chữ thay vì thêm tooltip — nút có nhãn rõ hơn tooltip.

## Chưa kiểm được (cần người làm)

- Chạy thật trên Android với TalkBack cho luồng nhân viên dọn phòng.
- Chạy thật trên Chrome chỉ bằng bàn phím cho luồng lễ tân (nhận → trả phòng).
- So ảnh chụp trước/sau các màn của PR #8 (Đăng nhập, Tài khoản, Nhật ký, Dọn phòng) để chắc không lệch màu.
  Thay đổi màu duy nhất có chủ đích: xanh "Sẵn sàng" đậm hơn một chút.
