# Use Case: Nhận hoặc từ chối việc dọn

> Scope: housekeeping · Level: sea · FR-housekeeping-004

## Primary Actor

Nhân viên buồng phòng

## Trigger

Nhân viên mở việc được giao và bấm nhận hoặc từ chối.

## Preconditions

- Nhân viên đã đăng nhập với vai trò buồng phòng.
- Việc đang ở "đã giao" (hoặc vừa được giao lại) và gắn với nhân viên này (trừ bước giao lại do từ chối).

## Guarantees

- **Minimal Guarantee:** Không đổi trạng thái khi mất mạng / sai quyền / xung đột phiên bản; thông báo rõ và yêu cầu tải lại khi cần.
- **Success Guarantee (nhận):** Việc = "đang làm"; trục vệ sinh = "đang dọn"; nhật ký + realtime.
- **Success Guarantee (từ chối):** Việc được giao lại cho người trực ít việc kế tiếp (hoặc "chờ giao" nếu hết người) + nhật ký.

## Main Success Scenario (Nhận)

1) Nhân viên mở danh sách việc của tôi / chi tiết việc "đã giao".
2) Nhân viên bấm nhận việc.
3) Hệ thống kiểm tra quyền (chỉ việc của mình) và phiên bản (FR-housekeeping-012).
4) Hệ thống chuyển việc sang "đang làm"; phòng sang "đang dọn" (FR-housekeeping-004).
5) Hệ thống ghi nhật ký và phát realtime.

## Extensions

**2a. Từ chối việc (FR-housekeeping-004):**
- 2a1. Nhân viên bấm từ chối.
- 2a2. Hệ thống ghi nhật ký từ chối; giao lại cho NV trực ít việc kế tiếp (không gồm người vừa từ chối trong vòng giao này nếu còn người khác).
- 2a3. Nếu hết người → việc về "chờ giao" + cảnh báo quản lý (E-housekeeping-002).

**3a. Việc đã có người nhận (E-housekeeping-001):**
- 3a1. Hệ thống từ chối + "Công việc này đã có người khác nhận." + tải lại danh sách.

**3b. Trạng thái đã đổi (E-housekeeping-004):**
- 3b1. Từ chối + yêu cầu tải lại trạng thái mới nhất.

**3c. Sai quyền (E-housekeeping-006):**
- 3c1. Từ chối + "Bạn không có quyền thực hiện thao tác này."

**3d. Mất kết nối (E-housekeeping-003):**
- 3d1. Khóa ghi; báo chưa lưu; thử lại khi có mạng (FR-housekeeping-011).

## Related Requirements

- FR-housekeeping-004, FR-housekeeping-011, FR-housekeeping-012, FR-housekeeping-013
- E-housekeeping-001, E-housekeeping-002, E-housekeeping-003, E-housekeeping-004, E-housekeeping-006
