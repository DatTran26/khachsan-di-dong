---
type: brainstorm
feature: auth-roles
slug: auth-roles-core
status: draft
updated: 2026-09-15
author: "@Tran Tan Dat"
links: []
---

# Brainstorm: Đăng nhập, quản lý tài khoản & phân quyền 3 vai trò

## 1. Idea Seed

Đăng nhập + quản lý tài khoản nhân viên + phân quyền 3 vai trò (quản lý / lễ tân / buồng phòng–bảo trì). Mọi thay đổi dữ liệu phải kiểm tra quyền; mật khẩu băm, phân quyền thực thi phía server (theo tôn chỉ). — Devin CLI 3, 2026-09-15

## 2. Bối cảnh

- Phần mềm theo dõi trạng thái phòng khách sạn realtime + dashboard; MVP 8 tuần (08/09–02/11/2026), 1 khách sạn ~50 phòng, tiếng Việt, dữ liệu giả lập (tôn chỉ).
- `auth-roles` nằm Sprint 1 (08/09–21/09) — là nền tảng: mọi feature sau (room-catalog, check-in-out, housekeeping, dashboard) đều phải biết ai đang thao tác và có quyền gì.
- Pain hiện tại: cập nhật rời rạc giữa thiết bị/ca, không ai chịu trách nhiệm với dữ liệu trung tâm; cần biết ai đã sửa gì.
- ~10 phiên đăng nhập đồng thời; ≥95% cập nhật lan sang thiết bị khác trong ≤3 giây (tiêu chí nghiệm thu tôn chỉ).
- Vai trò quản lý xem toàn bộ và có thể xuất báo cáo định kỳ; AI advisor (nếu làm) chỉ cho quản lý.

## 3. User Types

| Nhóm user | Pain hiện tại | Họ cần gì |
|---|---|---|
| Quản lý khách sạn | Không kiểm soát được ai sửa dữ liệu, không truy vết được sai sót | Cấp/thu hồi quyền nhanh, xem nhật ký, giám sát toàn bộ |
| Lễ tân | Dùng chung kênh rời rạc, không rõ quyền hạn khi nhận/trả phòng | Đăng nhập nhanh đầu ca, làm đúng việc nhận/trả phòng |
| Nhân viên buồng phòng–bảo trì | Nhận việc bằng miệng/chat rời, không cập nhật được trạng thái | Xem việc được giao, cập nhật vệ sinh/bảo trì, báo hỏng |

Primary user (tham chiếu chung): nhân viên khách sạn — người đăng nhập và làm việc hằng ngày.

## 4. Phạm vi capabilities (ước lượng)

| P0 | P1 | P2 |
|---|---|---|
| Đăng nhập bằng SĐT + mật khẩu | Xem nhật ký hoạt động (quản lý) | Tách vai trò buồng phòng / bảo trì |
| Đăng xuất + phiên 12h + 1 TK 1 thiết bị | Nhắc/quản lý phiên đang mở | OTP/đăng nhập sinh trắc học |
| Phân quyền 3 vai trò thực thi phía server | | Quên mật khẩu tự phục hồi (SMS/email) |
| Quản lý tạo/sửa/khóa/mở tài khoản (sinh MK tạm) | | Phân quyền tùy biến theo từng người |
| Đổi MK self-service + bắt đổi MK tạm lần đầu | | |
| Khóa tự động sau 5 lần sai MK | | |
| Ghi nhật ký phía server mọi thay đổi + sự kiện auth | | |

## 5. Core Flows

### Luồng chính

**Đăng nhập:**
1. Nhân viên mở app → màn đăng nhập → nhập SĐT + mật khẩu → bấm "Đăng nhập".
2. Hệ thống kiểm chứng danh → kiểm tra trạng thái tài khoản → nếu đúng và đang dùng MK tạm → màn đổi MK bắt buộc.
3. Đúng và MK thường → tạo phiên 12h; nếu TK đang có phiên trên thiết bị khác → hủy phiên cũ.
4. Vào màn chính theo vai trò → ghi nhật ký đăng nhập.

**Đổi mật khẩu (self-service):**
1. Nhân viên vào Tài khoản → "Đổi mật khẩu" → nhập MK cũ + MK mới (2 lần).
2. Hệ thống kiểm MK cũ + rule MK mới → đổi → giữ phiên hiện tại → ghi nhật ký.

**Quản lý tạo tài khoản:**
1. Quản lý vào màn Tài khoản → "Thêm nhân viên" → nhập họ tên + SĐT + chọn vai trò.
2. Hệ thống kiểm SĐT chưa tồn tại → sinh MK tạm → TK ở trạng thái "Chờ kích hoạt" → ghi nhật ký.
3. Hiển thị MK tạm một lần để quản lý chuyển cho nhân viên.

**Khóa / mở khóa tài khoản:**
1. Quản lý chọn tài khoản → "Khóa" → xác nhận → TK chuyển "Bị khóa" → phiên đang mở bị hủy ngay → ghi nhật ký.
2. "Mở khóa" → sinh MK tạm mới → TK về "Chờ kích hoạt" → nhân viên đăng nhập bằng MK tạm → bắt đổi MK.

**Quên mật khẩu (MVP):** nhân viên báo quản lý → quản lý "Đặt lại mật khẩu" → sinh MK tạm → nhân viên đăng nhập + bắt đổi.

### Sơ đồ rẽ nhánh — Đăng nhập

```
Nhân viên                        Hệ thống
   │                                │
   │── nhập SĐT + MK, bấm ĐN ──────▶│
   │                                ├─ định danh + MK đúng? ── NO ──▶ +1 đếm sai
   │                                │                              │
   │                                │                              ├─ đủ 5 lần? ── YES ──▶ Khóa TK
   │                                │                              │            (ghi nhật ký)
   │                                │                              └── NO ──▶ báo lỗi, cho nhập lại
   │                                │
   │                                ├─ YES ──▶ TK đang Bị khóa? ── YES ──▶ báo "liên hệ quản lý"
   │                                │                    │
   │                                │                   NO
   │                                │                    ├─ đang dùng MK tạm? ── YES ──▶ màn đổi MK bắt buộc
   │                                │                    └── NO ──▶ tạo phiên 12h
   │                                │                                 + hủy phiên cũ (nếu có)
   │                                │                                 + ghi nhật ký
   │◀── vào màn chính theo vai trò ──┤
```

### Sơ đồ rẽ nhánh — Quản lý khóa tài khoản

```
Quản lý                          Hệ thống
   │                                │
   │── chọn TK → "Khóa" ───────────▶│
   │                                ├─ đây là TK quản lý cuối cùng? ── YES ──▶ từ chối + báo lỗi
   │                                │                    │
   │                                │                   NO
   │                                │                    ├─ TK → "Bị khóa"
   │                                │                    ├─ hủy ngay phiên đang mở (realtime)
   │                                │                    └─ ghi nhật ký (ai khóa, lúc nào)
   │◀── báo "Đã khóa tài khoản" ────┤
```

## 6. Đi sâu

### 6.1 Điểm rẽ nhánh quan trọng

| Điểm rẽ | Điều kiện | Nhánh A | Nhánh B | Ảnh hưởng |
|---|---|---|---|---|
| Xác thực đăng nhập | SĐT+MK đúng/sai | Đúng → kiểm tiếp trạng thái | Sai → +1 đếm, đủ 5 → khóa TK | Quyết định lockout tự động |
| Trạng thái TK | Hoạt động / Chờ kích hoạt / Bị khóa | Hoạt động → vào app | Khóa → từ chối; Chờ kích hoạt (MK tạm) → bắt đổi MK | Chặn truy cập trái phép |
| Phiên song song | TK đã có phiên thiết bị khác? | Có → hủy phiên cũ, tạo phiên mới | Không → tạo phiên mới | Rule 1 TK 1 thiết bị |
| Khóa TK quản lý | Đây có phải QL cuối cùng? | Có → từ chối | Không → cho khóa | Bảo vệ không mất quyền quản trị |
| Kiểm quyền thao tác | Vai trò có quyền hành động? | Có → thực hiện + ghi nhật ký | Không → từ chối + báo lỗi | Toàn bộ thao tác ghi |

### 6.2 Bảng kịch bản nhiều vai trò (vai trò × hành động)

| Vai trò | Nhận/trả phòng | Cập nhật vệ sinh/bảo trì | Xem trạng thái + dashboard | Quản lý tài khoản | Xem nhật ký | Xem AI advisor |
|---|---|---|---|---|---|---|
| Quản lý | ❌ (chỉ lễ tân) | ❌ | ✅ toàn bộ | ✅ | ✅ | ✅ |
| Lễ tân | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ |
| Buồng phòng–bảo trì | ❌ | ✅ (việc được giao) | ✅ danh sách việc | ❌ | ❌ | ❌ |

### 6.3 State machine — trạng thái tài khoản

```
            tạo TK (MK tạm)
                 ▼
        ┌──────────────────┐
        │ Chờ kích hoạt    │── nhân viên đăng nhập + đổi MK ──▶
        └──────────────────┘                                   │
            ▲                                                  ▼
            │ mở khóa / reset MK                        ┌────────────┐
            │ (sinh MK tạm mới)                         │ Hoạt động  │
        ┌──────────┐                                    └────────────┘
        │ Bị khóa  │◀── quản lý khóa / sai MK 5 lần ────────┘
        └──────────┘
   (Bị khóa: không đăng nhập được, phiên đang mở bị hủy ngay;
    không có trạng thái "Đã xóa" — tài khoản chỉ khóa, không xóa)
```

### 6.4 Edge cases khác

- Phiên hết hạn giữa ca (sau 12h) → báo hết phiên, bắt đăng nhập lại; thao tác ghi chưa lưu → báo "dữ liệu chưa được lưu".
- TK bị khóa khi nhân viên đang dùng → phiên bị hủy realtime, app về màn đăng nhập.
- Mất mạng khi đổi MK/đăng nhập → báo mất kết nối, không lưu, cho thử lại (tôn chỉ: mất mạng khóa thao tác ghi).
- Hai quản lý cùng tạo TK trùng SĐT đồng thời → một giao dịch thành công, giao dịch sau báo "SĐT đã có tài khoản" (ràng buộc duy nhất phía server).
- Nhân viên nghỉ việc → quản lý khóa TK (không xóa), lịch sử nhật ký giữ nguyên.

## 7. Validation / Giới hạn / Wording

### 7.1 Validation & giới hạn (đã chốt)

- Định danh đăng nhập: **số điện thoại** (định dạng di động VN: 10 số, bắt đầu bằng 0).
- Mật khẩu: **tối thiểu 8 ký tự, gồm cả chữ và số**.
- Sai mật khẩu **5 lần liên tiếp** → khóa TK, chờ quản lý mở.
- Phiên đăng nhập: **12 giờ**; **1 tài khoản chỉ 1 thiết bị** — đăng nhập mới đá phiên cũ.
- Khóa TK → **hủy ngay phiên đang mở**.
- Tài khoản **không bao giờ bị xóa** — chỉ khóa/mở.
- Mở khóa/reset → **sinh MK tạm + bắt buộc đổi MK** khi đăng nhập.
- **Không được khóa/đổi vai trò tài khoản quản lý cuối cùng**.
- Nhật ký hoạt động **giữ toàn bộ thời gian MVP**.

### 7.2 Wording mẫu (tiếng Việt, đề xuất — sửa tại đây nếu cần)

| Loại | Tình huống | Câu chữ |
|---|---|---|
| Lỗi | Sai SĐT/MK | "Số điện thoại hoặc mật khẩu chưa đúng. Vui lòng thử lại." |
| Lỗi | TK bị khóa | "Tài khoản của bạn đang bị khóa. Vui lòng liên hệ quản lý để được mở lại." |
| Lỗi | Phiên hết hạn | "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại." |
| Lỗi | MK mới không đạt | "Mật khẩu mới cần ít nhất 8 ký tự, gồm cả chữ và số." |
| Lỗi | SĐT trùng khi tạo TK | "Số điện thoại này đã có tài khoản. Vui lòng kiểm tra lại." |
| Lỗi | Không đủ quyền | "Bạn không có quyền thực hiện thao tác này." |
| Lỗi | Mất mạng khi ghi | "Mất kết nối. Dữ liệu chưa được lưu — vui lòng thử lại khi có mạng." |
| Lỗi | Khóa QL cuối | "Không thể khóa — đây là tài khoản quản lý cuối cùng." |
| Thành công | Tạo TK | "Đã tạo tài khoản cho {họ tên}. Mật khẩu tạm: {XXXX} — hãy chuyển cho nhân viên." |
| Thành công | Đổi MK | "Đổi mật khẩu thành công." |
| Thành công | Khóa TK | "Đã khóa tài khoản {họ tên}." |
| Thành công | Mở khóa | "Đã mở khóa tài khoản. Mật khẩu tạm mới: {XXXX}" |
| Thông báo | Bắt đổi MK tạm | "Bạn đang dùng mật khẩu tạm — vui lòng đặt mật khẩu mới để tiếp tục." |
| Thông báo | Phiên bị hủy | "Tài khoản vừa đăng nhập trên thiết bị khác (hoặc đã bị khóa) — phiên này đã kết thúc." |

## 8. Giả định

- SĐT chỉ là định danh đăng nhập — **không gửi OTP xác thực** (dữ liệu giả lập, không tích hợp dịch vụ ngoài).
- MK tạm **không hết hạn** trong MVP nhưng chỉ dùng được cho một lần đổi MK bắt buộc.
- Đổi MK thành công **giữ phiên hiện tại** (không bắt đăng nhập lại).
- Nhân viên buồng phòng–bảo trì là **một vai trò gộp** trong MVP.
- Hạ tầng đã có theo tôn chỉ: HTTPS, băm MK, phân quyền server-side, VPS + CSDL (giả định triển khai trong đồ án).

## 9. Rủi ro (góc nhìn IT-BA)

- Nhân viên chia sẻ tài khoản → giảm bằng rule 1 TK 1 thiết bị + quy trình cấp TK cá nhân.
- Quản lý quên MK của chính mình và không còn QL nào khác → cấm khóa QL cuối + quy trình reset thủ công (giả định: người vận hành hệ thống/team dev hỗ trợ — ngoài phạm vi app).
- Ngưỡng 5 lần sai có thể gây khóa oan khi gõ nhầm → chọn 5 là cân bằng UX/bảo mật, có thể chỉnh sau pilot.
- Sprint 1 chật: auth + catalog + giao việc cùng lúc → ưu tiên P0 đăng nhập + phân quyền trước.

## 10. Tiêu chí thành công (sơ bộ)

- 100% thao tác ghi dữ liệu gắn đúng định danh người thực hiện trong nhật ký.
- 0 thao tác vượt quyền trong bộ kịch bản kiểm thử phân quyền (theo tiêu chí tôn chỉ: 100% kịch bản phân quyền pass).
- Nhân viên đăng nhập thành công ≤30 giây (người đã quen); quản lý cấp TK mới ≤2 phút.

## 11. Open Questions

| OQ | Câu hỏi | Quyết định tạm | Hướng đi |
|---|---|---|---|
| OQ-1 | Khi nào cần tách vai trò buồng phòng vs bảo trì? | Giữ 1 vai trò gộp trong MVP — chốt (không còn tạm) | resolved 2026-09-17 (project-profile 15/09); đánh giá lại post-MVP nếu cần tách quyền |
| OQ-2 | NV buồng phòng–bảo trì có cần gắn "khu vực/tầng phụ trách" để xác định "việc được giao"? | Chốt: không theo khu vực — giao tường minh tới cá nhân | resolved 2026-09-17 (housekeeping: hệ thống tự giao cho người ít việc nhất; maintenance: tự nhận từ danh sách chung) |

## 12. Bước tiếp

- [x] Ghi bảng ý tưởng này
- [ ] `/urd auth-roles`
- [ ] `/brd auth-roles`
- [ ] `/prd-epic auth-roles`
- [ ] `/srs auth-roles` (Tầng 1 — Core spec)
