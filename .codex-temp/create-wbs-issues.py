import argparse
import json
import re
import subprocess
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

ROOT = Path(r"D:\Projects\KhachSanDiDong")
MANIFEST_PATH = ROOT / ".codex-temp" / "wbs-issue-manifest.json"
CREATED_PATH = ROOT / ".codex-temp" / "wbs-issue-created.json"
ASSIGNEE = {"Đạt": "DatTran26", "Bảo": "NgoQuocBao24405", "Hoàng": "HoangKim72"}

parser = argparse.ArgumentParser()
parser.add_argument("--start", type=int, required=True)
parser.add_argument("--end", type=int, required=True)
args = parser.parse_args()

manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
existing = json.loads(CREATED_PATH.read_text(encoding="utf-8")) if CREATED_PATH.exists() else {}
titles = json.loads(subprocess.run(
    ["gh", "issue", "list", "--state", "all", "--limit", "500", "--json", "number,title,url"],
    cwd=ROOT, check=True, capture_output=True, text=True, encoding="utf-8"
).stdout)
existing_by_title = {item["title"]: item for item in titles}

def create_or_reuse(item):
    if item["wbs_id"] in existing:
        return item, None
    if item["title"] in existing_by_title:
        issue = existing_by_title[item["title"]]
    else:
        command = ["gh", "issue", "create", "--title", item["title"], "--body-file", item["body_file"]]
        assignee = ASSIGNEE.get(item["owner"])
        if assignee:
            command.extend(["--assignee", assignee])
        result = subprocess.run(command, cwd=ROOT, check=True, capture_output=True, text=True, encoding="utf-8")
        url = result.stdout.strip().splitlines()[-1]
        match = re.search(r"/issues/(\d+)$", url)
        if not match:
            raise RuntimeError(f"Unexpected issue URL: {url}")
        issue = {"number": int(match.group(1)), "title": item["title"], "url": url}
    return item, issue


created = []
selected = manifest[args.start:args.end]
with ThreadPoolExecutor(max_workers=6) as executor:
    results = list(executor.map(create_or_reuse, selected))
for item, issue in results:
    if issue is None:
        continue
    existing[item["wbs_id"]] = {**item, "issue_number": issue["number"], "issue_url": issue["url"]}
    created.append(issue)

CREATED_PATH.write_text(json.dumps(existing, ensure_ascii=False, indent=2), encoding="utf-8")
print(json.dumps({"requested": args.end - args.start, "created_or_reused": len(created), "total_recorded": len(existing), "issues": created}))
