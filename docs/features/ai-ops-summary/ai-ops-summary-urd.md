---
type: urd
feature: ai-ops-summary
status: draft
updated: 2026-09-17
links:
  - "[[docs/features/ai-ops-summary/brainstorms/ai-tom-tat-van-hanh.md|Brainstorm: AI tóm tắt vận hành]]"
  - "[[docs/_product/prd.md|Product PRD — mục 7.9]]"
  - "[[Ton_Chi_Du_An_WPCTeam.txt|Tôn chỉ dự án]]"
---

# ai-ops-summary — User Requirements Document

## 1. Purpose

Cho phép quản lý tạo một bản tóm tắt vận hành theo ca/ngày trong một thao tác: hệ thống tổng hợp số liệu từ dashboard và nhật ký (không chứa thông tin định danh khách), nhờ dịch vụ AI bên ngoài diễn giải thành bản tóm tắt có cấu trúc kèm gợi ý việc cần chú ý — thay cho việc tự mở nhiều màn hình và tự cộng dồn cuối mỗi ca.

### User Problem & Current Experience

| User | Current Situation | Problem | User Consequence | Evidence |
|------|-------------------|---------|------------------|----------|
| Quản lý | Cuối ca/cuối ngày tự mở dashboard, lật nhật ký từng phòng để tổng hợp tình hình | Việc tổng hợp thủ công chậm, dễ sót việc đang trễ hoặc sự kiện nổi bật trong ca | Bàn giao ca thiếu thông tin; việc quá hạn/phòng ngừng phục vụ bị phát hiện muộn | Confirmed (tôn chỉ: "AI tạo bản tóm tắt vận hành theo ca/ngày từ số liệu hệ thống và gợi ý các việc cần chú ý") |
| Quản lý | Nghe đồn/nguồn tin không kiểm chứng được khi hỏi lại nhân viên | Không có bản tin chốt theo thời điểm dữ liệu rõ ràng | Khó đối chiếu "lúc đó tình hình thế nào" khi có tranh luận | Assumption (suy từ nhu cầu truy vết của PRD mục 7.8 + thời điểm dữ liệu ở 7.9) |

## 2. User Types

| Tier | User Type | Context | Primary Goal | Pain Points |
|------|-----------|---------|--------------|-------------|
| primary | Quản lý | Web dashboard, cuối ca hoặc cuối ngày | Có bản tóm tắt vận hành đáng tin trong 1 thao tác, biết ngay việc cần chú ý | Tổng hợp thủ công chậm và sót; không tin được bản tóm tắt sai số liệu |

*Feature chỉ phục vụ quản lý (PRD mục 7.9). Lễ tân và nhân viên buồng phòng–bảo trì không có điểm chạm trong feature này — họ chỉ là nguồn dữ liệu gián tiếp qua dashboard và nhật ký. Không có secondary user.*

## 3. Scope Boundaries

### In Scope

- Quản lý chọn kỳ tóm tắt trong các tùy chọn có sẵn (ca hiện tại / ca trước / hôm nay) và bấm tạo — tạo theo yêu cầu, không tự động theo lịch.
- Xem bản tóm tắt có cấu trúc: tổng quan tình hình + điểm nổi bật + danh sách việc cần chú ý.
- Thấy rõ thời điểm dữ liệu mà bản tóm tắt dựa vào, và nhãn "tham khảo" trên mọi bản.
- Khi dịch vụ AI lỗi hoặc hết hạn mức, vẫn nhận được báo cáo mẫu dựng từ dữ liệu gốc (cùng nhóm chỉ số chính + việc cần chú ý theo quy tắc).
- Kỳ không có dữ liệu thì thấy thông báo rõ, không tốn lượt gọi AI.

### Out of Scope

- Tự động tạo tóm tắt theo lịch cuối ca (hướng sau MVP).
- Hỏi-đáp tự do với AI về số liệu vận hành; đa ngôn ngữ; huấn luyện/tinh chỉnh AI riêng.
- AI quyết định hoặc tự sửa dữ liệu/trạng thái phòng — AI chỉ đọc số liệu, người quản lý quyết định.
- Xem lưới phòng/chỉ số realtime (feature `room-dashboard` — nguồn số liệu); xem nhật ký chi tiết từng phòng (feature `audit-log` — nguồn sự kiện).
- Xuất/chia sẻ bản tóm tắt ra ngoài (email, file, in).

## 4. User Needs

| ID | User | Context / Trigger | User Need | Expected Outcome | Importance | Evidence |
|----|------|-------------------|-----------|------------------|------------|----------|
| UN-001 | Quản lý | Cuối ca/cuối ngày cần nắm tình hình | Tạo bản tóm tắt vận hành của kỳ trong 1 thao tác, không phải mở nhiều màn | Bản tóm tắt hiển thị sau khi bấm "Tạo tóm tắt" | Critical | Confirmed (tôn chỉ + PRD 7.9) |
| UN-002 | Quản lý | Đọc bản tóm tắt để quyết định điều phối | Số liệu trong tóm tắt khớp dữ liệu gốc, không có sự kiện bịa thêm | Mọi con số AI nêu đối chiếu được với dashboard/nhật ký cùng kỳ | Critical | Confirmed (tôn chỉ: "kiểm tra đầu ra") |
| UN-003 | Quản lý | Có việc đang trễ trong ca | Bản tóm tắt nêu rõ việc cần chú ý (việc quá hạn, phòng ngừng phục vụ) | Mục "việc cần chú ý" liệt kê đúng các việc quá hạn/ngừng phục vụ của kỳ | High | Confirmed (tôn chỉ: "gợi ý các việc cần chú ý") |
| UN-004 | Quản lý | Đọc bản AI tạo | Biết rõ đây là bản tham khảo do AI tạo, và dữ liệu tính đến thời điểm nào | Mọi bản hiển thị nhãn tham khảo + thời điểm dữ liệu; không nhầm là quyết định hệ thống | High | Confirmed (tôn chỉ: "kèm thời điểm dữ liệu và nhãn tham khảo") |
| UN-005 | Quản lý | Dịch vụ AI lỗi hoặc hết hạn mức | Vẫn có báo cáo số liệu cốt lõi của kỳ, không bị trắng trang | Báo cáo mẫu từ dữ liệu gốc hiển thị thay thế, kèm nhãn phân biệt | High | Confirmed (tôn chỉ: "nếu AI lỗi thì hiển thị báo cáo mẫu từ dữ liệu gốc") |
| UN-006 | Quản lý | Muốn tóm tắt kỳ khác hoặc tạo lại | Đổi kỳ/tạo lại dễ dàng; nếu chốt lưu thì xem lại bản gần nhất | Tạo lại được cho kỳ đã chọn; bản mới thay bản cũ | Medium | Assumption + OQ-4 (chưa chốt lưu/xem lại) |

## 5. Prioritized User Journeys

### Journey 1: Quản lý tạo và đọc tóm tắt AI cuối ca

- **User:** Quản lý
- **Importance:** Critical
- **Trigger:** Cuối ca làm việc, cần nắm và bàn giao tình hình
- **Expected outcome:** Có bản tóm tắt có cấu trúc, đúng số liệu, nêu việc cần chú ý, kèm thời điểm dữ liệu và nhãn tham khảo
- **Related needs:** UN-001, UN-002, UN-003, UN-004

1) Quản lý mở màn "Tóm tắt vận hành" trên web dashboard.
2) Chọn kỳ (ca hiện tại / ca trước / hôm nay), bấm "Tạo tóm tắt".
3) Chờ trạng thái đang tạo; bản tóm tắt hiển thị gồm tổng quan + điểm nổi bật + việc cần chú ý.
4) Đọc và đối chiếu nhanh với dashboard nếu cần; dùng để bàn giao ca.

**Independent verification:** Chọn một kỳ có dữ liệu giả lập; bản tóm tắt hiển thị, mọi con số nêu trong đó khớp chỉ số dashboard và đếm sự kiện nhật ký của đúng kỳ đó; mục việc cần chú ý chứa đúng các việc quá hạn/ngừng phục vụ.

### Journey 2: Quản lý vẫn nắm được tình hình khi AI lỗi hoặc hết hạn mức

- **User:** Quản lý
- **Importance:** High
- **Trigger:** Bấm tạo tóm tắt nhưng dịch vụ AI lỗi/quá thời gian chờ, hoặc hệ thống đã hết hạn mức
- **Expected outcome:** Vẫn nhận được báo cáo mẫu đủ số liệu cốt lõi của kỳ, hiểu rõ đây không phải bản AI
- **Related needs:** UN-005, UN-001

1) Quản lý bấm tạo như Journey 1.
2) Thay vì bản AI, hệ thống hiển thị báo cáo mẫu: các chỉ số chính của kỳ + việc cần chú ý theo quy tắc, kèm nhãn "Báo cáo mẫu — dữ liệu gốc, chưa qua AI" và thời điểm dữ liệu.
3) Quản lý đọc số liệu như thường, có thể bấm tạo lại sau.

**Independent verification:** Giả lập lỗi dịch vụ AI hoặc trạng thái hết hạn mức; báo cáo mẫu vẫn hiển thị đủ nhóm chỉ số chính và danh sách việc cần chú ý, không có nội dung narrative nào của AI.

### Journey 3: Quản lý tạo tóm tắt cho kỳ trước hoặc tạo lại

- **User:** Quản lý
- **Importance:** Medium
- **Trigger:** Cần xem lại tình hình ca trước/hôm nay, hoặc muốn bản mới hơn cho cùng kỳ
- **Expected outcome:** Bản tóm tắt của kỳ được chọn hiển thị; bản mới thay thế bản cũ trên màn
- **Related needs:** UN-006, UN-001

1) Quản lý đổi kỳ (vd "ca trước") và bấm tạo.
2) Hệ thống tạo bản mới cho kỳ đó và hiển thị thay bản đang xem.
3) Nếu chốt lưu (OQ-4), quản lý mở lại bản gần nhất mà không cần tạo lại.

**Independent verification:** Tạo cho 2 kỳ khác nhau liên tiếp: mỗi bản mang đúng thời điểm dữ liệu và số liệu của kỳ tương ứng, không lẫn dữ liệu giữa các kỳ.

## 6. User Exceptions & Edge Conditions

| Situation | User Impact | Expected User-facing Outcome | Related Journey / Need |
|-----------|-------------|------------------------------|------------------------|
| Kỳ được chọn không có hoạt động nào | Tưởng hệ thống lỗi vì không có nội dung | Thấy báo cáo mẫu rỗng "Chưa có dữ liệu trong kỳ đã chọn", không mất lượt gọi AI | J1, UN-001 |
| Dịch vụ AI lỗi / quá thời gian chờ | Không có bản tóm tắt AI | Thấy báo cáo mẫu kèm nhãn rõ "chưa qua AI", có thể tạo lại sau | J2, UN-005 |
| Đã hết hạn mức AI | Không gọi AI được nữa | Báo cáo mẫu hiển thị bình thường kèm thông báo hết hạn mức; vẫn đủ số liệu cốt lõi | J2, UN-005 |
| Đầu ra AI sai số liệu / bịa sự kiện | Nguy cơ đọc và tin dữ liệu sai | Không thấy bản sai — hệ thống loại bản AI và hiển thị báo cáo mẫu thay thế | J1, UN-002 |
| Mất kết nối khi đang tạo | Không biết tóm tắt đã tạo chưa | Thấy báo "Mất kết nối — chưa tạo được tóm tắt. Thử lại khi có mạng."; không có bản lỗi lưu lại | J1, UN-001 |
| Bấm tạo khi đã có một lượt đang chạy | Tưởng bấm không ăn | Thấy thông báo "Đang có một tóm tắt được tạo — vui lòng chờ."; yêu cầu đầu tiếp tục | J1 |
| Lễ tân/nhân viên cố mở màn tóm tắt | Truy cập bị từ chối | Thấy "Bạn không có quyền thực hiện thao tác này." | — (ràng buộc quyền) |
| Dữ liệu thay đổi trong lúc đang tạo | Số liệu tóm tắt lệch màn hình hiện tại | Bản tóm tắt gắn thời điểm chốt T; nhãn thời điểm làm rõ thay đổi sau T không thuộc bản này | J1, UN-004 |

## 7. User-side Constraints

- Ngôn ngữ: toàn bộ giao diện, bản tóm tắt và thông báo bằng tiếng Việt.
- Kênh/thiết bị: chỉ trên web dashboard của quản lý (mobile không có màn này trong MVP).
- Điều kiện sử dụng: chỉ vai trò quản lý được tạo và xem tóm tắt.
- Riêng tư: quản lý cần chắc rằng không thông tin nào định danh khách bị gửi ra dịch vụ ngoài — chỉ số liệu tổng hợp.
- Môi trường: 1 khách sạn 50 phòng, dữ liệu giả lập; hạn mức chi phí AI có giới hạn nên mỗi lần tạo đều được tính vào hạn mức.

## 8. Assumptions & Validation

| Assumption | Impact if Wrong | Validation Status | Next Action |
|------------|-----------------|-------------------|-------------|
| "Ca/ngày" là các tùy chọn kỳ có sẵn; khung giờ ca định nghĩa sẵn trong hệ thống | Nếu quản lý phải tự chọn khoảng giờ, màn chọn kỳ phức tạp hơn | Chưa xác nhận — OQ-1 | Chốt định nghĩa khung giờ ca khi thiết kế màn chọn kỳ |
| Dịch vụ AI bên ngoài trả được kết quả có cấu trúc (tổng quan + nổi bật + việc cần chú ý) | Nếu không có đầu ra cấu trúc, bước kiểm tra và hiển thị khó thống nhất | Assumption từ tôn chỉ (ví dụ OpenAI/Google AI) — OQ-3 | Chốt provider khi tích hợp ở sprint 3 |
| Bản tóm tắt được lưu để xem lại trong ngày | Nếu chỉ hiển thị tức thời, quản lý mất bản khi đổi màn/đăng xuất | Chưa xác nhận — OQ-4 | Chốt lưu hay không lưu trước khi build |
| Báo cáo mẫu dùng cùng nhóm chỉ số chính của kỳ + việc cần chú ý theo quy tắc, không có narrative AI | Nếu báo cáo mẫu thiếu nhóm chỉ số, fallback không đủ dùng | Assumption nhất quán tôn chỉ ("báo cáo mẫu từ dữ liệu gốc") | Kiểm chứng qua demo khi AI lỗi |
| Kiểm tra đầu ra AI ở mức đối chiếu số liệu (con số phải khớp, sự kiện bịa bị loại) | Nếu ngưỡng kiểm tra lỏng, bản sai có thể lọt hiển thị | Assumption | Xác nhận tiêu chí đối chiếu trong kịch bản nghiệm thu |

## 9. User Success Criteria

| ID | User Outcome | Baseline | Target | Measurement | Review Period |
|----|--------------|----------|--------|-------------|---------------|
| USC-001 | Quản lý có bản tóm tắt vận hành đáng tin trong 1 thao tác | Chưa có — hiện tổng hợp thủ công từ nhiều màn | ≥18/20 tình huống thử nghiệm: đúng số liệu, không thêm sự kiện, nêu đúng việc cần chú ý | Kịch bản nghiệm thu AI của tôn chỉ | Nghiệm thu (02/11/2026) |
| USC-002 | Không mất khả năng xem số liệu khi AI lỗi | Chưa có | 100% ca API lỗi hoặc hết hạn mức rơi về báo cáo mẫu | Kịch bản nghiệm thu bắt buộc | Nghiệm thu |
| USC-003 | Mọi bản đều rõ nguồn và thời điểm dữ liệu | Chưa có | 100% bản hiển thị kèm thời điểm dữ liệu + nhãn "tham khảo"/"báo cáo mẫu" đúng loại | Kiểm tra giao diện trong demo | Nghiệm thu |
| USC-004 | AI không bao giờ chạm vào dữ liệu nghiệp vụ | Chưa có | 0 lần AI tự ghi/sửa dữ liệu (kể cả trạng thái phòng); 0 payload gửi ra ngoài chứa thông tin định danh khách | Đối soát nhật ký + dữ liệu gửi AI trong kịch bản thử | Nghiệm thu |

## 10. Open Questions

- [ ] OQ-1: Khung giờ "ca" để tóm tắt định nghĩa thế nào — ca cố định theo giờ (vd sáng/chiều/tối) hay quản lý chọn khoảng thời gian tùy ý?
- [ ] OQ-2: Hạn mức AI cụ thể là gì — số lần tạo tối đa/ngày, ngưỡng chi phí cắt, hay cả hai? Giá trị bao nhiêu?
- [ ] OQ-3: Chọn dịch vụ LLM nào cho demo (OpenAI, Google AI, hay provider khác có đầu ra có cấu trúc)?
- [ ] OQ-4: Bản tóm tắt đã tạo có được lưu để xem lại trong ngày, hay chỉ hiển thị tức thời?
- [ ] OQ-5: Thời gian chờ tối đa khi gọi dịch vụ AI trước khi rơi về báo cáo mẫu là bao nhiêu giây?
