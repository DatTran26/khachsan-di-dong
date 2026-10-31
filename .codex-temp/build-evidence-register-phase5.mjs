import fs from "node:fs/promises";
import { FileBlob, SpreadsheetFile } from "@oai/artifact-tool";

const root = "D:/Projects/KhachSanDiDong";
const inputPath = `${root}/outputs/evidence-register-261028-phase4/khach-san-di-dong-evidence-register.xlsx`;
const outputDir = `${root}/outputs/evidence-register-261028-phase5`;
const outputPath = `${outputDir}/khach-san-di-dong-evidence-register.xlsx`;
const previewDir = `${outputDir}/previews`;
const allAudit = JSON.parse(await fs.readFile(`${root}/.codex-temp/all-historical-pr-audit.json`, "utf8"));
const legacy = JSON.parse(await fs.readFile(`${root}/.codex-temp/all-pr-task-backfill-manifest.json`, "utf8"));
const recent = JSON.parse(await fs.readFile(`${root}/.codex-temp/pr-backfill-manifest.json`, "utf8"));
const legacyByNumber = new Map(legacy.map((item) => [item.number, item]));
const recentByNumber = new Map(recent.map((item) => [item.number, item]));

const workbook = await SpreadsheetFile.importXlsx(await FileBlob.load(inputPath));
const summary = workbook.worksheets.getItem("Manager Summary");
summary.getRange("A12:C12").values = [["PR lịch sử đã audit", 53, "53 PR: 20 đã có WBS Issue; 33 dùng Task Name tổng hợp"]];

const auditSheet = workbook.worksheets.add("All PR Audit");
auditSheet.showGridLines = false;
auditSheet.getRange("A1:I1").merge();
auditSheet.getRange("A1").values = [["PR Audit — 53 historical pull requests"]];
auditSheet.getRange("A1").format = { font: { name: "Arial", size: 14, bold: true, color: "#1F4E78" }, verticalAlignment: "center" };
auditSheet.getRange("A2:I2").merge();
auditSheet.getRange("A2").values = [["Tên hiển thị phản ánh Task Name tổng hợp. PR lịch sử rộng không được tự suy diễn một WBS Issue cụ thể."]];
auditSheet.getRange("A2").format = { font: { name: "Arial", size: 10, italic: true, color: "#666666" } };
const headers = [["PR #", "State", "Base", "Current title", "Task name tổng hợp", "Evidence treatment", "WBS link status", "Mapping", "URL"]];
auditSheet.getRange("A4:I4").values = headers;
const rows = allAudit.map((pr) => {
  const legacyItem = legacyByNumber.get(pr.number);
  const recentItem = recentByNumber.get(pr.number);
  if (legacyItem) {
    return [pr.number, pr.state, pr.baseRefName, legacyItem.new_title, legacyItem.aggregate_task_name,
      legacyItem.evidence_treatment, "Aggregate only; exact WBS not asserted", "Backfilled title/body", pr.url];
  }
  return [pr.number, pr.state, pr.baseRefName, pr.title, `WBS candidates: ${recentItem.wbs_candidates.join(", ")}`,
    recentItem.classification, "Canonical WBS Issues linked", "Existing mapping reverified", pr.url];
});
auditSheet.getRange(`A5:I${4 + rows.length}`).values = rows;
auditSheet.getRange(`A4:I${4 + rows.length}`).format.font = { name: "Arial", size: 10, color: "#1F1F1F" };
auditSheet.getRange("A4:I4").format = { fill: "#1F4E78", font: { name: "Arial", size: 10, bold: true, color: "#FFFFFF" }, horizontalAlignment: "center", verticalAlignment: "center", wrapText: true };
auditSheet.getRange(`A5:I${4 + rows.length}`).format.verticalAlignment = "top";
auditSheet.getRange(`D5:I${4 + rows.length}`).format.wrapText = true;
auditSheet.getRange(`A5:C${4 + rows.length}`).format.horizontalAlignment = "center";
auditSheet.getRange(`A4:I${4 + rows.length}`).format.borders = { preset: "inside", style: "thin", color: "#D9E2F3" };
auditSheet.getRange(`A5:I${4 + rows.length}`).conditionalFormats.add("containsText", { text: "CLOSED", format: { fill: "#F2F2F2", font: { color: "#666666" } } });
auditSheet.getRange("A1:A57").format.columnWidth = 9;
auditSheet.getRange("B1:C57").format.columnWidth = 13;
auditSheet.getRange("D1:D57").format.columnWidth = 44;
auditSheet.getRange("E1:E57").format.columnWidth = 38;
auditSheet.getRange("F1:F57").format.columnWidth = 30;
auditSheet.getRange("G1:H57").format.columnWidth = 28;
auditSheet.getRange("I1:I57").format.columnWidth = 42;
auditSheet.getRange("A5:I57").format.rowHeight = 32;
auditSheet.freezePanes.freezeRows(4);
auditSheet.tables.add("A4:I57", true, "AllPrAuditTable").style = "TableStyleMedium2";

workbook.recalculate();
const summaryCheck = await workbook.inspect({ kind: "table", range: "Manager Summary!A6:C15", include: "values,formulas", tableMaxRows: 10, tableMaxCols: 3 });
const auditCheck = await workbook.inspect({ kind: "table", range: "All PR Audit!A1:I12", include: "values,formulas", tableMaxRows: 12, tableMaxCols: 9 });
const errors = await workbook.inspect({ kind: "match", searchTerm: "#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!|#NULL!|#SPILL!|#CALC!", options: { useRegex: true, maxResults: 300 }, summary: "final formula error scan" });

await fs.mkdir(previewDir, { recursive: true });
for (const [sheetName, range, fileName] of [["Manager Summary", "A1:H23", "manager-summary.png"], ["All PR Audit", "A1:I18", "all-pr-audit.png"]]) {
  const preview = await workbook.render({ sheetName, range, scale: 1, format: "png" });
  await fs.writeFile(`${previewDir}/${fileName}`, new Uint8Array(await preview.arrayBuffer()));
}

await fs.mkdir(outputDir, { recursive: true });
const output = await SpreadsheetFile.exportXlsx(workbook);
await output.save(outputPath);
const reloaded = await SpreadsheetFile.importXlsx(await FileBlob.load(outputPath));
const saved = await reloaded.inspect({ kind: "workbook,sheet,table", maxChars: 2500, tableMaxRows: 5, tableMaxCols: 9 });
console.log(JSON.stringify({ summary: summaryCheck.ndjson, audit: auditCheck.ndjson, errors: errors.ndjson, saved: saved.ndjson }, null, 2));
