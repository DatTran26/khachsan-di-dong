---
title: "Sprint 3 — Giám sát và AI"
status: todo
---

# Sprint 3 — Giám sát và AI (06/10–19/10)

## Mục tiêu

Quản lý thấy toàn cảnh 50 phòng realtime, việc quá hạn và bản tóm tắt vận hành an toàn; hoàn thiện Web/Android theo token guideline.

## Backlog chi tiết

| ID | Owner | Task | Phụ thuộc | Definition of Done |
|---|---|---|---|---|
| S3-DAT-01 | Đạt | Chốt KPI dashboard, overdue và acceptance data set | S2 | Occupancy/mẫu số 0, composite state, expected count rõ |
| S3-DAT-02 | Đạt | Review AI privacy/cost/output policy, Responses JSON schema | S3-DAT-01 | Aggregate only, 15s timeout, cap 300k, fallback/redaction |
| S3-DAT-03 | Đạt | Review token compliance, usability và technical PR | S3-DAT-01 | Checklist design/architecture pass trước demo |
| S3-BAO-01 | Bảo | Dashboard aggregate/filter API + query index | S2, S3-DAT-01 | KPI khớp fixture; filter không sai count |
| S3-BAO-02 | Bảo | Overdue worker/rule + event/audit exposure | S2-BAO-04..07 | Task được cờ theo rule, không phụ thuộc AI |
| S3-BAO-03 | Bảo | Summary aggregate theo ca/ngày không định danh | S2-BAO-06, S3-DAT-02 | Payload không chứa tên khách/log thô; test pass |
| S3-BAO-04 | Bảo | OpenAI Responses structured output, quota/cost/timeout | S3-BAO-03 | Server-only key, single request, schema validation |
| S3-BAO-05 | Bảo | Fallback report + anti-hallucination validation + lưu latest summary | S3-BAO-04 | AI lỗi/invalid/hết quota vẫn trả report đúng dữ liệu |
| S3-BAO-06 | Bảo | Dashboard/AI tests: 20 scenario, timeout/quota/privacy | S3-BAO-01..05 | ≥18/20 scenario đúng; fallback 100% |
| S3-HOANG-01 | Hoàng | Dashboard web: KPI/grid 50 room/filter/connection state | S3-BAO-01 | Realtime, responsive, legend rõ |
| S3-HOANG-02 | Hoàng | Overdue UI + deep-link room/task/log | S3-BAO-02 | Cờ dễ thấy, điều hướng đúng ngữ cảnh |
| S3-HOANG-03 | Hoàng | AI screen: period/loading/disabled/error/fallback/reference label | S3-BAO-03..05 | Chống double click; có thời điểm T + nhãn tham khảo |
| S3-HOANG-04 | Hoàng | Responsive/accessibility/token compliance toàn app | S3-DAT-03 | Web desktop/tablet và Android pass visual QA |
| S3-HOANG-05 | Hoàng | QA dashboard/AI/realtime/reconciliation | S3-HOANG-01..04 | KPI đúng; 100 cross-client event được đo |

## Gate

- Dashboard khớp dữ liệu nguồn và realtime ≤3 giây.
- AI/fallback luôn dựa số liệu thật, không lộ dữ liệu khách hoặc secret.
