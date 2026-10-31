## WBS và phạm vi

- **WBS ID:** `Sx-OWNER-NNN` (một hoặc nhiều mã)
- **WBS Issue:** #... (bắt buộc gắn trước khi yêu cầu review)
- **Tóm tắt WBS:**

## Outcome

Mô tả đầu ra quan sát được. Không dùng title chung chung thay cho task WBS.

## Branch

- Source:
- Target: `develop` (personal/feature) or `main` (release/hotfix only)

## Checks

- [ ] No secrets committed
- [ ] Personal branch is not targeting `main`
- [ ] Tests / hygiene considered (ghi lệnh và kết quả bên dưới)
- [ ] Evidence URL (PR/commit, test/CI, artefact) đã gắn vào WBS Issue

## Validation và evidence

- **Lệnh/CI đã chạy:**
- **Kết quả:**
- **Evidence URL:**

## Acceptance trước Done

- **Loại acceptance:** UAT / Stakeholder sign-off / Reviewer approval / Not applicable
- **Acceptance owner / reviewer:**
- [ ] Issue được chuyển sang `Review` sau merge vào `develop`; merge không tự là `Done`.
- [ ] Điều kiện acceptance phù hợp đã được kiểm tra trước khi chuyển card sang `Done`.

## Notes
