---
type: brd
feature: room-dashboard
status: draft
updated: 2026-09-23
links:
  - "[[docs/features/room-dashboard/room-dashboard-urd.md|Room Dashboard URD]]"
  - "[[docs/features/room-dashboard/brainstorms/giam-sat-ba-truc-trang-thai.md|Brainstorm: Giám sát 3 trục trạng thái]]"
  - "[[docs/_product/prd.md|Product PRD]]"
  - "[[Ton_Chi_Du_An_WPCTeam.txt|Tôn chỉ dự án]]"
---

# room-dashboard — Business Requirements Document

## 1. Executive Summary

Quản lý khách sạn hiện không có cái nhìn tổng theo thời điểm về trạng thái phòng: lưu trú nằm ở lễ tân, vệ sinh nằm ở buồng phòng, bảo trì nằm ở tổ kỹ thuật — muốn biết gì cũng phải hỏi từng người, và việc nào đang trễ thì không ai chủ động báo. Feature room-dashboard dựng một màn hình giám sát realtime duy nhất: lưới 50 phòng hiển thị riêng 3 trục trạng thái (lưu trú / vệ sinh / bảo trì), kèm chỉ số tại thời điểm xem — đang ở, sẵn sàng, cần dọn, ngừng phục vụ, công việc quá hạn, tỷ lệ lấp đầy — và tô cờ việc quá hạn bằng quy tắc để quản lý can thiệp ngay trong ca. Dashboard chỉ giám sát: nó đọc trạng thái do các feature vận hành sở hữu và lan qua realtime-sync, không sở hữu luồng dọn/bảo trì.

## 2. Business Problem & Context

### 2.1 Problem Statement

| ID | Business Condition | Baseline | Business Impact | Evidence |
|----|--------------------|----------|-----------------|----------|
| BP-room-dashboard-01 | Trạng thái phòng trên 3 trục được cập nhật rời rạc giữa các vai trò; quản lý không có cái nhìn tổng theo thời điểm | Chưa có — muốn biết phải hỏi từng bộ phận | Điều phối trong ca chậm và dễ nhầm ("phòng này đang ở trạng thái gì tại thời điểm này") | Confirmed (PRD: vấn đề cốt lõi) |
| BP-room-dashboard-02 | Công việc dọn/sửa quá hạn không tự lộ diện | Chưa có — quản lý tự phát hiện muộn | Phòng "treo" không bán được; việc trễ kéo dài cả ca | Confirmed (PRD 7.4 rủi ro; tôn chỉ: cảnh báo quá hạn) |
| BP-room-dashboard-03 | Lễ tân không chắc phòng nào thật sự sẵn sàng tại thời điểm nhận khách | Chưa có — phải gọi điện xác nhận từng phòng | Nhận khách chậm; rủi ro nhận vào phòng chưa đạt điều kiện | Confirmed (PRD: ai đang đau) |

### 2.2 Opportunity & Why Now

Dashboard là feature nhóm "Giám sát & truy vết" trong Feature Map, mức Must, chạy Sprint 3 (dashboard + cảnh báo quá hạn — khung tới 19/10). Nó chỉ có giá trị sau khi các luồng vận hành Sprint 2 (nhận/trả → dọn → sửa) đã sinh trạng thái thật — vì vậy làm đúng lúc này là khi 3 trục đã có nguồn dữ liệu để hiển thị. Không có feature này, cam kết tôn chỉ "đồng bộ thay đổi giữa các thiết bị; dashboard thể hiện ... công việc quá hạn và tỷ lệ lấp đầy" và kịch bản nghiệm thu "dashboard" không kiểm chứng được.

### 2.3 Strategic Alignment

Trực tiếp phục vụ mục tiêu tôn chỉ: "dashboard thể hiện phòng đang ở, phòng sẵn sàng, phòng cần dọn, phòng ngừng phục vụ, công việc quá hạn và tỷ lệ lấp đầy tại thời điểm xem" + "hỗ trợ điều phối vận hành bằng dữ liệu" + "trạng thái lưu trú, vệ sinh và bảo trì được theo dõi riêng để tránh nhầm lẫn". Cũng là nguồn số liệu đầu vào cho `ai-ops-summary` (feature sau đọc chỉ số dashboard để tóm tắt ca).

## 3. Current State, Future State & Gap

### 3.1 Current State (AS-IS)

Quản lý muốn biết tình trạng phòng phải đi kiểm tra hoặc gọi/hỏi lễ tân — người duy nhất nhập liệu tại quầy; buồng phòng và bảo trì báo miệng hoặc gọi điện; không có màn hình nào cho thấy "tại thời điểm này" toàn khách sạn ra sao; việc quá hạn chỉ lộ ra khi ai đó chủ động phát hiện.

### 3.2 Future State (TO-BE)

Một dashboard web realtime: quản lý mở lên là thấy lưới 50 phòng với 3 trục riêng và 6 chỉ số tại thời điểm xem; mọi thay đổi từ các vai trò lan lên ≤3 giây; việc quá hạn tự tô cờ; lễ tân tham khảo cùng màn hình trước khi nhận khách; mất mạng thì dashboard báo rõ thay vì im lặng hiển thị dữ liệu cũ.

### 3.3 Gap

| Gap | Mô tả | Ưu tiên |
|-----|-------|---------|
| G1 | Chưa có cái nhìn tổng realtime phủ đủ 3 trục trạng thái cho toàn bộ phòng | Cao |
| G2 | Chưa có chỉ số tổng hợp tại thời điểm xem (đang ở / sẵn sàng / cần dọn / ngừng phục vụ / quá hạn / lấp đầy) | Cao |
| G3 | Chưa có cơ chế tự lộ diện công việc quá hạn trên màn hình giám sát | Cao |
| G4 | Chưa có chỉ báo sức khỏe dữ liệu (mất kết nối / lỗi thời) cho người giám sát | Trung bình |

## 4. Stakeholders

| Stakeholder Role | Interest | Influence | Stakeholder Requirement / Expectation |
|------------------|----------|-----------|----------------------------------------|
| Quản lý khách sạn | Điều phối trong ca dựa trên dữ liệu đúng thời điểm | Cao (người dùng chính) | Thấy toàn bộ phòng + việc quá hạn ngay; chỉ số tin cậy được để ra quyết định |
| Lễ tân | Nhận khách nhanh, đúng phòng đạt điều kiện | Trung bình | Tham khảo phòng "sẵn sàng" theo thời gian thực |
| Nhân viên buồng phòng–bảo trì | (Nguồn dữ liệu gián tiếp) | Thấp | Cập nhật của họ trên mobile phải lan lên dashboard đúng lúc |
| WPCTeam (dev) | Hoàn thành MVP đúng phạm vi 8 tuần | Cao | Scope khả thi trong Sprint 3; không phình tính năng giám sát |
| Giảng viên hướng dẫn | Đánh giá theo tiêu chí môn học | Cao | Kịch bản "dashboard" + "khôi phục kết nối" thông qua trên nền tảng nghiệm thu |

## 5. Business Objectives & Success Measures

| ID | Objective | Baseline | Target | Timeframe | Success Measure |
|----|-----------|----------|--------|-----------|-----------------|
| BO-room-dashboard-01 | Có một cái nhìn tổng realtime tin cậy cho toàn bộ phòng | Chưa có — quản lý hỏi từng người | 100% chỉ số dashboard khớp dữ liệu đối soát; cập nhật ≤3 giây | Sprint 3 → nghiệm thu | Đối soát chỉ số với dữ liệu nguồn trong nghiệm thu |
| BO-room-dashboard-02 | Công việc quá hạn luôn lộ diện để can thiệp kịp trong ca | Chưa có | 100% việc có cờ quá hạn được tô cờ + đếm trên dashboard | Sprint 3 | Kịch bản nghiệm thu "dashboard + cảnh báo quá hạn" |
| BO-room-dashboard-03 | Mọi vai trò giám sát thấy cùng một trạng thái mới nhất | Chưa có | ≥95% trong 100 lượt cập nhật hiển thị trên thiết bị khác ≤3 giây (50 phòng, 30 phiên) | Nghiệm thu | Đo theo tiêu chí tôn chỉ |

## 6. Business Scope

### 6.1 In Scope

- Màn hình dashboard web cho quản lý và lễ tân: lưới toàn bộ phòng (50), 3 trục trạng thái riêng mỗi phòng, 6 chỉ số thời điểm xem, cập nhật realtime, cờ/cảnh báo quá hạn, lọc theo tầng/trạng thái, chỉ báo mất kết nối, phân quyền xem, chỉ-đọc.

### 6.2 Out of Scope

- Thao tác ghi/đổi trạng thái từ dashboard; luồng dọn phòng (`housekeeping`), luồng bảo trì (`maintenance`), nhận/trả phòng (`check-in-out`), danh mục phòng (`room-catalog`) — dashboard chỉ đọc kết quả của chúng.
- Dự báo, báo cáo doanh thu, xem lịch sử từ dashboard (PRD: chưa làm).
- Tóm tắt AI (`ai-ops-summary`); truy vết nhật ký (`audit-log`); kênh realtime nền (`realtime-sync` — dependency, không phải scope của feature này).
- Nhiều khách sạn/chuỗi; khách tự xem; OTA/PMS; IoT.

### 6.3 Assumptions

- Các feature vận hành (check-in-out, housekeeping, maintenance) sinh và sở hữu trạng thái 3 trục; dashboard chỉ đọc — xem OQ-1 về cờ quá hạn bảo trì.
- `realtime-sync` cung cấp kênh cập nhật ≤3 giây và xử lý xung đột/mất mạng phía nguồn.
- "Phòng có thể phục vụ" (mẫu số lấp đầy) = phòng không "ngừng phục vụ".
- Dashboard v1 trên web; phạm vi Android xem OQ-3.

### 6.4 Constraints

- MVP 8 tuần, nhóm 3 người ~20 giờ/người/tuần (tôn chỉ); dashboard chạy Sprint 3.
- Tiếng Việt, dữ liệu giả lập, 1 khách sạn 50 phòng, 30 phiên đồng thời.
- Cảnh báo quá hạn bằng quy tắc, không phụ thuộc AI (tôn chỉ).
- 3 trục trạng thái tách riêng — ràng buộc lõi tôn chỉ.
- Kiểm tra quyền ở máy chủ cho quyền xem theo vai trò.

### 6.5 Dependencies

- `housekeeping` — trục vệ sinh + cờ quá hạn việc dọn (đã chi tiết hóa, ngưỡng 60 phút).
- `maintenance` — trục bảo trì + cờ quá hạn việc sửa (chưa chi tiết hóa; ngưỡng chờ OQ-1).
- `realtime-sync` — kênh cập nhật realtime ≤3 giây (chưa chi tiết hóa).
- `room-catalog` — danh mục 50 phòng + dữ liệu tầng (phục vụ lưới và lọc theo tầng).
- `check-in-out` — trục lưu trú (trống/đang ở).
- `auth-roles` — vai trò quản lý/lễ tân cho quyền xem.

## 7. High-level Business Requirements

| ID | Business Requirement | Business Objective | Priority |
|----|----------------------|--------------------|----------|
| BREQ-room-dashboard-01 | Hệ thống phải hiển thị lưới toàn bộ phòng với 3 trục trạng thái riêng (lưu trú / vệ sinh / bảo trì) tại thời điểm xem, cập nhật realtime | BO-room-dashboard-01 | Must |
| BREQ-room-dashboard-02 | Hệ thống phải hiển thị chỉ số tổng hợp tại thời điểm xem: đang ở / sẵn sàng / cần dọn / ngừng phục vụ / việc quá hạn / tỷ lệ lấp đầy (mẫu = 0 → "không áp dụng") | BO-room-dashboard-01, BO-room-dashboard-03 | Must |
| BREQ-room-dashboard-03 | Công việc quá hạn phải được tô cờ trên dashboard và đếm vào chỉ số riêng, bằng quy tắc không AI | BO-room-dashboard-02 | Must |
| BREQ-room-dashboard-04 | Người xem phải lọc được lưới theo tầng và theo nhóm trạng thái | BO-room-dashboard-01 | Must |
| BREQ-room-dashboard-05 | Dashboard phải báo rõ khi mất kết nối/dữ liệu lỗi thời và tự cập nhật lại khi có mạng | BO-room-dashboard-03 | Must |
| BREQ-room-dashboard-06 | Dashboard chỉ cho quản lý và lễ tân xem, chỉ đọc — không thao tác ghi | BO-room-dashboard-03 | Must |

## 8. Business Rules

| ID | Business Rule | Rationale |
|----|---------------|-----------|
| BR-room-dashboard-01 | Ba trục lưu trú / vệ sinh / bảo trì luôn hiển thị riêng, không gộp thành 1 trạng thái | Ràng buộc lõi tôn chỉ để tránh nhầm lẫn |
| BR-room-dashboard-02 | Tỷ lệ lấp đầy = phòng đang ở ÷ phòng có thể phục vụ × 100%; mẫu số = 0 hiển thị "không áp dụng" | Công thức tôn chỉ |
| BR-room-dashboard-03 | Phòng chỉ được tính/hiển thị "sẵn sàng" khi trống + sạch + bảo trì bình thường | Điều kiện nhận phòng tôn chỉ; "sẵn sàng" là composite không phải trạng thái lưu (tham chiếu `housekeeping` BR-housekeeping-03) |
| BR-room-dashboard-04 | Cờ "quá hạn" do feature nghiệp vụ sở hữu đánh theo quy tắc (việc dọn 60 phút theo `housekeeping`; việc sửa chờ OQ-1 ở `maintenance`); dashboard chỉ hiển thị và đếm — không dùng AI | Tôn chỉ: cảnh báo quá hạn bằng quy tắc; dashboard giám sát, không sở hữu luồng |
| BR-room-dashboard-05 | Dashboard chỉ đọc: mọi thay đổi trạng thái/công việc thực hiện ở feature nghiệp vụ sở hữu | Phạm vi giám sát của Feature Map; chống scope creep |
| BR-room-dashboard-06 | Chỉ vai trò quản lý và lễ tân được xem dashboard | PRD 7.7 (màn hình tổng cho quản lý, tham khảo cho lễ tân) + project profile |

## 9. Cost-Benefit (định tính)

### 9.1 Cost Drivers

- Effort phát triển trong Sprint 3 (đã nằm trong kế hoạch 480 giờ của tôn chỉ): màn hình dashboard web (lưới 50 phòng + chỉ số + bộ lọc), tính chỉ số tổng hợp tại thời điểm xem, hiển thị cờ quá hạn, chỉ báo kết nối.
- Phụ thuộc kênh realtime và trạng thái nguồn: chi phí đã nằm ở các feature upstream (`realtime-sync`, `housekeeping`, `maintenance`, `check-in-out`, `room-catalog`, `auth-roles`).

### 9.2 Expected Benefits

- Quản lý điều phối trong ca bằng dữ liệu thay vì hỏi từng người → quyết định nhanh và đúng hơn.
- Việc quá hạn lộ diện ngay → giảm phòng "treo" không bán được trong giờ cao điểm.
- Lễ tân tự tin nhận khách vào phòng đạt điều kiện → giảm khiếu nại, giảm thao tác xác nhận thủ công.
- Chỉ số dashboard là nguồn đầu vào cho `ai-ops-summary` và kênh chứng minh tiêu chí nghiệm thu realtime.

### 9.3 Priority / Rough ROI

Ưu tiên cao — đây là feature "Must" trong Feature Map và là điểm chạm chính của persona primary (quản lý). Chi phí nằm trong kế hoạch Sprint 3; rủi ro lớn nhất là phụ thuộc upstream — giảm bằng thứ tự sprint và dữ liệu giả lập phủ đủ 3 trục.

## 10. Risks

| ID | Risk | Likelihood | Impact | Mitigation | Owner Role |
|----|------|------------|--------|------------|------------|
| RISK-room-dashboard-01 | Chỉ số dashboard lệch dữ liệu thật | Thấp | Quản lý điều phối sai trong ca — mất niềm tin vào sản phẩm | Đối soát nghiệm thu 100% khớp; hiển thị rõ offline/lỗi thay vì im lặng | Trưởng nhóm |
| RISK-room-dashboard-02 | Upstream chưa sẵn (`maintenance`, `realtime-sync` chưa chi tiết hóa) | Trung bình | Dashboard thiếu trục bảo trì / cờ quá hạn sửa / kênh realtime | Theo thứ tự sprint (dashboard S3 sau vận hành S2); dữ liệu giả lập phủ đủ 3 trục để phát triển song song | Trưởng nhóm |
| RISK-room-dashboard-03 | Scope creep: quản lý đòi thao tác trực tiếp trên dashboard | Trung bình | Feature phình, trễ Sprint 3 | Giữ chỉ-đọc (BR-05); can thiệp qua màn feature sở hữu; điều hướng là P1 | PM |
| RISK-room-dashboard-04 | Ngưỡng quá hạn bảo trì chưa chốt (OQ-1) | Trung bình | Chỉ số "việc quá hạn" thiếu phần việc sửa | Cờ do feature nguồn đánh — chỉ số tự đầy đủ khi `maintenance` chốt ngưỡng | PM |
| RISK-room-dashboard-05 | Nghiệm thu đòi dashboard trên Android (OQ-3) | Thấp | Thiếu nền tảng nếu chỉ làm web | Chốt OQ-3 sớm với điều phối viên; nếu cần thì thiết kế lưới responsive | Trưởng nhóm |

## 11. Open Questions

- [ ] OQ-1: Ngưỡng "quá hạn" cho công việc bảo trì là bao nhiêu (việc dọn đã chốt 60 phút ở `housekeeping`)? Chỉ số "việc quá hạn" của dashboard chỉ đầy đủ khi ngưỡng này được chốt — quyết cùng feature `maintenance`.
- [ ] OQ-4: Chạm vào một ô phòng có mở màn chi tiết phòng (đủ 3 trục + công việc đang mở + liên kết sang màn xử lý của housekeeping/maintenance) không, hay lưới tổng quan đã đủ cho v1?
