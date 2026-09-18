# Use Case: Ghi bản ghi nhật ký khi thao tác ghi thành công

> Scope: Nhật ký truy vết · Level: sea

## Primary Actor

Hệ thống

## Stakeholders & Interests

- Quản lý — cần chuỗi trước→sau đáng tin khi tranh chấp.
- `ai-ops-summary` — cần đủ trường để đếm/nhóm theo kỳ.

## Trigger

Một thao tác ghi (đổi trạng thái phòng, thao tác nghiệp vụ, sự kiện auth, hoặc hành động tự động) được máy chủ kiểm quyền và sẵn sàng lưu.

## Preconditions

- Máy chủ đã xác định người thực hiện (định danh + vai trò) hoặc xác định đây là hành động tự động ("hệ thống").
- Thao tác đã được kiểm quyền thành công (BR-audit-log-001).

## Guarantees

- **Minimal Guarantee:** Nếu phần nhật ký không lưu được, thao tác ghi tương ứng không hoàn tất; không để thay đổi dữ liệu tồn tại mà thiếu bản ghi (FR-audit-log-006, BR-audit-log-002). Thao tác bị từ chối quyền không sinh bản ghi.
- **Success Guarantee:** Có đúng một bản ghi nhật ký cho thao tác, gồm thời điểm máy chủ, người thực hiện, hành động, đối tượng kèm nhãn tại thời điểm ghi, và danh sách thay đổi đủ từng trục/trường trước→sau; bản ghi bất biến, không chứa mật khẩu.

## Main Success Scenario

1. Hệ thống nhận thao tác ghi đã kiểm quyền.
2. Hệ thống chuẩn bị nội dung bản ghi: thời điểm máy chủ, người thực hiện (hoặc "hệ thống"), hành động, đối tượng + nhãn chụp, danh sách thay đổi.
3. Nếu thay đổi trạng thái phòng, hệ thống liệt kê rõ từng trục (lưu trú / vệ sinh / bảo trì) với giá trị trước→sau.
4. Hệ thống lưu thay đổi dữ liệu và bản ghi nhật ký như một kết quả duy nhất.
5. Hệ thống xác nhận thao tác hoàn tất; bản ghi sẵn sàng cho xem/lọc và cho `ai-ops-summary` đếm/nhóm.

## Extensions

**2a. Thao tác bị từ chối quyền:**
- 2a1. Hệ thống không đổi dữ liệu và không sinh bản ghi (BR-audit-log-001).
- 2a2. Use case kết thúc (Minimal Guarantee: không có bản ghi giả).

**3a. Hành động tự động (tự tạo việc, cờ quá hạn, khóa TK, hủy phiên…):**
- 3a1. Hệ thống đặt người thực hiện = "hệ thống" (FR-audit-log-003).
- 3a2. Tiếp tục bước 4.

**3b. Sự kiện auth (đăng nhập/đăng xuất/hết phiên/khóa/mở/đổi MK):**
- 3b1. Hệ thống ghi theo định nghĩa `auth-roles`; không ghi giá trị mật khẩu (FR-audit-log-004).
- 3b2. Tiếp tục bước 4.

**4a. Lưu phần nhật ký thất bại:**
- 4a1. Hệ thống báo thao tác "chưa hoàn tất" (E-audit-log-005).
- 4a2. Use case kết thúc với Minimal Guarantee — không có thay đổi mồ côi thiếu nhật ký.

## Related Requirements

- FR-audit-log-001, FR-audit-log-002, FR-audit-log-003, FR-audit-log-004, FR-audit-log-005, FR-audit-log-006, FR-audit-log-012
- BR-audit-log-001, BR-audit-log-002, BR-audit-log-004, BR-audit-log-005, BR-audit-log-006
- CAP-audit-log-01, CAP-audit-log-02, CAP-audit-log-03
