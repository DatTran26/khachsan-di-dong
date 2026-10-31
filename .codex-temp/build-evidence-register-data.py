import csv
import json
import math
import re
import subprocess
import xml.etree.ElementTree as ET
from collections import Counter
from pathlib import Path

ROOT = Path(r"D:\Projects\KhachSanDiDong")
PLAN = ROOT / "plans" / "260923-1658-four-sprint-mvp-backlog"
XML_PATH = PLAN / "Ke-hoach-KhachSanDiDong-MSProject-2021.xml"
CSV_PATH = PLAN / "microsoft-project-import.csv"
DETAIL_PATH = PLAN / "detailed-task-breakdown.md"
OUTPUT_PATH = ROOT / ".codex-temp" / "evidence-register-data.json"
NS = {"m": "http://schemas.microsoft.com/project"}

PR_TITLES = {
    34: ("feat(ui): [S1-UX] loading skeletons and tablet layout foundation", "Code only"),
    35: ("feat(ui): [S1-UX] offline guidance and shared accessibility tokens", "Code only"),
    36: ("feat(shell): [S1-UX] responsive navigation and reconnect feedback", "Code only"),
    37: ("feat(dashboard): [S3-DASH] loading, refresh and room-search persistence", "Code only"),
    38: ("feat(rooms): [S1-ROOM][S2-STAY] room controls and check-in shortcuts", "Code only"),
    39: ("feat(app): [S1-ROOM][S2-STAY][S2-MNT] form validation and offline list UX", "Code only"),
    40: ("feat(operations): [S2-STAY][S2-MNT] checkout and maintenance task UX", "Code only"),
    41: ("feat(housekeeping): [S2-HK] task list readability and mobile interaction", "Code only"),
    42: ("feat(admin): [S1-USER][S2-AUDIT] accounts and audit-screen UX", "Code only"),
    43: ("feat(app): [S1-AUTH][S3-AI] autofill and supporting-screen responsive UX", "Code only"),
    44: ("test(app): [S1-UX][S2-UX] shared-widget and feature-screen coverage", "Test source, CI evidence pending"),
    45: ("test(ui): [S3-UX][S4-UAT] layout matrix and design-system checks", "Test/docs, manual accessibility pending"),
    46: ("ci(app): [S4-DEVOPS] Flutter analyze, test and web-build workflow", "CI configuration + passing check"),
    47: ("docs(project): [S4-PM] risk register and communication workbooks", "Reviewed artefact only"),
    48: ("docs(ui): [S3-UX] five-phase UI/UX upgrade specification", "Plan only"),
    49: ("docs(qa): [S3-UX] automated QA report and unresolved manual checks", "Historical QA report, gaps remain"),
    50: ("docs(dashboard): [S3-DASH] compact PMS room-tile redesign plan", "Plan only"),
    51: ("docs(dashboard): [S3-DASH] room-tile mockups and interactive prototype", "Prototype only"),
    52: ("feat(dashboard): [S3-DASH] live stays-connected PMS room tiles", "Code + tests/CI; UAT pending"),
    53: ("feat(app): [S1-AUTH][S2-OPS] login slideshow and duplicate-action guard", "Code + CI; UAT pending"),
}


def text(node, name, default=""):
    child = node.find(f"m:{name}", NS)
    return child.text.strip() if child is not None and child.text else default


def iso_minutes(value):
    days = int(re.search(r"(\d+)D", value).group(1)) if re.search(r"(\d+)D", value) else 0
    hours = int(re.search(r"(\d+)H", value).group(1)) if re.search(r"(\d+)H", value) else 0
    minutes = int(re.search(r"(\d+)M", value).group(1)) if re.search(r"(\d+)M", value) else 0
    return days * 480 + hours * 60 + minutes


def note_value(notes, label):
    match = re.search(rf"^{label}:\s*(.+)$", notes or "", re.MULTILINE)
    return match.group(1).strip() if match else ""


def parse_reviewer_status():
    result = {}
    for line in DETAIL_PATH.read_text(encoding="utf-8").splitlines():
        if not line.startswith("| S"):
            continue
        cells = [cell.strip() for cell in line.split("|")[1:-1]]
        if len(cells) < 4 or not re.fullmatch(r"S[1-4]-(DAT|BAO|HOANG)-\d+", cells[0]):
            continue
        result[cells[0]] = {"reviewer": cells[-2], "detailed_status": cells[-1]}
    return result


tree = ET.parse(XML_PATH)
root = tree.getroot()
resources = {text(node, "UID"): text(node, "Name") for node in root.findall("m:Resources/m:Resource", NS)}
task_resources = {}
for assignment in root.findall("m:Assignments/m:Assignment", NS):
    task_uid = text(assignment, "TaskUID")
    resource = resources.get(text(assignment, "ResourceUID"))
    if task_uid and resource:
        task_resources.setdefault(task_uid, []).append(resource)

reviewer_status = parse_reviewer_status()
rows = []
workstream = ""
for task in root.findall("m:Tasks/m:Task", NS):
    summary = text(task, "Summary") == "1"
    level = int(text(task, "OutlineLevel", "1"))
    if summary and level == 3:
        workstream = text(task, "Name")
        continue
    if summary or text(task, "Milestone") == "1":
        continue
    notes = text(task, "Notes")
    code = ""
    for attr in task.findall("m:ExtendedAttribute", NS):
        candidate = text(attr, "Value")
        if re.fullmatch(r"S[1-4]-(DAT|BAO|HOANG)-\d+", candidate):
            code = candidate
            break
    if not code:
        code = note_value(notes, "Mã")
    source_status = note_value(notes, "Trạng thái")
    details = reviewer_status.get(code, {})
    if source_status.startswith("Đã xong"):
        actual_status = "Cần xác minh"
        evidence_level = "Tài liệu đã nêu"
    elif source_status == "Kế hoạch":
        actual_status = "Kế hoạch"
        evidence_level = "Chưa có"
    else:
        actual_status = "Cần đối chiếu"
        evidence_level = "Chưa có"
    duration_hours = iso_minutes(text(task, "Duration")) / 60
    rows.append({
        "wbs_id": code,
        "outline": text(task, "OutlineNumber"),
        "sprint": code.split("-")[0] if code else "",
        "workstream": workstream,
        "task_name": text(task, "Name"),
        "owner": ", ".join(dict.fromkeys(task_resources.get(text(task, "UID"), []))),
        "reviewer": details.get("reviewer", "Chưa gán"),
        "start": text(task, "Start"),
        "finish": text(task, "Finish"),
        "effort_hours": duration_hours,
        "proposed_days": max(1, math.ceil(duration_hours / 8)),
        "source_status": source_status,
        "actual_status": actual_status,
        "evidence_level": evidence_level,
        "deliverable": note_value(notes, "Đầu ra"),
        "source_evidence": note_value(notes, "Bằng chứng"),
    })

rows.sort(key=lambda row: [int(part) for part in row["outline"].split(".")])

with CSV_PATH.open(encoding="utf-8-sig", newline="") as csv_file:
    csv_rows = list(csv.DictReader(csv_file))
allowed = {"Đã xong", "Đã xong, cần publish", "Cần đối chiếu", "Kế hoạch"}
invalid_statuses = [row.get("Status", "") for row in csv_rows if row.get("Status", "") and row.get("Status", "") not in allowed]

command = [
    "gh", "pr", "list", "--state", "merged", "--limit", "100",
    "--json", "number,title,url,mergedAt,headRefName,baseRefName",
]
live_prs = json.loads(
    subprocess.run(command, cwd=ROOT, check=True, capture_output=True, text=True, encoding="utf-8").stdout
)
pr_rows = []
for pr in sorted((item for item in live_prs if item["number"] in PR_TITLES), key=lambda item: item["number"]):
    title, evidence = PR_TITLES[pr["number"]]
    pr_rows.append({
        "number": pr["number"],
        "current_title": pr["title"],
        "proposed_title": title,
        "merged_at": pr["mergedAt"],
        "base": pr["baseRefName"],
        "url": pr["url"],
        "evidence": evidence,
        "mapping_status": "Cần mapping WBS task lá",
    })

payload = {
    "project": {"status_date": text(root, "StatusDate"), "minutes_per_day": int(text(root, "MinutesPerDay", "480"))},
    "rows": rows,
    "prs": pr_rows,
    "quality": {
        "xml_task_count": len(rows),
        "xml_unique_wbs_id": len({row["wbs_id"] for row in rows}),
        "csv_row_count": len(csv_rows),
        "invalid_status_count": len(invalid_statuses),
        "invalid_status_values": dict(Counter(invalid_statuses)),
        "source_status_counts": dict(Counter(row["source_status"] for row in rows)),
    },
    "sources": [str(XML_PATH), str(DETAIL_PATH), str(CSV_PATH), "Live GitHub PR metadata via gh pr list"],
}
OUTPUT_PATH.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
print(json.dumps({"task_rows": len(rows), "prs": len(pr_rows), "quality": payload["quality"]}))
