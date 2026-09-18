# Use Case: Nhận việc bảo trì

> Scope: maintenance · Level: sea · CAP-maintenance-03

## Primary Actor

Nhân viên bảo trì (vai trò gộp buồng phòng–bảo trì)

## Trigger

Nhân viên chọn một việc đang "chờ nhận" và nhận việc.

## Preconditions

- Nhân viên đã đăng nhập với vai trò buồng phòng–bảo trì.
- Việc tồn tại ở trạng thái "chờ nhận".

## Guarantees

- **Minimal Guarantee:** Không gán người xử lý khi xung đột nhận hoặc sai trạng thái; danh sách được tải lại khi từ chối.
- **Success Guarantee:** Việc chuyển "đang sửa", gắn người xử lý là nhân viên nhận; nhật ký + realtime cập nhật.

## Main Success Scenario

1) Nhân viên mở danh sách việc bảo trì.
2) Hệ thống hiển thị việc kèm phòng, mô tả, vị trí, trạng thái, người xử lý (FR-maintenance-004).
3) Nhân viên mở chi tiết một việc "chờ nhận" và chọn nhận việc.
4) Hệ thống kiểm tra quyền (BR-maintenance-03) và trạng thái còn "chờ nhận".
5) Hệ thống chuyển việc sang "đang sửa", gán người xử lý.
6) Hệ thống ghi nhật ký và phát realtime (FR-maintenance-011).
7) Hệ thống xác nhận nhận việc thành công.

## Extensions

**4a. Hai thiết bị cùng nhận (E-maintenance-001):**
- 4a1. Hệ thống từ chối thao tác sau, báo "Công việc này đã có người khác nhận."
- 4a2. Tải lại danh sách; use case kết thúc.

**4b. Thao tác sai trạng thái (E-maintenance-004):**
- 4b1. Từ chối + gợi ý tải lại.
- 4b2. Use case kết thúc.

**4c. Sai quyền (E-maintenance-006):**
- 4c1. Từ chối + ghi nhật ký.

**5a. Mất mạng (E-maintenance-002):**
- 5a1. Khóa ghi, báo chưa lưu.

## Related Requirements

- FR-maintenance-004, FR-maintenance-011
- BR-maintenance-03
- CAP-maintenance-03
