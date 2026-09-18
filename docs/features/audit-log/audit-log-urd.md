---
type: urd
feature: audit-log
status: draft
updated: 2026-09-17
links:
  - "[[docs/features/audit-log/brainstorms/nhat-ky-truy-vet.md|Brainstorm: Nhật ký truy vết]]"
  - "[[docs/_product/prd.md|Product PRD — mục 7.8]]"
  - "[[Ton_Chi_Du_An_WPCTeam.txt|Tôn chỉ dự án]]"
---

# audit-log — User Requirements Document

## 1. Purpose

Nhật ký thay đổi giúp quản lý truy vết mọi thay đổi trạng thái và thao tác ghi trên hệ thống — ai làm, khi nào, trên đối tượng nào, từ giá trị nào sang giá trị nào — để giải quyết sai lệch và tranh chấp "ai đã đổi gì", đồng thời làm nguồn sự kiện đáng tin cho `ai-ops-summary`.

### User Problem & Current Experience

| User | Current Situation | Problem | User Consequence | Evidence |
|------|-------------------|---------|------------------|----------|
| Quản lý | Cập nhật trạng thái rời rạc qua điện thoại/miệng, lễ tân nhập hộ sau | Không có bằng chứng ai đổi gì khi nào | Tranh chấp giữa các ca không giải quyết được; sai lệch dữ liệu không ai chịu trách nhiệm | Confirmed (PRD 7.8: "truy vết khi có tranh chấp"; tôn chỉ: ghi nhật ký máy chủ) |
| Quản lý | Cuối ca muốn rà soát hoạt động | Phải hỏi từng người hoặc tự nhớ | Sót việc, mất thời gian điều hành | Confirmed (PRD 7.8: xem theo khoảng thời gian) |
| Quản lý | Đọc bản tóm tắt AI cuối ca | Tóm tắt chỉ đúng nếu sự kiện đầu vào đầy đủ | AI thiếu sự kiện → tóm tắt sai → mất tin | Confirmed (PRD: audit-log là nguồn sự kiện cho ai-ops-summary) |
| Người vận hành (WPCTeam) | Nghiệm thu cần đối soát dữ liệu vs hành vi | Không có vết để chứng minh hệ thống ghi đúng | Không chứng minh được tiêu chí "100% thay đổi có bản ghi" | Confirmed (PRD: đo thành công của feature) |

## 2. User Types

| Tier | User Type | Context | Primary Goal | Pain Points |
|------|-----------|---------|--------------|-------------|
| primary | Quản lý | Web dashboard tại quầy/văn phòng | Truy vết thay đổi khi tranh chấp; rà soát theo phòng/thời gian/người | Không muốn hỏi từng người; cần đọc hiểu ngay không qua kỹ thuật |
| secondary | Người vận hành (WPCTeam) | Ngoài app — đối soát, phục hồi | Nhật ký tin cậy để chứng minh và điều tra | Can thiệp trực tiếp ngoài app không nằm trong nhật ký |

*Lễ tân và nv buồng phòng–bảo trì không phải người dùng của feature này — họ là chủ thể được ghi. Khách là đối tượng dữ liệu. "Hệ thống" là tác nhân ghi, không phải người dùng.*

## 3. Scope Boundaries

### In Scope

- Tự động ghi mọi thay đổi trạng thái phòng theo từng trục riêng (lưu trú / vệ sinh / bảo trì) và mọi thao tác ghi nghiệp vụ.
- Bản ghi đủ: thời điểm máy chủ, người thực hiện + vai trò (hoặc "hệ thống"), hành động, đối tượng, giá trị trước → sau.
- Quản lý xem nhật ký theo phòng; lọc theo khoảng thời gian và vai trò/người thao tác.
- Nhật ký bất biến, append-only, giữ toàn bộ thời gian MVP.
- Sự kiện auth và hành động tự động của hệ thống cũng được ghi (theo định nghĩa `auth-roles`).
- Bản ghi đủ cấu trúc làm nguồn sự kiện cho `ai-ops-summary`.

### Out of Scope

- Nội dung tóm tắt AI, cách tính số liệu, khử định danh khi gửi AI — thuộc `ai-ops-summary`.
- Quyền hạn từng vai trò trên từng hành động — thuộc `auth-roles`; audit-log chỉ ghi lại.
- Nghiệp vụ sinh sự kiện (nhận/trả phòng, dọn, báo hỏng, danh mục phòng) — thuộc feature tương ứng.
- Export nhật ký, chính sách lưu trữ dài hạn, cảnh báo từ nhật ký — PRD "chưa làm".
- Xem lịch sử từ dashboard — `room-dashboard` đã xếp ngoài phạm vi.
- Ghi can thiệp của người vận hành ngoài app.

## 4. User Needs

| ID | User | Context / Trigger | User Need | Expected Outcome | Importance | Evidence |
|----|------|-------------------|-----------|------------------|------------|----------|
| UN-001 | Quản lý | Có tranh chấp/sai lệch về một phòng | Biết ai đã đổi gì, khi nào, trên trục nào của phòng đó | Mở nhật ký phòng thấy chuỗi đầy đủ trước→sau | Critical | Confirmed (PRD 7.8) |
| UN-002 | Quản lý | Rà soát hoạt động cuối ca/ngày | Xem mọi thay đổi trong khoảng thời gian chọn | Lọc từ–đến trả đúng bản ghi | High | Confirmed (PRD: lọc theo thời gian) |
| UN-003 | Quản lý | Nghi vấn về một nhân viên/vai trò cụ thể | Thu hẹp nhật ký theo vai trò/người thao tác | Lọc trả đúng bản ghi của đối tượng đó | High | Confirmed (PRD: lọc vai trò/người) |
| UN-004 | Quản lý | Đọc từng dòng nhật ký | Hiểu ngay thay đổi, biết rõ trục nào đổi, không cần giải thích kỹ thuật | Wording nghiệp vụ; ba trục thể hiện riêng | High | Confirmed (tôn chỉ: 3 trục riêng tránh nhầm) |
| UN-005 | Quản lý | Dựa vào nhật ký để kết luận trách nhiệm | Tin rằng nhật ký phản ánh đúng sự thật | Không thao tác sửa/xóa nào tồn tại; thay đổi nào cũng có vết | Critical | Confirmed (PRD rủi ro "mất vết") |
| UN-006 | Quản lý | Đọc tóm tắt AI cuối ca (qua `ai-ops-summary`) | Sự kiện đầu vào đầy đủ để tóm tắt đúng | Mọi loại sự kiện MVP đếm/nhóm được từ nhật ký | High | Confirmed (PRD: audit-log là nguồn sự kiện) |

## 5. Prioritized User Journeys

### Journey 1: Quản lý truy vết tranh chấp trên một phòng

- **User:** Quản lý
- **Importance:** Critical
- **Trigger:** Phát hiện sai lệch hoặc tranh chấp "ai đã đổi gì" trên phòng X
- **Expected outcome:** Xác định được người thực hiện, thời điểm và nội dung thay đổi
- **Related needs:** UN-001, UN-004, UN-005

1) Quản lý mở màn nhật ký, chọn xem theo phòng X.
2) Danh sách bản ghi của phòng X hiện theo thời gian, mới nhất trước.
3) Quản lý đọc chuỗi thay đổi: ai — vai trò — lúc nào — hành động — trục nào — trước→sau.
4) Quản lý kết luận được trách nhiệm mà không cần hỏi ai thêm.

**Independent verification:** Đối chiếu nhật ký phòng X với trạng thái hiện tại của phòng — chuỗi trước→sau phải dẫn đúng tới trạng thái hiện tại.

### Journey 2: Quản lý rà soát một khoảng thời gian và/hoặc một người

- **User:** Quản lý
- **Importance:** High
- **Trigger:** Cuối ca/ngày, hoặc nghi vấn về một nhân viên/vai trò
- **Expected outcome:** Danh sách bản ghi thu hẹp đúng theo lọc
- **Related needs:** UN-002, UN-003

1) Quản lý đặt lọc khoảng thời gian (từ–đến) và/hoặc chọn vai trò/người thao tác (gồm lựa chọn "hệ thống").
2) Hệ thống hiển thị bản ghi khớp lọc.
3) Quản lý đọc/rà soát; không có bản ghi thì thấy trạng thái rỗng rõ ràng.

**Independent verification:** Tạo vài thao tác mẫu bởi các vai trò khác nhau rồi lọc — kết quả khớp đúng phạm vi lọc.

### Journey 3: Quản lý kiểm chứng hành động tự động của hệ thống

- **User:** Quản lý
- **Importance:** Medium
- **Trigger:** Thấy thay đổi mà không ai thừa nhận (vd việc dọn tự tạo, TK bị khóa, cờ quá hạn)
- **Expected outcome:** Thấy bản ghi ghi người thực hiện là "hệ thống", hiểu đó là hành động tự động
- **Related needs:** UN-001, UN-004, UN-005

1) Quản lý mở nhật ký (theo phòng hoặc lọc người thao tác = "hệ thống").
2) Bản ghi do hệ thống sinh hiển thị actor "hệ thống" kèm thay đổi trước→sau.
3) Quản lý phân biệt được hành động người vs hành động tự động.

**Independent verification:** Kịch bản trả phòng tự sinh việc dọn — nhật ký có bản ghi actor "hệ thống" cho việc được tạo.

### Journey 4: Vai trò không phải quản lý tìm cách xem nhật ký

- **User:** Lễ tân / nv buồng phòng–bảo trì
- **Importance:** Medium
- **Trigger:** Cố mở màn/dữ liệu nhật ký
- **Expected outcome:** Bị từ chối — không thấy mục nhật ký, máy chủ từ chối dữ liệu
- **Related needs:** UN-005

1) Người dùng vai trò khác quản lý tìm mục nhật ký → không có trên giao diện của họ.
2) Nếu cố truy cập trực tiếp → máy chủ từ chối vì thiếu quyền.

**Independent verification:** Bộ kịch bản phân quyền: 0 vai trò ngoài quản lý đọc được nhật ký.

## 6. User Exceptions & Edge Conditions

| Situation | User Impact | Expected User-facing Outcome | Related Journey / Need |
|-----------|-------------|------------------------------|------------------------|
| Phòng chưa có thay đổi nào | Tưởng màn hỏng | Trạng thái rỗng rõ ràng "Chưa có thay đổi nào trong phạm vi đã chọn." | J1, J2 |
| Khoảng thời gian lọc không hợp lệ (từ sau đến) | Không hiểu vì sao không có kết quả | Báo lỗi rõ và giữ giá trị đã nhập để sửa | J2 |
| Mất mạng khi đang tải nhật ký | Không biết dữ liệu có đầy đủ không | Báo mất kết nối, giữ phần đã tải, cho tải lại khi có mạng | J1, J2 |
| Nhật ký quá dài | Tải chậm, khó đọc | Tải theo phần + khung thời gian mặc định (giá trị — OQ-1) | J2 |
| Bản ghi chứa tên khách giả lập | Quản lý thấy tên khách trong giá trị | Hiển thị bình thường — dữ liệu giả lập; khử định danh chỉ áp khi gửi AI (thuộc `ai-ops-summary`) | J1 |
| Thao tác bị từ chối (thiếu quyền/xung đột) | Tìm vết của thao tác đó trong nhật ký | Không có bản ghi — vì không có thay đổi dữ liệu (theo luồng kiểm quyền → lưu → ghi) | J1 |
| Đối tượng bị đổi tên/xóa sau đó | Bản ghi tham chiếu đối tượng cũ | Bản ghi vẫn hiển thị nhãn tại thời điểm ghi — nhật ký là bản chụp lịch sử | J1 |

## 7. User-side Constraints

- Ngôn ngữ: tiếng Việt toàn bộ giao diện và nội dung nhật ký.
- Kênh/thiết bị: màn nhật ký trên web cho quản lý; mobile không có màn nhật ký trong v1.
- Điều kiện sử dụng: phải đăng nhập vai trò quản lý; quyền xem kiểm tra ở máy chủ.
- Kết nối: đọc nhật ký cần kết nối; mất mạng báo trạng thái rõ (nhất quán quy tắc offline chung).
- Phạm vi dữ liệu: 1 khách sạn 50 phòng, dữ liệu giả lập.

## 8. Assumptions & Validation

| Assumption | Impact if Wrong | Validation Status | Next Action |
|------------|-----------------|-------------------|-------------|
| Chỉ thao tác ghi đã lưu thành công mới sinh bản ghi | Nếu cần ghi cả thao tác bị từ chối → phải mở phạm vi | Suy ra từ luồng tôn chỉ (kiểm quyền → lưu → ghi) | Xác nhận qua kịch bản demo |
| Xem nhật ký là đọc theo yêu cầu, không realtime | Nếu cần realtime thì phải thêm kênh phát | Suy ra từ PRD (chỉ realtime thay đổi trạng thái) | Xác nhận khi demo |
| Khung thời gian mặc định + giới hạn dòng tải chưa chốt | Màn mặc định có thể nặng hoặc thiếu ngữ cảnh | Chưa xác nhận — OQ-1 | Hỏi khi `/srs` hoặc demo |
| Ghi lượt xem nhật ký (read-audit) chưa nằm trong v1 | Nếu cần tự truy vết việc truy vết → thêm loại sự kiện | Chưa xác nhận — OQ-2 (tạm chốt chỉ ghi thao tác ghi) | Xác nhận với điều phối/BA |

## 9. User Success Criteria

| ID | User Outcome | Baseline | Target | Measurement | Review Period |
|----|--------------|----------|--------|-------------|---------------|
| USC-001 | Mọi thay đổi trạng thái đều có vết đủ | Chưa có — không có nhật ký thống nhất | 100% thay đổi trạng thái có bản ghi đủ ai/khi/trục/từ→sang | Đối soát nhật ký vs thao tác trong kịch bản nghiệm thu | Nghiệm thu |
| USC-002 | Quản lý tự truy vết được | Chưa có | Xác định được ai/khi/thay đổi gì trên một phòng trong kịch bản tranh chấp demo, không cần hỗ trợ kỹ thuật | Demo có quan sát | Sprint 2–3 |
| USC-003 | Nhật ký chỉ quản lý thấy | Chưa có | 0 vai trò ngoài quản lý đọc được nhật ký | Bộ kịch bản phân quyền | Nghiệm thu |
| USC-004 | Nhật ký đủ làm nguồn sự kiện | Chưa có | Mọi loại sự kiện MVP đếm/nhóm được theo phòng và khoảng thời gian | Đối soát nhu cầu tổng hợp của `ai-ops-summary` | Sprint 3 |

## 10. Open Questions

- [ ] OQ-1: Khung thời gian mặc định khi mở màn nhật ký và số dòng tối đa mỗi lần tải là bao nhiêu?
- [ ] OQ-2: Có cần ghi cả lượt xem nhật ký của quản lý (read-audit) không? Tạm chốt: v1 chỉ ghi thao tác ghi theo PRD.
