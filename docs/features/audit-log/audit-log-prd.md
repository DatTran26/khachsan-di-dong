---
type: prd
feature: audit-log
status: draft
updated: 2026-09-17
links:
  - "[[docs/features/audit-log/audit-log-brd.md|Audit-log BRD]]"
  - "[[docs/features/audit-log/audit-log-urd.md|Audit-log URD]]"
---

# audit-log — Product Requirements Document (Feature)

## 1. Overview

Nhật ký thay đổi là lớp truy vết của hệ thống: mọi thay đổi trạng thái phòng (theo từng trục lưu trú/vệ sinh/bảo trì), mọi thao tác ghi nghiệp vụ, sự kiện auth và hành động tự động của hệ thống đều tự động thành bản ghi máy chủ bất biến. Quản lý xem lại theo phòng hoặc lọc theo thời gian/vai trò/người thao tác để truy vết; `ai-ops-summary` đọc bản ghi làm nguồn sự kiện tổng hợp.

### Product Gap

- AS-IS: không có vết ghi tập trung; sai lệch/tranh chấp không giải quyết được; không nguồn sự kiện cho tổng hợp.
- TO-BE: mọi thay đổi có bản ghi đủ ai/khi/hành động/đối tượng/trước→sau, truy vết được theo phòng và theo lọc.

## 2. Goals & Non-Goals

### Goals

- G1: 100% thay đổi trạng thái và thao tác ghi có bản ghi đủ ai/khi/trục/từ→sang — không còn "mất vết".
- G2: Quản lý tự truy vết theo phòng và theo lọc thời gian/vai trò/người, không cần hỗ trợ kỹ thuật.
- G3: Bản ghi bất biến, giữ toàn bộ MVP — đủ tin cậy để kết luận trách nhiệm.
- G4: Nhật ký đủ cấu trúc làm nguồn sự kiện cho `ai-ops-summary` và đối soát dashboard.

### Non-Goals

- Không viết nội dung hay cách tính của tóm tắt AI (thuộc `ai-ops-summary`); audit-log chỉ cung cấp bản ghi sự kiện.
- Không quyết định quyền hạn từng hành động (thuộc `auth-roles`); audit-log chỉ ghi lại.
- Không export nhật ký, không chính sách lưu trữ dài hạn, không cảnh báo từ nhật ký (PRD "chưa làm").
- Không ghi thao tác bị từ chối, không ghi lượt đọc (OQ-2), không ghi can thiệp ngoài app của người vận hành.
- Không xem lịch sử từ dashboard (`room-dashboard` ngoài phạm vi đó).

## 3. Personas & Use Cases

| Persona | Bối cảnh | Use cases trong feature |
|---------|----------|--------------------------|
| Quản lý | Web dashboard | Xem nhật ký theo phòng; lọc theo khoảng thời gian; lọc theo vai trò/người thao tác (gồm "hệ thống"); đọc chuỗi trước→sau để kết luận trách nhiệm |
| Hệ thống | Máy chủ | Tự sinh bản ghi khi thao tác ghi hoàn tất; ghi hành động tự động với actor "hệ thống" |
| Người vận hành (WPCTeam) | Ngoài app | Đối soát nhật ký với dashboard/kịch bản nghiệm thu; phục hồi sự cố |

Ref: `[[docs/features/audit-log/audit-log-urd.md]]` mục User Types + Journeys.

## 4. Capabilities (Epics)

| ID | Epic | P | Rationale | Sizing | Trace |
|----|------|---|-----------|--------|-------|
| CAP-audit-log-01 | Tự ghi bản ghi cho mọi thay đổi trạng thái (rõ trục) và thao tác ghi — ai/khi/hành động/đối tượng/trước→sau | P0 | Nền của mọi truy vết; đo thành công PRD | ~5 story | UN-001, UN-005 → BO-01 |
| CAP-audit-log-02 | Ghi hành động tự động của hệ thống (actor "hệ thống") và sự kiện auth theo `auth-roles` | P0 | Tranh chấp thường gặp đúng các thay đổi không do ai trực tiếp bấm | ~3 | UN-001 → BO-01 |
| CAP-audit-log-03 | Nhật ký bất biến, append-only, giữ toàn bộ MVP | P0 | Điều kiện để nhật ký đáng tin khi tranh chấp | ~2 | UN-005 → BO-01 |
| CAP-audit-log-04 | Xem nhật ký theo phòng (dòng thời gian trước→sau) | P0 | Điểm chạm chính của job "truy vết" | ~4 | UN-001 → BO-02 |
| CAP-audit-log-05 | Lọc nhật ký theo khoảng thời gian và vai trò/người thao tác | P0 | Thu hẹp vết khi rà soát | ~3 | UN-002, UN-003 → BO-02 |
| CAP-audit-log-06 | Màn nhật ký chung toàn hệ thống + lọc theo loại hành động/trục/loại đối tượng | P1 | Sự kiện auth không gắn phòng cần nơi xem; mở rộng màn nhật ký của `auth-roles` | ~4 | UN-002, UN-003 → BO-02 |
| CAP-audit-log-07 | Liên kết dòng nhật ký tới đối tượng; export/lưu trữ dài hạn/cảnh báo từ nhật ký | P2 | Tiện ích sau MVP; PRD đã xếp "chưa làm" | ~5 | UN-002 → BO-02 |

### Done when (product level)

- CAP-01: Mọi thay đổi trạng thái phòng sinh bản ghi ghi rõ trục (lưu trú/vệ sinh/bảo trì) + trước→sau; mọi thao tác ghi nghiệp vụ (tạo/sửa phòng, giao/nhận/hoàn tất việc, báo hỏng, quản lý tài khoản, tạo tóm tắt AI...) có bản ghi đủ trường; một thao tác đổi nhiều trục liệt kê đủ từng thay đổi trong cùng bản ghi.
- CAP-02: Hành động tự động (tự tạo việc, cờ quá hạn, khóa TK, hết phiên) có bản ghi actor "hệ thống"; sự kiện auth ghi theo `auth-roles`, không ghi giá trị mật khẩu.
- CAP-03: Không tồn tại thao tác sửa/xóa bản ghi trong app; bản ghi cũ vẫn đọc được đến cuối MVP.
- CAP-04: Chọn một phòng → thấy đủ chuỗi bản ghi của phòng đó theo thời gian (mới nhất trước), mỗi dòng đủ ai/khi/hành động/trục/trước→sau.
- CAP-05: Lọc từ–đến và/hoặc vai trò/người (gồm "hệ thống") trả đúng phạm vi; không khớp → trạng thái rỗng rõ ràng.
- CAP-06: Màn nhật ký chung hiển thị được sự kiện không gắn phòng (auth) và lọc theo loại hành động/trục/loại đối tượng.
- CAP-07: (Later) Bấm dòng nhật ký mở được đối tượng liên quan; có export khi cần.

## 5. Success Metrics

| Metric | Baseline | Target | Measurement | Timeframe |
|--------|----------|--------|-------------|-----------|
| Tỷ lệ thay đổi trạng thái có bản ghi đủ ai/khi/trục/từ→sang | 0% — chưa có nhật ký | 100% | Đối soát nhật ký vs thao tác mẫu trong kịch bản nghiệm thu | Nghiệm thu |
| Thay đổi dữ liệu thiếu vết | Chưa có | 0 | Đối soát trạng thái hiện tại vs chuỗi bản ghi | Nghiệm thu |
| Quản lý tự truy vết được khi tranh chấp | Chưa có | Xác định được ai/khi/thay đổi gì trên phòng X không cần hỗ trợ kỹ thuật | Demo kịch bản tranh chấp | Sprint 2–3 |
| Vai trò ngoài quản lý đọc được nhật ký | Chưa có | 0 | Bộ kịch bản phân quyền | Nghiệm thu |
| Nhật ký đủ làm nguồn sự kiện cho `ai-ops-summary` | Chưa có | Mọi loại sự kiện MVP đếm/nhóm được theo phòng + khoảng thời gian | Đối chiếu nhu cầu tổng hợp | Sprint 3 |

## 6. Feature interactions

- **Auth-roles (overlap UI xem nhật ký):** `auth-roles` CAP-auth-roles-08 / FR-auth-roles-014 là placeholder P1. **UI xem/lọc nhật ký** (theo phòng, chung, auth) **thực thi tại feature này** (CAP-audit-log-04..06). `auth-roles` vẫn sở hữu ghi sự kiện auth (CAP-auth-roles-07) và định nghĩa sự kiện; không xóa CAP phía auth — chỉ gom màn hình xem về `audit-log`.

## 7. Dependencies

| Dependency | Owner | Status | Needed By |
|------------|-------|--------|-----------|
| Định danh/vai trò người thực hiện, kiểm quyền server, định nghĩa sự kiện auth | `auth-roles` | Sprint 1 (đã có spec) | CAP-audit-log-01, 02, 05, 06 |
| Sự kiện nghiệp vụ (trạng thái phòng, công việc, danh mục) | `room-catalog`, `check-in-out`, `housekeeping`, `maintenance` | Song song Sprint 2 | CAP-audit-log-01 |
| Kênh phát realtime sau khi lưu | `realtime-sync` | Song song Sprint 2 | CAP-audit-log-01 (thứ tự lưu→ghi→phát) |
| Bên tiêu thụ bản ghi để tổng hợp | `ai-ops-summary` | Sprint 3 | CAP-audit-log-01, 05 (đủ cấu trúc sự kiện) |

## 8. Assumptions

- Chỉ thao tác ghi đã lưu thành công mới sinh bản ghi (luồng tôn chỉ); thao tác bị từ chối không vào nhật ký.
- Xem nhật ký là đọc theo yêu cầu, không realtime; màn nhật ký trên web cho quản lý.
- Khung thời gian mặc định + giới hạn dòng mỗi lần tải chưa chốt — OQ-1.
- v1 chỉ ghi thao tác ghi, chưa ghi lượt xem nhật ký — OQ-2 (tạm chốt).
- Bản ghi giữ nhãn đối tượng tại thời điểm ghi — đổi tên/xóa đối tượng không làm mất vết.

## 9. Risks (product)

| Risk | P | Impact | Mitigation | Owner |
|------|---|--------|------------|-------|
| Thay đổi tồn tại mà thiếu bản ghi (lỗi ghi) | Low | Mất vết đúng lúc tranh chấp | Nhật ký lưu cùng thay đổi; lỗi ghi = thao tác chưa hoàn tất; đối soát nghiệm thu | PM |
| Nhật ký phình → màn tải chậm | Medium | Khó tra cứu | Tải theo phần + khung mặc định (OQ-1); lọc | PM |
| Quản lý là người xem duy nhất (một chiều) | Low | Không đối chứng được chính quản lý | Giới hạn MVP; sao lưu CSDL của người vận hành; OQ-2 cân nhắc read-audit | PM |
| Wording bản ghi quá kỹ thuật | Medium | Nhật ký bị bỏ không dùng | Format nghiệp vụ đã chốt ở brainstorm; kiểm chứng demo | PM |

## 10. Release Plan

### Now (Sprint 2 — khung 22/09–05/10)

- CAP-audit-log-01, 02, 03, 04, 05 — ghi tự động đủ trường + xem theo phòng + lọc cơ bản.

### Next (Sprint 3)

- CAP-audit-log-06 — màn nhật ký chung + lọc mở rộng (phục vụ rà soát và `ai-ops-summary`).

### Later (sau MVP)

- CAP-audit-log-07 — liên kết đối tượng, export nhật ký, chính sách lưu trữ dài hạn, cảnh báo từ nhật ký.

## 11. Launch Readiness

- Guardrail: 0 thay đổi trạng thái/thao tác ghi thiếu bản ghi; 0 vai trò ngoài quản lý đọc được nhật ký.
- Demo script: chạy luồng trả phòng → dọn → xác nhận → báo hỏng → sửa xong, rồi mở nhật ký phòng đó đối chiếu đủ chuỗi trước→sau trên đúng các trục; thử lọc theo thời gian/người/"hệ thống".
- Rollback: nhật ký là lớp ghi thêm — nếu màn xem lỗi, dữ liệu bản ghi vẫn giữ nguyên để đối soát sau.

## 12. Open Questions

- [ ] OQ-1: Khung thời gian mặc định khi mở màn nhật ký và số dòng tối đa mỗi lần tải là bao nhiêu?
- [ ] OQ-2: Có cần ghi cả lượt xem nhật ký của quản lý (read-audit) không? Tạm chốt: v1 chỉ ghi thao tác ghi theo PRD.
