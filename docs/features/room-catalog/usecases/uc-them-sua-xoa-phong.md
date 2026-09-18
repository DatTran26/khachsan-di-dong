# Use Case: Thêm / sửa / xóa phòng

> Scope: Room Catalog · Level: sea

## Primary Actor

Quản lý

## Trigger

Quản lý mở danh mục phòng và chọn thêm phòng mới, sửa một phòng, hoặc xóa một phòng.

## Preconditions

- Actor đã đăng nhập với quyền quản lý (lễ tân thêm/sửa đang mở — xem `spec.md#OQ-1`).
- Danh mục loại phòng có ít nhất một loại đang dùng (khi thêm/sửa).

## Guarantees

- __Minimal Guarantee:__ Nếu lưu thất bại, danh mục và form giữ nguyên dữ liệu đã nhập; không tạo phòng nửa chừng.
- __Success Guarantee:__ Phòng được thêm với trạng thái mặc định trống + sạch + bình thường; hoặc sửa/xóa thành công; mọi thay đổi có nhật ký ai/khi/trước→sau và phát realtime.

## Main Success Scenario

1) Quản lý mở danh mục phòng và chọn "Thêm phòng" (hoặc chọn phòng → "Sửa" / "Xóa").
2) Hệ thống hiển thị form số phòng, tầng, loại phòng (thêm/sửa) hoặc hộp xác nhận xóa.
3) Quản lý nhập/chỉnh số phòng (bắt buộc, duy nhất), tầng (số nguyên dương), loại phòng từ danh mục; xác nhận lưu hoặc xóa.
4) Hệ thống kiểm tra quyền và điều kiện tại thời điểm ghi.
5) Thêm: tạo phòng với lưu trú=trống, vệ sinh=sạch, bảo trì=bình thường; Sửa: cập nhật trường; Xóa: xóa cứng khi đủ điều kiện.
6) Hệ thống ghi nhật ký trước→sau và phát realtime tới thiết bị đang mở.
7) Hệ thống hiển thị danh mục cập nhật.

## Extensions

__3a. Số phòng trùng khi thêm/sửa (E-room-catalog-001):__
- 3a1. Hệ thống từ chối lưu, giữ form, báo "Số phòng {số} đã tồn tại trong danh mục."
- 3a2. Use case kết thúc ở Minimal Guarantee.

__4a. Xóa phòng đang ở / đang dọn / có việc mở (E-room-catalog-002):__
- 4a1. Hệ thống từ chối xóa kèm lý do.
- 4a2. Use case kết thúc.

__4b. Xóa phòng đã có lịch sử (E-room-catalog-003):__
- 4b1. Hệ thống từ chối xóa cứng, gợi ý đặt "Ngừng phục vụ".
- 4b2. Use case kết thúc.

__4c. Mất mạng khi lưu (E-room-catalog-005):__
- 4c1. Hệ thống báo thao tác chưa lưu; danh mục giữ nguyên.

__4d. Trạng thái đã đổi đồng thời (E-room-catalog-006):__
- 4d1. Hệ thống từ chối, yêu cầu tải lại.

__4e. Sai quyền (E-room-catalog-007):__
- 4e1. Hệ thống từ chối thao tác.

## Related Requirements

- FR-room-catalog-001 — thêm phòng, số duy nhất
- FR-room-catalog-002 — trạng thái mặc định phòng mới
- FR-room-catalog-003 — sửa phòng + nhật ký
- FR-room-catalog-004 — điều kiện xóa
- FR-room-catalog-012 — kiểm quyền + nhật ký máy chủ
- NFR-room-catalog-001 — realtime ≤3s
