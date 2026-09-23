---
type: urd
feature: realtime-sync
status: draft
updated: 2026-09-23
links:
  - "[[docs/features/realtime-sync/brainstorms/co-che-dong-bo-realtime.md|Brainstorm: Cơ chế đồng bộ thời gian thực]]"
  - "[[Ton_Chi_Du_An_WPCTeam.txt|Tôn chỉ dự án]]"
---

# realtime-sync — User Requirements Document

## 1. Purpose

Đảm bảo mọi vai trò luôn nhìn và thao tác trên cùng một trạng thái phòng mới nhất: cập nhật lan tới thiết bị khác trong ≤3 giây, không ai vô tình ghi đè lên thay đổi của người khác, và khi mất mạng người dùng được báo rõ thay vì âm thầm mất thao tác.

### User Problem & Current Experience

| User | Current Situation | Problem | User Consequence | Evidence |
|------|-------------------|---------|------------------|----------|
| Mọi vai trò | Mỗi người cập nhật trên giấy/Excel/điện thoại riêng | Trạng thái phòng lệch nhau giữa các người dùng | Lễ tân phải gọi đi xác nhận từng phòng; nhận nhầm phòng chưa sẵn sàng | Confirmed (tôn chỉ: "giảm việc cập nhật rời rạc"; PRD cốt lõi) |
| Nhân viên buồng phòng–bảo trì | Wifi hiện trường không ổn định | Không biết thao tác vừa làm đã lưu hay chưa | Dọn/sửa xong nhưng quầy vẫn thấy cũ; thao tác mất lặng lẽ | Confirmed (PRD: mất mạng phải báo + khóa ghi) |
| Quản lý | Cần cái nhìn tổng realtime để điều phối | Dữ liệu trễ làm quyết định sai trong ca | Điều phối trễ, việc quá hạn không ai biết | Confirmed (PRD: dashboard realtime) |
| Hai người cùng thao tác | Sửa cùng một đối tượng | Người sau ghi đè người trước không ai hay | Dữ liệu sai trên toàn hệ thống (rủi ro chính PRD) | Confirmed (PRD: kiểm tra phiên bản) |

## 2. User Types

| Tier | User Type | Context | Primary Goal | Pain Points |
|------|-----------|---------|--------------|-------------|
| primary | Mọi vai trò đang thao tác (nhân viên buồng phòng–bảo trì, lễ tân, quản lý) | Web + Android, trong ca làm việc | Thao tác và nhìn trên dữ liệu mới nhất; được báo rõ khi mất kết nối hoặc bị xung đột | Màn hình cũ; thao tác mất lặng lẽ; ghi đè lẫn nhau |
| secondary | Người vận hành hệ thống (WPCTeam) | Vận hành/kiểm thử | Một cơ chế đồng bộ dùng chung, đo được độ trễ để nghiệm thu | Mỗi feature tự đồng bộ sẽ lệch nhau |

## 3. Scope Boundaries

### In Scope

- Lưu thay đổi ở máy chủ trước rồi phát sự kiện tới mọi thiết bị đang kết nối.
- Cập nhật hiển thị trên thiết bị khác trong ≤3 giây.
- Kiểm tra phiên bản chống ghi đè; người bị từ chối được báo và tải lại bản mới.
- Phát hiện mất kết nối → báo trạng thái + khóa ghi (vẫn xem dữ liệu cuối).
- Tự kết nối lại → tải trạng thái mới → mở khóa ghi.
- Chỉ báo trạng thái kết nối thống nhất trên mọi màn hình.

### Out of Scope

- Hàng đợi offline cho thao tác ghi; đồng bộ nội dung soạn dở; retry thông minh (PRD "chưa làm").
- Nghiệp vụ trạng thái cụ thể (báo hỏng, dọn phòng, nhận/trả) — thuộc `maintenance`, `housekeeping`, `check-in-out`; feature này chỉ là đường truyền.
- Quản lý phiên đăng nhập (`auth-roles` — chỉ tham chiếu khi phiên hết hạn).
- Ghi nhật ký nghiệp vụ (`audit-log`).
- Đồng bộ đa máy chủ, đa khách sạn.

## 4. User Needs

| ID | User | Context / Trigger | User Need | Expected Outcome | Importance | Evidence |
|----|------|-------------------|-----------|------------------|------------|----------|
| UN-001 | Mọi vai trò | Vừa thay đổi trạng thái trên máy mình | Thiết bị khác thấy cập nhật ngay không cần tải lại tay | Hiển thị trên thiết bị khác ≤3 giây | Critical | Confirmed (PRD: ≤3s) |
| UN-002 | Mọi vai trò | Đang xem màn hình bất kỳ | Tin rằng dữ liệu đang xem là mới nhất | Mọi thiết bị hiển thị cùng một trạng thái | Critical | Confirmed (PRD: "một nguồn sự thật") |
| UN-003 | Người thao tác | Hai người sửa cùng đối tượng | Không bị mất thay đổi lặng lẽ | Người ghi sau bị từ chối + được báo + tải bản mới | Critical | Confirmed (PRD: kiểm tra phiên bản) |
| UN-004 | Nhân viên hiện trường | Mất mạng giữa ca | Biết rõ đang offline và thao tác ghi bị khóa | Banner rõ ràng + mọi ghi đều báo "chưa được lưu" | Critical | Confirmed (PRD: báo trạng thái + khóa ghi) |
| UN-005 | Nhân viên hiện trường | Có mạng trở lại | Không phải đăng nhập lại hay tải tay | Tự kết nối lại + dữ liệu tự cập nhật + mở khóa ghi | Critical | Confirmed (PRD: kết nối lại → tải trạng thái mới) |
| UN-006 | Người vận hành | Nghiệm thu/giám sát | Đo được độ trễ đồng bộ | Có số liệu lượt đạt/chậm để đối chiếu tiêu chí 95% | High | Confirmed (tiêu chí nghiệm thu PRD) |

## 5. Prioritized User Journeys

### Journey 1: Cập nhật lan realtime tới đồng nghiệp

- **User:** Nhân viên buồng phòng–bảo trì + lễ tân/quản lý
- **Importance:** Critical
- **Trigger:** Một thao tác ghi thành công (vd báo xong việc phòng 305 — sự kiện thuộc `maintenance`)
- **Expected outcome:** Mọi thiết bị khác thấy trạng thái mới trong ≤3 giây
- **Related needs:** UN-001, UN-002

1) Nhân viên báo xong trên mobile → máy chủ lưu thành công.
2) Máy chủ phát cập nhật → màn lễ tân + dashboard quản lý hiển thị trạng thái mới ≤3s.
3) Lễ tân nhìn thấy phòng đã mở lại và nhận khách.

**Independent verification:** Đo 100 lượt cập nhật giữa 2 thiết bị — ≥95% ≤3 giây (tiêu chí nghiệm thu).

### Journey 2: Hai người sửa cùng lúc — không ghi đè

- **User:** Hai vai trò bất kỳ thao tác đồng thời
- **Importance:** Critical
- **Trigger:** Hai thiết bị ghi cùng một đối tượng gần như đồng thời
- **Expected outcome:** Ghi đầu thắng; ghi sau bị từ chối, được báo và tải bản mới
- **Related needs:** UN-003

1) A và B cùng mở đối tượng ở phiên bản n.
2) A ghi trước → lưu, phiên bản n+1, phát cập nhật.
3) B ghi với phiên bản n → bị từ chối, báo "dữ liệu vừa được người khác cập nhật", tự tải bản mới.

**Independent verification:** Kịch bản xung đột trong kiểm thử — 0 ca ghi đè; người sau luôn thấy bản mới.

### Journey 3: Mất mạng giữa ca → kết nối lại

- **User:** Nhân viên buồng phòng–bảo trì
- **Importance:** Critical
- **Trigger:** Wifi hiện trường mất
- **Expected outcome:** Được báo rõ, không mất thao tác lặng lẽ, tự đồng bộ khi có mạng lại
- **Related needs:** UN-004, UN-005

1) Thiết bị mất kết nối → banner "Mất kết nối — đang thử kết nối lại…", ghi bị khóa.
2) Nhân viên chạm thao tác ghi → báo "chưa được lưu".
3) Có mạng → tự kết nối lại, tải trạng thái mới, mở khóa ghi, báo "dữ liệu đã cập nhật".

**Independent verification:** Kiểm thử tắt/bật mạng — 100% thời điểm offline có banner + khóa ghi; 100% lần reconnect tự tải trạng thái mới.

## 6. User Exceptions & Edge Conditions

| Situation | User Impact | Expected User-facing Outcome | Related Journey / Need |
|-----------|-------------|------------------------------|------------------------|
| Mất mạng ngay sau khi bấm lưu | Không biết thao tác đã lưu chưa | Khi kết nối lại, trạng thái mới tải về cho thấy kết quả thật; không tự giả định | J3, UN-004 |
| Offline kéo dài (hết ca) | Bỏ lỡ nhiều cập nhật | Mở lại vẫn thấy trạng thái mới nhất (tải lại toàn bộ), không cần theo từng sự kiện cũ | J3 |
| Bị từ chối ghi đè | Thao tác vừa nhập không được lưu | Được báo rõ lý do + bản mới đã tải sẵn để thao tác lại | J2, UN-003 |
| Sự kiện đến trễ >3s do mạng | Thấy cập nhật chậm | Vẫn hiển thị đúng khi đến; lượt chậm được ghi nhận khi đo | J1 |
| Phiên hết hạn trong lúc offline | Kết nối lại không ghi được | Được chuyển đăng nhập lại với thông báo rõ | J3, UN-005 |
| Nhận sự kiện của màn hình không đang xem | Không liên quan trực tiếp | Không làm phiền; dữ liệu vẫn mới khi quay lại màn đó | J1 |

## 7. User-side Constraints

- Ngôn ngữ: thông báo tiếng Việt.
- Kênh/thiết bị: Flutter Web + Android; áp dụng đồng nhất cho cả hai.
- Quy mô: 50 phòng, tối đa 30 phiên đồng thời (tôn chỉ) — không thiết kế cho tải lớn hơn.
- Điều kiện sử dụng: phải đăng nhập; mất kết nối chỉ được xem, không được ghi.
- Chỉ có một máy chủ là nguồn sự thật (MVP).

## 8. Assumptions & Validation

| Assumption | Impact if Wrong | Validation Status | Next Action |
|------------|-----------------|-------------------|-------------|
| 30 phiên đồng thời là tải đỉnh | Nếu nhiều hơn → độ trễ và ổn định phải đo lại | Confirmed theo tôn chỉ | Đo trong nghiệm thu đúng quy mô |
| Mất mạng vẫn cho xem dữ liệu cuối (chỉ khóa ghi) | Nếu phải chặn luôn xem → UX đổi | Assumption hợp lý — chưa chốt | Xác nhận khi demo |
| Tải lại trạng thái khi kết nối lại đủ bù sự kiện lỡ (không cần hàng đợi sự kiện) | Nếu thiếu → trạng thái hiển thị sai sót | Assumption đơn giản nhất đảm bảo đúng | Kiểm chứng kiểm thử J3 |
| Kênh realtime của stack chọn (Socket.IO theo tôn chỉ) đạt ≤3s ở quy mô này | Nếu không → phải đổi cơ chế | Assumption theo tôn chỉ | Mốc kiểm chứng sprint 1 |

## 9. User Success Criteria

| ID | User Outcome | Baseline | Target | Measurement | Review Period |
|----|--------------|----------|--------|-------------|---------------|
| USC-001 | Thiết bị khác thấy cập nhật kịp thời | Chưa có | ≥95% trong 100 lượt ≤3 giây (50 phòng, 30 phiên) | Đo theo tiêu chí nghiệm thu PRD | Nghiệm thu |
| USC-002 | Không ghi đè lặng lẽ | Chưa có | 0 ca ghi đè do xung đột | Kịch bản xung đột trong kiểm thử | Nghiệm thu |
| USC-003 | Người dùng biết rõ khi mất kết nối | Chưa có | 100% thời điểm offline hiển thị cảnh báo + khóa ghi | Kiểm thử tắt/bật mạng | Sprint 1–4 |
| USC-004 | Tự đồng bộ khi có mạng lại | Chưa có | 100% lần reconnect tự tải trạng thái mới, không đăng nhập lại (phiên còn hạn) | Kiểm thử tắt/bật mạng | Sprint 1–4 |

## 10. Open Questions

- [ ] OQ-1: Thiết bị báo "mất kết nối" sau tối đa bao lâu kể từ khi mất liên lạc máy chủ?
- [ ] OQ-2: Người bị từ chối ghi đè có cần giữ nội dung vừa nhập để nhập lại không?
- [ ] OQ-3: "Tải trạng thái mới" khi kết nối lại là toàn bộ hay chỉ phần đã đổi?
