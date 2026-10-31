import fs from "node:fs/promises";
import { SpreadsheetFile, Workbook } from "@oai/artifact-tool";

const dataPath = "D:/Projects/KhachSanDiDong/.codex-temp/wbs-review-data.json";
const outputDir = "D:/Projects/KhachSanDiDong/outputs/wbs-review-261027";
const outputPath = `${outputDir}/khach-san-di-dong-wbs-task-name-review.xlsx`;
const source = JSON.parse(await fs.readFile(dataPath, "utf8"));

const font = "Arial";
const navy = "#1F4E78";
const blue = "#D9EAF7";
const paleBlue = "#EAF2F8";
const amber = "#FFF2CC";
const redFill = "#FCE4D6";
const redText = "#C00000";
const lightBorder = "#D9E2F3";
const darkText = "#1F2937";
const dataStartRow = 7;
const dataEndRow = dataStartRow + source.rows.length - 1;

function parseDate(value) {
  return value ? new Date(value) : null;
}

const workbook = Workbook.create();
const taskSheet = workbook.worksheets.add("WBS Review");
const costSheet = workbook.worksheets.add("Chi phí nhân sự");
taskSheet.tabColor = navy;
costSheet.tabColor = "#5B9BD5";
taskSheet.showGridLines = false;
costSheet.showGridLines = false;

taskSheet.getRange("A2").values = [["Đề xuất WBS và Task Name — Khách Sạn Di Động"]];
taskSheet.getRange("A2").format.font = { name: font, size: 15, bold: true, color: navy };
taskSheet.getRange("A3").values = [["Dùng để kiểm duyệt trước khi sửa file MPP. Ô vàng là phần được phép điều chỉnh trực tiếp."]];
taskSheet.getRange("A3").format.font = { name: font, size: 10, italic: true, color: "#5B6573" };
taskSheet.getRange("A4").values = [["Quy ước duration: Task > 0 giờ → làm tròn lên số ngày nguyên theo 8 giờ/ngày; Milestone = 0 ngày; dòng tổng hợp tự tính từ task con."]];
taskSheet.getRange("A4").format.font = { name: font, size: 10, italic: true, color: "#5B6573" };
taskSheet.getRange("A4:O4").format.borders = { bottom: { style: "thin", color: navy } };

taskSheet.getRange("K2:L5").values = [
  ["Hạng mục", "Số lượng"],
  ["Task chi tiết", source.rows.filter((row) => row.type === "Task").length],
  ["Dòng tổng hợp", source.rows.filter((row) => row.type === "Tổng hợp").length],
  ["Milestone", source.rows.filter((row) => row.type === "Milestone").length],
];
taskSheet.getRange("K2:L2").format = { fill: navy, font: { name: font, bold: true, color: "#FFFFFF" } };
taskSheet.getRange("K2:L5").format.borders = { preset: "outside", style: "thin", color: lightBorder };
taskSheet.getRange("K3:L5").format.font = { name: font, size: 10, color: darkText };

const headers = [[
  "WBS",
  "Loại",
  "Cấp",
  "Task Name hiện tại",
  "Task Name đề xuất",
  "Kết quả hoàn thành",
  "Phụ trách",
  "Gốc (giờ)",
  "Mới (ngày)",
  "Nhập vào MPP",
  "Bắt đầu tham chiếu",
  "Kết thúc tham chiếu",
  "Predecessor",
  "Điều chỉnh lịch",
  "Ghi chú review",
]];
taskSheet.getRange("A6:O6").values = headers;
taskSheet.getRange("A6:O6").format = {
  fill: navy,
  font: { name: font, size: 10, bold: true, color: "#FFFFFF" },
  horizontalAlignment: "center",
  verticalAlignment: "center",
  wrapText: true,
  borders: { preset: "all", style: "thin", color: "#FFFFFF" },
};
taskSheet.getRange("A6:O6").format.rowHeight = 30;

const taskValues = source.rows.map((row) => [
  row.wbs,
  row.type,
  row.level,
  row.current_name,
  row.proposed_name,
  row.deliverable || "",
  row.resources || "",
  row.original_hours || 0,
  row.proposed_days,
  row.mpp_duration,
  parseDate(row.start),
  parseDate(row.finish),
  row.predecessors || "",
  row.schedule_action,
  "",
]);
taskSheet.getRange(`A${dataStartRow}:O${dataEndRow}`).values = taskValues;
taskSheet.getRange(`A${dataStartRow}:O${dataEndRow}`).format.font = { name: font, size: 10, color: darkText };
taskSheet.getRange(`A${dataStartRow}:O${dataEndRow}`).format.verticalAlignment = "center";
taskSheet.getRange(`A${dataStartRow}:O${dataEndRow}`).format.wrapText = true;
taskSheet.getRange(`A${dataStartRow}:O${dataEndRow}`).format.rowHeight = 34;
taskSheet.getRange(`H${dataStartRow}:H${dataEndRow}`).format.numberFormat = "0.0";
taskSheet.getRange(`I${dataStartRow}:I${dataEndRow}`).format.numberFormat = "0";
taskSheet.getRange(`K${dataStartRow}:L${dataEndRow}`).format.numberFormat = "dd/mm/yyyy";

taskSheet.getRange(`E${dataStartRow}:E${dataEndRow}`).format.fill = amber;
taskSheet.getRange(`I${dataStartRow}:I${dataEndRow}`).format.fill = amber;
taskSheet.getRange(`O${dataStartRow}:O${dataEndRow}`).format.fill = amber;

for (let index = 0; index < source.rows.length; index += 1) {
  const row = source.rows[index];
  const excelRow = dataStartRow + index;
  const range = taskSheet.getRange(`A${excelRow}:O${excelRow}`);
  if (row.type === "Tổng hợp") {
    if (row.level === 1) {
      range.format = { fill: navy, font: { name: font, size: 10, bold: true, color: "#FFFFFF" } };
    } else if (row.level === 2) {
      range.format = { fill: blue, font: { name: font, size: 10, bold: true, color: navy } };
    } else {
      range.format = { fill: paleBlue, font: { name: font, size: 10, bold: true, color: darkText } };
    }
  } else if (row.type === "Milestone") {
    range.format = { fill: redFill, font: { name: font, size: 10, bold: true, color: redText } };
  }
}

taskSheet.getRange(`A${dataStartRow}:O${dataEndRow}`).format.borders = {
  insideHorizontal: { style: "thin", color: "#E7EDF5" },
  bottom: { style: "thin", color: "#B8C6D9" },
};

taskSheet.getRange(`I${dataStartRow}:I${dataEndRow}`).dataValidation = {
  rule: { type: "whole", operator: "between", formula1: 0, formula2: 60 },
};

taskSheet.getRange("A:A").format.columnWidth = 12;
taskSheet.getRange("B:B").format.columnWidth = 13;
taskSheet.getRange("C:C").format.columnWidth = 7;
taskSheet.getRange("D:D").format.columnWidth = 38;
taskSheet.getRange("E:E").format.columnWidth = 40;
taskSheet.getRange("F:F").format.columnWidth = 30;
taskSheet.getRange("G:G").format.columnWidth = 15;
taskSheet.getRange("H:I").format.columnWidth = 11;
taskSheet.getRange("J:J").format.columnWidth = 20;
taskSheet.getRange("K:L").format.columnWidth = 15;
taskSheet.getRange("M:M").format.columnWidth = 18;
taskSheet.getRange("N:N").format.columnWidth = 28;
taskSheet.getRange("O:O").format.columnWidth = 28;
taskSheet.freezePanes.freezeRows(6);
taskSheet.freezePanes.freezeColumns(3);

const taskTable = taskSheet.tables.add(`A6:O${dataEndRow}`, true, "TaskNameReviewTable");
taskTable.style = "TableStyleLight1";

costSheet.getRange("A2").values = [["Chi phí nhân sự dự kiến — 03 kỹ sư giàu kinh nghiệm"]];
costSheet.getRange("A2").format.font = { name: font, size: 15, bold: true, color: navy };
costSheet.getRange("A3").values = [["Chỉ tính lương gross. Không cộng hạ tầng, thiết bị, dịch vụ cloud, API, domain, thưởng hoặc chi phí quản lý."]];
costSheet.getRange("A3").format.font = { name: font, size: 10, italic: true, color: "#5B6573" };
costSheet.getRange("A4:D4").format.borders = { bottom: { style: "thin", color: navy } };

costSheet.getRange("A6:D6").values = [["Hạng mục", "Giá trị", "Đơn vị", "Giải thích"]];
costSheet.getRange("A6:D6").format = {
  fill: navy,
  font: { name: font, size: 10, bold: true, color: "#FFFFFF" },
  horizontalAlignment: "center",
  verticalAlignment: "center",
  borders: { preset: "all", style: "thin", color: "#FFFFFF" },
};
costSheet.getRange("A7:D13").values = [
  ["Số kỹ sư", 3, "người", "Nhóm gồm ba kỹ sư có kinh nghiệm lâu năm."],
  ["Lương gross / kỹ sư / tháng", 50000000, "VND", "Giả định để kiểm duyệt. Có thể sửa theo mức đã chốt với nhân sự."],
  ["Ngày công quy đổi / tháng", 20, "ngày", "Dùng để quy đổi chi phí theo ngày công."],
  ["Thời lượng lịch dự án sau quy đổi", 42, "ngày", "41,88 ngày trong MPP được làm tròn lên 42 ngày theo quy ước số nguyên."],
  ["Đơn giá / kỹ sư / ngày", null, "VND/ngày", "Lương gross tháng ÷ ngày công quy đổi."],
  ["Đơn giá nhóm / ngày", null, "VND/ngày", "Số kỹ sư × đơn giá / kỹ sư / ngày."],
  ["Tổng chi phí nhân sự theo lịch", null, "VND", "Thời lượng lịch quy đổi × đơn giá nhóm / ngày."],
];
costSheet.getRange("B11").formulas = [["=B8/B9"]];
costSheet.getRange("B12").formulas = [["=B7*B11"]];
costSheet.getRange("B13").formulas = [["=B10*B12"]];
costSheet.getRange("A7:D13").format.font = { name: font, size: 10, color: darkText };
costSheet.getRange("A7:D13").format.verticalAlignment = "center";
costSheet.getRange("A7:D13").format.wrapText = true;
costSheet.getRange("A7:D13").format.rowHeight = 28;
costSheet.getRange("B7:B10").format.fill = amber;
costSheet.getRange("B11:B13").format.fill = paleBlue;
costSheet.getRange("A13:D13").format.font = { name: font, size: 10, bold: true, color: navy };
costSheet.getRange("A6:D13").format.borders = { preset: "outside", style: "thin", color: lightBorder };
costSheet.getRange("B8").format.numberFormat = "#,##0";
costSheet.getRange("B11:B13").format.numberFormat = "#,##0";

costSheet.getRange("B7").dataValidation = { rule: { type: "whole", operator: "between", formula1: 1, formula2: 20 } };
costSheet.getRange("B8").dataValidation = { rule: { type: "decimal", operator: "greaterThan", formula1: 0 } };
costSheet.getRange("B9").dataValidation = { rule: { type: "whole", operator: "between", formula1: 1, formula2: 31 } };
costSheet.getRange("B10").dataValidation = { rule: { type: "whole", operator: "between", formula1: 1, formula2: 365 } };

costSheet.getRange("A15:D15").values = [["Phạm vi loại trừ", "Không cộng vào tổng", "", "Thiết bị, máy chủ, cloud, API AI, domain, Internet, bản quyền, chi phí employer-side, thưởng, quản lý và vận hành."]];
costSheet.getRange("A15:D15").format = { fill: "#F3F4F6", font: { name: font, size: 10, color: darkText }, wrapText: true };
costSheet.getRange("A15:D15").format.rowHeight = 32;

costSheet.getRange("A18:D20").values = [
  ["Nguồn tham chiếu lương", "Phạm vi", "Ghi chú", "Liên kết"],
  ["NodeFlair Vietnam Salary Report 2025", "Senior Software Engineer", "Dùng để đặt giả định thận trọng, không phải báo giá tuyển dụng.", "https://nodeflair.com/salaries/report-2025.pdf"],
  ["Adecco Vietnam Salary Guide 2026", "Software Engineer 5+ năm", "Dải lương thay đổi theo thành phố, vai trò và doanh nghiệp.", "https://www.adecco.com/-/jssmedia/project/adecco/adeccovn/pdf/adecco-vietnam-salary-guide-2026.pdf"],
];
costSheet.getRange("A18:D18").format = { fill: "#5B9BD5", font: { name: font, size: 10, bold: true, color: "#FFFFFF" }, horizontalAlignment: "center", wrapText: true };
costSheet.getRange("A19:D20").format = { font: { name: font, size: 10, color: darkText }, verticalAlignment: "center", wrapText: true };
costSheet.getRange("A18:D20").format.borders = { preset: "outside", style: "thin", color: lightBorder };
costSheet.getRange("A19:D20").format.rowHeight = 34;

costSheet.getRange("A:A").format.columnWidth = 35;
costSheet.getRange("B:B").format.columnWidth = 18;
costSheet.getRange("C:C").format.columnWidth = 16;
costSheet.getRange("D:D").format.columnWidth = 72;

workbook.recalculate();

const taskCheck = await workbook.inspect({
  kind: "table",
  range: "WBS Review!A2:O15",
  include: "values,formulas",
  tableMaxRows: 15,
  tableMaxCols: 15,
});
console.log(taskCheck.ndjson);
const costCheck = await workbook.inspect({
  kind: "table",
  range: "Chi phí nhân sự!A6:D20",
  include: "values,formulas",
  tableMaxRows: 20,
  tableMaxCols: 4,
});
console.log(costCheck.ndjson);
const errors = await workbook.inspect({
  kind: "match",
  searchTerm: "#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!|#NULL!|#SPILL!|#CALC!",
  options: { useRegex: true, maxResults: 50 },
  summary: "final formula error scan",
});
console.log(errors.ndjson);

await fs.mkdir(outputDir, { recursive: true });
for (const [sheetName, range, fileName] of [
  ["WBS Review", "A1:O22", "wbs-review.png"],
  ["Chi phí nhân sự", "A1:D21", "chi-phi-nhan-su.png"],
]) {
  const preview = await workbook.render({ sheetName, range, scale: 1.25, format: "png" });
  await fs.writeFile(`${outputDir}/${fileName}`, new Uint8Array(await preview.arrayBuffer()));
}

const output = await SpreadsheetFile.exportXlsx(workbook);
await output.save(outputPath);
console.log(`SAVED ${outputPath}`);
