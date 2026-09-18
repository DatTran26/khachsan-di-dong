---
type: srs-states
feature: ai-ops-summary
updated: 2026-09-17
---

# ai-ops-summary — States

## State: BanTomTatKy

**Related entity**: BanTomTatKy  
**Related UC**: [[../usecases/uc-tao-tom-tat-van-hanh.md]]  
**Related BR**: BR-ai-ops-summary-004, BR-ai-ops-summary-005, BR-ai-ops-summary-006

```mermaid
stateDiagram-v2
    [*] --> chua_co
    chua_co --> dang_tao : quan ly bam Tao
    dang_tao --> rong : ky khong co du lieu
    dang_tao --> san_sang_AI : AI hop le
    dang_tao --> san_sang_mau : AI loi / timeout / het han muc / dau ra sai
    rong --> [*]
    san_sang_AI --> [*]
    san_sang_mau --> [*]
    san_sang_AI --> dang_tao : tao lai ky moi
    san_sang_mau --> dang_tao : tao lai ky moi
    rong --> dang_tao : tao lai
```

### Invalid transitions

| From | To | Why not |
|---|---|---|
| chua_co | san_sang_AI | Phai qua dang_tao va goi AI |
| dang_tao | san_sang_AI | Khong hop le neu dau ra sai — phai mau |
| san_sang_AI | rong | Khong chuyen nguoc sau khi da co noi dung |

## State: HanMucAI

**Related entity**: HanMucAI  
**Related FR**: FR-ai-ops-summary-009  
**Note**: Hinh thuc va nguong — `spec.md#OQ-2` (khong bia so).

```mermaid
stateDiagram-v2
    [*] --> con_han_muc
    con_han_muc --> con_han_muc : goi AI thanh cong tru han muc
    con_han_muc --> het_han_muc : cham nguong OQ-2
    het_han_muc --> het_han_muc : yeu cau tao chi bao cao mau
    het_han_muc --> [*]
```

### Invalid transitions

| From | To | Why not |
|---|---|---|
| het_han_muc | con_han_muc | MVP khong mo ta nap lai trong feature nay |
