---
type: srs-flows
feature: maintenance
updated: 2026-09-17
---

# maintenance — Flows

## Flow: Báo hỏng → tạo việc (Sequence)

**Trigger**: Người dùng gửi báo hỏng hợp lệ
**Related UC**: [[../usecases/uc-bao-hong.md]]
**Related FR**: FR-maintenance-001, FR-maintenance-002, FR-maintenance-008, FR-maintenance-011
**Related E**: E-maintenance-002, E-maintenance-003, E-maintenance-006

```mermaid
sequenceDiagram
    actor User as Nguoi bao
    participant App
    participant Server as May chu

    User->>App: Gui bao hong (phong + mo ta)
    App->>Server: Tao viec bao tri
    alt Thieu mo ta
        Server-->>App: Tu choi
        App-->>User: E-maintenance-003
    else Sai quyen
        Server-->>App: Tu choi
        App-->>User: E-maintenance-006
    else Mat mang
        App-->>User: E-maintenance-002
    else Thanh cong
        Server->>Server: Tao viec cho nhan
        Server->>Server: Dat truc bao tri ngung neu can
        Server->>Server: Ghi nhat ky + phat realtime
        Server-->>App: Xac nhan
        App-->>User: Da tao viec
    end
```

## Flow: Báo hỏng → tạo việc (Activity)

**Trigger**: Người dùng gửi báo hỏng
**Related UC**: [[../usecases/uc-bao-hong.md]]
**Related E**: E-maintenance-002, E-maintenance-003, E-maintenance-006

```mermaid
flowchart TB
    Start((Bat dau)) --> Nhap["Nhap phong + mo ta"]
    Nhap --> CoMoTa{"Co mo ta?"}
    CoMoTa -->|"khong"| E003["E-maintenance-003"]
    CoMoTa -->|"co"| Quyen{"Du quyen?"}
    Quyen -->|"khong"| E006["E-maintenance-006"]
    Quyen -->|"co"| Mang{"Co mang?"}
    Mang -->|"khong"| E002["E-maintenance-002"]
    Mang -->|"co"| Tao["Tao viec cho nhan"]
    Tao --> CoViecMo{"Phong da co viec mo?"}
    CoViecMo -->|"co"| CanhBao["Canh bao nhe dang co viec mo"]
    CoViecMo -->|"khong"| DatNgung["Dat truc bao tri ngung"]
    CanhBao --> NhatKy["Ghi nhat ky + realtime"]
    DatNgung --> NhatKy
    NhatKy --> EndOk((Ket thuc OK))
    E003 --> EndFail((Ket thuc))
    E006 --> EndFail
    E002 --> EndFail
```

## Flow: Nhận việc (Sequence)

**Trigger**: NV bảo trì nhận việc "chờ nhận"
**Related UC**: [[../usecases/uc-nhan-viec.md]]
**Related FR**: FR-maintenance-004, FR-maintenance-011
**Related E**: E-maintenance-001, E-maintenance-002, E-maintenance-004, E-maintenance-006

```mermaid
sequenceDiagram
    actor NV as NV bao tri
    participant App
    participant Server as May chu

    NV->>App: Nhan viec cho nhan
    App->>Server: Ghi nhan viec kem phien ban
    alt Da co nguoi nhan
        Server-->>App: Tu choi
        App-->>NV: E-maintenance-001
        Note over App,Server: Tai lai danh sach
    else Sai trang thai
        Server-->>App: Tu choi
        App-->>NV: E-maintenance-004
    else Thanh cong
        Server->>Server: chuyen dang sua + gan nguoi
        Server->>Server: Nhat ky + realtime
        Server-->>App: OK
        App-->>NV: Da nhan viec
    end
```

## Flow: Nhận việc (Activity)

**Related E**: E-maintenance-001, E-maintenance-004

```mermaid
flowchart TB
    Start((Bat dau)) --> Chon["Chon viec cho nhan"]
    Chon --> KiemTra{"Con cho nhan va dung quyen?"}
    KiemTra -->|"khong"| E004["E-maintenance-004 / E-maintenance-006"]
    KiemTra -->|"co"| XungDot{"Ai do da nhan?"}
    XungDot -->|"co"| E001["E-maintenance-001"]
    XungDot -->|"khong"| CapNhat["Chuyen dang sua"]
    CapNhat --> Sync["Nhat ky + realtime"]
    Sync --> EndOk((Ket thuc OK))
    E004 --> EndFail((Ket thuc))
    E001 --> EndFail
```

## Flow: Hoàn tất việc (Sequence)

**Related UC**: [[../usecases/uc-hoan-tat-viec.md]]
**Related FR**: FR-maintenance-003, FR-maintenance-005, FR-maintenance-011
**Related E**: E-maintenance-002, E-maintenance-004, E-maintenance-006

```mermaid
sequenceDiagram
    actor NV as NV bao tri
    participant App
    participant Server as May chu

    NV->>App: Bao hoan tat
    App->>Server: Dong viec dang sua
    alt Sai quyen hoac sai trang thai
        Server-->>App: Tu choi
        App-->>NV: E-maintenance-004 / E-maintenance-006
    else Thanh cong
        Server->>Server: Viec hoan tat
        Server->>Server: Danh gia lai truc bao tri phong
        Server->>Server: Nhat ky + realtime
        Server-->>App: OK
        App-->>NV: Da hoan tat
    end
```

## Flow: Hoàn tất việc (Activity)

```mermaid
flowchart TB
    Start((Bat dau)) --> BaoXong["Bao xong"]
    BaoXong --> HopLe{"Dung nguoi va dang sua?"}
    HopLe -->|"khong"| Err["E-maintenance-004 / E-maintenance-006"]
    HopLe -->|"co"| Dong["Chuyen hoan tat"]
    Dong --> HetMo{"Het viec mo va khong co ngung tay?"}
    HetMo -->|"co"| MoLai["Truc bao tri binh thuong"]
    HetMo -->|"khong"| GiuNgung["Giu ngung phuc vu"]
    MoLai --> Sync["Nhat ky + realtime"]
    GiuNgung --> Sync
    Sync --> EndOk((Ket thuc OK))
    Err --> EndFail((Ket thuc))
```

## Flow: Đặt/gỡ ngừng tay (Sequence)

**Related UC**: [[../usecases/uc-dat-go-ngung.md]]
**Related FR**: FR-maintenance-007, FR-maintenance-011
**Related E**: E-maintenance-002, E-maintenance-005, E-maintenance-006

```mermaid
sequenceDiagram
    actor LT as Le tan / QL
    participant App
    participant Server as May chu

    LT->>App: Dat hoac go ngung tay
    App->>Server: Cap nhat co ngung tay
    alt Go khi con viec mo
        Server-->>App: Tu choi
        App-->>LT: E-maintenance-005
    else Sai quyen
        Server-->>App: Tu choi
        App-->>LT: E-maintenance-006
    else Thanh cong
        Server->>Server: Cap nhat truc bao tri
        Server->>Server: Nhat ky + realtime
        Server-->>App: OK
        App-->>LT: Xac nhan
    end
```

## Flow: Đặt/gỡ ngừng tay (Activity)

```mermaid
flowchart TB
    Start((Bat dau)) --> Chon{"Dat hay go?"}
    Chon -->|"dat"| LyDo{"Co ly do bat buoc?"}
    LyDo -->|"khong"| YeuCau["Yeu cau nhap ly do"]
    LyDo -->|"co"| Dat["Dat co ngung tay"]
    Chon -->|"go"| ConViec{"Con viec bao tri mo?"}
    ConViec -->|"co"| E005["E-maintenance-005"]
    ConViec -->|"khong"| Go["Go co ngung tay"]
    Dat --> Sync["Nhat ky + realtime"]
    Go --> Sync
    Sync --> EndOk((Ket thuc OK))
    YeuCau --> EndFail((Ket thuc))
    E005 --> EndFail
```
