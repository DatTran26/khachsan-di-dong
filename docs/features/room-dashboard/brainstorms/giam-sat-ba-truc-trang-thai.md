---
type: brainstorm
feature: room-dashboard
status: draft
updated: 2026-09-17
links:
  - "[[docs/_product/prd.md|Product PRD]]"
  - "[[Ton_Chi_Du_An_WPCTeam.txt|Tôn chỉ dự án]]"
---

# Room Dashboard — Giám sát 3 trục trạng thái phòng theo thời gian thực

## 1. Idea Seed

Một màn hình tổng trên web cho quản lý (và tham khảo cho lễ tân): lưới 50 phòng cập nhật realtime, mỗi phòng hiển thị riêng 3 trục trạng thái — lưu trú / vệ sinh / bảo trì — kèm các chỉ số tại thời điểm xem: phòng đang ở, phòng sẵn sàng, phòng cần dọn, phòng ngừng phục vụ, công việc quá hạn và tỷ lệ lấp đầy. Việc quá hạn được tô cờ bằng quy tắc (không phụ thuộc AI) để quản lý can thiệp ngay trong ca. Dashboard chỉ giám sát: mọi thay đổi trạng thái do các feature nghiệp vụ sở hữu (check-in-out, housekeeping, maintenance) và lan lên dashboard qua realtime-sync.

## 2. Context

MVP 8 tuần (08/09–02/11/2026), 1 khách sạn giả định 50 phòng, tiếng Việt, dữ liệu giả lập. Tôn chỉ yêu cầu: trạng thái lưu trú, vệ sinh và bảo trì được theo dõi riêng để tránh nhầm lẫn; dashboard thể hiện phòng đang ở, phòng sẵn sàng, phòng cần dọn, phòng ngừng phục vụ, công việc quá hạn và tỷ lệ lấp đầy tại thời điểm xem; cảnh báo quá hạn dùng quy tắc, không phụ thuộc AI. Theo Feature Map, `room-dashboard` thuộc nhóm "Giám sát & truy vết", mức Must, phụ thuộc `housekeeping`, `maintenance`, `realtime-sync` — chạy Sprint 3 (dashboard + cảnh báo quá hạn, khung tới 19/10).

## 3. User Types (preliminary)

| User Type | Pain Point | Primary Need |
|-----------|-----------|--------------|
| Quản lý (primary) | Không có cái nhìn tổng theo thời điểm; phải đi kiểm tra hoặc hỏi từng người mới biết việc nào đang trễ | Một màn hình realtime hiển thị toàn bộ trạng thái phòng + việc quá hạn để điều phối trong ca |
| Lễ tân (secondary) | Không chắc phòng nào thật sự sẵn sàng; phải gọi điện hỏi buồng phòng/bảo trì trước khi nhận khách | Tham khảo dashboard để biết ngay phòng "sẵn sàng" / "đang ở" tại thời điểm đó |
| Nhân viên buồng phòng–bảo trì | (Không phải người xem dashboard — họ thao tác trên danh sách việc mobile của feature khác) | Cập nhật của họ phải lan lên dashboard đúng lúc — là nguồn dữ liệu, không phải viewer |

*Khách lưu trú không phải người dùng hệ thống (tôn chỉ).*

## 4. Capabilities Breakdown

### P0 — must have

- Lưới toàn bộ 50 phòng; mỗi ô phòng hiển thị riêng 3 trục (lưu trú / vệ sinh / bảo trì), không gộp thành 1 trạng thái.
- Chỉ số tổng hợp tại thời điểm xem: đang ở / sẵn sàng / cần dọn / ngừng phục vụ / việc quá hạn / tỷ lệ lấp đầy.
- Tỷ lệ lấp đầy = phòng đang ở ÷ phòng có thể phục vụ × 100%; mẫu số = 0 thì hiển thị "không áp dụng".
- Cập nhật realtime khi bất kỳ vai trò nào thay đổi trạng thái — mục tiêu ≤3 giây kể từ khi máy chủ lưu (qua `realtime-sync`).
- Tô cờ/đánh dấu công việc quá hạn trên ô phòng và đếm vào chỉ số "việc quá hạn"; cờ do feature nghiệp vụ đánh theo quy tắc (housekeeping đã chốt 60 phút cho việc dọn).
- Lọc lưới theo tầng và theo nhóm trạng thái.
- Báo rõ trạng thái mất kết nối (dữ liệu có thể lỗi thời); khi kết nối lại tự tải trạng thái mới nhất.
- Phân quyền xem cho quản lý + lễ tân; dashboard chỉ đọc — không cho đổi trạng thái từ màn hình này.

### P1 — should have

- Từ ô phòng / cảnh báo quá hạn điều hướng sang màn nghiệp vụ sở hữu để can thiệp (housekeeping / maintenance) — dashboard không tự xử lý.
- Nhãn mốc cập nhật cuối ("dữ liệu tính đến ...") để quản lý tin chỉ số đúng thời điểm.

### P2 — nice to have

- Xem chi tiết một phòng khi chạm vào ô phòng (đủ 3 trục + công việc đang mở của phòng đó) — xem OQ-4.
- Hiển thị dashboard trong app Android cho quản lý/lễ tân — xem OQ-3.
- Lọc chi tiết theo từng trạng thái của từng trục (vd chỉ phòng "đang dọn").

## 5. Core Flows (Happy Path)

### 5.1 Quản lý mở dashboard và theo dõi trong ca

1) Quản lý đăng nhập đúng vai trò, mở dashboard trên web.
2) Hệ thống tải trạng thái tại thời điểm xem: lưới 50 phòng (3 trục mỗi phòng) + 6 chỉ số tổng hợp.
3) Mọi thay đổi trạng thái từ lễ tân (lưu trú), nhân viên buồng phòng (vệ sinh), nhân viên bảo trì (bảo trì) lan lên dashboard realtime qua `realtime-sync`.
4) Việc vượt ngưỡng quá hạn được tô cờ trên ô phòng và tính vào chỉ số "việc quá hạn" → quản lý thấy và can thiệp trong ca.

```
CÁC VAI TRÒ NGUỒN                    MÁY CHỦ                        DASHBOARD (web)
lễ tân · nv buồng phòng–bảo trì

thao tác ghi (nhận/trả, dọn, sửa)
        │                            │
        └───────────────────────────▶│ kiểm quyền + lưu + ghi nhật ký
                                     │
                                     ├─▶ phát sự kiện realtime (≤3s) ──▶ ô phòng + chỉ số cập nhật
                                     │
                                     └─▶ quy tắc quá hạn (không AI) ───▶ tô cờ việc/phòng quá hạn

mất kết nối ─────────────────────────────────────────────────────────▶ banner offline + dữ liệu lỗi thời
có mạng lại ─────────────────────────────────────────────────────────▶ tải trạng thái mới nhất
```

### 5.2 Lễ tân kiểm tra phòng sẵn sàng trước khi nhận khách

1) Lễ tân mở dashboard (tham khảo), lọc trạng thái "sẵn sàng" kèm tầng nếu cần.
2) Lưới chỉ còn các phòng trống + sạch + bảo trì bình thường tại thời điểm đó.
3) Lễ tân nhận khách trên màn nghiệp vụ nhận/trả phòng; dashboard cập nhật phòng sang "đang ở" ngay sau khi lễ tân xác nhận.

### 5.3 Quản lý xử lý việc quá hạn

1) Chỉ số "việc quá hạn" tăng; các ô phòng có việc quá hạn được tô cờ.
2) Quản lý lọc theo "quá hạn" để khoanh vùng phòng/việc đang trễ.
3) Quản lý can thiệp trên màn nghiệp vụ sở hữu (phân công lại việc dọn ở `housekeeping`, xử lý việc sửa ở `maintenance`); dashboard phản ánh kết quả ngay và cờ tự gỡ khi việc hoàn tất.

## 6. System Behavior Deep Dive

### 6.1 Decision Points (quyết định hiển thị)

| ID | Tình huống | Điều kiện | YES | NO |
|----|-----------|-----------|-----|----|
| D1 | Nhãn "sẵn sàng" của phòng | Phòng trống + sạch + bảo trì bình thường? | Hiển thị "sẵn sàng", đếm vào chỉ số sẵn sàng | Hiển thị trạng thái thật của từng trục |
| D2 | Tỷ lệ lấp đầy | Mẫu số "phòng có thể phục vụ" = 0? | Hiển thị "không áp dụng" | Hiển thị % bình thường |
| D3 | Kết nối realtime | Đang mất kết nối? | Banner offline + đánh dấu dữ liệu có thể lỗi thời | Hiển thị bình thường |
| D4 | Cờ quá hạn trên ô phòng | Phòng có ≥1 công việc đang mở bị cờ quá hạn? | Tô cờ ô phòng + đếm vào chỉ số quá hạn | Không cờ |

### 6.2 Scenario Matrix — phòng hiển thị theo 3 trục riêng

| Trục lưu trú | Trục vệ sinh | Trục bảo trì | Nhãn hiển thị chính | Đóng góp vào chỉ số |
|--------------|--------------|--------------|---------------------|---------------------|
| trống | sạch | bình thường | "sẵn sàng" | sẵn sàng +1; mẫu lấp đầy +1 |
| đang ở | sạch | bình thường | "đang ở" | đang ở +1; tử lấp đầy +1; mẫu +1 |
| trống | cần dọn / đang dọn / chờ kiểm tra | bình thường | "cần dọn" (kèm trạng thái vệ sinh chi tiết) | cần dọn +1 (xem OQ-2); mẫu +1 |
| đang ở | (bất kỳ) | ngừng phục vụ | "đang ở" + cờ "ngừng phục vụ" | đang ở +1; ngừng phục vụ +1; tử +1; mẫu +0 |
| trống | (bất kỳ) | ngừng phục vụ | "ngừng phục vụ" | ngừng phục vụ +1; mẫu +0 |
| (bất kỳ) | (bất kỳ) | (bất kỳ) — có việc quá hạn | + cờ "quá hạn" trên ô | việc quá hạn +1 |

### 6.3 Quy tắc hiển thị theo trạng thái nguồn

Dashboard không sở hữu vòng đời trạng thái — chỉ đọc và hiển thị. Trạng thái hợp lệ của từng trục do feature sở hữu quy định:

| Trục | Trạng thái | Feature sở hữu |
|------|-----------|----------------|
| Lưu trú | trống / đang ở | `check-in-out` |
| Vệ sinh | cần dọn / đang dọn / chờ kiểm tra / sạch | `housekeeping` |
| Bảo trì | bình thường / ngừng phục vụ | `maintenance` |

- "Sẵn sàng" là trạng thái suy ra (composite: trống + sạch + bảo trì bình thường), không phải trạng thái lưu của trục nào — tham chiếu `housekeeping`.
- "Quá hạn" là cờ suy ra trên công việc theo quy tắc thời gian — việc dọn do `housekeeping` đánh (60 phút), việc sửa do `maintenance` đánh (ngưỡng chờ OQ-1).

### 6.4 Interrupted Transactions & Edge Cases

| Tình huống | Dashboard còn lại gì | Resume | Cleanup |
|---|---|---|---|
| Mất mạng khi đang xem | Dữ liệu tại thời điểm mất kết nối + banner offline | Kết nối lại → tải trạng thái mới nhất, gỡ banner | Không có |
| Sự kiện realtime đến trễ/sai thứ tự | Trạng thái đang hiển thị | Luôn render theo trạng thái mới nhất từ máy chủ (xử lý thứ tự/xung đột thuộc `realtime-sync`) | Không có |
| Tải dashboard ban đầu thất bại | Trạng thái lỗi + nút thử lại | Tải lại thành công → hiển thị bình thường | Không có |
| Phiên đăng nhập hết hạn khi đang mở | Yêu cầu đăng nhập lại | Đăng nhập lại đúng vai trò → vào lại dashboard | Không có |
| Giờ cao điểm: nhiều thay đổi dồn một lúc | Lưới cập nhật liên tục | Giữ ngữ cảnh bộ lọc/vùng nhìn đang dùng | Không có |

Edge cases khác:

- Phòng đang ở bị chuyển "ngừng phục vụ" giữa chừng: ô phòng hiển thị đồng thời "đang ở" (lưu trú) và "ngừng phục vụ" (bảo trì) — không gộp; chỉ số đếm vào cả hai nhóm.
- Tất cả phòng ngừng phục vụ: mẫu số lấp đầy = 0 → "không áp dụng" (không phải lỗi).
- Phòng đang ở + ngừng phục vụ vẫn tính vào tử số lấp đầy nhưng không tính mẫu số → tỷ lệ có thể vượt 100% trong tình huống cực đoan; công thức tôn chỉ áp nguyên, không tự điều chỉnh.
- Lọc ra 0 phòng: hiển thị trạng thái rỗng rõ ràng, không hiểu nhầm là lỗi.

## 7. Validation, Limits & Wording

### 7.1 Display rules (dashboard chỉ đọc — không có form validate)

| Element | Rule |
|---------|------|
| Chỉ số "sẵn sàng" | Chỉ đếm phòng trống + sạch + bảo trì bình thường |
| Chỉ số "việc quá hạn" | Đếm công việc đang mở có cờ quá hạn (cờ do feature nguồn đánh) |
| Tỷ lệ lấp đầy | Tử = phòng "đang ở"; mẫu = phòng không "ngừng phục vụ"; mẫu = 0 → "không áp dụng" |
| Lọc theo tầng | Theo dữ liệu tầng của danh mục phòng (`room-catalog`) |
| Nhãn trục | Luôn tách riêng 3 trục — cấm gộp thành 1 trạng thái |

### 7.2 Limits & Quotas (exact values)

| Tham số | Giá trị | Window | Behavior khi vượt |
|---------|---------|--------|-------------------|
| Số phòng trên lưới | 50 (1 khách sạn) | — | — |
| Độ trễ cập nhật realtime | ≤ 3 giây | Từ lúc máy chủ lưu thành công | Mục tiêu nghiệm thu ≥95% lượt (tôn chỉ) |
| Ngưỡng quá hạn việc dọn | 60 phút | Do `housekeeping` sở hữu và đánh cờ | Dashboard chỉ hiển thị cờ |
| Ngưỡng quá hạn việc sửa | Chưa chốt — OQ-1 | Do `maintenance` sở hữu | Dashboard chỉ hiển thị cờ |
| Phiên đồng thời | ~10 | Tôn chỉ | — |

### 7.3 Wording samples (exact strings)

#### Error / status messages

| Tình huống | Wording | Code |
|---|---|---|
| Mất kết nối | "Mất kết nối — dữ liệu có thể chưa mới nhất. Đang thử kết nối lại…" | E-? |
| Tải dashboard lỗi | "Không tải được dữ liệu dashboard. Thử lại." | E-? |
| Không đủ quyền | "Bạn không có quyền xem màn hình này." | E-? |
| Phiên hết hạn | "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại." | E-? |

#### Info / neutral messages

| Tình huống | Wording |
|---|---|
| Kết nối lại thành công | "Đã kết nối lại — dữ liệu đã cập nhật." |
| Mẫu số lấp đầy = 0 | "không áp dụng" |
| Lọc ra 0 phòng | "Không có phòng nào khớp bộ lọc." |
| Nhãn chỉ số | "Đang ở" · "Sẵn sàng" · "Cần dọn" · "Ngừng phục vụ" · "Việc quá hạn" · "Tỷ lệ lấp đầy" |

## 8. Assumptions

- "Phòng có thể phục vụ" (mẫu số tỷ lệ lấp đầy) = tổng phòng trừ phòng đang "ngừng phục vụ" — giả định làm việc từ công thức tôn chỉ.
- Chỉ số "phòng cần dọn" = phòng có trục vệ sinh chưa đạt "sạch" (cần dọn / đang dọn / chờ kiểm tra) — chờ xác nhận, xem OQ-2.
- Cờ "quá hạn" do feature nghiệp vụ sở hữu việc đánh (không phải dashboard tự tính) — nhất quán phạm vi "giám sát, không sở hữu luồng".
- Dashboard v1 chạy trên web cho quản lý + lễ tân (PRD); phạm vi Android xem OQ-3.
- Lọc theo trạng thái = theo nhóm hiển thị chính (đang ở / sẵn sàng / cần dọn / ngừng phục vụ / quá hạn); lọc chi tiết từng trạng thái trục là nhu cầu P2.
- Khách lưu trú không phải người dùng; dashboard không hiển thị dữ liệu định danh khách (dữ liệu giả lập).

## 9. Risks

| Rủi ro | Khả năng | Hậu quả nghiệp vụ | Cách phòng |
|--------|----------|-------------------|-----------|
| Chỉ số dashboard lệch dữ liệu thật (rủi ro chính của PRD) | thấp | Quản lý điều phối sai trong ca | Đối soát nghiệm thu yêu cầu 100% khớp; hiển thị rõ offline/lỗi thay vì im lặng |
| Upstream chưa sẵn sàng (`maintenance`, `realtime-sync` chưa chi tiết hóa) | trung bình | Dashboard thiếu trục bảo trì / cờ quá hạn bảo trì / kênh realtime | Theo kế hoạch sprint (dashboard Sprint 3 sau vận hành Sprint 2); dữ liệu giả lập phủ đủ 3 trục |
| Quản lý đòi thao tác trực tiếp trên dashboard (scope creep) | trung bình | Feature vượt phạm vi, trễ sprint | Giữ dashboard chỉ-đọc; can thiệp qua màn feature sở hữu (điều hướng P1) |
| Ngưỡng quá hạn bảo trì chưa chốt (OQ-1) | trung bình | Chỉ số "việc quá hạn" thiếu phần việc sửa | Cờ do feature nguồn đánh — chỉ số tự đầy đủ khi `maintenance` chốt ngưỡng |
| Lưới 50 phòng khó đọc trên màn nhỏ nếu OQ-3 yêu cầu Android | trung bình | Quản lý khó dùng trên điện thoại | Chờ OQ-3; thiết kế responsive nếu cần |

## 10. Success Criteria (preliminary)

- 100% chỉ số dashboard khớp dữ liệu đối soát trong nghiệm thu (tôn chỉ/PRD).
- ≥95% trong 100 lượt cập nhật trạng thái hiển thị trên dashboard trong ≤3 giây (50 phòng, ~10 phiên đồng thời).
- 100% công việc có cờ quá hạn được tô cờ và đếm đúng trên dashboard.
- 0 màn hình/báo cáo nào trộn 3 trục trạng thái thành 1 trạng thái duy nhất.

## 11. Open Questions

- [ ] OQ-1: Ngưỡng "quá hạn" cho công việc bảo trì là bao nhiêu (việc dọn đã chốt 60 phút ở `housekeeping`)? Chỉ số "việc quá hạn" của dashboard chỉ đầy đủ khi ngưỡng này được chốt — quyết cùng feature `maintenance`.
- [ ] OQ-4: Chạm vào một ô phòng có mở màn chi tiết phòng (đủ 3 trục + công việc đang mở + liên kết sang màn xử lý của housekeeping/maintenance) không, hay lưới tổng quan đã đủ cho v1?

## 12. Next Steps

Sau brainstorm này (sau khi BA approve):
- `/urd room-dashboard` — capture user perspective
- `/brd room-dashboard` — business case
- `/prd-epic room-dashboard` — product scope
- `/srs room-dashboard` — core spec
