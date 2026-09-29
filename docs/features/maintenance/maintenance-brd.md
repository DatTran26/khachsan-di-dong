---
type: brd
feature: maintenance
status: draft
updated: 2026-09-17
links:
  - "[[docs/features/maintenance/maintenance-urd.md|Maintenance URD]]"
  - "[[docs/features/maintenance/brainstorms/bao-hong-va-bao-tri.md|Brainstorm: Báo hỏng & chu trình bảo trì]]"
  - "[[Ton_Chi_Du_An_WPCTeam.txt|Tôn chỉ dự án]]"
---

# maintenance — Business Requirements Document

## 1. Executive Summary

Báo hỏng và bảo trì hiện vận hành rời rạc: hỏng hóc được truyền miệng/điện thoại đến lễ tân rồi mới tới bảo trì, phòng đang sửa vẫn có thể bị nhận khách nhầm vì trạng thái không nhất quán, và không có bằng chứng truy vết tiến độ. Feature maintenance số hóa chu trình này — mọi vai trò báo hỏng trực tiếp kèm phòng + mô tả, phòng tự "ngừng phục vụ" trên trục bảo trì riêng để chặn nhận khách, nhân viên bảo trì nhận và báo xong trên mobile, phòng tự mở lại khi hết việc — để loại bỏ sự cố bán nhầm phòng đang sửa và mọi báo hỏng đều có trạng thái truy vết được.

## 2. Business Problem & Context

### 2.1 Problem Statement

| ID | Business Condition | Baseline | Business Impact | Evidence |
|----|--------------------|----------|-----------------|----------|
| BP-maintenance-01 | Phòng đang sửa vẫn có thể bị nhận khách nhầm vì trạng thái "ngừng phục vụ" không được cập nhật/chia sẻ tức thời | Chưa có — xác lập qua log demo | Sự cố vận hành nghiêm trọng: khách vào phòng chưa an toàn, khiếu nại, mất uy tín | Confirmed (PRD rủi ro chính: "phòng đang sửa vẫn bị nhận khách") |
| BP-maintenance-02 | Báo hỏng truyền qua nhiều trung gian (nhân viên → lễ tân → bảo trì), thiếu phòng/vị trí, không trạng thái | Chưa có | Việc hỏng bị trì hoãn/sót; phòng ngừng phục vụ kéo dài hơn cần thiết → mất doanh thu phòng | Confirmed (tôn chỉ: "giảm việc cập nhật rời rạc") |
| BP-maintenance-03 | Không truy vết được ai báo/ai sửa/khi nào xong | Chưa có | Không đối soát được khi tranh chấp; không đánh giá được thời gian xử lý | Confirmed (tôn chỉ: ghi nhật ký ở máy chủ) |

### 2.2 Opportunity & Why Now

`maintenance` nằm trong luồng vận hành lõi Sprint 2 (22/09–05/10): "Nhận/trả phòng, công việc buồng phòng/báo hỏng". Không có feature này: (1) trục bảo trì — một trong 3 trục trạng thái bắt buộc của tôn chỉ — không có chủ sở hữu; (2) điều kiện nhận phòng "không ngừng phục vụ" của `check-in-out` không có nguồn dữ liệu; (3) dashboard Sprint 3 thiếu nhóm chỉ số "ngừng phục vụ / việc quá hạn".

### 2.3 Strategic Alignment

Trực tiếp phục vụ mục tiêu tôn chỉ: "công việc dọn phòng, báo hỏng và lịch sử thay đổi" + "trạng thái lưu trú, vệ sinh và bảo trì được theo dõi riêng để tránh nhầm lẫn" + "chỉ cho nhận phòng khi phòng trống, đã sạch và không ngừng phục vụ".

## 3. Current State, Future State & Gap

### 3.1 Current State (AS-IS)

Nhân viên phát hiện hỏng → báo miệng/gọi điện cho lễ tân → lễ tân gọi bảo trì → bảo trì sửa xong báo miệng lại → lễ tân cập nhật phòng sau. Trong khoảng giữa, phòng "đang sửa" chỉ nằm trong đầu người biết — lễ tân ca sau hoặc quản lý không có cách nào chắc chắn.

### 3.2 Future State (TO-BE)

Ai phát hiện cũng báo hỏng trực tiếp vào hệ thống kèm phòng + mô tả; phòng tự "ngừng phục vụ" và bị chặn nhận khách ngay lập tức trên mọi thiết bị; nhân viên bảo trì tự nhận việc từ danh sách chung và báo xong tại hiện trường; phòng tự mở lại khi hết việc; mọi thay đổi có nhật ký và lan realtime ≤3 giây.

### 3.3 Gap

| Gap | Mô tả | Ưu tiên |
|-----|-------|---------|
| G1 | Chưa có kênh báo hỏng trực tiếp kèm phòng/mô tả cho mọi vai trò | Cao |
| G2 | Chưa có cơ chế tự chặn nhận khách vào phòng đang sửa (trục bảo trì) | Cao |
| G3 | Chưa có danh sách việc bảo trì thống nhất với trạng thái xử lý | Cao |
| G4 | Chưa có cảnh báo quá hạn và nhật ký truy vết cho việc bảo trì | Trung bình |

## 4. Stakeholders

| Stakeholder Role | Interest | Influence | Stakeholder Requirement / Expectation |
|------------------|----------|-----------|----------------------------------------|
| Quản lý khách sạn | Phòng sửa không bị bán nhầm; điều phối việc trễ | Cao (quyết định nghiệp vụ) | Thấy việc đang mở/quá hạn trên dashboard; chỉ định lại khi cần; đối soát được ai làm gì |
| Lễ tân | Không nhận nhầm phòng đang sửa | Trung bình | Trạng thái "ngừng phục vụ" luôn đúng và bị chặn khi nhận phòng; đặt/gỡ ngừng tay được |
| Nhân viên bảo trì | Việc rõ ràng, thao tác nhanh tại hiện trường | Trung bình | Danh sách việc kèm phòng/mô tả/vị trí; nhận/báo xong ít chạm trên mobile |
| Mọi vai trò (người báo hỏng) | Báo hỏng nhanh, có theo dõi | Trung bình | Báo trong vài chạm; xem lại trạng thái báo hỏng của mình |
| WPCTeam (dev) | Hoàn thành MVP đúng phạm vi 8 tuần | Cao | Scope khả thi sprint 2; không phình tính năng |
| Giảng viên hướng dẫn | Đánh giá theo tiêu chí môn học | Cao | Luồng báo hỏng bắt buộc thông qua trên Flutter Web + Android |

## 5. Business Objectives & Success Measures

| ID | Objective | Baseline | Target | Timeframe | Success Measure |
|----|-----------|----------|--------|-----------|-----------------|
| BO-maintenance-01 | Loại bỏ sự cố nhận khách vào phòng đang sửa | Chưa có hệ thống — sự cố ngẫu nhiên | 0 lượt nhận khách vào phòng "ngừng phục vụ" | Nghiệm thu | Kịch bản nghiệm thu bắt buộc; 100% lượt thử bị chặn |
| BO-maintenance-02 | Rút ngắn thời gian từ báo hỏng đến mở lại phục vụ | Chưa có — xác lập qua log demo sprint 2 | Đo được thời gian trung bình; 100% báo hỏng có trạng thái xử lý rõ tới khi đóng | Sprint 2–3 | Đối soát nhật ký: mốc báo, mốc nhận, mốc hoàn tất |
| BO-maintenance-03 | 100% việc bảo trì truy vết được người báo/người sửa/mốc thời gian | Chưa có | Mọi thay đổi trạng thái có bản ghi ai/khi nào/từ→sang | Nghiệm thu | Đối soát audit-log khớp danh sách việc |

## 6. Business Scope

### 6.1 In Scope

- Chu trình báo hỏng và sửa chữa tại 1 khách sạn 50 phòng: báo hỏng từ mọi vai trò, phòng tự ngừng phục vụ, nhân viên bảo trì nhận/xử lý/hoàn tất, phòng tự mở lại, đặt/gỡ ngừng tay, hủy báo nhầm, cảnh báo quá hạn, đồng bộ realtime.

### 6.2 Out of Scope

- Kho vật tư, chi phí sửa chữa, lịch bảo trì định kỳ, mức độ ưu tiên hỏng (PRD "chưa làm").
- Nhiều khách sạn/chuỗi; thanh toán, kế toán, OTA/PMS, IoT.
- Chấm công/phân ca nhân viên bảo trì; tính lương/KPI.
- Báo hỏng bởi khách lưu trú (khách không dùng hệ thống).

### 6.3 Assumptions

- Cơ chế giao việc MVP: danh sách chung, nhân viên bảo trì tự nhận — xem OQ-2.
- Báo xong → phòng mở lại ngay không qua xác nhận chất lượng (theo PRD).
- Nhân viên có thiết bị Android hoặc truy cập web trên điện thoại.

### 6.4 Constraints

- MVP 8 tuần, nhóm 3 người ~20 giờ/người/tuần (tôn chỉ).
- Tiếng Việt, dữ liệu giả lập, 1 khách sạn 50 phòng.
- 3 trục trạng thái phòng tách biệt (lưu trú/vệ sinh/bảo trì) — maintenance chỉ sở hữu trục bảo trì (tôn chỉ + PRD).
- Cảnh báo quá hạn bằng quy tắc, không phụ thuộc AI (tôn chỉ).

### 6.5 Dependencies

- Feature `room-catalog` cung cấp danh mục phòng làm đích báo hỏng (sprint 1).
- Feature `auth-roles` cung cấp vai trò và kiểm quyền (sprint 1).
- Feature `check-in-out` tôn trọng "ngừng phục vụ" khi nhận khách (cùng sprint 2, phát triển song song).
- Feature `audit-log` nhận ghi nhật ký mọi thay đổi (cùng nhóm vận hành).
- Feature `room-dashboard` hiển thị phòng ngừng phục vụ + việc quá hạn (sprint 3).
- Feature `realtime-sync` là cơ chế lan truyền mọi thay đổi (sprint 1–2).

## 7. High-level Business Requirements

| ID | Business Requirement | Business Objective | Priority |
|----|----------------------|--------------------|----------|
| BREQ-maintenance-01 | Mọi vai trò phải báo được hỏng hóc kèm phòng + mô tả mà không qua trung gian | BO-maintenance-02 | Must |
| BREQ-maintenance-02 | Phòng có việc bảo trì đang mở phải tự "ngừng phục vụ" và bị chặn nhận khách | BO-maintenance-01 | Must |
| BREQ-maintenance-03 | Nhân viên bảo trì phải nhận và báo hoàn tất việc trên thiết bị di động với thao tác tối thiểu | BO-maintenance-02 | Must |
| BREQ-maintenance-04 | Phòng chỉ trở lại phục vụ khi không còn việc bảo trì đang mở hoặc được gỡ tay hợp lệ | BO-maintenance-01 | Must |
| BREQ-maintenance-05 | Mọi thay đổi trạng thái phải được ghi nhật ký ở máy chủ phục vụ đối soát | BO-maintenance-03 | Must |

## 8. Business Rules

| ID | Business Rule | Rationale |
|----|---------------|-----------|
| BR-maintenance-01 | Có việc bảo trì đang mở → phòng "ngừng phục vụ"; hết việc mở → tự về "bình thường" | Chặn bán nhầm tự động, không phụ thuộc ai nhớ cập nhật |
| BR-maintenance-02 | Chỉ được nhận khách khi phòng trống + đã sạch + không ngừng phục vụ | Tôn chỉ; chống sự cố an toàn |
| BR-maintenance-03 | Chỉ nhân viên bảo trì (vai trò gộp buồng phòng–bảo trì) nhận/báo xong việc; báo xong chỉ trên việc do chính mình đang sửa | Đúng người đúng việc, truy vết trách nhiệm |
| BR-maintenance-04 | Chỉ lễ tân/quản lý đặt/gỡ "ngừng phục vụ" thủ công; đặt tay bắt buộc lý do | Ngừng phục vụ vì lý do vận hành là quyền điều phối (project-profile) |
| BR-maintenance-05 | Việc đã "hoàn tất" hoặc "đã hủy" không mở lại — sửa nhầm thì tạo báo hỏng mới | Giữ vết lịch sử truy vết |
| BR-maintenance-06 | "Ngừng phục vụ" chặn nhận khách mới nhưng không đá khách đang ở | An toàn nhưng không phá trải nghiệm khách hiện tại |

## 9. Cost-Benefit (định tính)

### 9.1 Cost Drivers

- Effort phát triển trong sprint 2 (đã nằm trong kế hoạch 480 giờ): màn báo hỏng, danh sách/chi tiết việc bảo trì trên mobile, cơ chế tự ngừng/mở lại phòng, quy tắc quá hạn, đồng bộ realtime.
- Chi phí vận hành nền tảng: đã nằm trong hạng mục VPS + CSDL của ngân sách chung.

### 9.2 Expected Benefits

- Loại bỏ sự cố "nhận khách vào phòng đang sửa" — rủi ro vận hành nặng nhất của luồng.
- Phòng hỏng quay vòng nhanh hơn: báo trực tiếp không qua trung gian, mở lại tự động.
- Có bằng chứng truy vết phục vụ đối soát và đánh giá thời gian xử lý.

### 9.3 Priority / Rough ROI

Ưu tiên cao — feature Must trong Feature Map và là chủ sở hữu duy nhất của trục bảo trì (không có nó thì điều kiện nhận phòng của tôn chỉ không hoàn thiện và dashboard thiếu nhóm chỉ số). Chi phí đã nằm trong kế hoạch; lợi ích đo được qua kịch bản nghiệm thu và log.

## 10. Risks

| ID | Risk | Likelihood | Impact | Mitigation | Owner Role |
|----|------|------------|--------|------------|------------|
| RISK-maintenance-01 | Nhân viên bảo trì không mở app → không thấy việc mới | Trung bình | Việc hỏng treo, phòng ngừng kéo dài | Cảnh báo quá hạn lên dashboard quản lý; quy trình demo có hướng dẫn | Quản lý |
| RISK-maintenance-02 | Mở lại phòng không qua kiểm tra chất lượng | Trung bình | Phòng chưa thật sự xong đã bán lại | PRD chấp nhận mở trực tiếp; nhật ký truy vết người báo xong; đánh giá lại sau pilot | Quản lý |
| RISK-maintenance-03 | Báo hỏng trùng/spam làm nhiễu danh sách việc | Trung bình | Khó theo dõi việc thật | Cảnh báo "đang có việc mở" + hủy được khi chưa nhận | Quản lý |
| RISK-maintenance-04 | Dữ liệu giả lập không tái hiện ca sự cố thật | Thấp | Demo lạc quan so với thực tế | Kịch bản giả lập có nhiều phòng hỏng đồng thời; ghi rõ giới hạn xác thực | Trưởng nhóm |

## 11. Open Questions

- [ ] OQ-1: Ngưỡng "quá hạn" cho việc bảo trì (bao nhiêu phút/giờ)? Cảnh báo phát 1 lần hay lặp lại?
