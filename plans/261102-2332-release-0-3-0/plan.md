---
status: ready-for-pr
date: 2026-11-02
branch: release/0.3.0
target: main
---

# Release 0.3.0

## Outcome

Phát hành các thay đổi đã tích hợp và kiểm chứng trên `develop` thành phiên bản chính thức `0.3.0`, merge qua pull request vào `main`, gắn tag và tạo GitHub Release khi CI xanh.

## Constraints

- Không đưa bộ ảnh hướng dẫn đang chụp sai ở checkout chính vào release.
- Không bỏ qua test, review, branch protection hoặc CI.
- Không tuyên bố UAT, APK Android, deploy hay ảnh demo hoàn tất khi chưa có bằng chứng.
- Không force-push hoặc ghi trực tiếp vào `main`.

## Non-goals

- Không sửa rộng hành vi sản phẩm trong nhánh release.
- Không đóng các issue Sprint 4 chưa có acceptance evidence.
- Không triển khai production trong đợt ship này.

## Acceptance criteria

- [x] App và backend vượt qua các quality gate khả dụng.
- [ ] Review không còn finding Critical hoặc Important.
- [x] Version app/server và changelog cùng ở `0.3.0`.
- [ ] Pull request `release/0.3.0` vào `main` có CI xanh và được merge đúng GitFlow.
- [ ] Tag `v0.3.0` và GitHub Release trỏ đúng merge commit trên `main`.
- [ ] Checkout chính vẫn giữ nguyên các file ảnh/script chưa ship.

## Execution

1. Kiểm kê diff `main...develop`, issue, test và review evidence.
2. Chuẩn bị version, changelog, release note và journal trong worktree cô lập.
3. Commit, push và mở pull request vào `main`.
4. Review PR, chờ CI xanh, merge và xác minh CI sau merge.
5. Gắn tag, tạo GitHub Release và xác minh remote.

## Risks and rollback

- Dừng trước merge nếu test, review hoặc CI đỏ.
- Nếu release đã merge nhưng CI sau merge đỏ, sửa qua nhánh/PR mới; không rewrite lịch sử.
- Nếu tag hoặc GitHub Release tạo sai, không di chuyển tag đã công bố; tạo bản sửa theo quy trình release tiếp theo.
