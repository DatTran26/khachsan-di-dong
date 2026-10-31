import fs from "node:fs/promises";
import { FileBlob, SpreadsheetFile } from "@oai/artifact-tool";

const root = "D:/Projects/KhachSanDiDong";
const inputPath = `${root}/outputs/evidence-register-261028-phase3/khach-san-di-dong-evidence-register.xlsx`;
const outputDir = `${root}/outputs/evidence-register-261028-phase4`;
const outputPath = `${outputDir}/khach-san-di-dong-evidence-register.xlsx`;
const previewDir = `${outputDir}/previews`;
const manifest = JSON.parse(await fs.readFile(`${root}/.codex-temp/pr-backfill-manifest.json`, "utf8"));
const projectItems = JSON.parse(await fs.readFile(`${root}/.codex-temp/wbs-project-items.json`, "utf8"));

const workbook = await SpreadsheetFile.importXlsx(await FileBlob.load(inputPath));
const summary = workbook.worksheets.getItem("Manager Summary");
const register = workbook.worksheets.getItem("Task Register");
const prEvidence = workbook.worksheets.getItem("PR Evidence");

summary.getRange("A12:C15").values = [
  ["PR lịch sử đã audit", manifest.length, "20 PR đã liên kết WBS Issue"],
  ["Giá trị Status CSV không hợp lệ", 31, "Đã tách khỏi dữ liệu tiến độ"],
  ["GitHub Project card", Object.keys(projectItems).length, "178 card: 32 Review, 146 Triage"],
  ["Project card Triage", 146, "Các task chưa có code/test/CI evidence phù hợp"],
];
summary.getRange("A12:C15").format.wrapText = true;
summary.getRange("B12:B15").format.font = { name: "Arial", size: 10, bold: true, color: "#1F4E78" };
summary.getRange("H18").values = [["WBS candidate đã liên kết tới Issue; acceptance vẫn phải kiểm tra riêng"]];

prEvidence.getRange("H6:H25").values = manifest.map(() => ["Mapped to canonical WBS Issues"]);
prEvidence.getRange("H6:H25").format.fill = "#E2F0D9";

register.getRange("W5:AA5").values = [[
  "Project Issue #", "Project Issue URL", "Project status", "Kanban", "Project sync date",
]];
const rows = register.getRange("A6:AA183").values;
for (const row of rows) {
  const project = projectItems[row[0]];
  if (!project) throw new Error(`No Project item for ${row[0]}`);
  row[22] = project.issue_number;
  row[23] = project.issue_url;
  row[24] = project.kanban === "Review" ? "In review" : "Backlog";
  row[25] = project.kanban;
  row[26] = new Date("2026-10-28T00:00:00");
}
register.getRange("A6:AA183").values = rows;
register.getRange("W5:AA5").format = {
  fill: "#1F4E78",
  font: { name: "Arial", size: 10, bold: true, color: "#FFFFFF" },
  horizontalAlignment: "center",
  verticalAlignment: "center",
  wrapText: true,
};
register.getRange("W6:AA183").format.fill = "#EAF3F8";
register.getRange("X6:X183").format.wrapText = true;
register.getRange("AA6:AA183").format.numberFormat = "dd/mm/yyyy";
register.getRange("W1:W183").format.columnWidth = 14;
register.getRange("X1:X183").format.columnWidth = 38;
register.getRange("Y1:Z183").format.columnWidth = 16;
register.getRange("AA1:AA183").format.columnWidth = 14;

workbook.recalculate();
const summaryCheck = await workbook.inspect({ kind: "table", range: "Manager Summary!A6:C20", include: "values,formulas", tableMaxRows: 15, tableMaxCols: 3 });
const registerCheck = await workbook.inspect({ kind: "table", range: "Task Register!W5:AA12", include: "values,formulas", tableMaxRows: 8, tableMaxCols: 5 });
const prCheck = await workbook.inspect({ kind: "table", range: "PR Evidence!A5:I10", include: "values,formulas", tableMaxRows: 6, tableMaxCols: 9 });
const errors = await workbook.inspect({ kind: "match", searchTerm: "#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!|#NULL!|#SPILL!|#CALC!", options: { useRegex: true, maxResults: 300 }, summary: "final formula error scan" });

await fs.mkdir(previewDir, { recursive: true });
for (const [sheetName, range, fileName] of [
  ["Manager Summary", "A1:H23", "manager-summary.png"],
  ["Task Register", "A1:AA20", "task-register.png"],
  ["PR Evidence", "A1:I25", "pr-evidence.png"],
]) {
  const preview = await workbook.render({ sheetName, range, scale: 1, format: "png" });
  await fs.writeFile(`${previewDir}/${fileName}`, new Uint8Array(await preview.arrayBuffer()));
}

await fs.mkdir(outputDir, { recursive: true });
const output = await SpreadsheetFile.exportXlsx(workbook);
await output.save(outputPath);
const reloaded = await SpreadsheetFile.importXlsx(await FileBlob.load(outputPath));
const savedCheck = await reloaded.inspect({ kind: "workbook,sheet,table", maxChars: 3500, tableMaxRows: 6, tableMaxCols: 10 });
console.log(JSON.stringify({
  summary: summaryCheck.ndjson,
  register: registerCheck.ndjson,
  prEvidence: prCheck.ndjson,
  errors: errors.ndjson,
  saved: savedCheck.ndjson,
}, null, 2));
