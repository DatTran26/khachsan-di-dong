---
type: srs-spec
feature: audit-log
status: draft
updated: 2026-09-17
links:
  - "[[docs/features/audit-log/audit-log-prd.md|Audit-log PRD]]"
---

# audit-log — SRS (Core Spec)

## 1. Purpose & Scope

Đặc tả lớp nhật ký truy vết: tự động ghi phía máy chủ mọi thay đổi trạng thái phòng (theo từng trục lưu trú/vệ sinh/bảo trì), mọi thao tác ghi nghiệp vụ, sự kiện auth và hành động tự động của hệ thống; quản lý xem nhật ký theo phòng và lọc theo khoảng thời gian/vai trò/người thao tác; bản ghi bất biến làm nguồn sự kiện cho `ai-ops-summary`. Phạm vi: 1 khách sạn 50 phòng, tiếng Việt, dữ liệu giả lập.

## 2. Actors & Stakeholders

| Actor | Type | Trách nhiệm |
|-------|------|-------------|
| Quản lý | Người | Xem nhật ký theo phòng; lọc theo thời gian/vai trò/người thao tác; truy vết khi tranh chấp |
| Nhân viên các vai trò (lễ tân, nv buồng phòng–bảo trì, quản lý) | Người | Chủ thể được ghi khi thực hiện thao tác ghi — không có màn nhật ký |
| Hệ thống | Hệ thống | Tự sinh bản ghi khi thao tác ghi hoàn tất; ghi hành động tự động với actor "hệ thống" |
| Người vận hành (WPCTeam) | Người, ngoài app | Đối soát nghiệm thu, phục hồi sự cố; can thiệp ngoài app không nằm trong nhật ký |
| `ai-ops-summary` | Hệ thống | Bên đọc bản ghi để tổng hợp số liệu theo kỳ (ngoài phạm vi spec này) |

## 3. Functional Requirements

| ID | Requirement | Verification | Priority |
|----|-------------|--------------|----------|
| FR-audit-log-001 | Khi một thao tác ghi được máy chủ kiểm quyền và lưu thành công, hệ thống phải tạo một bản ghi nhật ký gồm: thời điểm máy chủ lưu, người thực hiện (định danh + vai trò, hoặc "hệ thống"), hành động, đối tượng kèm nhãn hiển thị tại thời điểm ghi, và danh sách thay đổi (trường/trục, giá trị trước, giá trị sau). | Test: thực hiện thao tác ghi mẫu, đối chiếu bản ghi | Must |
| FR-audit-log-002 | Bản ghi thay đổi trạng thái phòng phải ghi rõ trục bị đổi (lưu trú / vệ sinh / bảo trì) kèm giá trị trước→sau của trục đó; một thao tác đổi nhiều trục hoặc nhiều đối tượng phải liệt kê đủ từng thay đổi trong cùng một bản ghi. | Test: trả phòng đổi 2 trục → bản ghi liệt kê đủ 2 thay đổi | Must |
| FR-audit-log-003 | Hành động tự động của hệ thống (tự tạo việc, đánh cờ quá hạn, khóa tài khoản sau sai MK, hủy phiên...) phải sinh bản ghi với người thực hiện là "hệ thống". | Demo: trả phòng tự tạo việc → thấy bản ghi "hệ thống" | Must |
| FR-audit-log-004 | Sự kiện auth (đăng nhập/đăng xuất/hết phiên/khóa/mở/đổi MK) phải được ghi theo định nghĩa của `auth-roles`; bản ghi không chứa giá trị mật khẩu. | Test theo kịch bản auth | Must |
| FR-audit-log-005 | Trong ứng dụng không tồn tại thao tác sửa hoặc xóa bản ghi nhật ký; bản ghi giữ nguyên toàn bộ thời gian MVP, không tự xóa. | Kiểm tra chức năng + đọc lại bản ghi cũ | Must |
| FR-audit-log-006 | Bản ghi nhật ký phải lưu cùng thay đổi dữ liệu như một kết quả duy nhất; nếu bản ghi không lưu được, thao tác ghi tương ứng phải báo "chưa hoàn tất" thay vì để thay đổi tồn tại mà thiếu vết. | Test: chặn ghi nhật ký giả lập → thao tác báo không hoàn tất | Must |
| FR-audit-log-007 | Quản lý phải xem được nhật ký của một phòng: danh sách bản ghi theo thời gian (mới nhất trước), mỗi dòng đủ ai/khi/hành động/trục hoặc trường/trước→sau. | Demo theo phòng mẫu | Must |
| FR-audit-log-008 | Quản lý phải lọc được nhật ký theo khoảng thời gian (từ–đến) và theo vai trò/người thao tác (gồm lựa chọn "hệ thống"); kết hợp nhiều lọc thì trả phần giao. | Demo: đặt từng lọc và kết hợp | Must |
| FR-audit-log-009 | Vai trò khác quản lý không được xem nhật ký: giao diện không hiển thị mục nhật ký và máy chủ từ chối đọc dữ liệu nhật ký. | Test bằng tài khoản từng vai trò | Must |
| FR-audit-log-010 | Quản lý phải xem được nhật ký chung toàn hệ thống (gồm sự kiện không gắn phòng như auth) và lọc thêm theo loại hành động, trục trạng thái và loại đối tượng. | Demo | Should |
| FR-audit-log-011 | Khi phạm vi lọc không có bản ghi nào, hệ thống phải hiển thị trạng thái rỗng rõ ràng, không báo lỗi. | Demo: lọc phòng chưa có thay đổi | Must |
| FR-audit-log-012 | Bản ghi nhật ký phải đủ trường (loại hành động, đối tượng/phòng, thời điểm, trục) để `ai-ops-summary` đếm và nhóm sự kiện theo kỳ ca/ngày; nội dung và cách tính tóm tắt thuộc `ai-ops-summary`. | Đối soát nhu cầu tổng hợp của `ai-ops-summary` | Must |

## 4. Non-Functional Requirements

| ID | Requirement | Verification | Priority |
|----|-------------|--------------|----------|
| NFR-audit-log-001 | Integrity: 100% thay đổi trạng thái và thao tác ghi có bản ghi; chuỗi trước→sau của một đối tượng phải dẫn đúng tới trạng thái hiện tại (đối soát 1-1, không thiếu, không lệch). | Đối soát log vs trạng thái hiện tại trong nghiệm thu | Must |
| NFR-audit-log-002 | Immutability: bản ghi là bản chụp lịch sử bất biến — giữ nhãn đối tượng tại thời điểm ghi; đổi tên/xóa đối tượng sau đó không làm mất hay đổi bản ghi. | Test: đổi số phòng sau khi có bản ghi → bản ghi giữ nhãn cũ | Must |
| NFR-audit-log-003 | Security: quyền xem nhật ký thực thi ở máy chủ (chỉ quản lý); không ghi giá trị mật khẩu hay dữ liệu bí mật tương đương vào bản ghi. | Test phân quyền + quét wording bản ghi | Must |
| NFR-audit-log-004 | Usability: dòng nhật ký dùng wording nghiệp vụ tiếng Việt theo mẫu đã chốt — quản lý hiểu được không cần giải thích kỹ thuật; nhãn trục thể hiện riêng. | Demo đọc hiểu với vai trò quản lý | Must |
| NFR-audit-log-005 | Performance: nhật ký được tải theo phần (không tải toàn bộ lịch sử một lần); khung thời gian mặc định và số dòng mỗi lần tải — OQ-1. | Test trên bộ dữ liệu giả lập lớn | Must |

## 5. Business Rules

| ID | Rule | Source | Liên kết |
|----|------|--------|----------|
| BR-audit-log-001 | Chỉ thao tác ghi đã kiểm quyền và lưu thành công mới sinh bản ghi; thao tác bị từ chối không vào nhật ký. | Tôn chỉ (kiểm quyền → lưu → ghi) / BRD BR-01 | FR-001 |
| BR-audit-log-002 | Bản ghi nhật ký lưu cùng thay đổi dữ liệu như một kết quả duy nhất; không ghi được thì thao tác không hoàn tất. | BRD BR-02 | FR-006 |
| BR-audit-log-003 | Chỉ quản lý xem nhật ký; kiểm tra ở máy chủ. | `auth-roles` ma trận quyền / BRD BR-03 | FR-009 |
| BR-audit-log-004 | Nhật ký bất biến, append-only, giữ toàn bộ MVP, không tự xóa. | `auth-roles` (đã chốt) / BRD BR-04 | FR-005 |
| BR-audit-log-005 | Bản ghi thay đổi trạng thái phòng phải chỉ rõ trục (lưu trú/vệ sinh/bảo trì), không gộp. | Tôn chỉ / BRD BR-05 | FR-002 |
| BR-audit-log-006 | Thời điểm bản ghi = mốc máy chủ lưu thành công, không lấy giờ thiết bị. | BRD BR-06 | FR-001 |

## 6. Error Matrix

| ID | Error | Trigger | Severity | Linked Req | User Message |
|----|-------|---------|----------|------------|--------------|
| E-audit-log-001 | Vai trò không được xem nhật ký | Vai trò khác quản lý cố đọc nhật ký | major | FR-009 | "Bạn không có quyền xem nhật ký." |
| E-audit-log-002 | Khoảng thời gian lọc không hợp lệ | Mốc "từ" sau mốc "đến" | minor | FR-008 | "Khoảng thời gian chưa hợp lệ — mốc bắt đầu phải trước hoặc bằng mốc kết thúc." |
| E-audit-log-003 | Mất kết nối khi tải nhật ký | Offline khi mở/lọc nhật ký | major | FR-007, FR-008 | "Mất kết nối — chưa tải được nhật ký. Thử lại khi có mạng." |
| E-audit-log-004 | Không có bản ghi trong phạm vi | Lọc/phòng chưa có thay đổi | info | FR-011 | "Chưa có thay đổi nào trong phạm vi đã chọn." |
| E-audit-log-005 | Ghi nhật ký thất bại khi lưu thao tác | Lỗi lưu phần nhật ký | critical | FR-006 | "Thao tác chưa hoàn tất — vui lòng thử lại." |

## 7. Success Criteria

| ID | Criterion | Đo lường |
|----|-----------|----------|
| SC-audit-log-01 | 100% thay đổi trạng thái có bản ghi đủ ai/khi/trục/từ→sang | Đối soát nhật ký vs thao tác mẫu trong kịch bản nghiệm thu |
| SC-audit-log-02 | 0 thay đổi dữ liệu tồn tại mà thiếu bản ghi tương ứng | Đối soát trạng thái hiện tại vs chuỗi bản ghi |
| SC-audit-log-03 | Quản lý xác định được ai/khi/thay đổi gì trên một phòng trong kịch bản tranh chấp demo, không cần hỗ trợ kỹ thuật | Demo có quan sát |
| SC-audit-log-04 | 0 vai trò ngoài quản lý đọc được nhật ký | Bộ kịch bản phân quyền |
| SC-audit-log-05 | Mọi loại sự kiện nghiệp vụ trong MVP đếm/nhóm được từ nhật ký theo phòng và khoảng thời gian — đủ làm nguồn cho `ai-ops-summary` | Đối chiếu nhu cầu tổng hợp Sprint 3 |

## 8. Entity Summary

| Entity | Fields chính | Quan hệ | Ghi chú |
|--------|--------------|---------|---------|
| Bản ghi nhật ký | thời điểm máy chủ; người thực hiện (định danh + vai trò, hoặc "hệ thống"); hành động; đối tượng (loại + nhãn hiển thị tại thời điểm ghi); danh sách thay đổi (trục/trường, giá trị trước, giá trị sau) | Tham chiếu tới Phòng/Công việc/Tài khoản (entity của feature khác) bằng định danh + nhãn chụp | Append-only, bất biến; không ghi giá trị mật khẩu; một bản ghi có thể liệt kê nhiều thay đổi của cùng thao tác |

## 9. Flow Summary

- Luồng ghi: thao tác ghi → máy chủ kiểm quyền → lưu dữ liệu + bản ghi nhật ký như một kết quả → phát realtime; kiểm quyền thất bại → không đổi, không ghi; ghi nhật ký thất bại → thao tác báo "chưa hoàn tất".
- Luồng xem: quản lý mở màn nhật ký → chọn theo phòng hoặc đặt lọc (thời gian/vai trò/người/"hệ thống"; P1 thêm loại hành động/trục/loại đối tượng) → hệ thống trả bản ghi theo thời gian (mới nhất trước), tải theo phần.
- Luồng nguồn sự kiện: `ai-ops-summary` đọc bản ghi trong kỳ để tổng hợp — `audit-log` chỉ đảm bảo đủ trường để đếm/nhóm.

## 10. Screen Summary

| Screen | Vai trò | Nội dung chính |
|--------|---------|----------------|
| Nhật ký theo phòng | Quản lý (web) | Dòng thời gian bản ghi của một phòng, mới nhất trước; mỗi dòng đủ ai/khi/hành động/trục/trước→sau |
| Nhật ký chung + bộ lọc | Quản lý (web, P1) | Toàn hệ thống gồm sự kiện không gắn phòng; lọc thời gian/vai trò/người/loại hành động/trục/loại đối tượng; tải theo phần |

## 11. Constraints & Dependencies

### Constraints

- MVP 8 tuần, 1 khách sạn 50 phòng, tiếng Việt, dữ liệu giả lập (tôn chỉ).
- Kiểm tra quyền và ghi nhật ký ở máy chủ; lưu dữ liệu trước khi phát sự kiện (tôn chỉ).
- Ba trục trạng thái phòng theo dõi riêng — bản ghi chỉ rõ trục, không gộp.
- Chưa làm v1: export nhật ký, chính sách lưu trữ dài hạn, cảnh báo từ nhật ký.
- Màn nhật ký trên web cho quản lý; mobile không có màn nhật ký v1.

### Dependencies

- `auth-roles`: định danh/vai trò, kiểm quyền server-side, định nghĩa sự kiện auth và cơ chế ghi nền (Sprint 1).
- `room-catalog`, `check-in-out`, `housekeeping`, `maintenance`: nguồn sự kiện nghiệp vụ (Sprint 2, song song).
- `realtime-sync`: phát thay đổi sau khi lưu (Sprint 2).
- `ai-ops-summary`: bên đọc bản ghi để tổng hợp (Sprint 3).

### Assumptions

- Chỉ thao tác ghi thành công mới sinh bản ghi; xem nhật ký là đọc theo yêu cầu, không realtime; thứ tự mặc định mới nhất trước.
- Một thao tác đổi nhiều trục/đối tượng sinh một bản ghi liệt kê đủ từng thay đổi.
- Can thiệp ngoài app của người vận hành nằm ngoài nhật ký; khung mặc định + giới hạn tải — OQ-1; read-audit — OQ-2 (tạm chốt không ghi).

## 12. Open Questions

- [ ] OQ-1: Khung thời gian mặc định khi mở màn nhật ký và số dòng tối đa mỗi lần tải là bao nhiêu?
- [ ] OQ-2: Có cần ghi cả lượt xem nhật ký của quản lý (read-audit) không? Tạm chốt: v1 chỉ ghi thao tác ghi theo PRD.
