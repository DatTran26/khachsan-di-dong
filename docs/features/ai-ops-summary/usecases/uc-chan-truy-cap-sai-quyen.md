# Use Case: Chan truy cap sai quyen tom tat van hanh

> Scope: Tom tat van hanh AI · Level: sea

## Primary Actor

He thong

## Trigger

Tai khoan khong phai quan ly co gang mo man tom tat hoac tao/xem ban tom tat.

## Preconditions

- Yeu cau den may chu de truy cap chuc nang tom tat.

## Guarantees

- **Minimal Guarantee:** Khong hien noi dung tom tat; khong goi AI.
- **Success Guarantee:** May chu tu choi; nguoi dung nhan E-ai-ops-summary-006.

## Main Success Scenario

1. He thong nhan yeu cau truy cap/tao/xem tom tat.
2. He thong kiem vai tro o may chu.
3. He thong xac dinh khong phai quan ly.
4. He thong tu choi va tra thong bao "Ban khong co quyen thuc hien thao tac nay."

## Extensions

**2a. La quan ly:**
- 2a1. Cho phep tiep tuc cac UC tao/xem (khong thuoc UC nay).

## Related Requirements

- FR-ai-ops-summary-011
- BR-ai-ops-summary-001
- Phu thuoc `auth-roles`
