import json
from pathlib import Path

ROOT = Path(r"D:\Projects\KhachSanDiDong")
DATA_PATH = ROOT / ".codex-temp" / "evidence-register-data.json"
PR_PATH = ROOT / ".codex-temp" / "pr-backfill-manifest.json"
BODY_DIR = ROOT / ".codex-temp" / "wbs-issue-bodies"
MANIFEST_PATH = ROOT / ".codex-temp" / "wbs-issue-manifest.json"

data = json.loads(DATA_PATH.read_text(encoding="utf-8"))
prs = json.loads(PR_PATH.read_text(encoding="utf-8"))
BODY_DIR.mkdir(parents=True, exist_ok=True)

pr_by_wbs = {}
for pr in prs:
    for wbs_id in pr["wbs_candidates"]:
        pr_by_wbs.setdefault(wbs_id, []).append(pr)


def project_workstream(row):
    name = row["task_name"].lower()
    stream = row["workstream"].lower()
    if "khảo sát" in stream or "phỏng vấn" in stream:
        return "Discovery"
    if "kiến trúc" in stream or "contract" in stream:
        return "Architecture"
    if row["wbs_id"].startswith("S4-DAT") and any(term in name for term in ["github", "deploy", "release", "biến môi trường"]):
        return "DevOps"
    if row["wbs_id"].startswith("S4-DAT"):
        return "Project management"
    if "ai" in name or "ai summary" in stream:
        return "AI"
    if "dashboard" in stream:
        return "Dashboard"
    if row["wbs_id"].startswith("S4-HOANG") or "qa" in name or "kiểm thử" in name:
        return "QA"
    if row["wbs_id"].split("-")[1] == "BAO":
        return "Backend"
    if any(term in name for term in ["check-in", "check-out", "dọn", "bảo trì", "nhật ký", "vận hành"]):
        return "Operations"
    return "Flutter"


def acceptance_type(row):
    if row["wbs_id"].split("-")[1] == "DAT":
        return "Stakeholder sign-off" if row["reviewer"] == "Khách hàng" else "Reviewer approval"
    if row["wbs_id"].startswith("S4-HOANG") or "kiểm thử" in row["task_name"].lower():
        return "Reviewer approval"
    if row["wbs_id"].split("-")[1] == "HOANG":
        return "UAT"
    return "Reviewer approval"


def evidence_level(prs_for_wbs):
    labels = [pr["classification"] for pr in prs_for_wbs]
    if any("Code +" in label or "CI configuration" in label for label in labels):
        return "Code + test/CI"
    if any("Code only" in label or "Test source" in label for label in labels):
        return "Code"
    return "No evidence"


manifest = []
for row in data["rows"]:
    candidates = pr_by_wbs.get(row["wbs_id"], [])
    links = "\n".join(
        f"- [PR #{pr['number']}](https://github.com/DatTran26/khachsan-di-dong/pull/{pr['number']}): {pr['classification']}"
        for pr in candidates
    ) or "- Chưa có PR/commit được map vào task này."
    body = f"""## Outcome

{row['task_name']}

## Kế hoạch và ownership

- **WBS ID:** `{row['wbs_id']}`
- **Sprint:** {row['sprint']}
- **Workstream:** {row['workstream']}
- **Owner:** {row['owner'] or 'Chưa gán'}
- **KT / reviewer:** {row['reviewer'] or 'Chưa gán'}
- **Estimate:** {row['effort_hours']:g} giờ, chuẩn hóa {row['proposed_days']} ngày
- **Mốc tham chiếu:** {row['start'][:10]} đến {row['finish'][:10]}

## Đầu ra và acceptance

- **Đầu ra:** {row['deliverable']}
- **Acceptance bắt buộc:** {"Reviewer phê duyệt artefact" if row['wbs_id'].split('-')[1] == 'DAT' else 'Evidence kỹ thuật và review/UAT theo loại task'}

## Evidence hiện tại

- **Actual status:** {row['actual_status']}
- **Evidence level:** {evidence_level(candidates)}
- **Nguồn baseline:** {row['source_evidence'] or 'Chưa có bằng chứng trong repository ở baseline'}
{links}

## Điều kiện chuyển Đã xong

- [ ] Evidence phù hợp được gắn vào Issue và evidence register.
- [ ] {"Reviewer/khách hàng phê duyệt artefact." if row['wbs_id'].split('-')[1] == 'DAT' else 'Review hoặc UAT/sign-off phù hợp đã được xác nhận.'}

PR link ở trên có thể chỉ là evidence candidate. Không chuyển task sang `Done` chỉ vì PR đã merge.
"""
    body_file = BODY_DIR / f"{row['wbs_id']}.txt"
    body_file.write_text(body, encoding="utf-8")
    manifest.append({
        "wbs_id": row["wbs_id"],
        "title": f"{row['wbs_id']}: {row['task_name']}",
        "body_file": str(body_file),
        "owner": row["owner"],
        "sprint": row["sprint"],
        "workstream": project_workstream(row),
        "evidence_level": evidence_level(candidates),
        "acceptance_type": acceptance_type(row),
        "last_verified": "2026-10-28" if candidates else None,
        "kanban": "Review" if candidates else "Triage",
        "estimate": row["proposed_days"],
        "start": row["start"][:10],
        "target": row["finish"][:10],
    })

MANIFEST_PATH.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
print(json.dumps({"issue_count": len(manifest), "candidate_evidence_count": sum(item['kanban'] == 'Review' for item in manifest)}))
