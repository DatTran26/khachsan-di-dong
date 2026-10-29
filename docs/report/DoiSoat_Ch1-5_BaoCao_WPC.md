# Đối soát Chương 1–5 báo cáo WPC

Ngày rà soát: 29/10/2026. Bản gốc: `Bao_Cao_WPC_Ver2_1_1_1.docx`. Bản đã sửa và rút gọn: `Bao_Cao_WPC_Ver2_1_1_3.docx`.

Lưu ý: số hình và số bảng ở mục 1–5 là **số của bản gốc**. Sau khi rút gọn, Chương 3 được đánh số lại (xem mục 6).

Nguồn đối chiếu là file `khach-san-di-dong-wps-daily-package-review.xlsx` (WPS 28/10), gồm 178 công việc, 97 gói ngày và 572 giờ. Trần ngân sách 151.000.000 VNĐ, đơn giá 237.500 VNĐ/giờ.

Vai trò đã chốt:

| Thành viên | Vai trò |
|---|---|
| Trần Tấn Đạt | PM / BA / Release |
| Kim Ngọc Hoàng | Backend / CSDL / AI |
| Ngô Quốc Bảo | Flutter Web, Android / UI-UX / QA |

Nguyên tắc sửa: giữ nguyên định dạng (style, bảng, bố cục). Chỉ đổi chữ trong đoạn và ô bảng, sửa hoặc thay hình. Chương 6–7 không bị đụng tới vì đã ghi đúng vai trò.

---

## 1. Nội dung đã có (Chương 1–5)

| Chương | Đã có | Đánh giá |
|---|---|---|
| 1 | Tên nhóm và đề tài; Bảng 1.1 thành viên; Bảng 1.2 phân công theo sprint; bối cảnh, hiện trạng, phát biểu bài toán; Bảng 1.3 SMART; phạm vi và ngoài phạm vi; Bảng 1.4 đối tượng sử dụng | Đủ khung. Đã sai vai trò Hoàng/Bảo (đã sửa). Còn thiếu mục 1.5.2 (đã bổ sung) |
| 2 | 2.1 thời gian, vật liệu (Bảng 2.1); phát biểu bài toán; cấp quyền; tôn chỉ 2.2.1–2.2.9 (Bảng 2.2–2.5); phát biểu phạm vi (Bảng 2.6); WBS (Hình 2.1) | Số liệu 572 giờ / 151 triệu / 178 việc đã khớp. Đã sai vai trò (đã sửa) |
| 3 | Bảng 3.1 ước lượng theo nhóm việc; Bảng 3.2 tải theo sprint; Bảng 3.3 lịch báo cáo ngày; PERT 4 nhánh và tổng quát (Hình 3.1–3.5, Bảng 3.4); tối ưu Sprint 4 (Bảng 3.5–3.7, Hình 3.6) | Số liệu khớp WPS. Sai vai trò trong bảng, chữ và hình (đã sửa). Sai số ngày-người (đã sửa) |
| 4 | Bảng 4.1 đơn giá; Bảng 4.2 chi phí theo WBS; Bảng 4.3 chi phí 12 gói cấp 4; Hình 4.1 Gantt; EVM tại 03/10 (Bảng 4.4, 4.5) | Số liệu chi phí và EVM tính lại đều khớp. Sai vai trò (đã sửa). Sai một mã gói (đã sửa). Hình 4.1 đã thay bằng Gantt tổng quát |
| 5 | Bảng 5.1 tiêu chuẩn chung; Bảng 5.2–5.5 kiểm tra 4 đợt; Bảng 5.6 vấn đề; Pareto (Hình 5.1); 80-20 (Bảng 5.7); Ishikawa (Hình 5.2–5.3); Bảng 5.8 kế hoạch Sprint 3 | Số liệu Pareto khớp (142 lần, 114 lần = 80,3%). Sai vai trò ở cột phụ trách, cột người kiểm tra và Hình 5.2 (đã sửa) |

## 2. Kiểm tra theo số liệu đã chốt

Các số dưới đây được tính lại từ WPS, sau khi đổi người phụ trách theo vai trò mới.

| Hạng mục | Trong báo cáo | Tính lại từ WPS | Kết quả |
|---|---|---|---|
| Tổng giờ công | 572 | 572 (214 dòng việc, 178 mã WBS) | Khớp |
| Số công việc | 178 công việc gốc, 214 dòng chi tiết, 97 gói ngày, 23 nhóm việc | 178 / 214 / 97 / 23 | Khớp |
| Trần ngân sách | 151.000.000 | 135.850.000 + 660.000 + 800.000 + 13.690.000 | Khớp |
| Nhân công | 572 × 237.500 = 135.850.000 | Như báo cáo | Khớp |
| Giờ theo sprint | 230 / 153 / 127 / 62 | Như báo cáo | Khớp |
| Đạt theo sprint | 80 / 8 / 12 / 18 = 118 | Như báo cáo | Khớp |
| Hoàng (Backend) theo sprint | 70 / 66 / 64 / 29 = 229 | 80 / 79 / 51 / 15 = **225** | Sai, đã sửa |
| Bảo (Flutter/QA) theo sprint | 80 / 79 / 51 / 15 = 225 | 70 / 66 / 64 / 29 = **229** | Sai, đã sửa |
| Chi phí theo người | Hoàng 54.387.500; Bảo 53.437.500 | Hoàng 53.437.500 (39,3%); Bảo 54.387.500 (40,0%) | Đã sửa |
| Ngày-người có gói việc | Đạt 18, Hoàng 32, Bảo 31 | Đạt **19**, Hoàng **31**, Bảo **31** (tổng 81) | Sai, đã sửa |
| Bảng 3.1 (thời lượng, gói, giờ của 33 dòng) | — | Khớp từng dòng | Khớp |
| Bảng 3.3 (giờ theo ngày, số gói) | — | Khớp 36 ngày | Khớp (đã đổi cột) |
| PERT (TE, σ, Z, xác suất, chi phí đường) | — | Tính lại khớp | Khớp |
| Bảng 4.2–4.5 (chi phí, PV/EV/AC, CPI 0,92, SPI 0,96, EAC, VAC) | — | Tính lại khớp | Khớp |
| Pareto (142 lần, 9 vấn đề = 80,3%) | — | Tính lại khớp | Khớp |

## 3. Số liệu và vai trò chưa thống nhất (đã sửa trong bản Ver2_1_1_2)

1. **Vai trò Hoàng và Bảo bị ghi ngược trong toàn bộ Chương 1–5.** Bản Ver2 ghi Hoàng làm Flutter/UI-UX/QA và Bảo làm Backend/CSDL/AI, trong khi Chương 6–7 ghi đúng. Đã sửa 115 vị trí:
   - Bảng 1.1: cột vai trò.
   - Bảng 1.2: tên người theo từng khối việc.
   - Bảng 2.1: dòng Nhân lực.
   - Bảng 2.2, mục 2.2.8, Bảng 2.4 (gồm email và điện thoại theo người), đoạn "Kiểm tra chéo".
   - Bảng 3.1 cột Phụ trách, Bảng 3.2, tiêu đề cột Bảng 3.3, các đoạn PERT 3.2.1–3.3.4.
   - Bảng 4.3, các đoạn 4.1–4.3.
   - Cột người kiểm tra ở Bảng 5.2–5.5, cột phụ trách ở Bảng 5.7–5.8, mục 5.5.3.

   Giữ nguyên tên ở trang bìa, Bảng 1.1 (họ tên, MSSV, liên hệ), Bảng 2.5 (chữ ký) và câu "K13–K16 do Ngô Quốc Bảo tổng hợp" (Bảo là QA, đúng vai trò).
2. **Giờ công từng người** đổi theo vai trò: Hoàng 225 giờ, Bảo 229 giờ. Các chỗ đã sửa: Bảng 1.2, mục 1.1.3, Bảng 2.2, mục 2.2.8, Bảng 3.2, mục 4.1.
3. **Số ngày-người** ở mục 3.1: đổi "Đạt 18, Hoàng 32, Bảo 31" thành "Đạt 19, Hoàng 31, Bảo 31".
4. **Mã gói sai** ở giải pháp mục 4.3.2: đổi "bộ test vận hành (2.2.5.10)" thành "(2.2.5.8)" cho khớp Bảng 4.3 và 4.4.
5. **Hình có tên người theo vai trò cũ** đã được sửa trên ảnh:
   - Hình 3.1, 3.2, 3.3, 3.4, 3.6: tiêu đề cột Hoàng và Bảo.
   - Hình 3.5: nhãn tên trong 33 gói găng.
   - Hình 5.2: dòng "Hoàng 225 h, Bảo 229 h" và dòng "Sprint 1: Đạt, Hoàng kín 80/80 giờ".

## 4. Nội dung còn thiếu hoặc cần bổ sung

| # | Nội dung | Trạng thái |
|---|---|---|
| 1 | Mục 1.5.2 Các bên liên quan (SH-01 → SH-10) | **Đã bổ sung**, dẫn sang Bảng 7.1 và 7.2 |
| 2 | Logo WPCTeam và ý nghĩa tên nhóm (Chương 1) | Đã có (nhóm xác nhận) |
| 3 | Kiểm soát thay đổi phạm vi (Chương 2) | Chưa có. Xem giải thích ngay dưới bảng |
| 4 | Kết quả thực tế Sprint 3–4 và UAT 26/10 (Bảng 5.2–5.5, mục 5.5.3) | Vẫn là số liệu tại 03/10; báo cáo đã ghi rõ thời điểm. Cần điền nếu có số đo thật |
| 5 | Kết quả đo thật cho realtime ≥95/100 và AI ≥18/20 | Chưa có (để cho Chương 10) |
| 6 | Mục lục, danh mục hình, danh mục bảng | Đã sửa chữ các dòng bị đổi hoặc bỏ. Nên bấm Update Field (F9) trong Word trước khi nộp để cập nhật số trang |

**Giải thích mục 3: kiểm soát thay đổi phạm vi là gì và báo cáo đang thiếu gì**

Kiểm soát thay đổi phạm vi là cách nhóm xử lý khi có yêu cầu thêm, bớt hoặc dời việc sau khi phạm vi đã chốt (baseline ký ngày 15/09). Quy trình gồm 4 bước:

1. Ai được đề xuất thay đổi.
2. Ai đánh giá tác động lên thời gian, chi phí và chất lượng.
3. Ai duyệt (trưởng nhóm, và giảng viên nếu đổi hạn hoặc ngân sách).
4. Ghi vào đâu (Decision Log), rồi cập nhật lại WBS và kế hoạch Project.

Hiện Chương 2 chỉ có một câu nguyên tắc ở cuối mục 2.2.9: "Thay đổi làm tăng phạm vi, ngân sách hoặc ảnh hưởng hạn nộp phải được thống nhất với giảng viên". Báo cáo chưa mô tả 4 bước trên và chưa có ví dụ thật nào. Dự án đã có sẵn 3 ví dụ:

- **D-17 (04/10/2026):** tách mốc bàn giao 27/10 và mốc nghiệm thu 02/11, để có khoảng 4–5 ngày làm việc dự phòng. Nguồn: `docs/project-charter.md`.
- **Mốc trạng thái 24/09:** việc Sprint 1 chưa xong được lập lịch lại sang Sprint 2. Đây chính là các nhóm 2.2.2–2.2.4 trong Bảng 3.1.
- **Đóng băng phạm vi 16/10:** sau ngày này không nhận tính năng mới, chỉ sửa lỗi.

Đề xuất: thêm một đoạn khoảng 5–6 dòng ở cuối mục 2.3, gồm quy trình 4 bước và 3 ví dụ trên. Nhóm duyệt nội dung đoạn này trước khi chèn vào Word.

## 5. Phần phải sửa hoặc làm lại (ngoài file Word)

1. **File nguồn WPS (`.xlsx` và `.xml`) vẫn gán ngược người**: việc mã `S*-BAO-*` là backend nhưng ghi người làm Bảo, việc mã `S*-HOANG-*` là Flutter nhưng ghi người làm Hoàng. Cần đổi Resource Names trước khi lưu thành `.mpp`. File Excel Gantt mới đã dùng vai trò đúng.
2. WPS còn 21 liên kết phụ thuộc không giữ được khi gom gói ngày (18 cùng ngày, 3 đảo thứ tự). Báo cáo đã nêu ở mục 3.1, nhưng nhóm chưa xử lý.
3. Định dạng tiêu đề "1.3.", "1.4.", "1.5." thừa dấu chấm. Các mục 1.3.1, 1.4.1, 1.5.1 đang dùng style Normal nên không lên mục lục. **Chưa sửa** vì yêu cầu là không đổi format.
4. Ngày trên bìa và trong Lời cảm ơn là 28/10/2026. Cần đổi sang ngày nộp chính thức.

## 6. Rút gọn báo cáo: phần đã chuyển sang Excel

Nguyên tắc: phần nào Excel đã có đủ chi tiết thì bỏ khỏi Word. Word chỉ giữ bảng tổng hợp, sơ đồ tổng quát và phần phân tích. Bản 1_1_3 còn 69 trang (bản 1_1_2 có 74 trang).

| Đã bỏ khỏi Word (đánh số bản gốc) | Thuộc | Nay nằm ở |
|---|---|---|
| Hình 3.1–3.4: sơ đồ mạng PERT nhánh Sprint 1–4 | Ch3, mục 3.2.1–3.2.4 | `Chuong3_PERT_KhachSanDiDong.xlsx`, sheet Sprint 1–4 |
| Hình 3.6: sơ đồ mạng PERT Sprint 4 sau tối ưu | Ch3, mục 3.3.3 | `Chuong3_PERT_KhachSanDiDong.xlsx`, sheet Sprint 4 sau tối ưu |
| Bảng 3.3: lịch 36 kỳ báo cáo ngày và giờ theo ngày | Ch3, mục 3.1 | `Chuong3-4_Gantt_KhachSanDiDong.xlsx`, sheet Giờ theo ngày |
| Hình 4.1 cũ: Gantt 12 gói cấp 4 | Ch4, mục 4.2 | `Chuong3-4_Gantt_KhachSanDiDong.xlsx`, sheet Sprint 2 |

Câu văn trỏ tới hình hoặc bảng đã bỏ được sửa thành trỏ tới đúng sheet Excel. Đánh số lại Chương 3:

- Hình 3.5 thành **Hình 3.1** (đường găng PERT tổng quát).
- Bảng 3.4, 3.5, 3.6, 3.7 thành **Bảng 3.3, 3.4, 3.5, 3.6**.

## 7. Nội dung Excel và báo cáo thuộc chương nào

| File / phần | Nội dung | Thuộc chương, mục trong báo cáo |
|---|---|---|
| **Chuong3_PERT_KhachSanDiDong.xlsx** | | **Chương 3: Quản lí thời gian** |
| sheet Sprint 1 | Bảng tính PERT 40 gói (O, M, P, TE, σ², ES, EF, LS, LF, DT bằng công thức), 10 đường dài nhất và đường ngắn nhất, sơ đồ mạng có mũi tên | 3.2.1 Sơ đồ PERT nhánh Sprint 1 |
| sheet Sprint 2 | Như trên, 26 gói, 30 đường | 3.2.2 |
| sheet Sprint 3 | Như trên, 21 gói, 16 đường | 3.2.3 |
| sheet Sprint 4 | Như trên, 10 gói, 8 đường (trước tối ưu) | 3.2.4 và 3.3.1 (Bảng 3.4) |
| sheet Sprint 4 sau tối ưu | Mạng sau fast tracking, 8 đường, T = 5,14 ngày | 3.3.2–3.3.4 (Bảng 3.5, 3.6) |
| sheet Tổng quan | Tổng hợp 4 nhánh và toàn dự án, chuỗi 4 sprint, 36 gói găng của toàn dự án | 3.2.5 (Bảng 3.3, Hình 3.1) |
| **Chuong3-4_Gantt_KhachSanDiDong.xlsx** | | **Chương 3 và Chương 4** |
| sheet Tổng hợp | Gantt 4 sprint, 23 nhóm việc, các mốc; bảng giờ theo người và sprint | 3.1 (Bảng 3.1, 3.2) và 4.2 (Hình 4.1) |
| sheet Sprint 1–4 | Gantt chi tiết đến từng công việc (cấp 3–5) | 3.1; riêng sheet Sprint 2 chứa 12 gói của Bảng 4.3 (mục 4.2, EVM 4.3) |
| sheet Giờ theo ngày | 36 kỳ báo cáo ngày, giờ từng người, số gói | 3.1 (thay Bảng 3.3 cũ) |
| **Bao_Cao_WPC_Ver2_1_1_3.docx** | | |
| Hình 2.1 WBS | Cấu trúc phân rã công việc | Chương 2, mục 2.4 |
| Hình 3.1 | Đường găng PERT tổng quát | Chương 3, mục 3.2.5 |
| Hình 4.1 | Gantt tổng quát theo sprint | Chương 4, mục 4.2 |
| Hình 5.1–5.3 | Pareto, Ishikawa | Chương 5, mục 5.4 và 5.5.2 |

Mỗi sheet Excel đều ghi dòng "Thuộc Chương …, mục …" ở đầu sheet.

## 8. Cách kiểm tra đã chạy

- Tính lại toàn bộ số liệu từ sheet `WPS Gantt Draft`: tổng giờ, giờ theo người và sprint, giờ theo ngày, số gói theo ngày và theo nhóm, người phụ trách từng nhóm.
- Tính lại PERT từ dữ liệu WPS. Kết quả khớp đúng báo cáo: số đường 776, 30, 16, 8 (tổng 2.979.840); đường găng và TE 10,37 / 10,34 / 10,26 / 6,18; toàn dự án 37,15 ngày, σ 0,71, xác suất 5,2%; Sprint 4 sau tối ưu 5,14 ngày; chi phí từng đường khớp.
- Tính tay lại chi phí, EVM và Pareto. Tất cả khớp, trừ các lỗi nêu ở mục 3.
- Mở cả hai file Excel trong Excel. Công thức tự tính lại đúng: tổng 572 giờ (118 / 225 / 229), số ngày có việc 19 / 31 / 31. Mũi tên sơ đồ mạng hiển thị đúng.
- Word mở được bản 1_1_3 (69 trang). Mọi dẫn chiếu hình và bảng trong Chương 3 đã được kiểm tra, không còn trỏ tới hình hoặc bảng đã bỏ. **Chưa soát bằng mắt từng trang Word.** Khi mở, bấm F9 để cập nhật số trang ở mục lục và các danh mục.
