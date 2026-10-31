import fs from "node:fs/promises";
import { FileBlob, SpreadsheetFile } from "@oai/artifact-tool";

const root = "D:/Projects/KhachSanDiDong";
const source = `${root}/outputs/evidence-register-261028-phase3/khach-san-di-dong-evidence-register.xlsx`;
const previewPath = `${root}/.codex-temp/phase3-before-edit.png`;
const workbook = await SpreadsheetFile.importXlsx(await FileBlob.load(source));
const summary = await workbook.inspect({ kind: "table", range: "Manager Summary!A1:H23", include: "values,formulas", tableMaxRows: 23, tableMaxCols: 8 });
const register = await workbook.inspect({ kind: "table", range: "Task Register!A1:V12", include: "values,formulas", tableMaxRows: 12, tableMaxCols: 22 });
const preview = await workbook.render({ sheetName: "Manager Summary", range: "A1:H23", scale: 1, format: "png" });
await fs.writeFile(previewPath, new Uint8Array(await preview.arrayBuffer()));
console.log(JSON.stringify({ summary: summary.ndjson, register: register.ndjson, previewPath }, null, 2));
