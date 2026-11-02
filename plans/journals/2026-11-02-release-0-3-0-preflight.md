# Nhật ký chuẩn bị phát hành 0.3.0

**Date**: 2026-11-02
**Severity**: Medium
**Component**: Release app Flutter, backend Node/Prisma và CI
**Status**: Ongoing

## What Happened

Từ mốc 0.2.0 (`082f810`) đến HEAD `3b4fd26`, nhánh release gom các thay đổi đã tích hợp: ô phòng PMS, thao tác nhanh/check-in và tìm phòng; slideshow đăng nhập; design token, skeleton, trạng thái offline/reconnect và kiểm thử responsive/accessibility; REST/Socket.IO đọc `API_URL`; xử lý handshake hết phiên/tài khoản khóa, đăng xuất lặp và state cũ; AI summary có request ID, trần chi phí mỗi lượt và fixture dashboard; cùng workflow CI cho app và backend. Quyết định phiên bản là app `0.3.0+3`, server `0.3.0`, changelog và release note cùng ngày.

## The Brutal Truth

Phần mã nguồn của release đã được gom, nhưng release chưa đủ bằng chứng để gọi là đã ship. Kế hoạch đang `ready-for-pr`; việc dùng worktree cô lập giúp bộ ảnh hướng dẫn chụp sai ở checkout chính không bị kéo vào release, nhưng cũng không biến các gate còn thiếu thành đạt. Cảm giác khó chịu là phạm vi nhìn khá hoàn chỉnh trong diff, trong khi bằng chứng vận hành thực tế vẫn trống.

## Technical Details

Gate cục bộ đã chạy trên đúng mã nguồn `3b4fd26`: backend lint, typecheck, build, 7 migration, 3 seed, 353/353 test và benchmark realtime 30 client/100 lượt đều đạt; Flutter 3.47.4 analyze, 133/133 test và web build cũng đạt. Docker image chưa được xác minh vì Docker Desktop daemon đang tắt. Chưa có trong repository/GitHub biên bản UAT, manual accessibility, visual regression, APK release, deploy smoke test hoặc CI sau merge.

## What We Tried

- Đối soát changelog, release note, plan, diff và git log thay vì suy diễn từ tên nhánh.
- Chạy toàn bộ gate backend/Flutter khả dụng và dọn database test cùng tiến trình validation sau khi hoàn tất.
- Giữ ảnh sai ngoài worktree release và không sửa checkout chính.
- Ghi rõ phiên bản và các gate chưa có bằng chứng; không đánh dấu hoàn tất giả.

## Root Cause Analysis

Release đang dựa trên các thay đổi đã merge và workflow đã viết, nhưng quy trình kiểm chứng cuối kỳ chưa tạo artifact/receipt tương ứng. Đây là thiếu bằng chứng phát hành, không phải lỗi version: app/server đã thống nhất `0.3.0+3`/`0.3.0`.

## Lessons Learned

Workflow CI và test commit chỉ chứng minh ý định kiểm tra. Trước khi tuyên bố ship phải lưu kết quả chạy, review và artifact theo đúng commit/tag; không dùng screenshot sai hoặc wireframe thay cho UAT.

## Next Steps

Chủ release cần kiểm tra PR/CI xanh, xác minh Docker image khi daemon khả dụng, rồi xử lý các ràng buộc chưa hoàn tất của #215 (go/no-go/bàn giao), #228 (APK Android), #230 và #237 (QA/UAT/ảnh). Không được tuyên bố các issue này đã xong khi chưa có acceptance evidence; chỉ gắn tag `v0.3.0` và tạo GitHub Release sau khi gate phát hành cho phép.
