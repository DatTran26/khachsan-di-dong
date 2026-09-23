---
type: srs-spec
feature: check-in-out
status: draft
updated: 2026-09-23
links:
  - "[[docs/features/check-in-out/check-in-out-prd.md|PRD — Check-in-out]]"
  - "[[docs/features/check-in-out/check-in-out-brd.md|BRD — Check-in-out]]"
  - "[[docs/features/check-in-out/check-in-out-urd.md|URD — Check-in-out]]"
---

# SRS — Check-in-out (Tầng 1 — Core Spec)

## 1. Purpose & Scope

Đặc tả lõi cho `check-in-out`: nhận phòng chỉ khi sẵn sàng (trống + sạch + bình thường), trả phòng đưa phòng về trống + cần dọn và phát sự kiện cho `housekeeping`. Chỉ Tầng 1 — không use case chi tiết, luồng màn hình, ERD, sơ đồ trạng thái, wireframe, user story, tiêu chí nghiệm thu mở rộng.

## 2. Actors

| Actor | Loại | Quyền trong feature |
|---|---|---|
| Lễ tân | Người | Nhận phòng, trả phòng, hủy nhận phòng (P1), xem danh sách đang ở |
| Quản lý | Người | Xem danh sách đang ở + nhật ký lượt lưu trú; KHÔNG nhận/trả |
| Nhân viên buồng–bảo trì | Người | Downstream — thấy việc dọn sau trả phòng (qua `housekeeping`) |
| Hệ thống | Tự động | Kiểm tra điều kiện; tạo/đóng/hủy lượt lưu trú; đổi trục lưu trú + vệ sinh khi trả; phát sự kiện; nhật ký; realtime |

## 3. Functional Requirements

| ID | FR | Actor | P | Trace |
|---|---|---|---|---|
| FR-check-in-out-001 | Nhận phòng: kiểm tra LẠI 3 điều kiện (lưu trú=trống, vệ sinh=sạch, bảo trì=bình thường) tại thời điểm ghi; không thỏa → chặn kèm lý do cụ thể theo trục vi phạm | Lễ tân | P0 | CAP-check-in-out-01, BREQ-01/02 |
| FR-check-in-out-002 | Khi nhận phòng: bắt buộc nhập thông tin khách tối thiểu — tên khách + số người (giả định OQ-1); thiếu → từ chối, chỉ rõ trường, giữ form | Lễ tân | P0 | CAP-check-in-out-02 |
| FR-check-in-out-003 | Nhận phòng thành công → tạo lượt lưu trú mở (phòng + khách + mốc nhận) → trục lưu trú = "đang ở" → nhật ký + realtime | Hệ thống | P0 | CAP-check-in-out-02, CAP-check-in-out-05 |
| FR-check-in-out-004 | Trả phòng: chỉ trên phòng "đang ở" có lượt lưu trú mở → đóng lượt (mốc trả) → lưu trú = "trống", vệ sinh = "cần dọn" → phát sự kiện trả phòng cho `housekeeping` → nhật ký + realtime | Lễ tân | P0 | CAP-check-in-out-03, BREQ-04 |
| FR-check-in-out-005 | Danh sách phòng đang ở: phòng + khách + mốc nhận; realtime; rỗng có trạng thái rỗng | Lễ tân, Quản lý | P0 | CAP-check-in-out-04 |
| FR-check-in-out-006 | Hủy nhận phòng: chỉ trong cửa sổ ngắn sau nhận + phòng chưa phát sinh hoạt động khác → lượt đánh dấu hủy, lưu trú về "trống", vệ sinh giữ trạng thái trước nhận, KHÔNG phát sự kiện trả phòng → nhật ký rõ hủy | Lễ tân | P1 | CAP-check-in-out-06 |
| FR-check-in-out-007 | Ghi chú khi nhận (≤500 ký tự) + ngày dự kiến trả tùy chọn — chỉ hiển thị, không xử lý quá hạn | Lễ tân | P1 | CAP-check-in-out-07 |
| FR-check-in-out-008 | Chặn đồng thời: kiểm tra điều kiện tại thời điểm ghi; tối đa 1 lượt lưu trú mở/phòng | Hệ thống | P0 | BREQ-05 |
| FR-check-in-out-009 | Mọi thao tác ghi kiểm tra quyền lễ tân ở máy chủ; quản lý và nhân viên không ghi được | Hệ thống | P0 | BREQ-06 |
| FR-check-in-out-010 | Mọi nhận/trả/hủy ghi nhật ký ai/khi/phòng/hành động | Hệ thống | P0 | BREQ-07 |

## 4. Non-Functional Requirements

| ID | NFR | Giá trị | Trace |
|---|---|---|---|
| NFR-check-in-out-001 | Cập nhật trạng thái hiển thị trên thiết bị khác ≤3 giây | ≥95% lượt (tôn chỉ) | BREQ-07 |
| NFR-check-in-out-002 | Kiểm tra quyền + nhật ký ở máy chủ — không tin client | Tôn chỉ | BREQ-06/07 |
| NFR-check-in-out-003 | Nhận/trả phòng 1–2 bước xác nhận — nhanh tại quầy | URD §8 | UN-01/03 |
| NFR-check-in-out-004 | 30 phiên đồng thời; đồng thời bị chặn bằng kiểm tra điều kiện khi ghi | Tôn chỉ | BREQ-05 |
| NFR-check-in-out-005 | Tiếng Việt; web cho lễ tân/quản lý | Tôn chỉ | Scope |

## 5. Business Rules

- Nhận phòng chỉ khi trống + sạch + bình thường tại thời điểm ghi — không tin trạng thái hiển thị cũ.
- Chặn nhận phòng phải nêu lý do theo trục: "đang có khách" / "chưa dọn xong ({trạng thái})" / "ngừng phục vụ".
- Trả phòng LUÔN đưa vệ sinh về "cần dọn" + phát sự kiện — bất kể tình trạng thực tế.
- Tối đa 1 lượt lưu trú mở/phòng tại mọi thời điểm.
- Hủy nhận: chỉ trong cửa sổ ngắn + chưa phát sinh hoạt động khác; không tạo việc dọn; giữ vết.
- Phòng ngừng phục vụ nhưng đang có khách: trả phòng bình thường; sau trả vẫn ngừng phục vụ.
- Quản lý không nhận/trả phòng — chỉ giám sát.
- Mọi nhận/trả/hủy ghi nhật ký ai/khi/phòng.

## 6. Error Matrix

| ID | Tình huống | Behavior | Thông báo (mẫu) |
|---|---|---|---|
| E-check-in-out-001 | Nhận phòng đang ở | Chặn + lý do | "Phòng đang có khách — không thể nhận." |
| E-check-in-out-002 | Nhận phòng chưa sạch | Chặn + lý do kèm trạng thái | "Phòng chưa dọn xong ({trạng thái}) — không thể nhận." |
| E-check-in-out-003 | Nhận phòng ngừng phục vụ | Chặn + lý do | "Phòng đang ngừng phục vụ — không thể nhận." |
| E-check-in-out-004 | Thiếu thông tin khách | Từ chối lưu, chỉ rõ trường, giữ form | "Vui lòng nhập tên khách." |
| E-check-in-out-005 | Trả phòng không đang ở | Từ chối + yêu cầu tải lại | "Thao tác không hợp lệ ở trạng thái hiện tại. Tải lại để xem trạng thái mới nhất." |
| E-check-in-out-006 | Hủy nhận quá cửa sổ / đã phát sinh hoạt động | Từ chối, hướng dẫn trả phòng | "Đã quá thời gian hủy nhận phòng — vui lòng dùng 'Trả phòng'." |
| E-check-in-out-007 | Mất mạng khi xác nhận | Thao tác chưa lưu | "Mất kết nối — thao tác chưa được lưu. Thử lại khi có mạng." |
| E-check-in-out-008 | Sai quyền (không phải lễ tân) | Từ chối thao tác | "Bạn không có quyền thực hiện thao tác này." |

## 7. Success Criteria

| ID | Tiêu chí |
|---|---|
| SC-check-in-out-001 | 100% lượt nhận vào phòng không sẵn sàng bị chặn kèm lý do đúng trục |
| SC-check-in-out-002 | 100% lượt trả phòng → vệ sinh "cần dọn" + sự kiện đến `housekeeping` |
| SC-check-in-out-003 | 0 lượt lưu trú mở đôi trên cùng phòng |
| SC-check-in-out-004 | ≥95% lượt cập nhật lan ≤3s sang thiết bị khác |
| SC-check-in-out-005 | 100% nhận/trả/hủy có nhật ký ai/khi/phòng |

## 8. Entity Summary

| Entity | Thuộc tính chính | Ghi chú |
|---|---|---|
| Lượt lưu trú | Phòng, khách (tên + số người), mốc nhận, mốc trả, trạng thái (mở/đóng/hủy), ghi chú, ngày dự kiến trả (P1) | 1 lượt mở/phòng; hủy giữ vết |
| Phòng (đọc) | Số phòng, tầng, loại + 3 trục | Đọc từ `room-catalog`; feature này chỉ đổi trục lưu trú (và vệ sinh sạch→cần dọn khi trả) |
| Nhật ký lưu trú | Ai, khi, phòng, hành động (nhận/trả/hủy) | Ghi trên mọi thao tác |

## 9. Flow Summary

- Nhận phòng: chọn phòng sẵn sàng → kiểm tra lại 3 điều kiện khi ghi → đủ thông tin khách → tạo lượt mở → lưu trú "đang ở" → nhật ký + realtime.
- Nhận bị chặn: phòng không sẵn sàng → lý do cụ thể theo trục → không đổi gì.
- Trả phòng: chọn phòng đang ở → xác nhận → đóng lượt → trống + cần dọn → phát sự kiện → `housekeeping` tạo việc.
- Hủy nhận (P1): trong cửa sổ + chưa phát sinh → đánh dấu hủy → về trống, không việc dọn.

## 10. Screen Summary

- Danh sách phòng đang ở (phòng + khách + mốc nhận) — lễ tân, quản lý.
- Form nhận phòng (tên khách + số người + ghi chú/ngày dự kiến trả P1) — lễ tân.
- Xác nhận trả phòng — lễ tân.
- Xác nhận hủy nhận phòng (P1) — lễ tân.
- Chọn phòng "sẵn sàng" để nhận — dùng chung tra cứu `room-catalog` (không nhân bản).

## 11. Constraints & Dependencies

- Phụ thuộc `room-catalog` (danh mục + 3 trục) và `auth-roles` (quyền lễ tân).
- Phát sự kiện trả phòng cho `housekeeping`; `room-dashboard` tiêu thụ trạng thái/lượt lưu trú (gồm hiển thị quá hạn).
- Ràng buộc tôn chỉ: 3 trục riêng (feature chỉ sở hữu trục lưu trú); kiểm quyền + nhật ký máy chủ; realtime ≤3s; tiếng Việt; dữ liệu giả lập; AI không quyết định nghiệp vụ.

## 12. Assumptions

- Thông tin khách tối thiểu: tên khách + số người bắt buộc (OQ-1).
- Trả phòng luôn → vệ sinh "cần dọn" + sự kiện — bất kể tình trạng thực tế.
- Hủy nhận chỉ trong cửa sổ ngắn + chưa phát sinh hoạt động khác; không việc dọn; giữ vết.
- Ngày dự kiến trả chỉ hiển thị — cảnh báo/hiển thị quá hạn thuộc `room-dashboard` (theo quy tắc, không AI).

## 13. Open Questions

- [ ] OQ-1: Thông tin khách tối thiểu khi nhận phòng?
- [ ] OQ-2: Cửa sổ hủy nhận phòng nhầm? Điều kiện "chưa phát sinh hoạt động khác"?
- [ ] OQ-3: Trả phòng có ghi chú tình trạng phòng không, hay hoàn toàn thuộc `maintenance`?
- [ ] OQ-4: Lễ tân xem được lịch sử lượt lưu trú đã đóng không, hay chỉ quản lý?
