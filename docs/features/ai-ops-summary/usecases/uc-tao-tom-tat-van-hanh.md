# Use Case: Tao tom tat van hanh theo ky

> Scope: Tom tat van hanh AI · Level: sea

## Primary Actor

Quan ly

## Trigger

Quan ly chon ky (ca hien tai / ca truoc / hom nay) va bam tao tom tat.

## Preconditions

- Quan ly da dang nhap va duoc kiem quyen may chu (FR-ai-ops-summary-011).
- Khong co ky tuong lai trong cac tuy chon (FR-ai-ops-summary-001).
- Dinh nghia khung "ca": `spec.md#OQ-1` (chua chot).

## Guarantees

- **Minimal Guarantee:** Neu AI loi/timeout/het han muc/dau ra sai/ky rong/mat mang — quan ly van nhan bao cao mau hoac thong bao ro; AI khong ghi/sua du lieu nghiep vu; khong luu ban loi khi mat mang.
- **Success Guarantee:** Hien ban tom tat AI hop le kem thoi diem T + nhan "tham khao", hoac bao cao mau dung nhan; moi luot tao duoc ghi nhat ky (ai/khi/ky/ket qua/co goi AI).

## Main Success Scenario

1. Quan ly chon ky hop le va bam tao.
2. He thong chot thoi diem du lieu T va khoa nut tao trong luc xu ly.
3. He thong tinh so lieu tong hop ky tai T (3 truc, ty le lap day, viec don/bao tri theo TT, viec qua han, su kien noi bat tu nhat ky) — khong dinh danh khach.
4. He thong xac nhan ky co du lieu va con han muc AI (`spec.md#OQ-2`).
5. He thong gui so lieu tong hop toi dich vu LLM (`spec.md#OQ-3`) va nhan ban tom tat cau truc: tong quan + noi bat + viec can chu y.
6. He thong kiem dau ra AI khop so lieu goc, khong bia su kien.
7. He thong hien ban AI kem "Du lieu tinh den {T}" va nhan tham khao co dinh.
8. He thong ghi nhat ky luot tao (ban giao `audit-log`).

## Extensions

**1a. Vai tro khong phai quan ly:**
- 1a1. Tu choi E-ai-ops-summary-006; ket thuc.

**1b. Da co luot dang tao:**
- 1b1. Bao E-ai-ops-summary-007; khong tao them; ket thuc Minimal.

**3a. Ky khong co du lieu:**
- 3a1. Hien bao cao mau rong E-ai-ops-summary-001; khong goi AI; ghi nhat ky; ket thuc Success (mau rong).

**4a. Het han muc:**
- 4a1. Khong goi AI; hien bao cao mau E-ai-ops-summary-003; ghi nhat ky; ket thuc Success (mau).

**5a. AI loi hoac qua thoi gian cho (`spec.md#OQ-5`):**
- 5a1. Hien bao cao mau E-ai-ops-summary-002 + nhan bao cao mau; ghi nhat ky; ket thuc Success (mau).

**6a. Dau ra AI khong hop le:**
- 6a1. Loai ban AI; hien bao cao mau; ghi nhat ky "dau ra AI khong hop le" (E-ai-ops-summary-005); ket thuc Success (mau).

**2a. Mat ket noi khi tao:**
- 2a1. Bao E-ai-ops-summary-004; khong luu ban loi; ket thuc Minimal.

## Related Requirements

- FR-ai-ops-summary-001 … 011, 014
- BR-ai-ops-summary-001 … 007
- CAP-ai-ops-summary-01 … 06
- OQ: spec.md#OQ-1, OQ-2, OQ-3, OQ-5
