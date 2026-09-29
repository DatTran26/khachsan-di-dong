# WBS thực thi chi tiết — MVP Khách Sạn Di Động

## Cách dùng bảng này

- `Đã xong`: chỉ áp dụng cho tài liệu/cấu hình có bằng chứng hiện có.
- `Cần đối chiếu`: không tìm thấy source code trong repository tại thời điểm lập WBS; người sở hữu cần gắn link PR, commit, ảnh chạy hoặc kết quả test trước khi chuyển sang Done.
- `Kế hoạch`: chưa đến thời điểm triển khai.
- Cột `Đầu ra` là artefact bắt buộc phải có. `KT` là người kiểm tra/review trước khi Done.
- Effort là giờ làm thực tế ước lượng, không tính thời gian chờ phản hồi. Baseline nỗ lực theo Project Charter là 530h; capacity tham chiếu 3 người × 20h/tuần × 8 tuần = 480h, vì vậy 50h chênh lệch phải được theo dõi như rủi ro nguồn lực. Xem [WBS baseline và từ điển WBS](./wbs-baseline-review-and-dictionary.md) để kiểm soát phạm vi ở cấp gói công việc.

## Đường dẫn đích đề xuất

Các đường dẫn dưới đây là contract khởi tạo vì repo chưa có source. Nếu team bootstrap cấu trúc khác, Đạt cập nhật bảng mapping một lần trước khi Bảo/Hoàng làm task phụ thuộc.

| Khu vực | Đường dẫn đích |
|---|---|
| Backend | `apps/api/` |
| Prisma/database | `apps/api/prisma/` |
| Backend tests | `apps/api/src/**/*.spec.ts` |
| Flutter shared/Web/Android | `apps/mobile/` |
| Flutter test | `apps/mobile/test/`, `apps/mobile/integration_test/` |
| API contract | `docs/api/` |
| Design tokens | `docs/design-tokens.md`, sau đó `apps/mobile/lib/core/theme/` |
| Deploy/CI | `.github/workflows/`, `infra/`, `docs/runbooks/` |

## Sprint 1 — 08/09–21/09: Nền tảng

### Business Analysis và làm việc với khách hàng (08/09–12/09, thuộc Sprint 1)

Các task này là workstream bắt buộc trước và song song với khởi tạo kỹ thuật. Nếu dự án dùng khách sạn giả lập, “khách hàng” là giảng viên/đại diện người dùng giả định; vẫn cần lưu quyết định như một cuộc phỏng vấn thật.

| ID | Owner | Task name | Đầu ra/bằng chứng | Effort | KT | Status |
|---|---|---|---|---:|---|---|
| S1-DAT-017 | Đạt | Xác định sponsor, người quyết định và stakeholder của khách hàng | Stakeholder map: quản lý, lễ tân, buồng phòng, bảo trì, giảng viên | 1h | Team | Cần đối chiếu |
| S1-DAT-018 | Đạt | Lập lịch kickoff và phỏng vấn theo từng vai trò | Interview plan có người tham gia, mục tiêu, thời lượng | 1h | Khách hàng | Cần đối chiếu |
| S1-DAT-019 | Đạt | Chuẩn bị bộ câu hỏi phỏng vấn quản lý khách sạn | Questionnaire về KPI, dashboard, quyền, báo cáo, escalation | 2h | Hoàng | Cần đối chiếu |
| S1-DAT-020 | Đạt | Chuẩn bị bộ câu hỏi phỏng vấn lễ tân | Questionnaire check-in/out, điều kiện phòng sẵn sàng, lỗi thường gặp | 2h | Hoàng | Cần đối chiếu |
| S1-DAT-021 | Đạt | Chuẩn bị bộ câu hỏi phỏng vấn nhân viên buồng phòng | Questionnaire giao việc, thời gian dọn, thao tác mobile, quá hạn | 2h | Hoàng | Cần đối chiếu |
| S1-DAT-022 | Đạt | Chuẩn bị bộ câu hỏi phỏng vấn nhân viên bảo trì | Questionnaire báo hỏng, mức độ ảnh hưởng, xử lý, mở lại phòng | 2h | Hoàng | Cần đối chiếu |
| S1-DAT-023 | Đạt | Thực hiện kickoff, ghi mục tiêu và tiêu chí thành công | Biên bản kickoff có scope, deadline 27/10, người duyệt | 2h | Khách hàng | Cần đối chiếu |
| S1-DAT-024 | Đạt | Phỏng vấn quản lý về dashboard và điều phối ca | Interview notes + pain point + decision/OQ | 2h | Khách hàng | Cần đối chiếu |
| S1-DAT-025 | Đạt | Phỏng vấn lễ tân về check-in/check-out và tra cứu phòng | Interview notes + process exceptions | 2h | Khách hàng | Cần đối chiếu |
| S1-DAT-026 | Đạt | Phỏng vấn nhân viên buồng về nhận/hoàn tất việc | Interview notes + thao tác tối đa chấp nhận được | 2h | Khách hàng | Cần đối chiếu |
| S1-DAT-027 | Đạt | Phỏng vấn nhân viên bảo trì về báo hỏng và đóng việc | Interview notes + điều kiện ngừng/mở lại phòng | 2h | Khách hàng | Cần đối chiếu |
| S1-DAT-028 | Đạt | Quan sát hoặc mô phỏng quy trình AS-IS của một ca làm việc | AS-IS flow + điểm nghẽn + dữ liệu đầu vào/đầu ra | 3h | Khách hàng | Cần đối chiếu |
| S1-DAT-029 | Đạt | Lập problem statement và opportunity backlog | Danh sách pain point được liên kết với feature | 2h | Team | Cần đối chiếu |
| S1-DAT-030 | Đạt | Chuẩn hóa glossary nghiệp vụ và định nghĩa 3 trục trạng thái | Glossary được khách hàng xác nhận | 2h | Khách hàng | Cần đối chiếu |
| S1-DAT-031 | Đạt | Elicit functional requirement và business rule theo feature | Requirement matrix trace tới SRS/use case | 4h | Bảo, Hoàng | Cần đối chiếu |
| S1-DAT-032 | Đạt | Elicit non-functional requirement, bảo mật và dữ liệu giả lập | NFR matrix: performance/realtime/privacy/availability | 2h | Bảo | Cần đối chiếu |
| S1-DAT-033 | Đạt | Phân loại MoSCoW và chốt non-goal MVP với khách hàng | Scope baseline được phê duyệt | 2h | Khách hàng | Cần đối chiếu |
| S1-DAT-034 | Đạt | Tạo Open Question/assumption/decision log | OQ register: owner, due date, tác động nếu chưa chốt | 2h | Team | Cần đối chiếu |
| S1-DAT-035 | Đạt | Tổ chức workshop validate TO-BE process và exception flow | Workshop minutes; change requests/decision được ghi | 3h | Khách hàng | Cần đối chiếu |
| S1-DAT-036 | Đạt | Thu thập xác nhận requirement baseline/sign-off | Email/biên bản/approval giả lập có ngày và người duyệt | 1h | Khách hàng | Cần đối chiếu |
| S1-HOANG-016 | Hoàng | Nghiên cứu bối cảnh sử dụng Web tại quầy và Android tại hiện trường | Context-of-use note: thiết bị, mạng, ánh sáng, thao tác tay | 2h | Đạt | Cần đối chiếu |
| S1-HOANG-017 | Hoàng | Tạo persona và journey map từ phỏng vấn | Persona/journey có pain point/opportunity/acceptance | 3h | Đạt | Cần đối chiếu |
| S1-HOANG-018 | Hoàng | Chạy usability review wireframe với người dùng đại diện | Feedback log: issue, severity, quyết định sửa/giữ | 3h | Khách hàng | Cần đối chiếu |
| S1-HOANG-019 | Hoàng | Xác nhận design token có đủ trạng thái nghiệp vụ và accessibility | Token gap list + quyết định bổ sung | 2h | Đạt | Cần đối chiếu |
| S1-HOANG-020 | Hoàng | Ghi yêu cầu responsive và touch target từ khách hàng | UI acceptance checklist Web/Android | 2h | Đạt | Cần đối chiếu |
| S1-BAO-021 | Bảo | Feasibility review cho realtime, DB transaction và thiết bị Android | Feasibility risks/mitigation/PO decision | 2h | Đạt | Cần đối chiếu |
| S1-BAO-022 | Bảo | Xác nhận dữ liệu tối thiểu cần lưu và không được lưu | Data classification/retention note | 2h | Đạt | Cần đối chiếu |
| S1-BAO-023 | Bảo | Review API/third-party assumptions với khách hàng | Integration assumptions, cost limit và fallback decision | 2h | Đạt | Cần đối chiếu |

### Hạng mục Đạt đã thực hiện

| ID | Owner | Công việc chi tiết | Đầu ra/bằng chứng | Effort | KT | Status |
|---|---|---|---|---:|---|---|
| S1-DAT-001 | Đạt | Thu thập phạm vi, persona, non-goal và tiêu chí nghiệm thu | `docs/_product/prd.md` | 10h | Team | Đã xong |
| S1-DAT-002 | Đạt | Phân rã 9 feature thành BRD/PRD/URD/SRS | `docs/features/*` | 32h | Team | Đã xong |
| S1-DAT-003 | Đạt | Viết ERD, state machine, flow, use case, user story và wireframe | `docs/features/**/srs`, `usecases`, `userstories`, `ascii-wireframe` | 36h | Team | Đã xong |
| S1-DAT-004 | Đạt | Chốt MVP: 3 role, 3 trục trạng thái, dữ liệu giả lập 50 phòng | `docs/_shared/project-profile.md` | 4h | Team | Đã xong |
| S1-DAT-005 | Đạt | Thiết lập Gitflow, nhánh thành viên, security, contribution rule | `AGENTS.md`, `.github/`, `SECURITY.md` | 4h | Team | Đã xong |
| S1-DAT-006 | Đạt | Thiết kế Design Token guideline | Artefact hiện chưa tracked; cần chuyển sang `docs/design-tokens.md` | 8h | Hoàng | Đã xong, cần publish |

### Nền kiến trúc và vận hành

| ID | Owner | Công việc chi tiết | Bước thực hiện | Đầu ra/bằng chứng | Effort | Phụ thuộc | KT | Status |
|---|---|---|---|---|---:|---|---|---|
| S1-DAT-007 | Đạt | Chốt cấu trúc source | Chọn single repo `apps/api` + `apps/mobile`; viết mapping module | `docs/architecture.md` và tree source | 2h | S1-DAT-001 | Bảo, Hoàng | Cần đối chiếu |
| S1-DAT-008 | Đạt | Chốt API error contract | Quy ước HTTP code, body lỗi, validation field error, conflict error | `docs/api/error-contract.md` | 2h | S1-DAT-007 | Bảo | Cần đối chiếu |
| S1-DAT-009 | Đạt | Chốt enum dùng chung | Role, occupancy, cleaning, maintenance, task status, audit action | `docs/api/domain-enums.md` | 2h | S1-DAT-002 | Bảo, Hoàng | Cần đối chiếu |
| S1-DAT-010 | Đạt | Chốt auth/session policy | Token/session lifetime, logout, password hash, rate limit login | `docs/security/auth-policy.md` | 2h | S1-DAT-001 | Bảo | Cần đối chiếu |
| S1-DAT-011 | Đạt | Tạo Definition of Done/PR checklist | Require lint/test/review/migration/secret check | `.github/pull_request_template.md` | 1h | S1-DAT-005 | Team | Cần đối chiếu |
| S1-DAT-012 | Đạt | Tạo môi trường dev/staging | Xác định DB, hosting, domain, env ownership và health check | `docs/runbooks/environment.md` | 3h | S1-DAT-007 | Bảo | Cần đối chiếu |
| S1-DAT-013 | Đạt | Publish token guideline | Chuẩn hóa color, typography, spacing, radius, elevation, component state, breakpoint | `docs/design-tokens.md` | 2h | S1-DAT-006 | Hoàng | Kế hoạch |

### Backend và database — Bảo

| ID | Công việc chi tiết | Bước thực hiện | Đầu ra/bằng chứng | Effort | Phụ thuộc | KT | Status |
|---|---|---|---|---:|---|---|---|
| S1-BAO-001 | Bootstrap API | Tạo Express TS, scripts dev/build/lint/test, cấu hình strict TS | `apps/api/package.json`, `src/main.ts`; build pass | 3h | S1-DAT-007 | Đạt | Cần đối chiếu |
| S1-BAO-002 | Env validation | Khai báo schema env, fail-fast khi thiếu biến, `.env.example` không có secret | `src/config/env.ts`, `.env.example` | 2h | S1-BAO-001 | Đạt | Cần đối chiếu |
| S1-BAO-003 | Health/readiness endpoint | Tạo `/health` và `/ready`; ready kiểm tra DB | test endpoint + curl result | 2h | S1-BAO-001 | Đạt | Cần đối chiếu |
| S1-BAO-004 | Prisma baseline | Setup Prisma client, naming convention, migration workflow | `prisma/schema.prisma` | 2h | S1-DAT-009 | Đạt | Cần đối chiếu |
| S1-BAO-005 | User/role schema | Model User/Role; unique phone; active flag; password hash field | migration + schema review | 2h | S1-BAO-004 | Đạt | Cần đối chiếu |
| S1-BAO-006 | Room schema | Model RoomType/Room; room number unique; floor; 3 state enum; version | migration + constraint test | 3h | S1-BAO-004 | Đạt | Cần đối chiếu |
| S1-BAO-007 | Seed data | Seed idempotent 3 role, demo users, 50 rooms và type | `prisma/seed.ts`; rerun succeeds | 3h | S1-BAO-005,006 | Hoàng | Cần đối chiếu |
| S1-BAO-008 | Password service | Bcrypt/Argon2; never return hash; password policy | unit tests | 2h | S1-BAO-005 | Đạt | Cần đối chiếu |
| S1-BAO-009 | Login endpoint | Validate credentials, inactive user, generic invalid response, token issue | `POST /auth/login` tests | 3h | S1-BAO-008 | Hoàng | Cần đối chiếu |
| S1-BAO-010 | Auth middleware | Parse/verify token, attach actor, reject expired token | protected-route tests | 2h | S1-BAO-009 | Đạt | Cần đối chiếu |
| S1-BAO-011 | RBAC guard | Permission matrix: manager/receptionist/staff; deny by default | role matrix tests | 3h | S1-BAO-010 | Đạt | Cần đối chiếu |
| S1-BAO-012 | Room read APIs | List/detail/filter floor/state/type, paging contract | API tests + `docs/api/rooms.md` | 3h | S1-BAO-006,011 | Hoàng | Cần đối chiếu |
| S1-BAO-013 | Room write APIs | Manager create/update/deactivate; request validation; version conflict | create/update/conflict tests | 4h | S1-BAO-012 | Đạt | Cần đối chiếu |
| S1-BAO-014 | Socket foundation | Socket auth, connection event, room update event name/payload | two-client manual proof | 4h | S1-BAO-010,013 | Hoàng | Cần đối chiếu |
| S1-BAO-015 | Backend quality gate | Unit/integration tests, lint, coverage report, review fixes | CI command output | 4h | S1-BAO-001..014 | Đạt | Cần đối chiếu |

### Flutter/UI/QA — Hoàng

| ID | Công việc chi tiết | Bước thực hiện | Đầu ra/bằng chứng | Effort | Phụ thuộc | KT | Status |
|---|---|---|---|---:|---|---|---|
| S1-HOANG-001 | Bootstrap Flutter | Flutter project, flavors/env, analyzer/test/build Web+APK debug | `apps/mobile/pubspec.yaml`; build output | 3h | S1-DAT-007 | Đạt | Cần đối chiếu |
| S1-HOANG-002 | App shell/routing | Auth guard, role route guard, loading/error/not-found shell | widget tests | 3h | S1-HOANG-001 | Đạt | Cần đối chiếu |
| S1-HOANG-003 | Token implementation | ThemeData, semantic colors, typography/spacing/state primitives | `lib/core/theme/`; token review | 4h | S1-DAT-013 | Đạt | Cần đối chiếu |
| S1-HOANG-004 | Network client | API base URL, auth header, typed error mapping, timeout | client unit tests | 3h | S1-BAO-009 | Bảo | Cần đối chiếu |
| S1-HOANG-005 | Login UI | Phone/password, form validation, loading, invalid-credential, logout | widget/golden/manual evidence | 4h | S1-HOANG-004 | Bảo | Cần đối chiếu |
| S1-HOANG-006 | Session persistence | Secure store, restore session, expiry/logout path | restart test | 2h | S1-HOANG-005 | Đạt | Cần đối chiếu |
| S1-HOANG-007 | Room catalog list | Search/filter/paging/loading/empty/error UI | screen capture + widget test | 4h | S1-BAO-012 | Bảo | Cần đối chiếu |
| S1-HOANG-008 | Room detail/form | Manager create/edit validation, role-hide write controls | integration test | 4h | S1-BAO-013 | Đạt | Cần đối chiếu |
| S1-HOANG-009 | Realtime client | Socket lifecycle, subscription, update local state | two-browser/client evidence | 3h | S1-BAO-014 | Bảo | Cần đối chiếu |
| S1-HOANG-010 | Offline UI | Connection banner; disable all write controls; reconnect refresh | manual offline scenario | 2h | S1-HOANG-009 | Đạt | Cần đối chiếu |
| S1-HOANG-011 | S1 QA matrix | 3 role auth/RBAC, catalog, two client realtime, responsive | `docs/qa/sprint-1.md` | 4h | S1-HOANG-005..010 | Đạt | Cần đối chiếu |

### Sprint 1 exit criteria

1. Có source repo và build command lặp lại được; manager đăng nhập, tạo/sửa phòng, seed có 50 phòng.
2. Receptionist/staff không gọi được manager write API, kể cả sửa request client.
3. Hai client đã đăng nhập nhận room update sau commit trong mục tiêu ≤3 giây.
4. Nếu bất kỳ điều nào chưa có evidence, Sprint 1 không được đánh Done; ticket tương ứng chuyển sang Sprint 2 carry-over.

## Sprint 2 — 22/09–05/10: Vận hành lõi

### Product/architecture/coordination — Đạt

| ID | Công việc chi tiết | Đầu ra/bằng chứng | Effort | Phụ thuộc | KT | Status |
|---|---|---|---:|---|---|---|
| S2-DAT-001 | Chốt thông tin khách tối thiểu: tên, số người, giấy tờ giả lập hay chỉ tên | Cập nhật canonical check-in SRS | 1h | S1 exit | Bảo, Hoàng | Kế hoạch |
| S2-DAT-002 | Chốt overdue housekeeping/maintenance: 60 phút hay theo loại; tần suất quét/cảnh báo | SRS + acceptance test | 1h | S1 exit | Bảo | Kế hoạch |
| S2-DAT-003 | Chốt danh sách nhân viên trực và tie-break auto-assign | SRS + API contract | 1h | S1 exit | Bảo | Kế hoạch |
| S2-DAT-004 | Chốt reconnect threshold, conflict UX và refresh scope | SRS realtime | 1h | S1 exit | Hoàng | Kế hoạch |
| S2-DAT-005 | Review aggregate state machine/transaction boundary | State transition matrix ký duyệt | 3h | S2-DAT-001..004 | Bảo | Kế hoạch |
| S2-DAT-006 | Viết E2E acceptance scenario 01–10 | `docs/qa/e2e-sprint-2.md` | 3h | S2-DAT-005 | Team | Kế hoạch |
| S2-DAT-007 | API and event contract review | `docs/api/operations.md` | 3h | S2-DAT-005 | Team | Kế hoạch |

### Backend/mobile — Bảo

| ID | Công việc chi tiết | Đầu ra/bằng chứng | Effort | Phụ thuộc | KT | Status |
|---|---|---|---:|---|---|---|
| S2-BAO-001 | Migration Stay và guest snapshot tối thiểu | migration + rollback test | 3h | S2-DAT-001 | Đạt | Kế hoạch |
| S2-BAO-002 | Migration HousekeepingTask | state, assignee, dueAt, version, room relation | 3h | S2-DAT-002,003 | Đạt | Kế hoạch |
| S2-BAO-003 | Migration MaintenanceTask | status, reporter, assignee, dueAt, description | 3h | S2-DAT-002 | Đạt | Kế hoạch |
| S2-BAO-004 | Migration AuditLog/indexes | actor/action/entity/before/after/timestamp | 3h | S1 auth | Đạt | Kế hoạch |
| S2-BAO-005 | Check-in eligibility service | single source of truth condition + reason codes | 3h | S2-BAO-001 | Đạt | Kế hoạch |
| S2-BAO-006 | Check-in command/API | transaction stay/create state/audit/emit | 4h | S2-BAO-005 | Hoàng | Kế hoạch |
| S2-BAO-007 | Check-out command/API | close stay + dirty + create cleaning task atomically | 4h | S2-BAO-006,002 | Đạt | Kế hoạch |
| S2-BAO-008 | Auto-assign service | on-duty least-open-task, deterministic tie-break | 3h | S2-BAO-002,003 | Đạt | Kế hoạch |
| S2-BAO-009 | Housekeeping commands | accept/reject/start/complete/manager confirm | 5h | S2-BAO-008 | Hoàng | Kế hoạch |
| S2-BAO-010 | Maintenance report command | create task, mark room OOS, audit/emit | 4h | S2-BAO-003 | Hoàng | Kế hoạch |
| S2-BAO-011 | Maintenance commands | claim/start/complete/reopen with guards | 4h | S2-BAO-010 | Đạt | Kế hoạch |
| S2-BAO-012 | Audit service | reusable transaction-aware writer and read API | 4h | S2-BAO-004 | Hoàng | Kế hoạch |
| S2-BAO-013 | Realtime event integration | emit only after commit; version conflict payload | 3h | S2-BAO-006..012 | Hoàng | Kế hoạch |
| S2-BAO-014 | Operation test suite | RBAC, idempotency, rollback, concurrent check-in, state tests | 8h | S2-BAO-001..013 | Đạt | Kế hoạch |

### UI/mobile/QA — Hoàng

| ID | Công việc chi tiết | Đầu ra/bằng chứng | Effort | Phụ thuộc | KT | Status |
|---|---|---|---:|---|---|---|
| S2-HOANG-001 | Check-in screen | ready room picker, guest form, eligibility/error UI | 5h | S2-BAO-006 | Bảo | Kế hoạch |
| S2-HOANG-002 | Check-out screen | confirmation, completion state, task-created feedback | 4h | S2-BAO-007 | Bảo | Kế hoạch |
| S2-HOANG-003 | My cleaning tasks mobile | assigned list, priority/due/empty/loading state | 4h | S2-BAO-009 | Bảo | Kế hoạch |
| S2-HOANG-004 | Cleaning task action UI | accept/reject/complete, confirmation and error state | 4h | S2-BAO-009 | Đạt | Kế hoạch |
| S2-HOANG-005 | Manager cleaning confirmation | queue, room detail, confirm/reject/feedback | 3h | S2-BAO-009 | Bảo | Kế hoạch |
| S2-HOANG-006 | Report maintenance UI | select room, description validation, submit feedback | 3h | S2-BAO-010 | Bảo | Kế hoạch |
| S2-HOANG-007 | Maintenance task mobile UI | claim/start/complete/reopen display | 4h | S2-BAO-011 | Bảo | Kế hoạch |
| S2-HOANG-008 | Audit log web UI | filters, paging, room drill-down, before→after display | 4h | S2-BAO-012 | Đạt | Kế hoạch |
| S2-HOANG-009 | Conflict/reconnect UX | stale warning, refresh, retry safe interaction | 3h | S2-BAO-013 | Đạt | Kế hoạch |
| S2-HOANG-010 | E2E and visual QA | Run scenario 01–10 in Web + Android, log defects | 6h | S2-HOANG-001..009 | Đạt | Kế hoạch |

### Sprint 2 exit criteria

1. One room completes check-in → check-out → cleaning → manager confirmation → check-in again.
2. Report maintenance makes room unavailable; reopened room can pass check-in eligibility.
3. All writes create audit log and realtime event after transaction commit.

## Sprint 3 — 06/10–19/10: Dashboard, QA UI và AI

### Product/architecture — Đạt

| ID | Công việc chi tiết | Đầu ra/bằng chứng | Effort | Phụ thuộc | KT | Status |
|---|---|---|---:|---|---|---|
| S3-DAT-001 | Chốt công thức KPI/cách xử lý mẫu số 0 và room composite label | Dashboard SRS canonical update | 2h | Sprint 2 exit | Bảo, Hoàng | Kế hoạch |
| S3-DAT-002 | Chốt test fixture dashboard 50 phòng và expected counters | `docs/qa/dashboard-fixture.md` | 2h | S3-DAT-001 | Bảo | Kế hoạch |
| S3-DAT-003 | Chốt provider/timeout 15s/cost cap 300k/schema summary | AI integration ADR | 2h | S3-DAT-001 | Bảo | Kế hoạch |
| S3-DAT-004 | Define AI red-team 20 scenario và fallback acceptance | `docs/qa/ai-evaluation.md` | 3h | S3-DAT-003 | Hoàng | Kế hoạch |
| S3-DAT-005 | Review UX token/accessibility/technical PR | Signed checklist | 4h | S3 UI work | Hoàng, Bảo | Kế hoạch |

### Backend — Bảo

| ID | Công việc chi tiết | Đầu ra/bằng chứng | Effort | Phụ thuộc | KT | Status |
|---|---|---|---:|---|---|---|
| S3-BAO-001 | Dashboard aggregate query | state counts, occupancy, overdue count, OOS, filters | API tests matching fixture | 5h | S3-DAT-001,002 | Đạt | Kế hoạch |
| S3-BAO-002 | Query/index profiling | add only needed indexes, inspect query plan | explain evidence | 2h | S3-BAO-001 | Đạt | Kế hoạch |
| S3-BAO-003 | Overdue rule/job | periodic evaluation idempotent, audit/event | unit/integration tests | 4h | S2 tasks, S3-DAT-001 | Đạt | Kế hoạch |
| S3-BAO-004 | Summary aggregate builder | per shift/day, no PII, deterministic fact list | privacy/unit tests | 4h | S2 audit, S3-DAT-003 | Đạt | Kế hoạch |
| S3-BAO-005 | OpenAI adapter | Responses API, server-only key, structured response parser | mock contract tests | 4h | S3-BAO-004 | Đạt | Kế hoạch |
| S3-BAO-006 | Quota/cost/timeout control | single-flight, usage recording, 15s abort, 300k cap | unit tests | 3h | S3-BAO-005 | Đạt | Kế hoạch |
| S3-BAO-007 | Output validator/fallback | reject wrong numbers/events, construct deterministic report | invalid-AI tests | 4h | S3-BAO-005,006 | Hoàng | Kế hoạch |
| S3-BAO-008 | Persist/view latest summary | latest record per period, audit generation attempt | API integration test | 3h | S3-BAO-007 | Hoàng | Kế hoạch |
| S3-BAO-009 | AI quality/security tests | execute 20 cases, timeout/quota/privacy test | result sheet + tests | 6h | S3-BAO-001..008 | Đạt | Kế hoạch |

### UI/QA — Hoàng

| ID | Công việc chi tiết | Đầu ra/bằng chứng | Effort | Phụ thuộc | KT | Status |
|---|---|---|---:|---|---|---|
| S3-HOANG-001 | Dashboard layout | KPI header, 50-room grid, semantic legend | visual QA evidence | 5h | S3-BAO-001 | Đạt | Kế hoạch |
| S3-HOANG-002 | Dashboard filters/details | floor/state filters, room detail, empty/error/loading | widget/integration test | 4h | S3-BAO-001 | Bảo | Kế hoạch |
| S3-HOANG-003 | Realtime dashboard refresh | update only affected grid/KPI, connection state | two-client evidence | 3h | S3-BAO-001,003 | Bảo | Kế hoạch |
| S3-HOANG-004 | Overdue presentation | visible priority label/count/deep-link task/log | visual/accessibility test | 3h | S3-BAO-003 | Đạt | Kế hoạch |
| S3-HOANG-005 | AI summary screen | period chooser, generate disabled/loading, result sections | widget test | 4h | S3-BAO-008 | Bảo | Kế hoạch |
| S3-HOANG-006 | AI error/fallback states | timeout/quota/invalid/no-data labels and retry behavior | integration test | 3h | S3-BAO-007 | Đạt | Kế hoạch |
| S3-HOANG-007 | Cross-device polish | desktop/tablet/mobile responsive, touch targets, contrast | QA checklist | 5h | S3-HOANG-001..006 | Đạt | Kế hoạch |
| S3-HOANG-008 | Reconciliation and AI QA | 50-room fixture, 100 realtime updates, 20 AI cases | `docs/qa/sprint-3.md` | 7h | S3-HOANG-001..007 | Đạt | Kế hoạch |

### Sprint 3 exit criteria

1. Dashboard counters match the fixed fixture and live source data; 100 update test evidence exists.
2. AI sends no PII, respects 15 seconds/300k cap and shows deterministic fallback for every failure.
3. 18/20 AI quality scenarios pass; the two failures, if any, must safely fall back without invented facts.

## Sprint 4 — 20/10–27/10: Release và bàn giao

### Release management/security/DevOps — Đạt

| ID | Công việc chi tiết | Đầu ra/bằng chứng | Effort | Phụ thuộc | KT | Status |
|---|---|---|---:|---|---|---|
| S4-DAT-001 | Freeze scope và triage board | bug severity, owner, SLA, daily note | 2h | Sprint 3 exit | Team | Kế hoạch |
| S4-DAT-002 | Security review | RBAC bypass, validation, CORS, rate limit, secret scan, dependency scan | security checklist | 5h | All code | Bảo | Kế hoạch |
| S4-DAT-003 | CI workflow | install/lint/test/build backend + Flutter on PR | workflow run link | 4h | S1 source | Bảo, Hoàng | Kế hoạch |
| S4-DAT-004 | Deploy/rollback runbook | env variables by name, migration order, smoke/rollback steps | `docs/runbooks/deploy.md` | 4h | S4-DAT-003 | Bảo | Kế hoạch |
| S4-DAT-005 | Acceptance script | role accounts, demo data reset, scenario order, expected result | `docs/qa/acceptance.md` | 3h | All features | Hoàng | Kế hoạch |
| S4-DAT-006 | Handover pack | architecture, ERD/API, setup, known limits, release note | `docs/` handover checklist | 5h | S4-DAT-004,005 | Team | Kế hoạch |

### Backend/mobile hardening — Bảo

| ID | Công việc chi tiết | Đầu ra/bằng chứng | Effort | Phụ thuộc | KT | Status |
|---|---|---|---:|---|---|---|
| S4-BAO-001 | Fix blocker/critical backend defects | linked issue/PR and regression test per fix | 8h | S4-DAT-001 | Đạt | Kế hoạch |
| S4-BAO-002 | Migration rehearsal | backup, migrate, seed/reset, rollback on staging copy | rehearsal log | 4h | S4-DAT-004 | Đạt | Kế hoạch |
| S4-BAO-003 | Backend test and load proof | full suite + 100 updates/10 sessions measurement | CI report | 5h | S4-BAO-001 | Đạt | Kế hoạch |
| S4-BAO-004 | API smoke after deploy | health, auth, key operation, socket reconnect | smoke result | 2h | S4-DAT-004 | Đạt | Kế hoạch |
| S4-BAO-005 | Android release artifact | version, release build/signing path, install test | APK + install evidence | 4h | S4-BAO-001 | Hoàng | Kế hoạch |

### Frontend QA/UAT — Hoàng

| ID | Công việc chi tiết | Đầu ra/bằng chứng | Effort | Phụ thuộc | KT | Status |
|---|---|---|---:|---|---|---|
| S4-HOANG-001 | Full role regression | manager/receptionist/staff, every mandatory flow on Web/Android | pass/fail matrix | 8h | S4-DAT-005 | Đạt | Kế hoạch |
| S4-HOANG-002 | Responsive/browser QA | Chrome/Edge, desktop/tablet widths, Android target | defect list/evidence | 4h | S4-HOANG-001 | Đạt | Kế hoạch |
| S4-HOANG-003 | Accessibility quick pass | focus, keyboard web, labels, contrast/touch target | checklist | 3h | S4-HOANG-002 | Đạt | Kế hoạch |
| S4-HOANG-004 | Visual regression/design token audit | compare screen states with guideline, remove inconsistent hard codes | review log | 3h | S4-HOANG-003 | Đạt | Kế hoạch |
| S4-HOANG-005 | UAT rehearsal | run acceptance script, file defects, verify fixes | signed UAT evidence | 6h | S4-HOANG-001..004 | Đạt, Bảo | Kế hoạch |

### Sprint 4 exit criteria

1. Không còn bug blocker/critical; tất cả mandatory acceptance scenarios pass.
2. Web HTTPS và APK Android đều chạy bằng dữ liệu demo có thể reset.
3. Có deploy/rollback runbook, CI xanh, handover pack và release tag.

## 42 hoạt động tách nhỏ để triển khai trên Microsoft Project

Những activity dưới đây tách từ các task tổng ở trên, không mở rộng phạm vi MVP. Cùng workstream Business Analysis phía trên, WBS hiện có **178 task leaf**.

| ID | Owner | Task name | Parent task | Đầu ra/tiêu chí hoàn thành | Effort | Status |
|---|---|---|---|---|---:|---|
| S1-DAT-014 | Đạt | Tạo ADR quyết định monorepo và trách nhiệm module | S1-DAT-007 | ADR có rationale, owner và link source root | 1h | Cần đối chiếu |
| S1-DAT-015 | Đạt | Tạo ma trận quyền theo vai trò cho API | S1-DAT-010 | Bảng role × action dùng được cho test RBAC | 1h | Cần đối chiếu |
| S1-DAT-016 | Đạt | Tạo checklist review migration và rollback | S1-DAT-011 | PR checklist yêu cầu backup/rollback/test migration | 1h | Cần đối chiếu |
| S1-BAO-016 | Bảo | Thêm request validation middleware | S1-BAO-001 | Payload sai nhận 400 field-level error thống nhất | 2h | Cần đối chiếu |
| S1-BAO-017 | Bảo | Thêm global exception handler và correlation ID | S1-BAO-001 | Lỗi không lộ stack/secret; log có request ID | 2h | Cần đối chiếu |
| S1-BAO-018 | Bảo | Thêm test kết nối database và transaction helper | S1-BAO-004 | Test DB chạy độc lập và rollback test pass | 2h | Cần đối chiếu |
| S1-BAO-019 | Bảo | Thêm login rate limit và audit sự kiện login | S1-BAO-009 | Brute-force cơ bản bị chặn, event có actor/result | 2h | Cần đối chiếu |
| S1-BAO-020 | Bảo | Xuất OpenAPI tối thiểu cho auth và room catalog | S1-BAO-012 | Contract import được vào Postman/Swagger | 2h | Cần đối chiếu |
| S1-HOANG-012 | Hoàng | Tạo bộ component form tái sử dụng | S1-HOANG-003 | Text field/button/error/loading dùng token | 2h | Cần đối chiếu |
| S1-HOANG-013 | Hoàng | Tạo component room status badge | S1-HOANG-003 | 3 trục trạng thái có semantic color/label | 1h | Cần đối chiếu |
| S1-HOANG-014 | Hoàng | Thiết lập test widget cho auth guard và form validation | S1-HOANG-005 | Test pass trên CI/local | 2h | Cần đối chiếu |
| S1-HOANG-015 | Hoàng | Thực hiện smoke test build Web và Android debug | S1-HOANG-011 | Build artifact/capture kết quả | 1h | Cần đối chiếu |
| S2-DAT-008 | Đạt | Xác nhận quyền tạo báo hỏng cho từng vai trò | S2-DAT-003 | Permission matrix và SRS thống nhất | 1h | Kế hoạch |
| S2-DAT-009 | Đạt | Viết acceptance criteria cho room bị ngừng phục vụ | S2-DAT-006 | Kịch bản check-in bị chặn có expected message | 1h | Kế hoạch |
| S2-DAT-010 | Đạt | Review thông điệp lỗi tiếng Việt cho luồng nghiệp vụ | S2-DAT-007 | Error catalogue có UI copy đã duyệt | 1h | Kế hoạch |
| S2-BAO-015 | Bảo | Thêm idempotency guard cho lệnh check-out | S2-BAO-007 | Gửi lại request không tạo task dọn thứ hai | 2h | Kế hoạch |
| S2-BAO-016 | Bảo | Thêm optimistic-lock test cho room và task | S2-BAO-013 | Version cũ trả conflict nhất quán | 2h | Kế hoạch |
| S2-BAO-017 | Bảo | Thêm audit before/after serializer an toàn | S2-BAO-012 | Không ghi password/token/PII không cần thiết | 2h | Kế hoạch |
| S2-BAO-018 | Bảo | Thêm API danh sách task theo assignee và trạng thái | S2-BAO-009 | Paging/filter/sort được test | 2h | Kế hoạch |
| S2-BAO-019 | Bảo | Viết OpenAPI cho check-in/out và task command | S2-BAO-014 | Hoàng tích hợp không cần suy đoán payload | 2h | Kế hoạch |
| S2-HOANG-011 | Hoàng | Tạo component command confirmation dùng chung | S2-HOANG-001 | Confirm/cancel/loading/error nhất quán | 2h | Kế hoạch |
| S2-HOANG-012 | Hoàng | Tạo task status timeline dùng chung | S2-HOANG-003 | Cleaning/maintenance hiển thị state timeline | 2h | Kế hoạch |
| S2-HOANG-013 | Hoàng | Kiểm thử thao tác mobile khi mạng chập chờn | S2-HOANG-009 | Không gửi write trùng, user thấy hướng dẫn retry | 2h | Kế hoạch |
| S2-HOANG-014 | Hoàng | Ghi defect log và retest cho 10 scenario E2E | S2-HOANG-010 | Mỗi lỗi có reproduction/owner/retest result | 2h | Kế hoạch |
| S3-DAT-006 | Đạt | Duyệt copy nhãn AI và fallback để tránh hiểu là quyết định tự động | S3-DAT-003 | Nhãn tham khảo/fallback được chấp thuận | 1h | Kế hoạch |
| S3-DAT-007 | Đạt | Review dữ liệu aggregate trước khi gửi OpenAI | S3-DAT-004 | Data contract chứng minh không có PII | 1h | Kế hoạch |
| S3-BAO-010 | Bảo | Thêm cache/invalidation an toàn cho dashboard aggregate | S3-BAO-002 | Không hiển thị count cũ sau event; có test | 2h | Kế hoạch |
| S3-BAO-011 | Bảo | Thêm request ID và audit cho lượt tạo summary | S3-BAO-008 | Truy được ai tạo/kỳ nào/kết quả gì | 2h | Kế hoạch |
| S3-BAO-012 | Bảo | Thêm schema version cho AI summary payload/output | S3-BAO-005 | Thay đổi schema được kiểm tra tương thích | 2h | Kế hoạch |
| S3-BAO-013 | Bảo | Đo latency API dashboard và summary | S3-BAO-009 | Có baseline p50/p95 trong QA report | 2h | Kế hoạch |
| S3-HOANG-009 | Hoàng | Tạo dashboard skeleton/loading/error states | S3-HOANG-001 | Không nhấp nháy; error có retry | 2h | Kế hoạch |
| S3-HOANG-010 | Hoàng | Tạo formatter thời gian và tỷ lệ dùng chung | S3-HOANG-001 | Timezone VN, percent N/A khi mẫu số 0 | 1h | Kế hoạch |
| S3-HOANG-011 | Hoàng | Kiểm thử keyboard navigation dashboard web | S3-HOANG-007 | Focus order/visible focus hợp lý | 2h | Kế hoạch |
| S3-HOANG-012 | Hoàng | Kiểm thử AI fallback và empty-period visual state | S3-HOANG-006 | Có ảnh/evidence từng state | 2h | Kế hoạch |
| S4-DAT-007 | Đạt | Tạo release checklist và tiêu chí go/no-go | S4-DAT-001 | Có sign-off PO/Tech/QA trước tag | 1h | Kế hoạch |
| S4-DAT-008 | Đạt | Tạo inventory biến môi trường không lộ giá trị | S4-DAT-004 | Chỉ tên biến, owner, môi trường, rotation rule | 1h | Kế hoạch |
| S4-BAO-006 | Bảo | Thực hiện dependency lockfile audit và cập nhật bản an toàn | S4-BAO-003 | Không có critical CVE chấp nhận được | 2h | Kế hoạch |
| S4-BAO-007 | Bảo | Test khôi phục database từ backup staging | S4-BAO-002 | Restore đúng dữ liệu demo và thời gian ghi nhận | 2h | Kế hoạch |
| S4-BAO-008 | Bảo | Xác minh production log không chứa secret/PII | S4-BAO-004 | Sample log được review/redact | 1h | Kế hoạch |
| S4-HOANG-006 | Hoàng | Chạy visual regression cho 3 role và 3 breakpoint | S4-HOANG-004 | Evidence before/after/fix | 2h | Kế hoạch |
| S4-HOANG-007 | Hoàng | Kiểm thử cài đặt APK trên thiết bị Android mục tiêu | S4-BAO-005 | Install/login/core flow pass | 2h | Kế hoạch |
| S4-HOANG-008 | Hoàng | Chuẩn bị ảnh màn hình và kịch bản trình diễn | S4-HOANG-005 | Asset demo nhất quán với release | 1h | Kế hoạch |

## Quy tắc cập nhật trạng thái hàng ngày

1. Owner thêm PR/commit/test evidence vào task trước khi đổi sang `Đã xong`.
2. Reviewer đánh dấu `Đã review` hoặc trả về `Cần sửa`; không có reviewer thì task ở `Chờ review`.
3. Task blocked quá 4 giờ làm việc phải có blocker, người chịu trách nhiệm gỡ và ngày dự kiến xử lý.
4. Mỗi cuối sprint, Đạt chốt carry-over: giữ ID task, cập nhật effort còn lại, không tạo ticket trùng.
