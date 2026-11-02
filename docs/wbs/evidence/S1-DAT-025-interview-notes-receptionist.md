# S1-DAT-025 — Biên bản Phỏng vấn Lễ tân về Check-in, Check-out và Ngoại lệ

- **WBS ID:** S1-DAT-025
- **Issue liên kết:** #62
- **Sprint:** Sprint 1 — Khảo sát, phỏng vấn và phân tích yêu cầu
- **Owner:** Trần Tấn Đạt (DatTran26)
- **Reviewer / Acceptance Owner:** Khách hàng
- **Mốc tham chiếu:** 2026-09-09
- **Đầu ra bắt buộc:** Interview notes lễ tân

---

## 1. Tóm tắt Phiên Phỏng vấn

- **Người được phỏng vấn:** Nhân viên Lễ tân ca trực quầy (RECEPTIONIST)
- **Người thực hiện:** Trần Tấn Đạt, Hoàng Kim
- **Bộ câu hỏi sử dụng:** S1-DAT-020 (#57)

---

## 2. Ghi nhận Thực tế và Pain Points tại Quầy Lễ tân

1. **Giao nhầm phòng chưa sẵn sàng (PP-REC-01):**
   - Giờ cao điểm (11:30–14:00), khách trả phòng liên tục. Trên sổ/bảng cũ chỉ ghi "Trống" nên lễ tân dễ giao phòng khách vừa trả nhưng buồng phòng chưa kịp dọn, hoặc phòng đang hỏng vòi nước/điều hòa.
2. **Quên báo dọn phòng sau khi khách trả (PP-REC-02):**
   - Lễ tân làm thủ tục trả phòng xong nhưng có khách mới tới hỏi nên quên nhắn Zalo cho tổ buồng phòng, làm phòng bị bỏ trống bẩn hàng giờ.
3. **Nhập liệu rườm rà lúc nhận phòng (PP-REC-03):**
   - Lễ tân cần thao tác nhận phòng dưới 30 giây, chỉ nhập thông tin cốt lõi để giao chìa khóa ngay.

---

## 3. Các Quy tắc Nghiệp vụ Đã Chốt với Lễ tân

| Mã quy tắc | Nội dung chốt | Áp dụng tại module |
|---|---|---|
| **BR-REC-01** | **Điều kiện cứng để Check-in:** Phòng bắt buộc thỏa mãn đồng thời occupancyStatus = VACANT, cleaningStatus = CLEAN, maintenanceStatus = OPERATIONAL. Nếu vi phạm, API và UI trả rõ lý do tiếng Việt (ví dụ: *"Phòng đang ngừng phục vụ để bảo trì"*). | server/src/services/stays.service.ts, pp/lib/features/stays/ |
| **BR-REC-02** | **Thông tin khách tối thiểu khi Check-in:** Họ tên khách (guestName), số điện thoại liên hệ (guestPhone — tùy chọn/chuẩn hóa), số lượng khách (guestCount <= capacity), thời점 dự kiến trả phòng (xpectedCheckOutAt). Không lưu số CCCD/hộ chiếu thật. | docs/features/check-in-out/srs/check-in-out-spec.md |
| **BR-REC-03** | **Check-out tự động sinh việc dọn:** Trong cùng 1 transaction với đóng lượt lưu trú (Stay), phòng chuyển sang VACANT + DIRTY và tự động tạo 1 HousekeepingTask gán cho nhân viên trực ít việc nhất. | server/src/services/stays.service.ts |
| **BR-REC-04** | **Quyền báo hỏng của Lễ tân:** Lễ tân được phép tạo phiếu báo hỏng (MaintenanceTask) khi khách báo sự cố tại quầy. | docs/features/maintenance/maintenance-prd.md |

---

## 4. Liên kết Tài liệu trong Repo

- BRD Nhận/Trả phòng: [docs/features/check-in-out/check-in-out-brd.md](../../features/check-in-out/check-in-out-brd.md)
- URD Nhận/Trả phòng: [docs/features/check-in-out/check-in-out-urd.md](../../features/check-in-out/check-in-out-urd.md)

## 5. Trạng thái Nghiệm thu

- [x] Đã ghi nhận đầy đủ interview notes Lễ tân và chốt 4 quy tắc nghiệp vụ cốt lõi.
- [x] Đã gắn liên kết bằng chứng vào Issue #62.
- [ ] Chờ Reviewer (Khách hàng) phê duyệt chính thức để đóng Issue.