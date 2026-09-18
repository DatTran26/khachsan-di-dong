---
type: srs-flows
feature: room-catalog
updated: 2026-09-17
---

# Room Catalog — Flows

## Flow: Them phong
**Trigger**: Quan ly bam "Them phong"
**Related UC**: [[../usecases/uc-them-sua-xoa-phong.md]]
**Related FR**: FR-room-catalog-001, FR-room-catalog-002, FR-room-catalog-012
**Related E**: E-room-catalog-001, E-room-catalog-005, E-room-catalog-007

```mermaid
sequenceDiagram
    actor QL as Quan ly
    participant App as Ung dung
    participant HeThong as He thong

    QL->>App: Mo form them phong
    QL->>App: Nhap so phong, tang, loai
    App->>HeThong: Luu phong moi
    alt So phong trung
        HeThong-->>App: Tu choi E-room-catalog-001
        App-->>QL: Bao so da ton tai, giu form
    else Thanh cong
        HeThong->>HeThong: "Mac dinh trong + sach + binh thuong"
        HeThong->>HeThong: "Ghi nhat ky + realtime"
        HeThong-->>App: Phong da tao
        App-->>QL: Cap nhat danh muc
    else Mat mang
        HeThong-->>App: Loi E-room-catalog-005
        App-->>QL: Thao tac chua luu
    end
```

```mermaid
flowchart TB
    Start((Bat dau)) --> Form[Nhap so tang loai]
    Form --> Check{"Hop le?"}
    Check -->|"trung so"| E001["E-room-catalog-001"]
    Check -->|"mat mang"| E005["E-room-catalog-005"]
    Check -->|"sai quyen"| E007["E-room-catalog-007"]
    Check -->|"ok"| Create[Tao phong mac dinh]
    Create --> Log["Nhat ky + realtime"]
    Log --> End((Ket thuc))
    E001 --> End
    E005 --> End
    E007 --> End
```

## Flow: Sua / xoa phong
**Trigger**: Quan ly chon sua hoac xoa phong
**Related UC**: [[../usecases/uc-them-sua-xoa-phong.md]]
**Related FR**: FR-room-catalog-003, FR-room-catalog-004
**Related E**: E-room-catalog-001, E-room-catalog-002, E-room-catalog-003, E-room-catalog-006

```mermaid
sequenceDiagram
    actor QL as Quan ly
    participant App as Ung dung
    participant HeThong as He thong

    QL->>App: Chon sua hoac xoa phong
    App->>HeThong: Gui yeu cau ghi
    alt Xoa khi dang o / viec mo
        HeThong-->>App: E-room-catalog-002
        App-->>QL: Tu choi xoa
    else Xoa khi da co lich su
        HeThong-->>App: E-room-catalog-003
        App-->>QL: Goi y ngung phuc vu
    else Sua so trung
        HeThong-->>App: E-room-catalog-001
        App-->>QL: Bao trung so
    else Trang thai da doi
        HeThong-->>App: E-room-catalog-006
        App-->>QL: Yeu cau tai lai
    else Thanh cong
        HeThong->>HeThong: Cap nhat hoac xoa
        HeThong->>HeThong: "Nhat ky + realtime"
        HeThong-->>App: OK
        App-->>QL: Danh muc moi
    end
```

```mermaid
flowchart TB
    Start((Bat dau)) --> Action{"Sua hay xoa?"}
    Action -->|sua| Sua[Luu thay doi]
    Action -->|xoa| Cond{"Du dieu kien xoa?"}
    Cond -->|"dang o / viec mo"| E002["E-room-catalog-002"]
    Cond -->|"co lich su"| E003["E-room-catalog-003"]
    Cond -->|du| Xoa[Xoa cung]
    Sua --> CheckTrung{"So trung?"}
    CheckTrung -->|co| E001["E-room-catalog-001"]
    CheckTrung -->|khong| Done["Nhat ky + realtime"]
    Xoa --> Done
    Done --> End((Ket thuc))
    E001 --> End
    E002 --> End
    E003 --> End
```

## Flow: Dat / go ngung phuc vu
**Trigger**: Quan ly hoac le tan dat/go ngung phuc vu
**Related UC**: [[../usecases/uc-dat-go-ngung-phuc-vu.md]]
**Related FR**: FR-room-catalog-007, FR-room-catalog-008
**Related E**: E-room-catalog-004

```mermaid
sequenceDiagram
    actor User as "Quan ly hoac Le tan"
    participant App as "Ung dung"
    participant HeThong as "He thong"

    User->>App: Chon dat hoac go ngung phuc vu
    alt Dat ngung
        App-->>User: Form ly do bat buoc
        opt Phong dang o
            App-->>User: Canh bao va xac nhan lai
        end
        User->>App: Nhap ly do va xac nhan
        alt Thieu ly do
            App-->>User: E-room-catalog-004
        else OK
            App->>HeThong: Cap nhat bao tri = ngung
            HeThong->>HeThong: Nhat ky va realtime
            HeThong-->>App: OK
            App-->>User: Cap nhat danh muc
        end
    else Go ngung
        User->>App: Xac nhan go
        App->>HeThong: Bao tri = binh thuong
        HeThong->>HeThong: Nhat ky va realtime
        HeThong-->>App: OK
        App-->>User: Cap nhat danh muc
    end
```

```mermaid
flowchart TB
    Start((Bat dau)) --> Loai{"Dat hay go?"}
    Loai -->|dat| LyDo{"Co ly do?"}
    LyDo -->|khong| E004["E-room-catalog-004"]
    LyDo -->|co| Warn{"Phong dang o?"}
    Warn -->|co| Confirm["Canh bao + xac nhan"]
    Warn -->|khong| SetStop[Bao tri = ngung]
    Confirm -->|huy| End((Ket thuc))
    Confirm -->|ok| SetStop
    Loai -->|go| SetNormal[Bao tri = binh thuong]
    SetStop --> Log["Nhat ky + realtime"]
    SetNormal --> Log
    Log --> End
    E004 --> End
```

## Flow: Tra cuu / loc
**Trigger**: Actor mo danh muc va ap dung bo loc
**Related UC**: [[../usecases/uc-tra-cuu-loc-phong.md]]
**Related FR**: FR-room-catalog-005, FR-room-catalog-006

```mermaid
sequenceDiagram
    actor User as "Nguoi dung"
    participant App as "Ung dung"
    participant HeThong as "He thong"

    User->>App: Mo danh muc phong
    App->>HeThong: Tai danh sach va 3 truc
    HeThong-->>App: Danh sach
    App-->>User: Hien thi phong va san sang composite
    User->>App: Chon bo loc tang loai trang thai
    App->>HeThong: Loc
    alt Khong co ket qua
        HeThong-->>App: Rong
        App-->>User: Trang thai rong
    else Co ket qua
        HeThong-->>App: Danh sach loc
        App-->>User: Hien thi ket qua
    end
```

```mermaid
flowchart TB
    Start((Bat dau)) --> Load[Tai danh muc]
    Load --> Filter[Ap dung bo loc]
    Filter --> Has{"Co phong?"}
    Has -->|khong| Empty[Trang thai rong]
    Has -->|co| Show[Hien thi 3 truc]
    Empty --> End((Ket thuc))
    Show --> End
```
