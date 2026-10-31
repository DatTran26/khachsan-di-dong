import fs from "node:fs/promises";
import { FileBlob, SpreadsheetFile } from "@oai/artifact-tool";

const root = "D:/Projects/KhachSanDiDong";
const inputPath = `${root}/outputs/evidence-register-261028/khach-san-di-dong-evidence-register.xlsx`;
const outputDir = `${root}/outputs/evidence-register-261028-phase3`;
const outputPath = `${outputDir}/khach-san-di-dong-evidence-register.xlsx`;
const previewDir = `${outputDir}/previews`;
const manifest = JSON.parse(await fs.readFile(`${root}/.codex-temp/pr-backfill-manifest.json`, "utf8"));
const successChecks = {
  46: "https://github.com/DatTran26/khachsan-di-dong/actions/runs/38981730442/job/117243907592",
  52: "https://github.com/DatTran26/khachsan-di-dong/actions/runs/40381272375/job/121777833988",
  53: "https://github.com/DatTran26/khachsan-di-dong/actions/runs/40449667352/job/122009168540",
};
const evidenceRank = {
  "Chưa có": 0,
  "Tài liệu đã nêu": 1,
  "Code": 2,
  "Reviewer approved": 3,
  "Code + test/CI": 4,
  "UAT/sign-off": 5,
};

function evidenceFor(classification) {
  if (classification.includes("Code +")) return "Code + test/CI";
  if (classification.includes("Code only")) return "Code";
  if (classification.includes("Test source")) return "Code";
  if (classification.includes("CI configuration")) return "Code + test/CI";
  return "Tài liệu đã nêu";
}

function appendUnique(current, incoming) {
  const values = (current || "").split("\n").map((value) => value.trim()).filter(Boolean);
  if (!values.includes(incoming)) values.push(incoming);
  return values.join("\n");
}

const workbook = await SpreadsheetFile.importXlsx(await FileBlob.load(inputPath));
const summary = workbook.worksheets.getItem("Manager Summary");
const register = workbook.worksheets.getItem("Task Register");
const prEvidence = workbook.worksheets.getItem("PR Evidence");

// Preserve the register's layout and formulas. Only update content that Phase 3 owns.
summary.getRange("A12:C12").values = [["PR lịch sử đã audit", null, "20 PR có title/body chuẩn và WBS candidate; Issue links sẽ bổ sung sau"]];
summary.getRange("B12").formulas = [["=COUNTA('PR Evidence'!$A$6:$A$25)"]];
summary.getRange("C12").format.wrapText = true;
summary.getRange("H18").values = [["WBS candidate đã ghi; Issue links đang chờ"]];

prEvidence.getRange("A5:I5").values = [[
  "PR #", "Current title", "Previous title (snapshot)", "Merged at", "Base", "Evidence classification",
  "WBS task candidates", "Mapping status", "URL",
]];
const prRows = manifest.map((item) => [
  item.number,
  item.new_title,
  item.old_title,
  null,
  "develop",
  item.classification,
  item.wbs_candidates.join(", "),
  "WBS candidates recorded; Issue links pending",
  `https://github.com/DatTran26/khachsan-di-dong/pull/${item.number}`,
]);
const existingDates = prEvidence.getRange("D6:D25").values;
prRows.forEach((row, index) => { row[3] = existingDates[index][0]; });
prEvidence.getRange("A6:I25").values = prRows;
prEvidence.getRange("B6:C25").format.wrapText = true;
prEvidence.getRange("G6:H25").format.wrapText = true;
prEvidence.getRange("G6:G25").format.fill = "#EAF3F8";
prEvidence.getRange("H6:H25").format.fill = "#FFF2CC";

const dataRange = register.getRange("A6:V183");
const rows = dataRange.values;
const rowIndexByWbs = new Map(rows.map((row, index) => [row[0], index]));
for (const item of manifest) {
  const evidence = evidenceFor(item.classification);
  const prUrl = `#${item.number} https://github.com/DatTran26/khachsan-di-dong/pull/${item.number}`;
  for (const wbsId of item.wbs_candidates) {
    const index = rowIndexByWbs.get(wbsId);
    if (index === undefined) throw new Error(`Missing WBS ID in register: ${wbsId}`);
    const row = rows[index];
    row[17] = appendUnique(row[17], prUrl);
    if (successChecks[item.number]) row[18] = appendUnique(row[18], `#${item.number} App CI success ${successChecks[item.number]}`);
    if ((evidenceRank[evidence] || 0) > (evidenceRank[row[13]] || 0)) row[13] = evidence;
    row[20] = new Date("2026-10-28T00:00:00");
    row[21] = appendUnique(row[21], "PR evidence mapped as candidate; reviewer/acceptance evidence still required.");
  }
}
dataRange.values = rows;
register.getRange("U6:U183").format.numberFormat = "dd/mm/yyyy";
register.getRange("R6:V183").format.wrapText = true;
register.getRange("R6:V183").format.fill = "#FFF2CC";
register.getRange("R6:T183").format.font = { name: "Arial", size: 10, color: "#1F1F1F" };

workbook.recalculate();
const summaryCheck = await workbook.inspect({ kind: "table", range: "Manager Summary!A6:C13", include: "values,formulas", tableMaxRows: 8, tableMaxCols: 3 });
const registerCheck = await workbook.inspect({ kind: "table", range: "Task Register!A5:V12", include: "values,formulas", tableMaxRows: 8, tableMaxCols: 22 });
const prCheck = await workbook.inspect({ kind: "table", range: "PR Evidence!A5:I10", include: "values,formulas", tableMaxRows: 6, tableMaxCols: 9 });
const errors = await workbook.inspect({ kind: "match", searchTerm: "#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!|#NULL!|#SPILL!|#CALC!", options: { useRegex: true, maxResults: 300 }, summary: "final formula error scan" });

await fs.mkdir(previewDir, { recursive: true });
for (const [sheetName, range, fileName] of [
  ["Manager Summary", "A1:H23", "manager-summary.png"],
  ["Task Register", "A1:V20", "task-register.png"],
  ["PR Evidence", "A1:I25", "pr-evidence.png"],
]) {
  const preview = await workbook.render({ sheetName, range, scale: 1, format: "png" });
  await fs.writeFile(`${previewDir}/${fileName}`, new Uint8Array(await preview.arrayBuffer()));
}

const output = await SpreadsheetFile.exportXlsx(workbook);
await fs.mkdir(outputDir, { recursive: true });
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
