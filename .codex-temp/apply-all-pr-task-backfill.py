import concurrent.futures
import json
import subprocess
from pathlib import Path

ROOT = Path(r"D:\Projects\KhachSanDiDong")
REPO = "DatTran26/khachsan-di-dong"
manifest = json.loads((ROOT / ".codex-temp" / "all-pr-task-backfill-manifest.json").read_text(encoding="utf-8"))

def update(entry):
    result = subprocess.run(
        ["gh", "pr", "edit", str(entry["number"]), "--repo", REPO, "--title", entry["new_title"], "--body-file", entry["body_file"]],
        cwd=ROOT, capture_output=True, text=True, encoding="utf-8",
    )
    if result.returncode:
        raise RuntimeError(result.stderr or result.stdout)
    return entry["number"]

completed, failures = [], []
with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
    futures = {executor.submit(update, entry): entry["number"] for entry in manifest}
    for future in concurrent.futures.as_completed(futures):
        number = futures[future]
        try:
            completed.append(future.result())
        except Exception as error:
            failures.append({"number": number, "error": str(error)})

report = {"updated": sorted(completed), "failures": failures}
(ROOT / ".codex-temp" / "all-pr-task-backfill-report.json").write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
print(json.dumps({"updated": len(completed), "failures": failures}, ensure_ascii=False))
if failures:
    raise SystemExit(1)
