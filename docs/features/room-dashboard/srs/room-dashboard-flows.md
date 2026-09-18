---
type: srs-flows
feature: room-dashboard
updated: 2026-09-17
---

# room-dashboard — Flows

## Flow: Mở dashboard (Sequence)

**Related UC**: [[../usecases/uc-mo-va-xem-dashboard.md]]
**Related FR**: FR-room-dashboard-001, FR-room-dashboard-002, FR-room-dashboard-008, FR-room-dashboard-010
**Related E**: E-room-dashboard-002, E-room-dashboard-003, E-room-dashboard-004

```mermaid
sequenceDiagram
    actor User as Nguoi xem
    participant App
    participant Server as MayChu

    User->>App: Mo dashboard
    App->>Server: Kiem quyen + tai trang thai
    alt Sai quyen
        Server-->>App: Tu choi
        App-->>User: E-room-dashboard-003
    else Phien het han
        Server-->>App: Het phien
        App-->>User: E-room-dashboard-004
    else Tai that bai
        App-->>User: E-room-dashboard-002
    else Thanh cong
        Server-->>App: Luoi 3 truc + chi so
        App-->>User: Hien dashboard
    end
```

## Flow: Mở dashboard (Activity)

```mermaid
flowchart TB
    Start((Bat dau)) --> Quyen{"Du quyen xem?"}
    Quyen -->|"khong"| E003["E-room-dashboard-003"]
    Quyen -->|"co"| Tai{"Tai OK?"}
    Tai -->|"khong"| E002["E-room-dashboard-002"]
    Tai -->|"co"| Hien["Luoi 3 truc + chi so"]
    Hien --> Mau0{"Mau so lap day = 0?"}
    Mau0 -->|"co"| N_A["Hien khong ap dung"]
    Mau0 -->|"khong"| Pct["Hien ty le %"]
    N_A --> EndOk((Ket thuc))
    Pct --> EndOk
    E003 --> EndFail((Ket thuc))
    E002 --> EndFail
```

## Flow: Realtime + cờ quá hạn (Sequence)

**Related UC**: [[../usecases/uc-theo-doi-realtime-va-qua-han.md]]
**Related FR**: FR-room-dashboard-005, FR-room-dashboard-006
**Related E**: E-room-dashboard-001

```mermaid
sequenceDiagram
    participant Src as FeatureNguon
    participant Sync as RealtimeSync
    participant Dash as Dashboard

    Src->>Sync: Luu OK + phat su kien
    Sync->>Dash: Cap nhat truc / co qua han
    Note over Dash: Hien trong toi da 3s
    Dash->>Dash: Cap nhat o phong + chi so
```

## Flow: Realtime + cờ quá hạn (Activity)

```mermaid
flowchart TB
    Start((Bat dau)) --> Nhan["Nhan su kien"]
    Nhan --> Online{"Con ket noi?"}
    Online -->|"khong"| E001["E-room-dashboard-001"]
    Online -->|"co"| CapNhat["Cap nhat o + chi so"]
    CapNhat --> CoQH{"Co co qua han?"}
    CoQH -->|"co"| To["To co + dem"]
    CoQH -->|"khong"| Ok((Ket thuc))
    To --> Ok
    E001 --> EndOff((Ket thuc))
```

## Flow: Lọc phòng (Sequence)

**Related UC**: [[../usecases/uc-loc-phong.md]]
**Related FR**: FR-room-dashboard-007
**Related E**: E-room-dashboard-005

```mermaid
sequenceDiagram
    actor User as Nguoi xem
    participant App

    User->>App: Chon tang / nhom trang thai
    alt 0 ket qua
        App-->>User: E-room-dashboard-005
    else Co ket qua
        App-->>User: Luoi phong khop
    end
```

## Flow: Lọc phòng (Activity)

```mermaid
flowchart TB
    Start((Bat dau)) --> Loc["Chon bo loc"]
    Loc --> CoKQ{"Co phong khop?"}
    CoKQ -->|"khong"| E005["E-room-dashboard-005"]
    CoKQ -->|"co"| Luoi["Hien luoi da loc"]
    Luoi --> Ok((Ket thuc))
    E005 --> EndEmpty((Ket thuc))
```

## Flow: Mất kết nối dashboard (Sequence)

**Related UC**: [[../usecases/uc-xu-ly-mat-ket-noi-dashboard.md]]
**Related FR**: FR-room-dashboard-009
**Related E**: E-room-dashboard-001

```mermaid
sequenceDiagram
    actor User as Nguoi xem
    participant App
    participant Server as MayChu

    App-->>User: E-room-dashboard-001 banner
    App->>App: Danh dau du lieu loi thoi
    App->>Server: Co mang - tai trang thai moi
    Server-->>App: Ban moi nhat
    App-->>User: Cap nhat + da ket noi lai
```

## Flow: Mất kết nối dashboard (Activity)

```mermaid
flowchart TB
    Start((Bat dau)) --> Banner["E-room-dashboard-001"]
    Banner --> Cho["Cho mang"]
    Cho --> Tai["Tai trang thai moi"]
    Tai --> CapNhat["Cap nhat luoi + chi so"]
    CapNhat --> Ok((Ket thuc))
```
