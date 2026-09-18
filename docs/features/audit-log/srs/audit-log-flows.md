---
type: srs-flows
feature: audit-log
updated: 2026-09-17
---

# audit-log — Flows

## Flow: Ghi bản ghi nhật ký

**Trigger**: Thao tác ghi đã kiểm quyền sẵn sàng lưu  
**Related UC**: [[../usecases/uc-ghi-ban-ghi-nhat-ky.md]]  
**Related FR**: FR-audit-log-001, FR-audit-log-002, FR-audit-log-003, FR-audit-log-004, FR-audit-log-006  
**Related E**: E-audit-log-005

```mermaid
sequenceDiagram
    actor NV as Nhan vien / He thong
    participant BE as May chu
    participant NK as Nhat ky

    NV->>BE: Thao tac ghi
    BE->>BE: Kiem quyen

    alt Tu choi quyen
        BE-->>NV: Khong doi du lieu, khong ghi NK
    else Du quyen
        BE->>BE: Chuan bi ban ghi
        opt Doi trang thai phong nhieu truc
            BE->>BE: Liet ke du tung truc truoc sang sau
        end
        BE->>NK: Luu du lieu + ban ghi nhu mot ket qua
        alt Luu NK that bai
            NK-->>BE: Loi
            BE-->>NV: E-audit-log-005 Thao tac chua hoan tat
        else Thanh cong
            NK-->>BE: OK
            BE-->>NV: Thao tac hoan tat
        end
    end
```

```mermaid
flowchart TD
    A["Nhan thao tac ghi"] --> B{"Kiem quyen OK?"}
    B -->|"Khong"| Z["KetThuc khong doi khong ghi"]
    B -->|"Co"| C["Chuan bi ban ghi"]
    C --> D{"Co thay doi trang thai phong?"}
    D -->|"Co"| E["Liet ke tung truc"]
    D -->|"Khong"| F["Ghi truong truoc sang sau"]
    E --> G["Luu du lieu + NK cung ket qua"]
    F --> G
    G --> H{"Luu NK OK?"}
    H -->|"Khong"| I["KetThuc E-audit-log-005"]
    H -->|"Co"| J["KetThuc hoan tat"]
```

## Flow: Xem nhật ký theo phòng

**Trigger**: Quản lý mở nhật ký một phòng  
**Related UC**: [[../usecases/uc-xem-nhat-ky-theo-phong.md]]  
**Related FR**: FR-audit-log-007, FR-audit-log-009, FR-audit-log-011  
**Related E**: E-audit-log-001, E-audit-log-003, E-audit-log-004

```mermaid
sequenceDiagram
    actor QL as Quan ly
    participant UI as Giao dien
    participant BE as May chu

    QL->>UI: Mo nhat ky theo phong
    UI->>BE: Yeu cau doc nhat ky phong
    BE->>BE: Kiem quyen quan ly

    alt Khong du quyen
        BE-->>UI: Tu choi
        UI-->>QL: E-audit-log-001
    else Du quyen
        BE-->>UI: Danh sach moi nhat truoc, tai theo phan
        alt Khong co ban ghi
            UI-->>QL: E-audit-log-004 trang thai rong
        else Co ban ghi
            UI-->>QL: Dong thoi gian day du
        end
    end

    opt Mat ket noi
        BE-->>UI: Loi mang
        UI-->>QL: E-audit-log-003
    end
```

## Flow: Lọc nhật ký

**Trigger**: Quản lý đặt lọc thời gian / vai trò / người  
**Related UC**: [[../usecases/uc-loc-nhat-ky.md]]  
**Related FR**: FR-audit-log-008, FR-audit-log-010  
**Related E**: E-audit-log-002, E-audit-log-003, E-audit-log-004

```mermaid
sequenceDiagram
    actor QL as Quan ly
    participant UI as Giao dien
    participant BE as May chu

    QL->>UI: Dat loc tu-den / vai tro / nguoi
    UI->>BE: Ap dung loc
    alt Khoang thoi gian khong hop le
        BE-->>UI: Tu choi
        UI-->>QL: E-audit-log-002
    else Hop le
        BE-->>UI: Phan giao cac loc, moi nhat truoc
        alt Rong
            UI-->>QL: E-audit-log-004
        else Co ket qua
            UI-->>QL: Danh sach da thu hep
        end
    end
```

## Flow: Xem nhật ký chung (P1)

**Trigger**: Quản lý mở nhật ký toàn hệ thống  
**Related UC**: [[../usecases/uc-xem-nhat-ky-chung.md]]  
**Related FR**: FR-audit-log-010  
**Related E**: E-audit-log-001, E-audit-log-003, E-audit-log-004

```mermaid
sequenceDiagram
    actor QL as Quan ly
    participant UI as Giao dien
    participant BE as May chu

    QL->>UI: Mo nhat ky chung
    UI->>BE: Doc toan he thong
    BE->>BE: Kiem quyen
    alt Tu choi
        UI-->>QL: E-audit-log-001
    else OK
        BE-->>UI: Ban ghi gom su kien khong gan phong
        QL->>UI: Loc loai hanh dong / truc / loai doi tuong
        BE-->>UI: Ket qua loc
        UI-->>QL: Hien thi danh sach
    end
```
