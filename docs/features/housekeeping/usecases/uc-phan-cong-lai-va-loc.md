# Use Case: Phân công lại và lọc danh sách việc

> Scope: housekeeping · Level: sea · FR-housekeeping-009, FR-housekeeping-010

## Primary Actor

Quản lý (phân công lại); Quản lý và Nhân viên buồng phòng (lọc)

## Trigger

Quản lý chọn phân công lại một việc đang mở; hoặc người dùng đặt bộ lọc danh sách.

## Preconditions

- Người dùng đã đăng nhập đúng vai trò.
- Việc đang mở (chưa "hoàn tất") khi phân công lại.
- Người được giao lại đang trực (nguồn trực — OQ-1).

## Guarantees

- **Minimal Guarantee:** Không đổi người khi sai quyền/mất mạng; lọc 0 kết quả hiển thị trạng thái rỗng rõ (không báo lỗi hệ thống).
- **Success Guarantee (phân công lại):** Việc gắn NV mới đang trực; nhật ký mỗi lần đổi người (FR-housekeeping-009).
- **Success Guarantee (lọc):** Danh sách theo nhân viên phụ trách / trạng thái việc / phòng (FR-housekeeping-010).

## Main Success Scenario (Phân công lại)

1) Quản lý mở danh sách công việc, chọn việc đang mở.
2) Quản lý chọn NV buồng phòng đang trực khác.
3) Hệ thống kiểm tra quyền quản lý và trạng thái việc.
4) Hệ thống gán lại phụ trách; ghi nhật ký; phát realtime.

## Main Success Scenario (Lọc)

1) Người dùng mở danh sách việc (của tôi / toàn bộ tùy vai trò).
2) Người dùng chọn lọc theo NV / trạng thái / phòng.
3) Hệ thống trả danh sách khớp; 0 kết quả → trạng thái rỗng rõ.

## Extensions

**3a. Sai quyền (E-housekeeping-006):** từ chối phân công lại.
**3b. Mất mạng (E-housekeeping-003):** khóa ghi phân công lại.

## Related Requirements

- FR-housekeeping-009, FR-housekeeping-010, FR-housekeeping-013
- OQ: `spec.md#OQ-1`
