# Use Case: Xem nhật ký chung toàn hệ thống

> Scope: Nhật ký truy vết · Level: sea

## Primary Actor

Quản lý

## Trigger

Quản lý mở nhật ký chung để rà soát sự kiện toàn hệ thống, gồm sự kiện không gắn phòng (ví dụ auth).

## Preconditions

- Quản lý đã đăng nhập với vai trò quản lý.
- Năng lực P1 (FR-audit-log-010 / CAP-audit-log-06) được triển khai trong phạm vi đang xem xét.

## Guarantees

- **Minimal Guarantee:** Vai trò khác không đọc được; lỗi tải/rỗng không hiện dữ liệu sai.
- **Success Guarantee:** Quản lý thấy nhật ký toàn hệ thống (gồm sự kiện không gắn phòng), có thể lọc theo loại hành động, trục trạng thái và loại đối tượng, tải theo phần, mới nhất trước.

## Main Success Scenario

1. Quản lý mở màn nhật ký chung.
2. Hệ thống kiểm tra quyền xem ở máy chủ.
3. Hệ thống trả bản ghi toàn hệ thống theo thời gian (mới nhất trước), tải theo phần.
4. Quản lý (tuỳ chọn) áp dụng lọc loại hành động / trục / loại đối tượng / thời gian / người.
5. Quản lý đọc kết quả để rà soát vận hành hoặc đối chiếu với nhu cầu tổng hợp của `ai-ops-summary`.

## Extensions

**2a. Không đủ quyền:**
- 2a1. Hệ thống từ chối (E-audit-log-001).
- 2a2. Use case kết thúc.

**3a. Mất kết nối:**
- 3a1. Báo E-audit-log-003; thử lại → resume bước 3.

**3b. Phạm vi rỗng:**
- 3b1. Hiển thị E-audit-log-004 (trạng thái rỗng, không lỗi).

**4a. Lọc thời gian không hợp lệ:**
- 4a1. Báo E-audit-log-002; chỉnh lại → resume bước 4.

## Related Requirements

- FR-audit-log-010, FR-audit-log-011, FR-audit-log-012
- CAP-audit-log-06
- Quan hệ `auth-roles` FR-auth-roles-014: màn xem/lọc cơ bản; nhật ký chung mở rộng phạm vi ops (trục, loại đối tượng) — cùng nguyên tắc chỉ quản lý.
