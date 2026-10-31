import argparse
import json
import subprocess
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

ROOT = Path(r"D:\Projects\KhachSanDiDong")
MANIFEST_PATH = ROOT / ".codex-temp" / "wbs-issue-manifest.json"
ITEMS_PATH = ROOT / ".codex-temp" / "wbs-project-items.json"

parser = argparse.ArgumentParser()
parser.add_argument("--start", type=int, required=True)
parser.add_argument("--end", type=int, required=True)
args = parser.parse_args()

manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
issues = json.loads(subprocess.run(
    ["gh", "issue", "list", "--state", "open", "--limit", "500", "--json", "number,title,url"],
    cwd=ROOT, check=True, capture_output=True, text=True, encoding="utf-8"
).stdout)
by_title = {}
for issue in issues:
    if issue["title"] not in by_title or issue["number"] < by_title[issue["title"]]["number"]:
        by_title[issue["title"]] = issue
items = json.loads(ITEMS_PATH.read_text(encoding="utf-8")) if ITEMS_PATH.exists() else {}

def add(item):
    issue = by_title.get(item["title"])
    if not issue:
        raise RuntimeError(f"Canonical issue missing: {item['wbs_id']}")
    result = subprocess.run(
        ["gh", "project", "item-add", "14", "--owner", "DatTran26", "--url", issue["url"], "--format", "json"],
        cwd=ROOT, check=True, capture_output=True, text=True, encoding="utf-8"
    )
    project_item = json.loads(result.stdout)
    return item, issue, project_item

selected = manifest[args.start:args.end]
with ThreadPoolExecutor(max_workers=3) as executor:
    results = list(executor.map(add, selected))
for item, issue, project_item in results:
    items[item["wbs_id"]] = {**item, "issue_number": issue["number"], "issue_url": issue["url"], "project_item_id": project_item["id"]}

ITEMS_PATH.write_text(json.dumps(items, ensure_ascii=False, indent=2), encoding="utf-8")
print(json.dumps({"requested": len(selected), "total_recorded": len(items)}))
