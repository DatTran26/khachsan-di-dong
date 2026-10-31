import concurrent.futures
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(r"D:\Projects\KhachSanDiDong")
manifest = json.loads((ROOT / ".codex-temp" / "pr-backfill-manifest.json").read_text(encoding="utf-8"))
issue_items = json.loads((ROOT / ".codex-temp" / "wbs-project-items.json").read_text(encoding="utf-8"))
output_dir = ROOT / ".codex-temp" / "pr-backfill-bodies-linked"
output_dir.mkdir(exist_ok=True)

def prepare_and_update(entry):
    links = []
    for wbs_id in entry["wbs_candidates"]:
        item = issue_items[wbs_id]
        links.append(f'[{wbs_id} #{item["issue_number"]}]({item["issue_url"]})')
    source = Path(entry["body_file"]).read_text(encoding="utf-8")
    replacement = "- **WBS Issue links:** " + "; ".join(links)
    body = re.sub(r"- \*\*Issue links:\*\* .*", replacement, source, count=1)
    destination = output_dir / f'pr-{entry["number"]}.txt'
    destination.write_text(body, encoding="utf-8")
    result = subprocess.run(
        ["gh", "pr", "edit", str(entry["number"]), "--repo", "DatTran26/khachsan-di-dong", "--body-file", str(destination)],
        cwd=ROOT, capture_output=True, text=True, encoding="utf-8",
    )
    if result.returncode:
        raise RuntimeError(result.stderr or result.stdout)
    return entry["number"]

failures = []
completed = []
with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
    futures = {executor.submit(prepare_and_update, entry): entry["number"] for entry in manifest}
    for future in concurrent.futures.as_completed(futures):
        number = futures[future]
        try:
            completed.append(future.result())
        except Exception as error:
            failures.append({"number": number, "error": str(error)})

report = {"updated": sorted(completed), "failures": failures}
(ROOT / ".codex-temp" / "pr-wbs-link-update-report.json").write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
print(json.dumps({"updated": len(completed), "failures": failures}, ensure_ascii=False))
if failures:
    raise SystemExit(1)
