---
type: brd
feature: auth-roles
status: draft
updated: 2026-09-17
author: "@Tran Tan Dat"
links: ["docs/features/auth-roles/auth-roles-urd.md"]
---

# BRD — Đăng nhập, tài khoản & phân quyền

## 1. Tóm tắt điều hành

Khách sạn cần một hệ thống tài khoản cá nhân có phân quyền để mọi thay đổi dữ liệu phòng gắn đúng người thực hiện và chỉ đúng vai trò mới được làm việc của vai trò đó. Đây là nền tảng Sprint 1 — không có nó, mọi feature nghiệp vụ phía sau không thể kiểm soát truy cập hay truy vết thao tác.

## 2. Vấn đề nghiệp vụ

| BP | Mô tả | Tác động |
|---|---|---|
| BP-01 | Cập nhật trạng thái phòng rời rạc giữa thiết bị/ca (sổ, Excel, chat) | Sai trạng thái phòng, mâu thuẫn giữa ca, mất thời gian đối chiếu |
| BP-02 | Không truy vết được ai đã sửa gì | Không quy trách nhiệm khi sai; khó xử lý khiếu nại |
| BP-03 | Không kiểm soát quyền — ai cũng có thể sửa mọi thứ | Rủi ro thao tác sai/vượt quyền, dữ liệu không tin cậy |

**Cơ hội / vì sao làm bây giờ:** `auth-roles` được xếp Sprint 1 (08/09–21/09) — là nền cho mọi feature khác trong MVP 8 tuần; trì hoãn = block toàn bộ pipeline nghiệp vụ.

**Căn chỉnh chiến lược:** khớp trực tiếp mục tiêu tôn chỉ — "một hệ thống chung, giảm cập nhật rời rạc, điều phối công việc bằng dữ liệu thay vì ghi nhớ thủ công" và ràng buộc "mọi thay đổi kiểm tra quyền + ghi nhật ký ở máy chủ".

## 3. Hiện trạng / Tương lai / Khoảng trống

| Hiện trạng (AS-IS) | Tương lai (TO-BE) | Khoảng trống |
|---|---|---|
| Cập nhật rời rạc trên sổ/Excel/kênh chat, không tài khoản cá nhân | Mỗi nhân viên 1 tài khoản cá nhân, đăng nhập vào hệ thống chung | Cần quy trình cấp TK + chính sách tài khoản |
| Ai cũng sửa được mọi dữ liệu | 3 vai trò với quyền rõ ràng, thực thi phía server | Cần ma trận vai trò–quyền được chốt (đã có) |
| Không biết ai đã sửa gì | Nhật ký tập trung ghi ai-làm-gì-lúc nào, quản lý xem được | Cần quyết định nhật ký giữ bao lâu (đã chốt: toàn bộ MVP) |

## 4. Stakeholders

| Vai trò | Họ quan tâm gì |
|---|---|
| Quản lý khách sạn | Kiểm soát quyền, truy vết nhật ký, cấp/thu hồi TK nhanh |
| Lễ tân | Đăng nhập nhanh, làm đúng việc nhận/trả phòng |
| Nhân viên buồng phòng–bảo trì | Thấy việc được giao, cập nhật đúng phần mình |
| WPCTeam (team dev) | Nền phân quyền đúng ngay Sprint 1 để các feature sau kế thừa |
| Giảng viên / đại diện khách sạn | Đánh giá đồ án / phản hồi nghiệp vụ |

## 5. Mục tiêu nghiệp vụ + success measures

| ID | Mục tiêu | Thước đo thành công |
|---|---|---|
| BO-01 | Mọi thao tác ghi gắn đúng người thực hiện | 100% thay đổi trong nhật ký có định danh + vai trò (đối chiếu mẫu thao tác thực tế) |
| BO-02 | Không có truy cập vượt quyền | 100% kịch bản phân quyền kiểm thử pass; 0 sự cố vượt quyền trong pilot |
| BO-03 | Cấp/thu hồi quyền nhanh | TK mới sẵn sàng ≤2 phút; TK khóa có hiệu lực ngay (kể cả phiên đang mở) |
| BO-04 | Mỗi người dùng đúng 1 tài khoản cá nhân | Không tài khoản dùng chung; 1 TK chỉ 1 phiên thiết bị tại một thời điểm |

## 6. Phạm vi (business)

- **In scope:** quản lý tài khoản nhân viên nội bộ (tạo/khóa/mở/đặt lại MK); phân quyền vận hành theo 3 vai trò; chính sách đăng nhập (SĐT+MK, phiên, lockout); nhật ký hoạt động phục vụ truy vết.
- **Out of scope (business):** quản lý nhân sự (hợp đồng, lương, chấm công); tài khoản cho khách; đăng ký tự do; xác thực đa yếu tố/SSO; phân quyền tùy biến; tách vai trò buồng phòng vs bảo trì; audit tuân thủ bên ngoài.

## 7. Business Requirements

| BREQ | Yêu cầu | Priority | Trace |
|---|---|---|---|
| BREQ-01 | Hệ thống tài khoản cá nhân, mỗi nhân viên đúng 1 TK gắn 1 vai trò | Critical | BP-01, BP-03 → BO-01, BO-04 |
| BREQ-02 | Mọi thao tác ghi dữ liệu phải kiểm tra quyền theo vai trò | Critical | BP-03 → BO-02 |
| BREQ-03 | Nhật ký truy vết đầy đủ (ai, làm gì, lúc nào, đối tượng nào) | Critical | BP-02 → BO-01 |
| BREQ-04 | Quy trình cấp TK (NV mới), khóa TK (nghỉ việc), reset MK (quên MK) | High | UN-005, UN-006, UN-004 → BO-03 |

## 8. Business Rules

| ID | Quy tắc | Nguồn |
|---|---|---|
| BR-01 | Chỉ quản lý được quản lý tài khoản (tạo/sửa/khóa/mở/đặt lại MK) | Đã chốt trong brainstorm |
| BR-02 | Chỉ lễ tân được nhận/trả phòng — quản lý giám sát, không tự thao tác | Đã chốt (sửa ma trận) |
| BR-03 | Buồng phòng–bảo trì chỉ cập nhật vệ sinh/bảo trì thuộc việc được giao | Đã chốt |
| BR-04 | Sai mật khẩu 5 lần liên tiếp → khóa TK, chỉ quản lý mở được | Đã chốt |
| BR-05 | Tài khoản không bao giờ bị xóa — chỉ khóa/mở; nhật ký giữ nguyên | Đã chốt |
| BR-06 | Không được khóa/đổi vai trò tài khoản quản lý cuối cùng | Đã chốt |
| BR-07 | Một tài khoản chỉ một phiên thiết bị; phiên tối đa 12 giờ | Đã chốt |

## 9. Cost–benefit (qualitative)

- **Chi phí:** effort dev trong Sprint 1 (đã nằm trong plan); hạ tầng chung VPS + CSDL ~1.5M VNĐ cho cả dự án (tôn chỉ) — feature này không thêm chi phí riêng đáng kể.
- **Lợi ích:** truy vết được mọi thay đổi (giải quyết BP-02); giảm thao tác sai/vượt quyền (BP-03); là điều kiện tiên quyết cho 4+ feature còn lại — ROI cao nhất trong backlog vì là blocker.
- **Đánh đổi:** không self-service password reset (nhân viên phụ thuộc quản lý) — chấp nhận được ở quy mô 1 khách sạn.

## 10. Risks

| RISK | Rủi ro nghiệp vụ | Ảnh hưởng | Xác suất | Giảm thiểu | Trạng thái |
|---|---|---|---|---|---|
| RISK-01 | Nhân viên chia sẻ tài khoản | Mất ý nghĩa truy vết | Trung bình | 1 TK 1 thiết bị + quy định nội bộ | open |
| RISK-02 | Quản lý duy nhất quên MK → mất quyền quản trị | Block toàn bộ quản lý TK | Thấp | Cấm khóa QL cuối (BR-06) + quy trình reset thủ công bởi người vận hành | open |
| RISK-03 | Nhân viên quen cách cũ (gọi điện/ghi sổ), bỏ dùng app | Không đạt BO-01 | Trung bình | Đăng nhập tối giản (SĐT+MK), training ngắn đầu pilot | open |
| RISK-04 | Sprint 1 overload (auth + catalog + giao việc) | Trễ nền → trễ cả chuỗi | Trung bình | Ưu tiên P0 đăng nhập + phân quyền; phần phụ (xem nhật ký UI) có thể lùi P1 | open |

## 11. Open Questions

| OQ | Câu hỏi | Liên quan | Owner / Deadline |
|---|---|---|---|
| OQ-1 | Quy trình reset MK cho quản lý cuối cùng khi quên MK do ai thực hiện? | RISK-02 | Tạm: người vận hành hệ thống (ngoài app) — chốt trước pilot |
| OQ-2 | Tách vai trò buồng phòng vs bảo trì khi nào? | BR-03, scope | ✅ Resolved 2026-09-17: không tách trong MVP — 1 vai trò gộp (project-profile 15/09); đánh giá lại post-MVP |

