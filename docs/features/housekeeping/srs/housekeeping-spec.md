---
type: srs-spec
feature: housekeeping
status: draft
updated: 2026-09-15
links:
  - "[[docs/features/housekeeping/housekeeping-prd.md|Housekeeping PRD]]"
---

# housekeeping — SRS (Core Spec)

## 1. Purpose & Scope

Đặc tả chu trình công việc dọn phòng: tạo và phân công tự động khi trả phòng, thao tác của nhân viên buồng phòng, xác nhận chất lượng của quản lý, cảnh báo quá hạn 60 phút bằng quy tắc, và đồng bộ realtime trạng thái vệ sinh. Phạm vi: 1 khách sạn 50 phòng, tiếng Việt, dữ liệu giả lập.

## 2. Actors & Stakeholders

| Actor | Type | Trách nhiệm |
|-------|------|-------------|
| Nhân viên buồng phòng | Người | Nhận/từ chối/báo hoàn tất việc được giao |
| Quản lý | Người | Xác nhận "sẵn sàng" / trả lại việc; phân công lại; theo dõi quá hạn |
| Lễ tân | Người | Xem trạng thái phòng "sẵn sàng" (read-only trong feature này); phát sinh sự kiện trả phòng |
| Hệ thống | Hệ thống | Tạo việc, tự giao, đánh cờ quá hạn, ghi nhật ký, phát sự kiện realtime |
| Feature nhận/trả phòng | Hệ thống | Nguồn sự kiện "trả phòng" (ngoài phạm vi spec này) |

## 3. Functional Requirements

| ID | Requirement | Verification | Priority |
|----|-------------|--------------|----------|
| FR-housekeeping-001 | Khi phòng được trả (sự kiện trả phòng), hệ thống phải tạo đúng 1 công việc dọn cho phòng đó và chuyển trục vệ sinh của phòng sang "cần dọn". | Demo/test: đối chiếu số việc tạo với số lượt trả phòng | Must |
| FR-housekeeping-002 | Hệ thống phải tự giao việc mới cho nhân viên buồng phòng đang trực có ít việc đang mở nhất, theo thứ tự giờ trả phòng; nếu hòa nhau thì ưu tiên người lâu nhất chưa được giao việc. | Test: dàn việc + danh sách trực giả lập | Must |
| FR-housekeeping-003 | Nếu không có nhân viên buồng phòng nào đang trực, hệ thống phải giữ việc ở trạng thái "chờ giao" và cảnh báo cho quản lý; khi có người vào trực, hệ thống tự giao theo FR-002. | Test: tắt hết trực, tạo việc, bật lại trực | Must |
| FR-housekeeping-004 | Khi nhân viên bấm nhận việc, hệ thống phải chuyển việc sang "đang làm" và phòng sang "đang dọn". Khi nhân viên từ chối, hệ thống phải giao lại cho người trực ít việc kế tiếp và ghi nhật ký; nếu hết người, việc về "chờ giao" và cảnh báo quản lý. | Demo: luồng nhận và luồng từ chối | Must |
| FR-housekeeping-005 | Nhân viên chỉ được báo hoàn tất khi việc có đủ ba ảnh nghiệm thu đang tải thành công: tổng quan phòng, khu ngủ/giường và nhà vệ sinh. Ảnh cận cảnh là bắt buộc khi nhân viên đánh dấu bất thường. | Demo/test: thử báo hoàn tất khi thiếu từng nhóm ảnh | Must |
| FR-housekeeping-006 | Khi nhân viên báo hoàn tất với bộ ảnh hợp lệ, hệ thống phải chuyển việc sang "chờ xác nhận", phòng sang "chờ kiểm tra" và thông báo quản lý. | Demo | Must |
| FR-housekeeping-007 | Quản lý phải xem được ảnh nghiệm thu của đúng lần dọn, theo thứ tự nhóm ảnh; có thể mở toàn màn hình và phóng to trước khi xác nhận hoặc trả lại. | Demo trên Web + Android | Must |
| FR-housekeeping-008 | Khi quản lý xác nhận, hệ thống phải chuyển việc sang "hoàn tất" và phòng sang "sạch". Khi quản lý trả lại, hệ thống phải yêu cầu ghi chú (không rỗng, ≤500 ký tự) rồi chuyển việc về "đang làm", phòng về "đang dọn" kèm ghi chú cho nhân viên; bộ ảnh cũ được giữ để truy vết. | Demo: cả 2 nhánh | Must |
| FR-housekeeping-009 | Hệ thống chỉ được hiển thị phòng "sẵn sàng" khi phòng đang trống + đã sạch + trục bảo trì bình thường. Mọi thay đổi trạng thái phải được phát realtime tới mọi thiết bị đang mở. | Test: nhận khách vào phòng chưa đủ điều kiện phải bị chặn | Must |
| FR-housekeeping-010 | Khi công việc vượt 60 phút kể từ lúc tạo (mốc giờ trả phòng) mà chưa "hoàn tất", hệ thống phải đánh cờ "quá hạn" và cảnh báo quản lý (dashboard) cùng nhân viên phụ trách (trong app); cờ tự gỡ khi việc "hoàn tất". | Test: dịch đồng hồ giả lập quá ngưỡng | Must |
| FR-housekeeping-011 | Quản lý phải phân công lại được công việc đang mở cho nhân viên buồng phòng đang trực khác; mỗi lần đổi người phải ghi nhật ký. | Demo | Should |
| FR-housekeeping-012 | Quản lý và nhân viên phải lọc được danh sách công việc theo nhân viên phụ trách, trạng thái việc và phòng. | Demo | Should |
| FR-housekeeping-013 | Khi mất kết nối, hệ thống phải khóa thao tác ghi và hiển thị trạng thái mất kết nối; khi kết nối lại, hệ thống phải tải trạng thái mới nhất thay cho giữ dữ liệu cũ. | Test: ngắt mạng giữa thao tác | Must |
| FR-housekeeping-014 | Khi hai thao tác đồng thời cùng nhắm một công việc, hệ thống phải chấp nhận thao tác đến trước và từ chối thao tác sau kèm thông báo và yêu cầu tải lại trạng thái. | Test: 2 thiết bị cùng nhận 1 việc | Must |
| FR-housekeeping-015 | Mọi thay đổi trạng thái công việc/phòng và lần nộp ảnh nghiệm thu phải được ghi nhật ký ở máy chủ gồm: ai đổi, khi nào, từ trạng thái nào, sang trạng thái nào (bàn giao cho feature audit-log). | Đối soát audit-log | Must |

## 4. Non-Functional Requirements

| ID | Requirement | Verification | Priority |
|----|-------------|--------------|----------|
| NFR-housekeeping-001 | Performance: ≥95% trong 100 lượt cập nhật trạng thái phải hiển thị trên thiết bị khác trong ≤3 giây (50 phòng, tối đa ~10 phiên đồng thời). | Đo theo tiêu chí nghiệm thu tôn chỉ | Must |
| NFR-housekeeping-002 | Usability: thao tác nhận việc hoặc báo hoàn tất hoàn thành trong ≤3 chạm trên mobile; toàn bộ nhãn và thông báo tiếng Việt. | Demo trên Android/Web | Must |
| NFR-housekeeping-003 | Reliability: mất mạng không được mất dữ liệu đã xác nhận lưu — máy chủ lưu trước rồi mới phát sự kiện realtime. | Test: ngắt mạng sau khi lưu | Must |
| NFR-housekeeping-004 | Security: mọi thay đổi trạng thái phải kiểm tra quyền vai trò ở máy chủ (nhân viên chỉ thao tác việc của mình; chỉ quản lý xác nhận/trả lại/phân công lại). | Test bằng tài khoản từng vai trò | Must |
| NFR-housekeeping-005 | Auditability: dữ liệu trạng thái phải đối soát được với nhật ký máy chủ 1-1 (không thiếu, không lệch). | Đối soát log vs dashboard | Must |
| NFR-housekeeping-006 | Privacy: ảnh chỉ gắn với công việc cụ thể, chỉ nhân viên phụ trách và quản lý được xem; giao diện nhắc không chụp đồ cá nhân của khách. | Review RBAC + demo | Must |

## 5. Business Rules

| ID | Rule | Source | Liên kết |
|----|------|--------|----------|
| BR-housekeeping-001 | Chỉ quản lý được xác nhận phòng "sẵn sàng" (chuyển phòng sang "sạch"). | BRD BR-housekeeping-01 | FR-008 |
| BR-housekeeping-002 | Công việc quá 60 phút tính từ lúc tạo mà chưa "hoàn tất" thì bị cờ "quá hạn"; đo tới mốc nhân viên báo hoàn tất, không gồm thời gian chờ quản lý xác nhận. | BRD BR-housekeeping-02 | FR-010 |
| BR-housekeeping-003 | Phòng chỉ được nhận khách khi trống + đã sạch + trục bảo trì bình thường. | Tôn chỉ / BRD BR-housekeeping-03 | FR-009 |
| BR-housekeeping-004 | Giao việc chia đều: người đang trực có ít việc đang mở nhất; hòa thì ưu tiên người lâu chưa được giao. | BRD BR-housekeeping-04 | FR-002 |
| BR-housekeeping-005 | Trả lại việc bắt buộc ghi chú lý do, không rỗng, ≤500 ký tự. | BRD BR-housekeeping-05 | FR-008 |
| BR-housekeeping-006 | Bộ ảnh tối thiểu của một lần nghiệm thu gồm tổng quan phòng, khu ngủ/giường và nhà vệ sinh; ảnh cận cảnh bổ sung khi có bất thường. | User decision 2026-09-26 | FR-005, FR-007 |

## 6. Error Matrix

| ID | Error | Trigger | Severity | Linked Req | User Message |
|----|-------|---------|----------|------------|--------------|
| E-housekeeping-001 | Việc đã có người nhận | 2 thiết bị cùng nhận 1 việc | minor | FR-012 | "Công việc này đã có người khác nhận." + tải lại danh sách |
| E-housekeeping-002 | Không có ai đang trực | Auto-assign không tìm được nhân viên | major | FR-003 | "Chưa có nhân viên buồng phòng đang trực — công việc đang chờ giao." (cảnh báo quản lý) |
| E-housekeeping-003 | Mất kết nối khi ghi | Offline khi nhận/báo hoàn tất/xác nhận | major | FR-011 | "Mất kết nối — thao tác chưa được lưu. Thử lại khi có mạng." |
| E-housekeeping-004 | Trạng thái đã đổi | Thao tác trên dữ liệu cũ (xung đột phiên bản) | minor | FR-012 | "Thao tác không hợp lệ ở trạng thái hiện tại. Tải lại để xem trạng thái mới nhất." |
| E-housekeeping-005 | Thiếu ghi chú trả lại | Quản lý trả lại mà chưa nhập ghi chú | minor | FR-006 | "Vui lòng nhập ghi chú khi trả lại công việc." |
| E-housekeeping-006 | Sai quyền vai trò | Nhân viên thao tác việc của người khác; vai trò không được phép xác nhận | major | FR-004, FR-006, NFR-004 | "Bạn không có quyền thực hiện thao tác này." |
| E-housekeeping-007 | Thiếu hoặc lỗi ảnh nghiệm thu | Báo hoàn tất khi thiếu nhóm ảnh bắt buộc hoặc tệp chưa tải xong | minor | FR-005 | "Cần đủ ảnh tổng quan, khu ngủ và nhà vệ sinh trước khi báo hoàn tất." |

## 7. Success Criteria

| ID | Criterion | Đo lường |
|----|-----------|----------|
| SC-housekeeping-01 | 100% sự kiện trả phòng sinh việc được giao (hoặc cảnh báo thiếu người trực) trong ≤1 phút | Đối soát nhật ký trong kịch bản nghiệm thu |
| SC-housekeeping-02 | ≥95% trong 100 lượt thay đổi trạng thái hiển thị trên thiết bị khác ≤3 giây | Đo theo tiêu chí nghiệm thu tôn chỉ |
| SC-housekeeping-03 | 0 phòng đạt "sẵn sàng" mà chưa qua xác nhận quản lý; 0 lượt nhận khách vào phòng chưa đủ điều kiện | Kịch bản nghiệm thu bắt buộc |
| SC-housekeeping-04 | 100% việc vượt 60 phút chưa hoàn tất được cờ "quá hạn" trong chu kỳ quét kế tiếp (≤1 phút sau khi vượt ngưỡng) | Test dịch đồng hồ giả lập |
| SC-housekeeping-05 | 100% việc được xác nhận có ba nhóm ảnh nghiệm thu và quản lý xem được trước khi xác nhận | Kịch bản nghiệm thu Web + Android |

## 8. Entity Summary

| Entity | Fields chính | Quan hệ | Ghi chú |
|--------|--------------|---------|---------|
| Công việc dọn phòng | phòng, nhân viên phụ trách, trạng thái việc, mốc tạo/nhận/hoàn tất/xác nhận, ghi chú trả lại, cờ quá hạn | thuộc 1 Phòng; gán 1 Nhân viên buồng phòng | Trạng thái: chờ giao → đã giao → đang làm → chờ xác nhận → hoàn tất |
| Ảnh nghiệm thu | công việc, nhóm ảnh, vị trí hiển thị, người nộp, mốc nộp, trạng thái tải | thuộc đúng 1 Công việc dọn | Nhóm: tổng quan, khu ngủ, nhà vệ sinh, cận cảnh bất thường |
| Phòng (trục vệ sinh) | trạng thái vệ sinh | thuộc Phòng chung; độc lập trục lưu trú và bảo trì | Trạng thái: cần dọn → đang dọn → chờ kiểm tra → sạch; "sẵn sàng" = trống + sạch + bảo trì bình thường (composite, không phải state riêng) |
| Nhật ký thay đổi | ai, khi nào, từ trạng thái, sang trạng thái | ghi cho mọi thay đổi của 2 entity trên | Bàn giao chi tiết cho feature audit-log |

## 9. Flow Summary

- Luồng chính: trả phòng → tạo việc "cần dọn" → tự giao → nhận ("đang làm"/"đang dọn") → chụp/tải ảnh nghiệm thu → báo hoàn tất ("chờ xác nhận"/"chờ kiểm tra") → quản lý xem ảnh + xác nhận ("hoàn tất"/"sạch") → "sẵn sàng" nếu trống + phục vụ → realtime tới dashboard.
- Luồng phụ: từ chối việc → giao lại; trả lại việc → "đang làm" kèm ghi chú; quá 60 phút → cờ + cảnh báo; không ai trực → "chờ giao" + cảnh báo.

## 10. Screen Summary

| Screen | Vai trò | Nội dung chính |
|--------|---------|----------------|
| Danh sách việc của tôi | Nhân viên buồng phòng | Việc được giao/đang làm/chờ xác nhận; nút nhận, từ chối, báo hoàn tất; đánh dấu quá hạn |
| Chi tiết công việc | Nhân viên buồng phòng | Số phòng, trạng thái, ghi chú trả lại (nếu có), bộ ảnh nghiệm thu, thao tác theo trạng thái |
| Hàng chờ xác nhận | Quản lý | Việc "chờ xác nhận", gallery ảnh nghiệm thu; nút xác nhận / trả lại (form ghi chú bắt buộc) |
| Danh sách công việc | Quản lý | Toàn bộ việc + lọc theo nhân viên/trạng thái/phòng; phân công lại; cảnh báo quá hạn |
| Dashboard phòng | Quản lý, Lễ tân | Trạng thái phòng realtime, số việc quá hạn, phòng sẵn sàng |

## 11. Constraints & Dependencies

### Constraints

- MVP 8 tuần, 1 khách sạn 50 phòng, tiếng Việt, dữ liệu giả lập (tôn chỉ).
- Cảnh báo quá hạn bằng quy tắc, không phụ thuộc AI (tôn chỉ).
- Kiểm tra quyền và ghi nhật ký ở máy chủ cho mọi thay đổi (tôn chỉ).
- Realtime qua Socket.IO; backend Node.js + Express + TypeScript; PostgreSQL + Prisma — ràng buộc đã duyệt theo tôn chỉ.
- Công thức tỷ lệ lấp đầy theo tôn chỉ; "sẵn sàng" là composite không phải trạng thái lưu.

### Dependencies

- Sự kiện trả phòng từ feature nhận/trả phòng (sprint 2, song song).
- Vai trò + cờ đang trực do quản lý bật/tắt trong `auth-roles` (Sprint 1).
- Audit-log nhận nhật ký thay đổi (cùng nhóm).
- Dashboard hiển thị trạng thái và cảnh báo (sprint 3).

### Assumptions

- Danh sách đang trực lấy từ cờ do quản lý bật/tắt; thông báo qua realtime trong app; ngưỡng 60 phút đồng nhất mọi phòng.

## 12. Open Questions

- [ ] OQ-2: Cảnh báo quá hạn phát 1 lần khi vượt ngưỡng hay lặp lại định kỳ (vd mỗi 15 phút) tới khi hoàn tất?
- [ ] OQ-3: Việc "chờ xác nhận" quá lâu có cần ngưỡng nhắc riêng cho quản lý không? Bao nhiêu phút?
- [ ] OQ-4: Thời hạn lưu, dung lượng tệp và quy trình xoá ảnh sau nghiệm thu do chủ khách sạn quyết định.
