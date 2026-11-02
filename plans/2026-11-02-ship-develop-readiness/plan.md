---
status: ready-for-pr
date: 2026-11-02
branch: develop-dat
target: develop
---

# Ship develop readiness

## Outcome

Rà toàn bộ issue đang mở, đồng bộ nhánh `develop-dat`, kiểm tra chất lượng, commit và push toàn bộ file hợp lệ, sau đó đưa thay đổi vào `develop` qua pull request đúng GitFlow.

## Constraints

- Không commit `.env`, secret, khóa, credential hoặc dữ liệu cá nhân.
- Không đóng issue chỉ vì code hoặc pull request liên quan đã tồn tại; từng acceptance item phải có evidence và approval.
- Không merge nhánh cá nhân thẳng vào `main` và không bỏ qua CI/branch protection.
- Giữ toàn bộ artefact mà người dùng yêu cầu push, trừ nội dung bị chặn bởi quy tắc bảo mật.

## Non-goals

- Không cắt release hoặc merge vào `main` trong đợt này.
- Không tự xác nhận UAT, deploy hoặc approval chưa có bằng chứng.

## Acceptance criteria

- [x] Kiểm kê đầy đủ issue mở và phát hiện issue trùng.
- [x] Đồng bộ `develop-dat` với `origin/develop`.
- [x] Flutter analyze, 133 test và web build đạt; backend lint, typecheck và build đạt.
- [ ] Backend integration test local cần PostgreSQL test tại `localhost:15432`; PR CI phải cung cấp gate thay thế.
- [x] Review không còn finding chặn merge.
- [x] Staged diff vượt qua kiểm tra whitespace và secret.
- [ ] Commit/push `develop-dat`, tạo PR vào `develop`, merge khi CI xanh.
- [ ] Xác minh remote `develop` chứa merge commit và ghi lại trạng thái CI.

## Execution

1. Audit issue và trạng thái Git/GitHub.
2. Đồng bộ target branch trước khi kiểm thử.
3. Chạy test, build và review độc lập.
4. Cập nhật báo cáo evidence, kiểm tra staged scope và secret.
5. Commit, push, tạo PR, review/merge và xác minh CI sau merge.

## Risks and rollback

- Nếu test, review, CI hoặc mergeability đỏ, dừng trước merge và ghi blocker.
- Nếu phát hiện secret, không commit file liên quan; giữ nguyên worktree để owner xử lý.
- Nếu merge gây lỗi sau đó, tạo nhánh fix từ `develop`; không rewrite lịch sử chia sẻ.
