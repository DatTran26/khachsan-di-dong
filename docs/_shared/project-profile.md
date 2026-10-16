---
type: project-profile
status: draft
updated: 2026-09-15
links: []
---

# Project Profile

> Kho thông tin cấp dự án tích lũy dần — skill thiếu thông tin sẽ hỏi rồi ghi vào đây, skill sau
> đọc lại không hỏi nữa (xem `.agents/rules/project-profile.md`). Chỉ tạo section khi có nội dung
> thật; mỗi mục kèm ngày ghi.

## Domain

Phần mềm theo dõi trạng thái phòng khách sạn theo thời gian thực + dashboard dữ liệu (web/mobile). Bài toán: trạng thái phòng (lưu trú/vệ sinh/bảo trì) hiện cập nhật rời rạc — chỉ lễ tân nhập vào hệ thống tại quầy, buồng phòng/bảo trì báo miệng/điện thoại. Sản phẩm cho 1 khách sạn giả định 50 phòng, dữ liệu giả lập. (2026-09-15, `/prd`)

## Người dùng & thuật ngữ

| Nhóm user | Gọi là gì trong doc | Ghi chú | Ngày |
|---|---|---|---|
| Quản lý khách sạn | quản lý | Toàn quyền trừ nhận/trả phòng; xem dashboard, nhật ký, AI; quản lý tài khoản/gán vai trò | 2026-09-15 |
| Lễ tân | lễ tân | Nhận/trả phòng tại quầy (web); tra cứu danh mục phòng; đặt/gỡ ngừng phục vụ | 2026-09-23 |
| Nhân viên buồng phòng–bảo trì | nv buồng phòng–bảo trì | MỘT vai trò gộp trong MVP (đã chốt 2026-09-15): xem việc được giao, báo hỏng, đánh dấu đã dọn/đã sửa xong trên mobile Android | 2026-09-15 |
| Khách thuê phòng | khách | KHÔNG dùng hệ thống — chỉ là đối tượng dữ liệu (tên khách khi nhận phòng) | 2026-09-15 |
| Hệ thống / Người vận hành | hệ thống / người vận hành | Hệ thống tự khóa TK, hết phiên, ghi nhật ký (actor SYSTEM); Người vận hành (WPCTeam) phục hồi quản trị ngoài app | 2026-09-15 |

## Thị trường & ngôn ngữ

Sản phẩm tiếng Việt; đồ án/demo MVP 8 tuần của WPCTeam (3 người), nghiệm thu Flutter Web + Android, iOS mở rộng. (2026-09-15, `/prd`)

## Compliance

Dữ liệu giả lập — không dùng dữ liệu khách thật; dữ liệu gửi API AI chỉ là số liệu tổng hợp không định danh khách. (2026-09-15, `/prd`)

## Mô hình kinh doanh

Không áp — đồ án môn học/demo; ngân sách tiền mặt 1.500.000 VNĐ là hạn mức lập kế hoạch. (2026-09-15, `/prd`)
