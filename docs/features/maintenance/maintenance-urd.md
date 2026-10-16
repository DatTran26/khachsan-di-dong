---
type: urd
feature: maintenance
status: draft
updated: 2026-09-23
links:
  - "[[docs/features/maintenance/brainstorms/bao-hong-va-bao-tri.md|Brainstorm: Báo hỏng & chu trình bảo trì]]"
  - "[[Ton_Chi_Du_An_WPCTeam.txt|Tôn chỉ dự án]]"
---

# maintenance — User Requirements Document

## 1. Purpose

Chu trình báo hỏng và bảo trì giúp mọi vai trò báo hỏng ngay khi phát hiện (kèm phòng + mô tả), giúp nhân viên bảo trì nhận việc và báo xong tại hiện trường, và đảm bảo phòng đang sửa không bị nhận khách nhầm — tất cả trên một nguồn trạng thái realtime thay cho báo miệng/điện thoại rời rạc.

### User Problem & Current Experience

| User | Current Situation | Problem | User Consequence | Evidence |
|------|-------------------|---------|------------------|----------|
| Nhân viên bảo trì | Nhận báo hỏng qua miệng/điện thoại từ lễ tân | Thiếu thông tin phòng/vị trí; không có danh sách việc thống nhất | Chạy đi hỏi lại, sót việc, không ai biết tiến độ | Confirmed (tôn chỉ: "giảm việc cập nhật rời rạc"; PRD 7.5) |
| Nhân viên buồng phòng / lễ tân | Phát hiện hỏng khi đang làm việc | Phải tìm đúng người để báo; báo xong không biết ai xử lý | Hỏng hóc bị trì hoãn hoặc rơi mất | Confirmed (PRD: "bất kỳ vai trò nào phát hiện đều báo") |
| Quản lý | Không có cái nhìn tổng về phòng đang sửa | Không biết phòng nào ngừng phục vụ, việc nào đang trễ | Phòng hỏng bị nhận khách nhầm; việc trễ không ai xử | Confirmed (PRD: dashboard + "phòng đang sửa không bị bán nhầm") |
| Lễ tân | Trạng thái phòng cập nhật chậm | Không chắc phòng nào đang sửa khi khách đến | Nhận khách vào phòng chưa an toàn → sự cố vận hành | Confirmed (tôn chỉ: chỉ nhận khi không ngừng phục vụ) |

## 2. User Types

| Tier | User Type | Context | Primary Goal | Pain Points |
|------|-----------|---------|--------------|-------------|
| primary | Nhân viên bảo trì *(vai trò gộp buồng phòng–bảo trì, MVP)* | Mobile Android, tại hiện trường | Biết việc hỏng nào đang chờ, nhận việc, cập nhật tiến độ, báo xong ngay tại chỗ | Báo hỏng thiếu phòng/vị trí; phải gọi lại quầy hỏi |
| secondary | Mọi vai trò (người báo hỏng) | Web/mobile tại nơi phát hiện hỏng | Báo hỏng nhanh, theo dõi được báo hỏng của mình | Không biết báo cho ai, báo xong "rơi vào hư không" |
| secondary | Quản lý | Web dashboard | Phòng sửa không bị bán nhầm; thấy việc bảo trì đang mở/quá hạn | Không có kênh giám sát tập trung |
| secondary | Lễ tân | Web tại quầy | Biết phòng nào ngừng phục vụ để không nhận nhầm; đặt/gỡ ngừng tay khi cần | Trạng thái phòng không tin được |

## 3. Scope Boundaries

### In Scope

- Báo hỏng kèm phòng + mô tả (bắt buộc) + vị trí/hạng mục (tùy chọn) từ mọi vai trò đã đăng nhập.
- Phòng tự "ngừng phục vụ" trên trục bảo trì khi có việc mở; chặn nhận khách qua `check-in-out`.
- Nhân viên bảo trì xem danh sách việc, tự nhận việc, báo sửa xong trên mobile.
- Phòng tự mở lại phục vụ khi hết việc bảo trì đang mở.
- Đặt/gỡ "ngừng phục vụ" thủ công (lễ tân/quản lý); hủy báo hỏng nhầm khi chưa nhận.
- Trạng thái bảo trì + trạng thái việc realtime; ghi nhật ký máy chủ.
- Cảnh báo việc quá hạn bằng quy tắc (ngưỡng theo OQ-1).

### Out of Scope

- Thao tác nhận/trả phòng (feature `check-in-out` — chỉ bị chặn bởi trạng thái "ngừng phục vụ").
- Kho vật tư, chi phí sửa chữa, lịch bảo trì định kỳ, mức độ ưu tiên hỏng (PRD "chưa làm").
- Chấm công/đánh giá hiệu suất nhân viên bảo trì.
- Báo hỏng từ phía khách (khách không dùng hệ thống — báo qua nhân viên).
- Đối soát/truy vết lịch sử chi tiết (feature `audit-log`); dashboard tổng hợp (feature `room-dashboard`).

## 4. User Needs

| ID | User | Context / Trigger | User Need | Expected Outcome | Importance | Evidence |
|----|------|-------------------|-----------|------------------|------------|----------|
| UN-001 | Mọi vai trò | Phát hiện hỏng hóc tại phòng | Báo hỏng nhanh với phòng + mô tả, không cần tìm người nhận | Báo hỏng được tạo, phòng tự ngừng phục vụ, có mã/trạng thái để theo dõi | Critical | Confirmed (PRD: báo hỏng từ mọi vai trò) |
| UN-002 | Nhân viên bảo trì | Đang trực, có việc mới | Thấy danh sách việc chờ nhận kèm phòng + mô tả + vị trí | Việc xuất hiện realtime trong danh sách "chờ nhận" | Critical | Confirmed (PRD: nhận báo hỏng rõ phòng/vị trí) |
| UN-003 | Nhân viên bảo trì | Tại hiện trường, tay bận | Nhận việc / báo xong bằng thao tác tối thiểu | Hoàn tất thao tác trong ≤3 chạm | Critical | Assumption (bối cảnh mobile tôn chỉ) |
| UN-004 | Quản lý | Phòng đang sửa / việc đang mở | Phòng sửa không bị nhận khách nhầm; thấy việc quá hạn | "Ngừng phục vụ" chặn check-in 100%; việc quá hạn hiển thị trên dashboard | Critical | Confirmed (PRD đo thành công) |
| UN-005 | Lễ tân | Khách đến nhận phòng | Biết chắc phòng nào đang ngừng phục vụ | Trạng thái phòng trên màn lễ tân luôn mới nhất; nhận vào phòng ngừng bị chặn | Critical | Confirmed (tôn chỉ) |
| UN-006 | Quản lý / Lễ tân | Phòng cần ngừng vì lý do vận hành (không qua báo hỏng) | Đặt/gỡ "ngừng phục vụ" thủ công kèm lý do | Trạng thái đổi ngay, có nhật ký, không nhận khách được | High | Confirmed (project-profile: lễ tân đặt/gỡ ngừng phục vụ) |
| UN-007 | Người báo hỏng | Sau khi đã báo | Theo dõi báo hỏng của mình đang ở bước nào | Trạng thái việc (chờ nhận/đang sửa/hoàn tất/đã hủy) nhìn thấy rõ | High | Confirmed (PRD: "trạng thái xử lý rõ ràng cho tới khi đóng") |

## 5. Prioritized User Journeys

### Journey 1: Báo hỏng → sửa xong → phòng mở lại

- **User:** Nhân viên bảo trì (kết hợp người báo, lễ tân)
- **Importance:** Critical
- **Trigger:** Một vai trò bất kỳ báo hỏng trên phòng
- **Expected outcome:** Việc được xử lý xong, phòng trở lại phục vụ, lễ tân nhận khách được
- **Related needs:** UN-001, UN-002, UN-003, UN-004, UN-005

1) Người báo chọn phòng, nhập mô tả, gửi → phòng "ngừng phục vụ".
2) Nhân viên bảo trì thấy việc "chờ nhận", bấm nhận → "đang sửa".
3) Sửa xong, báo hoàn tất → việc "hoàn tất".
4) Phòng hết việc mở → "bình thường"; nếu trống + sạch → "sẵn sàng".
5) Lễ tân thấy phòng sẵn sàng và nhận khách.

**Independent verification:** Đối chiếu lịch sử phòng: có chuỗi "bình thường → ngừng phục vụ → bình thường" gắn vòng đời việc, và lượt nhận khách sau đó thành công.

### Journey 2: Lễ tân bị chặn khi nhận khách vào phòng đang sửa

- **User:** Lễ tân
- **Importance:** Critical
- **Trigger:** Phòng có việc bảo trì đang mở
- **Expected outcome:** Nhận khách bị từ chối với lý do rõ ràng
- **Related needs:** UN-004, UN-005

1) Phòng X có báo hỏng → "ngừng phục vụ".
2) Lễ tân chọn phòng X để nhận khách → hệ thống chặn, báo "phòng đang ngừng phục vụ".
3) Lễ tân chọn phòng khác đủ điều kiện → nhận bình thường.

**Independent verification:** Kịch bản nghiệm thu: 100% lượt nhận vào phòng ngừng phục vụ bị chặn.

### Journey 3: Quản lý xử lý việc bảo trì quá hạn

- **User:** Quản lý
- **Importance:** High
- **Trigger:** Việc bảo trì vượt ngưỡng (OQ-1) chưa hoàn tất
- **Expected outcome:** Việc được đẩy xử lý (nhắc người phụ trách hoặc chỉ định lại), phòng không kẹt
- **Related needs:** UN-004

1) Dashboard hiển thị cảnh báo việc phòng X quá hạn.
2) Quản lý xem ai phụ trách, liên hệ hoặc chỉ định lại cho người khác (P1).
3) Việc hoàn tất; cờ quá hạn tự gỡ; phòng mở lại.

**Independent verification:** Cảnh báo xuất hiện đúng khi vượt ngưỡng; sau xử lý dashboard hết cảnh báo.

### Journey 4: Lễ tân đặt ngừng phục vụ thủ công và mở lại

- **User:** Lễ tân / Quản lý
- **Importance:** Medium
- **Trigger:** Phòng cần ngừng vì lý do vận hành (không phải hỏng)
- **Expected outcome:** Phòng ngừng đúng lúc, mở lại khi hết lý do
- **Related needs:** UN-006

1) Lễ tân chọn phòng → "Ngừng phục vụ" → nhập lý do → phòng bị chặn nhận khách.
2) Khi xong việc vận hành → "Mở lại phục vụ" → phòng trở lại bình thường.

**Independent verification:** Nhật ký có đủ ai đặt/gỡ + lý do; trong thời gian ngừng không nhận khách được.

### Journey 5: Người báo hủy báo hỏng nhầm

- **User:** Người báo (mọi vai trò) / Quản lý
- **Importance:** Medium
- **Trigger:** Báo hỏng nhầm phòng/nhầm nội dung, việc chưa ai nhận
- **Expected outcome:** Việc bị hủy, phòng mở lại nếu hết việc mở
- **Related needs:** UN-001, UN-007

1) Người báo mở việc "chờ nhận" vừa tạo → chọn hủy.
2) Việc "đã hủy"; phòng hết việc mở → về "bình thường".

**Independent verification:** Việc có trạng thái "đã hủy" trong nhật ký; phòng không còn bị chặn.

## 6. User Exceptions & Edge Conditions

| Situation | User Impact | Expected User-facing Outcome | Related Journey / Need |
|-----------|-------------|------------------------------|------------------------|
| Nhân viên mất mạng khi báo xong | Không biết thao tác đã lưu chưa | App báo rõ "chưa được lưu", khóa thao tác ghi; có mạng lại thì tải trạng thái mới và báo lại | J1, UN-003 |
| Hai nhân viên cùng nhận một việc | Người sau tưởng việc của mình | Người sau nhận "đã có người nhận" + danh sách tự cập nhật | J1 |
| Báo hỏng phòng đang có khách ở | Lo phòng bị đá khách | Phòng vẫn cho khách ở hết kỳ; chỉ chặn nhận khách mới sau khi trả | J1 — OQ-3 |
| Hai người cùng báo hỏng một phòng | Sợ tạo trùng | Cảnh báo "đang có việc mở" nhưng vẫn cho tạo; hủy được việc trùng | J5 |
| Gỡ ngừng tay khi còn việc mở | Tưởng đã mở được phòng | Từ chối gỡ + giải thích phải hoàn tất/hủy việc trước | J4 |
| Nhân viên hết ca khi việc đang sửa | Việc treo trên người đã về | Quản lý thấy trên dashboard và chỉ định lại (P1) | J3 |
| Báo xong nhầm rồi phát hiện chưa xong | Việc đã đóng | Không mở lại việc cũ — tạo báo hỏng mới, lịch sử giữ nguyên | J1 |

## 7. User-side Constraints

- Ngôn ngữ: tiếng Việt toàn bộ giao diện và thông báo.
- Kênh/thiết bị: nhân viên bảo trì dùng mobile Android; lễ tân/quản lý dùng web; người báo dùng cả hai.
- Môi trường: 1 khách sạn 50 phòng, tối đa 30 phiên đăng nhập đồng thời (tôn chỉ).
- Điều kiện sử dụng: phải đăng nhập đúng vai trò; báo xong chỉ trên việc do chính mình đang sửa; đặt/gỡ ngừng tay chỉ lễ tân/quản lý.
- Kết nối: mất mạng không cho ghi; báo trạng thái rõ cho người dùng.
- Trục trạng thái: bảo trì là trục riêng — "ngừng phục vụ" không đổi trục lưu trú/vệ sinh; "sẵn sàng" là tổ hợp 3 trục (trống + sạch + phục vụ).

## 8. Assumptions & Validation

| Assumption | Impact if Wrong | Validation Status | Next Action |
|------------|-----------------|-------------------|-------------|
| Việc bảo trì vào danh sách chung, nhân viên tự nhận (MVP) | Nếu nghiệp vụ đòi chỉ định từ đầu → thiếu capability P0 | Assumption từ PRD OQ — chưa chốt | Xác nhận OQ-2 |
| Báo xong → phòng mở lại ngay, không cần ai xác nhận | Nếu cần kiểm tra chất lượng → thiếu bước kiểm soát | Assumption theo PRD ("sửa xong thì phòng mở lại") | Kiểm chứng qua demo; theo dõi sau nghiệm thu |
| "Ngừng phục vụ" 2 nguồn (việc mở / đặt tay) độc lập | Nếu gộp 1 nguồn → gỡ tay mở phòng còn việc mở | Assumption thiết kế nhất quán | Test case D5 |
| Thông báo việc mới/cảnh báo qua realtime trong app, không SMS/push | Nhân viên không mở app sẽ không biết | Assumption nhất quán tôn chỉ | Xác nhận khi demo |

## 9. User Success Criteria

| ID | User Outcome | Baseline | Target | Measurement | Review Period |
|----|--------------|----------|--------|-------------|---------------|
| USC-001 | Phòng đang sửa không bị bán nhầm | Chưa có hệ thống — sự cố xảy ra ngẫu nhiên | 0 lượt nhận khách vào phòng "ngừng phục vụ" trong nghiệm thu | Kịch bản nghiệm thu bắt buộc | Nghiệm thu |
| USC-002 | Báo hỏng luôn có trạng thái rõ ràng | Chưa có | 100% báo hỏng có trạng thái (chờ nhận/đang sửa/hoàn tất/đã hủy) tới khi đóng | Đối soát nhật ký + danh sách việc | Sprint 2 |
| USC-003 | Nhân viên thao tác nhanh tại hiện trường | Chưa có | Nhận việc/báo xong trong ≤3 chạm, ≤10 giây | Đo trên bản demo Android | Demo sprint 2 |
| USC-004 | Mọi thiết bị thấy cùng trạng thái | Chưa có | ≥95% trong 100 lượt cập nhật hiển thị trên thiết bị khác ≤3 giây | Đo theo tiêu chí nghiệm thu tôn chỉ | Nghiệm thu |
| USC-005 | Người báo theo dõi được báo hỏng của mình | Chưa có — báo xong mất vết | 100% báo hỏng tra được trạng thái hiện tại | Kiểm tra trên danh sách việc | Sprint 2 |

## 10. Open Questions

- [ ] OQ-1: Ngưỡng "quá hạn" cho việc bảo trì (bao nhiêu phút/giờ)? Cảnh báo phát 1 lần hay lặp lại? → **Chốt 10/10/2026: ngưỡng 4 giờ** từ lúc báo hỏng. Tần suất cảnh báo chưa chốt (hiện cảnh báo 1 lần).
