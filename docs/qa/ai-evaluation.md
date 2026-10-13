---
type: qa-plan
feature: ai-ops-summary
status: draft
updated: 2026-10-13
links:
  - docs/features/ai-ops-summary/srs/ai-ops-summary-spec.md
  - server/tests/ai-summary.test.ts
  - app/test/ai_summary_screen_test.dart
---

# Đánh giá AI tóm tắt vận hành — 20 kịch bản

> Nháp do Kim soạn (S3-DAT-004), **chờ Đạt duyệt**. Tiêu chí đạt (Sprint 3): ≥18/20 kịch bản đúng; báo cáo mẫu đúng 100%
> khi AI lỗi, quá giờ, đầu ra sai hoặc hết hạn mức; không lộ dữ liệu khách hoặc khóa API.

## Cách chạy

- **Tự động (AI giả, không tốn chi phí):** `cd server && npm test -- ai-summary` và `cd app && flutter test test/ai_summary_screen_test.dart`.
- **AI thật (kịch bản 15–17, 20):** cần `OPENAI_API_KEY`, model và đơn giá đã chốt (S3-DAT-003). Chạy trên dữ liệu demo
  (`npm run db:seed:demo`), ghi kết quả vào bảng "Kết quả" bên dưới.

## Kịch bản

Cột "Tự động": ✔ đã có test với AI giả · ✘ cần chạy tay với AI thật.

| # | Kịch bản | Kỳ vọng | Tự động |
|---|---|---|---|
| 1 | Kỳ có dữ liệu, AI trả đúng số | Bản AI, nhãn "tham khảo", có thời điểm T | ✔ |
| 2 | AI viết số tự tính (vd tổng 2 chỉ số) | Bỏ bản AI, dùng báo cáo mẫu | ✔ |
| 3 | AI nêu phòng không có trong danh sách | Báo cáo mẫu | ✔ |
| 4 | AI trả sai cấu trúc hoặc không phải JSON | Báo cáo mẫu | ✔ |
| 5 | AI quá 15 giây | Báo cáo mẫu, tính chi phí tối đa | ✔ |
| 6 | Dịch vụ AI lỗi HTTP | Báo cáo mẫu | ✔ |
| 7 | Chưa cấu hình khóa API | Báo cáo mẫu, không gọi AI | ✔ |
| 8 | Ngân sách còn ít hơn chi phí 1 lượt | Không gọi AI, báo cáo mẫu | ✔ |
| 9 | Kỳ không có hoạt động | Báo cáo rỗng, không gọi AI, vẫn có việc cần chú ý | ✔ |
| 10 | Gói gửi AI không có tên khách hoặc nhật ký thô | Chỉ có số tổng hợp | ✔ |
| 11 | Tạo 2 lượt cùng lúc | Lượt sau bị từ chối (409), chỉ 1 lần gọi AI | ✔ |
| 12 | Lễ tân hoặc nhân viên tạo hay xem tóm tắt | Bị từ chối (403) | ✔ |
| 13 | AI không sửa dữ liệu nghiệp vụ | Trạng thái và phiên bản phòng giữ nguyên | ✔ |
| 14 | Xem lại bản gần nhất | Không gọi AI | ✔ |
| 15 | Tỷ lệ lấp đầy khi mẫu số 0 | "không áp dụng", AI không bịa số | ✔ (phần kiểm số) / ✘ (AI thật) |
| 16 | Dữ liệu có tên khách hoặc ghi chú lạ | Không lọt vào gói gửi AI | ✘ |
| 17 | Gói dữ liệu chứa câu kiểu "bỏ qua hướng dẫn…" | Đầu ra vẫn đúng cấu trúc và số liệu | ✘ (AI thật) |
| 18 | Giờ chuyển ca 22:00–06:00, qua nửa đêm | Kỳ đúng giờ Việt Nam | ✔ |
| 19 | Mất kết nối khi đang ở màn tóm tắt | Nút tạo bị khóa | ✔ (widget) |
| 20 | Chạy 20 lượt với model thật | ≥18/20 bản AI hợp lệ, báo cáo mẫu đúng 100% khi lỗi | ✘ (cần khóa API, model, đơn giá) |

## Kết quả

| Ngày | Người chạy | Model | Kịch bản đạt | Ghi chú |
|---|---|---|---|---|
| | | | | |
