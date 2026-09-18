---
type: srs-spec
feature: room-catalog
status: draft
updated: 2026-09-17
links:
  - "[[docs/features/room-catalog/room-catalog-prd.md|PRD — Room Catalog]]"
  - "[[docs/features/room-catalog/room-catalog-brd.md|BRD — Room Catalog]]"
  - "[[docs/features/room-catalog/room-catalog-urd.md|URD — Room Catalog]]"
---

# SRS — Room Catalog (Tầng 1 — Core Spec)

## 1. Purpose & Scope

Đặc tả lõi cho `room-catalog`: danh mục 50 phòng giả lập, mỗi phòng mang 3 trục trạng thái riêng (lưu trú / vệ sinh / bảo trì), CRUD bởi quản lý, tra cứu cho mọi vai trò, realtime + nhật ký. Tài liệu này chỉ phủ Tầng 1 — không có use case chi tiết, luồng màn hình, ERD, sơ đồ trạng thái, wireframe, user story hay tiêu chí nghiệm thu mở rộng.

## 2. Actors

| Actor | Loại | Quyền trong feature |
|---|---|---|
| Quản lý | Người | Thêm/sửa/xóa phòng, đặt/gỡ ngừng phục vụ, tra cứu, quản lý loại phòng |
| Lễ tân | Người | Tra cứu; đặt/gỡ ngừng phục vụ; thêm/sửa phòng đang mở — OQ-1 |
| Nhân viên buồng–bảo trì | Người | Tra cứu |
| Hệ thống | Tự động | Khởi tạo trạng thái mặc định phòng mới; ghi nhật ký; phát realtime |

## 3. Functional Requirements

| ID | FR | Actor | P | Trace |
|---|---|---|---|---|
| FR-room-catalog-001 | Thêm phòng: nhập số phòng (bắt buộc, duy nhất), tầng (bắt buộc, số nguyên dương), loại phòng (bắt buộc, từ danh mục loại); từ chối khi số trùng | Quản lý | P0 | CAP-room-catalog-01, UN-01 |
| FR-room-catalog-002 | Phòng mới tạo mặc định: lưu trú = trống, vệ sinh = sạch, bảo trì = bình thường | Hệ thống | P0 | CAP-room-catalog-02 |
| FR-room-catalog-003 | Sửa phòng (tầng/loại/số); số phòng sửa đổi vẫn phải duy nhất; ghi nhật ký giá trị trước→sau | Quản lý | P0 | CAP-room-catalog-01, UN-02 |
| FR-room-catalog-004 | Xóa phòng chỉ khi: trống + không việc đang mở + chưa có lịch sử hoạt động; ngoài ra từ chối kèm lý do và gợi ý "ngừng phục vụ" | Quản lý | P0 | CAP-room-catalog-01, BREQ-03 |
| FR-room-catalog-005 | Mỗi phòng hiển thị 3 trục trạng thái riêng; "sẵn sàng" = trống + sạch + bình thường là giá trị suy ra, không lưu riêng | Hệ thống | P0 | CAP-room-catalog-02, BREQ-04 |
| FR-room-catalog-006 | Tra cứu/lọc danh mục theo tầng, loại phòng, trạng thái từng trục; lọc rỗng hiển thị trạng thái rỗng | Mọi vai trò | P0 | CAP-room-catalog-03 |
| FR-room-catalog-007 | Đặt "ngừng phục vụ" thủ công: bắt buộc nhập lý do; phòng đang có khách thì cảnh báo + xác nhận lại; phòng vẫn chặn nhận khách mới | Quản lý, Lễ tân | P1 | CAP-room-catalog-06 |
| FR-room-catalog-008 | Gỡ "ngừng phục vụ" → trục bảo trì về "bình thường"; phòng lại "sẵn sàng" nếu trống + sạch | Quản lý, Lễ tân | P1 | CAP-room-catalog-06 |
| FR-room-catalog-009 | Tạo nhanh nhiều phòng theo dải (tầng + khoảng số + loại); bỏ qua số đã tồn tại và báo rõ số nào bị bỏ | Quản lý | P1 | CAP-room-catalog-07 |
| FR-room-catalog-010 | Quản lý loại phòng: thêm/sửa/tắt loại; phòng phải chọn loại từ danh sách hiện có | Quản lý | P1 | CAP-room-catalog-08 |
| FR-room-catalog-011 | Mọi thay đổi danh mục phát realtime tới thiết bị đang mở | Hệ thống | P0 | CAP-room-catalog-05, BREQ-06 |
| FR-room-catalog-012 | Mọi thao tác ghi kiểm tra quyền ở máy chủ và ghi nhật ký ai/khi/hành động/trước→sau | Hệ thống | P0 | CAP-room-catalog-05, BREQ-05 |

## 4. Non-Functional Requirements

| ID | NFR | Giá trị | Trace |
|---|---|---|---|
| NFR-room-catalog-001 | Cập nhật danh mục hiển thị trên thiết bị khác trong ≤3 giây | ≥95% lượt (tôn chỉ) | BREQ-06 |
| NFR-room-catalog-002 | Kiểm tra quyền và ghi nhật ký ở máy chủ — không tin client | Tôn chỉ | BREQ-05 |
| NFR-room-catalog-003 | Giao diện tiếng Việt; web cho quản lý/lễ tân, Android cho nhân viên | Tôn chỉ | Scope |
| NFR-room-catalog-004 | ~10 phiên đồng thời; cập nhật đồng thời bị chặn bằng kiểm tra trạng thái | Tôn chỉ | BRD Risk |

## 5. Business Rules

- Số phòng duy nhất toàn danh mục — bắt buộc, không rỗng, kiểm tra cả khi sửa.
- Phòng mới mặc định trống + sạch + bình thường.
- Chặn xóa khi phòng đang ở, đang dọn, có việc mở hoặc đã có lịch sử — rút khỏi vận hành qua "ngừng phục vụ".
- Trục lưu trú/vệ sinh chỉ đổi qua `check-in-out`/`housekeeping`; trục bảo trì đổi qua `maintenance` hoặc đặt/gỡ tay.
- Đặt ngừng phục vụ bắt buộc lý do; phòng đang ở vẫn đặt được sau cảnh báo (khách ở hết kỳ).
- Mọi thay đổi ghi nhật ký ai/khi/trước→sau.

## 6. Error Matrix

| ID | Tình huống | Behavior | Thông báo (mẫu) |
|---|---|---|---|
| E-room-catalog-001 | Số phòng trùng khi thêm/sửa | Từ chối lưu, giữ form | "Số phòng {số} đã tồn tại trong danh mục." |
| E-room-catalog-002 | Xóa phòng đang ở/đang dọn/có việc mở | Từ chối xóa | "Không thể xóa — phòng đang có khách / có việc đang mở." |
| E-room-catalog-003 | Xóa phòng đã có lịch sử | Từ chối xóa cứng, gợi ý ngừng phục vụ | "Phòng đã có lịch sử hoạt động — không xóa được. Hãy đặt 'Ngừng phục vụ'..." |
| E-room-catalog-004 | Thiếu lý do ngừng phục vụ | Từ chối lưu | "Vui lòng nhập lý do ngừng phục vụ." |
| E-room-catalog-005 | Mất mạng khi lưu | Thao tác chưa lưu, danh mục giữ nguyên | "Mất kết nối — thao tác chưa được lưu. Thử lại khi có mạng." |
| E-room-catalog-006 | Ghi khi trạng thái đã đổi (đồng thời) | Từ chối, yêu cầu tải lại | "Thao tác không hợp lệ ở trạng thái hiện tại. Tải lại để xem trạng thái mới nhất." |
| E-room-catalog-007 | Sai quyền | Từ chối thao tác | "Bạn không có quyền thực hiện thao tác này." |

## 7. Success Criteria

| ID | Tiêu chí |
|---|---|
| SC-room-catalog-001 | 50/50 phòng khớp dữ liệu giả lập (số/tầng/loại) khi nghiệm thu |
| SC-room-catalog-002 | ≥95% lượt thay đổi danh mục hiển thị trên thiết bị khác ≤3s |
| SC-room-catalog-003 | 0 số phòng trùng; 0 xóa sai điều kiện |
| SC-room-catalog-004 | 100% thay đổi danh mục có nhật ký ai/khi/trước→sau |
| SC-room-catalog-005 | Lễ tân tra được phòng "sẵn sàng" trong UAT không cần hỏi buồng phòng |

## 8. Entity Summary

| Entity | Thuộc tính chính | Ghi chú |
|---|---|---|
| Phòng | Số phòng (duy nhất), tầng, loại phòng; 3 trục: lưu trú (trống/đang ở), vệ sinh (cần dọn/đang dọn/chờ kiểm tra/sạch), bảo trì (bình thường/ngừng phục vụ) | "Sẵn sàng" là composite, không lưu riêng |
| Loại phòng | Tên loại, trạng thái dùng/ngừng | Danh mục quản lý tự định nghĩa (P1) |
| Nhật ký danh mục | Ai, khi nào, hành động, giá trị trước→sau | Ghi trên mọi thay đổi danh mục |

## 9. Flow Summary

- Nhập danh mục: thêm phòng → kiểm tra trùng → tạo trạng thái mặc định → nhật ký → realtime.
- Sửa phòng → kiểm tra trùng số → lưu → nhật ký → realtime.
- Xóa phòng → kiểm tra điều kiện → xóa hẳn (chưa lịch sử) hoặc từ chối kèm gợi ý ngừng phục vụ.
- Đặt/gỡ ngừng phục vụ → đổi trục bảo trì → nhật ký → realtime.
- Tra cứu/lọc → hiển thị phòng + 3 trục tại thời điểm xem.

## 10. Screen Summary

- Danh mục phòng (danh sách + lọc theo tầng/loại/trạng thái) — mọi vai trò.
- Thêm/sửa phòng (form số/tầng/loại) — quản lý.
- Tạo theo dải (P1) — quản lý.
- Xác nhận ngừng phục vụ (nhập lý do; cảnh báo nếu đang ở) — quản lý, lễ tân.

## 11. Constraints & Dependencies

- Phụ thuộc `auth-roles` cho đăng nhập + phân quyền.
- Là dependency của `check-in-out`, `housekeeping`, `maintenance`, `room-dashboard`.
- Ràng buộc tôn chỉ: 3 trục riêng; kiểm quyền + nhật ký ở máy chủ; realtime ≤3s; ~10 phiên; tiếng Việt; dữ liệu giả lập.

## 12. Assumptions

- Phòng mới mặc định trống + sạch + bình thường.
- Loại phòng tự định nghĩa; phòng chọn loại từ danh sách.
- Phòng có lịch sử không xóa cứng.
- Lễ tân đặt/gỡ ngừng phục vụ (project-profile); thêm/sửa phòng của lễ tân đang mở (OQ-1).

## 13. Open Questions

- [ ] OQ-1: Quyền của lễ tân với danh mục — chỉ tra cứu + đặt/gỡ ngừng phục vụ, hay cả thêm/sửa phòng?
- [ ] OQ-2: Cách nạp danh mục ban đầu 50 phòng — nhập tay, theo dải, hay nạp sẵn giả lập? Cho phép vượt 50?
- [ ] OQ-3: Quy ước đánh số phòng có bắt buộc không?
