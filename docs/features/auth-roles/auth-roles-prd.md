---
type: feature-prd
feature: auth-roles
status: draft
updated: 2026-09-17
author: "@Tran Tan Dat"
links: ["docs/features/auth-roles/auth-roles-brd.md", "docs/features/auth-roles/auth-roles-urd.md"]
---

# Feature PRD — Đăng nhập, tài khoản & phân quyền

## 1. Feature overview + khoảng trống

Đăng nhập bằng SĐT + mật khẩu, quản lý tài khoản nhân viên bởi quản lý, phân quyền 3 vai trò thực thi phía server, và nhật ký truy vết mọi thay đổi. AS-IS: cập nhật rời rạc, không tài khoản cá nhân, không truy vết → TO-BE: tài khoản cá nhân theo vai trò, mọi thao tác ghi có chủ nhân. Nền tảng Sprint 1 cho toàn bộ MVP.

## 2. Goals / Non-goals

**Goals:**
- G1 — Kiểm soát truy cập theo vai trò: mỗi nhân viên chỉ làm đúng việc của mình (BO-02).
- G2 — Truy vết đầy đủ: mọi thay đổi dữ liệu gắn ai-làm-gì-lúc nào (BO-01).
- G3 — Vận hành TK nhanh: cấp TK ≤2 phút, khóa có hiệu lực ngay (BO-03).

**Non-goals (feature này):**
- Tự đăng ký tài khoản; đăng nhập SSO/mạng xã hội; OTP/đa yếu tố.
- Quên mật khẩu tự phục hồi (quản lý reset thủ công — đã chốt).
- Xóa cứng tài khoản (chỉ khóa — BR-05).
- Phân quyền tùy biến ngoài 3 vai trò cố định; tách buồng phòng vs bảo trì.
- Quản lý thiết bị/địa điểm đăng nhập, cảnh báo đăng nhập lạ.
- Nhật ký cho nghiệp vụ phòng chi tiết — thuộc các feature tương ứng (feature này chỉ định nghĩa cơ chế ghi + sự kiện auth).

## 3. Personas & use cases

| Persona | Nhu cầu cốt lõi | Cách dùng |
|---|---|---|
| Quản lý khách sạn | Kiểm soát ai được làm gì, truy vết | Cấp/khóa TK, xem nhật ký, giám sát dashboard |
| Lễ tân | Đăng nhập nhanh đầu ca, nhận/trả phòng | Đăng nhập SĐT+MK, thao tác check-in/out cả ca |
| Nhân viên buồng phòng–bảo trì | Biết việc được giao, cập nhật nhanh | Đăng nhập, xem danh sách việc, cập nhật trạng thái |

Chi tiết pain/goals: xem URD mục 3.

## 4. Capabilities & phân tầng

| ID | Mô tả | Priority | Trace | Vì sao | Stories | Done when | Readiness |
|---|---|---|---|---|---|---|---|
| CAP-auth-roles-01 | Đăng nhập/đăng xuất bằng SĐT + mật khẩu | P0 | UN-001, BREQ-01 | Cửa ngõ mọi việc — không có không dùng được hệ thống | 5 | NV đăng nhập vào màn đúng vai trò; sai TK báo lỗi đúng wording | Dev-ready |
| CAP-auth-roles-02 | Phiên đăng nhập: 12h, 1 TK 1 thiết bị, hết phiên bắt đăng nhập lại | P0 | UN-008, BR-auth-roles-007 | Giữ trọn ca làm việc + chặn dùng chung TK | 3 | Đăng nhập thiết bị mới đá phiên cũ; hết 12h về màn login | Dev-ready |
| CAP-auth-roles-03 | Phân quyền 3 vai trò thực thi phía server cho mọi thao tác ghi | P0 | UN-002, BREQ-02, BR-auth-roles-001..003 | Ràng buộc tôn chỉ; nền cho mọi feature | 4 | Mọi API ghi reject khi sai quyền; ma trận vai trò pass test | Dev-ready |
| CAP-auth-roles-04 | Quản lý tài khoản: tạo (sinh MK tạm), sửa, khóa, mở; cấm khóa QL cuối | P0 | UN-005, UN-006, BREQ-04, BR-auth-roles-005, BR-auth-roles-006 | Vận hành nhân sự khách sạn | 5 | QL tạo TK ≤2 phút; khóa TK đá phiên ngay; không xóa được TK | Dev-ready |
| CAP-auth-roles-05 | Đổi MK self-service + bắt đổi MK tạm lần đầu/sau reset | P0 | UN-003, UN-004, BREQ-04 | MK tạm bắt đổi là điều kiện của CAP-auth-roles-04 | 3 | MK tạm không vào được app tới khi đổi; đổi xong giữ phiên | Dev-ready |
| CAP-auth-roles-06 | Khóa tự động sau 5 lần sai MK liên tiếp | P0 | BR-auth-roles-004 | Chống dò mật khẩu | 2 | Lần sai thứ 5 → TK khóa + nhật ký + chỉ QL mở | Dev-ready |
| CAP-auth-roles-07 | Ghi nhật ký phía server: mọi thay đổi + sự kiện auth | P0 | BREQ-03, BO-01 | Điều kiện truy vết | 3 | Mọi thao tác ghi/auth có dòng nhật ký đủ trường | Dev-ready |
| CAP-auth-roles-08 | Màn xem nhật ký cho quản lý (lọc theo người/ngày/hành động) | P1 | UN-007 | Ghi nhật ký là P0 nhưng UI xem có thể lùi sau | 3 | QL lọc và xem được nhật ký | Dev-ready |

## 5. Traceability lên upstream

| CAP | ← URD (UN-*) | ← BRD (BREQ-*/BR-*/BO-*) |
|---|---|---|
| CAP-auth-roles-01 | UN-001 | BREQ-01 |
| CAP-auth-roles-02 | UN-008 | BR-auth-roles-007, BO-04 |
| CAP-auth-roles-03 | UN-002 | BREQ-02, BR-auth-roles-001/002/003, BO-02 |
| CAP-auth-roles-04 | UN-005, UN-006 | BREQ-04, BR-auth-roles-001/005/006, BO-03 |
| CAP-auth-roles-05 | UN-003, UN-004 | BREQ-04 |
| CAP-auth-roles-06 | — | BR-auth-roles-004 |
| CAP-auth-roles-07 | — | BREQ-03, BO-01 |
| CAP-auth-roles-08 | UN-007 | BREQ-03 |

Coverage: UN-001..008 và BREQ-01..04 đều được phủ bởi ≥1 CAP; BR-auth-roles-001..007 đều có CAP thực thi.

## 6. Feature interactions

- **Room-catalog / check-in-out / housekeeping / dashboard / reports:** tất cả phụ thuộc CAP-auth-roles-03 (kiểm quyền) và CAP-auth-roles-07 (ghi nhật ký). `auth-roles` là tiền đề — các feature này không được thực thi thao tác ghi mà không qua kiểm quyền.
- **Housekeeping:** OQ "việc được giao" đã chốt — giao tường minh tới cá nhân, không theo khu vực (housekeeping tự giao; maintenance tự nhận); OQ tách vai trò đã chốt — giữ 1 vai trò gộp trong MVP nên CAP-auth-roles-03 không cần mở rộng vai trò ở v1.
- **Audit-log (overlap UI xem nhật ký):** CAP-auth-roles-08 / FR-auth-roles-014 là **placeholder P1** cho màn xem/lọc nhật ký phía auth. UI xem nhật ký nghiệp vụ + sự kiện auth **thực thi bởi feature `audit-log`** (CAP-audit-log-04..06). Điều kiện truy vết / bất biến / ghi đủ trường thuộc `audit-log` + CAP-auth-roles-07 (ghi phía server). Không xóa CAP-auth-roles-08 — giữ trace UN-007; triển khai UI gom về `audit-log`.

## 7. Success metrics

| Metric | Baseline | Target | Cách đo | Timeframe |
|---|---|---|---|---|
| Tỷ lệ thao tác ghi có định danh | Không truy vết được | 100% | Đối chiếu nhật ký vs thao tác mẫu | Liên tục từ pilot |
| Sự cố vượt quyền | — | 0 | Test suite phân quyền + pilot | Trước demo Sprint 1 |
| Thời gian cấp TK mới | Rời rạc, không chuẩn | ≤2 phút | Đo thủ công trên kịch bản pilot | Cuối Sprint 1 |
| Đăng nhập thành công (NV quen) | — | ≤30 giây | Đo thủ công pilot | Sprint 2 |
| TK dùng chung | Phổ biến | 0 | Kiểm tra nhật ký phiên đồng thời | Pilot |

## 8. Dependencies

- **Business:** ma trận vai trò–quyền đã chốt với điều phối viên (đợt brainstorm 2026-09-15); kịch bản giả lập do WPCTeam tự xây.
- **Feature:** không phụ thuộc feature nào — là feature đầu tiên của chuỗi.
- **Team:** backend (Node/Express + PostgreSQL/Prisma) và realtime (Socket.IO) theo hướng tôn chỉ — cần sẵn hạ tầng VPS/DB đầu Sprint 1.

## 9. Assumptions

- SĐT chỉ là định danh, không OTP xác thực (dữ liệu giả lập, không dịch vụ ngoài).
- MK tạm không hết hạn, chỉ dùng 1 lần cho đổi MK bắt buộc.
- Đổi MK thành công giữ phiên hiện tại.
- Quản lý nhận MK tạm từ màn hình và chuyển cho nhân viên ngoài app (không gửi SMS/email).

## 10. Risks (product)

| Rủi ro | Ảnh hưởng | Giảm thiểu |
|---|---|---|
| Nhân viên chia sẻ TK | Truy vết vô nghĩa | 1 TK 1 thiết bị + quy định nội bộ (RISK-01) |
| Chia sẻ MK tạm lộ trong nhật ký/UI | Lộ credential | MK tạm chỉ hiển thị 1 lần cho quản lý, không log giá trị MK |
| Scope creep: thêm OTP/SSO giữa MVP | Trễ Sprint 1 | Non-goals đã chốt; mọi bổ sung phải qua review |

## 11. Release horizon + launch readiness

- **Now (Sprint 1, 08/09–21/09):** CAP-auth-roles-01 → CAP-auth-roles-07 (toàn bộ P0).
- **Next:** CAP-auth-roles-08 (xem nhật ký UI) — có thể lùi Sprint 2 nếu Sprint 1 chật.
- **Later:** OTP/SSO, tách vai trò, phân quyền tùy biến — ngoài MVP.

**Launch readiness:** 100% kịch bản phân quyền kiểm thử pass (tiêu chí tôn chỉ); mọi P0 capability đạt "done when". Guardrail metric: tỷ lệ phiên bị hủy do đăng nhập nơi khác cao bất thường → dấu hiệu chia sẻ TK.

## 12. Open Questions

| OQ | Câu hỏi | Owner | Deadline |
|---|---|---|---|
| OQ-1 | Quy trình reset MK cho QL cuối cùng (khi quên MK) do ai thực hiện? | Điều phối viên | Trước pilot Sprint 2 |
| OQ-2 | Tách vai trò buồng phòng vs bảo trì? | ✅ Resolved 2026-09-17 — giữ 1 vai trò gộp MVP (project-profile 15/09) | Đánh giá lại post-MVP |

