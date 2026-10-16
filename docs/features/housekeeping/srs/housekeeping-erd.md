---
type: srs-erd
feature: housekeeping
updated: 2026-09-17
---

# housekeeping — ERD

```mermaid
erDiagram
    NGUOI_DUNG ||--o{ VIEC_DON_PHONG : "phu trach"
    PHONG ||--o{ VIEC_DON_PHONG : "co"
    VIEC_DON_PHONG ||--o{ ANH_NGHIEM_THU : "co"
    VIEC_DON_PHONG ||--o{ NHAT_KY : "ghi"
    PHONG ||--o{ NHAT_KY : "ghi"

    PHONG {
        string id PK
        string so_phong
        string truc_luu_tru "trong | dang_o"
        string truc_ve_sinh "can_don | dang_don | cho_kiem_tra | sach"
        string truc_bao_tri "binh_thuong | ngung_phuc_vu"
        int phien_ban
    }

    VIEC_DON_PHONG {
        string id PK
        string phong_id FK
        string nhan_vien_id FK
        string trang_thai "cho_giao | da_giao | dang_lam | cho_xac_nhan | hoan_tat"
        boolean qua_han
        string ghi_chu_tra_lai
        datetime tao_luc
        datetime nhan_luc
        datetime hoan_tat_luc
        datetime xac_nhan_luc
        int phien_ban
    }

    ANH_NGHIEM_THU {
        string id PK
        string viec_don_phong_id FK
        string nhom_anh "tong_quan | khu_ngu | nha_ve_sinh | can_canh"
        string tep_id
        string trang_thai_tai "dang_tai | thanh_cong | loi"
        string nguoi_nop_id FK
        datetime nop_luc
    }

    NGUOI_DUNG {
        string id PK
        string vai_tro
        boolean dang_truc
    }

    NHAT_KY {
        string id PK
        string doi_tuong_loai
        string doi_tuong_id
        string hanh_dong
        string tu_trang_thai
        string sang_trang_thai
        string ai_id FK
        datetime khi_nao
    }
```

> "Sẵn sàng" = trống + sạch + bình thường — composite suy ra, không phải trường lưu (BR-housekeeping-003). Nguồn danh sách đang trực — OQ-1.

> Ảnh nghiệm thu thuộc một lần dọn, không phải album cố định của phòng. Bộ tối thiểu có một ảnh `tong_quan`, `khu_ngu` và `nha_ve_sinh`; `can_canh` chỉ dùng khi có bất thường (BR-housekeeping-006).
