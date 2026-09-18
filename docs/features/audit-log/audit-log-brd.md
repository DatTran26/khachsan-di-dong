---
type: brd
feature: audit-log
status: draft
updated: 2026-09-17
links:
  - "[[docs/features/audit-log/audit-log-urd.md|Audit-log URD]]"
  - "[[docs/features/audit-log/brainstorms/nhat-ky-truy-vet.md|Brainstorm: Nhật ký truy vết]]"
  - "[[Ton_Chi_Du_An_WPCTeam.txt|Tôn chỉ dự án]]"
---

# audit-log — Business Requirements Document

## 1. Executive Summary

Hệ thống vận hành phòng thay đổi liên tục bởi nhiều vai trò (lễ tân nhận/trả, nhân viên dọn/sửa, quản lý xác nhận) và cả hành động tự động (tự tạo việc, cờ quá hạn, khóa tài khoản). Nếu không có vết ghi thống nhất, mọi sai lệch hay tranh chấp "ai đã đổi gì" đều bế tắc — và `ai-ops-summary` thiếu nguồn sự kiện đáng tin để tổng hợp. Feature audit-log ghi tự động ở máy chủ mọi thay đổi trạng thái và thao tác ghi, cho quản lý xem lại theo phòng và theo khoảng thời gian/vai trò/người thao tác, với bản ghi bất biến giữ suốt MVP.

## 2. Business Problem & Context

### 2.1 Problem Statement

| ID | Business Condition | Baseline | Business Impact | Evidence |
|----|--------------------|----------|-----------------|----------|
| BP-audit-log-01 | Thay đổi dữ liệu không có bằng chứng ai làm gì khi nào | Chưa có nhật ký thống nhất | Tranh chấp giữa các ca/vai trò không giải quyết được; sai lệch không truy trách nhiệm | Confirmed (PRD 7.8: rủi ro "mất vết khi tranh chấp") |
| BP-audit-log-02 | Trạng thái phòng 3 trục bị đổi qua nhiều tay, không ai nắm chuỗi thay đổi | Chưa có | Không tái dựng được "phòng này đã qua trạng thái gì" → nghi ngờ dữ liệu dashboard | Confirmed (tôn chỉ: 3 trục theo dõi riêng; PRD: truy vết theo phòng) |
| BP-audit-log-03 | Không có nguồn sự kiện thống nhất để tổng hợp vận hành | Chưa có | `ai-ops-summary` và đối soát nghiệm thu thiếu đầu vào tin cậy | Confirmed (PRD: audit-log là nguồn dữ liệu sự kiện cho ai-ops-summary) |

### 2.2 Opportunity & Why Now

Nhật ký nằm trong kết quả cam kết của Sprint 2 (22/09–05/10): "Nhận/trả phòng, công việc buồng phòng/báo hỏng; nhật ký, đồng bộ". Cơ chế kiểm quyền và ghi nhật ký phía máy chủ đã được `auth-roles` định nghĩa trong Sprint 1 — audit-log mở rộng sang toàn bộ sự kiện nghiệp vụ và thêm góc nhìn truy vết theo phòng, kịp trước khi `room-dashboard` và `ai-ops-summary` (Sprint 3) cần dữ liệu đối soát.

### 2.3 Strategic Alignment

Trực tiếp phục vụ mục tiêu tôn chỉ: "Mọi thay đổi được kiểm tra quyền và ghi nhật ký ở máy chủ" + "lịch sử thay đổi" trong phạm vi MVP + hỗ trợ điều phối vận hành bằng dữ liệu (nhật ký là nguồn sự kiện cho dashboard đối soát và tóm tắt AI).

## 3. Current State, Future State & Gap

### 3.1 Current State (AS-IS)

Mọi cập nhật trạng thái truyền miệng/điện thoại rồi lễ tân nhập hộ sau; không có vết ghi tập trung; khi sai lệch chỉ còn cách hỏi từng người theo trí nhớ.

### 3.2 Future State (TO-BE)

Mọi thay đổi trạng thái và thao tác ghi tự động để lại bản ghi máy chủ đủ ai/khi/hành động/đối tượng/trước→sau; quản lý mở nhật ký theo phòng hoặc lọc theo thời gian/vai trò/người để truy vết; nhật ký làm nguồn sự kiện cho `ai-ops-summary`.

### 3.3 Gap

| Gap | Mô tả | Ưu tiên |
|-----|-------|---------|
| G1 | Chưa có cơ chế ghi vết tự động cho toàn bộ thay đổi nghiệp vụ (auth-roles mới phủ sự kiện auth) | Cao |
| G2 | Chưa có góc nhìn truy vết theo phòng cho quản lý | Cao |
| G3 | Chưa có nguồn sự kiện có cấu trúc để tổng hợp vận hành/đối soát | Trung bình |

## 4. Stakeholders

| Stakeholder Role | Interest | Influence | Stakeholder Requirement / Expectation |
|------------------|----------|-----------|----------------------------------------|
| Quản lý khách sạn | Truy vết trách nhiệm, rà soát vận hành | Cao (người dùng chính) | Xem nhật ký theo phòng/thời gian/người; đọc hiểu ngay; tin nhật ký không bị sửa |
| WPCTeam (dev/vận hành) | Đối soát nghiệm thu, phục hồi sự cố | Cao | Nhật ký đủ trường để chứng minh "100% thay đổi có bản ghi" |
| Giảng viên hướng dẫn | Đánh giá theo tiêu chí môn học | Cao | Chức năng "lịch sử thay đổi" trong phạm vi tôn chỉ được chứng minh |
| Lễ tân, nv buồng phòng–bảo trì | Là chủ thể bị ghi | Thấp | Thao tác của mình được ghi đúng, không bị ghi sai/ngược |
| Người vận hành (WPCTeam) | Phục hồi quản trị ngoài app | Trung bình | Biết giới hạn: can thiệp ngoài app không nằm trong nhật ký |

## 5. Business Objectives & Success Measures

| ID | Objective | Baseline | Target | Timeframe | Success Measure |
|----|-----------|----------|--------|-----------|-----------------|
| BO-audit-log-01 | Mọi thay đổi trạng thái và thao tác ghi đều truy vết được | Chưa có | 100% thay đổi trạng thái có bản ghi đủ ai/khi/trục/từ→sang; 0 thay đổi thiếu vết | Nghiệm thu | Đối soát nhật ký vs thao tác mẫu trong kịch bản nghiệm thu |
| BO-audit-log-02 | Quản lý tự truy vết được khi tranh chấp | Chưa có | Trả lời được "ai đổi gì trên phòng X, lúc nào" từ màn nhật ký, không cần hỗ trợ kỹ thuật | Sprint 2–3 | Demo kịch bản tranh chấp mẫu |
| BO-audit-log-03 | Nhật ký đủ tin cậy làm nguồn sự kiện và đối soát | Chưa có | Mọi loại sự kiện MVP đếm/nhóm được theo phòng và khoảng thời gian; đối soát khớp dashboard | Sprint 3 | Đối chiếu nhu cầu `ai-ops-summary` + dashboard |

## 6. Business Scope

### 6.1 In Scope

- Ghi tự động phía máy chủ mọi thay đổi trạng thái phòng (rõ trục lưu trú/vệ sinh/bảo trì), mọi thao tác ghi nghiệp vụ, sự kiện auth và hành động tự động của hệ thống.
- Màn nhật ký cho quản lý trên web: xem theo phòng; lọc theo khoảng thời gian, vai trò/người thao tác.
- Bản ghi bất biến (không sửa/xóa trong app), giữ toàn bộ thời gian MVP.

### 6.2 Out of Scope

- Export nhật ký, chính sách lưu trữ dài hạn, cảnh báo từ nhật ký (PRD chưa làm).
- Nội dung/cách tính của tóm tắt AI (thuộc `ai-ops-summary`); quyền hạn từng hành động (thuộc `auth-roles`); nghiệp vụ sinh sự kiện (thuộc từng feature vận hành).
- Ghi nhật ký cho thao tác bị từ chối và cho can thiệp ngoài app của người vận hành.
- Xem lịch sử trên dashboard (`room-dashboard` đã xếp ngoài phạm vi).

### 6.3 Assumptions

- Chỉ thao tác ghi đã lưu thành công mới sinh bản ghi (luồng tôn chỉ: kiểm quyền → lưu → ghi).
- Xem nhật ký là đọc theo yêu cầu, không realtime.
- Khung thời gian mặc định + giới hạn dòng tải chưa chốt — OQ-1.
- v1 chỉ ghi thao tác ghi, chưa ghi lượt xem nhật ký — OQ-2 (tạm chốt).

### 6.4 Constraints

- MVP 8 tuần, nhóm 3 người ~20 giờ/người/tuần; "nhật ký" thuộc kết quả Sprint 2 (tôn chỉ).
- Tiếng Việt, dữ liệu giả lập, 1 khách sạn 50 phòng.
- Kiểm tra quyền và ghi nhật ký ở máy chủ; lưu dữ liệu trước khi phát sự kiện (tôn chỉ).
- Ba trục trạng thái phòng theo dõi riêng — bản ghi phải chỉ rõ trục, không gộp.

### 6.5 Dependencies

- `auth-roles` cung cấp định danh/vai trò người thực hiện, cơ chế kiểm quyền và định nghĩa sự kiện auth (Sprint 1 — đã có).
- Các feature vận hành (`room-catalog`, `check-in-out`, `housekeeping`, `maintenance`) là nguồn sinh sự kiện (Sprint 2, song song).
- `realtime-sync` phát thay đổi sau khi lưu (Sprint 2).
- `ai-ops-summary` là bên tiêu thụ bản ghi để tổng hợp (Sprint 3).

## 7. High-level Business Requirements

| ID | Business Requirement | Business Objective | Priority |
|----|----------------------|--------------------|----------|
| BREQ-audit-log-01 | Hệ thống phải tự ghi mọi thay đổi trạng thái (rõ trục) và thao tác ghi, kèm người/vai trò/thời điểm máy chủ/giá trị trước→sau | BO-audit-log-01 | Must |
| BREQ-audit-log-02 | Quản lý phải xem được nhật ký theo phòng và lọc theo khoảng thời gian, vai trò/người thao tác | BO-audit-log-02 | Must |
| BREQ-audit-log-03 | Bản ghi phải bất biến, append-only, giữ toàn bộ MVP, không có thao tác sửa/xóa trong app | BO-audit-log-01 | Must |
| BREQ-audit-log-04 | Chỉ vai trò quản lý được xem nhật ký; vai trò khác bị từ chối ở máy chủ | BO-audit-log-02 | Must |
| BREQ-audit-log-05 | Bản ghi phải đủ cấu trúc để `ai-ops-summary` tổng hợp theo kỳ (loại sự kiện/phòng/thời điểm) | BO-audit-log-03 | Must |

## 8. Business Rules

| ID | Business Rule | Rationale |
|----|---------------|-----------|
| BR-audit-log-01 | Chỉ thao tác ghi đã kiểm quyền và lưu thành công mới sinh bản ghi | Theo luồng tôn chỉ; thao tác bị từ chối không đổi dữ liệu nên không có gì để vết |
| BR-audit-log-02 | Bản ghi nhật ký lưu cùng thay đổi dữ liệu như một kết quả duy nhất; không ghi được thì thao tác không được coi là hoàn tất | Bảo đảm "100% thay đổi có bản ghi" — không để thay đổi mồ côi thiếu vết |
| BR-audit-log-03 | Chỉ quản lý xem nhật ký; kiểm tra ở máy chủ, không chỉ ẩn giao diện | Ma trận quyền `auth-roles` đã chốt |
| BR-audit-log-04 | Nhật ký bất biến — không sửa/xóa qua app; giữ toàn bộ MVP, không tự xóa | Truy vết tranh chấp chỉ có nghĩa khi vết không thể bị thay đổi |
| BR-audit-log-05 | Bản ghi thay đổi trạng thái phòng phải ghi rõ trục bị đổi (lưu trú/vệ sinh/bảo trì), không gộp thành "trạng thái chung" | Tôn chỉ: ba trục theo dõi riêng để tránh nhầm lẫn |
| BR-audit-log-06 | Thời điểm bản ghi = mốc máy chủ lưu thành công, không lấy giờ thiết bị | Đồng nhất mốc giờ để tránh tranh chấp về "khi nào" |

## 9. Cost-Benefit (định tính)

### 9.1 Cost Drivers

- Effort phát triển trong Sprint 2 (đã nằm trong kế hoạch 480 giờ): cơ chế ghi nhật ký chung cho mọi thao tác ghi + màn xem/lọc cho quản lý.
- Chi phí lưu trữ nhật ký: nằm trong hạng mục VPS + CSDL của ngân sách chung; quy mô 50 phòng giả lập nên khối lượng nhỏ.

### 9.2 Expected Benefits

- Giải quyết được tranh chấp "ai đã đổi gì" bằng bằng chứng, thay vì hỏi miệng.
- Làm nền cho đối soát dashboard và nguồn sự kiện cho `ai-ops-summary` — một lần ghi, nhiều nơi dùng.
- Chứng minh tiêu chí nghiệm thu "100% thay đổi có bản ghi" và "phân quyền đúng" (mọi thao tác kiểm quyền + ghi vết).

### 9.3 Priority / Rough ROI

Ưu tiên cao — là điều kiện tin cậy của toàn hệ thống (không có vết thì dashboard và AI đều thiếu căn cứ). Chi phí đã nằm trong kế hoạch Sprint 2; lợi ích đo được qua đối soát.

## 10. Risks

| ID | Risk | Likelihood | Impact | Mitigation | Owner Role |
|----|------|------------|--------|------------|------------|
| RISK-audit-log-01 | Lỗi khi ghi nhật ký → thay đổi tồn tại mà thiếu vết | Thấp | Mất giá trị cốt lõi đúng lúc tranh chấp | BR-audit-log-02: không ghi được thì thao tác chưa hoàn tất; đối soát nghiệm thu | Trưởng nhóm |
| RISK-audit-log-02 | Nhật ký tích lũy lớn → màn tải chậm | Trung bình | Quản lý khó tra cứu | Tải theo phần + khung mặc định (OQ-1); lọc theo phòng/thời gian | Trưởng nhóm |
| RISK-audit-log-03 | Quản lý là người xem duy nhất — nếu quản lý gây sai lệch, không ai đối chứng trong app | Thấp | Truy vết một chiều | Giới hạn MVP; người vận hành giữ sao lưu CSDL theo tôn chỉ; OQ-2 cân nhắc read-audit | Quản lý |
| RISK-audit-log-04 | Wording bản ghi quá kỹ thuật → quản lý đọc không hiểu | Trung bình | Nhật ký bị bỏ không dùng | Format hiển thị nghiệp vụ đã chốt ở brainstorm mục 7.3; kiểm chứng demo | Trưởng nhóm |

## 11. Open Questions

- [ ] OQ-1: Khung thời gian mặc định khi mở màn nhật ký và số dòng tối đa mỗi lần tải là bao nhiêu?
- [ ] OQ-2: Có cần ghi cả lượt xem nhật ký của quản lý (read-audit) không? Tạm chốt: v1 chỉ ghi thao tác ghi theo PRD.
