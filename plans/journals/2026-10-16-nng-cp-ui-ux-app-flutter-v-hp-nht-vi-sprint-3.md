---
title: Nâng cấp UI/UX app Flutter và hợp nhất với Sprint 3
date: 2026-10-16
summary: "Token, skeleton, trợ năng, responsive cho mọi màn; PR #32 sau khi merge 171 commit develop có việc trùng"
---

# Nâng cấp UI/UX app Flutter và hợp nhất với Sprint 3

## What happened
- Lên plan 5 phase (`plans/261017-0503-ui-ux-upgrade/`) rồi làm hết trên `develop-dat`: thêm `AppText`/`AppSpacing`/màu theo ý nghĩa, `initialLoadGate` + skeleton, `OfflineActionNote`, NavigationRail cho tablet, vùng chạm 48dp, nhãn semantics.
- Test ma trận bố cục (8 màn × 3 bề rộng × chữ 100%/200%) bắt được 14 chỗ tràn thật — gốc chung là chiều cao/bề rộng cố định cho khối có chữ (top bar 68px, StatusChip 24px, Row không Flexible).
- Lỗi phát hiện thêm: ô tìm kiếm màn Phòng trống khi quay lại dù filter vẫn áp; OverdueBadge đọc lặp "Quá hạn"; xanh "Sẵn sàng" 4.49:1.
- Khi mở PR mới thấy `origin/develop` đã đi 171 commit, trùng việc (lọc bằng thẻ số liệu, màu ready, SegmentedPills cuộn ngang, tách hàm nút Dọn phòng). 7 file / 13 hunk xung đột.

## Decision
- Giải xung đột theo hướng giữ cấu trúc của develop (đã review ở PR #31) rồi áp token/48dp/skeleton lên trên; dashboard lấy nguyên file develop.
- Không ghi `docs/_shared/changelog.md` (chỉ hook `ba-kit-run.mjs` được ghi); tài liệu mới ở `docs/_shared/design-system.md`.
- Form tạo tài khoản không bật autofill (sẽ điền thông tin của chính quản lý).

## Lessons
- Fetch và so với `origin/develop` TRƯỚC khi bắt đầu một đợt thay đổi rộng — nhánh cá nhân đã cũ 171 commit.
- `dart format <thư mục>` đụng cả provider/model ngoài phạm vi; chỉ format đúng file đã sửa.
- Kiểm `jq` riêng trước khi kết luận thiếu `ak` (lệnh ghép `ak ... | jq` lỗi vì thiếu jq).

## Next steps
- Review PR #32 (Bao: Lưu trú/Bảo trì; Kim: Dọn phòng/Tài khoản/Nhật ký/Đăng nhập).
- Kiểm thủ công: TalkBack Android, bàn phím trên Chrome, so ảnh chụp các màn PR #8.
- Cân nhắc thêm job `flutter analyze` + `flutter test` vào CI.

> Historical work record — not durable authority. Prefer docs/specs/ADRs for current decisions.
