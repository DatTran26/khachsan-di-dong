---
type: srs-flows
feature: housekeeping
updated: 2026-09-17
---

# housekeeping — Flows

## Flow: Tạo và giao việc sau trả phòng (Sequence)

**Trigger**: Sự kiện trả phòng
**Related UC**: [[../usecases/uc-tao-giao-viec-sau-tra-phong.md]]
**Related FR**: FR-housekeeping-001, FR-housekeeping-002, FR-housekeeping-003, FR-housekeeping-013
**Related E**: E-housekeeping-002

```mermaid
sequenceDiagram
    participant CIO as CheckInOut
    participant Server as MayChu
    actor QL as QuanLy
    actor NV as NVBuongPhong

    CIO->>Server: Su kien tra phong
    Server->>Server: Tao 1 viec don + truc ve sinh can don
    alt Khong co NV dang truc
        Server-->>QL: E-housekeeping-002 cho giao
    else Co NV truc
        Server->>Server: Giao NV it viec mo nhat
        Server-->>NV: Viec da giao
    end
    Server->>Server: Ghi nhat ky + realtime
```

## Flow: Tạo và giao việc (Activity)

**Related E**: E-housekeeping-002

```mermaid
flowchart TB
    Start((Bat dau)) --> NhanSK["Nhan su kien tra phong"]
    NhanSK --> Tao["Tao 1 viec + can don"]
    Tao --> CoTruc{"Co NV dang truc?"}
    CoTruc -->|"khong"| E002["E-housekeeping-002 cho giao"]
    CoTruc -->|"co"| Chon["Chon NV it viec / hoa theo BR-004"]
    Chon --> DaGiao["Trang thai da giao"]
    DaGiao --> Log["Nhat ky + realtime"]
    E002 --> Log
    Log --> EndOk((Ket thuc))
```

## Flow: Nhận / từ chối việc (Sequence)

**Related UC**: [[../usecases/uc-nhan-tu-choi-viec.md]]
**Related FR**: FR-housekeeping-004, FR-housekeeping-011, FR-housekeeping-012
**Related E**: E-housekeeping-001, E-housekeeping-003, E-housekeeping-004, E-housekeeping-006

```mermaid
sequenceDiagram
    actor NV as NVBuongPhong
    participant App
    participant Server as MayChu

    NV->>App: Nhan viec da giao
    App->>Server: Ghi nhan kem phien ban
    alt Da co nguoi nhan
        Server-->>App: Tu choi
        App-->>NV: E-housekeeping-001
    else Sai trang thai / phien ban
        Server-->>App: Tu choi
        App-->>NV: E-housekeeping-004
    else Sai quyen
        Server-->>App: Tu choi
        App-->>NV: E-housekeeping-006
    else Mat mang
        App-->>NV: E-housekeeping-003
    else Thanh cong
        Server->>Server: dang lam + dang don
        Server->>Server: Nhat ky + realtime
        Server-->>App: OK
    end
```

## Flow: Nhận / từ chối (Activity)

```mermaid
flowchart TB
    Start((Bat dau)) --> Chon{"Nhan hay tu choi?"}
    Chon -->|"nhan"| Kiem["Kiem quyen + phien ban"]
    Kiem -->|"OK"| CapNhat["dang lam / dang don"]
    Kiem -->|"xung dot"| E001["E-housekeeping-001 / 004"]
    Chon -->|"tu choi"| GiaoLai{"Con NV truc khac?"}
    GiaoLai -->|"co"| GanMoi["Giao lai NV ke"]
    GiaoLai -->|"khong"| ChoGiao["cho giao + E-002"]
    CapNhat --> Log["Nhat ky + realtime"]
    GanMoi --> Log
    ChoGiao --> Log
    E001 --> EndFail((Ket thuc))
    Log --> EndOk((Ket thuc OK))
```

## Flow: Báo hoàn tất → xác nhận / trả lại (Sequence)

**Related UC**: [[../usecases/uc-bao-hoan-tat.md]], [[../usecases/uc-xac-nhan-tra-lai.md]]
**Related FR**: FR-housekeeping-005, FR-housekeeping-006, FR-housekeeping-007
**Related E**: E-housekeeping-005

```mermaid
sequenceDiagram
    actor NV as NVBuongPhong
    actor QL as QuanLy
    participant Server as MayChu

    NV->>Server: Bao hoan tat
    Server->>Server: cho xac nhan / cho kiem tra
    Server-->>QL: Thong bao hang cho
    alt QL xac nhan
        QL->>Server: Xac nhan
        Server->>Server: hoan tat / sach
        Note over Server: San sang neu trong + sach + dang phuc vu
    else QL tra lai
        QL->>Server: Tra lai + ghi chu
        alt Thieu ghi chu
            Server-->>QL: E-housekeeping-005
        else Hop le
            Server->>Server: dang lam / dang don + ghi chu
        end
    end
    Server->>Server: Nhat ky + realtime
```

## Flow: Cảnh báo quá hạn (Activity)

**Related UC**: [[../usecases/uc-canh-bao-qua-han.md]]
**Related FR**: FR-housekeeping-008
**Related BR**: BR-housekeeping-002

```mermaid
flowchart TB
    Start((Bat dau)) --> Quet["Quet viec chua hoan tat"]
    Quet --> Qua60{"Vuot 60 phut tu moc tao?"}
    Qua60 -->|"khong"| EndSkip((Ket thuc))
    Qua60 -->|"co"| Co["Danh co qua han"]
    Co --> CanhBao["Canh bao QL + NV"]
    CanhBao --> ChoHT{"Viec hoan tat?"}
    ChoHT -->|"co"| Go["Go co qua han"]
    ChoHT -->|"chua"| EndWait((Cho chu ky sau))
    Go --> EndOk((Ket thuc))
```
