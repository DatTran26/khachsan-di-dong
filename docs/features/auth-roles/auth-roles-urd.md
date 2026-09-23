---
type: urd
feature: auth-roles
status: draft
updated: 2026-09-23
author: "@Tran Tan Dat"
links: ["docs/features/auth-roles/brainstorms/auth-roles-core.md", "docs/_shared/project-profile.md"]
---

# URD — Đăng nhập, tài khoản & phân quyền

## 1. Mục đích

Xác định nhân viên khách sạn cần truy cập hệ thống thế nào — đúng người, đúng việc, truy vết được — trước khi bàn giải pháp kỹ thuật.

## 2. Vấn đề người dùng / trải nghiệm hiện tại

Hiện tại việc cập nhật trạng thái phòng rời rạc giữa các thiết bị và ca làm việc (sổ ghi, Excel, kênh chat), không ai chịu trách nhiệm trung tâm với dữ liệu và không truy vết được ai đã sửa gì. Nhân viên không có tài khoản riêng — không cách nào phân biệt thao tác của lễ tân với buồng phòng, dẫn đến sửa nhầm và mất dữ liệu. Cần một cách đăng nhập đơn giản để mỗi thay đổi gắn đúng người.

## 3. User types & primary user

- **Primary: Nhân viên khách sạn** (lễ tân + buồng phòng–bảo trì) — đăng nhập đầu ca, làm việc cả ca, cần nhanh và đúng quyền.
- **Secondary: Quản lý khách sạn** — cấp/thu hồi tài khoản, giám sát nhật ký, không trực tiếp vận hành nhận/trả phòng.
- Ngoài phạm vi user: khách thuê phòng (không dùng hệ thống), nhân viên IT/kế toán/đối tác OTA.

## 4. Phạm vi

- **In scope (user-visible):** đăng nhập bằng SĐT + mật khẩu; đăng xuất; phiên 12h; đổi mật khẩu tự phục vụ; quản lý tạo/khóa/mở/đặt lại tài khoản; phân quyền theo 3 vai trò; mỗi người chỉ thấy/làm đúng việc của vai trò mình; nhật ký ai-làm-gì xem bởi quản lý.
- **Out of scope:** tự đăng ký tài khoản; quên mật khẩu tự phục hồi (OTP/email — quản lý reset thủ công); đăng nhập SSO/mạng xã hội; xóa cứng tài khoản; phân quyền tùy biến ngoài 3 vai trò; tài khoản cho khách.

## 5. User Needs

| ID | Nhu cầu | Ai | Priority | Vì sao |
|---|---|---|---|---|
| UN-001 | Đăng nhập nhanh bằng SĐT quen thuộc, không phải nhớ tài khoản phức tạp | Nhân viên | Critical | Đầu ca là lúc bận nhất; đăng nhập chậm = bỏ dùng hệ thống |
| UN-002 | Chỉ thấy và làm đúng việc theo vai trò mình | Nhân viên | Critical | Giảm thao tác nhầm, bảo vệ dữ liệu trung tâm |
| UN-003 | Tự đổi mật khẩu khi cần, không phải nhờ quản lý | Nhân viên | High | Tự chủ thông tin cá nhân |
| UN-004 | Quên mật khẩu có đường khôi phục rõ ràng | Nhân viên | High | Không tự phục hồi được → phải biết báo ai |
| UN-005 | Cấp tài khoản cho nhân viên mới trong vài phút | Quản lý | Critical | Nhân sự khách sạn biến động theo ca/mùa |
| UN-006 | Khóa ngay tài khoản khi nhân viên nghỉ việc/đổi vai trò | Quản lý | Critical | Chặn truy cập trái phép sau nghỉ việc |
| UN-007 | Xem ai đã làm gì, lúc nào (nhật ký) | Quản lý | High | Truy vết sai sót, đối chiếu khiếu nại |
| UN-008 | Không bị đá phiên giữa ca làm việc | Nhân viên | Medium | Phiên 12h phải phủ trọn ca; mất phiên giữa thao tác gây mất dữ liệu |

## 6. User journeys (theo ưu tiên)

### J1 — Nhân viên đăng nhập đầu ca (UN-001, UN-002, UN-008) — Critical
1. Mở app trên thiết bị quầy/cá nhân → nhập SĐT + MK.
2. Hệ thống vào thẳng màn hình đúng vai trò (lễ tân thấy sơ đồ phòng, buồng phòng thấy việc được giao).
3. Làm việc cả ca không bị đá ra; nếu hết 12h → báo hết phiên, đăng nhập lại.

### J2 — Quản lý cấp tài khoản cho nhân viên mới (UN-005) — Critical
1. Vào màn Tài khoản → "Thêm nhân viên" → nhập họ tên, SĐT, vai trò.
2. Nhận mật khẩu tạm → chuyển cho nhân viên (ngoài app).
3. Nhân viên đăng nhập lần đầu → bắt buộc đặt MK mới → vào làm việc.

### J3 — Nhân viên đổi mật khẩu (UN-003) — High
1. Vào Tài khoản → "Đổi mật khẩu" → nhập MK cũ + MK mới.
2. Thành công → tiếp tục phiên hiện tại.

### J4 — Quản lý khóa tài khoản khi nhân viên nghỉ việc (UN-006) — Critical
1. Chọn tài khoản → "Khóa" → xác nhận.
2. Nhân viên đó nếu đang đăng nhập → bị đá ra ngay.

### J5 — Nhân viên quên mật khẩu (UN-004) — High
1. Báo quản lý → quản lý "Đặt lại mật khẩu" → nhận MK tạm.
2. Đăng nhập bằng MK tạm → bắt đặt MK mới → vào làm việc.

### J6 — Quản lý xem nhật ký để truy vết (UN-007) — High
1. Vào màn Nhật ký → lọc theo người/ngày → đối chiếu thao tác.

## 7. Edge conditions

- Sai mật khẩu lặp lại → đến 5 lần bị khóa, phải nhờ quản lý mở.
- Phiên hết hạn giữa thao tác ghi → báo hết phiên, dữ liệu chưa lưu.
- Tài khoản bị khóa khi đang dùng → bị đá ra ngay giữa thao tác.
- Đăng nhập trên thiết bị mới → phiên thiết bị cũ kết thúc (1 TK 1 thiết bị).
- Nhân viên dùng máy chung ở quầy → phải đăng xuất hết ca, tránh người sau thao tác dưới tên người trước.
- Mất mạng khi đăng nhập/đổi MK → báo mất kết nối, thử lại khi có mạng.

## 8. Constraints & Assumptions

- Constraints: toàn bộ tiếng Việt; chạy web + mobile (Flutter); 30 phiên đồng thời; máy chung tại quầy là tình huống phổ biến; mọi quyết định quyền ở phía server (tôn chỉ).
- Assumptions: SĐT chỉ là định danh, không OTP; MK tạm dùng 1 lần, không hết hạn; buồng phòng–bảo trì là 1 vai trò gộp trong MVP.

## 9. User Success Criteria

| ID | Tiêu chí | Cách đo | Baseline → Target | Deadline |
|---|---|---|---|---|
| USC-001 | Nhân viên đăng nhập thành công nhanh | Thời gian từ mở app đến màn chính | Chưa có hệ thống → ≤30 giây (người đã quen) | Cuối pilot Sprint 2 |
| USC-002 | Không thao tác vượt quyền | Bộ kịch bản kiểm thử phân quyền | — → 100% pass, 0 vượt quyền | Trước demo Sprint 1 |
| USC-003 | Quản lý cấp tài khoản nhanh | Thời gian từ yêu cầu đến TK sẵn sàng | Thủ công rời rạc → ≤2 phút | Cuối Sprint 1 |
| USC-004 | Mọi thao tác ghi gắn đúng người | Đối chiếu nhật ký với thao tác thực tế | Không truy vết được → 100% | Liên tục |

## 10. Open Questions

| OQ | Câu hỏi | Liên quan | Owner / Deadline |
|---|---|---|---|
| OQ-1 | Khi nào cần tách vai trò buồng phòng vs bảo trì? | UN-002 | ✅ Resolved 2026-09-17: giữ 1 vai trò gộp trong MVP (project-profile chốt 15/09); đánh giá lại post-MVP |
| OQ-2 | "Việc được giao" của buồng phòng–bảo trì xác định theo khu vực/tầng hay theo giao việc tường minh? | J1, UN-002 | ✅ Resolved 2026-09-17: giao tường minh tới cá nhân, không theo khu vực (housekeeping tự giao; maintenance tự nhận) |

