import json
from pathlib import Path

ROOT = Path(r"D:\Projects\KhachSanDiDong")
AUDIT_PATH = ROOT / ".codex-temp" / "all-historical-pr-audit.json"
OUTPUT_DIR = ROOT / ".codex-temp" / "all-pr-task-backfill-bodies"

MAPPING = {
    1: ("docs(project): [S1-DISCOVERY] 30-session target and baseline scope", "30-session target and project baseline scope", "Documentation baseline; closed without merge"),
    2: ("feat(platform): [S1-FOUNDATION] backend foundation, requirements and CI", "Backend foundation, requirements and CI baseline", "Code + CI; broad baseline scope"),
    3: ("feat(app): [S1-FOUNDATION] bootstrap Flutter hotel operations client", "Flutter hotel operations client baseline", "Code; broad client baseline"),
    4: ("feat(server): [S1-ROOM][S2-OPS] room, stay and operations backend foundation", "Room, stay and operations backend foundation", "Code; broad backend operational scope"),
    5: ("feat(app): [S1-ROOM][S2-OPS][S3-DASH] operational screens and realtime integration", "Operational screens and realtime dashboard integration", "Code; broad Flutter operational scope"),
    6: ("feat(server): [S2-AUDIT][S4-DEVOPS] audit API, demo data and Docker", "Audit API, demo data and Docker delivery", "Code + configuration"),
    7: ("build(project): [S4-DEVOPS] one-command setup and quick-start delivery", "One-command setup and quick-start delivery", "Build/release baseline; accumulated scope"),
    8: ("feat(app): [S1-UX][S2-OPS] theme, navigation and operational screens", "Theme, navigation and hotel operational screens", "Code; broad UI and operations scope"),
    9: ("chore(release): [S4-DEVOPS] release 0.1.0 delivery baseline", "Release 0.1.0 delivery baseline", "Release record"),
    10: ("feat(operations): [S2-HK][S3-DASH][S3-AI] close initial operations and insight gaps", "Initial operations, dashboard and AI delivery gaps", "Code + test/CI; mixed multi-sprint scope"),
    11: ("docs(app-core): [S1-FOUNDATION] document Flutter core and authentication plumbing", "Document Flutter core, API and authentication plumbing", "Documentation-only annotations"),
    12: ("docs(stays-dashboard): [S2-OPS][S3-DASH] document stay, dashboard and realtime modules", "Document stay, dashboard and realtime modules", "Documentation-only annotations"),
    13: ("docs(app-models): [S1-FOUNDATION] document Flutter models and navigation", "Document Flutter models and navigation", "Documentation-only annotations"),
    14: ("docs(server-lib): [S1-FOUNDATION] document shared server infrastructure", "Document shared server infrastructure", "Documentation-only annotations"),
    15: ("docs(server-http): [S1-FOUNDATION] document HTTP, configuration and error handling", "Document server HTTP, configuration and error handling", "Documentation-only annotations"),
    16: ("docs(rooms-housekeeping): [S1-ROOM][S2-HK] document catalog and assignments", "Document room catalog and housekeeping assignments", "Documentation-only annotations"),
    17: ("docs(ai): [S3-AI] document AI summary pipeline", "Document AI summary pipeline", "Documentation-only annotations"),
    18: ("docs(room-audit-maintenance): [S1-ROOM][S2-AUDIT][S2-MNT] document contracts", "Document room, audit and maintenance contracts", "Documentation-only annotations"),
    19: ("docs(auth): [S1-AUTH] document server authentication and sessions", "Document server authentication and session controls", "Documentation-only annotations"),
    20: ("docs(housekeeping-maintenance): [S2-HK][S2-MNT] document backend operations", "Document backend housekeeping and maintenance operations", "Documentation-only annotations"),
    21: ("docs(realtime-health): [S4-DEVOPS] document realtime, health and shutdown controls", "Document realtime, health and shutdown controls", "Documentation-only annotations"),
    22: ("docs(users-audit): [S1-USER][S2-AUDIT] document accounts, auth routes and audit", "Document accounts, auth routes and audit services", "Documentation-only annotations"),
    23: ("docs(app-maintenance-audit): [S2-MNT][S2-AUDIT] document Flutter operations screens", "Document Flutter maintenance and audit screens", "Documentation-only annotations"),
    24: ("docs(app-housekeeping): [S2-HK] document Flutter housekeeping workflow", "Document Flutter housekeeping workflow", "Documentation-only annotations"),
    25: ("docs(app-dashboard-stays): [S2-OPS][S3-DASH] document Flutter dashboard and stays", "Document Flutter dashboard and stays workflow", "Documentation-only annotations"),
    26: ("docs(app-rooms): [S1-ROOM] document Flutter room management", "Document Flutter room management workflow", "Documentation-only annotations"),
    27: ("docs(app-auth-ai): [S1-AUTH][S3-AI] document login and AI summary screens", "Document login and AI summary screens", "Documentation-only annotations"),
    28: ("docs(app-models-theme): [S1-UX][S1-FOUNDATION] document models and theme", "Document Flutter models and theme", "Documentation-only annotations"),
    29: ("docs(app-shared-ui): [S1-UX] document shared widgets and task controls", "Document shared widgets and task controls", "Documentation-only annotations"),
    30: ("docs(app-shell-users): [S1-USER] document application shell and account management", "Document application shell and account management", "Documentation-only annotations"),
    31: ("fix(dashboard-ai): [S3-DASH][S3-AI] close dashboard and AI gate gaps", "Close dashboard and AI delivery gate gaps", "Fix + test coverage"),
    32: ("feat(app): [S1-UX][S2-OPS][S3-DASH] UI/UX upgrade parent scope", "UI/UX upgrade parent scope; split into #33–#45", "Closed without merge; superseded by split PRs"),
    33: ("feat(ui): [S1-UX] semantic design tokens and touch foundation", "Semantic design tokens and touch-target foundation", "Code"),
}

records = {record["number"]: record for record in json.loads(AUDIT_PATH.read_text(encoding="utf-8"))}
if set(MAPPING) != set(range(1, 34)):
    raise RuntimeError("Mapping must cover PR #1 through #33 exactly")
OUTPUT_DIR.mkdir(exist_ok=True)
manifest = []
for number, (new_title, task_name, evidence) in MAPPING.items():
    record = records[number]
    state_text = f"Merged into `{record['baseRefName']}`" if record["state"] == "MERGED" else "Closed without merge"
    body = f"""## Backfilled task record

- **Task name tổng hợp:** {task_name}
- **Evidence treatment:** {evidence}
- **Historical state:** {state_text}
- **WBS link status:** Đây là PR lịch sử có phạm vi hỗn hợp hoặc trước khi tách 178 task lá. Không tự gán một WBS Issue cụ thể nếu không đủ bằng chứng từ file/commit.
- **Acceptance boundary:** Merge, code hoặc CI chỉ là delivery evidence. Chỉ task WBS có acceptance evidence phù hợp mới được chuyển `Done`.

<details>
<summary>Historical PR description</summary>

{record['body'] or '_Không có mô tả lịch sử._'}

</details>
"""
    body_path = OUTPUT_DIR / f"pr-{number}.txt"
    body_path.write_text(body, encoding="utf-8")
    manifest.append({
        "number": number,
        "old_title": record["title"],
        "new_title": new_title,
        "aggregate_task_name": task_name,
        "evidence_treatment": evidence,
        "state": record["state"],
        "base": record["baseRefName"],
        "url": record["url"],
        "body_file": str(body_path),
    })

(ROOT / ".codex-temp" / "all-pr-task-backfill-manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
print(json.dumps({"mapped": len(manifest), "changed_titles": sum(item["old_title"] != item["new_title"] for item in manifest)}, ensure_ascii=False))
