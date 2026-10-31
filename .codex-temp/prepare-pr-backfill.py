import json
from pathlib import Path

ROOT = Path(r"D:\Projects\KhachSanDiDong")
SNAPSHOT = ROOT / ".codex-temp" / "historical-pr-snapshot.json"
OUTPUT = ROOT / ".codex-temp" / "pr-backfill-bodies"
MANIFEST = ROOT / ".codex-temp" / "pr-backfill-manifest.json"

MAPPING = {
    34: ("feat(ui): [S1-UX] loading skeletons and tablet layout foundation", "Code only", ["S1-HOANG-002", "S1-HOANG-003"]),
    35: ("feat(ui): [S1-UX] offline guidance and shared accessibility tokens", "Code only", ["S1-HOANG-003", "S1-HOANG-010"]),
    36: ("feat(shell): [S1-UX] responsive navigation and reconnect feedback", "Code only", ["S1-HOANG-002", "S3-HOANG-007"]),
    37: ("feat(dashboard): [S3-DASH] loading, refresh and room-search persistence", "Code only", ["S3-HOANG-002", "S3-HOANG-003", "S3-HOANG-009"]),
    38: ("feat(rooms): [S1-ROOM][S2-STAY] room controls and check-in shortcuts", "Code only", ["S1-HOANG-007", "S1-HOANG-008", "S2-HOANG-001"]),
    39: ("feat(app): [S1-ROOM][S2-STAY][S2-MNT] form validation and offline list UX", "Code only", ["S1-HOANG-012", "S2-HOANG-009"]),
    40: ("feat(operations): [S2-STAY][S2-MNT] checkout and maintenance task UX", "Code only", ["S2-HOANG-002", "S2-HOANG-006", "S2-HOANG-007"]),
    41: ("feat(housekeeping): [S2-HK] task list readability and mobile interaction", "Code only", ["S2-HOANG-003", "S2-HOANG-004"]),
    42: ("feat(admin): [S1-USER][S2-AUDIT] accounts and audit-screen UX", "Code only", ["S1-BAO-005", "S1-BAO-011", "S2-BAO-012"]),
    43: ("feat(app): [S1-AUTH][S3-AI] autofill and supporting-screen responsive UX", "Code only", ["S1-HOANG-005", "S3-HOANG-005"]),
    44: ("test(app): [S1-UX][S2-UX] shared-widget and feature-screen coverage", "Test source, CI evidence pending", ["S1-HOANG-014", "S1-HOANG-015", "S2-HOANG-010"]),
    45: ("test(ui): [S3-UX][S4-UAT] layout matrix and design-system checks", "Test/docs, manual accessibility pending", ["S3-HOANG-007", "S3-HOANG-011", "S4-HOANG-003", "S4-HOANG-006"]),
    46: ("ci(app): [S4-DEVOPS] Flutter analyze, test and web-build workflow", "CI configuration + passing check", ["S4-DAT-003"]),
    47: ("docs(project): [S4-PM] risk register and communication workbooks", "Reviewed artefact only", ["S4-DAT-001"]),
    48: ("docs(ui): [S3-UX] five-phase UI/UX upgrade specification", "Plan only", ["S3-HOANG-007", "S3-HOANG-011"]),
    49: ("docs(qa): [S3-UX] automated QA report and unresolved manual checks", "Historical QA report, gaps remain", ["S3-HOANG-008", "S3-HOANG-011", "S4-HOANG-003", "S4-HOANG-006"]),
    50: ("docs(dashboard): [S3-DASH] compact PMS room-tile redesign plan", "Plan only", ["S3-HOANG-001", "S3-HOANG-002", "S3-HOANG-007"]),
    51: ("docs(dashboard): [S3-DASH] room-tile mockups and interactive prototype", "Prototype only", ["S3-HOANG-001", "S3-HOANG-002"]),
    52: ("feat(dashboard): [S3-DASH] live stays-connected PMS room tiles", "Code + tests/CI; UAT pending", ["S3-HOANG-001", "S3-HOANG-002", "S3-HOANG-003"]),
    53: ("feat(app): [S1-AUTH][S2-OPS] login slideshow and duplicate-action guard", "Code + CI; UAT pending", ["S1-HOANG-005", "S2-HOANG-004", "S2-HOANG-007"]),
}

records = {item["number"]: item for item in json.loads(SNAPSHOT.read_text(encoding="utf-8"))}
OUTPUT.mkdir(parents=True, exist_ok=True)
manifest = []
for number, (title, classification, wbs_ids) in MAPPING.items():
    source = records[number]
    wbs = ", ".join(f"`{item}`" for item in wbs_ids)
    acceptance = (
        "Không dùng PR này làm UAT/sign-off. Chỉ chuyển task WBS sang Đã xong sau khi có acceptance evidence phù hợp."
        if "UAT pending" not in classification
        else "UAT/sign-off của Đạt vẫn đang chờ. Không chuyển task WBS sang Đã xong chỉ từ code hoặc CI."
    )
    body = f"""## Backfilled delivery record

- **WBS task candidates:** {wbs}
- **Evidence classification:** {classification}
- **Verified merge:** `{source['baseRefName']}` on {source['mergedAt'][:10]}
- **Acceptance boundary:** {acceptance}
- **Issue links:** Chưa tạo. Sẽ liên kết đến từng WBS Issue sau khi register được đưa lên GitHub Project.

Các mã WBS ở trên là phạm vi ứng viên đối chiếu từ file thay đổi và mô tả PR. Chúng không tự xác nhận rằng task đã hoàn thành.

<details>
<summary>Historical PR description</summary>

{source['body'].strip()}

</details>
"""
    body_file = OUTPUT / f"pr-{number}.txt"
    body_file.write_text(body, encoding="utf-8")
    manifest.append({
        "number": number,
        "old_title": source["title"],
        "new_title": title,
        "wbs_candidates": wbs_ids,
        "classification": classification,
        "body_file": str(body_file),
    })

MANIFEST.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
print(json.dumps({"count": len(manifest), "manifest": str(MANIFEST)}))
