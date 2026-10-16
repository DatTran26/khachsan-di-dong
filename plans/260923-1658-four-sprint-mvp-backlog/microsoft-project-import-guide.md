# Hướng dẫn cũ — không dùng file Excel để lấy phụ thuộc

Phụ thuộc Finish-to-Start nằm trong file XML. Mở theo [HUONG-DAN-MO-MS-PROJECT.md](./HUONG-DAN-MO-MS-PROJECT.md), file `Ke-hoach-KhachSanDiDong-MSProject-2021.xml`. Wizard Excel/CSV không ghi cột Predecessors vào project đang mở.

# Hướng dẫn đưa 150 task vào Microsoft Project

## File dùng để import

Mở [microsoft-project-import.csv](./microsoft-project-import.csv). File có 178 task leaf, mã WBS ổn định và đủ các cột để map vào Project.

| Cột CSV                                              | Ý nghĩa                                                             |
| ---------------------------------------------------- | ------------------------------------------------------------------- |
| `WBS ID`                                             | Mã task ổn định, ví dụ `S2-BAO-009`; dùng để trao đổi và truy vết   |
| `Task Name`                                          | Tên công việc đưa vào cột Name của Microsoft Project                |
| `Sprint`                                             | S1/S2/S3/S4; dùng để group/filter                                   |
| `Sprint Start (Reference)`, `Sprint End (Reference)` | Mốc sprint tham chiếu, **không map vào Start/Finish** của Project   |
| `Duration`                                           | Ước lượng sơ bộ; hiện là 1d để team lập lịch chi tiết trong Project |
| `Resource Names`                                     | Người chịu trách nhiệm: Tấn Đạt, Bảo hoặc Ngọc Hoàng                |
| `Status`                                             | Đã xong, Cần đối chiếu hoặc Kế hoạch                                |
| `Parent Task ID`                                     | Mã task cha để hiểu bối cảnh; không phải predecessor tự động        |

## Microsoft Project 2021 — bắt buộc xử lý mã hóa trước khi import

Ảnh Import Wizard cho thấy text tiếng Việt thành `XÃ¡c Ä‘á»‹nh...`. Đây là lỗi **encoding**, không phải lỗi dữ liệu: file CSV là UTF-8 còn Text Import Wizard của Project 2021 đang đọc theo ANSI.

**Không bấm Finish ở màn hình hiện tại.** Thực hiện cách khuyến nghị dưới đây:

1. Bấm **Cancel** trong Project 2021.
2. Mở Excel → **Data → From Text/CSV** → chọn `microsoft-project-import.csv`.
3. Trong hộp preview của Excel, chọn **File Origin: 65001: Unicode (UTF-8)**. Chỉ tiếp tục khi tất cả tiếng Việt hiển thị đúng, ví dụ `Xác định sponsor, người quyết định`.
4. Chọn **Load** → **File → Save As** → lưu kiểu **Excel Workbook (`.xlsx`)**, ví dụ `microsoft-project-import-2021-wpc.xlsx`.
5. Trong Project 2021, chọn **File → New → New from Excel workbook** (hoặc File → Open và chọn Excel Workbook), sau đó dùng Import Wizard cho Excel.

Project Desktop 2021 có Import Wizard cho Excel workbook; cách này giữ Unicode tiếng Việt ổn định hơn Text Import. Microsoft cũng xác nhận Project 2021 hỗ trợ custom Text fields để nhập metadata không có trường chuẩn. [Import Excel data into Project](https://support.microsoft.com/en-us/project/import-excel-data-into-project), [Text1–Text30 fields](https://support.microsoft.com/en-gb/project/text1-30-fields).

Nếu bắt buộc dùng file text, hãy Save As **Unicode Text (`*.txt`)** trong Excel (không phải CSV), sau đó import `.txt`; mở preview và dừng lại nếu tiếng Việt còn lỗi.

## Bước 1 — Chuẩn bị Project

1. Mở đúng file `.mpp` đang có Resource Sheet trong ảnh; **không tạo Blank Project**.
2. Vào **Project → Project Information** và kiểm tra Start date là `08/09/2026`.
3. Vào **Project → Change Working Time** và giữ lịch `Lịch Khách Sạn`/quy ước ngày làm việc hiện có của team.
4. Resource Sheet hiện đã có `Đạt`, `Hoàng`, `Bảo` trong nhóm `WPC`; giữ nguyên các dòng này, Max Units, đơn giá và Base Calendar. Không import lại tab `Resources`.
5. Quay lại **Gantt Chart**: project đích phải chưa có task thật nào (chỉ có dòng trống mặc định). Cột `Predecessors` trong workbook dùng ID từ 1–178; nếu đã có task, ID sẽ lệch và phải tạo lại map predecessor.
6. Đặt Task Mode là `Auto Scheduled` cho các task mới. Nếu muốn giữ kế hoạch theo sprint trước khi nối dependency, có thể dùng `Manually Scheduled` trong lần import đầu rồi chuyển dần sang Auto Scheduled.

## Bước 1.5 — Import Resource Sheet (chỉ khi project chưa có resource)

Chỉ import resource **trước** task nếu Resource Sheet của project đang trống. Nếu đã có `Đạt`, `Hoàng`, `Bảo` như project hiện tại, bỏ qua toàn bộ bước này để tránh tạo resource trùng.

1. Trong Import Wizard của workbook, chọn source table **`ProjectResources`** hoặc sheet **Resources**, rồi chọn loại dữ liệu **Resources**.
2. Chọn import vào project hiện đang mở.
3. Map các cột:

| Workbook source field     | Microsoft Project resource field |
| ------------------------- | -------------------------------- |
| `Resource Name`           | `Name`                           |
| `Type`                    | `Type`                           |
| `Max Units`               | `Max Units`                      |
| `Base Calendar`           | `Base Calendar`                  |
| `Group`                   | `Group`                          |
| `Code`                    | `Code`                           |
| `Role Description`        | `Text1` (Resource)               |
| `Capacity Hours per Week` | `Number1` (Resource)             |

4. Mở **View → Resource Sheet**. Với project hiện tại, giữ nguyên nhóm `WPC`, lịch `Lịch Khách Sạn`, Max Units và các đơn giá bạn đã cấu hình; không ghi đè bằng dữ liệu mẫu.
5. Workbook task dùng đúng tên `Đạt`, `Hoàng`, `Bảo`, nên Project sẽ gán vào ba resource hiện hữu thay vì tạo dòng mới.

## Bước 2 — Import workbook trong Project 2021

1. Trong project hiện hành, mở Import Wizard và chọn file `microsoft-project-import-2021-wpc.xlsx`. Chỉ chọn table `ProjectTasks` (hoặc sheet `Tasks`); bỏ qua `ProjectResources`/`Resources`.
2. Trong **Import Wizard**, chọn **New map** → chọn loại dữ liệu **Tasks**.
3. Map các cột như sau:

| CSV source field           | Microsoft Project target field |
| -------------------------- | ------------------------------ |
| `Task Name`                | `Name`                         |
| `Duration`                 | `Duration`                     |
| `Resource Names`           | `Resource Names`               |
| `WBS ID`                   | `Text1`                        |
| `Sprint`                   | `Text2`                        |
| `Status`                   | `Text3`                        |
| `Parent Task ID`           | `Text4`                        |
| `Sprint Start (Reference)` | `Date1`                        |
| `Sprint End (Reference)`   | `Date2`                        |
| `Predecessors`             | `Predecessors`                 |

4. `Predecessors` đã là quan hệ **Finish-to-Start (FS)** theo ID task Project, ví dụ `1FS`; không sửa các số này trước khi import.
5. **Không map** hai cột mốc sprint tham chiếu vào trường `Start` hoặc `Finish`. Map vào `Date1`/`Date2` để giữ mốc tham chiếu mà không tạo constraint cho lịch từng activity.
6. Lưu map với tên `KhachSanDiDong-Task-Import`; bấm Finish.
7. Kiểm tra có đúng **178 dòng task** trong Gantt Chart và cột `Text1` hiển thị từ `S1-DAT-001` tới `S4-HOANG-008`.

### Map chính xác tại màn hình trong ảnh

| From: Text File/Excel Field | To: Microsoft Project Field | Thao tác                                                       |
| --------------------------- | --------------------------- | -------------------------------------------------------------- |
| `WBS ID`                    | `Text1`                     | Thay dòng đỏ `(not mapped)` bằng Text1                         |
| `Task Name`                 | `Name`                      | Giữ nguyên; đây là map đúng                                    |
| `Sprint`                    | `Text2`                     | Đổi từ `Sprint` sang Text2 để dùng như metadata/filter ổn định |
| `Sprint Start (Reference)`  | `Date1`                     | Giữ mốc sprint mà không ảnh hưởng Gantt                        |
| `Sprint End (Reference)`    | `Date2`                     | Giữ mốc sprint mà không ảnh hưởng Gantt                        |
| `Duration`                  | `Duration`                  | Giữ nguyên                                                     |
| `Resource Names`            | `Resource Names`            | Map khi cuộn xuống các dòng sau                                |
| `Status`                    | `Text3`                     | Không map vào trường Status hệ thống                           |
| `Parent Task ID`            | `Text4`                     | Map khi cuộn xuống các dòng sau                                |

Sau import, đổi tên custom fields trong **Project → Custom Fields** hoặc bằng Insert Column/right-click: `Text1` → `WBS ID`, `Text2` → `Sprint`, `Text3` → `Trạng thái nội bộ`, `Text4` → `Task cha WBS`, `Date1` → `Sprint Start Reference`, `Date2` → `Sprint End Reference`. Các trường Text1–Text30 và Date1–Date10 là trường custom chính thức của Project 2021, phù hợp để lưu metadata này. [Custom fields in Project desktop](https://support.microsoft.com/en-US/project/custom-fields-in-project-desktop).

## Bước 3 — Tạo cấu trúc 4 sprint

1. Chèn bốn task summary ở đầu danh sách: `Sprint 1 — Nền tảng`, `Sprint 2 — Luồng vận hành`, `Sprint 3 — Giám sát & AI`, `Sprint 4 — Release & bàn giao`.
2. Lọc theo `Text2` lần lượt S1, S2, S3, S4; kéo các task của mỗi sprint dưới summary tương ứng và dùng **Task → Indent Task**.
3. Đặt mốc summary theo sprint:

| Summary task                  | Start      | Finish     |
| ----------------------------- | ---------- | ---------- |
| Sprint 1 — Nền tảng           | 08/09/2026 | 21/09/2026 |
| Sprint 2 — Luồng vận hành     | 22/09/2026 | 05/10/2026 |
| Sprint 3 — Giám sát & AI      | 06/10/2026 | 19/10/2026 |
| Sprint 4 — Release & bàn giao | 20/10/2026 | 27/10/2026 |

4. Tạo milestone cuối mỗi sprint có Duration `0d`: `S1 Gate passed`, `S2 End-to-end passed`, `S3 Dashboard & AI accepted`, `Release accepted`.

## Bước 4 — Lập dependency đúng cách

Microsoft Project chỉ nhận `Predecessors` theo số dòng ID nội bộ, vì vậy không import dependency trực tiếp từ mã `S1-DAT-001`. Dùng cột `Parent Task ID` và WBS chi tiết làm nguồn, sau đó liên kết trong Project bằng cách chọn task trước → task sau → **Task → Link Tasks**.

Ưu tiên tạo các dependency đường găng trước:

| Tiền nhiệm                         | Kế nhiệm                       | Quan hệ         |
| ---------------------------------- | ------------------------------ | --------------- |
| S1-DAT-007 (chốt source structure) | S1-BAO-001, S1-HOANG-001       | Finish-to-Start |
| S1-BAO-004 (Prisma baseline)       | S1-BAO-005, S1-BAO-006         | Finish-to-Start |
| S1-BAO-009 (login)                 | S1-HOANG-005                   | Finish-to-Start |
| S1-BAO-014 (Socket foundation)     | S1-HOANG-009                   | Finish-to-Start |
| S1 exit gate                       | toàn bộ Sprint 2               | Finish-to-Start |
| S2-BAO-007 (checkout)              | S2-BAO-009 (housekeeping)      | Finish-to-Start |
| S2-BAO-012 (audit service)         | S2-BAO-013 và Sprint 3 summary | Finish-to-Start |
| S2 exit gate                       | Sprint 3 summary               | Finish-to-Start |
| S3-BAO-004 (summary aggregate)     | S3-BAO-005 (OpenAI adapter)    | Finish-to-Start |
| S3-BAO-007 (fallback)              | S3-HOANG-006 (fallback UI)     | Finish-to-Start |
| S3 exit gate                       | Sprint 4 summary               | Finish-to-Start |
| S4-DAT-003 (CI/CD)                 | S4-ALL-01 release demo         | Finish-to-Start |

Sau khi đường găng chạy được, tiếp tục nối các task con theo cột `Phụ thuộc` trong [WBS chi tiết](./detailed-task-breakdown.md). Tránh đặt constraint `Must Start On` cho task thông thường; dùng dependency và calendar để Project tự tính lại lịch.

## Bước 5 — Phân bổ resource và effort

1. Kiểm tra cột `Resource Names`; nếu Project chưa nhận resource lúc import, chọn task → **Resource → Assign Resources** và gán theo owner trong CSV.
2. Hiển thị `Work`, `Remaining Work`, `% Complete`, `Baseline Start`, `Baseline Finish`.
3. Để effort trong WBS là nguồn tham chiếu. Sau import, thay Duration từng task theo complexity thực tế (1h/2h/4h/8h) và để Project tính Work theo calendar/resource.
4. Không giao cùng lúc hơn 8 giờ/ngày cho một người. Dùng **Resource → Level All** chỉ sau khi dependency chính đã hoàn chỉnh; review các thay đổi mà Leveling tạo ra.

## Bước 6 — Tracking thực tế

1. Trước khi Sprint 2 bắt đầu, cập nhật toàn bộ task Sprint 1 theo evidence thật: link PR/commit/test trong `Notes`; chỉ task có evidence mới đặt `% Complete = 100%`.
2. Cuối mỗi ngày, owner cập nhật `% Complete`, Actual Start, Remaining Duration và blocker trong `Notes`.
3. Khi task chậm, không đổi deadline 27/10 ngay: thêm predecessor/điều chỉnh remaining work, xem đường găng, rồi Đạt quyết định carry-over hoặc cắt phần không lõi.
4. Khi baseline lịch đã được team duyệt: **Project → Set Baseline → Set Baseline**. Không reset baseline sau mỗi lần trễ; tạo baseline mới chỉ khi có quyết định thay đổi kế hoạch được ghi nhận.
5. Tạo view lọc nhanh: `Text2 = S2`, `Resource Names = Bảo`, hoặc `Text3 = Cần đối chiếu` để review hằng ngày.

## Kiểm tra sau import

- [ ] Có 178 task leaf và 4 summary task tạo thêm trong Project.
- [ ] Ba resource được gán đúng, không task nào mang owner mơ hồ.
- [ ] Các gate liên sprint và dependency đường găng đã nối.
- [ ] Deadline release là 27/10/2026.
- [ ] Sprint 1 không bị đánh 100% khi chưa có evidence source/test.
- [ ] Baseline được lưu sau khi team review tải resource.
