---
type: srs-spec
feature: room-dashboard
status: draft
updated: 2026-09-17
links:
  - "[[docs/features/room-dashboard/room-dashboard-prd.md|Room Dashboard PRD]]"
  - "[[docs/features/housekeeping/srs/housekeeping-spec.md|Housekeeping Spec]]"
---

# room-dashboard — SRS (Core Spec)

## 1. Purpose & Scope

Đặc tả màn hình dashboard giám sát trạng thái phòng cho quản lý (và tham khảo cho lễ tân): lưới toàn bộ phòng hiển thị riêng 3 trục trạng thái — lưu trú / vệ sinh / bảo trì — cùng chỉ số tổng hợp tại thời điểm xem (đang ở / sẵn sàng / cần dọn / ngừng phục vụ / việc quá hạn / tỷ lệ lấp đầy), tô cờ công việc quá hạn bằng quy tắc, lọc theo tầng/trạng thái, và chỉ báo sức khỏe dữ liệu khi mất kết nối. Phạm vi: 1 khách sạn 50 phòng, tiếng Việt, dữ liệu giả lập, dashboard chỉ đọc — mọi thay đổi trạng thái thuộc feature nghiệp vụ sở hữu (`check-in-out`, `housekeeping`, `maintenance`), kênh realtime thuộc `realtime-sync`.

## 2. Actors & Stakeholders

| Actor | Type | Trách nhiệm |
|-------|------|-------------|
| Quản lý | Người | Xem dashboard liên tục trong ca; lọc khoanh vùng; nhận diện việc quá hạn và can thiệp qua màn feature sở hữu |
| Lễ tân | Người | Tham khảo dashboard (read-only): xem/lọc phòng "sẵn sàng" trước khi nhận khách |
| Hệ thống | Hệ thống | Tải trạng thái tại thời điểm xem, tính chỉ số tổng hợp, nhận cập nhật realtime, hiển thị cờ quá hạn, báo trạng thái kết nối |
| Nhân viên buồng phòng–bảo trì | Người | (Không dùng dashboard) — nguồn thay đổi trạng thái qua feature nghiệp vụ |
| Feature vận hành (`check-in-out`, `housekeeping`, `maintenance`) | Hệ thống | Sở hữu và ghi trạng thái 3 trục + cờ quá hạn trên công việc (ngoài phạm vi spec này) |
| Feature `realtime-sync` | Hệ thống | Phát cập nhật tới dashboard ≤3 giây; xử lý xung đột/mất mạng phía nguồn (ngoài phạm vi spec này) |

## 3. Functional Requirements

| ID | Requirement | Verification | Priority |
|----|-------------|--------------|----------|
| FR-room-dashboard-001 | Khi người dùng đủ quyền mở dashboard, hệ thống phải hiển thị lưới toàn bộ phòng trong danh mục (50 phòng), mỗi phòng hiển thị riêng 3 trục trạng thái — lưu trú, vệ sinh, bảo trì — tại thời điểm xem; không gộp 3 trục thành 1 trạng thái. | Demo/test: đối chiếu ô phòng với trạng thái nguồn từng trục | Must |
| FR-room-dashboard-002 | Hệ thống phải hiển thị chỉ số tổng hợp tại thời điểm xem: số phòng đang ở; số phòng sẵn sàng; số phòng cần dọn; số phòng ngừng phục vụ; số công việc quá hạn; tỷ lệ lấp đầy. | Test: đối soát từng chỉ số với dữ liệu nguồn | Must |
| FR-room-dashboard-003 | Phòng chỉ được tính và hiển thị "sẵn sàng" khi trục lưu trú = trống + trục vệ sinh = sạch + trục bảo trì = bình thường. | Test: phòng thiếu 1 điều kiện không được vào nhóm "sẵn sàng" | Must |
| FR-room-dashboard-004 | Tỷ lệ lấp đầy = số phòng đang ở ÷ số phòng có thể phục vụ × 100%; khi mẫu số = 0 (mọi phòng ngừng phục vụ), hệ thống hiển thị "không áp dụng" thay vì con số. | Test: dàn trạng thái để mẫu = 0 | Must |
| FR-room-dashboard-005 | Mọi thay đổi trạng thái do các feature nghiệp vụ ghi thành công phải phản ánh lên dashboard đang mở trong ≤3 giây kể từ lúc máy chủ lưu (qua `realtime-sync`). | Đo 100 lượt theo tiêu chí nghiệm thu | Must |
| FR-room-dashboard-006 | Công việc đang mở có cờ "quá hạn" (do feature nghiệp vụ đánh theo quy tắc) phải được tô cờ trên ô phòng liên quan và đếm vào chỉ số "việc quá hạn"; cờ tự mất trên dashboard khi việc hoàn tất. Cơ chế hiển thị bằng quy tắc, không dùng AI. | Test: việc quá hạn xuất hiện/biến mất đúng lúc | Must |
| FR-room-dashboard-007 | Người xem phải lọc được lưới theo tầng và theo nhóm trạng thái hiển thị (đang ở / sẵn sàng / cần dọn / ngừng phục vụ / quá hạn); khi không có phòng khớp, hiển thị trạng thái rỗng rõ ràng. | Demo: lọc từng nhóm + case 0 kết quả | Must |
| FR-room-dashboard-008 | Chỉ vai trò quản lý và lễ tân được xem dashboard; quyền xem kiểm tra ở máy chủ. Dashboard chỉ đọc — không cung cấp thao tác thay đổi trạng thái hay công việc. | Test bằng tài khoản từng vai trò | Must |
| FR-room-dashboard-009 | Khi mất kết nối realtime, dashboard phải hiển thị rõ trạng thái mất kết nối và đánh dấu dữ liệu có thể lỗi thời; khi kết nối lại, hệ thống tải trạng thái mới nhất thay cho ghép dữ liệu cũ. | Test: ngắt mạng khi đang xem, nối lại | Must |
| FR-room-dashboard-010 | Khi tải dữ liệu ban đầu thất bại, dashboard hiển thị trạng thái lỗi rõ ràng và cho phép thử lại; không hiển thị lưới/chỉ số trống như thể "không có phòng". | Test: chặn tải lần đầu | Must |
| FR-room-dashboard-011 | Dashboard nên hiển thị mốc dữ liệu/cập nhật cuối để người xem biết chỉ số tính đến thời điểm nào. | Demo | Should |

## 4. Non-Functional Requirements

| ID | Requirement | Verification | Priority |
|----|-------------|--------------|----------|
| NFR-room-dashboard-001 | Performance: ≥95% trong 100 lượt cập nhật trạng thái phải hiển thị trên dashboard trong ≤3 giây (50 phòng, tối đa ~10 phiên đồng thời). | Đo theo tiêu chí nghiệm thu tôn chỉ | Must |
| NFR-room-dashboard-002 | Accuracy: 100% chỉ số dashboard khớp dữ liệu đối soát trong nghiệm thu; sai lệch chỉ số là lỗi chặn luồng. | Đối soát chỉ số vs dữ liệu nguồn | Must |
| NFR-room-dashboard-003 | Reliability: mất kết nối không được để dashboard im lặng hiển thị dữ liệu cũ như thể còn mới; khi phục hồi phải tải trạng thái mới nhất. | Test: ngắt/nối mạng trong kịch bản "khôi phục kết nối" | Must |
| NFR-room-dashboard-004 | Security: quyền xem dashboard kiểm tra ở máy chủ theo vai trò (quản lý, lễ tân); vai trò khác bị từ chối. | Test bằng tài khoản từng vai trò | Must |
| NFR-room-dashboard-005 | Usability: toàn bộ nhãn/thông báo tiếng Việt; lưới 50 phòng giữ ngữ cảnh bộ lọc/vùng nhìn đang dùng khi realtime cập nhật liên tục. | Demo giờ cao điểm nhiều cập nhật dồn | Must |
| NFR-room-dashboard-006 | Data privacy: dashboard chỉ hiển thị trạng thái phòng/công việc — không hiển thị dữ liệu định danh khách (khách không phải người dùng; dữ liệu giả lập). | Kiểm tra nội dung hiển thị | Must |

## 5. Business Rules

| ID | Rule | Source | Liên kết |
|----|------|--------|----------|
| BR-room-dashboard-001 | Ba trục lưu trú / vệ sinh / bảo trì luôn hiển thị riêng, không gộp thành 1 trạng thái. | Tôn chỉ / BRD BR-room-dashboard-01 | FR-001 |
| BR-room-dashboard-002 | Tỷ lệ lấp đầy = phòng đang ở ÷ phòng có thể phục vụ × 100%; mẫu số = 0 → "không áp dụng". | Tôn chỉ / BRD BR-room-dashboard-02 | FR-004 |
| BR-room-dashboard-003 | "Sẵn sàng" = trống + sạch + bảo trì bình thường — composite suy ra, không phải trạng thái lưu của trục nào. | Tôn chỉ / `housekeeping` BR-housekeeping-003 | FR-003 |
| BR-room-dashboard-004 | Cờ "quá hạn" do feature nghiệp vụ sở hữu đánh theo quy tắc (việc dọn 60 phút theo `housekeeping`; việc sửa chờ OQ-1 ở `maintenance`); dashboard chỉ hiển thị và đếm — không dùng AI. | Tôn chỉ / BRD BR-room-dashboard-04 | FR-006 |
| BR-room-dashboard-005 | Dashboard chỉ đọc: mọi thay đổi trạng thái/công việc thực hiện ở feature nghiệp vụ sở hữu. | BRD BR-room-dashboard-05 | FR-008 |
| BR-room-dashboard-006 | Chỉ vai trò quản lý và lễ tân được xem dashboard. | PRD 7.7 / BRD BR-room-dashboard-06 | FR-008, NFR-004 |

## 6. Error Matrix

| ID | Error | Trigger | Severity | Linked Req | User Message |
|----|-------|---------|----------|------------|--------------|
| E-room-dashboard-001 | Mất kết nối realtime | Rớt mạng/đứt kênh realtime khi đang xem | major | FR-009 | "Mất kết nối — dữ liệu có thể chưa mới nhất. Đang thử kết nối lại…" (banner; có lại mạng → tải trạng thái mới + "Đã kết nối lại — dữ liệu đã cập nhật.") |
| E-room-dashboard-002 | Tải dashboard thất bại | Lỗi khi tải trạng thái ban đầu | major | FR-010 | "Không tải được dữ liệu dashboard. Thử lại." + nút tải lại |
| E-room-dashboard-003 | Không đủ quyền xem | Vai trò ngoài quản lý/lễ tân truy cập | major | FR-008, NFR-004 | "Bạn không có quyền xem màn hình này." |
| E-room-dashboard-004 | Phiên hết hạn | Phiên đăng nhập hết hạn khi đang mở | minor | FR-008 | "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại." (xử lý phiên thuộc `auth-roles`) |
| E-room-dashboard-005 | Lọc ra 0 phòng | Bộ lọc không khớp phòng nào | info | FR-007 | "Không có phòng nào khớp bộ lọc." |

## 7. Success Criteria

| ID | Criterion | Đo lường |
|----|-----------|----------|
| SC-room-dashboard-01 | 100% chỉ số dashboard khớp dữ liệu đối soát | Đối soát trong nghiệm thu (tôn chỉ/PRD đo thành công) |
| SC-room-dashboard-02 | ≥95% trong 100 lượt cập nhật trạng thái hiển thị trên dashboard ≤3 giây (50 phòng, ~10 phiên đồng thời) | Đo theo tiêu chí nghiệm thu tôn chỉ |
| SC-room-dashboard-03 | 100% công việc có cờ quá hạn (do feature nguồn đánh) được tô cờ và đếm trên dashboard | Kịch bản nghiệm thu "dashboard + cảnh báo quá hạn" |
| SC-room-dashboard-04 | 0 phòng hiển thị "sẵn sàng" khi chưa đủ trống + sạch + bảo trì bình thường; 0 màn hình trộn 3 trục thành 1 trạng thái | Đối chiếu trạng thái nguồn trong test |

## 8. Entity Summary

| Entity | Fields chính | Quan hệ | Ghi chú |
|--------|--------------|---------|---------|
| Phòng (view đọc của dashboard) | số phòng, tầng, trục lưu trú (trống / đang ở), trục vệ sinh (cần dọn / đang dọn / chờ kiểm tra / sạch), trục bảo trì (bình thường / ngừng phục vụ) | thuộc danh mục phòng (`room-catalog`); 3 trục do `check-in-out`, `housekeeping`, `maintenance` sở hữu | Dashboard không lưu trạng thái riêng — chỉ đọc; "sẵn sàng" là composite suy ra, không phải trạng thái lưu |
| Chỉ số tổng hợp (suy ra tại thời điểm xem) | đang ở, sẵn sàng, cần dọn, ngừng phục vụ, việc quá hạn, tỷ lệ lấp đầy | tính từ trạng thái phòng + cờ công việc | Không phải entity lưu; cần khớp đối soát 100% |
| Cờ quá hạn trên công việc | thuộc việc dọn / việc sửa đang mở | do `housekeeping` / `maintenance` đánh theo quy tắc | Dashboard đọc cờ để tô màu + đếm; không tự tính ngưỡng |

## 9. Flow Summary

- Luồng chính: mở dashboard → tải lưới 50 phòng + chỉ số tại thời điểm xem → mọi thay đổi từ các vai trò lan lên realtime ≤3 giây → ô phòng và chỉ số cập nhật tại chỗ.
- Luồng quá hạn: feature nghiệp vụ đánh cờ việc quá hạn → cờ lan lên dashboard → ô phòng tô cờ + chỉ số "việc quá hạn" +1 → việc hoàn tất → cờ tự gỡ.
- Luồng lọc: chọn tầng/nhóm trạng thái → lưới chỉ còn phòng khớp → 0 kết quả thì trạng thái rỗng.
- Luồng offline: mất kết nối → banner + dữ liệu đánh dấu lỗi thời → có lại mạng → tải trạng thái mới nhất + gỡ banner.

## 10. Screen Summary

| Screen | Vai trò | Nội dung chính |
|--------|---------|----------------|
| Dashboard tổng quan | Quản lý, Lễ tân (read-only) | Hàng chỉ số (đang ở / sẵn sàng / cần dọn / ngừng phục vụ / việc quá hạn / tỷ lệ lấp đầy); lưới 50 phòng với 3 trục riêng mỗi ô; bộ lọc tầng + trạng thái; banner trạng thái kết nối; mốc cập nhật cuối (P1) |
| Chi tiết phòng | Quản lý, Lễ tân | (Chờ OQ-4) đủ 3 trục + công việc đang mở của phòng + liên kết sang màn xử lý của feature sở hữu |

## 11. Constraints & Dependencies

### Constraints

- MVP 8 tuần, 1 khách sạn 50 phòng, tiếng Việt, dữ liệu giả lập, ~10 phiên đồng thời (tôn chỉ).
- 3 trục trạng thái tách riêng — ràng buộc lõi tôn chỉ; "sẵn sàng" là composite không phải trạng thái lưu.
- Cảnh báo/hiển thị quá hạn bằng quy tắc, không phụ thuộc AI (tôn chỉ).
- Kiểm tra quyền ở máy chủ cho quyền xem theo vai trò (tôn chỉ).
- Công thức tỷ lệ lấp đầy theo tôn chỉ; mẫu = 0 → "không áp dụng".
- Dashboard v1 trên Flutter Web (phạm vi Android xem OQ-3); realtime qua Socket.IO; backend Node.js + Express + TypeScript; PostgreSQL + Prisma — ràng buộc đã duyệt theo tôn chỉ.

### Dependencies

- `housekeeping` — trục vệ sinh + cờ quá hạn việc dọn 60 phút (đã chi tiết hóa).
- `maintenance` — trục bảo trì + cờ quá hạn việc sửa (chưa chi tiết hóa; ngưỡng chờ OQ-1).
- `realtime-sync` — kênh cập nhật ≤3 giây + xử lý xung đột/offline phía nguồn (chưa chi tiết hóa).
- `room-catalog` — danh mục 50 phòng + dữ liệu tầng (chưa chi tiết hóa).
- `check-in-out` — trục lưu trú trống/đang ở (chưa chi tiết hóa).
- `auth-roles` — vai trò quản lý/lễ tân + phiên đăng nhập (đã chi tiết hóa).

### Assumptions

- Mẫu số tỷ lệ lấp đầy = phòng không "ngừng phục vụ" (giả định từ công thức tôn chỉ).
- Chỉ số "phòng cần dọn" chỉ đếm phòng có trục vệ sinh = `can_don`; `dang_don` và `cho_kiem_tra` vẫn hiển thị riêng trên lưới.
- Cờ quá hạn do feature nguồn đánh — dashboard chỉ hiển thị/đếm (nhất quán phạm vi giám sát).
- Dashboard v1 chỉ Web; Android là hậu MVP.

## 12. Open Questions

- [ ] OQ-1: Ngưỡng "quá hạn" cho công việc bảo trì là bao nhiêu (việc dọn đã chốt 60 phút ở `housekeeping`)? Chỉ số "việc quá hạn" của dashboard chỉ đầy đủ khi ngưỡng này được chốt — quyết cùng feature `maintenance`.
- [ ] OQ-4: Chạm vào một ô phòng có mở màn chi tiết phòng (đủ 3 trục + công việc đang mở + liên kết sang màn xử lý của housekeeping/maintenance) không, hay lưới tổng quan đã đủ cho v1?
