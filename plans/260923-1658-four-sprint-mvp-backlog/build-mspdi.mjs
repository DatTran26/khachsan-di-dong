import fs from "node:fs/promises";

const baseDir = "D:/Projects/KhachSanDiDong/plans/260923-1658-four-sprint-mvp-backlog";
const csvPath = `${baseDir}/microsoft-project-import.csv`;
const outputPath = `${baseDir}/Ke-hoach-KhachSanDiDong-MSProject-2021.xml`;

const PROJECT_START = "2026-09-08T08:00:00";
const STATUS_DATE = "2026-09-24T08:00:00";
const RELEASE_DEADLINE = "2026-10-27T17:00:00";

function t(wbs, name, owner, hours, status, deliverable, evidence = "") {
  return { wbs, name, owner, hours, status, deliverable, evidence };
}

const sprints = [
  {
    id: "S1",
    name: "Sprint 1 — Nền tảng (08/09–21/09/2026)",
    deadline: "2026-09-21T17:00:00",
    groups: [
      {
        name: "Khảo sát, kickoff, phỏng vấn, AS-IS/TO-BE, requirement và sign-off",
        tasks: [
          t("S1-DAT-017", "Xác định sponsor, người quyết định và stakeholder: quản lý, lễ tân, buồng phòng, bảo trì, giảng viên", "Đạt", 1, "Cần đối chiếu", "Stakeholder map có người duyệt phạm vi"),
          t("S1-DAT-018", "Lập lịch kickoff và lịch phỏng vấn riêng cho quản lý, lễ tân, buồng phòng, bảo trì", "Đạt", 1, "Cần đối chiếu", "Interview plan: người, mục tiêu, thời lượng"),
          t("S1-DAT-019", "Soạn bộ câu hỏi phỏng vấn quản lý về KPI phòng, dashboard, phân quyền và escalation", "Đạt", 2, "Cần đối chiếu", "Questionnaire quản lý"),
          t("S1-DAT-020", "Soạn bộ câu hỏi phỏng vấn lễ tân về nhận phòng, trả phòng và điều kiện phòng sẵn sàng", "Đạt", 2, "Cần đối chiếu", "Questionnaire lễ tân"),
          t("S1-DAT-021", "Soạn bộ câu hỏi phỏng vấn nhân viên buồng phòng về giao việc, thời gian dọn và thao tác Android", "Đạt", 2, "Cần đối chiếu", "Questionnaire buồng phòng"),
          t("S1-DAT-022", "Soạn bộ câu hỏi phỏng vấn nhân viên bảo trì về báo hỏng, mức ảnh hưởng và mở lại phòng", "Đạt", 2, "Cần đối chiếu", "Questionnaire bảo trì"),
          t("S1-DAT-023", "Tổ chức kickoff, ghi mục tiêu MVP, hạn bàn giao 27/10/2026 và người phê duyệt", "Đạt", 2, "Cần đối chiếu", "Biên bản kickoff"),
          t("S1-DAT-024", "Phỏng vấn quản lý về dashboard 50 phòng và cách điều phối ca", "Đạt", 2, "Cần đối chiếu", "Interview notes quản lý, pain point, quyết định"),
          t("S1-DAT-025", "Phỏng vấn lễ tân về check-in, check-out, tra cứu phòng và ngoại lệ thường gặp", "Đạt", 2, "Cần đối chiếu", "Interview notes lễ tân"),
          t("S1-DAT-026", "Phỏng vấn nhân viên buồng phòng về nhận việc, hoàn tất dọn và thao tác tối đa chấp nhận", "Đạt", 2, "Cần đối chiếu", "Interview notes buồng phòng"),
          t("S1-DAT-027", "Phỏng vấn nhân viên bảo trì về báo hỏng, đóng việc và điều kiện ngừng phục vụ phòng", "Đạt", 2, "Cần đối chiếu", "Interview notes bảo trì"),
          t("S1-DAT-028", "Quan sát hoặc mô phỏng AS-IS một ca làm việc từ quầy lễ tân tới buồng phòng và bảo trì", "Đạt", 3, "Cần đối chiếu", "AS-IS flow, điểm nghẽn, dữ liệu vào/ra"),
          t("S1-DAT-029", "Lập problem statement và opportunity backlog, gắn từng pain point với feature MVP", "Đạt", 2, "Cần đối chiếu", "Problem statement liên kết feature"),
          t("S1-DAT-030", "Chuẩn hóa glossary và định nghĩa 3 trục trạng thái phòng: lưu trú, vệ sinh, bảo trì", "Đạt", 2, "Cần đối chiếu", "Glossary được khách hàng xác nhận"),
          t("S1-DAT-031", "Thu thập functional requirement và business rule cho 9 feature, trace tới use case", "Đạt", 4, "Cần đối chiếu", "Requirement matrix"),
          t("S1-DAT-032", "Thu thập NFR: realtime dưới 3 giây, bảo mật, dữ liệu giả lập, không gửi PII sang AI", "Đạt", 2, "Cần đối chiếu", "NFR matrix"),
          t("S1-DAT-033", "Phân loại MoSCoW và chốt non-goal MVP với khách hàng, gồm iOS nằm ngoài phạm vi", "Đạt", 2, "Cần đối chiếu", "Scope baseline được phê duyệt"),
          t("S1-DAT-034", "Mở sổ Open Question, assumption và decision: owner, hạn chốt, tác động nếu chưa chốt", "Đạt", 2, "Cần đối chiếu", "OQ register"),
          t("S1-DAT-035", "Workshop xác nhận quy trình TO-BE và các exception flow nhận phòng, dọn, bảo trì", "Đạt", 3, "Cần đối chiếu", "Biên bản workshop TO-BE"),
          t("S1-DAT-036", "Thu thập sign-off requirement baseline: ngày duyệt, người duyệt, phạm vi 4 sprint", "Đạt", 1, "Cần đối chiếu", "Biên bản hoặc email phê duyệt baseline"),
          t("S1-HOANG-016", "Khảo sát bối cảnh dùng Flutter Web tại quầy và Android tại hành lang, buồng, kỹ thuật", "Hoàng", 2, "Cần đối chiếu", "Context-of-use: thiết bị, mạng, ánh sáng, thao tác một tay"),
          t("S1-HOANG-017", "Dựng persona quản lý, lễ tân, nhân viên hiện trường và journey map từ phỏng vấn", "Hoàng", 3, "Cần đối chiếu", "Persona và journey có pain point"),
          t("S1-HOANG-018", "Usability review wireframe ASCII với người dùng đại diện, ghi issue và mức độ", "Hoàng", 3, "Cần đối chiếu", "Feedback log: sửa hoặc giữ"),
          t("S1-HOANG-019", "Rà Design Token có đủ màu 3 trục trạng thái phòng và mức tương phản accessibility", "Hoàng", 2, "Cần đối chiếu", "Token gap list"),
          t("S1-HOANG-020", "Chốt yêu cầu responsive Web và touch target Android từ bối cảnh quầy và hiện trường", "Hoàng", 2, "Cần đối chiếu", "UI acceptance checklist Web/Android"),
          t("S1-BAO-021", "Đánh giá khả thi Socket.IO, transaction PostgreSQL và thiết bị Android mục tiêu", "Bảo", 2, "Cần đối chiếu", "Feasibility note và quyết định của Đạt"),
          t("S1-BAO-022", "Xác nhận dữ liệu tối thiểu được lưu và dữ liệu không được lưu, gồm giấy tờ khách", "Bảo", 2, "Cần đối chiếu", "Data classification và retention"),
          t("S1-BAO-023", "Rà assumption API nội bộ và OpenAI: hạn mức chi phí, timeout, phương án fallback", "Bảo", 2, "Cần đối chiếu", "Integration assumption và cost limit"),
        ],
      },
      {
        name: "Artefact nghiệp vụ Đạt đã có bằng chứng trong repository",
        tasks: [
          t("S1-DAT-001", "Thu thập phạm vi, persona, non-goal và tiêu chí nghiệm thu vào PRD sản phẩm", "Đạt", 10, "Đã xong", "PRD sản phẩm", "docs/_product/prd.md"),
          t("S1-DAT-002", "Phân rã 9 feature thành BRD, PRD, URD và SRS", "Đạt", 32, "Đã xong", "Bộ đặc tả 9 feature", "docs/features/*/ gồm auth-roles, room-catalog, room-dashboard, check-in-out, housekeeping, maintenance, audit-log, realtime-sync, ai-ops-summary"),
          t("S1-DAT-003", "Viết ERD, state machine, flow, use case, user story và wireframe ASCII cho 9 feature", "Đạt", 36, "Đã xong", "SRS, use case, user story, wireframe", "docs/features/**/srs, usecases, userstories, ascii-wireframe"),
          t("S1-DAT-004", "Chốt MVP: 3 vai trò, 3 trục trạng thái phòng, dữ liệu giả lập 50 phòng", "Đạt", 4, "Đã xong", "Project profile", "docs/_shared/project-profile.md cập nhật 2026-09-15"),
          t("S1-DAT-005", "Thiết lập Gitflow, nhánh develop-dat, develop-kim, develop-bao, SECURITY và contribution", "Đạt", 4, "Đã xong", "Quy ước repo", "AGENTS.md, SECURITY.md, .github/"),
          t("S1-DAT-006", "Thiết kế Design Token guideline: màu, chữ, spacing, radius, elevation, trạng thái", "Đạt", 8, "Đã xong", "Design Token guideline", "Đạt xác nhận đã thiết kế. File docs/design-tokens.md chưa có trong repository; việc publish nằm ở S1-DAT-013"),
        ],
      },
      {
        name: "Kiến trúc, contract API, môi trường dev/staging",
        tasks: [
          t("S1-DAT-007", "Chốt monorepo apps/api (Express/TypeScript) và apps/mobile (Flutter Web + Android)", "Đạt", 2, "Cần đối chiếu", "docs/architecture.md và cây thư mục"),
          t("S1-DAT-014", "Viết ADR monorepo: trách nhiệm module API, Prisma, Flutter Web và Android", "Đạt", 1, "Cần đối chiếu", "ADR có rationale và owner"),
          t("S1-DAT-008", "Chốt API error contract: HTTP code, body lỗi, field validation, conflict version", "Đạt", 2, "Cần đối chiếu", "docs/api/error-contract.md"),
          t("S1-DAT-009", "Chốt enum dùng chung: role, occupancy, cleaning, maintenance, task status, audit action", "Đạt", 2, "Cần đối chiếu", "docs/api/domain-enums.md"),
          t("S1-DAT-010", "Chốt chính sách phiên đăng nhập: thời hạn token, logout, hash mật khẩu, rate limit", "Đạt", 2, "Cần đối chiếu", "docs/security/auth-policy.md"),
          t("S1-DAT-015", "Lập ma trận quyền API cho quản lý, lễ tân và nhân viên buồng phòng–bảo trì", "Đạt", 1, "Cần đối chiếu", "Bảng role x action dùng cho test RBAC"),
          t("S1-DAT-011", "Tạo Definition of Done và PR checklist: lint, test, review, migration, không commit secret", "Đạt", 1, "Cần đối chiếu", "PR checklist đủ mục migration", ".github/pull_request_template.md mới có checklist ngắn, chưa có mục migration/rollback"),
          t("S1-DAT-016", "Thêm checklist review migration Prisma: backup, rollback và test migration trên PR", "Đạt", 1, "Cần đối chiếu", "Mục backup/rollback trong PR checklist"),
          t("S1-DAT-012", "Mô tả môi trường dev và staging: PostgreSQL, biến môi trường, health check, người sở hữu", "Đạt", 3, "Cần đối chiếu", "docs/runbooks/environment.md"),
          t("S1-DAT-013", "Publish Design Token guideline vào docs/design-tokens.md để Hoàng triển khai ThemeData", "Đạt", 2, "Kế hoạch", "docs/design-tokens.md"),
        ],
      },
      {
        name: "Backend: Express, Prisma, auth, RBAC, danh mục phòng, Socket.IO",
        tasks: [
          t("S1-BAO-001", "Bootstrap apps/api: Express, TypeScript strict, script dev, build, lint và test", "Bảo", 3, "Cần đối chiếu", "apps/api/package.json và src/main.ts, build pass"),
          t("S1-BAO-016", "Thêm middleware validate request: payload sai trả 400 kèm lỗi theo từng field", "Bảo", 2, "Cần đối chiếu", "Test 400 field-level"),
          t("S1-BAO-017", "Thêm global exception handler và correlation ID, không trả stack hoặc secret", "Bảo", 2, "Cần đối chiếu", "Log có request ID"),
          t("S1-BAO-002", "Validate biến môi trường lúc khởi động và tạo .env.example không chứa secret", "Bảo", 2, "Cần đối chiếu", "src/config/env.ts và .env.example"),
          t("S1-BAO-003", "Tạo GET /health và GET /ready; ready kiểm tra kết nối PostgreSQL", "Bảo", 2, "Cần đối chiếu", "Test health/ready"),
          t("S1-BAO-004", "Dựng Prisma baseline: schema, naming, workflow migration trong apps/api/prisma", "Bảo", 2, "Cần đối chiếu", "prisma/schema.prisma"),
          t("S1-BAO-018", "Viết test kết nối database và transaction helper, bảo đảm rollback khi lỗi", "Bảo", 2, "Cần đối chiếu", "Test DB độc lập, rollback pass"),
          t("S1-BAO-005", "Migration User và Role: số điện thoại unique, cờ active, cột password hash", "Bảo", 2, "Cần đối chiếu", "Migration user/role"),
          t("S1-BAO-006", "Migration RoomType và Room: số phòng unique, tầng, 3 enum trạng thái, cột version", "Bảo", 2, "Cần đối chiếu", "Migration room và test constraint"),
          t("S1-BAO-007", "Seed idempotent: 3 vai trò, user demo, 50 phòng và loại phòng; chạy lại không nhân bản", "Bảo", 3, "Cần đối chiếu", "prisma/seed.ts"),
          t("S1-BAO-008", "Cài password service bcrypt hoặc argon2; API không trả hash; có password policy", "Bảo", 2, "Cần đối chiếu", "Unit test password"),
          t("S1-BAO-009", "Viết POST /auth/login: sai thông tin chung chung, từ chối user inactive, phát hành token", "Bảo", 3, "Cần đối chiếu", "Test login"),
          t("S1-BAO-019", "Thêm rate limit đăng nhập và ghi audit sự kiện login thành công hoặc thất bại", "Bảo", 2, "Cần đối chiếu", "Test chặn brute-force"),
          t("S1-BAO-010", "Viết auth middleware: verify token, gắn actor, từ chối token hết hạn", "Bảo", 2, "Cần đối chiếu", "Test route được bảo vệ"),
          t("S1-BAO-011", "Viết RBAC guard mặc định từ chối: quản lý, lễ tân, nhân viên buồng phòng–bảo trì", "Bảo", 3, "Cần đối chiếu", "Test ma trận quyền"),
          t("S1-BAO-012", "Viết API đọc phòng: danh sách, chi tiết, lọc tầng/trạng thái/loại, phân trang", "Bảo", 3, "Cần đối chiếu", "Test API và docs/api/rooms.md"),
          t("S1-BAO-020", "Xuất OpenAPI tối thiểu cho auth và room catalog để import Postman hoặc Swagger", "Bảo", 2, "Cần đối chiếu", "OpenAPI auth và rooms"),
          t("S1-BAO-013", "Viết API ghi phòng: quản lý tạo, sửa, ngừng phục vụ; validate và conflict version", "Bảo", 4, "Cần đối chiếu", "Test create, update, conflict"),
          t("S1-BAO-014", "Dựng Socket.IO: xác thực kết nối và event cập nhật phòng kèm payload version", "Bảo", 4, "Cần đối chiếu", "Minh chứng hai client"),
          t("S1-BAO-015", "Chốt quality gate backend Sprint 1: unit, integration, lint và báo cáo coverage", "Bảo", 4, "Cần đối chiếu", "Log lệnh CI local"),
        ],
      },
      {
        name: "Flutter Web, Android, Design Token và QA nền tảng",
        tasks: [
          t("S1-HOANG-001", "Bootstrap apps/mobile: Flutter, flavor/env, analyzer, build Web và APK debug", "Hoàng", 3, "Cần đối chiếu", "apps/mobile/pubspec.yaml và log build"),
          t("S1-HOANG-002", "Dựng app shell: auth guard, chặn route theo vai trò, màn loading, lỗi và not-found", "Hoàng", 3, "Cần đối chiếu", "Widget test shell"),
          t("S1-HOANG-003", "Hiện thực ThemeData từ Design Token: màu semantic, chữ, spacing, trạng thái", "Hoàng", 4, "Cần đối chiếu", "apps/mobile/lib/core/theme/"),
          t("S1-HOANG-012", "Tạo component form dùng lại: text field, button, lỗi và loading theo token", "Hoàng", 2, "Cần đối chiếu", "Form primitives"),
          t("S1-HOANG-013", "Tạo room status badge cho 3 trục lưu trú, vệ sinh và bảo trì", "Hoàng", 1, "Cần đối chiếu", "Badge có semantic color và nhãn tiếng Việt"),
          t("S1-HOANG-004", "Viết API client: base URL, header auth, map lỗi có kiểu, timeout", "Hoàng", 3, "Cần đối chiếu", "Unit test client"),
          t("S1-HOANG-005", "Làm màn đăng nhập: số điện thoại, mật khẩu, loading, sai thông tin, đăng xuất", "Hoàng", 4, "Cần đối chiếu", "Widget test login"),
          t("S1-HOANG-014", "Viết widget test cho auth guard và validation form đăng nhập", "Hoàng", 2, "Cần đối chiếu", "Test pass local"),
          t("S1-HOANG-006", "Lưu phiên an toàn, khôi phục khi mở lại app, xử lý token hết hạn và logout", "Hoàng", 2, "Cần đối chiếu", "Test restart app"),
          t("S1-HOANG-007", "Làm danh sách danh mục phòng: tìm, lọc, phân trang, loading, rỗng và lỗi", "Hoàng", 4, "Cần đối chiếu", "Widget test catalog"),
          t("S1-HOANG-008", "Làm form chi tiết phòng: quản lý tạo và sửa; vai trò khác không thấy nút ghi", "Hoàng", 4, "Cần đối chiếu", "Test ẩn control theo role"),
          t("S1-HOANG-009", "Nối Socket.IO client: vòng đời kết nối, subscribe, cập nhật state phòng local", "Hoàng", 3, "Cần đối chiếu", "Minh chứng hai trình duyệt hoặc hai client"),
          t("S1-HOANG-010", "Làm banner mất kết nối: khóa mọi nút ghi và refresh khi nối lại", "Hoàng", 2, "Cần đối chiếu", "Kịch bản offline thủ công"),
          t("S1-HOANG-011", "Chạy QA Sprint 1: 3 vai trò, RBAC, danh mục phòng, realtime hai client, responsive", "Hoàng", 4, "Cần đối chiếu", "docs/qa/sprint-1.md"),
          t("S1-HOANG-015", "Smoke test build Flutter Web và APK Android debug của Sprint 1", "Hoàng", 1, "Cần đối chiếu", "Artifact hoặc ảnh log build"),
        ],
      },
    ],
    gate: t("S1-GATE", "Cổng Sprint 1: quản lý đăng nhập, sửa phòng, seed 50 phòng, RBAC chặn ghi, realtime hai client", "Đạt", 0, "Kế hoạch", "Biên bản cổng Sprint 1"),
  },
  {
    id: "S2",
    name: "Sprint 2 — Vận hành nhận trả, dọn phòng, bảo trì, audit (22/09–05/10/2026)",
    deadline: "2026-10-05T17:00:00",
    groups: [
      {
        name: "Chốt rule vận hành trước khi code check-in, housekeeping, maintenance",
        tasks: [
          t("S2-DAT-001", "Chốt dữ liệu khách tối thiểu lúc nhận phòng: tên, số người, có lưu giấy tờ giả lập hay không", "Đạt", 1, "Kế hoạch", "SRS check-in canonical"),
          t("S2-DAT-002", "Chốt ngưỡng quá hạn dọn phòng và bảo trì, cùng tần suất quét cảnh báo", "Đạt", 1, "Kế hoạch", "SRS overdue và acceptance test"),
          t("S2-DAT-003", "Chốt danh sách nhân viên trực và luật tie-break khi tự gán việc dọn hoặc sửa", "Đạt", 1, "Kế hoạch", "SRS auto-assign"),
          t("S2-DAT-004", "Chốt ngưỡng reconnect, cách hiện conflict version và phạm vi refresh trên client", "Đạt", 1, "Kế hoạch", "SRS realtime"),
          t("S2-DAT-008", "Xác nhận vai trò nào được tạo báo hỏng và ghi vào ma trận quyền", "Đạt", 1, "Kế hoạch", "Permission matrix khớp SRS"),
          t("S2-DAT-005", "Review state machine gộp lưu trú, vệ sinh, bảo trì và ranh giới transaction", "Đạt", 3, "Kế hoạch", "Ma trận chuyển trạng thái đã ký"),
          t("S2-DAT-006", "Viết kịch bản nghiệm thu E2E 01 đến 10 cho nhận, trả, dọn, bảo trì", "Đạt", 3, "Kế hoạch", "docs/qa/e2e-sprint-2.md"),
          t("S2-DAT-009", "Viết acceptance: phòng ngừng phục vụ thì lễ tân không check-in được, có câu lỗi kỳ vọng", "Đạt", 1, "Kế hoạch", "Kịch bản phòng OOS"),
          t("S2-DAT-007", "Review contract API và event Socket.IO của luồng vận hành", "Đạt", 3, "Kế hoạch", "docs/api/operations.md"),
          t("S2-DAT-010", "Duyệt catalogue thông điệp lỗi tiếng Việt cho check-in, check-out, dọn và bảo trì", "Đạt", 1, "Kế hoạch", "Error catalogue có UI copy"),
        ],
      },
      {
        name: "Check-in, check-out, housekeeping, maintenance, audit log và Socket.IO",
        tasks: [
          t("S2-BAO-001", "Migration Stay và snapshot khách tối thiểu theo rule đã chốt", "Bảo", 3, "Kế hoạch", "Migration Stay và test rollback"),
          t("S2-BAO-002", "Migration HousekeepingTask: trạng thái, người được gán, dueAt, version, quan hệ phòng", "Bảo", 3, "Kế hoạch", "Migration housekeeping"),
          t("S2-BAO-003", "Migration MaintenanceTask: trạng thái, người báo, người nhận, dueAt, mô tả hỏng", "Bảo", 3, "Kế hoạch", "Migration maintenance"),
          t("S2-BAO-004", "Migration AuditLog và index: actor, action, entity, before, after, timestamp", "Bảo", 3, "Kế hoạch", "Migration audit log"),
          t("S2-BAO-005", "Viết service đủ điều kiện check-in: một nguồn sự thật và mã lý do từ chối", "Bảo", 3, "Kế hoạch", "Test reason code"),
          t("S2-BAO-006", "Viết API check-in trong một transaction: tạo stay, đổi trạng thái, audit, rồi mới emit", "Bảo", 4, "Kế hoạch", "Test check-in"),
          t("S2-BAO-007", "Viết API check-out: đóng stay, đánh dấu phòng cần dọn, tạo việc housekeeping", "Bảo", 4, "Kế hoạch", "Test check-out atomic"),
          t("S2-BAO-015", "Thêm idempotency cho check-out để gửi lại không tạo thêm việc dọn thứ hai", "Bảo", 2, "Kế hoạch", "Test request lặp"),
          t("S2-BAO-008", "Viết auto-assign: người đang trực, ít việc mở nhất, tie-break xác định", "Bảo", 3, "Kế hoạch", "Unit test gán việc"),
          t("S2-BAO-009", "Viết lệnh housekeeping: nhận, từ chối, bắt đầu, hoàn tất, quản lý xác nhận", "Bảo", 5, "Kế hoạch", "Test chuyển trạng thái dọn phòng"),
          t("S2-BAO-018", "Viết API danh sách việc theo assignee và trạng thái, có phân trang, lọc và sort", "Bảo", 2, "Kế hoạch", "Test list task"),
          t("S2-BAO-010", "Viết lệnh báo hỏng: tạo maintenance task, chuyển phòng ngừng phục vụ, audit và emit", "Bảo", 4, "Kế hoạch", "Test báo hỏng"),
          t("S2-BAO-011", "Viết lệnh bảo trì: nhận việc, bắt đầu, hoàn tất, mở lại, mỗi lệnh có guard", "Bảo", 4, "Kế hoạch", "Test claim, complete, reopen"),
          t("S2-BAO-012", "Viết audit service trong transaction và API đọc nhật ký", "Bảo", 4, "Kế hoạch", "Test ghi và đọc audit"),
          t("S2-BAO-017", "Serializer before/after của audit không ghi password, token hoặc PII không cần", "Bảo", 2, "Kế hoạch", "Test redact"),
          t("S2-BAO-013", "Phát Socket.IO chỉ sau commit; payload conflict khi version phòng hoặc task cũ", "Bảo", 3, "Kế hoạch", "Test emit sau commit"),
          t("S2-BAO-016", "Test optimistic lock: version cũ của phòng và task trả conflict nhất quán", "Bảo", 2, "Kế hoạch", "Test conflict"),
          t("S2-BAO-014", "Bộ test vận hành: RBAC, idempotency, rollback, check-in đồng thời, state machine", "Bảo", 8, "Kế hoạch", "Báo cáo test Sprint 2"),
          t("S2-BAO-019", "Xuất OpenAPI cho check-in, check-out và các lệnh task", "Bảo", 2, "Kế hoạch", "OpenAPI operations"),
        ],
      },
      {
        name: "Flutter Web và Android cho nhận trả, dọn phòng, bảo trì, nhật ký",
        tasks: [
          t("S2-HOANG-011", "Tạo hộp thoại xác nhận lệnh dùng chung: confirm, cancel, loading, error", "Hoàng", 2, "Kế hoạch", "Component confirmation"),
          t("S2-HOANG-001", "Màn check-in Web: chọn phòng sẵn sàng, form khách, hiện lý do không đủ điều kiện", "Hoàng", 5, "Kế hoạch", "Màn check-in"),
          t("S2-HOANG-002", "Màn check-out Web: xác nhận trả phòng và báo đã tạo việc dọn", "Hoàng", 4, "Kế hoạch", "Màn check-out"),
          t("S2-HOANG-012", "Tạo timeline trạng thái việc dùng chung cho dọn phòng và bảo trì", "Hoàng", 2, "Kế hoạch", "Component timeline"),
          t("S2-HOANG-003", "Màn Android việc dọn được gán: danh sách, hạn, ưu tiên, rỗng và loading", "Hoàng", 4, "Kế hoạch", "Màn my cleaning tasks"),
          t("S2-HOANG-004", "Thao tác việc dọn trên Android: nhận, từ chối, hoàn tất, có xác nhận và lỗi", "Hoàng", 4, "Kế hoạch", "UI action dọn phòng"),
          t("S2-HOANG-005", "Hàng chờ quản lý xác nhận phòng đã dọn trên Web: xác nhận hoặc trả lại", "Hoàng", 3, "Kế hoạch", "UI xác nhận dọn phòng"),
          t("S2-HOANG-006", "Màn báo hỏng: chọn phòng, validate mô tả, phản hồi sau khi gửi", "Hoàng", 3, "Kế hoạch", "UI báo hỏng"),
          t("S2-HOANG-007", "Màn Android việc bảo trì: nhận, bắt đầu, hoàn tất, mở lại", "Hoàng", 4, "Kế hoạch", "UI maintenance task"),
          t("S2-HOANG-008", "Màn nhật ký Web: lọc, phân trang, xem theo phòng, before sang after", "Hoàng", 4, "Kế hoạch", "UI audit log"),
          t("S2-HOANG-009", "UX conflict và reconnect: cảnh báo dữ liệu cũ, refresh, retry không ghi trùng", "Hoàng", 3, "Kế hoạch", "UI conflict"),
          t("S2-HOANG-013", "Kiểm thử Android khi mạng chập chờn: không gửi write trùng, có hướng dẫn retry", "Hoàng", 2, "Kế hoạch", "Biên bản mạng yếu"),
          t("S2-HOANG-010", "Chạy E2E và QA giao diện kịch bản 01–10 trên Flutter Web và Android", "Hoàng", 6, "Kế hoạch", "Log defect Sprint 2"),
          t("S2-HOANG-014", "Ghi defect log và retest 10 kịch bản E2E: reproduction, owner, kết quả retest", "Hoàng", 2, "Kế hoạch", "Defect log đã retest"),
        ],
      },
    ],
    gate: t("S2-GATE", "Cổng Sprint 2: check-in, check-out, dọn, xác nhận, check-in lại; báo hỏng chặn nhận phòng; audit sau commit", "Đạt", 0, "Kế hoạch", "Biên bản cổng Sprint 2"),
  },
  {
    id: "S3",
    name: "Sprint 3 — Dashboard, accessibility và AI summary (06/10–19/10/2026)",
    deadline: "2026-10-19T17:00:00",
    groups: [
      {
        name: "Chốt KPI dashboard và hợp đồng AI summary",
        tasks: [
          t("S3-DAT-001", "Chốt công thức KPI, mẫu số 0 và nhãn tổ hợp 3 trục trạng thái trên ô phòng", "Đạt", 2, "Kế hoạch", "SRS dashboard canonical"),
          t("S3-DAT-002", "Chốt fixture 50 phòng và số đếm kỳ vọng cho dashboard", "Đạt", 2, "Kế hoạch", "docs/qa/dashboard-fixture.md"),
          t("S3-DAT-003", "Chốt provider AI, timeout 15 giây, trần chi phí 300.000 đồng và schema summary", "Đạt", 2, "Kế hoạch", "ADR tích hợp AI"),
          t("S3-DAT-006", "Duyệt nhãn AI và fallback để người dùng không hiểu summary là quyết định tự động", "Đạt", 1, "Kế hoạch", "Copy nhãn tham khảo đã duyệt"),
          t("S3-DAT-004", "Viết 20 kịch bản red-team AI và tiêu chí chấp nhận fallback", "Đạt", 3, "Kế hoạch", "docs/qa/ai-evaluation.md"),
          t("S3-DAT-007", "Review payload aggregate trước khi gọi OpenAI và chứng minh không có PII", "Đạt", 1, "Kế hoạch", "Data contract không PII"),
          t("S3-DAT-005", "Review PR token, accessibility và kỹ thuật của dashboard cùng màn AI", "Đạt", 4, "Kế hoạch", "Checklist review đã ký"),
        ],
      },
      {
        name: "API dashboard, job quá hạn và AI summary phía server",
        tasks: [
          t("S3-BAO-001", "Viết query tổng hợp dashboard: đếm trạng thái, công suất, quá hạn, phòng ngừng phục vụ, bộ lọc", "Bảo", 5, "Kế hoạch", "Test khớp fixture 50 phòng"),
          t("S3-BAO-002", "Xem query plan dashboard và chỉ thêm index thực sự cần", "Bảo", 2, "Kế hoạch", "Bằng chứng EXPLAIN"),
          t("S3-BAO-010", "Thêm cache dashboard và cách vô hiệu sau event, không giữ số đếm cũ", "Bảo", 2, "Kế hoạch", "Test invalidation"),
          t("S3-BAO-003", "Viết job quá hạn idempotent cho việc dọn và bảo trì, có audit và event", "Bảo", 4, "Kế hoạch", "Test job overdue"),
          t("S3-BAO-004", "Dựng bộ fact summary theo ca hoặc ngày, không PII, cùng đầu vào cho cùng kết quả", "Bảo", 4, "Kế hoạch", "Unit test privacy và fact"),
          t("S3-BAO-005", "Viết adapter OpenAI Responses API, key chỉ ở server, parse response có cấu trúc", "Bảo", 4, "Kế hoạch", "Contract test bằng mock"),
          t("S3-BAO-012", "Thêm schema version cho payload và output AI summary", "Bảo", 2, "Kế hoạch", "Test tương thích schema"),
          t("S3-BAO-006", "Khống chế single-flight, ghi usage, abort sau 15 giây và trần 300.000 đồng", "Bảo", 3, "Kế hoạch", "Unit test quota và timeout"),
          t("S3-BAO-007", "Validator output AI: sai số hoặc bịa sự kiện thì trả báo cáo fallback tất định", "Bảo", 4, "Kế hoạch", "Test AI invalid"),
          t("S3-BAO-008", "Lưu và đọc summary mới nhất theo kỳ, audit mỗi lần tạo", "Bảo", 3, "Kế hoạch", "Test API summary"),
          t("S3-BAO-011", "Gắn request ID và audit cho lượt tạo summary: ai tạo, kỳ nào, kết quả gì", "Bảo", 2, "Kế hoạch", "Test truy vết summary"),
          t("S3-BAO-009", "Chạy 20 case chất lượng và an toàn AI: timeout, quota, privacy", "Bảo", 6, "Kế hoạch", "Bảng kết quả và test"),
          t("S3-BAO-013", "Đo latency API dashboard và summary, ghi p50 và p95", "Bảo", 2, "Kế hoạch", "Baseline latency trong QA report"),
        ],
      },
      {
        name: "UI dashboard, AI summary, responsive và accessibility",
        tasks: [
          t("S3-HOANG-010", "Tạo formatter giờ Việt Nam và tỷ lệ; hiện N/A khi mẫu số KPI bằng 0", "Hoàng", 1, "Kế hoạch", "Formatter dùng chung"),
          t("S3-HOANG-009", "Tạo skeleton, loading và error của dashboard, có nút thử lại", "Hoàng", 2, "Kế hoạch", "State loading/error"),
          t("S3-HOANG-001", "Layout dashboard Web: header KPI, lưới 50 phòng, chú giải màu semantic", "Hoàng", 5, "Kế hoạch", "Bằng chứng visual QA"),
          t("S3-HOANG-002", "Bộ lọc tầng và trạng thái, panel chi tiết phòng, trạng thái rỗng và lỗi", "Hoàng", 4, "Kế hoạch", "Widget test filter"),
          t("S3-HOANG-003", "Refresh realtime dashboard: chỉ cập nhật ô và KPI bị ảnh hưởng, hiện trạng thái kết nối", "Hoàng", 3, "Kế hoạch", "Minh chứng hai client"),
          t("S3-HOANG-004", "Hiện việc quá hạn: nhãn ưu tiên, số đếm, deep-link sang task hoặc nhật ký", "Hoàng", 3, "Kế hoạch", "Test accessibility overdue"),
          t("S3-HOANG-005", "Màn AI summary: chọn kỳ, nút tạo, trạng thái disabled và loading, các mục kết quả", "Hoàng", 4, "Kế hoạch", "Widget test summary"),
          t("S3-HOANG-006", "State lỗi AI: timeout, hết quota, output invalid, kỳ không có dữ liệu, nút thử lại", "Hoàng", 3, "Kế hoạch", "Test fallback UI"),
          t("S3-HOANG-012", "Kiểm thử giao diện fallback AI và kỳ rỗng, lưu ảnh từng state", "Hoàng", 2, "Kế hoạch", "Ảnh evidence từng state"),
          t("S3-HOANG-007", "Chỉnh responsive desktop, tablet, mobile; touch target và tương phản", "Hoàng", 5, "Kế hoạch", "Checklist cross-device"),
          t("S3-HOANG-011", "Kiểm thử keyboard navigation dashboard Web: thứ tự focus và focus nhìn thấy", "Hoàng", 2, "Kế hoạch", "Ghi nhận focus order"),
          t("S3-HOANG-008", "QA đối soát fixture 50 phòng, 100 cập nhật realtime và 20 case AI", "Hoàng", 7, "Kế hoạch", "docs/qa/sprint-3.md"),
        ],
      },
    ],
    gate: t("S3-GATE", "Cổng Sprint 3: dashboard khớp fixture, AI không gửi PII, fallback 15 giây và trần 300.000 đồng", "Đạt", 0, "Kế hoạch", "Biên bản cổng Sprint 3"),
  },
  {
    id: "S4",
    name: "Sprint 4 — Security, CI/CD, UAT, triển khai và bàn giao (20/10–27/10/2026)",
    deadline: "2026-10-27T17:00:00",
    groups: [
      {
        name: "Security, CI/CD, staging, rollback và hồ sơ bàn giao",
        tasks: [
          t("S4-DAT-001", "Đóng băng phạm vi và mở bảng triage: mức lỗi, owner, SLA, ghi chú hằng ngày", "Đạt", 2, "Kế hoạch", "Bảng triage"),
          t("S4-DAT-007", "Viết release checklist và tiêu chí go/no-go, cần chữ ký PO, tech và QA trước tag", "Đạt", 1, "Kế hoạch", "Checklist go/no-go"),
          t("S4-DAT-002", "Security review: RBAC, validation, CORS, rate limit, secret scan, dependency scan", "Đạt", 5, "Kế hoạch", "Security checklist"),
          t("S4-DAT-003", "Dựng GitHub Actions: install, lint, test, build API và Flutter trên pull request", "Đạt", 4, "Kế hoạch", "Link workflow run"),
          t("S4-DAT-004", "Viết runbook deploy và rollback: tên biến môi trường, thứ tự migration, smoke, rollback", "Đạt", 4, "Kế hoạch", "docs/runbooks/deploy.md"),
          t("S4-DAT-008", "Lập inventory biến môi trường: chỉ tên biến, owner, môi trường, quy tắc rotate, không ghi giá trị", "Đạt", 1, "Kế hoạch", "Inventory env"),
          t("S4-DAT-005", "Viết script nghiệm thu: tài khoản 3 vai trò, reset data demo, thứ tự kịch bản, kết quả kỳ vọng", "Đạt", 3, "Kế hoạch", "docs/qa/acceptance.md"),
          t("S4-DAT-006", "Đóng gói bàn giao: kiến trúc, ERD, API, cách chạy, giới hạn đã biết, release note", "Đạt", 5, "Kế hoạch", "Handover pack"),
        ],
      },
      {
        name: "Gia cố backend, diễn tập migration, APK Android",
        tasks: [
          t("S4-BAO-001", "Sửa defect backend blocker và critical, mỗi lỗi có issue, PR và regression test", "Bảo", 8, "Kế hoạch", "PR và test hồi quy"),
          t("S4-BAO-003", "Chạy full test backend và đo 100 cập nhật với 10 phiên Socket.IO", "Bảo", 5, "Kế hoạch", "Báo cáo CI và đo tải"),
          t("S4-BAO-006", "Audit lockfile npm và pub, cập nhật bản vá không còn CVE critical chấp nhận được", "Bảo", 2, "Kế hoạch", "Kết quả audit"),
          t("S4-BAO-002", "Diễn tập migration trên bản sao staging: backup, migrate, seed, rollback", "Bảo", 4, "Kế hoạch", "Nhật ký diễn tập"),
          t("S4-BAO-007", "Test restore PostgreSQL từ backup staging và ghi thời gian cùng dữ liệu demo", "Bảo", 2, "Kế hoạch", "Biên bản restore"),
          t("S4-BAO-004", "Smoke API sau deploy: health, login, một lệnh vận hành, socket reconnect", "Bảo", 2, "Kế hoạch", "Kết quả smoke"),
          t("S4-BAO-008", "Rà sample log production hoặc staging, xác nhận không có secret hay PII", "Bảo", 1, "Kế hoạch", "Sample log đã redact"),
          t("S4-BAO-005", "Đóng gói APK Android release: version, đường ký, cài thử", "Bảo", 4, "Kế hoạch", "APK và bằng chứng cài"),
        ],
      },
      {
        name: "UAT, responsive, accessibility và bàn giao demo",
        tasks: [
          t("S4-HOANG-001", "Regression đủ 3 vai trò trên Flutter Web và Android cho mọi luồng bắt buộc", "Hoàng", 8, "Kế hoạch", "Ma trận pass/fail"),
          t("S4-HOANG-002", "QA Chrome, Edge, bề rộng desktop và tablet, cùng máy Android mục tiêu", "Hoàng", 4, "Kế hoạch", "Danh sách defect responsive"),
          t("S4-HOANG-003", "Accessibility pass: focus, bàn phím trên Web, nhãn, tương phản, touch target", "Hoàng", 3, "Kế hoạch", "Checklist accessibility"),
          t("S4-HOANG-004", "Đối chiếu màn hình với Design Token, gỡ mã màu cứng không nhất quán", "Hoàng", 3, "Kế hoạch", "Nhật ký visual review"),
          t("S4-HOANG-006", "Visual regression 3 vai trò tại 3 breakpoint, lưu ảnh trước và sau khi sửa", "Hoàng", 2, "Kế hoạch", "Ảnh before/after"),
          t("S4-HOANG-005", "Diễn tập UAT theo script nghiệm thu, ghi defect và xác nhận bản sửa", "Hoàng", 6, "Kế hoạch", "Biên bản UAT"),
          t("S4-HOANG-007", "Cài APK lên thiết bị Android mục tiêu và chạy login cùng luồng lõi", "Hoàng", 2, "Kế hoạch", "Biên bản cài APK"),
          t("S4-HOANG-008", "Chuẩn bị ảnh màn hình và kịch bản trình diễn khớp bản release", "Hoàng", 1, "Kế hoạch", "Asset demo"),
        ],
      },
    ],
    gate: t("S4-GATE", "Bàn giao 27/10/2026: Web HTTPS, APK Android, CI xanh, runbook rollback và handover pack", "Đạt", 0, "Kế hoạch", "Biên bản bàn giao"),
  },
];

const dependencyWbs = {
  "S1-DAT-018": ["S1-DAT-017"],
  "S1-DAT-019": ["S1-DAT-018"],
  "S1-DAT-020": ["S1-DAT-018"],
  "S1-DAT-021": ["S1-DAT-018"],
  "S1-DAT-022": ["S1-DAT-018"],
  "S1-DAT-023": ["S1-DAT-017"],
  "S1-DAT-024": ["S1-DAT-019"],
  "S1-DAT-025": ["S1-DAT-020"],
  "S1-DAT-026": ["S1-DAT-021"],
  "S1-DAT-027": ["S1-DAT-022"],
  "S1-DAT-028": ["S1-DAT-023"],
  "S1-DAT-029": ["S1-DAT-024", "S1-DAT-025", "S1-DAT-026", "S1-DAT-027", "S1-DAT-028"],
  "S1-DAT-030": ["S1-DAT-029"],
  "S1-DAT-031": ["S1-DAT-029"],
  "S1-DAT-032": ["S1-DAT-029"],
  "S1-DAT-033": ["S1-DAT-031", "S1-DAT-032"],
  "S1-DAT-034": ["S1-DAT-029"],
  "S1-DAT-035": ["S1-DAT-030", "S1-DAT-031", "S1-DAT-032", "S1-DAT-033", "S1-DAT-034"],
  "S1-DAT-036": ["S1-DAT-035"],
  "S1-HOANG-016": ["S1-DAT-017"],
  "S1-HOANG-017": ["S1-DAT-024", "S1-DAT-025", "S1-DAT-026", "S1-DAT-027"],
  "S1-HOANG-018": ["S1-HOANG-017"],
  "S1-HOANG-019": ["S1-DAT-030"],
  "S1-HOANG-020": ["S1-HOANG-017"],
  "S1-BAO-021": ["S1-DAT-032"],
  "S1-BAO-022": ["S1-DAT-032"],
  "S1-BAO-023": ["S1-DAT-032"],
  "S1-DAT-002": ["S1-DAT-001"],
  "S1-DAT-003": ["S1-DAT-002"],
  "S1-DAT-004": ["S1-DAT-003"],
  "S1-DAT-007": [],
  "S1-DAT-008": ["S1-DAT-002"],
  "S1-DAT-009": ["S1-DAT-008"],
  "S1-DAT-010": ["S1-DAT-008"],
  "S1-DAT-011": ["S1-DAT-005"],
  "S1-DAT-012": ["S1-DAT-007"],
  "S1-DAT-013": ["S1-DAT-006"],
  "S1-DAT-014": ["S1-DAT-007"],
  "S1-DAT-015": ["S1-DAT-010"],
  "S1-DAT-016": ["S1-DAT-011"],
  "S1-BAO-001": ["S1-DAT-007"],
  "S1-BAO-002": ["S1-BAO-001"],
  "S1-BAO-003": ["S1-BAO-001"],
  "S1-BAO-004": ["S1-BAO-001", "S1-DAT-009"],
  "S1-BAO-005": ["S1-BAO-004"],
  "S1-BAO-006": ["S1-BAO-004"],
  "S1-BAO-007": ["S1-BAO-005", "S1-BAO-006"],
  "S1-BAO-008": ["S1-BAO-005"],
  "S1-BAO-009": ["S1-BAO-008"],
  "S1-BAO-010": ["S1-BAO-009"],
  "S1-BAO-011": ["S1-BAO-010", "S1-DAT-015"],
  "S1-BAO-012": ["S1-BAO-006", "S1-BAO-011"],
  "S1-BAO-013": ["S1-BAO-012"],
  "S1-BAO-014": ["S1-BAO-010", "S1-BAO-013"],
  "S1-BAO-015": ["S1-BAO-012", "S1-BAO-013", "S1-BAO-014", "S1-BAO-016", "S1-BAO-017", "S1-BAO-018", "S1-BAO-019", "S1-BAO-020"],
  "S1-BAO-016": ["S1-BAO-001"],
  "S1-BAO-017": ["S1-BAO-001"],
  "S1-BAO-018": ["S1-BAO-004"],
  "S1-BAO-019": ["S1-BAO-009"],
  "S1-BAO-020": ["S1-BAO-012"],
  "S1-HOANG-001": ["S1-DAT-007"],
  "S1-HOANG-002": ["S1-HOANG-001"],
  "S1-HOANG-003": ["S1-DAT-013", "S1-HOANG-001"],
  "S1-HOANG-004": ["S1-HOANG-002", "S1-BAO-009"],
  "S1-HOANG-005": ["S1-HOANG-004", "S1-HOANG-012"],
  "S1-HOANG-006": ["S1-HOANG-005", "S1-BAO-009"],
  "S1-HOANG-007": ["S1-HOANG-004", "S1-BAO-012", "S1-HOANG-013"],
  "S1-HOANG-008": ["S1-HOANG-007", "S1-BAO-013"],
  "S1-HOANG-009": ["S1-HOANG-004", "S1-BAO-014"],
  "S1-HOANG-010": ["S1-HOANG-009"],
  "S1-HOANG-011": ["S1-HOANG-005", "S1-HOANG-006", "S1-HOANG-007", "S1-HOANG-008", "S1-HOANG-009", "S1-HOANG-010"],
  "S1-HOANG-012": ["S1-HOANG-003"],
  "S1-HOANG-013": ["S1-HOANG-003"],
  "S1-HOANG-014": ["S1-HOANG-005"],
  "S1-HOANG-015": ["S1-HOANG-011"],
  "S1-GATE": ["S1-BAO-015", "S1-HOANG-015", "S1-DAT-012"],
  "S2-DAT-001": ["S1-DAT-036"],
  "S2-DAT-002": ["S1-DAT-036"],
  "S2-DAT-003": ["S1-DAT-036"],
  "S2-DAT-004": ["S1-DAT-036"],
  "S2-DAT-005": ["S1-DAT-036", "S2-DAT-001", "S2-DAT-002", "S2-DAT-003", "S2-DAT-004"],
  "S2-DAT-006": ["S2-DAT-005"],
  "S2-DAT-007": ["S2-DAT-005"],
  "S2-DAT-008": ["S2-DAT-003"],
  "S2-DAT-009": ["S2-DAT-006"],
  "S2-DAT-010": ["S2-DAT-007"],
  "S2-BAO-001": ["S2-DAT-001", "S2-DAT-005"],
  "S2-BAO-002": ["S2-DAT-002", "S2-DAT-003", "S2-DAT-005"],
  "S2-BAO-003": ["S2-DAT-002", "S2-DAT-005"],
  "S2-BAO-004": ["S1-BAO-011", "S2-DAT-005"],
  "S2-BAO-005": ["S2-BAO-001"],
  "S2-BAO-006": ["S2-BAO-005"],
  "S2-BAO-007": ["S2-BAO-006", "S2-BAO-002"],
  "S2-BAO-008": ["S2-BAO-002", "S2-BAO-003"],
  "S2-BAO-009": ["S2-BAO-008", "S2-BAO-007"],
  "S2-BAO-010": ["S2-BAO-003", "S2-DAT-008"],
  "S2-BAO-011": ["S2-BAO-010"],
  "S2-BAO-012": ["S2-BAO-004"],
  "S2-BAO-013": ["S2-BAO-006", "S2-BAO-007", "S2-BAO-009", "S2-BAO-011", "S2-BAO-012", "S2-DAT-004"],
  "S2-BAO-014": ["S2-BAO-013", "S2-BAO-015", "S2-BAO-016", "S2-BAO-017", "S2-BAO-018"],
  "S2-BAO-015": ["S2-BAO-007"],
  "S2-BAO-016": ["S2-BAO-013"],
  "S2-BAO-017": ["S2-BAO-012"],
  "S2-BAO-018": ["S2-BAO-009", "S2-BAO-011"],
  "S2-BAO-019": ["S2-BAO-014"],
  "S2-HOANG-001": ["S1-HOANG-015", "S2-BAO-006", "S2-HOANG-011"],
  "S2-HOANG-002": ["S2-HOANG-001", "S2-BAO-007"],
  "S2-HOANG-003": ["S2-BAO-009", "S2-HOANG-012"],
  "S2-HOANG-004": ["S2-HOANG-003"],
  "S2-HOANG-005": ["S2-HOANG-004"],
  "S2-HOANG-006": ["S2-BAO-010"],
  "S2-HOANG-007": ["S2-HOANG-006", "S2-BAO-011"],
  "S2-HOANG-008": ["S2-BAO-012"],
  "S2-HOANG-009": ["S1-HOANG-010", "S2-BAO-013"],
  "S2-HOANG-010": ["S2-HOANG-001", "S2-HOANG-002", "S2-HOANG-005", "S2-HOANG-007", "S2-HOANG-008", "S2-HOANG-009", "S2-BAO-014", "S2-DAT-006"],
  "S2-HOANG-011": ["S1-HOANG-012"],
  "S2-HOANG-012": ["S1-HOANG-013"],
  "S2-HOANG-013": ["S2-HOANG-009"],
  "S2-HOANG-014": ["S2-HOANG-010"],
  "S2-GATE": ["S2-BAO-014", "S2-HOANG-014", "S2-DAT-009", "S2-DAT-010"],
  "S3-DAT-001": ["S2-DAT-005"],
  "S3-DAT-002": ["S3-DAT-001"],
  "S3-DAT-003": ["S3-DAT-001"],
  "S3-DAT-004": ["S3-DAT-003"],
  "S3-DAT-005": ["S3-HOANG-007", "S3-BAO-009"],
  "S3-DAT-006": ["S3-DAT-003"],
  "S3-DAT-007": ["S3-DAT-004", "S3-BAO-004"],
  "S3-BAO-001": ["S3-DAT-001", "S3-DAT-002"],
  "S3-BAO-002": ["S3-BAO-001"],
  "S3-BAO-003": ["S3-BAO-001", "S3-DAT-001", "S2-BAO-009", "S2-BAO-011"],
  "S3-BAO-004": ["S3-DAT-003", "S3-BAO-001", "S2-BAO-012"],
  "S3-BAO-005": ["S3-BAO-004", "S3-DAT-007"],
  "S3-BAO-006": ["S3-BAO-005"],
  "S3-BAO-007": ["S3-BAO-005", "S3-BAO-006"],
  "S3-BAO-008": ["S3-BAO-007"],
  "S3-BAO-009": ["S3-BAO-008", "S3-DAT-004"],
  "S3-BAO-010": ["S3-BAO-002"],
  "S3-BAO-011": ["S3-BAO-008"],
  "S3-BAO-012": ["S3-BAO-005"],
  "S3-BAO-013": ["S3-BAO-009"],
  "S3-HOANG-001": ["S3-DAT-001", "S3-BAO-001", "S3-HOANG-009", "S3-HOANG-010"],
  "S3-HOANG-002": ["S3-HOANG-001"],
  "S3-HOANG-003": ["S3-HOANG-001", "S3-BAO-010", "S3-BAO-003"],
  "S3-HOANG-004": ["S3-HOANG-001", "S3-BAO-003"],
  "S3-HOANG-005": ["S3-BAO-008", "S3-DAT-006"],
  "S3-HOANG-006": ["S3-HOANG-005", "S3-BAO-007"],
  "S3-HOANG-007": ["S3-HOANG-002", "S3-HOANG-003", "S3-HOANG-004", "S3-HOANG-006"],
  "S3-HOANG-008": ["S3-HOANG-007", "S3-BAO-009", "S3-HOANG-011", "S3-HOANG-012"],
  "S3-HOANG-009": ["S3-DAT-001"],
  "S3-HOANG-010": ["S3-DAT-001"],
  "S3-HOANG-011": ["S3-HOANG-007"],
  "S3-HOANG-012": ["S3-HOANG-006"],
  "S3-GATE": ["S3-HOANG-008", "S3-BAO-013", "S3-DAT-005"],
  "S4-DAT-001": ["S3-DAT-001"],
  "S4-DAT-002": ["S4-DAT-001"],
  "S4-DAT-003": ["S4-DAT-001", "S1-BAO-015", "S1-HOANG-015"],
  "S4-DAT-004": ["S4-DAT-003"],
  "S4-DAT-005": ["S4-DAT-001", "S2-DAT-006", "S3-DAT-002"],
  "S4-DAT-006": ["S4-DAT-004", "S4-DAT-005", "S4-DAT-008"],
  "S4-DAT-007": ["S4-DAT-001"],
  "S4-DAT-008": ["S4-DAT-004"],
  "S4-BAO-001": ["S4-DAT-001", "S2-HOANG-014", "S3-HOANG-008"],
  "S4-BAO-002": ["S4-DAT-004"],
  "S4-BAO-003": ["S4-BAO-001"],
  "S4-BAO-004": ["S4-BAO-002", "S4-DAT-004"],
  "S4-BAO-005": ["S4-BAO-001"],
  "S4-BAO-006": ["S4-BAO-003"],
  "S4-BAO-007": ["S4-BAO-002"],
  "S4-BAO-008": ["S4-BAO-004"],
  "S4-HOANG-001": ["S4-DAT-005", "S3-HOANG-008"],
  "S4-HOANG-002": ["S4-HOANG-001"],
  "S4-HOANG-003": ["S4-HOANG-001"],
  "S4-HOANG-004": ["S4-HOANG-002", "S4-HOANG-003"],
  "S4-HOANG-005": ["S4-HOANG-004", "S4-BAO-004", "S4-DAT-005"],
  "S4-HOANG-006": ["S4-HOANG-004"],
  "S4-HOANG-007": ["S4-BAO-005", "S4-HOANG-005"],
  "S4-HOANG-008": ["S4-HOANG-005", "S4-HOANG-007"],
  "S4-GATE": ["S4-DAT-006", "S4-DAT-007", "S4-HOANG-008", "S4-BAO-008", "S4-DAT-002"],
};

function parseCsv(text) {
  const rows = [];
  let row = [];
  let value = "";
  let inQuotes = false;
  for (let i = 0; i < text.length; i += 1) {
    const char = text[i];
    if (char === '"') {
      if (inQuotes && text[i + 1] === '"') {
        value += '"';
        i += 1;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (char === "," && !inQuotes) {
      row.push(value);
      value = "";
    } else if ((char === "\n" || char === "\r") && !inQuotes) {
      if (char === "\r" && text[i + 1] === "\n") i += 1;
      row.push(value);
      if (row.some((cell) => cell !== "")) rows.push(row);
      row = [];
      value = "";
    } else {
      value += char;
    }
  }
  if (value !== "" || row.length) {
    row.push(value);
    rows.push(row);
  }
  return rows;
}

const leaves = [];
for (const sprint of sprints) {
  for (const group of sprint.groups) {
    for (const task of group.tasks) {
      leaves.push({ ...task, sprint: sprint.id, group: group.name });
    }
  }
  leaves.push({
    ...sprint.gate,
    sprint: sprint.id,
    group: sprint.name,
    milestone: true,
  });
}
leaves.unshift({
  wbs: "S0-TODAY",
  name: "Mốc 24/09/2026: việc chưa xong được lập lịch từ ngày trạng thái",
  owner: "Đạt",
  hours: 0,
  status: "Kế hoạch",
  deliverable: "Điểm đầu để Driving Predecessors của phần còn lại bám 24/09/2026",
  evidence: "Ngày trạng thái dự án 24/09/2026",
  sprint: "",
  group: "",
  milestone: true,
});

const byWbs = new Map(leaves.map((task) => [task.wbs, task]));
if (byWbs.size !== leaves.length) throw new Error("Trùng mã WBS");

const LINK_CODE = { FF: 0, FS: 1, SS: 2, SF: 3 };
const linkStyle = {
  "S1-HOANG-004|S1-BAO-009": ["SS", 1],
  "S1-HOANG-006|S1-BAO-009": ["SS", 2],
  "S1-HOANG-007|S1-BAO-012": ["SS", 2],
  "S1-HOANG-008|S1-BAO-013": ["SS", 2],
  "S1-HOANG-009|S1-BAO-014": ["SS", 2],
  "S1-BAO-021|S1-DAT-032": ["SS", 1],
  "S1-BAO-022|S1-DAT-032": ["SS", 1],
  "S1-BAO-023|S1-DAT-032": ["SS", 1],
  "S1-HOANG-016|S1-DAT-017": ["SS", 1],
  "S2-HOANG-001|S2-BAO-006": ["SS", 2],
  "S2-HOANG-002|S2-BAO-007": ["SS", 2],
  "S2-HOANG-003|S2-BAO-009": ["SS", 2],
  "S2-HOANG-006|S2-BAO-010": ["SS", 2],
  "S2-HOANG-007|S2-BAO-011": ["SS", 2],
  "S2-HOANG-008|S2-BAO-012": ["SS", 2],
  "S2-HOANG-009|S2-BAO-013": ["SS", 2],
  "S3-HOANG-001|S3-BAO-001": ["SS", 2],
  "S3-HOANG-003|S3-BAO-010": ["SS", 1],
  "S3-HOANG-003|S3-BAO-003": ["SS", 2],
  "S3-HOANG-004|S3-BAO-003": ["SS", 2],
  "S3-HOANG-005|S3-BAO-008": ["SS", 2],
  "S3-HOANG-006|S3-BAO-007": ["SS", 2],
  "S4-HOANG-007|S4-BAO-005": ["SS", 1],
  "S2-HOANG-010|S2-BAO-014": ["FF", 4],
  "S3-HOANG-008|S3-BAO-009": ["FF", 4],
  "S4-HOANG-003|S4-HOANG-001": ["FF", 0],
};
const extraLinks = [
  ["S1-HOANG-001", "S1-BAO-001", "SS", 0],
  ["S1-HOANG-011", "S1-BAO-015", "FF", 0],
  ["S1-HOANG-016", "S1-DAT-023", "SS", 0],
  ["S4-DAT-002", "S4-BAO-003", "FF", 0],
  ["S4-DAT-006", "S4-HOANG-008", "FF", 0],
];
for (const task of leaves) {
  const preds = dependencyWbs[task.wbs] ?? [];
  task.preds = preds.map((pred) => {
    const styled = linkStyle[`${task.wbs}|${pred}`];
    return styled
      ? { wbs: pred, type: styled[0], lagHours: styled[1] }
      : { wbs: pred, type: "FS", lagHours: 0 };
  });
  for (const pred of task.preds) {
    if (LINK_CODE[pred.type] === undefined) throw new Error(`Loại quan hệ không hợp lệ: ${pred.type}`);
    if (!byWbs.has(pred.wbs)) throw new Error(`Predecessor không tồn tại: ${task.wbs} -> ${pred.wbs}`);
  }
}
for (const [taskWbs, predWbs, type, lagHours] of extraLinks) {
  const task = byWbs.get(taskWbs);
  if (task.preds.some((pred) => pred.wbs === predWbs)) throw new Error(`Quan hệ thêm bị trùng: ${taskWbs} -> ${predWbs}`);
  task.preds.push({ wbs: predWbs, type, lagHours });
}
for (const key of Object.keys(dependencyWbs)) {
  if (!byWbs.has(key)) throw new Error(`Map phụ thuộc thừa: ${key}`);
}

const visiting = new Set();
const visited = new Set();
function walk(wbs) {
  if (visited.has(wbs)) return;
  if (visiting.has(wbs)) throw new Error(`Vòng phụ thuộc tại ${wbs}`);
  visiting.add(wbs);
  for (const pred of byWbs.get(wbs).preds) walk(pred.wbs);
  visiting.delete(wbs);
  visited.add(wbs);
}
for (const task of leaves) walk(task.wbs);

const csvText = await fs.readFile(csvPath, "utf8");
const csvIds = new Set(parseCsv(csvText).slice(1).map((row) => row[0]));
for (const id of csvIds) {
  if (!byWbs.has(id)) throw new Error(`Thiếu task so với CSV: ${id}`);
}
const gateIds = new Set(["S0-TODAY", "S1-GATE", "S2-GATE", "S3-GATE", "S4-GATE"]);
for (const task of leaves) {
  if (!csvIds.has(task.wbs) && !gateIds.has(task.wbs)) throw new Error(`Task lạ: ${task.wbs}`);
}

function parseStamp(stamp) {
  const [date, time] = stamp.split("T");
  const [year, month, day] = date.split("-").map(Number);
  const [hour, minute, second] = time.split(":").map(Number);
  return Date.UTC(year, month - 1, day, hour, minute, second);
}
function formatStamp(utcMs) {
  const date = new Date(utcMs);
  const pad = (n) => String(n).padStart(2, "0");
  return `${date.getUTCFullYear()}-${pad(date.getUTCMonth() + 1)}-${pad(date.getUTCDate())}T${pad(date.getUTCHours())}:${pad(date.getUTCMinutes())}:${pad(date.getUTCSeconds())}`;
}
function dayMinutes(utcMs) {
  const date = new Date(utcMs);
  return date.getUTCHours() * 60 + date.getUTCMinutes();
}
function isWeekend(utcMs) {
  const day = new Date(utcMs).getUTCDay();
  return day === 0 || day === 6;
}
function atMinutes(utcMs, minutes) {
  const date = new Date(utcMs);
  return Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate(), 0, minutes, 0);
}
function nextWeekday(utcMs) {
  let cursor = utcMs + 24 * 60 * 60 * 1000;
  while (isWeekend(cursor)) cursor += 24 * 60 * 60 * 1000;
  return atMinutes(cursor, 8 * 60);
}
function snapForward(utcMs) {
  let cursor = utcMs;
  if (isWeekend(cursor)) {
    while (isWeekend(cursor)) cursor += 24 * 60 * 60 * 1000;
    return atMinutes(cursor, 8 * 60);
  }
  const mins = dayMinutes(cursor);
  if (mins < 8 * 60) return atMinutes(cursor, 8 * 60);
  if (mins >= 12 * 60 && mins < 13 * 60) return atMinutes(cursor, 13 * 60);
  if (mins >= 17 * 60) return nextWeekday(cursor);
  return cursor;
}
function slotEnd(utcMs) {
  const mins = dayMinutes(utcMs);
  return atMinutes(utcMs, mins < 12 * 60 ? 12 * 60 : 17 * 60);
}
function addWorkMinutes(startMs, minutes) {
  if (minutes <= 0) return snapForward(startMs);
  let cursor = snapForward(startMs);
  let left = minutes;
  while (left > 0) {
    cursor = snapForward(cursor);
    const end = slotEnd(cursor);
    const available = Math.round((end - cursor) / 60000);
    const use = Math.min(left, available);
    cursor += use * 60000;
    left -= use;
  }
  return cursor;
}
function previousWeekdayEnd(utcMs) {
  let cursor = utcMs - 24 * 60 * 60 * 1000;
  while (isWeekend(cursor)) cursor -= 24 * 60 * 60 * 1000;
  return atMinutes(cursor, 17 * 60);
}
function retreatToWorkEnd(utcMs) {
  let cursor = utcMs;
  if (isWeekend(cursor)) {
    while (isWeekend(cursor)) cursor -= 24 * 60 * 60 * 1000;
    return atMinutes(cursor, 17 * 60);
  }
  const mins = dayMinutes(cursor);
  if (mins <= 8 * 60) return previousWeekdayEnd(cursor);
  if (mins > 12 * 60 && mins <= 13 * 60) return atMinutes(cursor, 12 * 60);
  if (mins > 17 * 60) return atMinutes(cursor, 17 * 60);
  return cursor;
}
function subtractWorkMinutes(finishMs, minutes) {
  if (minutes <= 0) return snapForward(finishMs);
  let cursor = retreatToWorkEnd(finishMs);
  let left = minutes;
  while (left > 0) {
    const mins = dayMinutes(cursor);
    const slotStartMin = mins <= 12 * 60 ? 8 * 60 : 13 * 60;
    const available = mins - slotStartMin;
    const use = Math.min(left, available);
    cursor = atMinutes(cursor, mins - use);
    left -= use;
    if (left > 0) cursor = retreatToWorkEnd(cursor);
  }
  return cursor;
}
function shiftByLag(utcMs, lagHours) {
  return lagHours === 0 ? utcMs : addWorkMinutes(utcMs, lagHours * 60);
}
function workingMinutesBetween(startMs, finishMs) {
  if (finishMs <= startMs) return 0;
  let cursor = snapForward(startMs);
  let total = 0;
  while (cursor < finishMs) {
    const end = Math.min(slotEnd(cursor), finishMs);
    if (end > cursor) total += Math.round((end - cursor) / 60000);
    if (end >= finishMs) break;
    cursor = snapForward(end);
  }
  return total;
}
function durationIso(minutes) {
  const hours = Math.floor(minutes / 60);
  const mins = minutes % 60;
  return `PT${hours}H${mins}M0S`;
}
function xmlEscape(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

const projectStartMs = parseStamp(PROJECT_START);
const statusMs = parseStamp(STATUS_DATE);
for (const task of leaves) {
  if (task.status === "Đã xong" && task.preds.some((pred) => byWbs.get(pred.wbs).status !== "Đã xong")) {
    throw new Error(`${task.wbs} đã xong nhưng phụ thuộc task chưa xong`);
  }
}
const successors = new Map(leaves.map((task) => [task.wbs, []]));
for (const task of leaves) {
  for (const pred of task.preds) successors.get(pred.wbs).push(task.wbs);
}
const pendingPreds = new Map(leaves.map((task) => [task.wbs, task.preds.length]));
const ready = leaves.filter((task) => task.preds.length === 0).map((task) => task.wbs);
const resourceFree = { Đạt: projectStartMs, Hoàng: projectStartMs, Bảo: projectStartMs };
const scheduled = [];
while (ready.length) {
  ready.sort((a, b) => {
    const ta = byWbs.get(a);
    const tb = byWbs.get(b);
    const doneDelta = Number(tb.status === "Đã xong") - Number(ta.status === "Đã xong");
    if (doneDelta !== 0) return doneDelta;
    const discovery = (wbs) => (wbs.startsWith("S1-DAT-01") && wbs >= "S1-DAT-017") || wbs.startsWith("S1-DAT-02") || wbs.startsWith("S1-DAT-03") ? 0 : 1;
    const discoveryDelta = discovery(a) - discovery(b);
    if (discoveryDelta !== 0) return discoveryDelta;
    return a.localeCompare(b);
  });
  const task = byWbs.get(ready.shift());
  let earliest = projectStartMs;
  for (const pred of task.preds) {
    const source = byWbs.get(pred.wbs);
    if (pred.type === "FS") earliest = Math.max(earliest, shiftByLag(source.finishMs, pred.lagHours));
    else if (pred.type === "SS") earliest = Math.max(earliest, shiftByLag(source.startMs, pred.lagHours));
    else {
      const requiredFinish = pred.type === "FF"
        ? shiftByLag(source.finishMs, pred.lagHours)
        : shiftByLag(source.startMs, pred.lagHours);
      let impliedStart = task.hours === 0 ? requiredFinish : subtractWorkMinutes(requiredFinish, task.hours * 60);
      if (task.hours > 0 && addWorkMinutes(snapForward(impliedStart), task.hours * 60) < requiredFinish) {
        impliedStart = requiredFinish;
      }
      earliest = Math.max(earliest, impliedStart);
    }
  }
  if (task.status !== "Đã xong" && task.hours > 0) earliest = Math.max(earliest, resourceFree[task.owner]);
  task.startMs = snapForward(earliest);
  task.finishMs = task.hours === 0 ? task.startMs : addWorkMinutes(task.startMs, task.hours * 60);
  if (task.status !== "Đã xong" && task.hours > 0) resourceFree[task.owner] = task.finishMs;
  scheduled.push(task);
  for (const child of successors.get(task.wbs)) {
    pendingPreds.set(child, pendingPreds.get(child) - 1);
    if (pendingPreds.get(child) === 0) ready.push(child);
  }
}
if (scheduled.length !== leaves.length) throw new Error("Không xếp được toàn bộ task, có thể còn vòng phụ thuộc");

function reaches(fromWbs, targetWbs, seen = new Set()) {
  if (fromWbs === targetWbs) return true;
  if (seen.has(fromWbs)) return false;
  seen.add(fromWbs);
  for (const pred of byWbs.get(fromWbs).preds) {
    if (reaches(pred.wbs, targetWbs, seen)) return true;
  }
  return false;
}
for (const owner of ["Đạt", "Hoàng", "Bảo"]) {
  const queue = leaves
    .filter((task) => task.owner === owner && task.status !== "Đã xong" && task.hours > 0)
    .sort((a, b) => a.startMs - b.startMs || a.wbs.localeCompare(b.wbs));
  for (let index = 1; index < queue.length; index += 1) {
    const previous = queue[index - 1];
    const current = queue[index];
    const existing = current.preds.find((pred) => pred.wbs === previous.wbs);
    if (existing) {
      existing.type = "FS";
      existing.lagHours = 0;
      continue;
    }
    if (reaches(previous.wbs, current.wbs)) continue;
    current.preds.push({ wbs: previous.wbs, type: "FS", lagHours: 0 });
  }
}
const seenCycle = new Set();
const stackCycle = new Set();
function assertAcyclic(wbs) {
  if (seenCycle.has(wbs)) return;
  if (stackCycle.has(wbs)) throw new Error(`Vòng phụ thuộc sau khi nối chuỗi resource tại ${wbs}`);
  stackCycle.add(wbs);
  for (const pred of byWbs.get(wbs).preds) assertAcyclic(pred.wbs);
  stackCycle.delete(wbs);
  seenCycle.add(wbs);
}
for (const task of leaves) {
  assertAcyclic(task.wbs);
  for (const pred of task.preds) {
    const source = byWbs.get(pred.wbs);
    if (pred.type === "FS" && source.finishMs > task.startMs) {
      throw new Error(`${pred.wbs} kết thúc sau khi ${task.wbs} bắt đầu`);
    }
    if (pred.type === "SS" && shiftByLag(source.startMs, pred.lagHours) > task.startMs) {
      throw new Error(`${task.wbs} bắt đầu trước mốc SS của ${pred.wbs}`);
    }
    const requiredFinish = pred.type === "FF"
      ? shiftByLag(source.finishMs, pred.lagHours)
      : pred.type === "SF"
        ? shiftByLag(source.startMs, pred.lagHours)
        : null;
    if (requiredFinish !== null && task.finishMs < requiredFinish) {
      throw new Error(`${task.wbs} kết thúc trước ràng buộc ${pred.type} của ${pred.wbs}`);
    }
  }
}

const nodes = [{
  kind: "summary",
  name: "Khách Sạn Di Động — MVP quản lý phòng realtime",
  sprint: "",
  wbsCode: "1",
  level: 1,
  children: [],
}];
sprints.forEach((sprint, sprintIndex) => {
  const sprintNode = {
    kind: "summary",
    name: sprint.name,
    sprint: sprint.id,
    wbsCode: `1.${sprintIndex + 1}`,
    level: 2,
    deadline: sprint.deadline,
    children: [],
  };
  sprint.groups.forEach((group, groupIndex) => {
    const groupNode = {
      kind: "summary",
      name: group.name,
      sprint: sprint.id,
      wbsCode: `1.${sprintIndex + 1}.${groupIndex + 1}`,
      level: 3,
      children: group.tasks.map((source) => byWbs.get(source.wbs)),
    };
    sprintNode.children.push(groupNode);
  });
  sprintNode.children.push(byWbs.get(sprint.gate.wbs));
  nodes[0].children.push(sprintNode);
});
nodes[0].children.unshift(byWbs.get("S0-TODAY"));

const flat = [];
function flatten(node, outline) {
  node.wbsCode = outline;
  node.level = outline.split(".").length;
  flat.push(node);
  (node.children ?? []).forEach((child, index) => flatten(child, `${outline}.${index + 1}`));
}
flatten(nodes[0], "1");

function nodeStart(node) {
  if (node.kind !== "summary") return node.startMs;
  return Math.min(...node.children.map(nodeStart));
}
function nodeFinish(node) {
  if (node.kind !== "summary") return node.finishMs;
  return Math.max(...node.children.map(nodeFinish));
}
flat.forEach((node, index) => {
  node.uid = index + 1;
  node.id = index + 1;
  node.startMs = nodeStart(node);
  node.finishMs = nodeFinish(node);
  node.workMinutes = node.kind === "summary"
    ? workingMinutesBetween(node.startMs, node.finishMs)
    : node.hours * 60;
});
const uidByWbs = new Map(leaves.map((task) => [task.wbs, task.uid]));

let linkCount = 0;
const taskXml = flat.map((node) => {
  const summary = node.kind === "summary" ? 1 : 0;
  const milestone = node.milestone ? 1 : 0;
  const percent = node.status === "Đã xong" ? 100 : 0;
  const work = durationIso(node.workMinutes);
  const actual = percent === 100 ? work : "PT0H0M0S";
  const remaining = percent === 100 ? "PT0H0M0S" : work;
  const notes = node.kind === "summary"
    ? ""
    : [
      `Mã: ${node.wbs}`,
      `Trạng thái: ${node.status}`,
      `Đầu ra: ${node.deliverable}`,
      node.evidence ? `Bằng chứng: ${node.evidence}` : "Bằng chứng: chưa có trong repository tại 24/09/2026",
      "Quan hệ gồm FS, SS, FF và SF. Việc ghi dữ liệu đi qua API, kiểm quyền, ghi audit, rồi mới phát Socket.IO.",
    ].join("\n");
  const preds = node.kind === "summary"
    ? ""
    : node.preds.map((pred) => {
      linkCount += 1;
      const lagTenths = pred.lagHours * 60 * 10;
      return `<PredecessorLink><PredecessorUID>${uidByWbs.get(pred.wbs)}</PredecessorUID><Type>${LINK_CODE[pred.type]}</Type><CrossProject>0</CrossProject><LinkLag>${lagTenths}</LinkLag><LagFormat>${pred.lagHours > 0 ? 5 : 7}</LagFormat></PredecessorLink>`;
    }).join("");
  const extra = node.kind === "summary"
    ? ""
    : [
      `<ExtendedAttribute><FieldID>188743731</FieldID><Value>${xmlEscape(node.wbs)}</Value></ExtendedAttribute>`,
      `<ExtendedAttribute><FieldID>188743734</FieldID><Value>${xmlEscape(node.sprint)}</Value></ExtendedAttribute>`,
      `<ExtendedAttribute><FieldID>188743737</FieldID><Value>${xmlEscape(node.status)}</Value></ExtendedAttribute>`,
      `<ExtendedAttribute><FieldID>188743740</FieldID><Value>${xmlEscape(node.deliverable)}</Value></ExtendedAttribute>`,
    ].join("");
  const deadline = node.deadline ? `<Deadline>${node.deadline}</Deadline>` : node.wbs === "S4-GATE" ? `<Deadline>${RELEASE_DEADLINE}</Deadline>` : "";
  return `<Task>
<UID>${node.uid}</UID>
<ID>${node.id}</ID>
<Name>${xmlEscape(node.name)}</Name>
<Type>1</Type>
<IsNull>0</IsNull>
<WBS>${node.wbsCode ?? node.wbs}</WBS>
<OutlineNumber>${node.wbsCode ?? node.wbs}</OutlineNumber>
<OutlineLevel>${node.level ?? 4}</OutlineLevel>
<Priority>${node.milestone ? 800 : 500}</Priority>
<Start>${formatStamp(node.startMs)}</Start>
<Finish>${formatStamp(node.finishMs)}</Finish>
<Duration>${work}</Duration>
<Manual>0</Manual>
<DurationFormat>${node.workMinutes >= 480 || milestone || summary ? 7 : 5}</DurationFormat>
<Work>${summary ? "PT0H0M0S" : work}</Work>
<ResumeValid>0</ResumeValid>
<EffortDriven>0</EffortDriven>
<Recurring>0</Recurring>
<Estimated>0</Estimated>
<Milestone>${milestone}</Milestone>
<Summary>${summary}</Summary>
<Critical>0</Critical>
<PercentComplete>${summary ? 0 : percent}</PercentComplete>
<PercentWorkComplete>${summary ? 0 : percent}</PercentWorkComplete>
${percent === 100 ? `<ActualStart>${formatStamp(node.startMs)}</ActualStart><ActualFinish>${formatStamp(node.finishMs)}</ActualFinish>` : ""}
<ActualDuration>${actual}</ActualDuration>
<ActualWork>${summary ? "PT0H0M0S" : actual}</ActualWork>
<RemainingDuration>${remaining}</RemainingDuration>
<RemainingWork>${summary ? "PT0H0M0S" : remaining}</RemainingWork>
<ConstraintType>0</ConstraintType>
<CalendarUID>1</CalendarUID>
<FixedCostAccrual>3</FixedCostAccrual>
${deadline}
<Notes>${xmlEscape(notes)}</Notes>
${preds}
${extra}
</Task>`;
}).join("\n");

const leafNodes = flat.filter((node) => node.kind !== "summary" && node.hours > 0);
const assignments = leafNodes.map((node, index) => {
  const resourceUid = node.owner === "Đạt" ? 1 : node.owner === "Hoàng" ? 2 : 3;
  const percent = node.status === "Đã xong" ? 100 : 0;
  const work = durationIso(node.hours * 60);
  return `<Assignment>
<UID>${index + 1}</UID>
<TaskUID>${node.uid}</TaskUID>
<ResourceUID>${resourceUid}</ResourceUID>
<Units>1</Units>
<Work>${work}</Work>
<ActualWork>${percent === 100 ? work : "PT0H0M0S"}</ActualWork>
<RemainingWork>${percent === 100 ? "PT0H0M0S" : work}</RemainingWork>
<PercentWorkComplete>${percent}</PercentWorkComplete>
<Start>${formatStamp(node.startMs)}</Start>
<Finish>${formatStamp(node.finishMs)}</Finish>
</Assignment>`;
}).join("\n");

function weekDay(dayType, working) {
  if (!working) return `<WeekDay><DayType>${dayType}</DayType><DayWorking>0</DayWorking></WeekDay>`;
  return `<WeekDay><DayType>${dayType}</DayType><DayWorking>1</DayWorking><WorkingTimes><WorkingTime><FromTime>08:00:00</FromTime><ToTime>12:00:00</ToTime></WorkingTime><WorkingTime><FromTime>13:00:00</FromTime><ToTime>17:00:00</ToTime></WorkingTime></WorkingTimes></WeekDay>`;
}

const projectFinish = formatStamp(Math.max(...flat.map((node) => node.finishMs)));
const doneCount = leaves.filter((task) => task.status === "Đã xong").length;
const checkCount = leaves.filter((task) => task.status === "Cần đối chiếu").length;
const planCount = leaves.filter((task) => task.status === "Kế hoạch").length;
const leafCount = leaves.filter((task) => !task.milestone).length;

const xml = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Project xmlns="http://schemas.microsoft.com/project">
<SaveVersion>14</SaveVersion>
<Name>Khach San Sach</Name>
<Title>Kế hoạch triển khai hệ thống quản lý khách sạn realtime</Title>
<ScheduleFromStart>1</ScheduleFromStart>
<StartDate>${PROJECT_START}</StartDate>
<FinishDate>${projectFinish}</FinishDate>
<FYStartDate>1</FYStartDate>
<CriticalSlackLimit>0</CriticalSlackLimit>
<CurrencyDigits>0</CurrencyDigits>
<CurrencySymbol>VND</CurrencySymbol>
<CurrencyCode>VND</CurrencyCode>
<CalendarUID>1</CalendarUID>
<DefaultStartTime>08:00:00</DefaultStartTime>
<DefaultFinishTime>17:00:00</DefaultFinishTime>
<MinutesPerDay>480</MinutesPerDay>
<MinutesPerWeek>2400</MinutesPerWeek>
<DaysPerMonth>20</DaysPerMonth>
<DefaultTaskType>1</DefaultTaskType>
<DefaultFixedCostAccrual>3</DefaultFixedCostAccrual>
<DurationFormat>7</DurationFormat>
<WorkFormat>2</WorkFormat>
<EditableActualCosts>0</EditableActualCosts>
<HonorConstraints>1</HonorConstraints>
<EarnedValueMethod>0</EarnedValueMethod>
<InsertedProjectsLikeSummary>1</InsertedProjectsLikeSummary>
<MultipleCriticalPaths>0</MultipleCriticalPaths>
<NewTasksEffortDriven>0</NewTasksEffortDriven>
<NewTasksEstimated>0</NewTasksEstimated>
<SplitsInProgressTasks>0</SplitsInProgressTasks>
<SpreadActualCost>0</SpreadActualCost>
<SpreadPercentComplete>0</SpreadPercentComplete>
<TaskUpdatesResource>1</TaskUpdatesResource>
<FiscalYearStart>0</FiscalYearStart>
<WeekStartDay>1</WeekStartDay>
<MoveCompletedEndsBack>0</MoveCompletedEndsBack>
<MoveRemainingStartsBack>0</MoveRemainingStartsBack>
<MoveRemainingStartsForward>0</MoveRemainingStartsForward>
<MoveCompletedEndsForward>0</MoveCompletedEndsForward>
<BaselineForEarnedValue>0</BaselineForEarnedValue>
<AutoAddNewResourcesAndTasks>1</AutoAddNewResourcesAndTasks>
<CurrentDate>${STATUS_DATE}</CurrentDate>
<StatusDate>${STATUS_DATE}</StatusDate>
<Autolink>0</Autolink>
<NewTaskStartDate>0</NewTaskStartDate>
<NewTasksAreManual>0</NewTasksAreManual>
<DefaultTaskEVMethod>0</DefaultTaskEVMethod>
<ProjectExternallyEdited>0</ProjectExternallyEdited>
<ActualsInSync>1</ActualsInSync>
<RemoveFileProperties>0</RemoveFileProperties>
<AdminProject>0</AdminProject>
<ExtendedAttributes>
<ExtendedAttribute><FieldID>188743731</FieldID><FieldName>Text1</FieldName><Alias>WBS ID</Alias></ExtendedAttribute>
<ExtendedAttribute><FieldID>188743734</FieldID><FieldName>Text2</FieldName><Alias>Sprint</Alias></ExtendedAttribute>
<ExtendedAttribute><FieldID>188743737</FieldID><FieldName>Text3</FieldName><Alias>Trạng thái</Alias></ExtendedAttribute>
<ExtendedAttribute><FieldID>188743740</FieldID><FieldName>Text4</FieldName><Alias>Đầu ra</Alias></ExtendedAttribute>
</ExtendedAttributes>
<Calendars>
<Calendar>
<UID>1</UID>
<Name>Lịch Khách Sạn</Name>
<IsBaseCalendar>1</IsBaseCalendar>
<IsBaselineCalendar>0</IsBaselineCalendar>
<BaseCalendarUID>-1</BaseCalendarUID>
<WeekDays>
${weekDay(1, false)}
${weekDay(2, true)}
${weekDay(3, true)}
${weekDay(4, true)}
${weekDay(5, true)}
${weekDay(6, true)}
${weekDay(7, false)}
</WeekDays>
</Calendar>
</Calendars>
<Tasks>
${taskXml}
</Tasks>
<Resources>
<Resource><UID>0</UID><ID>0</ID><Type>1</Type><IsNull>1</IsNull></Resource>
<Resource><UID>1</UID><ID>1</ID><Name>Đạt</Name><Type>1</Type><IsNull>0</IsNull><Initials>Đ</Initials><Group>WPC</Group><MaxUnits>1</MaxUnits><PeakUnits>1</PeakUnits><CalendarUID>1</CalendarUID></Resource>
<Resource><UID>2</UID><ID>2</ID><Name>Hoàng</Name><Type>1</Type><IsNull>0</IsNull><Initials>H</Initials><Group>WPC</Group><MaxUnits>1</MaxUnits><PeakUnits>1</PeakUnits><CalendarUID>1</CalendarUID></Resource>
<Resource><UID>3</UID><ID>3</ID><Name>Bảo</Name><Type>1</Type><IsNull>0</IsNull><Initials>B</Initials><Group>WPC</Group><MaxUnits>1</MaxUnits><PeakUnits>1</PeakUnits><CalendarUID>1</CalendarUID></Resource>
</Resources>
<Assignments>
${assignments}
</Assignments>
</Project>
`;

await fs.writeFile(outputPath, xml, "utf8");

const hoursByOwner = { Đạt: 0, Hoàng: 0, Bảo: 0 };
for (const task of leaves) {
  if (task.status !== "Đã xong" && task.hours > 0) hoursByOwner[task.owner] += task.hours;
}
const gateFinish = Object.fromEntries(["S1-GATE", "S2-GATE", "S3-GATE", "S4-GATE"].map((id) => [id, formatStamp(byWbs.get(id).finishMs)]));
console.log(JSON.stringify({
  outputPath,
  leafTasks: leafCount,
  milestones: 4,
  rows: flat.length,
  predecessorLinks: linkCount,
  done: doneCount,
  canDoiChieu: checkCount,
  keHoach: planCount,
  projectFinish,
  gateFinish,
  remainingHours: hoursByOwner,
}, null, 2));
