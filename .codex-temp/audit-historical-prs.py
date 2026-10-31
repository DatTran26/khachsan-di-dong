import json
import subprocess
from pathlib import Path

ROOT = Path(r"D:\Projects\KhachSanDiDong")
OUT = ROOT / ".codex-temp" / "historical-pr-snapshot.json"
FIELDS = "number,title,body,url,state,baseRefName,headRefName,mergedAt,statusCheckRollup,commits,files"

records = []
for number in range(34, 54):
    result = subprocess.run(
        ["gh", "pr", "view", str(number), "--json", FIELDS],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
        encoding="utf-8",
    )
    records.append(json.loads(result.stdout))

OUT.write_text(json.dumps(records, ensure_ascii=False, indent=2), encoding="utf-8")
print(json.dumps({"snapshot": str(OUT), "count": len(records)}))
