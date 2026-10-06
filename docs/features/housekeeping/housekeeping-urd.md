---
type: urd
feature: housekeeping
status: draft
updated: 2026-09-23
links:
  - "[[docs/features/housekeeping/brainstorms/chu-trinh-don-phong.md|Brainstorm: Chu trình dọn phòng]]"
  - "[[Ton_Chi_Du_An_WPCTeam.txt|Tôn chỉ dự án]]"
---

# housekeeping — User Requirements Document

## 1. Purpose

Chu trình dọn phòng giúp nhân viên buồng phòng nhận và hoàn tất việc đúng lúc, giúp quản lý kiểm soát chất lượng trước khi phòng được bán lại, và giúp lễ tân biết ngay phòng nào sẵn sàng đón khách — tất cả trên một hệ thống realtime thay cho cập nhật rời rạc qua điện thoại/giấy.

### User Problem & Current Experience

| User | Current Situation | Problem | User Consequence | Evidence |
|------|-------------------|---------|------------------|----------|
| Nhân viên buồng phòng | Nhận việc qua điện thoại/giấy/bộ đàm rời rạc | Không biết việc nào của mình, không có danh sách thống nhất | Sót việc, trùng việc, chờ phân công thủ công | Confirmed (tôn chỉ: "giảm việc cập nhật rời rạc") |
| Quản lý | Phải đi kiểm tra hoặc hỏi từng người để biết phòng đã sạch | Không có kênh xác nhận chất lượng thống nhất | Phòng sạch không được bán lại kịp; hoặc khách vào phòng chưa dọn | Confirmed (tôn chỉ: luồng vận hành chuẩn có bước xác nhận) |
| Lễ tân | Gọi điện hỏi buồng phòng trước khi nhận khách | Trạng thái phòng không cập nhật realtime | Nhận khách chậm, trải nghiệm khách kém | Confirmed (tôn chỉ: dashboard realtime) |

## 2. User Types

| Tier | User Type | Context | Primary Goal | Pain Points |
|------|-----------|---------|--------------|-------------|
| primary | Nhân viên buồng phòng | Di động trong khách sạn, dùng điện thoại | Biết việc được giao, nhận và báo hoàn tất nhanh | Không muốn hỏi/chờ phân công; sợ sót việc bị khiển trách |
| secondary | Quản lý | Web dashboard tại quầy/văn phòng | Xác nhận chất lượng trước khi mở bán lại; can thiệp việc quá hạn | Không kiểm soát được tiến độ nếu cập nhật thủ công |
| secondary | Lễ tân | Web tại quầy lễ tân | Biết phòng nào "sẵn sàng" để nhận khách | Phải gọi điện xác nhận từng phòng |

## 3. Scope Boundaries

### In Scope

- Tự động tạo và tự giao công việc dọn khi phòng được trả.
- Nhân viên nhận việc, từ chối việc, báo hoàn tất trên thiết bị di động.
- Nhân viên chụp/tải ảnh nghiệm thu theo từng lần dọn trước khi báo hoàn tất.
- Quản lý xác nhận "sẵn sàng" hoặc trả lại việc kèm ghi chú.
- Quản lý xem ảnh toàn màn hình, phóng to và duyệt theo thứ tự để đối chiếu chất lượng.
- Trạng thái vệ sinh phòng và trạng thái công việc cập nhật realtime trên mọi thiết bị.
- Cảnh báo công việc quá hạn 60 phút bằng quy tắc.
- Quản lý phân công lại thủ công; lọc danh sách công việc.

### Out of Scope

- Thao tác nhận/trả phòng của lễ tân (thuộc feature nhận/trả phòng — nguồn sự kiện đầu vào).
- Quản lý ca trực/chấm công, phân quyền tài khoản (feature quản lý tài khoản).
- Tối ưu tuyến đi/phân công theo vị trí tầng; tính lương, KPI nhân viên.
- Tóm tắt vận hành bằng AI (feature AI riêng — AI chỉ đọc số liệu, không quyết định).
- Đối soát/truy vết lịch sử chi tiết (feature audit-log).

## 4. User Needs

| ID | User | Context / Trigger | User Need | Expected Outcome | Importance | Evidence |
|----|------|-------------------|-----------|------------------|------------|----------|
| UN-001 | Nhân viên buồng phòng | Có phòng vừa trả | Được giao việc tự động, không phải chờ ai phân công | Việc xuất hiện trong danh sách của mình kèm thông báo ngay khi có phòng cần dọn | Critical | Confirmed (user chốt: tự phân công chia đều theo giờ trả) |
| UN-002 | Nhân viên buồng phòng | Đang đứng tại phòng, tay bận | Nhận việc / báo hoàn tất bằng thao tác tối thiểu trên điện thoại | Hoàn tất thao tác trong ≤3 chạm, không cần gõ nhiều | Critical | Assumption (từ bối cảnh mobile của tôn chỉ) |
| UN-003 | Nhân viên buồng phòng | Nhiều việc cùng lúc | Biết việc nào của mình, việc nào đang quá hạn | Danh sách việc cá nhân rõ ràng, việc quá hạn được đánh dấu | High | Confirmed (tôn chỉ: cảnh báo quá hạn) |
| UN-004 | Quản lý | Nhân viên vừa báo hoàn tất | Xác nhận hoặc trả lại trước khi phòng được mở bán lại | Phòng chỉ "sẵn sàng" sau khi quản lý xác nhận; trả lại thì nhân viên nhận được ghi chú | Critical | Confirmed (user chốt: quản lý xác nhận) |
| UN-005 | Quản lý | Ca vận hành đang chạy | Thấy ngay việc quá hạn để can thiệp | Cảnh báo xuất hiện trên dashboard khi việc vượt 60 phút chưa hoàn tất | High | Confirmed (tôn chỉ + user chốt ngưỡng 60') |
| UN-006 | Lễ tân | Khách đến nhận phòng | Biết phòng nào "sẵn sàng" ngay lúc đó | Trạng thái phòng trên màn hình lễ tân luôn mới nhất | Critical | Confirmed (tôn chỉ: chỉ nhận phòng khi trống+sạch+phục vụ) |
| UN-007 | Nhân viên buồng phòng | Đã dọn xong một phòng | Gửi bằng chứng nhanh theo các góc bắt buộc, không cần soạn báo cáo dài | Có đủ ảnh tổng quan, khu ngủ và nhà vệ sinh trước khi báo hoàn tất | Critical | User decision 2026-09-26 |
| UN-008 | Quản lý | Có việc chờ xác nhận | Xem rõ ảnh theo từng lần dọn để quyết định từ xa | Có thể mở toàn màn hình, phóng to và trả lại kèm ghi chú cụ thể | Critical | User decision 2026-09-26 |

## 5. Prioritized User Journeys

### Journey 1: Nhân viên hoàn tất một việc dọn từ lúc được giao đến khi phòng sẵn sàng

- **User:** Nhân viên buồng phòng (kết hợp quản lý, lễ tân)
- **Importance:** Critical
- **Trigger:** Lễ tân xác nhận trả phòng
- **Expected outcome:** Phòng chuyển "sẵn sàng" và lễ tân nhận được khách mới
- **Related needs:** UN-001, UN-002, UN-004, UN-006

1) Nhân viên nhận thông báo được giao việc dọn phòng X.
2) Đến phòng, bấm nhận việc trên điện thoại.
3) Dọn xong, chụp/tải ảnh tổng quan, khu ngủ và nhà vệ sinh; nếu có bất thường, thêm ảnh cận cảnh.
4) Bấm báo hoàn tất sau khi bộ ảnh tối thiểu đủ.
5) Quản lý nhận thông báo, xem ảnh, kiểm tra và xác nhận hoặc trả lại.
6) Phòng hiển thị "sẵn sàng"; lễ tân thấy và nhận khách.

**Independent verification:** Đối chiếu lịch sử trạng thái phòng X: có đủ chuỗi "cần dọn → đang dọn → chờ kiểm tra → sạch" và phòng được nhận khách sau đó.

### Journey 2: Quản lý xử lý công việc quá hạn

- **User:** Quản lý
- **Importance:** High
- **Trigger:** Công việc dọn vượt 60 phút chưa hoàn tất
- **Expected outcome:** Việc được xử lý (nhân viên làm xong hoặc được phân công lại), phòng không kẹt
- **Related needs:** UN-005, UN-003

1) Dashboard hiển thị cảnh báo việc phòng X quá hạn.
2) Quản lý xem ai phụ trách, liên hệ hoặc phân công lại cho nhân viên khác.
3) Việc được hoàn tất và xác nhận; cờ quá hạn tự gỡ.

**Independent verification:** Cảnh báo xuất hiện đúng lúc vượt ngưỡng; sau xử lý, công việc "hoàn tất" và dashboard hết cảnh báo.

### Journey 3: Quản lý trả lại việc chưa đạt

- **User:** Quản lý (tác động nhân viên buồng phòng)
- **Importance:** High
- **Trigger:** Kiểm tra phòng "chờ kiểm tra" thấy chưa đạt
- **Expected outcome:** Nhân viên nhận lại việc kèm ghi chú và dọn lại đúng yêu cầu
- **Related needs:** UN-004

1) Quản lý mở việc "chờ xác nhận", chọn trả lại, nhập ghi chú lý do.
2) Nhân viên nhận thông báo việc bị trả lại kèm ghi chú.
3) Nhân viên dọn lại, báo hoàn tất lần hai.
4) Quản lý xác nhận → phòng "sạch"/"sẵn sàng".

**Independent verification:** Việc có vòng "chờ xác nhận → đang làm → chờ xác nhận → hoàn tất" kèm ghi chú trong lịch sử.

### Journey 4: Nhân viên từ chối việc được giao

- **User:** Nhân viên buồng phòng
- **Importance:** Medium
- **Trigger:** Được giao việc nhưng đang bận/không thể nhận
- **Expected outcome:** Việc được giao lại cho người trực khác, không bị treo
- **Related needs:** UN-001

1) Nhân viên bấm từ chối việc vừa được giao.
2) Hệ thống tự giao lại cho người trực ít việc kế tiếp.
3) Người mới nhận thông báo và nhận việc.

**Independent verification:** Lịch sử việc ghi nhận đổi người phụ trách; việc không nằm lâu ở người từ chối.

## 6. User Exceptions & Edge Conditions

| Situation | User Impact | Expected User-facing Outcome | Related Journey / Need |
|-----------|-------------|------------------------------|------------------------|
| Nhân viên mất mạng khi đang báo hoàn tất | Không biết thao tác đã lưu chưa | Ứng dụng báo rõ "chưa được lưu", khóa thao tác ghi; có mạng lại thì tải trạng thái mới và báo lại được | J1, UN-002 |
| Hai nhân viên cùng nhận một việc | Người sau tưởng việc của mình | Người sau nhận thông báo "đã có người nhận" và danh sách tự cập nhật | J1 |
| Không có nhân viên nào đang trực | Việc mới không ai làm | Việc hiển thị "chờ giao", quản lý nhận cảnh báo ngay | J1, UN-005 |
| Nhân viên hết ca khi việc còn đang làm | Việc treo trên người đã về | Quản lý thấy và phân công lại thủ công | J2 |
| Quản lý trả lại trong lúc nhân viên đang thao tác | Nhân viên thao tác trên trạng thái cũ | Thao tác sau bị từ chối, ứng dụng tải lại trạng thái mới | J3 |
| Nhiều phòng trả dồn trong giờ cao điểm | Việc ùn một lúc | Việc vẫn được tạo và chia đều; việc nào quá hạn vẫn được cảnh báo riêng | J1, J2 |
| Quản lý không xác nhận trong thời gian dài | Phòng sạch nhưng chưa bán được | Việc "chờ xác nhận" nổi bật trên dashboard của quản lý (không tính quá hạn 60') | J1 — OQ-3 |
| Ảnh thiếu, mờ hoặc không tải được | Quản lý không đủ căn cứ nghiệm thu | Nhân viên không thể báo hoàn tất nếu thiếu nhóm ảnh bắt buộc; quản lý thấy trạng thái lỗi và có thể trả lại kèm yêu cầu chụp lại | J1, UN-007, UN-008 |

## 7. User-side Constraints

- Ngôn ngữ: tiếng Việt toàn bộ giao diện và thông báo.
- Kênh/thiết bị: nhân viên buồng phòng dùng mobile (Android/app + web responsive); quản lý và lễ tân dùng web dashboard.
- Môi trường: 1 khách sạn 50 phòng, tối đa 30 phiên đăng nhập đồng thời (tôn chỉ).
- Điều kiện sử dụng: phải đăng nhập đúng vai trò; nhân viên chỉ thao tác việc của mình; chỉ quản lý xác nhận "sẵn sàng".
- Kết nối: mất mạng không cho ghi; phải báo trạng thái rõ cho người dùng.

## 8. Assumptions & Validation

| Assumption | Impact if Wrong | Validation Status | Next Action |
|------------|-----------------|-------------------|-------------|
| Danh sách "nhân viên đang trực" do quản lý bật/tắt | Auto-assign chỉ chọn đúng người sẵn sàng | Đã chốt | Cờ trực thuộc `auth-roles`, không bao gồm chấm công |
| "Chia đều" = giao cho người ít việc đang mở nhất, hòa thì ưu tiên người lâu chưa được giao | Phân công có thể lệch kỳ vọng "đều" của quản lý | Assumption hợp lý từ câu trả lời "chia đều phòng cho số lượng dọn phòng hiện có" | Kiểm chứng qua demo với quản lý |
| Ngưỡng quá hạn 60 phút áp cho mọi loại phòng | Phòng lớn/VIP thực tế cần lâu hơn → cảnh báo nhiễu | Assumption | Theo dõi sau nghiệm thu; P2 cân nhắc theo loại phòng |
| Thông báo đi qua realtime trong app (không SMS/push ngoài) | Nhân viên không mở app sẽ không biết việc mới | Assumption nhất quán tôn chỉ (Socket.IO) | Xác nhận khi demo |

## 9. User Success Criteria

| ID | User Outcome | Baseline | Target | Measurement | Review Period |
|----|--------------|----------|--------|-------------|---------------|
| USC-001 | Việc dọn luôn có người phụ trách kịp thời | Chưa có — xác lập qua log demo | 100% sự kiện trả phòng tạo việc và giao được (hoặc cảnh báo thiếu người trực) trong ≤1 phút | Đối soát nhật ký hệ thống trong kịch bản nghiệm thu | Cuối sprint 2 |
| USC-002 | Nhân viên thao tác nhanh tại phòng | Chưa có | Nhận việc hoặc báo hoàn tất trong ≤3 chạm, ≤10 giây | Đo trên bản demo Android/Web | Demo sprint 2 |
| USC-003 | Mọi thiết bị thấy cùng trạng thái | Chưa có | ≥95% trong 100 lượt cập nhật hiển thị trên thiết bị khác ≤3 giây | Đo theo tiêu chí nghiệm thu tôn chỉ | Nghiệm thu |
| USC-004 | Không có phòng bán nhầm khi chưa đạt | Chưa có | 0 phòng đạt "sẵn sàng" mà chưa qua xác nhận quản lý; 0 lượt nhận khách vào phòng chưa sạch | Kịch bản nghiệm thu bắt buộc | Nghiệm thu |
| USC-005 | Có bằng chứng ảnh cho việc được xác nhận | Chưa có | 100% việc hoàn tất có đủ ba nhóm ảnh tối thiểu, quản lý mở xem được trước xác nhận | Đối soát công việc và ảnh nghiệm thu | Nghiệm thu |

## 10. Open Questions

- [ ] OQ-2: Cảnh báo quá hạn phát 1 lần khi vượt ngưỡng, hay lặp lại định kỳ (vd mỗi 15 phút) tới khi hoàn tất?
- [ ] OQ-3: Việc "chờ xác nhận" quá lâu (quản lý không phản hồi) có cần ngưỡng nhắc riêng không? Bao nhiêu phút?
- [ ] OQ-4: Thời hạn lưu, dung lượng tệp và quy trình xoá ảnh sau nghiệm thu do chủ khách sạn quyết định.
