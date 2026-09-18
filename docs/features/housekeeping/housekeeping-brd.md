---
type: brd
feature: housekeeping
status: draft
updated: 2026-09-15
links:
  - "[[docs/features/housekeeping/housekeeping-urd.md|Housekeeping URD]]"
  - "[[docs/features/housekeeping/brainstorms/chu-trinh-don-phong.md|Brainstorm: Chu trình dọn phòng]]"
  - "[[Ton_Chi_Du_An_WPCTeam.txt|Tôn chỉ dự án]]"
---

# housekeeping — Business Requirements Document

## 1. Executive Summary

Chu trình dọn phòng hiện vận hành rời rạc (điện thoại, giấy, bộ đàm): phòng trả xong không có ai chịu trách nhiệm rõ ràng, phòng sạch không được mở bán lại kịp, và không có bằng chứng truy vết khi khách khiếu nại chất lượng. Feature housekeeping số hóa toàn bộ chu trình — tự tạo việc khi trả phòng, tự phân công chia đều cho nhân viên đang trực, xác nhận chất lượng bởi quản lý, và cảnh báo quá hạn 60 phút bằng quy tắc — để phòng sạch quay lại trạng thái bán được nhanh nhất và mọi thay đổi đều truy vết được.

## 2. Business Problem & Context

### 2.1 Problem Statement

| ID | Business Condition | Baseline | Business Impact | Evidence |
|----|--------------------|----------|-----------------|----------|
| BP-housekeeping-01 | Phòng trả xong nhưng việc dọn không có người phụ trách rõ ràng, phân công thủ công qua điện thoại | Chưa có — xác lập qua log demo | Phòng sạch "bị kẹt" không bán lại kịp trong giờ cao điểm; mất cơ hội doanh thu phòng | Confirmed (tôn chỉ: "giảm việc cập nhật rời rạc") |
| BP-housekeeping-02 | Trạng thái vệ sinh không nhất quán giữa lễ tân, buồng phòng, quản lý | Chưa có | Khách nhận phòng chưa dọn → khiếu nại, giảm uy tín | Confirmed (tôn chỉ: trục vệ sinh theo dõi riêng để tránh nhầm lẫn) |
| BP-housekeeping-03 | Không có bằng chứng ai làm gì khi nào | Chưa có | Không đối soát được khi có khiếu nại chất lượng hoặc tranh chấp trách nhiệm | Confirmed (tôn chỉ: ghi nhật ký ở máy chủ) |

### 2.2 Opportunity & Why Now

Đây là luồng vận hành lõi trong luồng nghiệm thu của MVP (Sprint 2, 22/09–05/10): "Nhận/trả phòng, công việc buồng phòng/báo hỏng; nhật ký, đồng bộ". Không có feature này, dashboard realtime (Sprint 3) không có dữ liệu vệ sinh để hiển thị và tiêu chí "0 phòng bán nhầm khi chưa sạch" không kiểm chứng được.

### 2.3 Strategic Alignment

Trực tiếp phục vụ mục tiêu tôn chỉ: "công việc dọn phòng, báo hỏng và lịch sử thay đổi" + "dashboard thể hiện phòng cần dọn, công việc quá hạn" + "giảm việc cập nhật rời rạc và hỗ trợ điều phối vận hành bằng dữ liệu".

## 3. Current State, Future State & Gap

### 3.1 Current State (AS-IS)

Lễ tân trả phòng xong gọi điện/nhắn cho buồng phòng; tổ trưởng chia việc thủ công; nhân viên dọn xong báo miệng; quản lý muốn biết phòng nào sạch phải hỏi từng người; không có nhật ký thống nhất.

### 3.2 Future State (TO-BE)

Trả phòng tự sinh công việc và hệ thống tự giao đều cho nhân viên đang trực; nhân viên thao tác nhận/hoàn tất trên mobile; quản lý xác nhận chất lượng một chạm; mọi trạng thái realtime trên dashboard; việc quá 60 phút tự cảnh báo; mọi thay đổi có nhật ký máy chủ.

### 3.3 Gap

| Gap | Mô tả | Ưu tiên |
|-----|-------|---------|
| G1 | Chưa có cơ chế tự tạo + tự phân công việc dọn | Cao |
| G2 | Chưa có trạng thái vệ sinh thống nhất realtime giữa các vai trò | Cao |
| G3 | Chưa có điểm kiểm soát chất lượng (xác nhận sẵn sàng) trước khi bán lại | Cao |
| G4 | Chưa có cảnh báo quá hạn và nhật ký truy vết | Trung bình |

## 4. Stakeholders

| Stakeholder Role | Interest | Influence | Stakeholder Requirement / Expectation |
|------------------|----------|-----------|----------------------------------------|
| Quản lý khách sạn | Kiểm soát chất lượng + tốc độ quay vòng phòng | Cao (quyết định nghiệp vụ) | Chỉ quản lý được xác nhận "sẵn sàng"; thấy việc quá hạn; đối soát được ai làm gì |
| Lễ tân | Nhận khách nhanh, đúng phòng sạch | Trung bình | Trạng thái phòng luôn mới nhất; không nhận khách vào phòng chưa đạt |
| Nhân viên buồng phòng | Việc rõ ràng, thao tác nhanh | Trung bình | Được giao việc tự động; không bị giao dồn; thao tác ít chạm trên mobile |
| WPCTeam (dev) | Hoàn thành MVP đúng phạm vi 8 tuần | Cao | Scope khả thi trong sprint 2; không phình tính năng |
| Giảng viên hướng dẫn | Đánh giá theo tiêu chí môn học | Cao | Luồng bắt buộc thông qua trên Flutter Web + Android |

## 5. Business Objectives & Success Measures

| ID | Objective | Baseline | Target | Timeframe | Success Measure |
|----|-----------|----------|--------|-----------|-----------------|
| BO-housekeeping-01 | Rút ngắn thời gian từ trả phòng đến "sẵn sàng" | Chưa có — xác lập qua log demo sprint 2 | Đo được thời gian trung bình trên dashboard; 100% việc được giao ≤1 phút sau trả phòng | Sprint 2 | Đối soát nhật ký: mốc tạo việc, mốc hoàn tất, mốc xác nhận |
| BO-housekeeping-02 | Loại bỏ sự cố phòng bán nhầm khi chưa sạch | Chưa có | 0 lượt nhận khách vào phòng chưa đạt điều kiện "sẵn sàng" trong nghiệm thu | Nghiệm thu | Kịch bản nghiệm thu bắt buộc thông qua |
| BO-housekeeping-03 | 100% việc dọn truy vết được người phụ trách và mốc thời gian | Chưa có | Mọi thay đổi trạng thái có bản ghi ai/khi nào/từ trạng thái nào | Nghiệm thu | Đối soát audit-log khớp dashboard |

## 6. Business Scope

### 6.1 In Scope

- Toàn bộ chu trình công việc dọn phòng tại 1 khách sạn 50 phòng: tạo việc tự động, phân công tự động, nhận/từ chối/hoàn tất, xác nhận chất lượng, cảnh báo quá hạn, đồng bộ realtime.

### 6.2 Out of Scope

- Nhiều khách sạn/chuỗi; thanh toán, kế toán, OTA/PMS, IoT; chấm công và phân ca nhân viên; tính lương/KPI; tối ưu tuyến đi theo vị trí tầng.
- Phát hành lên kho ứng dụng (bàn giao web trên VPS + APK Android).

### 6.3 Assumptions

- Danh sách nhân viên buồng phòng đang trực có sẵn trong hệ thống (dữ liệu giả lập) — xem OQ-1.
- Khách sạn demo chấp nhận quy trình "quản lý xác nhận mới sẵn sàng".
- Nhân viên có thiết bị Android hoặc truy cập web trên điện thoại.

### 6.4 Constraints

- MVP 8 tuần, nhóm 3 người ~20 giờ/người/tuần (tôn chỉ).
- Tiếng Việt, dữ liệu giả lập, 1 khách sạn 50 phòng.
- Cảnh báo quá hạn bằng quy tắc, không phụ thuộc AI (tôn chỉ).

### 6.5 Dependencies

- Feature nhận/trả phòng cung cấp sự kiện "trả phòng" (cùng sprint 2, phát triển song song).
- Feature quản lý tài khoản cung cấp vai trò và danh sách nhân viên (sprint 1).
- Feature audit-log nhận ghi nhật ký mọi thay đổi (cùng nhóm vận hành).
- Feature dashboard hiển thị trạng thái + cảnh báo quá hạn (sprint 3).

## 7. High-level Business Requirements

| ID | Business Requirement | Business Objective | Priority |
|----|----------------------|--------------------|----------|
| BREQ-housekeeping-01 | Hệ thống phải tự tạo và tự giao công việc dọn khi phòng được trả, không cần thao tác phân công thủ công | BO-housekeeping-01 | Must |
| BREQ-housekeeping-02 | Nhân viên phải nhận và báo hoàn tất việc trên thiết bị di động với thao tác tối thiểu | BO-housekeeping-01 | Must |
| BREQ-housekeeping-03 | Phòng chỉ được đánh dấu "sẵn sàng" sau khi quản lý xác nhận chất lượng | BO-housekeeping-02 | Must |
| BREQ-housekeeping-04 | Việc quá 60 phút chưa hoàn tất phải được cảnh báo cho quản lý và nhân viên phụ trách | BO-housekeeping-01 | Must |
| BREQ-housekeeping-05 | Mọi thay đổi trạng thái phải được ghi nhật ký ở máy chủ phục vụ đối soát | BO-housekeeping-03 | Must |

## 8. Business Rules

| ID | Business Rule | Rationale |
|----|---------------|-----------|
| BR-housekeeping-01 | Chỉ vai trò quản lý được xác nhận phòng "sẵn sàng" | Kiểm soát chất lượng là trách nhiệm quản lý; user đã chốt |
| BR-housekeeping-02 | Công việc dọn quá 60 phút kể từ lúc tạo mà chưa hoàn tất thì bị đánh dấu "quá hạn" và cảnh báo | Ngưỡng vận hành đã chốt; bằng quy tắc không qua AI |
| BR-housekeeping-03 | Chỉ được nhận khách khi phòng trống + đã sạch + không ngừng phục vụ | Tôn chỉ; chống bán nhầm phòng chưa đạt |
| BR-housekeeping-04 | Việc dọn được giao tự động theo thứ tự giờ trả phòng, chia đều cho nhân viên buồng phòng đang trực | User đã chốt cơ chế phân công |
| BR-housekeeping-05 | Quản lý trả lại việc bắt buộc kèm ghi chú lý do | Nhân viên cần biết sửa gì; truy vết chất lượng |

## 9. Cost-Benefit (định tính)

### 9.1 Cost Drivers

- Effort phát triển trong sprint 2 (đã nằm trong kế hoạch 480 giờ của tôn chỉ): màn hình việc cho nhân viên mobile, màn xác nhận cho quản lý, luồng realtime, quy tắc quá hạn.
- Chi phí vận hành nền tảng: đã nằm trong hạng mục VPS + CSDL của ngân sách chung.

### 9.2 Expected Benefits

- Phòng sạch quay vòng nhanh hơn trong giờ cao điểm → giảm mất cơ hội doanh thu.
- Giảm khiếu nại khách do phòng chưa dọn; giảm thời gian quản lý đi kiểm tra thủ công.
- Có bằng chứng truy vết phục vụ đối soát và đánh giá nhân viên.

### 9.3 Priority / Rough ROI

Ưu tiên cao — đây là luồng lõi của sản phẩm (không có nó thì dashboard và nghiệm thu không đạt). Chi phí đã nằm trong kế hoạch; lợi ích nghiệp vụ trực tiếp và đo được qua log.

## 10. Risks

| ID | Risk | Likelihood | Impact | Mitigation | Owner Role |
|----|------|------------|--------|------------|------------|
| RISK-housekeeping-01 | Nhân viên không dùng app / bỏ qua thông báo | Trung bình | Việc treo, phòng kẹt | Cảnh báo quá hạn lên dashboard quản lý; quy trình demo có hướng dẫn | Quản lý |
| RISK-housekeeping-02 | Quản lý trở thành nút thắt xác nhận giờ cao điểm | Trung bình | Phòng sạch chờ mở bán | Danh sách "chờ kiểm tra" nổi bật; OQ-3 cân nhắc ngưỡng nhắc | Quản lý |
| RISK-housekeeping-03 | Phân công tự động không hợp thực tế (tầng xa, phòng lớn) | Trung bình | Thời gian dọn thực tế dài, cảnh báo nhiễu | MVP chấp nhận chia đều đơn giản; đo và điều chỉnh sau demo | Trưởng nhóm |
| RISK-housekeeping-04 | Dữ liệu giả lập không tái hiện ca đỉnh thật | Thấp | Kết quả demo lạc quan | Kịch bản giả lập có ca đỉnh; ghi rõ giới hạn xác thực | Trưởng nhóm |

## 11. Open Questions

- [ ] OQ-1: Danh sách "nhân viên buồng phòng đang trực" lấy từ đâu trong MVP — giả lập cố định, hay quản lý đánh dấu theo ca?
- [ ] OQ-2: Cảnh báo quá hạn phát 1 lần khi vượt ngưỡng, hay lặp lại định kỳ (vd mỗi 15 phút) tới khi hoàn tất?
- [ ] OQ-3: Việc "chờ xác nhận" quá lâu (quản lý không phản hồi) có cần ngưỡng nhắc riêng không? Bao nhiêu phút?
