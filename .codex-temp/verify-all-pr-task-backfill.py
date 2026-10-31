import concurrent.futures
import json
import subprocess
from pathlib import Path

ROOT = Path(r"D:\Projects\KhachSanDiDong")
REPO = "DatTran26/khachsan-di-dong"
before = {item["number"]: item for item in json.loads((ROOT / ".codex-temp" / "all-historical-pr-audit.json").read_text(encoding="utf-8"))}
updated = {item["number"]: item for item in json.loads((ROOT / ".codex-temp" / "all-pr-task-backfill-manifest.json").read_text(encoding="utf-8"))}

def fetch(number):
    result = subprocess.run(
        ["gh", "pr", "view", str(number), "--repo", REPO, "--json", "number,title,state,body,baseRefName,headRefName,url"],
        cwd=ROOT, capture_output=True, text=True, encoding="utf-8",
    )
    if result.returncode:
        raise RuntimeError(result.stderr or result.stdout)
    return json.loads(result.stdout)

with concurrent.futures.ThreadPoolExecutor(max_workers=6) as executor:
    current = list(executor.map(fetch, range(1, 54)))

failures = []
for item in current:
    number = item["number"]
    snapshot = before[number]
    if (item["state"], item["baseRefName"], item["headRefName"]) != (snapshot["state"], snapshot["baseRefName"], snapshot["headRefName"]):
        failures.append({"number": number, "type": "immutable_state_changed"})
    if number in updated:
        expected = updated[number]
        if item["title"] != expected["new_title"]:
            failures.append({"number": number, "type": "title_mismatch"})
        if expected["aggregate_task_name"] not in item["body"] or "## Backfilled task record" not in item["body"]:
            failures.append({"number": number, "type": "task_record_missing"})
    elif "WBS Issue links:" not in item["body"]:
        failures.append({"number": number, "type": "existing_wbs_link_missing"})

report = {"prs_checked": len(current), "backfilled_1_33": len(updated), "existing_wbs_link_checked_34_53": 20, "failures": failures}
(ROOT / ".codex-temp" / "all-pr-task-backfill-verification.json").write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
print(json.dumps(report, ensure_ascii=False))
if failures:
    raise SystemExit(1)
