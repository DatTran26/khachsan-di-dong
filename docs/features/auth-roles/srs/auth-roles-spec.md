---
type: srs-spec
feature: auth-roles
status: draft
updated: 2026-09-17
author: "@Tran Tan Dat"
links: ["docs/features/auth-roles/auth-roles-prd.md"]
---

# SRS — Đăng nhập, tài khoản & phân quyền

## 1. Mục đích & phạm vi

### Phạm vi

- **In scope:** xác thực (đăng nhập/đăng xuất bằng SĐT+MK); quản lý phiên (12h, 1 TK 1 thiết bị); quản lý tài khoản bởi quản lý (tạo/sửa/khóa/mở/đặt lại MK); đổi MK self-service + bắt đổi MK tạm; phân quyền RBAC 3 vai trò thực thi server-side cho mọi thao tác ghi; nhật ký audit phía server; màn xem nhật ký cho quản lý.
- **Out of scope:** self-register, OTP/SSO, xóa cứng tài khoản, phân quyền tùy biến, tách vai trò buồng phòng/bảo trì (OQ-2 resolved — giữ 1 vai trò gộp MVP), tài khoản khách.

### Actors

- **Quản lý** — quản lý tài khoản, xem nhật ký, giám sát; KHÔNG nhận/trả phòng.
- **Lễ tân** — nhận/trả phòng, xem trạng thái + dashboard.
- **Nhân viên buồng phòng–bảo trì** — xem việc được giao tường minh tới cá nhân (OQ-3 resolved), cập nhật vệ sinh/bảo trì.
- **Hệ thống** — lockout tự động, hủy phiên, ghi nhật ký.

## 2. Functional Requirements

| ID | Mô tả | Priority | Trace |
|---|---|---|---|
| FR-auth-roles-001 | Khi nhân viên gửi SĐT + mật khẩu hợp lệ và tài khoản ở trạng thái Hoạt động, hệ thống xác thực và tạo phiên đăng nhập 12 giờ | P0 | CAP-auth-roles-01 |
| FR-auth-roles-002 | Khi nhân viên chọn đăng xuất, hệ thống hủy phiên hiện tại và đưa về màn đăng nhập | P0 | CAP-auth-roles-01 |
| FR-auth-roles-003 | Khi phiên đạt 12 giờ, hệ thống hủy phiên; thao tác tiếp theo bị từ chối và yêu cầu đăng nhập lại | P0 | CAP-auth-roles-02 |
| FR-auth-roles-004 | Với mọi thao tác thay đổi dữ liệu, hệ thống kiểm tra quyền theo vai trò tại máy chủ trước khi thực hiện; vai trò không có quyền → từ chối | P0 | CAP-auth-roles-03, BR-auth-roles-001/002/003 |
| FR-auth-roles-005 | Khi quản lý tạo tài khoản (họ tên, SĐT, vai trò) và SĐT chưa tồn tại, hệ thống sinh mật khẩu tạm, đặt trạng thái "Chờ kích hoạt" và hiển thị MK tạm một lần | P0 | CAP-auth-roles-04 |
| FR-auth-roles-006 | Khi nhân viên đăng nhập bằng MK tạm, hệ thống bắt buộc đặt mật khẩu mới trước khi vào chức năng nào khác; sau khi đổi, TK chuyển "Hoạt động" | P0 | CAP-auth-roles-05 |
| FR-auth-roles-007 | Khi nhân viên đổi MK (nhập đúng MK cũ + MK mới đạt rule), hệ thống cập nhật MK và giữ phiên hiện tại | P0 | CAP-auth-roles-05 |
| FR-auth-roles-008 | Khi quản lý đặt lại MK của một TK, hệ thống sinh MK tạm mới và đặt TK về "Chờ kích hoạt" | P0 | CAP-auth-roles-04 |
| FR-auth-roles-009 | Khi quản lý khóa một TK (không phải QL cuối cùng), hệ thống chuyển TK sang "Bị khóa" và hủy ngay mọi phiên đang mở của TK đó | P0 | CAP-auth-roles-04 |
| FR-auth-roles-010 | Khi quản lý mở khóa một TK, hệ thống sinh MK tạm mới, đặt TK về "Chờ kích hoạt" và đếm sai MK về 0 | P0 | CAP-auth-roles-04 |
| FR-auth-roles-011 | Nếu nhập sai MK 5 lần liên tiếp trên cùng một TK, hệ thống tự động chuyển TK sang "Bị khóa" và ghi nhật ký | P0 | CAP-auth-roles-06, BR-auth-roles-004 |
| FR-auth-roles-012 | Khi một TK đăng nhập thành công trên thiết bị mới, hệ thống hủy mọi phiên cũ của TK đó (1 TK 1 thiết bị) | P0 | CAP-auth-roles-02, BR-auth-roles-007 |
| FR-auth-roles-013 | Hệ thống ghi nhật ký phía máy chủ cho mọi thay đổi dữ liệu và sự kiện auth (đăng nhập/đăng xuất/hết phiên/khóa/mở/đổi MK), mỗi dòng gồm: người thực hiện, vai trò, hành động, đối tượng, thời điểm | P0 | CAP-auth-roles-07 |
| FR-auth-roles-014 | Quản lý xem và lọc nhật ký theo người thực hiện, ngày, loại hành động | P1 | CAP-auth-roles-08 |
| FR-auth-roles-015 | Hệ thống kiểm tra SĐT theo định dạng di động VN (10 số, bắt đầu bằng 0) và MK mới tối thiểu 8 ký tự gồm cả chữ và số; không đạt → từ chối với wording lỗi tương ứng | P0 | CAP-auth-roles-01, CAP-auth-roles-05 |
| FR-auth-roles-016 | Hệ thống từ chối khóa hoặc đổi vai trò khi tài khoản đích là tài khoản quản lý cuối cùng còn hoạt động | P0 | CAP-auth-roles-04, BR-auth-roles-006 |
| FR-auth-roles-017 | Tài khoản không bao giờ bị xóa khỏi hệ thống — thao tác xóa không tồn tại; mọi "thu hồi" quyền thực hiện qua khóa | P0 | BR-auth-roles-005 |
| FR-auth-roles-018 | Mọi thông báo lỗi/thành công/thông tin hiển thị tiếng Việt theo wording đã chốt trong brainstorm mục 7.2 | P0 | — |

### Trạng thái tài khoản (tham chiếu FR-auth-roles-005..011)

- `Chờ kích hoạt` — TK mới tạo/vừa reset/vừa mở khóa, đang giữ MK tạm; đăng nhập được nhưng bắt đổi MK.
- `Hoạt động` — dùng bình thường.
- `Bị khóa` — không đăng nhập; phiên đang mở bị hủy; chỉ quản lý mở.
- Không có trạng thái "đã xóa".

## 3. Non-Functional Requirements

| ID | Mô tả | Trace / nguồn |
|---|---|---|
| NFR-auth-roles-001 | Mật khẩu lưu dạng băm; không log, không hiển thị giá trị MK (kể cả MK tạm chỉ hiển thị một lần cho quản lý) | Tôn chỉ (hash MK), CAP-auth-roles-04 |
| NFR-auth-roles-002 | Toàn bộ giao tiếp qua HTTPS | Tôn chỉ |
| NFR-auth-roles-003 | Quyết định phân quyền chỉ thực thi ở máy chủ; client chỉ hiển thị theo vai trò | Tôn chỉ, CAP-auth-roles-03 |
| NFR-auth-roles-004 | Đăng nhập phản hồi ≤3 giây trên mạng thử nghiệm | Suy từ tiêu chí tôn chỉ (95% cập nhật ≤3s) — xem OQ-1 |
| NFR-auth-roles-005 | Hỗ trợ ≥10 phiên đăng nhập đồng thời hoạt động bình thường | Tôn chỉ (tiêu chí nghiệm thu) |
| NFR-auth-roles-006 | Mất kết nối → ứng dụng báo trạng thái và khóa thao tác ghi; có mạng lại → cho thử lại, không tự lưu bù | Tôn chỉ |
| NFR-auth-roles-007 | Nhật ký hoạt động giữ toàn bộ thời gian MVP, không tự xóa | Đã chốt brainstorm |
| NFR-auth-roles-008 | Toàn bộ giao diện và thông báo tiếng Việt | Tôn chỉ |

## 4. Business Rules

| ID | Quy tắc | Implements |
|---|---|---|
| BR-auth-roles-001 | Chỉ quản lý được quản lý tài khoản | FR-auth-roles-005/008/009/010/016 |
| BR-auth-roles-002 | Chỉ lễ tân được nhận/trả phòng | FR-auth-roles-004 |
| BR-auth-roles-003 | Buồng phòng–bảo trì chỉ cập nhật vệ sinh/bảo trì trong việc được giao tường minh tới cá nhân (không theo khu vực/tầng) | FR-auth-roles-004 |
| BR-auth-roles-004 | Sai MK 5 lần liên tiếp → khóa, chỉ quản lý mở | FR-auth-roles-011 |
| BR-auth-roles-005 | Tài khoản không xóa cứng — chỉ khóa/mở | FR-auth-roles-017 |
| BR-auth-roles-006 | Không khóa/đổi vai trò QL cuối cùng | FR-auth-roles-016 |
| BR-auth-roles-007 | 1 TK 1 phiên thiết bị; phiên ≤12 giờ | FR-auth-roles-003/012 |

Ma trận vai trò × hành động đầy đủ: xem brainstorm mục 6.2 (bảng kịch bản).

## 5. Error Matrix

| ID | Lỗi | Severity | Phát hiện | Người dùng làm gì | Recovery | Cần xử lý? |
|---|---|---|---|---|---|---|
| E-auth-roles-001 | Sai SĐT hoặc MK | major | Tại màn đăng nhập khi submit | Nhập lại | +1 đếm sai; đến 5 → khóa TK | Có — wording E-01 mục 7.2 brainstorm |
| E-auth-roles-002 | TK đang Bị khóa khi đăng nhập | major | Sau khi xác thực đúng MK | Liên hệ quản lý | QL mở khóa → MK tạm → đổi MK | Có |
| E-auth-roles-003 | Phiên hết hạn | minor | Thao tác bất kỳ sau 12h | Đăng nhập lại | Về màn login, giữ nguyên dữ liệu server | Có |
| E-auth-roles-004 | Đăng nhập bằng MK tạm | info | Sau xác thực | Đặt MK mới | Chuyển màn đổi MK bắt buộc | Có |
| E-auth-roles-005 | MK mới không đạt rule | minor | Form đổi MK | Nhập MK khác | Ở lại form, giữ giá trị đã nhập (trừ MK) | Có |
| E-auth-roles-006 | SĐT đã tồn tại khi tạo TK | major | Form tạo TK | Sửa SĐT | Ở lại form | Có |
| E-auth-roles-007 | Thao tác không đủ quyền | major | Mọi thao tác ghi | Không thực hiện được | Từ chối phía server + thông báo | Có |
| E-auth-roles-008 | Mất kết nối khi ghi | major | Submit thất bại | Thử lại khi có mạng | Không lưu; hiển thị trạng thái offline | Có |
| E-auth-roles-009 | TK bị khóa khi đang dùng | critical | Realtime khi QL khóa | Đăng nhập lại sau khi được mở | Hủy phiên ngay, về màn login | Có |
| E-auth-roles-010 | Khóa/đổi vai trò QL cuối cùng | major | Form quản lý TK | Hủy thao tác | Từ chối + giải thích | Có |
| E-auth-roles-011 | Phiên bị hủy do đăng nhập nơi khác | minor | Thiết bị cũ khi TK đăng nhập mới | Đăng nhập lại nếu là chủ TK | Về màn login + thông báo | Có |

## 6. Success Criteria

| ID | Tiêu chí | Đo bằng |
|---|---|---|
| SC-auth-roles-01 | 100% thao tác ghi dữ liệu có định danh người thực hiện + vai trò trong nhật ký | Đối chiếu nhật ký vs thao tác mẫu trong test |
| SC-auth-roles-02 | 0 thao tác vượt quyền — 100% kịch bản phân quyền trong bộ test pass | Test suite RBAC (3 vai trò × các hành động) |
| SC-auth-roles-03 | TK mới sẵn sàng cho nhân viên ≤2 phút từ khi quản lý bắt đầu | Đo thủ công trên kịch bản pilot |
| SC-auth-roles-04 | Nhân viên quen đăng nhập thành công ≤30 giây | Đo thủ công pilot |
| SC-auth-roles-05 | Khóa TK có hiệu lực ngay: phiên đang mở bị hủy trong ≤3 giây | Test realtime |

## 7. Entities (tóm tắt)

- **Tài khoản nhân viên**: SĐT (định danh, duy nhất), họ tên, vai trò, trạng thái (Chờ kích hoạt/Hoạt động/Bị khóa), MK đã băm, cờ MK tạm, đếm sai MK.
- **Phiên đăng nhập**: thuộc TK, thiết bị, thời điểm tạo, hết hạn (12h). Tối đa 1 phiên/TK.
- **Nhật ký hoạt động**: người thực hiện, vai trò, hành động, đối tượng, thời điểm, giá trị trước/sau (khi phù hợp). Không ghi giá trị MK.

## 8. Constraints & Assumptions

- Constraints: HTTPS + băm MK + phân quyền server-side + nhật ký máy chủ (ràng buộc tôn chỉ); Flutter web + Android; ~10 phiên đồng thời; tiếng Việt; 1 khách sạn ~50 phòng.
- Assumptions: SĐT không OTP; MK tạm không hết hạn, dùng 1 lần; đổi MK giữ phiên; MK tạm truyền tay ngoài app.
- Dependencies (business): danh sách vai trò/quyền đã chốt trong brainstorm; hạ tầng VPS/DB sẵn đầu Sprint 1 (team WPCTeam).

## 9. Open Questions

| ID | Câu hỏi | Owner | Deadline |
|---|---|---|---|
| OQ-1 | Ngưỡng hiệu năng chính thức cho đăng nhập (NFR-auth-roles-004 đang suy từ tiêu chí realtime ≤3s)? | Điều phối viên | Trước test Sprint 1 |
| OQ-2 | Tách vai trò buồng phòng vs bảo trì? | ✅ Resolved 2026-09-17 — giữ 1 vai trò gộp MVP (project-profile 15/09) | Đánh giá lại post-MVP |
| OQ-3 | "Việc được giao" xác định theo khu vực hay giao tường minh? | ✅ Resolved 2026-09-17 — giao tường minh tới cá nhân, không theo khu vực (housekeeping: hệ thống tự giao; maintenance: tự nhận) | — |

