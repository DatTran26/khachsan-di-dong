import concurrent.futures
import json
import subprocess
from pathlib import Path

ROOT = Path(r"D:\Projects\KhachSanDiDong")
REPO = "DatTran26/khachsan-di-dong"
numbers = list(range(1, 54))

def inspect(number):
    result = subprocess.run(
        ["gh", "pr", "view", str(number), "--repo", REPO, "--json", "number,title,state,body,baseRefName,headRefName,mergedAt,closedAt,files,commits,statusCheckRollup,url"],
        cwd=ROOT, capture_output=True, text=True, encoding="utf-8",
    )
    if result.returncode:
        raise RuntimeError(f"#{number}: {result.stderr or result.stdout}")
    return json.loads(result.stdout)

with concurrent.futures.ThreadPoolExecutor(max_workers=6) as executor:
    records = list(executor.map(inspect, numbers))
records.sort(key=lambda record: record["number"])
path = ROOT / ".codex-temp" / "all-historical-pr-audit.json"
path.write_text(json.dumps(records, ensure_ascii=False, indent=2), encoding="utf-8")
print(json.dumps({"count": len(records), "path": str(path)}, ensure_ascii=False))
