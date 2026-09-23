---
type: srs-spec
feature: realtime-sync
status: draft
updated: 2026-09-23
links:
  - "[[docs/features/realtime-sync/realtime-sync-prd.md|Realtime-sync PRD]]"
  - "[[docs/features/realtime-sync/realtime-sync-brd.md|Realtime-sync BRD]]"
---

# realtime-sync — System Requirements Specification (Tier 1)

## 1. Scope

### In Scope

- Lưu thay đổi trạng thái tại máy chủ trước, chỉ phát sự kiện sau khi lưu thành công.
- Phát cập nhật tới mọi thiết bị đang kết nối; hiển thị trong ≤3 giây.
- Kiểm tra phiên bản trước khi ghi; từ chối ghi dựa trên phiên bản cũ; báo + tải bản mới cho người bị từ chối.
- Phát hiện mất kết nối → hiển thị cảnh báo + khóa ghi (vẫn xem dữ liệu cuối).
- Tự kết nối lại khi có mạng → tải trạng thái mới từ máy chủ → mở khóa ghi.
- Chỉ báo trạng thái kết nối thống nhất trên mọi màn hình; đo độ trễ phục vụ nghiệm thu.

### Out of Scope

- Hàng đợi offline cho ghi; đồng bộ soạn dở; retry thông minh.
- Nghiệp vụ sinh sự kiện (`check-in-out`, `housekeeping`, `maintenance`, `room-dashboard`, `audit-log`).
- Quản lý phiên/xác thực (`auth-roles`); đồng bộ đa máy chủ/đa khách sạn.

## 2. Actors & Stakeholders

| Actor | Type | Responsibility |
|-------|------|----------------|
| Thiết bị người dùng (web/mobile) | primary | Ghi kèm phiên bản; nhận sự kiện; phát hiện và báo mất kết nối; tải lại khi kết nối lại |
| Máy chủ | system | Kiểm quyền + phiên bản; lưu; tăng phiên bản; phát sự kiện; cung cấp trạng thái mới khi được tải lại |
| Mọi vai trò (lễ tân, nv buồng phòng–bảo trì, quản lý) | secondary | Thụ hưởng cập nhật realtime; được báo khi offline/xung đột |
| Người vận hành (WPCTeam) | secondary | Đo độ trễ phục vụ nghiệm thu |

## 3. Functional Requirements

| ID | Requirement | Actor | Priority |
|----|-------------|-------|----------|
| FR-realtime-sync-001 | Mọi thay đổi trạng thái phải được máy chủ lưu thành công trước khi phát sự kiện cập nhật tới các thiết bị đang kết nối | Máy chủ | Must |
| FR-realtime-sync-002 | Sự kiện cập nhật mang trạng thái mới của đối tượng; thiết bị nhận được áp dụng và hiển thị trong ≤3 giây kể từ lúc máy chủ lưu | Thiết bị | Must |
| FR-realtime-sync-003 | Mọi thao tác ghi phải kèm phiên bản hiện tại của đối tượng; phiên bản không khớp máy chủ → từ chối ghi, không ghi đè | Máy chủ | Must |
| FR-realtime-sync-004 | Khi ghi bị từ chối do phiên bản cũ → báo cho thiết bị ghi "dữ liệu vừa được người khác cập nhật" và tải lại trạng thái mới | Máy chủ/Thiết bị | Must |
| FR-realtime-sync-005 | Thiết bị phát hiện mất liên lạc máy chủ → hiển thị cảnh báo "mất kết nối" trong ngưỡng OQ-1 và khóa mọi thao tác ghi (vẫn cho xem dữ liệu cuối) | Thiết bị | Must |
| FR-realtime-sync-006 | Khi có mạng trở lại, thiết bị tự kết nối lại (không yêu cầu đăng nhập lại nếu phiên còn hạn) → tải trạng thái mới từ máy chủ → mở khóa ghi | Thiết bị | Must |
| FR-realtime-sync-007 | Chỉ báo trạng thái kết nối hiển thị thống nhất (banner) trên mọi màn hình của cả Web và Android | Thiết bị | Should (P1) |
| FR-realtime-sync-008 | Ghi nhận độ trễ từng lượt phát sự kiện để đối chiếu tiêu chí nghiệm thu ≥95% ≤3s | Hệ thống | Should (P1) |
| FR-realtime-sync-009 | Thiết bị nhận sự kiện cho đối tượng không đang hiển thị → cập nhật dữ liệu nền, không làm phiền màn hình hiện tại | Thiết bị | Should |
| FR-realtime-sync-010 | Kết nối lại khi phiên đã hết hạn → chuyển luồng đăng nhập lại (theo `auth-roles`), không tự ghi | Thiết bị | Must |

## 4. Non-Functional Requirements

| Category | Requirement | Target |
|----------|-------------|--------|
| Performance | Độ trễ máy chủ lưu → thiết bị khác hiển thị | ≤3 giây, ≥95% trong 100 lượt (50 phòng, 30 phiên đồng thời) |
| Reliability | Ca ghi đè do xung đột phiên bản | 0 |
| Availability | Thời điểm offline được báo + khóa ghi | 100% |
| Consistency | Thiết bị chỉ áp dụng sự kiện do máy chủ phát; không tự đổi trạng thái khi chưa được xác nhận | Bắt buộc |
| Usability | Cảnh báo kết nối/thông báo xung đột bằng tiếng Việt, thống nhất mọi màn | Bắt buộc |
| Scalability | Đáp ứng quy mô chốt: 50 phòng, 30 phiên đồng thời | Không thiết kế quá mức |

## 5. Business Rules (system enforced)

| ID | Rule | Enforcement |
|----|------|-------------|
| BR-realtime-sync-01 | Lưu trước — phát sau; không phát sự kiện khi chưa lưu thành công | Thứ tự bắt buộc tại máy chủ |
| BR-realtime-sync-02 | Ghi kèm phiên bản; không khớp → từ chối | Kiểm tra tại máy chủ mọi lần ghi |
| BR-realtime-sync-03 | Mất kết nối → chỉ đọc, cấm ghi | Khóa tại thiết bị |
| BR-realtime-sync-04 | Kết nối lại → tải trạng thái mới trước khi mở khóa ghi | Thứ tự bắt buộc tại thiết bị |
| BR-realtime-sync-05 | Chỉ máy chủ phát sự kiện; thiết bị không tự coi thay đổi cục bộ là đã đồng bộ | Một nguồn sự thật |

## 6. Error Matrix

| ID | Trigger | User Message | System Action |
|------|---------|--------------|---------------|
| E-realtime-sync-001 | Ghi khi mất kết nối | "Mất kết nối — thao tác chưa được lưu. Thử lại khi có mạng." | Khóa ghi, giữ dữ liệu cuối để xem |
| E-realtime-sync-002 | Ghi với phiên bản cũ | "Dữ liệu vừa được người khác cập nhật — đã tải lại bản mới nhất." | Từ chối ghi + tải trạng thái mới |
| E-realtime-sync-003 | Kết nối lại nhưng phiên hết hạn | "Phiên đăng nhập đã hết — vui lòng đăng nhập lại." | Chuyển luồng đăng nhập (`auth-roles`) |
| E-realtime-sync-004 | Sự kiện áp dụng thất bại trên thiết bị | (không hiển thị) | Tải lại trạng thái mới từ máy chủ |

## 7. Success Criteria (system level)

| ID | Criterion | Target |
|----|-----------|--------|
| SC-realtime-sync-01 | Lượt cập nhật hiển thị trên thiết bị khác ≤3 giây | ≥95% trong 100 lượt (50 phòng, 30 phiên) |
| SC-realtime-sync-02 | Ca ghi đè do xung đột phiên bản | 0 |
| SC-realtime-sync-03 | Thời điểm offline có cảnh báo + khóa ghi | 100% |
| SC-realtime-sync-04 | Lần reconnect tự tải trạng thái mới, không đăng nhập lại (phiên còn hạn) | 100% |

## 8. Data Entities (high-level)

| Entity | Key Attributes | Relationships |
|--------|----------------|---------------|
| Kết nối thiết bị | id phiên kết nối, người dùng, trạng thái (trực tuyến/mất kết nối), mốc liên lạc cuối | thuộc 1 phiên đăng nhập |
| Sự kiện cập nhật | id, đối tượng, trạng thái mới, phiên bản mới, mốc phát | phát sinh sau mỗi lưu thành công |
| Phiên bản đối tượng | đối tượng, số phiên bản (chỉ tăng) | gắn với phòng/việc do feature nghiệp vụ sở hữu |
| Trạng thái đối tượng | đối tượng, trạng thái hiện tại | nguồn sự thật tại máy chủ |

## 9. Flows (summary — chi tiết ở Tầng 2)

| Flow | Trigger | Outcome |
|------|---------|---------|
| FL-01 Lan truyền cập nhật | Lưu thành công | Thiết bị khác hiển thị mới ≤3s |
| FL-02 Xung đột phiên bản | Hai ghi cùng đối tượng | Ghi sau bị từ chối + tải bản mới |
| FL-03 Mất kết nối | Mất liên lạc máy chủ | Cảnh báo + khóa ghi, chỉ đọc |
| FL-04 Kết nối lại | Có mạng trở lại | Tự reconnect + tải mới + mở khóa ghi |

## 10. Screens (summary — chi tiết ở Tầng 4)

| Screen | Actor | Purpose |
|--------|-------|---------|
| Chỉ báo trạng thái kết nối (banner) | Mọi vai trò | Hiển thị "mất kết nối — đang thử lại" / "đã kết nối lại" thống nhất mọi màn |
| Thông báo xung đột phiên bản | Mọi vai trò | Báo "dữ liệu vừa được người khác cập nhật" kèm bản mới đã tải |

*Feature nền — không có màn hình nghiệp vụ riêng; các màn trạng thái phòng/việc thuộc feature tương ứng (`room-dashboard`, `maintenance`, `housekeeping`, `check-in-out`).*

## 11. Constraints

- MVP 8 tuần, nhóm 3 người; kiểm chứng ngay Sprint 1 (mốc 21/09).
- 1 khách sạn 50 phòng; 30 phiên đồng thời; dữ liệu giả lập; tiếng Việt.
- Một máy chủ duy nhất là nguồn sự thật.
- Stack theo tôn chỉ: Node.js/Express + Socket.IO (kênh realtime), Flutter Web + Android (triển khai — chi tiết Tầng 2+).

## 12. Dependencies

| Dependency | Type | Status |
|------------|------|--------|
| `auth-roles` | Feature (phiên đăng nhập, kiểm quyền trước khi ghi/phát) | Sprint 1, đã chi tiết |
| `check-in-out` | Feature (phát sự kiện nhận/trả, tiêu thụ trạng thái phòng) | Sprint 2 |
| `housekeeping` | Feature (phát sự kiện việc dọn) | Sprint 2, đã chi tiết |
| `maintenance` | Feature (phát sự kiện báo hỏng/ngừng phục vụ) | Sprint 2, đang pipeline |
| `room-dashboard` | Feature (tiêu thụ mọi sự kiện trạng thái) | Sprint 3 |
| `audit-log` | Feature (nhận ghi nhật ký cùng nhịp thay đổi) | Nhóm vận hành |

## 13. Assumptions

- Kênh realtime của stack chọn (Socket.IO theo tôn chỉ) đạt mục tiêu ở quy mô 30 phiên.
- Mất kết nối vẫn cho xem dữ liệu cuối — chỉ khóa ghi.
- Thiết bị lỡ sự kiện được bù bằng "tải trạng thái mới" khi kết nối lại — không cần hàng đợi sự kiện lưu trữ.
- Kiểm tra phiên bản áp theo đối tượng trạng thái, không khóa toàn bộ phòng.

## 14. Open Questions

- [ ] OQ-1: Thiết bị báo "mất kết nối" sau tối đa bao lâu kể từ khi mất liên lạc máy chủ?
- [ ] OQ-2: Người bị từ chối ghi đè có cần giữ nội dung vừa nhập để nhập lại không?
- [ ] OQ-3: "Tải trạng thái mới" khi kết nối lại là toàn bộ hay chỉ phần đã đổi?
