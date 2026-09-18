---
type: srs-flows
feature: check-in-out
updated: 2026-09-17
---

# Check-in-out — Flows

## Flow: Nhan phong
**Trigger**: Le tan xac nhan nhan phong
**Related UC**: [[../usecases/uc-nhan-phong.md]]
**Related FR**: FR-check-in-out-001, FR-check-in-out-002, FR-check-in-out-003
**Related E**: E-check-in-out-001, E-check-in-out-002, E-check-in-out-003, E-check-in-out-004

```mermaid
sequenceDiagram
    actor LT as Le tan
    participant App as Ung dung
    participant HeThong as He thong

    LT->>App: "Chon phong san sang + nhap khach"
    App->>HeThong: Yeu cau nhan phong
    alt Dang o
        HeThong-->>App: E-check-in-out-001
        App-->>LT: "Chan + ly do"
    else Chua sach
        HeThong-->>App: E-check-in-out-002
        App-->>LT: "Chan + trang thai ve sinh"
    else Ngung phuc vu
        HeThong-->>App: E-check-in-out-003
        App-->>LT: Chan
    else Thieu thong tin khach
        HeThong-->>App: E-check-in-out-004
        App-->>LT: Chi ro truong, giu form
    else OK
        HeThong->>HeThong: Tao luot mo, luu tru = dang o
        HeThong->>HeThong: "Nhat ky + realtime"
        HeThong-->>App: Thanh cong
        App-->>LT: Cap nhat danh sach dang o
    end
```

```mermaid
flowchart TB
    Start((Bat dau)) --> Form["Nhap ten + so nguoi"]
    Form --> Cond{"3 dieu kien ok?"}
    Cond -->|"dang o"| E001["E-check-in-out-001"]
    Cond -->|"chua sach"| E002["E-check-in-out-002"]
    Cond -->|"ngung"| E003["E-check-in-out-003"]
    Cond -->|ok| Info{"Du thong tin?"}
    Info -->|thieu| E004["E-check-in-out-004"]
    Info -->|du| Create[Tao luot mo]
    Create --> Log["Nhat ky + realtime"]
    Log --> End((Ket thuc))
    E001 --> End
    E002 --> End
    E003 --> End
    E004 --> End
```

## Flow: Tra phong
**Trigger**: Le tan xac nhan tra phong
**Related UC**: [[../usecases/uc-tra-phong.md]]
**Related FR**: FR-check-in-out-004
**Related E**: E-check-in-out-005

```mermaid
sequenceDiagram
    actor LT as Le tan
    participant App as Ung dung
    participant HeThong as He thong
    participant HK as Housekeeping

    LT->>App: "Chon phong dang o + xac nhan tra"
    App->>HeThong: Tra phong
    alt Khong con dang o
        HeThong-->>App: E-check-in-out-005
        App-->>LT: Tai lai trang thai
    else OK
        HeThong->>HeThong: "Dong luot, trong + can don"
        HeThong->>HK: Su kien tra phong
        HeThong->>HeThong: "Nhat ky + realtime"
        HeThong-->>App: OK
        App-->>LT: Cap nhat danh sach
    end
```

```mermaid
flowchart TB
    Start((Bat dau)) --> Confirm[Xac nhan tra]
    Confirm --> State{"Dang o?"}
    State -->|khong| E005["E-check-in-out-005"]
    State -->|co| Close[Dong luot]
    Close --> Axes["Trong + can don"]
    Axes --> Event[Phat su kien housekeeping]
    Event --> Log["Nhat ky + realtime"]
    Log --> End((Ket thuc))
    E005 --> End
```

## Flow: Huy nhan phong
**Trigger**: Le tan huy nhan trong cua so ngan
**Related UC**: [[../usecases/uc-huy-nhan-phong.md]]
**Related FR**: FR-check-in-out-006
**Related E**: E-check-in-out-006

```mermaid
sequenceDiagram
    actor LT as Le tan
    participant App as Ung dung
    participant HeThong as He thong

    LT->>App: Huy nhan phong
    App->>HeThong: "Kiem cua so + chua phat sinh"
    alt Qua cua so / da phat sinh
        HeThong-->>App: E-check-in-out-006
        App-->>LT: Huong dan Tra phong
    else OK
        HeThong->>HeThong: Danh dau huy, ve trong, giu ve sinh
        HeThong->>HeThong: Nhat ky huy — khong su kien tra
        HeThong-->>App: OK
        App-->>LT: Cap nhat
    end
```

```mermaid
flowchart TB
    Start((Bat dau)) --> Win{"Trong cua so + chua phat sinh?"}
    Win -->|khong| E006["E-check-in-out-006"]
    Win -->|co| Cancel[Danh dau huy]
    Cancel --> Axes[Luu tru trong — giu ve sinh]
    Axes --> Log[Nhat ky huy]
    Log --> End((Ket thuc))
    E006 --> End
```
