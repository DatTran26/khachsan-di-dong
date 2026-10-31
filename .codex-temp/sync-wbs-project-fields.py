import concurrent.futures
import json
import subprocess
import threading
import time
from pathlib import Path

ROOT = Path(r"D:\Projects\KhachSanDiDong")
ITEMS = list(json.loads((ROOT / ".codex-temp" / "wbs-project-items.json").read_text(encoding="utf-8")).values())
ITEMS.sort(key=lambda item: item["wbs_id"])
PROJECT_ID = "PVT_kwHOCF-thM4Bj7wB"
FIELDS = {
    "status": "PVTSSF_lAHOCF-thM4Bj7wBzhiuRtQ", "kanban": "PVTSSF_lAHOCF-thM4Bj7wBzhiuoOY",
    "wbs": "PVTF_lAHOCF-thM4Bj7wBzhnej2Y", "sprint": "PVTSSF_lAHOCF-thM4Bj7wBzhnej3M",
    "workstream": "PVTSSF_lAHOCF-thM4Bj7wBzhnej4U", "evidence": "PVTSSF_lAHOCF-thM4Bj7wBzhnej5k",
    "acceptance": "PVTSSF_lAHOCF-thM4Bj7wBzhnej7U", "last_verified": "PVTF_lAHOCF-thM4Bj7wBzhnej8k",
    "estimate": "PVTF_lAHOCF-thM4Bj7wBzhiuRvA", "start": "PVTF_lAHOCF-thM4Bj7wBzhiuRvE",
    "target": "PVTF_lAHOCF-thM4Bj7wBzhiuRvI",
}
OPTIONS = {
    "status": {"Backlog": "f75ad846", "In review": "df73e18b"},
    "kanban": {"Triage": "798dfc8d", "Review": "c11e5ecd"},
    "sprint": {"S1": "c9d34b1f", "S2": "67653fb4", "S3": "8dfe30ec", "S4": "413c3822"},
    "workstream": {"Discovery": "585a757d", "Architecture": "0a548915", "Backend": "0adaa34d", "Flutter": "8a171801", "Operations": "9b3ec520", "Dashboard": "b7133c02", "AI": "63f234fd", "QA": "f1231c81", "DevOps": "2ecc181f", "Project management": "85f52381"},
    "evidence": {"No evidence": "42ab1d3b", "Code": "4cb4413b", "Code + test/CI": "1933e071", "Acceptance": "bc15256b"},
    "acceptance": {"UAT": "8b928720", "Stakeholder sign-off": "7e44952f", "Reviewer approval": "c5338fdd", "Not applicable": "4fe0beb3"},
}
lock = threading.Lock()
completed = []
failures = []

def gql_update(item, field_id, value):
    query = f'mutation {{ updateProjectV2ItemFieldValue(input: {{projectId: "{PROJECT_ID}", itemId: "{item["project_item_id"]}", fieldId: "{field_id}", value: {value}}}) {{ projectV2Item {{ id }} }} }}'
    for attempt in range(5):
        result = subprocess.run(["gh", "api", "graphql", "-f", f"query={query}"], cwd=ROOT, capture_output=True, text=True, encoding="utf-8")
        if result.returncode == 0:
            payload = json.loads(result.stdout)
            if not payload.get("errors"):
                return
            detail = json.dumps(payload["errors"], ensure_ascii=False)
        else:
            detail = result.stderr or result.stdout
        if attempt == 4:
            raise RuntimeError(detail.strip())
        time.sleep(1.25 * (attempt + 1))

def update_item(item):
    updates = [
        (FIELDS["wbs"], "{text: " + json.dumps(item["wbs_id"], ensure_ascii=False) + "}"),
        (FIELDS["sprint"], "{singleSelectOptionId: " + json.dumps(OPTIONS["sprint"][item["sprint"]]) + "}"),
        (FIELDS["workstream"], "{singleSelectOptionId: " + json.dumps(OPTIONS["workstream"][item["workstream"]]) + "}"),
        (FIELDS["evidence"], "{singleSelectOptionId: " + json.dumps(OPTIONS["evidence"][item["evidence_level"]]) + "}"),
        (FIELDS["acceptance"], "{singleSelectOptionId: " + json.dumps(OPTIONS["acceptance"][item["acceptance_type"]]) + "}"),
        (FIELDS["kanban"], "{singleSelectOptionId: " + json.dumps(OPTIONS["kanban"][item["kanban"]]) + "}"),
        (FIELDS["estimate"], "{number: " + str(item["estimate"]) + "}"),
        (FIELDS["start"], "{date: " + json.dumps(item["start"]) + "}"),
        (FIELDS["target"], "{date: " + json.dumps(item["target"]) + "}"),
    ]
    if item["kanban"] == "Review":
        updates.append((FIELDS["status"], "{singleSelectOptionId: " + json.dumps(OPTIONS["status"]["In review"]) + "}"))
    if item["last_verified"]:
        updates.append((FIELDS["last_verified"], "{date: " + json.dumps(item["last_verified"]) + "}"))
    for field_id, value in updates:
        gql_update(item, field_id, value)
    with lock:
        completed.append(item["wbs_id"])
        if len(completed) % 10 == 0:
            print(json.dumps({"completed": len(completed), "last_wbs": item["wbs_id"]}), flush=True)

with concurrent.futures.ThreadPoolExecutor(max_workers=8) as executor:
    futures = {executor.submit(update_item, item): item for item in ITEMS}
    for future in concurrent.futures.as_completed(futures):
        item = futures[future]
        try:
            future.result()
        except Exception as error:
            with lock:
                failures.append({"wbs_id": item["wbs_id"], "error": str(error)})
                print(json.dumps({"failed": item["wbs_id"], "error": str(error)}, ensure_ascii=False), flush=True)

report = {"completed": len(completed), "failures": failures}
(ROOT / ".codex-temp" / "wbs-project-field-sync-report.json").write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
print(json.dumps(report, ensure_ascii=False))
if failures:
    raise SystemExit(1)
