# Use Case: Xem lai tom tat gan nhat

> Scope: Tom tat van hanh AI · Level: sea

## Primary Actor

Quan ly

## Trigger

Quan ly mo lai ban tom tat da tao gan nhat (neu chot luu).

## Preconditions

- Quyet dinh luu ban de xem lai: `spec.md#OQ-4` (chua chot).
- Quan ly du quyen (FR-ai-ops-summary-011).

## Guarantees

- **Minimal Guarantee:** Neu chua luu (OQ-4 = khong luu) thi khong co ban de xem lai; khong phat sinh goi AI moi khi chi xem.
- **Success Guarantee:** Khi OQ-4 chot luu, quan ly xem lai ban gan nhat kem thoi diem T + nhan dung loai, khong goi AI moi.

## Main Success Scenario

1. Quan ly mo man tom tat van hanh.
2. He thong hien ban gan nhat da tao (neu co luu theo OQ-4).
3. Quan ly doc noi dung ma khong bam tao moi.

## Extensions

**2a. OQ-4 chua chot / khong luu:**
- 2a1. Khong co ban xem lai; quan ly phai tao moi neu can.
- 2a2. UC ket thuc — khong bia hanh vi luu.

**2b. Khong du quyen:**
- 2b1. E-ai-ops-summary-006.

## Related Requirements

- FR-ai-ops-summary-013
- CAP-ai-ops-summary-08
- OQ: `spec.md#OQ-4`
