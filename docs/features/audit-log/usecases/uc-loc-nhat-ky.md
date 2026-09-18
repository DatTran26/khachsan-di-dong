# Use Case: Lọc nhật ký theo thời gian và người thao tác

> Scope: Nhật ký truy vết · Level: sea

## Primary Actor

Quản lý

## Trigger

Quản lý đặt điều kiện lọc trên màn nhật ký (theo phòng hoặc nhật ký chung) để thu hẹp kết quả.

## Preconditions

- Quản lý đang ở màn nhật ký và đã được kiểm quyền xem (FR-audit-log-009).

## Guarantees

- **Minimal Guarantee:** Khoảng thời gian không hợp lệ không trả kết quả sai; mất mạng thì không hiện danh sách lệch.
- **Success Guarantee:** Kết quả là phần giao của mọi lọc đã chọn (thời gian từ–đến, vai trò/người gồm "hệ thống"; trên nhật ký chung thêm loại hành động/trục/loại đối tượng khi P1), sắp mới nhất trước.

## Main Success Scenario

1. Quản lý chọn khoảng thời gian (từ–đến) và/hoặc vai trò/người thao tác (có lựa chọn "hệ thống").
2. Hệ thống kiểm tra khoảng thời gian hợp lệ (từ ≤ đến).
3. Hệ thống trả bản ghi thỏa mọi điều kiện lọc đồng thời (phần giao).
4. Quản lý đọc danh sách đã thu hẹp.

## Extensions

**1a. Trên nhật ký chung (P1) — lọc thêm loại hành động / trục / loại đối tượng:**
- 1a1. Quản lý bổ sung các lọc mở rộng (FR-audit-log-010).
- 1a2. Tiếp tục bước 2 với đầy đủ điều kiện.

**2a. Khoảng thời gian không hợp lệ (từ sau đến):**
- 2a1. Hệ thống báo E-audit-log-002; không áp dụng lọc sai.
- 2a2. Quản lý chỉnh lại mốc → resume bước 2.

**3a. Mất kết nối khi lọc:**
- 3a1. Hệ thống báo E-audit-log-003.
- 3a2. Thử lại khi có mạng → resume bước 3.

**3b. Không có bản ghi thỏa lọc:**
- 3b1. Hệ thống hiển thị trạng thái rỗng (E-audit-log-004).
- 3b2. Use case kết thúc với trạng thái rỗng hợp lệ.

**2b. Vai trò bị từ chối giữa phiên:**
- 2b1. Hệ thống từ chối đọc (E-audit-log-001).
- 2b2. Use case kết thúc.

## Related Requirements

- FR-audit-log-008, FR-audit-log-010, FR-audit-log-011
- CAP-audit-log-05, CAP-audit-log-06
- OQ: `spec.md#OQ-1`
