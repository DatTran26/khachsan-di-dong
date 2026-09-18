# Use Case: Xem nhật ký theo phòng

> Scope: Nhật ký truy vết · Level: sea

## Primary Actor

Quản lý

## Trigger

Quản lý mở nhật ký của một phòng để truy vết thay đổi.

## Preconditions

- Quản lý đã đăng nhập với vai trò quản lý (FR-audit-log-009, BR-audit-log-003).
- Phòng đích tồn tại trong danh mục.

## Guarantees

- **Minimal Guarantee:** Vai trò khác quản lý không đọc được dữ liệu nhật ký; khi tải lỗi hoặc rỗng thì không hiện dữ liệu sai.
- **Success Guarantee:** Quản lý thấy dòng thời gian bản ghi của phòng (mới nhất trước), mỗi dòng đủ ai/khi/hành động/trục hoặc trường/trước→sau.

## Main Success Scenario

1. Quản lý chọn một phòng và mở nhật ký theo phòng.
2. Hệ thống kiểm tra quyền xem nhật ký ở máy chủ.
3. Hệ thống trả danh sách bản ghi của phòng theo thời gian (mới nhất trước), tải theo phần.
4. Quản lý đọc từng dòng: người thực hiện, thời điểm, hành động, trục/trường, giá trị trước→sau.
5. Quản lý xác định được chuỗi thay đổi liên quan tranh chấp (nếu có).

## Extensions

**2a. Vai trò không phải quản lý:**
- 2a1. Giao diện không có mục nhật ký; máy chủ từ chối đọc (E-audit-log-001).
- 2a2. Use case kết thúc với Minimal Guarantee.

**3a. Mất kết nối khi tải:**
- 3a1. Hệ thống báo E-audit-log-003.
- 3a2. Quản lý thử lại khi có mạng → resume bước 3.

**3b. Không có bản ghi trong phạm vi:**
- 3b1. Hệ thống hiển thị trạng thái rỗng rõ ràng (E-audit-log-004), không báo lỗi.
- 3b2. Use case kết thúc thành công với trạng thái rỗng.

**3c. Khung thời gian mặc định / số dòng mỗi lần tải:**
- 3c1. Giá trị cụ thể theo `spec.md#OQ-1` — chưa chốt; không tự đặt số trong UC.

## Related Requirements

- FR-audit-log-007, FR-audit-log-009, FR-audit-log-011
- BR-audit-log-003
- CAP-audit-log-04
- OQ: `spec.md#OQ-1`, `spec.md#OQ-2` (read-audit tạm không ghi)
