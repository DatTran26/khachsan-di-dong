---
type: srs-flows
feature: ai-ops-summary
updated: 2026-09-17
---

# ai-ops-summary — Flows

## Flow: Tao tom tat van hanh

**Trigger**: Quan ly bam Tao tom tat  
**Related UC**: [[../usecases/uc-tao-tom-tat-van-hanh.md]]  
**Related FR**: FR-ai-ops-summary-001 den FR-ai-ops-summary-010, FR-ai-ops-summary-014  
**Related E**: E-ai-ops-summary-001 den E-ai-ops-summary-007

```mermaid
sequenceDiagram
    actor QL as Quan ly
    participant UI as Giao dien
    participant BE as May chu
    participant LLM as Dich vu LLM
    participant NK as audit-log

    QL->>UI: Chon ky + bam Tao
    UI->>BE: Yeu cau tao
    BE->>BE: Kiem quyen quan ly

    alt Sai quyen
        BE-->>UI: E-ai-ops-summary-006
    else Dang co luot chay
        BE-->>UI: E-ai-ops-summary-007
    else OK
        BE->>BE: Chot T + khoa nut tao
        BE->>BE: Tinh so lieu tong hop
        alt Ky rong
            BE-->>UI: Bao cao mau rong E-ai-ops-summary-001
            BE->>NK: Ghi luot tao
        else Het han muc
            BE-->>UI: Bao cao mau E-ai-ops-summary-003
            BE->>NK: Ghi luot tao
        else Con han muc
            BE->>LLM: Gui so lieu tong hop
            alt AI loi hoac timeout
                LLM-->>BE: Loi
                BE-->>UI: Bao cao mau E-ai-ops-summary-002
            else Tra ve
                BE->>BE: Kiem dau ra
                alt Khong hop le
                    BE-->>UI: Bao cao mau E-ai-ops-summary-005
                else Hop le
                    BE-->>UI: Ban AI + T + nhan tham khao
                end
            end
            BE->>NK: Ghi luot tao
        end
    end

    opt Mat ket noi
        UI-->>QL: E-ai-ops-summary-004
    end
```

```mermaid
flowchart TD
    A["Chon ky + Tao"] --> B{"Quyen quan ly?"}
    B -->|"Khong"| Z1["KetThuc E-006"]
    B -->|"Co"| C{"Dang tao?"}
    C -->|"Co"| Z2["KetThuc E-007"]
    C -->|"Khong"| D["Chot T + khoa nut"]
    D --> E["Tinh so lieu tong hop"]
    E --> F{"Ky co DL?"}
    F -->|"Khong"| M1["Mau rong E-001"]
    F -->|"Co"| G{"Con han muc chi phi?"}
    G -->|"Khong"| M2["Mau E-003"]
    G -->|"Co"| H["Goi OpenAI Responses API"]
    H --> I{"AI OK trong 15 giay?"}
    I -->|"Khong"| M3["Mau E-002"]
    I -->|"Co"| J{"Dau ra khop?"}
    J -->|"Khong"| M4["Mau E-005"]
    J -->|"Co"| K["Hien AI + nhan tham khao"]
    M1 --> L["Ghi nhat ky luot tao"]
    M2 --> L
    M3 --> L
    M4 --> L
    K --> L
    L --> END["Ket thuc"]
```

## Flow: Dieu phoi viec can chu y

**Related UC**: [[../usecases/uc-dieu-phoi-viec-can-chu-y.md]]  
**Related FR**: FR-ai-ops-summary-012

```mermaid
sequenceDiagram
    actor QL as Quan ly
    participant UI as Tom tat
    participant DB as room-dashboard

    QL->>UI: Bam muc viec can chu y
    UI->>DB: Dieu huong toi vi tri tuong ung
    DB-->>QL: Man dashboard tai doi tuong
```
