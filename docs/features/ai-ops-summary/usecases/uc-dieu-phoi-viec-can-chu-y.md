# Use Case: Dieu phoi tu muc viec can chu y

> Scope: Tom tat van hanh AI · Level: sea

## Primary Actor

Quan ly

## Trigger

Quan ly bam mot muc trong "viec can chu y" tren ban tom tat hoac bao cao mau.

## Preconditions

- Dang hien thi ban tom tat AI hop le hoac bao cao mau co danh sach viec can chu y (viec qua han, phong ngung phuc vu).

## Guarantees

- **Minimal Guarantee:** Neu khong dieu huong duoc, quan ly van o man tom tat; khong de AI tu sua du lieu.
- **Success Guarantee:** Quan ly den duoc vi tri tuong ung tren dashboard de dieu phoi.

## Main Success Scenario

1. Quan ly xem muc viec can chu y (qua han / phong ngung phuc vu) cua ky.
2. Quan ly chon mot muc.
3. He thong dua quan ly den vi tri tuong ung tren dashboard (`room-dashboard`).
4. Quan ly tiep tuc dieu phoi ngoai pham vi feature nay.

## Extensions

**1a. Danh sach rong:**
- 1a1. Khong co muc bam; ket thuc (khong loi).

**2a. Khong du quyen:**
- 2a1. E-ai-ops-summary-006.

## Related Requirements

- FR-ai-ops-summary-012
- BR-ai-ops-summary-008
- CAP-ai-ops-summary-07
