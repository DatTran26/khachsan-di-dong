---
type: urd
feature: room-dashboard
status: draft
updated: 2026-09-23
links:
  - "[[docs/features/room-dashboard/brainstorms/giam-sat-ba-truc-trang-thai.md|Brainstorm: Giám sát 3 trục trạng thái]]"
  - "[[docs/_product/prd.md|Product PRD]]"
  - "[[Ton_Chi_Du_An_WPCTeam.txt|Tôn chỉ dự án]]"
---

# room-dashboard — User Requirements Document

## 1. Purpose

Dashboard trạng thái phòng giúp quản lý biết ngay tình trạng toàn khách sạn và việc nào đang trễ để điều phối trong ca, và giúp lễ tân chắc phòng nào thật sự sẵn sàng trước khi nhận khách — trên một màn hình realtime duy nhất thay cho việc hỏi từng người hoặc tin báo miệng rời rạc.

### User Problem & Current Experience

| User | Current Situation | Problem | User Consequence | Evidence |
|------|-------------------|---------|------------------|----------|
| Quản lý | Muốn biết trạng thái phòng phải đi kiểm tra hoặc hỏi từng bộ phận | Trạng thái 3 trục (lưu trú / vệ sinh / bảo trì) cập nhật rời rạc, không có cái nhìn tổng theo thời điểm | Điều phối chậm và dễ nhầm; việc nào đang trễ không ai biết | Confirmed (PRD: vấn đề cốt lõi; job quản lý) |
| Lễ tân | Phải gọi điện hỏi buồng phòng/bảo trì trước khi nhận khách | Không chắc phòng nào thật sự sẵn sàng tại thời điểm đó | Nhận khách chậm; rủi ro nhận vào phòng chưa đạt điều kiện | Confirmed (PRD: ai đang đau; dashboard tham khảo cho lễ tân) |
| Nhân viên buồng phòng–bảo trì | Báo miệng/gọi điện cho lễ tân để cập nhật tiến độ | Cập nhật của họ không lan tới người giám sát ngay | Dữ liệu trễ → mọi quyết định điều phối dựa trên thông tin cũ | Confirmed (PRD: giải pháp thay thế hiện tại) — vai trò nguồn dữ liệu, không phải người xem dashboard |

## 2. User Types

| Tier | User Type | Context | Primary Goal | Pain Points |
|------|-----------|---------|--------------|-------------|
| primary | Quản lý | Web dashboard tại quầy/văn phòng, xem liên tục trong ca | Biết ngay tình trạng toàn khách sạn và việc nào đang trễ để điều phối trong ca | Không có cái nhìn tổng theo thời điểm; phải hỏi từng người; việc quá hạn lặng lẽ |
| secondary | Lễ tân | Web tại quầy lễ tân | Tham khảo dashboard để biết phòng nào "sẵn sàng" / "đang ở" trước khi nhận khách | Phải gọi điện xác nhận từng phòng |
| (không phải viewer) | Nhân viên buồng phòng–bảo trì | Mobile Android tại hiện trường | Thao tác trên danh sách việc của feature nghiệp vụ — không dùng dashboard | Cập nhật của họ phải lan lên dashboard đúng lúc |

## 3. Scope Boundaries

### In Scope

- Màn hình dashboard web: lưới toàn bộ phòng (50) với 3 trục trạng thái riêng của từng phòng (lưu trú / vệ sinh / bảo trì).
- Chỉ số tại thời điểm xem: đang ở / sẵn sàng / cần dọn / ngừng phục vụ / việc quá hạn / tỷ lệ lấp đầy.
- Cập nhật realtime khi các vai trò thay đổi trạng thái (qua `realtime-sync`).
- Tô cờ/đánh dấu công việc quá hạn theo cờ do feature nghiệp vụ đánh; lọc lưới theo tầng/trạng thái.
- Báo rõ trạng thái mất kết nối và tự tải trạng thái mới nhất khi có mạng lại.
- Phân quyền xem cho quản lý và lễ tân; dashboard chỉ đọc.

### Out of Scope

- Mọi thao tác ghi/đổi trạng thái từ dashboard (nhận/trả phòng, xác nhận dọn, nhận việc sửa...) — thuộc feature nghiệp vụ sở hữu.
- Quy tắc đánh cờ quá hạn theo loại việc — do `housekeeping` / `maintenance` sở hữu; dashboard chỉ hiển thị cờ.
- Dự báo, báo cáo doanh thu, xem lịch sử từ dashboard (PRD: chưa làm).
- Tóm tắt vận hành bằng AI (feature `ai-ops-summary` — AI chỉ đọc số liệu tổng hợp, không quyết định).
- Truy vết ai đổi gì khi nào (feature `audit-log`).
- Thống kê hiệu suất nhân viên, chấm công, KPI.

## 4. User Needs

| ID | User | Context / Trigger | User Need | Expected Outcome | Importance | Evidence |
|----|------|-------------------|-----------|------------------|------------|----------|
| UN-001 | Quản lý | Bất kỳ lúc nào trong ca | Thấy toàn bộ trạng thái phòng (đủ 3 trục riêng) trên một màn hình tại thời điểm xem | Mở dashboard là có bức tranh hiện tại, không phải hỏi ai | Critical | Confirmed (PRD 7.7) |
| UN-002 | Quản lý | Việc dọn/sửa vượt ngưỡng quá hạn | Biết ngay việc nào đang trễ và phòng nào liên quan để can thiệp | Công việc quá hạn được tô cờ trên ô phòng và đếm rõ trong chỉ số | Critical | Confirmed (tôn chỉ: cảnh báo quá hạn bằng quy tắc) |
| UN-003 | Quản lý | Ra quyết định điều phối dựa trên chỉ số | Tin rằng chỉ số đúng thực tế và biết khi nào dữ liệu lỗi thời | 100% chỉ số khớp dữ liệu đối soát; trạng thái kết nối luôn rõ | High | Confirmed (PRD: đo thành công; tôn chỉ: khôi phục kết nối) |
| UN-004 | Lễ tân | Khách sắp đến / giờ cao điểm | Xác định ngay phòng nào "sẵn sàng" tại thời điểm đó | Lọc/xem phòng sẵn sàng luôn đúng thời điểm, không cần gọi điện | Critical | Confirmed (PRD: tham khảo cho lễ tân; tôn chỉ: điều kiện nhận phòng) |
| UN-005 | Quản lý | Khách sạn 50 phòng nhiều tầng | Khoanh vùng nhanh theo tầng và trạng thái | Lọc lưới theo tầng và nhóm trạng thái trả đúng tập phòng | High | Confirmed (PRD phạm vi v1) |
| UN-006 | Quản lý, Lễ tân | Mất kết nối giữa ca | Biết rõ dữ liệu đang xem có thể lỗi thời | Banner trạng thái kết nối rõ ràng; có mạng lại thì tự cập nhật | High | Confirmed (tôn chỉ: kịch bản khôi phục kết nối) |

## 5. Prioritized User Journeys

### Journey 1: Quản lý theo dõi và điều phối trong ca

- **User:** Quản lý
- **Importance:** Critical
- **Trigger:** Ca vận hành đang chạy
- **Expected outcome:** Nắm tình trạng toàn khách sạn tại thời điểm xem và phát hiện việc trễ kịp lúc
- **Related needs:** UN-001, UN-002, UN-003, UN-005

1) Quản lý mở dashboard trên web → lưới 50 phòng (3 trục/phòng) + 6 chỉ số hiển thị.
2) Trong ca, mọi thay đổi (nhận/trả phòng, dọn xong, báo hỏng, sửa xong...) cập nhật lên lưới và chỉ số realtime.
3) Chỉ số "việc quá hạn" tăng / ô phòng bị tô cờ → quản lý lọc "quá hạn" để khoanh vùng → can thiệp qua màn nghiệp vụ sở hữu.
4) Dashboard phản ánh kết quả xử lý ngay; cờ quá hạn tự gỡ khi việc hoàn tất.

**Independent verification:** Kịch bản nghiệm thu "dashboard + cảnh báo quá hạn" thông qua; đối soát chỉ số dashboard với nhật ký/trạng thái nguồn khớp 100%.

### Journey 2: Lễ tân kiểm tra phòng sẵn sàng trước khi nhận khách

- **User:** Lễ tân
- **Importance:** Critical
- **Trigger:** Khách đến nhận phòng
- **Expected outcome:** Chọn đúng phòng đạt điều kiện nhanh, không phải gọi điện xác nhận
- **Related needs:** UN-004, UN-005

1) Lễ tân mở dashboard, lọc trạng thái "sẵn sàng" (kèm tầng nếu cần).
2) Lưới chỉ còn các phòng trống + sạch + đang phục vụ tại thời điểm đó.
3) Lễ tân nhận khách trên màn nghiệp vụ nhận/trả phòng; dashboard cập nhật phòng sang "đang ở" ngay sau xác nhận.

**Independent verification:** Mọi phòng trong nhóm "sẵn sàng" đều thỏa trống + sạch + đang phục vụ; thay đổi trạng thái phản ánh trên dashboard ≤3 giây.

### Journey 3: Cập nhật realtime từ các bộ phận

- **User:** Quản lý, Lễ tân (nguồn thay đổi: lễ tân, nhân viên buồng phòng–bảo trì)
- **Importance:** Critical
- **Trigger:** Bất kỳ thay đổi trạng thái nào ở bất kỳ vai trò nào
- **Expected outcome:** Mọi thiết bị đang mở dashboard thấy cùng trạng thái mới nhất
- **Related needs:** UN-001, UN-003

1) Một vai trò thay đổi trạng thái trên thiết bị của họ (trả phòng, báo dọn xong, báo hỏng...).
2) Máy chủ lưu thành công → phát cập nhật realtime.
3) Dashboard đang mở cập nhật ô phòng và chỉ số liên quan trong ≤3 giây.

**Independent verification:** Đo 100 lượt cập nhật theo tiêu chí nghiệm thu — ≥95% hiển thị trên thiết bị khác ≤3 giây.

### Journey 4: Mất kết nối giữa ca

- **User:** Quản lý, Lễ tân
- **Importance:** High
- **Trigger:** Rớt mạng / đứt kênh realtime khi đang xem
- **Expected outcome:** Không bị hiểu nhầm dữ liệu cũ là mới; tự phục hồi khi có mạng lại
- **Related needs:** UN-006, UN-003

1) Mất kết nối → dashboard hiển thị banner rõ "Mất kết nối — dữ liệu có thể chưa mới nhất".
2) Trong lúc mất kết nối, dữ liệu cũ vẫn xem được nhưng đánh dấu lỗi thời.
3) Có mạng lại → dashboard tự tải trạng thái mới nhất, banner gỡ, hiển thị "Đã kết nối lại — dữ liệu đã cập nhật."

**Independent verification:** Kịch bản "khôi phục kết nối" của tôn chỉ thông qua trên dashboard: không có trạng thái sai-im-lặng sau khi phục hồi.

## 6. User Exceptions & Edge Conditions

| Situation | User Impact | Expected User-facing Outcome | Related Journey / Need |
|-----------|-------------|------------------------------|------------------------|
| Mất mạng khi đang xem | Không biết dữ liệu còn mới không | Banner offline rõ + dữ liệu đánh dấu có thể lỗi thời; có lại mạng tự cập nhật | J4, UN-006 |
| Tải dashboard ban đầu thất bại | Không có dữ liệu để xem | Trạng thái lỗi rõ ràng + nút thử lại; không hiển thị lưới trống như thể "không có phòng" | J1 |
| Phiên đăng nhập hết hạn khi đang mở | Mất quyền xem | Yêu cầu đăng nhập lại đúng vai trò (theo `auth-roles`) | J1, UN-006 |
| Tất cả phòng ngừng phục vụ | Tỷ lệ lấp đầy vô nghĩa | Hiển thị "không áp dụng" thay vì con số sai | J1, UN-003 |
| Phòng đang ở bị ngừng phục vụ giữa chừng | Trạng thái phức hợp dễ nhầm | Ô phòng hiển thị đồng thời "đang ở" + "ngừng phục vụ" trên 2 trục riêng — không gộp | J1, UN-001 |
| Nhiều việc quá hạn cùng lúc | Khó khoanh vùng | Lọc "quá hạn" chỉ còn các phòng/việc liên quan | J1, UN-002, UN-005 |
| Giờ cao điểm nhiều cập nhật dồn | Khó theo kịp thay đổi | Lưới cập nhật tại chỗ, giữ ngữ cảnh bộ lọc/vùng nhìn đang dùng | J3, UN-001 |
| Lọc ra 0 phòng | Tưởng hệ thống lỗi | Trạng thái rỗng rõ "Không có phòng nào khớp bộ lọc." | J2 |

## 7. User-side Constraints

- Ngôn ngữ: tiếng Việt toàn bộ nhãn và thông báo.
- Kênh/thiết bị: dashboard trên web cho quản lý + lễ tân (phạm vi Android xem OQ-3); nhân viên dùng mobile trong feature nghiệp vụ riêng.
- Môi trường: 1 khách sạn 50 phòng, 30 phiên đăng nhập đồng thời, dữ liệu giả lập (tôn chỉ).
- Điều kiện sử dụng: phải đăng nhập đúng vai trò quản lý hoặc lễ tân; dashboard chỉ đọc — không cho đổi trạng thái từ màn hình này.
- Ràng buộc hiển thị lõi: 3 trục trạng thái luôn tách riêng, không trộn thành 1 trạng thái.

## 8. Assumptions & Validation

| Assumption | Impact if Wrong | Validation Status | Next Action |
|------------|-----------------|-------------------|-------------|
| Mẫu số tỷ lệ lấp đầy = phòng không "ngừng phục vụ" | Chỉ số lấp đầy sai lệch kỳ vọng nghiệm thu | Assumption có căn cứ từ công thức tôn chỉ | Xác nhận khi đối soát nghiệm thu |
| Chỉ số "phòng cần dọn" = phòng có trục vệ sinh chưa đạt "sạch" (gồm đang dọn, chờ kiểm tra) | Chỉ số cần dọn thiếu hoặc thừa | Chưa xác nhận — OQ-2 | Chốt cách đếm trước khi đặc tả chỉ số |
| Cờ "quá hạn" do feature nghiệp vụ sở hữu đánh, dashboard chỉ hiển thị và đếm | Nếu sai, dashboard phải tự tính ngưỡng → phình scope | Assumption nhất quán phạm vi "giám sát, không sở hữu luồng" | Xác nhận khi `maintenance` chi tiết hóa (OQ-1) |
| Dashboard v1 chỉ cần trên web | Nếu nghiệm thu bắt buộc Android → thiếu nền tảng | Chưa xác nhận — OQ-3 | Đối chiếu tiêu chí nghiệm thu với điều phối viên |

## 9. User Success Criteria

| ID | User Outcome | Baseline | Target | Measurement | Review Period |
|----|--------------|----------|--------|-------------|---------------|
| USC-001 | Quản lý có cái nhìn tổng tin cậy | Chưa có — phải hỏi từng người | 100% chỉ số dashboard khớp dữ liệu đối soát | Đối soát trong nghiệm thu | Nghiệm thu (02/11/2026) |
| USC-002 | Mọi thiết bị thấy cùng trạng thái mới nhất | Chưa có — cập nhật thủ công qua lễ tân | ≥95% trong 100 lượt cập nhật hiển thị trên thiết bị khác ≤3 giây | Đo theo tiêu chí tôn chỉ (50 phòng, 30 phiên) | Nghiệm thu |
| USC-003 | Việc trễ không còn lặng lẽ | Chưa có — quá hạn phải tự phát hiện | 100% công việc có cờ quá hạn được tô cờ và đếm trên dashboard | Kịch bản nghiệm thu "dashboard + cảnh báo quá hạn" | Sprint 3 |
| USC-004 | Nhãn "sẵn sàng" luôn đáng tin | Chưa có | 0 phòng hiển thị "sẵn sàng" khi chưa đủ trống + sạch + đang phục vụ | Đối chiếu trạng thái nguồn trong test | Nghiệm thu |

## 10. Open Questions

- [ ] OQ-1: Ngưỡng "quá hạn" cho công việc bảo trì là bao nhiêu (việc dọn đã chốt 60 phút ở `housekeeping`)? Chỉ số "việc quá hạn" của dashboard chỉ đầy đủ khi ngưỡng này được chốt — quyết cùng feature `maintenance`.
- [ ] OQ-2: Chỉ số "phòng cần dọn" đếm chỉ phòng ở trạng thái "cần dọn", hay mọi phòng chưa đạt "sạch" (gồm "đang dọn", "chờ kiểm tra")?
- [ ] OQ-3: Dashboard có cần hiển thị trong app Android cho quản lý/lễ tân không — tiêu chí nghiệm thu tôn chỉ liệt kê "dashboard" trong bộ kịch bản chạy trên cả Flutter Web và Android, trong khi PRD ghi "quản lý mở dashboard trên web"?
- [ ] OQ-4: Chạm vào một ô phòng có mở màn chi tiết phòng (đủ 3 trục + công việc đang mở + liên kết sang màn xử lý của housekeeping/maintenance) không, hay lưới tổng quan đã đủ cho v1?
