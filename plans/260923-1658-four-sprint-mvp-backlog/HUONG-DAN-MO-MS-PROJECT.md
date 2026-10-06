# Mở kế hoạch trong Microsoft Project 2021

File dùng để mở:

`plans/260923-1658-four-sprint-mvp-backlog/Ke-hoach-KhachSanDiDong-MSProject-2021.xml`

File này đã có cấu trúc sprint, 178 task lá, 5 mốc, quan hệ Finish-to-Start, tài nguyên và lịch. Không import file Excel/CSV cũ vào project đang mở: wizard để trống cột Predecessors.

## Cách mở

1. Trong Project 2021, chọn **File → Open**.
2. Đổi bộ lọc kiểu file thành **XML Format (*.xml)**.
3. Chọn `Ke-hoach-KhachSanDiDong-MSProject-2021.xml`.
4. Nếu Project hỏi lịch, giữ lịch nhúng tên **Lịch Khách Sạn** (thứ Hai–thứ Sáu, 08:00–12:00 và 13:00–17:00).
5. **File → Save As** thành `.mpp`.

Không chèn file này vào Gantt đang có hai dòng `Khach San Sach` và `Xác định sponsor...`. Project đó chưa có link; mở XML tạo lịch mới, đủ mũi tên phụ thuộc.

## Sau khi mở, kiểm tra

- Gantt có task cha theo 4 sprint và các nhóm khảo sát, UI, backend, Flutter, DevOps, UAT.
- Cột **Predecessors** của task lá có số, quan hệ **FS**.
- **Resource Sheet** có `Đạt`, `Hoàng`, `Bảo`, nhóm `WPC`, lịch `Lịch Khách Sạn`.
- Cột **Text1** là mã WBS, **Text2** là sprint, **Text3** là `Đã xong` / `Cần đối chiếu` / `Kế hoạch`, **Text4** là đầu ra.
- Chỉ 6 task có **% Complete = 100**: PRD, bộ đặc tả 9 feature, ERD/use case/wireframe, project profile, Gitflow/SECURITY, Design Token guideline.
- Mốc cuối có **Deadline 27/10/2026**.

Đổi tên cột trong **Project → Custom Fields** nếu muốn: Text1 → `WBS ID`, Text2 → `Sprint`, Text3 → `Trạng thái`, Text4 → `Đầu ra`.

## Highlight đường phụ thuộc

Chọn một task lá, không chọn task tổng. Trên tab **Format** hoặc menu **Highlight**:

| Mục | Ý nghĩa |
|---|---|
| Predecessors | Mọi việc đứng trước, kể cả việc có độ trễ |
| Driving Predecessors | Việc quyết định ngày bắt đầu của task đang chọn |
| Successors | Mọi việc đứng sau |
| Driven Successors | Việc bị task đang chọn quyết định ngày bắt đầu |

Cột Predecessors có bốn loại quan hệ:

| Ký hiệu | Tên | Khi nào dùng |
|---|---|---|
| FS | Finish-to-Start | Việc sau bắt đầu khi việc trước kết thúc. Dùng cho sign-off, migration, cổng sprint, và chuỗi việc của cùng một người |
| SS | Start-to-Start | Việc sau bắt đầu khi việc trước bắt đầu, có thể trễ vài giờ. UI bắt đầu khi API của cùng luồng bắt đầu |
| FF | Finish-to-Finish | Việc sau kết thúc khi việc trước kết thúc. QA, OpenAPI, security review và hồ sơ bàn giao kết thúc cùng mốc kỹ thuật |
| SF | Start-to-Finish | Việc sau chỉ được kết thúc khi việc trước bắt đầu. Quan sát AS-IS, catalogue lỗi, checklist go/no-go và inventory môi trường giữ mở đến lúc việc kế tiếp bắt đầu |

Task để **Auto Scheduled**. Chuỗi việc của cùng một người vẫn là FS, vì một người không làm hai việc cùng lúc.

## Khung lịch 08/09–27/10

Lịch được xếp từ **08/09/2026** đến **27/10/2026**. Mốc bàn giao rơi vào **27/10/2026 lúc 11:00**. Cổng tính được: Sprint 1 ngày 28/09, Sprint 2 ngày 09/10, Sprint 3 ngày 16/10.

Mở lại file XML bằng **File → Open**. File `.mpp` đang sửa tay vẫn giữ lịch cũ. Không đặt `% Complete = 100` cho task `Cần đối chiếu` khi chưa có PR, commit hoặc biên bản.
