import fs from "node:fs/promises";
import { FileBlob, SpreadsheetFile, Workbook } from "@oai/artifact-tool";

const root = "D:/Projects/KhachSanDiDong";
const data = JSON.parse(await fs.readFile(`${root}/.codex-temp/evidence-register-data.json`, "utf8"));
const outputDir = `${root}/outputs/evidence-register-261028`;
const outputPath = `${outputDir}/khach-san-di-dong-evidence-register.xlsx`;
const previewDir = `${outputDir}/previews`;
const font = "Arial";
const navy = "#1F4E78";
const blue = "#D9EAF7";
const amber = "#FFF2CC";
const paleRed = "#FCE4D6";
const paleGreen = "#E2F0D9";
const paleBlue = "#EAF3F8";

function asDate(value) {
  return value ? new Date(value) : null;
}

function acceptanceFor(id) {
  if (id.includes("-DAT-")) return "Reviewer phê duyệt artefact";
  if (id.includes("-BAO-")) return "Code + test/CI + reviewer";
  return "UAT/sign-off Đạt cho UI/vận hành; test/CI cho QA nội bộ";
}

function statusHint(status) {
  if (status === "Đã xong") return "Nguồn nói đã xong, vẫn cần xác minh evidence";
  if (status === "Kế hoạch") return "Chưa có bằng chứng thực thi";
  return "Cần đối chiếu PR, commit, test hoặc artefact";
}

function sectionHeader(sheet, range) {
  const header = sheet.getRange(range);
  header.format = {
    fill: navy,
    font: { name: font, size: 10, bold: true, color: "#FFFFFF" },
    horizontalAlignment: "center",
    verticalAlignment: "center",
    wrapText: true,
    borders: { preset: "outside", style: "thin", color: navy },
  };
  header.format.rowHeight = 30;
}

function styleTableBody(sheet, range) {
  const body = sheet.getRange(range);
  body.format.font = { name: font, size: 10, color: "#1F1F1F" };
  body.format.verticalAlignment = "center";
  body.format.borders = { preset: "inside", style: "thin", color: "#E7E6E6" };
}

const workbook = Workbook.create();
const summary = workbook.worksheets.add("Manager Summary");
const register = workbook.worksheets.add("Task Register");
const prEvidence = workbook.worksheets.add("PR Evidence");

for (const sheet of [summary, register, prEvidence]) {
  sheet.showGridLines = false;
  sheet.tabColor = navy;
}

// Manager-facing summary.
summary.getRange("A2").values = [["Khách Sạn Di Động — Evidence register quản lý WBS"]];
summary.getRange("A2").format.font = { name: font, size: 15, bold: true, color: navy };
summary.getRange("A3").values = [["Baseline MS Project được giữ nguyên. Tiến độ thực tế chỉ được cập nhật từ evidence tại Task Register."]];
summary.getRange("A3").format.font = { name: font, size: 10, italic: true, color: "#666666" };
summary.getRange("A4").values = [["Cảnh báo dữ liệu nguồn: CSV có 31 giá trị Status là tên người review. Không dùng cột đó để kết luận tiến độ."]];
summary.getRange("A4").format = { fill: paleRed, font: { name: font, size: 10, bold: true, color: "#9C0006" } };

summary.getRange("A6:C6").values = [["Chỉ số", "Số lượng", "Ý nghĩa"]];
sectionHeader(summary, "A6:C6");
summary.getRange("A7:C13").values = [
  ["Task lá trong register", null, "Mỗi task có WBS ID bất biến"],
  ["Task source ghi Đã xong", null, "Chưa tự động là Done"],
  ["Task cần đối chiếu", null, "Chưa có evidence liên kết"],
  ["Task cần xác minh", null, "Nguồn ghi xong nhưng chưa kiểm tra evidence"],
  ["Task thực tế Đã xong", null, "Chỉ khi có acceptance evidence phù hợp"],
  ["PR lịch sử đã audit", null, "Cần mapping đến từng task lá ở Phase 3"],
  ["Giá trị Status CSV không hợp lệ", data.quality.invalid_status_count, "Đã tách khỏi dữ liệu tiến độ"],
];
summary.getRange("B7:B12").formulas = [
  ["=COUNTA('Task Register'!$A$6:$A$183)"],
  ["=COUNTIF('Task Register'!$L$6:$L$183,\"Đã xong\")"],
  ["=COUNTIF('Task Register'!$M$6:$M$183,\"Cần đối chiếu\")"],
  ["=COUNTIF('Task Register'!$M$6:$M$183,\"Cần xác minh\")"],
  ["=COUNTIF('Task Register'!$M$6:$M$183,\"Đã xong\")"],
  ["=COUNTA('PR Evidence'!$A$6:$A$25)"],
];
styleTableBody(summary, "A7:C13");
summary.getRange("B7:B13").format = { font: { name: font, size: 10, bold: true, color: navy }, horizontalAlignment: "right", numberFormat: "#,##0" };

summary.getRange("A16:D16").values = [["Sprint", "Task lá", "Cần đối chiếu", "Kế hoạch"]];
sectionHeader(summary, "A16:D16");
summary.getRange("A17:A20").values = [["S1"], ["S2"], ["S3"], ["S4"]];
summary.getRange("B17:D17").formulas = [[
  "=COUNTIF('Task Register'!$C$6:$C$183,A17)",
  "=COUNTIFS('Task Register'!$C$6:$C$183,A17,'Task Register'!$M$6:$M$183,\"Cần đối chiếu\")",
  "=COUNTIFS('Task Register'!$C$6:$C$183,A17,'Task Register'!$M$6:$M$183,\"Kế hoạch\")",
]];
summary.getRange("B17:D20").fillDown();
styleTableBody(summary, "A17:D20");
summary.getRange("B17:D20").format.numberFormat = "#,##0";

summary.getRange("F6:H6").values = [["Quy tắc cập nhật", "Thao tác", "Điều kiện chuyển Đã xong"]];
sectionHeader(summary, "F6:H6");
summary.getRange("F7:H11").values = [
  ["1. Gắn evidence", "Điền URL PR/commit, test/CI hoặc artefact", "Không để evidence chỉ là mô tả miệng"],
  ["2. Cập nhật actual status", "Chọn trạng thái ở cột Actual status", "Không suy diễn từ PercentComplete XML"],
  ["3. Xác nhận acceptance", "Gắn UAT/sign-off hoặc reviewer approval", "UI/vận hành cần Đạt xác nhận"],
  ["4. Đánh dấu Đã xong", "Chỉ sau bước 1 đến 3", "Task kỹ thuật cần code + test/CI + reviewer"],
  ["5. Lưu ngày kiểm tra", "Điền Last verified", "Giữ được lịch sử đối chứng cho quản lý"],
];
styleTableBody(summary, "F7:H11");
summary.getRange("F7:H11").format.wrapText = true;

summary.getRange("F14:H14").values = [["Nguồn", "Vai trò", "Kiểm tra đã áp dụng"]];
sectionHeader(summary, "F14:H14");
summary.getRange("F15:H18").values = [
  ["MS Project XML", "Baseline WBS, lịch, owner, status và deliverable", "178 task lá, 178 WBS ID duy nhất"],
  ["Detailed task breakdown", "KT/reviewer và quy tắc Done", "Tách KT khỏi Status"],
  ["Microsoft Project import CSV", "Đối chứng schema", "31 Status lỗi là tên người"],
  ["GitHub PR #34–#53", "Bằng chứng cấp PR lịch sử", "Chưa mapping trực tiếp đến task lá"],
];
styleTableBody(summary, "F15:H18");
summary.getRange("F15:H18").format.wrapText = true;

summary.getRange("A23").values = [["Nguồn file: plans/260923-1658-four-sprint-mvp-backlog/Ke-hoach-KhachSanDiDong-MSProject-2021.xml; detailed-task-breakdown.md; microsoft-project-import.csv; GitHub PR metadata tại thời điểm tạo register."]];
summary.getRange("A23:H23").merge();
summary.getRange("A23").format = { font: { name: font, size: 9, italic: true, color: "#666666" }, wrapText: true };

for (const [range, width] of [["A:A", 30], ["B:B", 14], ["C:C", 38], ["D:D", 14], ["E:E", 4], ["F:F", 25], ["G:G", 31], ["H:H", 35]]) {
  summary.getRange(range).format.columnWidth = width;
}
summary.getRange("A1:H25").format.font = { name: font, size: 10 };

// The normalized WBS evidence register.
register.getRange("A1").values = [["Task Register — 178 task lá theo WBS ID"]];
register.getRange("A1").format.font = { name: font, size: 15, bold: true, color: navy };
register.getRange("A2").values = [["Các ô vàng là input quản lý. Không chuyển sang Đã xong nếu chưa có URL evidence và evidence acceptance phù hợp."]];
register.getRange("A2").format = { fill: amber, font: { name: font, size: 10, bold: true, color: "#7F6000" } };
register.getRange("A3").values = [[`Baseline Status Date: ${data.project.status_date.slice(0, 10)} | 1 ngày chuẩn hóa = ${data.project.minutes_per_day / 60} giờ | XML PercentComplete không dùng làm actual progress.`]];
register.getRange("A3").format.font = { name: font, size: 9, italic: true, color: "#666666" };

const registerHeaders = [
  "WBS ID", "Outline", "Sprint", "Workstream", "Task Name", "Owner", "KT / Reviewer",
  "Reference Start", "Reference Finish", "Estimate (hours)", "Integer days", "Source Status",
  "Actual status", "Evidence level", "Acceptance required", "Deliverable", "Source evidence",
  "PR / commit URL", "Test / CI URL", "Acceptance / UAT URL", "Last verified", "Blocker / manager note",
];
register.getRange("A5:V5").values = [registerHeaders];
sectionHeader(register, "A5:V5");
const registerRows = data.rows.map((row) => [
  row.wbs_id, row.outline, row.sprint, row.workstream, row.task_name, row.owner || "Chưa gán", row.reviewer || "Chưa gán",
  asDate(row.start), asDate(row.finish), row.effort_hours, row.proposed_days, row.source_status,
  row.actual_status, row.evidence_level, acceptanceFor(row.wbs_id), row.deliverable, row.source_evidence || statusHint(row.source_status),
  "", "", "", null, "",
]);
register.getRange(`A6:V${5 + registerRows.length}`).values = registerRows;
styleTableBody(register, `A6:V${5 + registerRows.length}`);
register.getRange(`E6:E${5 + registerRows.length}`).format.wrapText = true;
register.getRange(`D6:G${5 + registerRows.length}`).format.wrapText = true;
register.getRange(`O6:Q${5 + registerRows.length}`).format.wrapText = true;
register.getRange(`V6:V${5 + registerRows.length}`).format.wrapText = true;
register.getRange(`H6:I${5 + registerRows.length}`).format.numberFormat = "dd/mm/yyyy";
register.getRange(`J6:K${5 + registerRows.length}`).format.numberFormat = "#,##0";
register.getRange(`U6:U${5 + registerRows.length}`).format.numberFormat = "dd/mm/yyyy";
register.getRange(`M6:N${5 + registerRows.length}`).format.fill = amber;
register.getRange(`R6:V${5 + registerRows.length}`).format.fill = amber;
register.getRange(`M6:V${5 + registerRows.length}`).format.font = { name: font, size: 10, color: "#1F1F1F" };
register.getRange(`A6:V${5 + registerRows.length}`).format.rowHeight = 34;
register.getRange(`A6:A${5 + registerRows.length}`).format.font = { name: font, size: 10, bold: true, color: navy };
register.getRange(`C6:C${5 + registerRows.length}`).format.horizontalAlignment = "center";
register.getRange(`H6:K${5 + registerRows.length}`).format.horizontalAlignment = "right";
register.getRange(`M6:N${5 + registerRows.length}`).format.horizontalAlignment = "center";
register.getRange(`U6:U${5 + registerRows.length}`).format.horizontalAlignment = "center";
register.getRange(`M6:M${5 + registerRows.length}`).dataValidation = {
  rule: { type: "list", values: ["Kế hoạch", "Cần đối chiếu", "Đang làm", "Chờ review", "Cần xác minh", "Bị chặn", "Đã xong"] },
};
register.getRange(`N6:N${5 + registerRows.length}`).dataValidation = {
  rule: { type: "list", values: ["Chưa có", "Tài liệu đã nêu", "Code", "Code + test/CI", "Reviewer approved", "UAT/sign-off"] },
};
register.getRange(`M6:M${5 + registerRows.length}`).conditionalFormats.add("containsText", { text: "Đã xong", format: { fill: paleGreen, font: { bold: true, color: "#006100" } } });
register.getRange(`M6:M${5 + registerRows.length}`).conditionalFormats.add("containsText", { text: "Cần đối chiếu", format: { fill: paleRed, font: { bold: true, color: "#9C0006" } } });
register.getRange(`M6:M${5 + registerRows.length}`).conditionalFormats.add("containsText", { text: "Cần xác minh", format: { fill: amber, font: { bold: true, color: "#7F6000" } } });
register.freezePanes.freezeRows(5);
register.freezePanes.freezeColumns(5);
for (const [range, width] of [
  ["A:A", 16], ["B:B", 12], ["C:C", 8], ["D:D", 24], ["E:E", 46], ["F:F", 15], ["G:G", 16],
  ["H:I", 14], ["J:K", 12], ["L:N", 17], ["O:O", 34], ["P:P", 36], ["Q:Q", 36],
  ["R:T", 31], ["U:U", 14], ["V:V", 34],
]) register.getRange(range).format.columnWidth = width;
register.tables.add(`A5:V${5 + registerRows.length}`, true, "EvidenceRegisterTable");

// PR evidence remains explicitly non-leaf-mapped until Phase 3.
prEvidence.getRange("A1").values = [["PR Evidence — lịch sử PR #34–#53"]];
prEvidence.getRange("A1").format.font = { name: font, size: 15, bold: true, color: navy };
prEvidence.getRange("A2").values = [["Danh sách này chỉ là evidence cấp PR. Chưa gắn PR vào task lá để tránh suy diễn phạm vi hoặc đánh dấu hoàn thành sai."]];
prEvidence.getRange("A2").format = { fill: paleBlue, font: { name: font, size: 10, bold: true, color: navy } };
const prHeaders = ["PR #", "Current title", "Proposed title (Phase 3)", "Merged at", "Base", "Evidence classification", "Potential workstream", "Mapping status", "URL"];
prEvidence.getRange("A5:I5").values = [prHeaders];
sectionHeader(prEvidence, "A5:I5");
const prRows = data.prs.map((pr) => [
  pr.number, pr.current_title, pr.proposed_title, asDate(pr.merged_at), pr.base, pr.evidence,
  (pr.proposed_title.match(/\[([^\]]+)\]/) || ["", ""])[1], pr.mapping_status, pr.url,
]);
prEvidence.getRange(`A6:I${5 + prRows.length}`).values = prRows;
styleTableBody(prEvidence, `A6:I${5 + prRows.length}`);
prEvidence.getRange(`B6:C${5 + prRows.length}`).format.wrapText = true;
prEvidence.getRange(`F6:H${5 + prRows.length}`).format.wrapText = true;
prEvidence.getRange(`D6:D${5 + prRows.length}`).format.numberFormat = "dd/mm/yyyy";
prEvidence.getRange(`H6:H${5 + prRows.length}`).format.fill = amber;
prEvidence.getRange(`A6:A${5 + prRows.length}`).format.font = { name: font, size: 10, bold: true, color: navy };
prEvidence.getRange(`A6:I${5 + prRows.length}`).format.rowHeight = 34;
prEvidence.freezePanes.freezeRows(5);
for (const [range, width] of [["A:A", 9], ["B:B", 37], ["C:C", 53], ["D:D", 14], ["E:E", 12], ["F:F", 29], ["G:G", 22], ["H:H", 27], ["I:I", 50]]) {
  prEvidence.getRange(range).format.columnWidth = width;
}
prEvidence.tables.add(`A5:I${5 + prRows.length}`, true, "PrEvidenceTable");

workbook.recalculate();

const inspections = [
  await workbook.inspect({ kind: "table", range: "Manager Summary!A2:H23", include: "values,formulas", tableMaxRows: 24, tableMaxCols: 8 }),
  await workbook.inspect({ kind: "table", range: "Task Register!A1:V12", include: "values,formulas", tableMaxRows: 12, tableMaxCols: 22 }),
  await workbook.inspect({ kind: "table", range: "PR Evidence!A1:I10", include: "values,formulas", tableMaxRows: 10, tableMaxCols: 9 }),
];
const formulaErrors = await workbook.inspect({
  kind: "match",
  searchTerm: "#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!|#NULL!|#SPILL!|#CALC!",
  options: { useRegex: true, maxResults: 300 },
  summary: "final formula error scan",
});

await fs.mkdir(previewDir, { recursive: true });
for (const [sheetName, range, fileName] of [
  ["Manager Summary", "A1:H23", "manager-summary.png"],
  ["Task Register", "A1:V20", "task-register.png"],
  ["PR Evidence", "A1:I25", "pr-evidence.png"],
]) {
  const preview = await workbook.render({ sheetName, range, scale: 1, format: "png" });
  await fs.writeFile(`${previewDir}/${fileName}`, new Uint8Array(await preview.arrayBuffer()));
}

await fs.mkdir(outputDir, { recursive: true });
const xlsx = await SpreadsheetFile.exportXlsx(workbook);
await xlsx.save(outputPath);

const reloaded = await SpreadsheetFile.importXlsx(await FileBlob.load(outputPath));
const savedCheck = await reloaded.inspect({ kind: "workbook,sheet,table", maxChars: 5000, tableMaxRows: 6, tableMaxCols: 8 });
console.log(JSON.stringify({
  inspections: inspections.map((item) => item.ndjson),
  formulaErrors: formulaErrors.ndjson,
  savedCheck: savedCheck.ndjson,
  outputPath,
}, null, 2));
