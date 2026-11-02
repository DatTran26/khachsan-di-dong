# Báo cáo tiến độ và mức sẵn sàng ship dự án Khách Sạn Di Động (WPCTeam)

*Bản gốc lập ngày 31/10/2026; cập nhật trạng thái Git/GitHub ngày 02/11/2026. Nguồn: 26 file hồ sơ quản lý dự án (Chương 1–9, Gantt, PERT, WPS ngày 28/10), repo, 184 issue đang mở, pull request và GitHub Actions.*

## 1. Kết luận nhanh

| Hạng mục | Đánh giá |
|---|---|
| **Tiến độ** | 🔴 **Chậm.** Mốc bàn giao trong kế hoạch là **27/10** và tới ngày 02/11 chưa có đủ bằng chứng nghiệm thu, deploy và bàn giao để kết luận hoàn thành. |
| **Chức năng (phạm vi)** | 🟢 Code đã có đủ 9 feature MVP, mỗi feature đều có test. |
| **Bàn giao (Sprint 4)** | 🔴 Hầu như chưa xong: chưa deploy HTTPS, chưa chạy UAT, chưa có handover pack. |
| **Hồ sơ quản lý dự án** | 🟡 Đủ chương, nhưng số liệu trạng thái chưa cập nhật theo thực tế và có chỗ mâu thuẫn giữa các file. |

Chính tài liệu PERT của nhóm cũng đã dự báo trước điều này: xác suất xong đúng 27/10 chỉ khoảng **5,2%**, còn nếu có thêm 4 ngày dự phòng tới 02/11 thì gần như chắc chắn xong. Hiện nhóm đang dùng hết vùng dự phòng đó, và phần còn lại lại là phần khó nhất (deploy và nghiệm thu).

## 2. Kế hoạch so với thực tế, từng sprint

| Sprint | Kế hoạch | Thực tế (theo git) | Đánh giá |
|---|---|---|---|
| **S1 Nền tảng** 08–21/09 | Khảo sát, đặc tả 9 feature, kiến trúc, auth/RBAC, phòng, Socket.IO | Commit code đầu tiên vào **18/09**. Chương 3 thừa nhận đã phải lập lịch lại một phần việc ở mốc 24/09 | 🔴 Trễ khoảng 1 tuần, phần trễ dồn sang S2 |
| **S2 Vận hành** 22/09–05/10 | Check-in/out, buồng phòng, bảo trì, audit, realtime | Gắn tag **v0.1.0 ngày 06/10**, có đủ các luồng trên cùng optimistic lock | 🟢 Đúng hạn (lệch 1 ngày) và bù được phần trễ của S1 |
| **S3 Dashboard + AI** 06–19/10 | Dashboard, job quá hạn, AI summary, responsive/a11y | Cắt **v0.2.0 ngày 14/10** (dashboard, AI có fallback, ảnh nghiệm thu, test RBAC). Ngày 17/10 thêm đợt UI a11y/tablet và App CI | 🟢 Sớm hơn kế hoạch. Riêng tiêu chí cổng "AI đạt ≥18/20" **chưa chạy** vì còn thiếu API key |
| **S4 Bàn giao** 20–27/10 | CI/CD, migration, APK, UAT, Web HTTPS, handover | Tuần 19–25/10 **có 0 commit**. Từ 26–28/10 mới viết runbook, kịch bản UAT, sửa lỗi APK (quyền INTERNET, API_URL); song song làm thêm UI (ô phòng mới, slideshow đăng nhập) | 🔴 Chậm. Có một phần công sức đổ vào làm thêm UI không có trong kế hoạch S4 |

Nhịp commit theo tuần: W38: 5 · W39: 44 · W40: 17 · W41: 19 · **W42: 215** · **W43: 0** · W44: 49. Công việc dồn cục rồi bỏ trống một tuần đúng lúc vào Sprint 4.

**Ước lượng thô:** coi S1–S3 (510/572 giờ) là xong và S4 mới khoảng 30–40% thì giá trị thu được rơi vào khoảng **93% kế hoạch, SPI ≈ 0,93**. Đây là số ước lượng, không lấy từ giờ công thực tế. EVM trong Chương 4 (SPI 0,96, CPI 0,92 tại 03/10) cũng là **số liệu giả định**, như chính chương đó ghi.

## 3. Đã hoàn thiện

- **9 feature có code ở cả server và app:** auth-roles, room-catalog (thêm room-types), check-in-out, housekeeping (có ảnh nghiệm thu), maintenance, audit-log, realtime-sync (banner mất kết nối, khóa ghi), room-dashboard (thẻ lọc, cảnh báo quá hạn), ai-ops-summary (có fallback và trần ngân sách).
- **Test:** server có 16 file test (RBAC matrix, optimistic lock, e2e vòng đời phòng, realtime…); app có 15 file test cùng 2 file helper/support trong `app/test` sau khi bổ sung regression test reconnect.
- **CI:** có `backend-ci.yml` và `app-ci.yml` (analyze, test, build web, biome).
- **Release:** v0.1.0 (06/10) và v0.2.0 (14/10) đã vào `main`.
- **Tài liệu:** BRD/PRD/URD/SRS cho 9 feature; đủ Chương 1–9 cùng Gantt, PERT, rủi ro, truyền thông; runbook deploy/rollback; kịch bản nghiệm thu AC-01…AC-09.

## 4. Chưa hoàn thiện

| # | Việc | Bằng chứng |
|---|---|---|
| 1 | **Web HTTPS trên VPS** | Runbook ghi rõ *"Chưa có trong repo: file cấu hình Nginx"*. Không thấy dấu hiệu nào cho thấy đã deploy |
| 2 | **UAT** | Ma trận kết quả AC-01…AC-09 trong `docs/qa/acceptance.md` còn trống, chưa có chữ ký |
| 3 | **Đánh giá AI 20 tình huống** | `ai-evaluation.md` vẫn là bản "chờ Đạt duyệt", bảng kết quả trống |
| 4 | **APK release** | Mới sửa cấu hình build ngày 28/10, chưa có ghi nhận đã build hay cài thử |
| 5 | **Phát hành chính thức** | Các thay đổi mới nhất của `develop-dat` và `develop-bao` đã vào `develop`; không còn pull request mở. Tuy nhiên `develop` chưa được promote qua `release/*` vào `main`, chưa có release 0.3.0 và `main` còn một commit không nằm trong `develop`, cần đối chiếu trước khi cắt release. |
| 6 | **Handover pack, benchmark realtime ≥95/100 ≤3s** | Chưa có kết quả |

## 5. Vấn đề trong hồ sơ quản lý (nên sửa trước khi nộp)

1. **Phân vai mâu thuẫn:** Chương 3 (docx) ghi Bảo làm backend, Hoàng làm Flutter. File Gantt xlsx và `plans/plan.md` lại ghi ngược lại: Hoàng làm Backend, Bảo làm Flutter/UI/QA.
2. **Đóng góp thực tế trên git lệch nhiều so với kế hoạch giờ công:**
   - HoangKim72: 92 commit, phần lớn ở server và app.
   - Đạt: 81 commit.
   - Bảo: 7 commit (5 commit app hồi tháng 9 và 2 commit báo cáo). Kế hoạch giao cho Bảo 225 giờ (39%).
   - Cursor Agent: 101 commit (ghi chú mã ngày 13/10), không gắn với thành viên nào.

   Giảng viên chấm qua lịch sử GitHub nên cần chuẩn bị bằng chứng cho phần việc làm ngoài git.
3. **WBS chưa được đối chiếu với thực tế:** trong 178 việc chỉ có 6 việc "Đã xong", 72 việc "Cần đối chiếu", 100 việc "Kế hoạch". Lịch WPS lại được duyệt **ngày 28/10, sau mốc bàn giao**. Ngoài ra còn 76 giờ ghi "Đã xong" dưới tên Đạt cần xác nhận.
4. **Sổ rủi ro chưa cập nhật:** 26 rủi ro, 0 rủi ro đã đóng. Rủi ro tiến độ đang xảy ra nhưng chưa phản ánh vào sổ.
5. **Số ngân sách không thống nhất:** Tôn chỉ ghi 1,5 triệu tiền mặt, Chương 4 ghi trần 151 triệu (tính cả nhân công), còn mẫu báo cáo tuần M1 vẫn dùng số cũ (30 triệu, 530 giờ, đơn giá 40–50k/giờ).
6. **Artefact tạm đã được commit:** lịch sử `develop-dat` có thư mục `.codex-temp/` cùng nhiều artefact sinh tự động. Đây là quyết định phạm vi đã được yêu cầu khi đẩy toàn bộ file; cần chủ động loại khỏi gói release nếu nhóm không muốn phân phối chúng.

## 6. Kiểm tra toàn bộ issue GitHub ngày 02/11

- Có **184 issue đang mở**, liên tục từ `#54` đến `#237`; không có issue đóng trong dải này.
- Tổng cộng có **368 checklist item chưa hoàn thành** và **0 checklist item đã được đánh dấu hoàn thành**. Vì issue yêu cầu cả evidence và reviewer phê duyệt, trạng thái này không đủ căn cứ để đóng tự động dù code hoặc PR liên quan đã tồn tại.
- Phân bố issue: S1 85 issue, S2 43 issue, S3 32 issue, S4 24 issue. Theo owner: Đạt 62, Bảo 63, Hoàng 59.
- Có **6 cặp trùng tiêu đề** cần owner xác nhận issue chuẩn trước khi đóng hoặc hợp nhất: `#73/#74`, `#78/#80`, `#79/#87`, `#76/#94`, `#77/#95`, `#75/#96`.
- Issue không được cập nhật theo tiến độ merge: ví dụ `#89` về GitFlow vẫn ghi “Cần xác minh” dù `AGENTS.md`, `SECURITY.md` và quy trình nhánh đã tồn tại; `#214` vẫn ghi “Kế hoạch” dù có PR candidate. Đây là backlog hygiene, không phải bằng chứng rằng 184 đầu việc đều chưa được triển khai.
- Không đóng issue hàng loạt trong đợt ship này vì chưa có evidence mapping và approval cho từng acceptance item.

## 7. Việc cần làm trước khi ship chính thức

1. **Đóng băng phạm vi:** dừng mọi việc làm thêm UI.
2. Hoàn tất PR của nhánh thành viên vào `develop`, sau đó đối chiếu commit riêng trên `main` trước khi cắt `release/0.3.0`; không merge thẳng nhánh cá nhân vào `main`.
3. Viết cấu hình Nginx và deploy theo runbook. Nếu không kịp có VPS thì demo local và ghi rõ đây là sai lệch so với YC12.
4. Build APK có `API_URL`, cài lên máy thật.
5. Chạy AC-01…09, điền ma trận kết quả, chạy `bench:realtime`. Nếu không có API key thì nghiệm thu AI ở chế độ fallback và ghi rõ.
6. Cập nhật hồ sơ: trạng thái WBS thực tế, sổ rủi ro, báo cáo sprint 4, thống nhất phân vai.

## Giới hạn của báo cáo

GitHub App CI của commit `66fd7a8` trên `develop` đã chạy thành công ngày 02/11. Trên worktree chuẩn bị ship: `flutter analyze` đạt, 133/133 Flutter test đạt và web build đạt khi tắt wasm dry-run do Dart compiler 3.13.3 trên Windows crash ở dry-run; backend lint, typecheck và build đạt. Backend test chưa chạy được vì PostgreSQL test tại `localhost:15432` không sẵn sàng. Chưa kiểm tra GitHub Project #14. Kết luận về deploy, UAT và AI dựa trên việc repo/issue chưa có bằng chứng được duyệt, nên nếu nhóm đã làm ngoài repo thì cần bổ sung evidence trước khi đóng issue hoặc phát hành.
