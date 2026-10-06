---
title: "Sprint 4 — Chất lượng và bàn giao"
status: todo
---

# Sprint 4 — Chất lượng và bàn giao (20/10–27/10)

## Mục tiêu

Ổn định MVP, nghiệm thu Web + Android, triển khai demo an toàn và bàn giao có thể tái lập.

## Backlog chi tiết

| ID | Owner | Task | Phụ thuộc | Definition of Done |
|---|---|---|---|---|
| S4-DAT-01 | Đạt | Đóng scope, triage bug blocker/critical/major/minor, daily coordination | S3 | Không mở feature mới; mỗi bug có owner/deadline |
| S4-DAT-02 | Đạt | Security review: auth/RBAC, CORS, validation, rate limit, secret, deps | All code | Không còn critical/high; report không lộ secret |
| S4-DAT-03 | Đạt | CI/CD build/test/deploy staging-prod + rollback | S1-DAT-05 | Pipeline/deploy/rollback tái lập được |
| S4-DAT-04 | Đạt | Acceptance checklist, demo script, release note, architecture/API/DB handover | S4-DAT-01 | Người khác có thể demo/vận hành theo tài liệu |
| S4-BAO-01 | Bảo | Fix backend/mobile, migration rehearsal, backup/restore, performance smoke | S4-DAT-01 | Migration/rollback logged; API không regression |
| S4-BAO-02 | Bảo | Backend suite, security/dependency check, Socket.IO load proof | S4-BAO-01 | 100 update/10 session đạt target hoặc có sign-off |
| S4-BAO-03 | Bảo | Build/sign APK demo, install test Android target | S4-BAO-01 | APK chạy với account demo; version ghi nhận |
| S4-HOANG-01 | Hoàng | Full regression Web+Android theo role/feature matrix | S4-DAT-04 | Mandatory scenario pass, evidence đính kèm |
| S4-HOANG-02 | Hoàng | Cross-browser/responsive/accessibility QA, fix UI blocker | S4-DAT-01 | Không overflow/blocker; keyboard/contrast cơ bản pass |
| S4-HOANG-03 | Hoàng | UAT rehearsal, verify fix, final visual acceptance | S4-HOANG-01..02 | 0 blocker/critical; PO ký acceptance |
| S4-ALL-01 | Cả team | E2E demo + production smoke + tag release | S4-DAT-03..04 | HTTPS web, APK, seed demo, rollback route sẵn sàng |

## Gate và phản ứng rủi ro

- 0 blocker/critical; toàn bộ kịch bản bắt buộc pass; không commit API key/password/database URL/.env.
- Sprint 2 chưa có E2E: dừng polish/AI, hoàn thành transaction vận hành + realtime trước.
- Dashboard lệch: khoá release, đối soát audit/source-of-truth.
- AI lỗi: release fallback report; không chặn vận hành.
- Deploy lỗi: rollback artefact trước và dùng checklist staging để sửa.
