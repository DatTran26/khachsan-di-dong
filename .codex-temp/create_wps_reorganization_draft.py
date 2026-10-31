from __future__ import annotations

import re
from collections import defaultdict
from datetime import datetime
from pathlib import Path

import pandas as pd
from openpyxl import Workbook, load_workbook
from openpyxl.formatting.rule import CellIsRule
from openpyxl.styles import Alignment, Border, Font, PatternFill, Side
from openpyxl.worksheet.table import Table, TableStyleInfo


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "outputs" / "wbs-review-261027" / "khach-san-di-dong-wbs-task-name-review.xlsx"
OUTPUT = ROOT / "outputs" / "wps-reorganization-261028" / "khach-san-di-dong-wps-task-name-draft.xlsx"

TITLE_FILL = PatternFill("solid", fgColor="1F4E78")
HEADER_FILL = PatternFill("solid", fgColor="D9EAF7")
SUMMARY_FILL = PatternFill("solid", fgColor="DDEBF7")
MILESTONE_FILL = PatternFill("solid", fgColor="FFF2CC")
TASK_FILL = PatternFill("solid", fgColor="FFFFFF")
THIN = Side(style="thin", color="D9E2F3")


def workday_finish(start: pd.Timestamp, duration: int) -> datetime:
    if duration <= 0:
        return start.to_pydatetime()
    return (start + pd.offsets.BDay(duration - 1)).to_pydatetime()


def descendants(frame: pd.DataFrame, index: int) -> list[int]:
    level = int(frame.at[index, "Cấp"])
    found = []
    for child_index in range(index + 1, len(frame)):
        if int(frame.at[child_index, "Cấp"]) <= level:
            break
        found.append(child_index)
    return found


def convert_predecessors(value: object, task_id_by_wbs: dict[str, int]) -> tuple[str, str]:
    if pd.isna(value):
        return "", ""
    source = str(value)
    matches = re.findall(r"WBS\s+([\d.]+)\s+\(Type\s+(\d)\)", source)
    link_type = {"0": "FF", "1": "FS", "2": "SS", "3": "SF"}
    wps = []
    wbs_refs = []
    for wbs, kind in matches:
        if wbs in task_id_by_wbs:
            wps.append(f"{task_id_by_wbs[wbs]}{link_type.get(kind, 'FS')}")
        wbs_refs.append(f"{wbs} ({link_type.get(kind, 'FS')})")
    return ", ".join(wps), ", ".join(wbs_refs)


def predecessor_links(value: object) -> list[tuple[str, str]]:
    if pd.isna(value):
        return []
    return [(wbs, {"0": "FF", "1": "FS", "2": "SS", "3": "SF"}.get(kind, "FS")) for wbs, kind in re.findall(r"WBS\s+([\d.]+)\s+\(Type\s+(\d)\)", str(value))]


def business_days(start: pd.Timestamp, duration: int) -> list[pd.Timestamp]:
    return [(start + pd.offsets.BDay(offset)).normalize() for offset in range(max(duration, 1))]


def level_schedule(frame: pd.DataFrame) -> tuple[dict[int, tuple[pd.Timestamp, pd.Timestamp]], int, dict[int, list[tuple[int, str]]]]:
    task_indexes = [index for index in range(len(frame)) if frame.at[index, "Loại"] == "Task"]
    task_by_wbs = {frame.at[index, "WBS"]: index for index in task_indexes}
    links: dict[int, list[tuple[int, str]]] = {}
    for index in task_indexes:
        resolved = []
        for wbs, kind in predecessor_links(frame.at[index, "Predecessor"]):
            if wbs not in task_by_wbs:
                continue
            predecessor = task_by_wbs[wbs]
            same_day = pd.Timestamp(frame.at[index, "source_datetime"]).normalize() == pd.Timestamp(frame.at[predecessor, "source_finish_datetime"]).normalize()
            resolved.append((predecessor, "SS" if kind == "FS" and same_day else kind))
        links[index] = resolved
    children = defaultdict(list)
    indegree = {index: 0 for index in task_indexes}
    for task, predecessors in links.items():
        for predecessor, _ in predecessors:
            children[predecessor].append(task)
            indegree[task] += 1
    ready = sorted(index for index in task_indexes if indegree[index] == 0)
    ordered = []
    while ready:
        index = ready.pop(0)
        ordered.append(index)
        for child in children[index]:
            indegree[child] -= 1
            if indegree[child] == 0:
                ready.append(child)
                ready.sort()
    ordered.extend(index for index in task_indexes if index not in set(ordered))

    assigned: dict[int, tuple[pd.Timestamp, pd.Timestamp]] = {}
    resource_load: dict[tuple[pd.Timestamp, str], float] = defaultdict(float)
    for index in ordered:
        duration = int(frame.at[index, "Mới (ngày)"])
        work_per_day = float(frame.at[index, "Gốc (giờ)"]) / duration
        owner = frame.at[index, "Phụ trách"]
        candidate = pd.Timestamp(frame.at[index, "source_start"]).normalize()
        for predecessor, kind in links[index]:
            if predecessor not in assigned:
                continue
            predecessor_start, predecessor_finish = assigned[predecessor]
            if kind == "FS":
                candidate = max(candidate, (predecessor_finish + pd.offsets.BDay(1)).normalize())
            elif kind == "SS":
                candidate = max(candidate, predecessor_start)
            elif kind == "FF":
                candidate = max(candidate, (predecessor_finish - pd.offsets.BDay(duration - 1)).normalize())
            else:
                candidate = max(candidate, (predecessor_start - pd.offsets.BDay(duration - 1)).normalize())
        while True:
            planned_days = business_days(candidate, duration)
            if all(resource_load[(day, owner)] + work_per_day <= 8.0001 for day in planned_days):
                break
            candidate = (candidate + pd.offsets.BDay(1)).normalize()
        finish = planned_days[-1]
        assigned[index] = (candidate, finish)
        for day in planned_days:
            resource_load[(day, owner)] += work_per_day
    overloads = sum(1 for value in resource_load.values() if value > 8.0001)
    return assigned, overloads, links


def format_sheet(ws, widths: dict[str, float], table_name: str, header_row: int, last_row: int, freeze: str) -> None:
    for cell in ws[header_row]:
        cell.fill = HEADER_FILL
        cell.font = Font(bold=True, color="1F1F1F")
        cell.alignment = Alignment(horizontal="center", vertical="center", wrap_text=True)
        cell.border = Border(bottom=THIN)
    for col, width in widths.items():
        ws.column_dimensions[col].width = width
    ws.freeze_panes = freeze
    ref = f"A{header_row}:{chr(64 + len(widths))}{last_row}"
    table = Table(displayName=table_name, ref=ref)
    table.tableStyleInfo = TableStyleInfo(name="TableStyleMedium2", showRowStripes=True, showColumnStripes=False)
    ws.add_table(table)
    ws.auto_filter.ref = ref


def main() -> None:
    raw = pd.read_excel(SOURCE, sheet_name="WBS Review", header=5)
    raw = raw[raw["WBS"].notna()].copy().reset_index(drop=True)
    raw["WBS"] = raw["WBS"].astype(str)
    raw["Cấp"] = pd.to_numeric(raw["Cấp"], errors="raise").astype(int)
    raw["Mới (ngày)"] = pd.to_numeric(raw["Mới (ngày)"], errors="coerce").fillna(0).round().astype(int)
    raw["Gốc (giờ)"] = pd.to_numeric(raw["Gốc (giờ)"], errors="coerce").fillna(0)
    raw["source_datetime"] = pd.to_datetime(raw["Bắt đầu tham chiếu"])
    raw["source_finish_datetime"] = pd.to_datetime(raw["Kết thúc tham chiếu"])
    raw["source_start"] = raw["source_datetime"].dt.normalize()
    raw["start"] = raw["source_start"]
    raw["finish"] = raw.apply(lambda row: workday_finish(row["start"], int(row["Mới (ngày)"])) if row["Loại"] == "Task" else row["start"].to_pydatetime(), axis=1)
    scheduled, leveling_overloads, effective_links = level_schedule(raw)
    for index, (start, finish) in scheduled.items():
        raw.at[index, "start"] = start
        raw.at[index, "finish"] = finish

    for index in range(len(raw) - 1, -1, -1):
        if raw.at[index, "Loại"] != "Tổng hợp":
            continue
        child_rows = descendants(raw, index)
        child_rows = [child for child in child_rows if raw.at[child, "Loại"] != "Tổng hợp" or True]
        raw.at[index, "start"] = min(pd.Timestamp(raw.at[child, "start"]) for child in child_rows)
        raw.at[index, "finish"] = max(pd.Timestamp(raw.at[child, "finish"]) for child in child_rows).to_pydatetime()

    raw["Task ID"] = list(range(1, len(raw) + 1))
    task_id_by_wbs = dict(zip(raw["WBS"], raw["Task ID"]))
    raw["Predecessors"] = ""
    raw["Predecessor WBS"] = ""
    for index, links in effective_links.items():
        raw.at[index, "Predecessors"] = ", ".join(f"{int(raw.at[predecessor, 'Task ID'])}{kind}" for predecessor, kind in links)
        raw.at[index, "Predecessor WBS"] = ", ".join(f"{raw.at[predecessor, 'WBS']} ({kind})" for predecessor, kind in links)
    raw["Resource Units"] = raw.apply(
        lambda row: (row["Gốc (giờ)"] / (row["Mới (ngày)"] * 8)) if row["Loại"] == "Task" and row["Mới (ngày)"] else 0,
        axis=1,
    )

    wb = Workbook()
    readme = wb.active
    readme.title = "Hướng dẫn"
    readme.merge_cells("A1:H1")
    readme["A1"] = "Bản nháp WPS/MS Project — Lịch làm việc 08/09/2026 đến 27/10/2026"
    readme["A1"].fill = TITLE_FILL
    readme["A1"].font = Font(bold=True, color="FFFFFF", size=14)
    readme["A1"].alignment = Alignment(horizontal="center")
    guidance = [
        ("Mục đích", "Duyệt Task Name và lịch trước khi copy sang WPS/MS Project. Không sửa file .mpp trong bản nháp này."),
        ("Task Name", "Chỉ ghi hành động + đối tượng + đầu ra; không ghi tên người thực hiện."),
        ("Người thực hiện", "Xem cột Resource Names. Đạt: BA/kiến trúc/điều phối; Bảo: backend/database; Hoàng: Flutter/UI/QA."),
        ("Duration", "Task có effort > 0 dùng số ngày nguyên. Milestone = 0 days. Summary task để WPS tự tổng hợp."),
        ("Work", "Giữ effort gốc theo giờ để không làm sai tải nguồn lực và chi phí. Resource Units = Work / (Duration × 8 giờ)."),
        ("Lịch", "Start/Finish chỉ dùng ngày làm việc, không dùng phần giờ. Lịch dùng Thứ Hai–Thứ Sáu; chưa đưa ngày nghỉ lễ vào."),
        ("Phụ thuộc", "Cột Predecessors chứa Task ID + loại liên kết WPS (FS/SS/FF/SF). Cột Predecessor WBS dùng để đối chiếu."),
        ("Trạng thái", "Không suy diễn Done từ PR merge. Chỉ chuyển Done khi có evidence và acceptance phù hợp."),
    ]
    readme.append([])
    readme.append(["Nội dung", "Quy ước"])
    for label, text in guidance:
        readme.append([label, text])
    for cell in readme[3]:
        cell.fill = HEADER_FILL
        cell.font = Font(bold=True)
    readme.column_dimensions["A"].width = 24
    readme.column_dimensions["B"].width = 120
    for row in readme.iter_rows(min_row=3, max_row=10, min_col=1, max_col=2):
        for cell in row:
            cell.alignment = Alignment(vertical="top", wrap_text=True)
    readme.freeze_panes = "A3"

    gantt = wb.create_sheet("WPS Gantt Draft")
    gantt.merge_cells("A1:N1")
    gantt["A1"] = "WPS/MS Project Draft — Task Name, lịch và phân công"
    gantt["A1"].fill = TITLE_FILL
    gantt["A1"].font = Font(bold=True, color="FFFFFF", size=14)
    gantt["A1"].alignment = Alignment(horizontal="center")
    gantt["A2"] = "Dòng Tổng hợp chỉ là nhóm; task lá là việc giao trong ngày. Resource Names là người chịu trách nhiệm."
    gantt.merge_cells("A2:N2")
    gantt["A2"].alignment = Alignment(wrap_text=True)
    headers = [
        "Task ID", "Outline Level", "WBS Ref", "Task Type", "Task Name", "Duration", "Start", "Finish",
        "Predecessors", "Resource Names", "Work (h)", "Resource Units", "Reviewer", "Expected Output",
    ]
    gantt.append([])
    gantt.append(headers)
    for _, row in raw.iterrows():
        task_type = {"Tổng hợp": "Summary", "Milestone": "Milestone", "Task": "Task"}[row["Loại"]]
        duration = "Auto" if task_type == "Summary" else f"{int(row['Mới (ngày)'])} days"
        resource = "" if task_type != "Task" else row["Phụ trách"]
        work = "" if task_type != "Task" else float(row["Gốc (giờ)"])
        units = "" if task_type != "Task" else float(row["Resource Units"])
        gantt.append([
            int(row["Task ID"]), int(row["Cấp"]), row["WBS"], task_type, row["Task Name đề xuất"], duration,
            pd.Timestamp(row["start"]).to_pydatetime(), pd.Timestamp(row["finish"]).to_pydatetime(),
            row["Predecessors"], resource, work, units, "", row["Kết quả hoàn thành"],
        ])
        current = gantt.max_row
        fill = SUMMARY_FILL if task_type == "Summary" else MILESTONE_FILL if task_type == "Milestone" else TASK_FILL
        for cell in gantt[current]:
            cell.fill = fill
            cell.alignment = Alignment(vertical="top", wrap_text=True)
            cell.border = Border(bottom=THIN)
        gantt.cell(current, 5).alignment = Alignment(vertical="top", wrap_text=True, indent=max(0, int(row["Cấp"]) - 1))
        if task_type == "Summary":
            gantt.cell(current, 5).font = Font(bold=True)
        if task_type == "Milestone":
            gantt.cell(current, 5).font = Font(bold=True, color="C00000")
    for row in range(5, gantt.max_row + 1):
        gantt.cell(row, 7).number_format = "ddd dd/mm/yy"
        gantt.cell(row, 8).number_format = "ddd dd/mm/yy"
        gantt.cell(row, 11).number_format = "0.0"
        gantt.cell(row, 12).number_format = "0%"
    format_sheet(
        gantt,
        {"A": 9, "B": 13, "C": 13, "D": 12, "E": 58, "F": 12, "G": 15, "H": 15, "I": 22, "J": 16, "K": 11, "L": 15, "M": 15, "N": 48},
        "WpsGanttDraft", 4, gantt.max_row, "E5",
    )

    daily = wb.create_sheet("Lịch theo ngày")
    daily.merge_cells("A1:H1")
    daily["A1"] = "Việc cần làm theo ngày — chỉ task lá"
    daily["A1"].fill = TITLE_FILL
    daily["A1"].font = Font(bold=True, color="FFFFFF", size=14)
    daily["A1"].alignment = Alignment(horizontal="center")
    daily.append([])
    daily.append(["Ngày", "Thứ", "Resource Names", "Task Name", "WBS Ref", "Duration", "Work hôm nay (h)", "Expected Output"])
    expanded = []
    for _, row in raw[raw["Loại"] == "Task"].iterrows():
        duration = int(row["Mới (ngày)"])
        work_per_day = float(row["Gốc (giờ)"]) / duration
        for offset in range(duration):
            date = (pd.Timestamp(row["start"]) + pd.offsets.BDay(offset)).to_pydatetime()
            expanded.append((date, row["Phụ trách"], row["Task Name đề xuất"], row["WBS"], duration, work_per_day, row["Kết quả hoàn thành"]))
    expanded.sort(key=lambda item: (item[0], item[1], item[3]))
    for date, owner, name, wbs, duration, work, outcome in expanded:
        daily.append([date, date.strftime("%A"), owner, name, wbs, f"{duration} days", work, outcome])
    for row in range(4, daily.max_row + 1):
        daily.cell(row, 1).number_format = "ddd dd/mm/yy"
        daily.cell(row, 7).number_format = "0.0"
        for cell in daily[row]:
            cell.alignment = Alignment(vertical="top", wrap_text=True)
    format_sheet(daily, {"A": 15, "B": 12, "C": 16, "D": 58, "E": 14, "F": 12, "G": 19, "H": 48}, "DailyPlan", 3, daily.max_row, "D4")

    capacity = wb.create_sheet("Kiểm tra tải")
    capacity.merge_cells("A1:G1")
    capacity["A1"] = "Kiểm tra tải theo ngày và người thực hiện"
    capacity["A1"].fill = TITLE_FILL
    capacity["A1"].font = Font(bold=True, color="FFFFFF", size=14)
    capacity["A1"].alignment = Alignment(horizontal="center")
    capacity.append([])
    capacity.append(["Ngày", "Thứ", "Resource Names", "Work kế hoạch (h)", "Capacity (h)", "Chênh lệch (h)", "Kết quả"])
    load = defaultdict(float)
    for date, owner, _, _, _, work, _ in expanded:
        load[(date.date(), owner)] += work
    for (date, owner), work in sorted(load.items()):
        result = "Đạt" if work <= 8.0001 else "Quá tải"
        capacity.append([date, date.strftime("%A"), owner, work, 8, 8 - work, result])
    for row in range(4, capacity.max_row + 1):
        capacity.cell(row, 1).number_format = "ddd dd/mm/yy"
        for col in (4, 5, 6):
            capacity.cell(row, col).number_format = "0.0"
    format_sheet(capacity, {"A": 15, "B": 12, "C": 16, "D": 22, "E": 15, "F": 17, "G": 14}, "CapacityCheck", 3, capacity.max_row, "A4")
    capacity.conditional_formatting.add(f"F4:F{capacity.max_row}", CellIsRule(operator="lessThan", formula=["0"], fill=PatternFill("solid", fgColor="FFC7CE")))

    mapping = wb.create_sheet("WBS Mapping")
    mapping.append(["WBS Ref", "WPS Task ID", "Task Name nguồn", "Task Name WPS", "Resource Names", "Work (h)", "Duration (days)", "Start", "Finish", "Predecessor WBS"])
    for _, row in raw.iterrows():
        mapping.append([
            row["WBS"], int(row["Task ID"]), row["Task Name hiện tại"], row["Task Name đề xuất"],
            row["Phụ trách"] if row["Loại"] == "Task" else "", row["Gốc (giờ)"] if row["Loại"] == "Task" else "",
            int(row["Mới (ngày)"]) if row["Loại"] != "Tổng hợp" else "Auto", pd.Timestamp(row["start"]).to_pydatetime(),
            pd.Timestamp(row["finish"]).to_pydatetime(), row["Predecessor WBS"],
        ])
    for row in range(2, mapping.max_row + 1):
        mapping.cell(row, 8).number_format = "ddd dd/mm/yy"
        mapping.cell(row, 9).number_format = "ddd dd/mm/yy"
    format_sheet(mapping, {"A": 14, "B": 12, "C": 54, "D": 54, "E": 16, "F": 12, "G": 16, "H": 15, "I": 15, "J": 35}, "WbsMapping", 1, mapping.max_row, "D2")

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    wb.save(OUTPUT)

    task_rows = raw[raw["Loại"] == "Task"]
    overloads = sum(1 for work in load.values() if work > 8.0001)
    print({
        "output": str(OUTPUT),
        "rows": int(len(raw)),
        "leaf_tasks": int(len(task_rows)),
        "start": str(task_rows["start"].min().date()),
        "finish": str(task_rows["finish"].max().date()),
        "owners": task_rows["Phụ trách"].value_counts().to_dict(),
        "overloaded_day_owner_pairs": overloads,
        "leveling_overloads": leveling_overloads,
    })


if __name__ == "__main__":
    main()
