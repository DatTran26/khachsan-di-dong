# Runbook triển khai và rollback (S4-DAT-004)

Mô hình: VPS chạy Docker Compose (`server/docker-compose.yml`, profile `full`) gồm PostgreSQL và API;
Nginx đứng trước để có HTTPS và phục vụ bản Flutter Web.

> Chưa có trong repo: file cấu hình Nginx, và cấu hình URL API cho bản build app (hiện cố định localhost).
> Phải bổ sung hai phần này trước lần deploy đầu.

## 1. Biến môi trường (chỉ ghi tên, không ghi giá trị)

| Biến | Bắt buộc | Ghi chú |
|---|---|---|
| `DATABASE_URL` | Có | Compose tự đặt khi chạy profile `full` |
| `PORT` | Không | Mặc định 3000 |
| `CORS_ORIGINS` | Có (prod) | Tên miền web HTTPS, cách nhau dấu phẩy |
| `SEED_PASSWORD` | Chỉ khi seed | Mật khẩu chung cho tài khoản demo |
| `MAINTENANCE_DUE_MINUTES` | Không | Mặc định 240; 0 = tắt |
| `UPLOAD_DIR`, `PHOTO_MAX_MB` | Không | Ảnh nghiệm thu dọn phòng; volume `uploads` |
| `OPENAI_API_KEY` | Không | Bỏ trống = dùng báo cáo mẫu |
| `OPENAI_MODEL`, `AI_BUDGET_VND`, `AI_PRICE_*` | Không | Ngân sách AI ≤300.000 VNĐ |

Giá trị thật để trong `server/.env` trên VPS (quyền 600). Không commit, không dán vào issue/PR.
Đổi mật khẩu PostgreSQL mặc định trong compose trước khi lên prod.

## 2. Trước khi deploy

- [ ] CI xanh trên commit sẽ deploy (Backend CI + App CI).
- [ ] Đã có tag release (`vX.Y.Z`) trên `main`.
- [ ] Ghi lại tag/commit đang chạy hiện tại để rollback.
- [ ] Backup CSDL (mục 3).

## 3. Backup

```bash
cd server
docker compose exec -T db pg_dump -U khachsan -Fc khachsan > backup-$(date +%Y%m%d-%H%M).dump
docker run --rm -v server_uploads:/data -v "$PWD":/out alpine tar czf /out/uploads-$(date +%Y%m%d-%H%M).tgz -C /data .
```

Tên volume `server_uploads` theo tên thư mục compose — kiểm tra bằng `docker volume ls` trên VPS.
Giữ ít nhất 2 bản backup gần nhất ngoài VPS.

## 4. Deploy

```bash
git fetch --tags && git checkout vX.Y.Z
cd server
docker compose --profile full build api
docker compose --profile full up -d        # container tự chạy `prisma migrate deploy` rồi mới mở server
```

Lần đầu (CSDL trống) mới seed:

```bash
docker compose exec api npx prisma db seed
```

Web: build `flutter build web --release` (trỏ URL API của VPS), chép `app/build/web` vào thư mục Nginx phục vụ.

## 5. Smoke test sau deploy (≤10 phút)

| # | Kiểm tra | Đạt khi |
|---|---|---|
| 1 | `curl -fsS https://<ten-mien>/api/health` | 200; 503 = CSDL không lên |
| 2 | Đăng nhập 3 vai trò trên web | Vào đúng màn |
| 3 | Nhận rồi trả 1 phòng | Thiết bị thứ hai thấy thay đổi ≤3s; việc dọn được tạo |
| 4 | Tắt/bật mạng thiết bị thứ hai | Banner "Mất kết nối", khoá nút; có mạng lại thì tự mở |
| 5 | `docker compose logs api --since 10m` | Không có lỗi; không có mật khẩu/token trong log |

Smoke fail ở bước 1–3 → rollback ngay (mục 6).

## 6. Rollback

**Chỉ lỗi code, schema không đổi:**

```bash
git checkout <tag-cu>
cd server && docker compose --profile full up -d --build api
```

**Bản mới có migration:** Prisma không có migrate down → khôi phục CSDL từ backup ở mục 3:

```bash
docker compose stop api
docker compose exec -T db pg_restore -U khachsan -d khachsan --clean --if-exists < backup-<thoi-diem>.dump
git checkout <tag-cu>
docker compose --profile full up -d --build api
```

Sau rollback chạy lại smoke test mục 5 và ghi sự cố vào worklog (thời điểm, nguyên nhân, dữ liệu mất nếu có).

## 7. Diễn tập (S4-BAO-002)

Trên bản sao staging: backup → deploy bản mới → smoke → rollback bằng restore → smoke.
Ghi thời gian từng bước và kết quả vào `docs/qa/` trước ngày nghiệm thu.
