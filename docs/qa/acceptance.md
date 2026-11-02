# Kịch bản nghiệm thu MVP (S4-DAT-005)

Mục tiêu: 100% kịch bản bắt buộc pass trên Flutter Web và Android (PRD mục 8). Nghiệm thu: 02/11/2026.

## 1. Chuẩn bị

### Tài khoản demo (seed `npm run db:seed`)

Mật khẩu mọi tài khoản = giá trị `SEED_PASSWORD` trong `.env` của môi trường demo (không ghi ở đây).

| Vai trò | SĐT | Tên |
|---|---|---|
| MANAGER | 0900000001 | Nguyễn Văn Quản Lý |
| RECEPTIONIST | 0900000002 | Trần Thị Lễ Tân |
| RECEPTIONIST | 0900000003 | Lê Văn Lễ Tân |
| STAFF (buồng phòng, đang ca) | 0900000004–0900000006 | Phạm / Hoàng / Võ … |
| STAFF (bảo trì, đang ca) | 0900000007 | Đặng Văn Bảo Trì |
| STAFF (nghỉ ca) | 0900000008 | Bùi Thị Nghỉ Ca |

### Reset dữ liệu demo (trước mỗi lượt nghiệm thu)

```bash
cd server
npm run db:reset          # xoá sạch, chạy lại migration + seed 50 phòng và tài khoản
npm run db:seed:demo      # tình huống mẫu: 101–103 có khách, 104 cần dọn, 105 đang dọn,
                          # 106 chờ xác nhận, 201 báo hỏng, 202 ngừng phục vụ
npm run db:seed:peak      # (ngay trước demo dashboard/AI) tạo hoạt động trong ca hiện tại
```

### Thiết bị

- Web: Chrome và Edge bản mới, rộng desktop ≥1280px và tablet 768px.
- Android: APK release cài trên máy thử (ghi model và phiên bản Android).
- Kịch bản realtime cần 2 thiết bị mở cùng lúc (A = lễ tân web, B = nhân viên Android).

## 2. Thứ tự chạy

Chạy đúng thứ tự vì các kịch bản sau dùng trạng thái do kịch bản trước tạo ra. Mỗi kịch bản ghi Pass/Fail
cho **Web** và **Android** vào ma trận ở mục 4.

### AC-01 Đăng nhập & phân quyền (`auth-roles`)

| # | Bước | Kết quả mong đợi |
|---|---|---|
| 1 | Đăng nhập lần lượt 3 vai trò | Vào đúng màn chính của vai trò; menu chỉ có mục được phép |
| 2 | Sai mật khẩu | Báo lỗi, không vào được |
| 3 | STAFF gọi thẳng `POST /api/rooms/:id/check-in` (Postman/curl) | 403 — server chặn, không chỉ ẩn nút |
| 4 | RECEPTIONIST mở tóm tắt AI / sửa danh mục phòng bằng API | 403 |
| 5 | Quản lý khoá tài khoản 0900000008 → thử đăng nhập | Bị từ chối; mở khoá → đăng nhập được |
| 6 | Quản lý reset mật khẩu → user đăng nhập | Bị buộc đổi mật khẩu trước khi dùng app |

### AC-02 Danh mục phòng (`room-catalog`) — MANAGER

| # | Bước | Kết quả mong đợi |
|---|---|---|
| 1 | Xem danh mục | Đủ 50 phòng, khớp dữ liệu seed |
| 2 | Thêm / đổi tên / tắt một loại phòng | Thay đổi hiện ngay ở thiết bị khác |
| 3 | Đưa phòng sẵn sàng về "ngừng phục vụ" rồi "phục vụ lại" | Ô phòng chỉ hiện "Ngừng phục vụ"; trở lại sẵn sàng |

### AC-03 Nhận / trả phòng (`check-in-out`) — RECEPTIONIST

| # | Bước | Kết quả mong đợi |
|---|---|---|
| 1 | Nhận khách vào phòng sẵn sàng | Phòng chuyển "có khách" trên mọi thiết bị ≤3s |
| 2 | Nhận khách vào 104 (cần dọn) và 202 (ngừng phục vụ) | Bị chặn, có thông báo lý do |
| 3 | Trả phòng 101 | Phòng chuyển "cần dọn"; **tự tạo việc dọn** |

### AC-04 Dọn phòng (`housekeeping`)

| # | Vai trò | Bước | Kết quả mong đợi |
|---|---|---|---|
| 1 | STAFF | Mở danh sách việc, nhận việc dọn 101 | Việc chuyển "đang dọn" |
| 2 | STAFF | Từ chối một việc khác | Việc quay về hàng chờ / người khác nhận được |
| 3 | STAFF | Chụp ảnh nghiệm thu, báo xong | Không có ảnh bắt buộc thì không cho báo xong |
| 4 | MANAGER | Xem ảnh, xác nhận 101 | Phòng 101 về "sẵn sàng" |
| 5 | MANAGER | Trả lại việc 106 (chưa đạt) | Việc quay lại nhân viên kèm lý do |
| 6 | MANAGER | Giao lại việc cho nhân viên khác | Nhân viên mới thấy việc ngay |

### AC-05 Báo hỏng & bảo trì (`maintenance`)

| # | Vai trò | Bước | Kết quả mong đợi |
|---|---|---|---|
| 1 | STAFF hoặc RECEPTIONIST | Báo hỏng một phòng | Có phiếu "chờ nhận"; phòng ngừng phục vụ |
| 2 | RECEPTIONIST | Giao phiếu cho 0900000007 | Nhân viên bảo trì thấy phiếu |
| 3 | STAFF bảo trì | Nhận → báo hoàn tất | Phiếu đóng, phòng phục vụ lại theo spec |
| 4 | RECEPTIONIST | Nhận khách vào phòng đang sửa | Bị chặn |

### AC-06 Đồng bộ realtime & mất kết nối (`realtime-sync`)

| # | Bước | Kết quả mong đợi |
|---|---|---|
| 1 | A nhận phòng, B đang xem dashboard | B thấy thay đổi ≤3s, không cần tải lại |
| 2 | Tắt mạng trên B | Hiện banner "Mất kết nối"; **mọi nút ghi bị khoá** |
| 3 | Bật mạng lại | Banner tắt, nút mở lại, dữ liệu tự tải lại đúng |
| 4 | A và B cùng sửa một phòng (cùng version) | Người ghi sau nhận báo xung đột; không ghi đè |
| 5 | CI `npm run bench:realtime` | ≥95% trong 100 lượt ≤3s (đính kèm log CI) |

### AC-07 Dashboard (`room-dashboard`) — MANAGER / RECEPTIONIST

| # | Bước | Kết quả mong đợi |
|---|---|---|
| 1 | Sau `db:seed:peak`, so số liệu thẻ thống kê với danh sách phòng thực tế | Khớp 100% |
| 2 | Bấm thẻ thống kê | Lưới phòng lọc đúng |
| 3 | Việc quá hạn (do seed peak tạo) | Có cờ quá hạn; bấm cảnh báo mở đúng phòng/việc |

### AC-08 Nhật ký (`audit-log`) — MANAGER

| # | Bước | Kết quả mong đợi |
|---|---|---|
| 1 | Mở nhật ký sau các kịch bản trên | Mỗi thay đổi trạng thái có ai / khi / từ → sang |
| 2 | Tìm bản ghi đổi/reset mật khẩu | Có bản ghi, **không chứa giá trị mật khẩu** |

### AC-09 Tóm tắt AI (`ai-ops-summary`) — MANAGER

| # | Bước | Kết quả mong đợi |
|---|---|---|
| 1 | Tạo tóm tắt ca hiện tại | Số liệu khớp dashboard, không bịa sự kiện |
| 2 | Bỏ `OPENAI_API_KEY` hoặc hết ngân sách | Rơi về báo cáo mẫu, app không lỗi |
| 3 | Bộ 20 tình huống ở `docs/qa/ai-evaluation.md` | ≥18/20 đạt |

## 3. Tiêu chí đạt

- 100% kịch bản trên pass ở cả Web và Android (AC-09.3 theo ngưỡng 18/20).
- 0 lỗi blocker/critical còn mở.
- Web chạy qua HTTPS trên VPS; APK cài và chạy trên máy Android thử.

## 4. Ma trận kết quả

| Kịch bản | Web | Android | Người chạy | Ngày | Bằng chứng / lỗi |
|---|---|---|---|---|---|
| AC-01 | | | | | |
| AC-02 | | | | | |
| AC-03 | | | | | |
| AC-04 | | | | | |
| AC-05 | | | | | |
| AC-06 | | | | | |
| AC-07 | | | | | |
| AC-08 | | | | | |
| AC-09 | | | | | |

Ký nghiệm thu: PO ______ · Tech ______ · QA ______
