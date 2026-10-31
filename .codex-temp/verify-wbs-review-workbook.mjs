import { FileBlob, SpreadsheetFile } from "@oai/artifact-tool";

const path = "D:/Projects/KhachSanDiDong/outputs/wbs-review-261027/khach-san-di-dong-wbs-task-name-review.xlsx";
const input = await FileBlob.load(path);
const workbook = await SpreadsheetFile.importXlsx(input);
const overview = await workbook.inspect({ kind: "sheet,table", maxChars: 3000, tableMaxRows: 4, tableMaxCols: 6 });
const cost = await workbook.inspect({
  kind: "table",
  range: "Chi phí nhân sự!A7:D13",
  include: "values,formulas",
  tableMaxRows: 7,
  tableMaxCols: 4,
});
const errors = await workbook.inspect({
  kind: "match",
  searchTerm: "#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!|#NULL!|#SPILL!|#CALC!",
  options: { useRegex: true, maxResults: 50 },
  summary: "saved workbook formula error scan",
});
console.log(overview.ndjson);
console.log(cost.ndjson);
console.log(errors.ndjson);
