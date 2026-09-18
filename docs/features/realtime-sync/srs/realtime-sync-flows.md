---
type: srs-flows
feature: realtime-sync
updated: 2026-09-17
---

# realtime-sync — Flows

## Flow: Lan truyền cập nhật (Sequence)

**Related UC**: [[../usecases/uc-lan-truyen-cap-nhat.md]]
**Related FR**: FR-realtime-sync-001, FR-realtime-sync-002
**Related E**: E-realtime-sync-004

```mermaid
sequenceDiagram
    actor DevA as Thiet bi A
    actor DevB as Thiet bi B
    participant Server as May chu

    DevA->>Server: Ghi trang thai kem phien ban
    Server->>Server: Luu thanh cong + tang phien ban
    Server-->>DevA: Xac nhan
    Server->>DevB: Phat su kien cap nhat
    DevB->>DevB: Ap dung trang thai moi
    opt Ap dung that bai
        DevB->>Server: Tai trang thai moi
        Note over DevB,Server: E-realtime-sync-004 khong hien thi loi
    end
```

## Flow: Lan truyền cập nhật (Activity)

```mermaid
flowchart TB
    Start((Bat dau)) --> Ghi["Nhan yeu cau ghi"]
    Ghi --> Luu{"Luu thanh cong?"}
    Luu -->|"khong"| NoEmit["Khong phat su kien"]
    Luu -->|"co"| Tang["Tang phien ban"]
    Tang --> Phat["Phat su kien toi thiet bi"]
    Phat --> Apply{"Ap dung OK?"}
    Apply -->|"co"| Done((Ket thuc OK))
    Apply -->|"khong"| Reload["Tai trang thai moi E-realtime-sync-004"]
    Reload --> Done
    NoEmit --> Fail((Ket thuc))
```

## Flow: Xung đột phiên bản (Sequence)

**Related UC**: [[../usecases/uc-xu-ly-xung-dot.md]]
**Related FR**: FR-realtime-sync-003, FR-realtime-sync-004
**Related E**: E-realtime-sync-002

```mermaid
sequenceDiagram
    actor DevA as Thiet bi A
    actor DevB as Thiet bi B
    participant Server as May chu

    DevA->>Server: Ghi phien ban N
    Server->>Server: Luu + phien ban N+1
    DevB->>Server: Ghi phien ban N cu
    Server-->>DevB: Tu choi
    Server-->>DevB: E-realtime-sync-002
    DevB->>Server: Tai trang thai moi
    Server-->>DevB: Ban moi nhat
```

## Flow: Xung đột phiên bản (Activity)

```mermaid
flowchart TB
    Start((Bat dau)) --> Gui["Gui ghi kem phien ban"]
    Gui --> Match{"Phien ban khop?"}
    Match -->|"co"| Luu["Luu + phat su kien"]
    Match -->|"khong"| Reject["Tu choi ghi"]
    Reject --> Msg["E-realtime-sync-002"]
    Msg --> Tai["Tai trang thai moi"]
    Luu --> Ok((Ket thuc OK))
    Tai --> EndReject((Ket thuc))
```

## Flow: Mất kết nối / reconnect (Sequence)

**Related UC**: [[../usecases/uc-xu-ly-mat-ket-noi.md]]
**Related FR**: FR-realtime-sync-005, FR-realtime-sync-006, FR-realtime-sync-010
**Related E**: E-realtime-sync-001, E-realtime-sync-003

```mermaid
sequenceDiagram
    actor User as Nguoi dung
    participant App as Thiet bi
    participant Server as May chu

    App->>App: Phat hien mat lien lac
    App-->>User: Banner mat ket noi
    App->>App: Khoa ghi
    User->>App: Thu ghi
    App-->>User: E-realtime-sync-001
    App->>Server: Co mang - reconnect
    alt Phien het han
        Server-->>App: Phien het
        App-->>User: E-realtime-sync-003
    else Phien con han
        App->>Server: Tai trang thai moi
        Server-->>App: Ban moi
        App->>App: Mo khoa ghi
        App-->>User: Da ket noi lai
    end
```

## Flow: Mất kết nối / reconnect (Activity)

```mermaid
flowchart TB
    Start((Bat dau)) --> Mat["Mat lien lac may chu"]
    Mat --> Banner["Hien banner + khoa ghi"]
    Banner --> ThuGhi{"User thu ghi?"}
    ThuGhi -->|"co"| E001["E-realtime-sync-001"]
    ThuGhi -->|"khong"| ChoMang["Cho mang tro lai"]
    E001 --> ChoMang
    ChoMang --> Reconnect["Tu reconnect"]
    Reconnect --> Phien{"Phien con han?"}
    Phien -->|"khong"| E003["E-realtime-sync-003 dang nhap lai"]
    Phien -->|"co"| Tai["Tai trang thai moi"]
    Tai --> MoKhoa["Mo khoa ghi"]
    MoKhoa --> Ok((Ket thuc OK))
    E003 --> EndLogin((Ket thuc))
```
