import fs from "node:fs/promises";
import { FileBlob, SpreadsheetFile, Workbook } from "@oai/artifact-tool";

const baseDir = "D:/Projects/KhachSanDiDong/plans/260923-1658-four-sprint-mvp-backlog";
const csvPath = `${baseDir}/microsoft-project-import.csv`;
const outputPath = `${baseDir}/microsoft-project-import-2021-wpc.xlsx`;

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
    } else if (char === ',' && !inQuotes) {
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

const csvText = await fs.readFile(csvPath, "utf8");
const source = parseCsv(csvText);
const headers = source[0];
const projectResourceNames = {
  "Tấn Đạt": "Đạt",
  "Ngọc Hoàng": "Hoàng",
  "Bảo": "Bảo",
};
// The values below are WBS keys, not fixed Project IDs. They are converted to
// the row-based IDs required by Project's Predecessors field at export time.
const dependencyWbs = {
  "S1-DAT-018": ["S1-DAT-017"],
  "S1-DAT-019": ["S1-DAT-018"], "S1-DAT-020": ["S1-DAT-018"], "S1-DAT-021": ["S1-DAT-018"], "S1-DAT-022": ["S1-DAT-018"],
  "S1-DAT-023": ["S1-DAT-017"],
  "S1-DAT-024": ["S1-DAT-019"], "S1-DAT-025": ["S1-DAT-020"], "S1-DAT-026": ["S1-DAT-021"], "S1-DAT-027": ["S1-DAT-022"],
  "S1-DAT-028": ["S1-DAT-023"],
  "S1-DAT-029": ["S1-DAT-024", "S1-DAT-025", "S1-DAT-026", "S1-DAT-027", "S1-DAT-028"],
  "S1-DAT-030": ["S1-DAT-029"], "S1-DAT-031": ["S1-DAT-029"], "S1-DAT-032": ["S1-DAT-029"],
  "S1-DAT-033": ["S1-DAT-031", "S1-DAT-032"], "S1-DAT-034": ["S1-DAT-029"],
  "S1-DAT-035": ["S1-DAT-030", "S1-DAT-031", "S1-DAT-032", "S1-DAT-033", "S1-DAT-034"], "S1-DAT-036": ["S1-DAT-035"],
  "S1-HOANG-016": ["S1-DAT-017"], "S1-HOANG-017": ["S1-DAT-024", "S1-DAT-025", "S1-DAT-026", "S1-DAT-027"],
  "S1-HOANG-018": ["S1-HOANG-017"], "S1-HOANG-019": ["S1-DAT-030"], "S1-HOANG-020": ["S1-HOANG-017"],
  "S1-BAO-021": ["S1-DAT-032"], "S1-BAO-022": ["S1-DAT-032"], "S1-BAO-023": ["S1-DAT-032"],
  "S1-DAT-002": ["S1-DAT-001"], "S1-DAT-003": ["S1-DAT-002"], "S1-DAT-004": ["S1-DAT-003"],
  "S1-DAT-007": ["S1-DAT-004"], "S1-DAT-008": ["S1-DAT-002"], "S1-DAT-009": ["S1-DAT-008"], "S1-DAT-010": ["S1-DAT-008"],
  "S1-DAT-011": ["S1-DAT-005"], "S1-DAT-012": ["S1-DAT-007"], "S1-DAT-013": ["S1-DAT-006"],
  "S1-DAT-014": ["S1-DAT-004"], "S1-DAT-015": ["S1-DAT-009"], "S1-DAT-016": ["S1-DAT-012"],
  "S1-BAO-002": ["S1-BAO-001"], "S1-BAO-003": ["S1-BAO-001"], "S1-BAO-004": ["S1-BAO-001"],
  "S1-BAO-005": ["S1-BAO-004"], "S1-BAO-006": ["S1-BAO-004"], "S1-BAO-007": ["S1-BAO-004"], "S1-BAO-008": ["S1-BAO-005"],
  "S1-BAO-009": ["S1-BAO-008"], "S1-BAO-010": ["S1-BAO-009"], "S1-BAO-011": ["S1-BAO-010"],
  "S1-BAO-012": ["S1-BAO-006", "S1-BAO-011"], "S1-BAO-013": ["S1-BAO-006", "S1-BAO-011"], "S1-BAO-014": ["S1-BAO-001"],
  "S1-BAO-015": ["S1-BAO-012", "S1-BAO-013", "S1-BAO-014"], "S1-BAO-016": ["S1-BAO-001"], "S1-BAO-017": ["S1-BAO-001"],
  "S1-BAO-018": ["S1-BAO-004"], "S1-BAO-019": ["S1-BAO-009"], "S1-BAO-020": ["S1-BAO-012"],
  "S1-HOANG-002": ["S1-HOANG-001"], "S1-HOANG-003": ["S1-DAT-006"], "S1-HOANG-004": ["S1-HOANG-002"],
  "S1-HOANG-005": ["S1-HOANG-002", "S1-HOANG-003"], "S1-HOANG-006": ["S1-HOANG-005", "S1-BAO-009"],
  "S1-HOANG-007": ["S1-HOANG-004", "S1-BAO-012"], "S1-HOANG-008": ["S1-HOANG-007", "S1-BAO-013"],
  "S1-HOANG-009": ["S1-HOANG-004", "S1-BAO-014"], "S1-HOANG-010": ["S1-HOANG-009"],
  "S1-HOANG-011": ["S1-HOANG-005", "S1-HOANG-007", "S1-HOANG-008", "S1-HOANG-009", "S1-HOANG-010"],
  "S1-HOANG-012": ["S1-HOANG-003"], "S1-HOANG-013": ["S1-HOANG-007"], "S1-HOANG-014": ["S1-HOANG-005"], "S1-HOANG-015": ["S1-HOANG-011"],
  "S2-DAT-005": ["S1-DAT-036", "S1-BAO-015"], "S2-DAT-006": ["S2-DAT-005"], "S2-DAT-007": ["S2-DAT-005"],
  "S2-DAT-008": ["S2-DAT-005"], "S2-DAT-009": ["S2-DAT-005"], "S2-DAT-010": ["S2-DAT-006"],
  "S2-BAO-001": ["S2-DAT-005"], "S2-BAO-002": ["S2-DAT-005"], "S2-BAO-003": ["S2-DAT-005"], "S2-BAO-004": ["S2-DAT-005"],
  "S2-BAO-005": ["S2-BAO-001"], "S2-BAO-006": ["S2-BAO-005"], "S2-BAO-007": ["S2-BAO-006"],
  "S2-BAO-008": ["S2-BAO-002"], "S2-BAO-009": ["S2-BAO-002", "S2-BAO-008"], "S2-BAO-010": ["S2-BAO-003"], "S2-BAO-011": ["S2-BAO-010"],
  "S2-BAO-012": ["S2-BAO-004"], "S2-BAO-013": ["S2-BAO-006", "S2-BAO-007", "S2-BAO-009", "S2-BAO-011", "S2-BAO-012"],
  "S2-BAO-014": ["S2-BAO-013"], "S2-BAO-015": ["S2-BAO-007"], "S2-BAO-016": ["S2-BAO-006", "S2-BAO-009"], "S2-BAO-017": ["S2-BAO-012"], "S2-BAO-018": ["S2-BAO-009", "S2-BAO-011"], "S2-BAO-019": ["S2-BAO-014"],
  "S2-HOANG-001": ["S1-HOANG-015", "S2-BAO-006"], "S2-HOANG-002": ["S2-HOANG-001", "S2-BAO-007"],
  "S2-HOANG-003": ["S2-BAO-009"], "S2-HOANG-004": ["S2-HOANG-003"], "S2-HOANG-005": ["S2-HOANG-004"],
  "S2-HOANG-006": ["S2-BAO-010"], "S2-HOANG-007": ["S2-HOANG-006", "S2-BAO-011"], "S2-HOANG-008": ["S2-BAO-012"],
  "S2-HOANG-009": ["S1-HOANG-010", "S2-BAO-013"], "S2-HOANG-010": ["S2-HOANG-001", "S2-HOANG-002", "S2-HOANG-005", "S2-HOANG-007", "S2-HOANG-008", "S2-HOANG-009", "S2-BAO-014"],
  "S2-HOANG-011": ["S2-HOANG-001"], "S2-HOANG-012": ["S2-HOANG-003"], "S2-HOANG-013": ["S2-HOANG-009"], "S2-HOANG-014": ["S2-HOANG-010"],
  "S3-DAT-002": ["S2-BAO-014"], "S3-DAT-004": ["S3-DAT-003"], "S3-DAT-005": ["S2-HOANG-010"], "S3-DAT-006": ["S3-DAT-003", "S3-DAT-004"], "S3-DAT-007": ["S3-DAT-003"],
  "S3-BAO-001": ["S3-DAT-001", "S3-DAT-002"], "S3-BAO-002": ["S3-BAO-001"], "S3-BAO-003": ["S3-BAO-001"],
  "S3-BAO-004": ["S3-DAT-003", "S3-BAO-001"], "S3-BAO-005": ["S3-DAT-003"], "S3-BAO-006": ["S3-BAO-005"],
  "S3-BAO-007": ["S3-BAO-005", "S3-BAO-006"], "S3-BAO-008": ["S3-BAO-007"], "S3-BAO-009": ["S3-BAO-008"],
  "S3-BAO-010": ["S3-BAO-001"], "S3-BAO-011": ["S3-BAO-005"], "S3-BAO-012": ["S3-BAO-007"], "S3-BAO-013": ["S3-BAO-009"],
  "S3-HOANG-001": ["S3-DAT-001", "S3-BAO-001"], "S3-HOANG-002": ["S3-HOANG-001"], "S3-HOANG-003": ["S3-HOANG-001", "S3-BAO-010"],
  "S3-HOANG-004": ["S3-HOANG-001", "S3-BAO-003"], "S3-HOANG-005": ["S3-BAO-008"], "S3-HOANG-006": ["S3-HOANG-005", "S3-BAO-007"],
  "S3-HOANG-007": ["S3-HOANG-002", "S3-HOANG-003", "S3-HOANG-004", "S3-HOANG-006"], "S3-HOANG-008": ["S3-HOANG-007", "S3-BAO-009"],
  "S3-HOANG-009": ["S3-HOANG-001"], "S3-HOANG-010": ["S3-HOANG-001"], "S3-HOANG-011": ["S3-HOANG-002"], "S3-HOANG-012": ["S3-HOANG-006"],
  "S4-DAT-002": ["S4-DAT-001"], "S4-DAT-003": ["S4-DAT-001"], "S4-DAT-004": ["S4-DAT-003"], "S4-DAT-005": ["S4-DAT-002", "S4-DAT-004"],
  "S4-DAT-006": ["S4-DAT-005"], "S4-DAT-007": ["S4-DAT-001"], "S4-DAT-008": ["S4-DAT-004"],
  "S4-BAO-001": ["S2-HOANG-014", "S3-HOANG-008"], "S4-BAO-002": ["S4-DAT-004"], "S4-BAO-003": ["S4-BAO-001"],
  "S4-BAO-004": ["S4-BAO-002", "S4-BAO-003"], "S4-BAO-005": ["S4-BAO-004"], "S4-BAO-006": ["S4-DAT-002"], "S4-BAO-007": ["S4-BAO-002"], "S4-BAO-008": ["S4-BAO-004"],
  "S4-HOANG-001": ["S3-HOANG-008"], "S4-HOANG-002": ["S4-HOANG-001"], "S4-HOANG-003": ["S4-HOANG-001"], "S4-HOANG-004": ["S4-HOANG-002", "S4-HOANG-003"],
  "S4-HOANG-005": ["S4-HOANG-004", "S4-BAO-004"], "S4-HOANG-006": ["S4-HOANG-004"], "S4-HOANG-007": ["S4-BAO-005"], "S4-HOANG-008": ["S4-HOANG-005", "S4-HOANG-007"],
};
const taskIdByWbs = new Map(source.slice(1).map((row, index) => [row[0], index + 1]));
function predecessorsFor(wbsId) {
  const dependencies = dependencyWbs[wbsId] ?? [];
  return dependencies.map((dependency) => {
    const taskId = taskIdByWbs.get(dependency);
    if (!taskId) throw new Error(`Unknown predecessor WBS ID: ${dependency}`);
    return `${taskId}FS`;
  }).join(",");
}
const outputHeaders = [...headers, "Predecessors"];
const rows = source.slice(1).map((row) => [
  row[0],
  row[1],
  row[2],
  new Date(`${row[3]}T00:00:00`),
  new Date(`${row[4]}T00:00:00`),
  row[5],
  projectResourceNames[row[6]] ?? row[6],
  row[2] === "S3" || row[2] === "S4" ? "Kế hoạch" : row[7],
  row[8],
  predecessorsFor(row[0]),
]);

const workbook = Workbook.create();
const sheet = workbook.worksheets.add("Tasks");
sheet.getRangeByIndexes(0, 0, 1, outputHeaders.length).values = [outputHeaders];
sheet.getRangeByIndexes(1, 0, rows.length, outputHeaders.length).values = rows;
const table = sheet.tables.add(`A1:J${rows.length + 1}`, true, "ProjectTasks");
table.style = "TableStyleMedium2";
sheet.freezePanes.freezeRows(1);
sheet.getRange(`D2:E${rows.length + 1}`).format.numberFormat = "dd/mm/yyyy";
sheet.getRange(`A1:J${rows.length + 1}`).format.font = { name: "Arial", size: 10 };
sheet.getRange("A:A").format.columnWidth = 16;
sheet.getRange("B:B").format.columnWidth = 54;
sheet.getRange("C:C").format.columnWidth = 10;
sheet.getRange("D:E").format.columnWidth = 18;
sheet.getRange("F:F").format.columnWidth = 12;
sheet.getRange("G:G").format.columnWidth = 18;
sheet.getRange("H:H").format.columnWidth = 22;
sheet.getRange("I:I").format.columnWidth = 18;
sheet.getRange("J:J").format.columnWidth = 24;
sheet.getRange(`A2:J${rows.length + 1}`).format.verticalAlignment = "center";
sheet.getRange(`B2:B${rows.length + 1}`).format.wrapText = true;
sheet.getRange(`A1:J${rows.length + 1}`).format.borders = { preset: "all", style: "thin", color: "#D9E2F3" };
sheet.getRange(`H2:H${rows.length + 1}`).conditionalFormats.add("containsText", {
  text: "Đã xong",
  format: { fill: "#E2F0D9", font: { color: "#375623" } },
});
sheet.getRange(`H2:H${rows.length + 1}`).conditionalFormats.add("containsText", {
  text: "Cần đối chiếu",
  format: { fill: "#FFF2CC", font: { color: "#7F6000" } },
});
const resourceSheet = workbook.worksheets.add("Resources");
const resourceHeaders = [
  "Resource Name",
  "Type",
  "Max Units",
  "Base Calendar",
  "Group",
  "Code",
  "Role Description",
  "Capacity Hours per Week",
];
const resourceRows = [
  ["Đạt", "Work", 1, "Lịch Khách Sạn", "WPC", "Đ", "PO, BA, PM, System Architect/Tech Lead, DevOps", 20],
  ["Hoàng", "Work", 1, "Lịch Khách Sạn", "WPC", "H", "UI/UX Designer, Frontend Developer, Tester/QA", 20],
  ["Bảo", "Work", 1, "Lịch Khách Sạn", "WPC", "B", "Backend Developer, Mobile Developer", 20],
];
resourceSheet.getRangeByIndexes(0, 0, 1, resourceHeaders.length).values = [resourceHeaders];
resourceSheet.getRangeByIndexes(1, 0, resourceRows.length, resourceHeaders.length).values = resourceRows;
const resourceTable = resourceSheet.tables.add("A1:H4", true, "ProjectResources");
resourceTable.style = "TableStyleMedium2";
resourceSheet.freezePanes.freezeRows(1);
resourceSheet.getRange("C2:C4").format.numberFormat = "0%";
resourceSheet.getRange("H2:H4").format.numberFormat = "0";
resourceSheet.getRange("A1:H4").format.font = { name: "Arial", size: 10 };
resourceSheet.getRange("A:A").format.columnWidth = 18;
resourceSheet.getRange("B:B").format.columnWidth = 12;
resourceSheet.getRange("C:C").format.columnWidth = 12;
resourceSheet.getRange("D:D").format.columnWidth = 16;
resourceSheet.getRange("E:E").format.columnWidth = 14;
resourceSheet.getRange("F:F").format.columnWidth = 12;
resourceSheet.getRange("G:G").format.columnWidth = 54;
resourceSheet.getRange("H:H").format.columnWidth = 22;
resourceSheet.getRange("G2:G4").format.wrapText = true;
resourceSheet.getRange("A1:H4").format.borders = { preset: "all", style: "thin", color: "#D9E2F3" };
workbook.recalculate();
const check = await workbook.inspect({
  kind: "table",
  range: "Tasks!A1:J4",
  include: "values",
  tableMaxRows: 4,
  tableMaxCols: 10,
});
if (!check.ndjson.includes("Xác định sponsor")) throw new Error("Unicode verification failed");
const image = await workbook.render({ sheetName: "Tasks", range: "A1:J12", scale: 1.2, format: "png" });
await fs.writeFile(`${baseDir}/microsoft-project-import-2021-preview.png`, new Uint8Array(await image.arrayBuffer()));
const resourceImage = await workbook.render({ sheetName: "Resources", range: "A1:H4", scale: 1.2, format: "png" });
await fs.writeFile(`${baseDir}/microsoft-project-resources-2021-preview.png`, new Uint8Array(await resourceImage.arrayBuffer()));
const output = await SpreadsheetFile.exportXlsx(workbook);
await output.save(outputPath);
const savedWorkbook = await SpreadsheetFile.importXlsx(await FileBlob.load(outputPath));
const savedCheck = await savedWorkbook.inspect({
  kind: "table",
  range: "Tasks!A1:J3",
  include: "values",
  tableMaxRows: 3,
  tableMaxCols: 10,
});
if (!savedCheck.ndjson.includes("Xác định sponsor")) throw new Error("Saved workbook Unicode verification failed");
if (!savedCheck.ndjson.includes("1FS")) throw new Error("Saved workbook predecessor verification failed");
const savedResourceCheck = await savedWorkbook.inspect({
  kind: "table",
  range: "Resources!A1:H4",
  include: "values",
  tableMaxRows: 4,
  tableMaxCols: 8,
});
if (!savedResourceCheck.ndjson.includes("Hoàng")) throw new Error("Saved resource sheet verification failed");
console.log(JSON.stringify({ outputPath, taskCount: rows.length }));
